local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local Signal = import 'Class/Signal'
    local SignalConnection = import 'Class/Signal/Connection'

    describe('SignalConnection.new', function()
        local signal = Signal.new()

        expect(signal).to.be.ok()

        it('should return an instance of the SignalConnection class', function()
            local connection = SignalConnection.new(signal, function() end)

            expect(connection).to.be.ok()
        end)

        describe('SignalConnection.fire', function()
            it('should call its listener function', function()
                local called = false

                local connection = SignalConnection.new(signal, function()
                    called = true
                end)

                connection:fire()

                expect(called).to.equal(true)
            end)
        end)

        describe('SignalConnection.disconnect', function()
            it('should disconnect itself from its parent Signal', function()
                local called = false

                local connection = signal:connect(function()
                    called = true
                end)

                connection:disconnect()
                signal:fire()

                expect(called).to.equal(false)
            end)
        end)

        describe('SignalConnection.reconnect', function()
            it('should reconnect to its parent instance', function()
                local called = false

                local connection = signal:connect(function()
                    called = true
                end)

                connection:disconnect()
                signal:fire()

                expect(called).to.equal(false)
                
                connection:reconnect()
                signal:fire()
                
                expect(called).to.equal(true)
            end)
        end)
    end)

    describe('Signal.new', function()
        it('should return an instance of the Signal class', function()
            local signal = Signal.new()

            expect(signal).to.be.ok()
        end)

        describe('Signal.fire', function()
            it('should fire the signal, calling all listeners', function()
                local signal = Signal.new()

                signal:fire(1, 2, 3)
            end)
        end)

        describe('Signal.connect', function()
            it('should connect the passed listener to the signal instance, returning a SignalConnection', function()
                local signal = Signal.new()
                
                signal:connect(function(a, b, c, nothing)
                    expect(a).to.equal(1)
                    expect(b).to.equal(2)
                    expect(c).to.equal(3)
                    expect(nothing).never.to.be.ok()
                end)

                signal:fire(1, 2, 3)
            end)
        end)

        describe('Signal.await', function()
            it('should wait for the signal to be fired and return the result', function()
                local signal = Signal.new()

                delay(0.5, function()
                    signal:fire(1, 2)
                end)

                local a, b, c = signal:await()

                expect(a).to.equal(1)
                expect(b).to.equal(2)
                expect(c).never.to.be.ok()
            end)
        end)
    end)
end