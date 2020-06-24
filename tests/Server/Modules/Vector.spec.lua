local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local vec = import 'Vector'
    
    local lookVector = (
        CFrame.Angles(math.random() * math.pi, math.random() * math.pi, math.random() * math.pi ) *
        CFrame.new( math.random() * 1000, math.random() * 1000, math.random() * 1000 )
        
    ).LookVector

    describe('Vector.toSpherical', function()
        it('should return rho, theta, and phi with acceptable precision', function()
            local rho, theta, phi = vec.toSpherical(lookVector)

            expect(rho).to.be.near(1)
            expect(theta).to.be.ok()
            expect(phi).to.be.ok()
        end)
    end)

    describe('Vector.fromSpherical', function()
        it('should return a Vector3 value with acceptable precision', function()
            local rho, theta, phi = vec.toSpherical(lookVector)
            local vector = vec.fromSpherical(rho, theta, phi)

            expect(vector.magnitude).to.be.near(1)

            expect(vector.x).to.be.near(lookVector.x)
            expect(vector.y).to.be.near(lookVector.y)
            expect(vector.z).to.be.near(lookVector.z)

            -- we lose some precision during conversion due to machine epsilon :(
        end)
    end)
end