return function(import)
    local Class = import 'Class'

    local SignalConnection = Class.new('SignalConnection') do
        function SignalConnection:init(parent, fn)
            self.parent = parent
            self.fn = fn
            
            self.connected = false
        end

        do -- // Prototype
            function SignalConnection.prototype:fire(...)
                self.fn(...)
            end

            function SignalConnection.prototype:Reconnect()
                self.connected = true

                table.insert(self.parent._connections, self)
            end

            function SignalConnection.prototype:Disconnect()
                table.remove(self.parent._connections, table.find(self.parent._connections, self) or -1)

                self.connected = false

                return self
            end

            SignalConnection.prototype.disconnect = SignalConnection.prototype.Disconnect
            SignalConnection.prototype.reconnect = SignalConnection.prototype.Reconnect
        end
    end

    return SignalConnection
end