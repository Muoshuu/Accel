local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local class = import 'Class'
    local httpService = import 'HttpService'

    describe('Class.new', function()
        local Object

        it('should create a class and return it', function()
            Object = class.new('Object')

            function Object:init(value)
                self.key = value
            end

            expect(Object).to.be.ok()
            expect(Object.name).to.equal('Object')
        end)

        describe('CustomClass.new', function()
            it('should return an instance', function()
                local instance = Object.new()

                expect(instance).to.be.ok()
            end)

            describe('CustomClass.meta', function()
                it('should correctly be applied', function()
                    function Object.meta:tostring()
                        return 'im a string'
                    end

                    expect(tostring(Object.new())).to.equal('im a string')
                end)
            end)

            describe('CustomClass.prototype', function()
                it('should correctly be applied', function()
                    function Object.prototype:method()
                        return self.key
                    end

                    local instance = Object.new('sup')

                    expect(instance).to.be.ok()
                    expect(instance:method()).to.equal('sup')
                end)
            end)

            describe('Instance of CustomClass', function()
                it('should be garbage collected when no references exist', function()
                    local instance = Object.new()

                    expect(#Object.instances).never.to.equal(0)

                    instance = nil

                    wait(1)

                    expect(#Object.instances).to.equal(0)
                end)

                describe('Instance.iter', function()
                    it('should iterate over an instance\'s key/value pairs', function()
                        local instance = Object.new('Hello world!')
                        local values = {}
            
                        for i, v in instance:iter() do
                            table.insert(values, v)
                        end
            
                        expect(#values).to.equal(1)
                        expect(values[1]).to.equal('Hello world!')
                    end)
                end)

                describe('Instance.delete', function()
                    it('should correctly delete a key', function()
                        local instance = Object.new()

                        expect(instance.method).to.be.a('function')
                        
                        instance.method = 'test'

                        expect(instance.method).to.equal('test')

                        instance:delete('method')

                        expect(instance.method).to.be.a('function')
                    end)
                end)

                describe('Instance.toJSON', function()
                    it('should correctly convert an instance to JSON', function()
                        local instance = Object.new('Hello world!')
                        local json = instance:toJSON()
                        local table = httpService:JSONDecode(json)

                        expect(table.key).to.equal('Hello world!')
                    end)
                end)

                describe('Instance.destroy', function()
                    it('should remove all properties and metamethods', function()
                        local instance = Object.new('Hello world!')

                        expect(instance.key).to.equal('Hello world!')

                        instance:destroy()

                        expect(instance.key).never.to.be.ok()
                        expect(instance.method).never.to.be.ok()
                        expect(getmetatable(instance)).never.to.be.ok()
                    end)
                end)
            end)
        end)
    end)
end