local replicatedStorage = game:GetService('ReplicatedStorage')

local testEZModule = script.Parent.TestEZ;
local engineModule = replicatedStorage:WaitForChild('Accel')

testEZModule.Parent = game:GetService('ReplicatedStorage')

local testEZ = require(testEZModule)

wait(1)

local tests = {} do
    for i, folder in pairs(script:GetChildren()) do
        for i, module in pairs(folder:GetChildren()) do
            if (module.Name:sub(-4) == 'spec') then
                table.insert(tests, module)
            end
        end
    end
end

testEZ.TestBootstrap:run(tests)