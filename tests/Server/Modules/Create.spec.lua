local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local create = import 'Create'
    local workspace = import 'Workspace'

    it('should return a function that creates an instance when called', function()
        local instanceCreator = create('Part', workspace, 'Some Part') 

        expect(instanceCreator).to.be.a('function')

        local instance = instanceCreator {
            Position = Vector3.new(0, 100, 0),
            Anchored = true
        }

        expect(instance).to.be.ok()
        expect(instance.Name).to.equal('Some Part')
        expect(instance.Parent).to.equal(workspace)
        expect(instance.Position).to.equal(Vector3.new(0, 100, 0))
        expect(instance.Anchored).to.equal(true)

        instance:Destroy()
    end)

    describe('Create.folder', function()
        it('should create a folder with the specified name and parent', function()
            local folder = create.folder(workspace, 'Folder Name')

            expect(folder).to.be.ok()
            expect(folder.Name).to.equal('Folder Name')
            expect(folder.Parent).to.equal(workspace)

            folder:Destroy()
        end)
    end)
end