return function(import)
    local Signal = import 'Class/Signal'
    local Promise = import 'Class/Promise'
    local Player = import './Player'

    local rbxPlayerSvc, rbxBadgeSvc, rbxGroupSvc, rbxSocialSvc, rbxRunService =
        import 'Players',
        import 'BadgeService',
        import 'GroupService',
        import 'SocialService',
        import 'RunService'

    local create, table =
        import 'Create',
        import 'Table'

    local common = import './Common'

    local playerService = {} do
        setmetatable(playerService, {
            __index = function(self, index)
                local ok, value = pcall(function() return rbxPlayerSvc[index:gsub('^.', string.upper)] end)

                if (ok and type(value) ~= 'function') then
                    return value
                end
            end
        })

        do -- // Players
            playerService.players = {}

            function playerService.getPlayer(arg)
                local mode = typeof(arg)

                if (mode == 'Instance') then
                    if (arg:IsA('Model')) then
                        return table.find(playerService.players, 'character', arg)
                    elseif (arg:IsA('Player')) then
                        return table.find(playerService.players, 'client', arg)
                    end
                elseif (mode == 'string') then
                    return table.find(playerService.players, 'name', arg)
                elseif (mode == 'number') then
                    return table.find(playerService.players, 'id', arg)
                end
            end

            playerService.getNameFromId = common.getNameFromId
            playerService.getIdFromName = common.getIdFromName
            playerService.getAppearanceFromId = common.getCharacterAppearance
            playerService.getAppearanceInfoFromId = common.getCharacterAppearanceInfo
            playerService.getHumanoidDescriptionFromOutfitId = common.getHumanoidDescriptionFromOutfitId
            playerService.getHumanoidDescriptionFromUserId = common.getHumanoidDescriptionFromUserId
            playerService.getUserThumbnail = common.getUserThumbnail

            do -- // Events
                playerService.onPlayerJoin = Signal.new()
                playerService.onPlayerLeave = Signal.new()
                playerService.onPlayerMembershipChange = Signal.new()

                local function eventHandler(plr, eventName)
                    local player = playerService.getPlayer(plr)

                    if (player) then
                        playerService[eventName]:fire(player)
                    end
                end

                rbxPlayerSvc.PlayerAdded:Connect(function(plr)
                    if (not playerService.getPlayer(plr)) then
                        table.insert(playerService.players, Player.new(plr))

                        eventHandler(plr, 'onPlayerJoin')
                    end
                end)

                rbxPlayerSvc.PlayerRemoving:Connect(function(plr)
                    eventHandler(plr, 'onPlayerLeave')

                    table.expel(playerService.players, playerService.getPlayer(plr))
                end)

                rbxPlayerSvc.PlayerMembershipChanged:Connect(function(plr)
                    eventHandler(plr, 'onPlayerMembershipChange')
                end)

                if (rbxRunService:IsClient()) then -- // LocalPlayer
                    local plr = rbxPlayerSvc.LocalPlayer

                    if (plr) then
                        if (not playerService.getPlayer(plr)) then
                            local player = Player.new(plr)

                            playerService.localPlayer = player
                            table.insert(playerService.players, player)

                            eventHandler(plr, 'onPlayerJoin')
                        end
                    end
                end
            end
        end

        do -- // SocialService
            playerService.onGameInvitePromptClose = Signal.new()

            rbxSocialSvc.GameInvitePromptClosed:Connect(function(plr, recipients)
                local player = playerService.getPlayer(plr)

                if (player) then
                    playerService.onGameInvitePromptClose:fire(player, recipients)
                end
            end)
        end

        do -- // GroupService
            local convertGroupInfo = function(object)
                local group = {
                    id = object.Id,
                    name = object.Name,
                    description = object.Description,

                    iconId = object.EmblemUrl:match('%d-$') or 0,

                    roles = {},

                    owner = {
                        id = object.Owner.Id,
                        name = object.Owner.Name
                    }
                }

                for i, role in pairs(object.Roles) do
                    table.insert(group.roles, { name = role.Name, rank = role.Rank })
                end

                return group
            end

            function playerService.getGroupInfo(groupId)
                return Promise.async(function(resolve, reject)
                    common.getGroupInfo(groupId):andThen(function(groupInfo)
                        resolve(convertGroupInfo(groupInfo))
                    end)
                end)
            end

            function playerService.getGroupAllies(groupId, returnPages)
                return Promise.async(function(resolve, reject)
                    common.getGroupAllies(groupId):andThen(function(pages)
                        if (returnPages) then
                            resolve(pages)
                        else
                            resolve(table.fromPages(pages, function(object)
                                return convertGroupInfo(object)
                            end))
                        end
                    end):catch(reject)
                end)
            end

            function playerService.getGroupEnemies(groupId, returnPages)
                return Promise.async(function(resolve, reject)
                    common.getGroupEnemies(groupId):andThen(function(pages)
                        if (returnPages) then
                            resolve(pages)
                        else
                            resolve(table.fromPages(pages, function(object)
                                return convertGroupInfo(object)
                            end))
                        end
                    end):catch(reject)
                end)
            end
        end

        do -- // BadgeService
            playerService.awardBadge = common.awardBadge
            playerService.getBadgeOwnership = common.userHasBadge

            function playerService.getBadgeInfo(id)
                return Promise.async(function(resolve, reject)
                    common.getBadgeInfo(id):andThen(function(badgeInfo)
                        resolve({
                            name = badgeInfo.Name,
                            description = badgeInfo.Description,
                            iconId = badgeInfo.IconImageId,
                            isEnabled = badgeInfo.IsEnabled
                        })
                    end):catch(reject)
                end)
            end
        end
    end

    return playerService
end