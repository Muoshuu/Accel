return function(import)
    local class, create, console =
        import 'Class',
        import 'Create',
        import 'Console'

    local runtimeService = import 'Service/Runtime'

    local NetworkChannel = class.new('NetworkChannel') do
        function NetworkChannel:init(name, emitter)
            self.name = name
            self.listeners = {}

            if (runtimeService.isServer) then
                self.emitter = create('RemoteEvent', nil, self._id)()
            elseif (emitter) then
                self.emitter = emitter
            else
                console.errorf('Cannot create a network channel on the client without an existing RemoteEvent')
            end

            local function eventHandler(eventName, arg, ...)
                if (runtimeService.isServer) then
                    eventName, arg = arg, eventName
                end

                local listeners = self.listeners[eventName]

                if (listeners) then
                    for _, listener in pairs(listeners) do
                        listener(arg, ...)
                    end
                end
            end

            if (runtimeService.isServer) then
                self._fire = self.emitter.FireClient
                self._fireAll = self.emitter.FireAllClients
            else
                self._fire = self.emitter.FireServer
            end

            self.emitter[('On%sEvent'):format(runtimeService.isServer and 'Server' or 'Client')]:connect(eventHandler)
        end

        do -- // Prototype
            function NetworkChannel.prototype:fire(...)
                self._fire(self.emitter, ...)
            end

            function NetworkChannel.prototype:broadcast(...)
                self._fireAll(self.emitter, ...)
            end

            function NetworkChannel.prototype:on(eventName, fn)
                local listeners = self.listeners[eventName]

                if (not listeners) then
                    listeners = {}

                    self.listeners[eventName] = listeners
                end

                listeners[#listeners+1] = fn
            end

            function NetworkChannel.prototype:once(eventName, fn)
                local listeners = self.listeners[eventName]

                if (not listeners) then
                    listeners = {}

                    self.listeners[eventName] = listeners
                end

                local wrapper; wrapper = function(...)
                    for i, v in pairs(listeners) do
                        if (v == wrapper) then
                            table.remove(listeners, i)
                        end
                    end

                    fn(...)
                end

                listeners[#listeners+1] = wrapper
            end
        end
    end

    return NetworkChannel
end