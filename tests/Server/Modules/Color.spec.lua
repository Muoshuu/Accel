local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local color = import 'Color'

    describe('Color.toInt', function()
        it('should correctly convert a Color3 value to an integer', function()
            local int = color.toInt(Color3.fromRGB(255, 95, 95))

            expect(int).to.equal(16736095)
        end)
    end)

    describe('Color.fromInt', function()
        it('should correctly convert an integer into a Color3 value', function()
            local color3 = color.fromInt(16736095)

            expect(color3.r).to.be.near(1)
            expect(color3.g).to.be.near(95/255)
            expect(color3.b).to.be.near(95/255)
        end)
    end)

    describe('Color.toHex', function()
        it('should correctly convert a Color3 value to hexadecimal', function()
            local hex = color.toHex(Color3.fromRGB(255, 95, 95))

            expect(hex).to.equal('ff5f5f')
        end)
    end)

    describe('Color.fromHex', function()
        it('should correctly convert hexadecimal into a Color3 value', function()
            local color3 = color.fromHex('ff5f5f')

            expect(color3.r).to.be.near(1)
            expect(color3.g).to.be.near(95/255)
            expect(color3.b).to.be.near(95/255)
        end)
    end)
end