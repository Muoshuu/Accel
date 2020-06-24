return function(import)
    local class = import 'Class'
    local table = import 'Table'

    local Promise = import 'Class/Promise'

    local socialService = import 'SocialService'
    local common = import './../Common'

    local Player = class.new('Player') do
        function Player:init(client)
            self.client = client

            self.onCharacterSpawn = client.CharacterAdded
            self.onCharacterDespawn = client.CharacterRemoving
            self.onAppearanceLoad = client.CharacterAppearanceLoaded
            self.onChat = client.Chatted
            self.onIdle = client.Idled
            self.onTeleport = client.OnTeleport
        end

        do -- // Prototype
            do -- // Getters & Setters
                local readOnly = {
                    'AccountAge',
                    'FollowUserId',
                    'LocaleId',
                    'MembershipType',
                    'UserId',
                    'Name'
                }

                local readAndWrite = {
                    'AutoJumpEnabled',
                    'CameraMaxZoomDisstance',
                    'CameraMinZoomDistance',
                    'CameraMode',
                    'CanLoadCharacterAppearance',
                    'Character',
                    'CharacterAppearanceId',
                    --'DevCameraOcclusionMode',
                    --'DevComputerCameraMode',
                    --'DevComputerMovementMode',
                    --'DevEnableMouseLock',
                    --'DevTouchCameraMode',
                    --'DevTouchMovementMode',
                    'DisplayName',
                    'GameplayPaused',
                    'HealthDisplayDistance',
                    'NameDisplayDistance',
                    --'Neutral',
                    'ReplicationFocus',
                    'RespawnLocation',
                    --'Team',
                    --'TeamColor'
                }

                local aliases = {
                    ['UserId'] = 'Id'
                }

                for i, key in pairs(readOnly) do
                    local name = aliases[key] or key

                    Player.prototype['get' .. name] = function(self)
                        return self.client[key]
                    end
                end

                for i, key in pairs(readAndWrite) do
                    local name = aliases[key] or key

                    Player.prototype['set' .. name] = function(self, value)
                        self.client[key] = value
                    end

                    Player.prototype['get' .. name] = function(self)
                        return self.client[key]
                    end
                end
            end

            function Player.prototype:getRegion()
                return common.getRegion(self.client)
            end

            function Player.prototype:getTranslator()
                return common.getTranslator(self.client)
            end

            function Player.prototype:getFriends(returnPages)
                return Promise.async(function(resolve, reject)
                    common.getFriends(self.id):andThen(function(pages)
                        if (returnPages) then
                            resolve(pages)
                        else
                            resolve(table.fromPages(pages, function(object)
                                return {
                                    id = object.Id,
                                    name = object.Username,
                                    isOnline = object.IsOnline
                                }
                            end))
                        end
                    end):catch(reject)
                end)
            end

            function Player.prototype:getFriendsOnline(limit)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(self.client.GetFriendsOnline, self.client, limit)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:getIsFriendsWith(id)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(self.client.IsFriendsWith, self.client, id)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:getGroups()
                return Promise.async(function(resolve, reject)
                    common.getGroups(self.id):andThen(function(groups)
                        local groupList = {}

                        for i, group in pairs(groups) do
                            table.insert(groupList, {
                                id = group.Id,
                                name = group.Name,
                                iconId = group.EmblemId,
                                rank = group.Rank,
                                role = group.Role,
                                isPrimary = group.IsPrimary,
                                isInClan = group.IsInClan
                            })
                        end

                        resolve(groupList)
                    end):catch(reject)
                end)
            end

            function Player.prototype:isInGroup(id)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(self.client.IsInGroup, self.client, id)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:getRankInGroup(id)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(self.client.GetRankInGroup, self.client, id)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:getRoleInGroup(id)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(self.client.GetRoleInGroup, self.client, id)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:awardBadge(id)
                return common.awardBadge(self.id, id)
            end

            function Player.prototype:getBadgeOwnership(id)
                return common.userHasBadge(self.id, id)
            end

            function Player.prototype:getAppearance(...)
                return common.getCharacterAppearance(self.id, ...)
            end

            function Player.prototype:getAppearanceInfo(...)
                return common.getCharacterAppearanceInfo(self.id, ...)
            end

            function Player.prototype:getHumanoidDescription()
                return common.getHumanoidDescriptionFromUserId(self.id)
            end

            function Player.prototype:getThumbnail(...)
                return common.getUserThumnail(self.id, ...)
            end

            function Player.prototype:clearAppearance(...)
                return self.client:ClearCharacterAppearance(...)
            end

            function Player.prototype:hasAppearanceLoaded(...)
                return self.client:HasAppearanceLoaded(...)
            end

            function Player.prototype:getJoinData(...)
                return self.client:GetJoinData(...)
            end

            function Player.prototype:getMouse(...)
                return self.client:GetMouse(...)
            end

            function Player.prototype:kick(...)
                return self.client:kick(...)
            end

            function Player.prototype:spawn()
                return Promise.async(function(resolve, reject)
                    local ok, err = pcall(self.client.LoadCharacter, self.client)

                    if (ok) then
                        resolve()
                    else
                        reject(err)
                    end
                end)
            end

            function Player.prototype:move(...)
                self.client:move(...)
            end

            function Player.prototype:requestStreamAround(position, timeout)
                return Promise.async(function(resolve, reject)
                    local ok, err = pcall(self.client.RequestStreamAroundAsync, self.client, position, timeout)

                    if (ok) then
                        resolve()
                    else
                        reject(err)
                    end
                end)
            end

            function Player.prototype:promptGameInvite(arg)
                socialService:PromptGameInvite(self.client)
            end

            function Player.prototype:getWhetherUserCanSendGameInvite(arg)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(socialService.CanSendGameInviteAsync, socialService, self.client)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function Player.prototype:getWhetherUserCanChat()
                return common.canUserChat(self.id)
            end

            function Player.prototype:getWhetherUsersCanChat(...)
                return Promise.all(table.map({...}, function(userId)
                    return common.canUsersChat(self.id, userId)
                end))
            end
        end
    end

    return Player
end
