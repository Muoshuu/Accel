return function(import)
    local Promise = import 'Class/Promise'
    local Signal = import 'Class/Signal'

    local HttpRequest = import './HttpRequest'
    local DataStore = import './DataStore'
    local NetworkChannel = import './NetworkChannel'

    local create, table, console, lzw, string =
        import 'Create',
        import 'Table',
        import 'Console',
        import 'LZW',
        import 'String'

    local storageService, messagingService, dataService, runtimeService =
        import 'ReplicatedStorage',
        import 'MessagingService',
        import 'DataStoreService',
        import 'Service/Runtime'

    local networkService = {} do
        local self = networkService

        self.HttpRequest = HttpRequest
        self.DataStore = DataStore
        self.NetworkChannel = NetworkChannel

        do -- // In-game Networking
            self.channels = {}
            self.onChannelCreated = Signal.new()

            function self.getChannel(name, timeout)
                if (self.channels[name]) then
                    return Promise.resolve(self.channels[name])
                else
                    timeout = tonumber(timeout) or 5

                    return Promise.async(function(resolve, reject)
                        local done = false

                        coroutine.wrap(function()
                            while (not done) do
                                local newChannelName = self.onChannelCreated:await()

                                if (done) then return end

                                if (self.channels[name]) then
                                    done = true; return resolve(self.channels[name])
                                end
                            end
                        end)()

                        wait(timeout)

                        if (not done) then
                            done = true; reject(string.format('Request for channel %q timed out (%d)', name, timeout))
                        end
                    end)
                end
            end

            function self.createChannel(name, emitter)
                if (self.channels[name]) then
                    console.errorf('Network channel %q already exists', name)
                else
                    local channel = NetworkChannel.new(name, emitter)

                    if (runtimeService.isServer and self.channelContainer) then
                        channel.emitter.Parent = self.channelContainer
                    end

                    self.channels[name] = channel
                    self.onChannelCreated:fire(name)

                    return channel
                end
            end
        end

        do -- // DataStoreService
            function self.getDataStore(...)
                return DataStore.new(...)
            end

            function self.getDataStoreRequestBudget(requestType)
                return dataService:GetRequestBudgetForRequestType(requestType)
            end
        end

        do -- // HttpService
            function self.createHttpRequest(...)
                return HttpRequest.new(...)
            end
        end

        do -- // MessagingService
            local maxLength = 800

            local chunksReceived = {}

            local function combineChunks(chunks, fn)
                local index, data = 1, ''

                local isCompressed = false
                local isJSON = false

                chunksReceived[chunks[1].cacheId] = nil

                while (#chunks > 0) do
                    for i, chunk in pairs(chunks) do
                        if (chunk.index == 1) then
                            isCompressed = chunk.isCompressed
                            isJSON = chunk.isJSON
                        end

                        if (chunk.index == index) then
                            table.remove(chunks, i)

                            index += 1
                            data ..= chunk.data

                            break
                        end
                    end
                end

                if (isCompressed) then
                    data = lzw.decompress(data)
                end

                return (isJSON and table.fromJSON(data)) or data
            end

            function self.broadcast(topic, message)
                return Promise.async(function(resolve, reject)
                    local isJSON = type(message) == 'table'
                        message = (isJSON and table.toJSON(message)) or tostring(message)

                    local compressed = lzw.compress(message)
                        message = (#compressed < #message and compressed) or message

                    local isCompressed = message == compressed

                    local chunks, count = {}, math.ceil(#message/maxLength)

                    while (#message > 0) do
                        table.insert(chunks, message:sub(1, maxLength))

                        message = message:sub(maxLength+1)
                    end

                    local cacheId = string.derivedId(16)

                    for i, chunkData in pairs(chunks) do
                        local chunk = { data = chunkData, index = i, cacheId = cacheId, siblings = count }

                        if (i == 1) then
                            chunk.isCompressed = isCompressed
                            chunk.isJSON = isJSON
                        end

                        local ok, result = pcall(function()
                            messagingService:PublishAsync(topic, table.toJSON(chunk))
                        end)

                        if (not ok) then
                            return reject(result)
                        end
                    end

                    resolve(cacheId)
                end)
            end

            function self.subscribe(topic, fn)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(function()
                        return messagingService:SubscribeAsync(topic, function(message)
                            local chunk = table.fromJSON(message.Data)

                            if (chunk.siblings == 1) then
                                fn(combineChunks({ chunk }))
                            else
                                local chunks = chunksReceived[chunk.cacheId]

                                if (chunks) then
                                    chunks[#chunks+1] = chunk

                                    if (#chunks == chunk.siblings) then
                                        fn(combineChunks(chunks))
                                    end
                                else
                                    chunksReceived[chunk.cacheId] = { chunk }
                                end
                            end
                        end)
                    end)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end
        end

        coroutine.wrap(function() -- Replicator
            local INTERNAL_CHANNEL_NAME = '__INTERNAL__'
            local CHANNEL_CONTAINER_NAME = 'Emitters'

            if (runtimeService.isServer) then
                self.channelContainer = create.folder(script, CHANNEL_CONTAINER_NAME)
                self.internalChannel = create('RemoteEvent', self.channelContainer, INTERNAL_CHANNEL_NAME)()

                self.onChannelCreated:connect(function(name)
                    local channel = self.channels[name]

                    if (channel) then
                        self.internalChannel:FireAllClients('NEW_CHANNELS', {{ name = channel.name, emitter = channel.emitter }})
                    end
                end)

                self.internalChannel.OnServerEvent:Connect(function(client, eventName)
                    if (eventName == 'READY_FOR_LIST') then
                        local list = table.map(self.channels, function(channel)
                            return { name = channel.name, emitter = channel.emitter }
                        end)

                        self.internalChannel:FireClient(client, 'NEW_CHANNELS', list)
                    end
                end)
            else
                self.channelContainer = script:WaitForChild(CHANNEL_CONTAINER_NAME)
                self.internalChannel = self.channelContainer:WaitForChild(INTERNAL_CHANNEL_NAME)

                self.internalChannel.OnClientEvent:connect(function(eventName, ...)
                    if (eventName == 'NEW_CHANNELS') then
                        local list = (...)

                        for _, channel in pairs(list) do
                            self.createChannel(channel.name, channel.emitter)
                        end
                    end
                end)

                self.internalChannel:FireServer('READY_FOR_LIST')
            end
        end)()
    end

    return networkService
end