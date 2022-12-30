--!nonstrict

local ERROR = {
	DESTROYED_SIGNAL = 'Attempted to call Signal::%s on a destroyed Signal',
	INVALID_ARG_TYPE = 'Argument passed to Signal::%s must be a %s, but a %s was passed'
}

local function assertf(condition: boolean, str: string, ...)
	if not condition then
		error(str:format(...), 0)
	end
end

local Connection = {} do
	local meta = {
		__index = {
			Disconnect = function(self)
				self.Signal:Disconnect(self)
			end
		},

		__tostring = function()
			return 'Instance of Connection'
		end
	}

	function Connection.new(signal, listener)
		local this = setmetatable({
			Signal = signal,
			Listener = listener,

			Connected = true

		}, meta)
		
		table.insert(signal.Connections, this)
		
		return this
	end

	function Connection.is(value)
		if type(value) == 'table' and getmetatable(value) == meta then
			return true
		end

		return false
	end
end

local Signal = {} do
	local meta = {
		__index = {
			Connect = function(self, listener)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'Connect')
				assertf(type(listener) == 'function', ERROR.INVALID_ARG_TYPE, 'Connect', 'function', typeof(listener))

				return Connection.new(self, listener)
			end,

			ConnectOnce = function(self, listener)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'ConnectOnce')
				assertf(type(listener) == 'function', ERROR.INVALID_ARG_TYPE, 'ConnectOnce', 'function', typeof(listener))

				local temp; temp = self:Connect(function(...)
					if temp then
						temp:Disconnect()
					end

					listener(...)
				end)

				return temp
			end,

			Disconnect = function(self, connection)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'Disconnect')
				assertf(Connection.is(connection), ERROR.INVALID_ARG_TYPE, 'Disconnect', 'Connection', typeof(connection))

				table.remove(self.Connections, table.find(self.Connections, connection) or 0)

				connection.Connected = false
			end,

			DisconnectAll = function(self)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'DisconnectAll')

				for _, connection in pairs(self.Connections) do
					self:Disconnect(connection)
				end
			end,

			Destroy = function(self)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'Destroy')

				self:DisconnectAll()
				self.Destroyed = true
			end,

			Wait = function(self)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'Wait')

				local thread = coroutine.running()

				local temp; temp = self:Connect(function(...)
					if temp then
						self:Disconnect(temp)

						task.spawn(thread, ...)
					end
				end)

				return coroutine.yield()
			end,

			Fire = function(self, ...)
				assertf(not self.Destroyed, ERROR.DESTROYED_SIGNAL, 'Fire')

				for _, connection in pairs(self.Connections) do
					task.spawn(connection.Listener, ...)
				end
			end
		},

		__tostring = function()
			return 'Instance of Signal'
		end,
	}

	function Signal.new()
		return setmetatable({
			Destroyed = false,
			Connections = {}

		}, meta)
	end

	function Signal.is(value)
		if type(value) == 'table' and getmetatable(value) == meta then
			return true
		end

		return false
	end
end

Signal.Connection = Connection

return Signal