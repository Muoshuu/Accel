return function(import)
    local Promise = import 'Class/Promise'

    local playerService = import 'Players'
    local socialService = import 'SocialService'
    local groupService = import 'GroupService'
    local badgeService = import 'BadgeService'
    local chatService = import 'Chat'
    local localizationService = import 'LocalizationService'

    local list = {
        ['getCharacterAppearance'] = { playerService, 'GetCharacterAppearanceAsync' },
        ['getCharacterAppearanceInfo'] = { playerService, 'GetCharacterAppearanceInfoAsync' },
        ['getFriends'] = { playerService, 'GetFriendsAsync' },
        ['getHumanoidDescriptionFromOutfitId'] = { playerService, 'GetHumanoidDescriptionFromOutfitId' },
        ['getHumanoidDescriptionFromUserId'] = { playerService, 'GetHumanoidDescriptionFromUserId' },
        ['getNameFromId'] = { playerService, 'GetNameFromUserIdAsync' },
        ['getIdFromName'] = { playerService, 'GetUserIdFromNameAsync' },
        ['getUserThumbnail'] = { playerService, 'GetUserThumbnailAsync' },
        ['canSendGameInvite'] = { socialService, 'CanSendGameInviteAsync' },
        ['getGroupAllies'] = { groupService, 'GetAlliesAsync' },
        ['getGroupEnemies'] = { groupService, 'GetEnemiesAsync' },
        ['getGroupInfo'] = { groupService, 'GetGroupInfoAsync' },
        ['getGroups'] = { groupService, 'GetGroupsAsync' },
        ['getBadgeInfo'] = { badgeService, 'GetBadgeInfoAsync' },
        ['userHasBadge'] = { badgeService, 'UserHasBadgeAsync' },
        ['awardBadge'] = { badgeService, 'AwardBadge' },
        ['canUserChat'] = { chatService, 'CanUserChatAsync' },
        ['canUsersChat'] = { chatService, 'CanUsersChatAsync' },
        ['getRegion'] = { localizationService, 'GetCountryRegionForPlayerAsync' },
        ['getTranslator'] = { localizationService, 'GetTransltorForPlayer' },
    }

    for key, info in pairs(list) do
        list[key] = Promise.promisify(function(...)
            return info[1][info[2]](info[1], ...)
        end)
    end

    return list
end