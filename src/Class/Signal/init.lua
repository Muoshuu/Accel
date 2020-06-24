return function(import)
    local class = import 'Class'
    
    local Signal = class.new('Signal') do
        function Signal:init()
            self._connections = {}
        end

        local SignalConnection = import './Connection'

        do -- // Prototype
            function Signal.prototype:Connect(fn)
                local connection = SignalConnection.new(self, fn)

                connection:reconnect()

                return connection
            end

            Signal.prototype.connect = Signal.prototype.Connect

            function Signal.prototype:fire(...)
                for _, connection in pairs(self._connections) do
                    connection:fire(...)
                end
            end

            function Signal.prototype:await()
                local bindable = Instance.new('BindableEvent')

                local connection = self:connect(function(...)
                    bindable:Fire(...)
                end)

                local data = { bindable.Event:wait() }

                connection:disconnect()
                bindable:destroy()

                return unpack(data)
            end
        end
    end

    return Signal
end