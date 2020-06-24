return function(import)
    local Promise = import 'Class/Promise'

    local debris, chat = import 'Debris', 'Chat'

    local collectionService = import 'CollectionService'
    local textService = import 'TextService'
    local tweenService = import 'TweenService'
    local physicsService = import 'PhysicsService'
    local pathfindingService = import 'PathfindingService'

    local utilityService = {} do
        utilityService.stats = import 'Stats'

        function utilityService.addToDebris(...)
            debris:AddItem(...)
        end

        function utilityService.registerChatCallback(...)
            chat:RegisterChatCallback(...)
        end

        function utilityService.createPath(params)
            return pathfindingService:CreatePath(({
                AgentRadius = params.width,
                AgentHeight = params.height,
                AgentCanJump = params.canJump
            }))
        end

        function utilityService.createTween(...)
            return tweenService:Create(...)
        end

        function utilityService.getAlpha(...)
            return tweenService:GetValue(...)
        end

        do -- // Collection Service
            function utilityService.addTag(...)
                return collectionService:AddTag(...)
            end

            function utilityService.removeTag(...)
                return collectionService:RemoveTag(...)
            end

            function utilityService.hasTag(...)
                return collectionService:HasTag(...)
            end

            function utilityService.getTags(...)
                return collectionService:GetTags(...)
            end

            function utilityService.getTagged(...)
                return collectionService:GetTagged(...)
            end

            function utilityService.getInstanceAddedSignal(...)
                return collectionService:GetInstanceAddedSignal(...)
            end

            function utilityService.getInstanceRemovedSignal(...)
                return collectionService:GetInstanceRemovedSignal(...)
            end
        end

        do -- // Text Service
            local filterString = Promise.promisify(function(...)
                return textService:FilterStringAsync(...)
            end)

            function utilityService.filterString(...)
                return filterString(...)
            end
        end

        do -- // Physics Service
            local methods = {
                'CollisionGroupContainsPart',
                'CollisionGroupSetCollidable',
                'CreateCollisionGroup',
                'GetCollisionGroupId',
                'GetCollisionGroupName',
                'GetCollisionGroups',
                'GetMaxCollisionGroups',
                'RemoveCollisionGroup',
                'RenameCollisionGroup',
                'SetPartCollisionGroup',
            }

            for _, method in pairs(methods) do
                utilityService[method:gsub('^.', string.lower)] = physicsService[method]
            end
        end
    end

    return utilityService
end