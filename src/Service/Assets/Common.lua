return function(import)
    local Promise = import 'Class/Promise'

    local insertService = import 'InsertService'
    local marketService = import 'MarketplaceService'
    local assetService = import 'AssetService'

    return {
        loadAsset = Promise.promisify(function(assetId)
            return insertService:LoadAsset(assetId)
        end),

        loadAssetVersion = Promise.promisify(function(assetVersionId)
            return insertService:LoadAssetVersion(assetVersionId)
        end),

        isPlayerSubscribed = Promise.promisify(function(player, subscriptionId)
            return marketService:IsPlayerSubscribed(player, subscriptionId)
        end),

        getBundleDetails = Promise.promisify(function(bundleId)
            return assetService:GetBundleDetailsAsync(bundleId)
        end),

        getProductInfo = Promise.promisify(function(assetId, assetType)
            return marketService:GetProductInfo(assetId, assetType)
        end),

        promptCancelSubscription = Promise.promisify(function(player, subscriptionId)
            return marketService:PromptSubscriptionCancellation(player, subscriptionId)
        end),

        playerOwnsAsset = Promise.promisify(function(player, assetId)
            return marketService:PlayerOwnsAsset(player, assetId)
        end),

        userOwnsGamePass = Promise.promisify(function(playerId, gamePassId)
            return marketService:UserOwnsGamePassAsync(playerId, gamePassId)
        end),

        isPlayerSubscribed = Promise.promisify(function(player, subscriptionId)
            return marketService:IsPlayerSubscribed(player, subscriptionId)
        end),

        getDeveloperProducts = Promise.promisify(function()
            return marketService:GetDeveloperProductsAsync()
        end)
    }
end