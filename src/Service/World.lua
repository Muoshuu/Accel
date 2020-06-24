return function(import)
    local workspace = import 'Workspace'
    local lighting = import 'Lighting'
    local sound = import 'SoundService'

    local create = import 'Create'

    local worldService = setmetatable({
        sound = sound,

        lighting = setmetatable({
            blur = lighting:FindFirstChildOfClass('BlurEffect') or create('BlurEffect', lighting, 'Blur') { Enabled = false },
            color = lighting:FindFirstChildOfClass('ColorCorrectionEffect') or create('ColorCorrectionEffect', lighting, 'Color') { Enabled = false },
            bloom = lighting:FindFirstChildOfClass('BloomEffect') or create('BloomEffect', lighting, 'Bloom') { Enabled = false },
            sunRays = lighting:FindFirstChildOfClass('SunRaysEffect') or create('SunRaysEffect', lighting, 'Sun') { Enabled = false },
            depthOfField = lighting:FindFirstChildOfClass('DepthOfFieldEffect') or create('DepthOfFieldEffect', lighting, 'DOF') { Enabled = false }
        }, { __index = lighting, __newindex = lighting })
    }, { __index = workspace, __newindex = workspace })

    return worldService
end