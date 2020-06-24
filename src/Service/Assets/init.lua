return function(import)
    local marketService = import 'MarketplaceService'
    local runService = import 'RunService'

    local Promise = import 'Class/Promise'
    local Signal = import 'Class/Signal'

    local common = import './Common'
    local table = import 'Table'

    local assetService = {} do
        function assetService.insert(assetId)
            return common.loadAsset(assetId)
        end

        function assetService.insertVersion(versionId)
            return common.loadAssetVersion(versionId)
        end

        function assetService.getBundleInfo(bundleId)
            return Promise.async(function(resolve, reject)
                common.getBundleDetails(bundleId):andThen(function(info)
                    local bundle = {}

                    bundle.id = info.id
                    bundle.name = info.Name
                    bundle.description = info.Description
                    bundle.type = info.BundleType
                    bundle.price = 0 -- TODO: Find a way to retrieve bundle price

                    bundle.assets = {}

                    for _, asset in pairs(info.Items) do
                        table.insert(bundle.assets, {
                            id = asset.Id,
                            name = asset.Name,
                            type = asset.Type
                        })
                    end

                    resolve(bundle)
                end):catch(reject)
            end)
        end

        function assetService.getAssetInfo(assetId, assetInfoType)
            return Promise.async(function(resolve, reject)
                common.getProductInfo(assetId, assetInfoType):andThen(function(info)
                    local asset = {}

                    if assetInfoType == Enum.InfoType.Asset then
                        asset.id = info.AssetId
                    elseif assetInfoType == Enum.InfoType.Product then
                        asset.id = info.ProductId
                    elseif assetInfoType == Enum.InfoType.GamePass then
                        asset.id = info.TargetId
                    elseif assetInfoType == Enum.InfoType.Bundle then
                        reject('Cannot get bundle info from assetService.getAssetInfo; use assetService.getBundleInfo instead')
                    else
                        reject(('Unsuported asset type %q passed to assetService.getAssetInfo'):format(assetInfoType.Name))
                    end

                    asset.kind = assetInfoType
                    asset.name = info.Name
                    asset.description = info.Description
                    asset.price = info.PriceInRobux
                    asset.sales = info.Sales
                    asset.createdAt = info.Created
                    asset.updatedAt = info.Updated
                    asset.type = info.AssetTypeId
                    asset.productType = info.ProductTypeId

                    asset.creator = {
                        id = info.Creator.Id,
                        name = info.Creator.Name,
                        target = info.Creator.CreatorTargetId,
                        type = info.Creator.CreatorType
                    }

                    asset.status = {
                        isNew = info.IsNew,
                        isFree = info.IsFree,
                        isLimited = info.IsLimited,
                        isLimitedUnique = info.IsLimitedUnique,
                        unitsRemaining = info.Remaining
                    }

                    resolve(asset)
                end):catch(reject)
            end)
        end

        function assetService.promptPurchase(player, assetId, assetInfoType)
            return Promise.async(function(resolve, reject)
                if assetInfoType == Enum.InfoType.Asset then
                    marketService:PromptPurchase(player, assetId)
                elseif assetInfoType == Enum.InfoType.Product then
                    marketService:PromptProductPurchase(player, assetId)
                elseif assetInfoType == Enum.InfoType.GamePass then
                    marketService:PromptGamePassPurchase(player, assetId)
                elseif assetInfoType == Enum.InfoType.Subscription then
                    marketService:PromptSubscriptionPurchase(player, assetId)
                elseif assetInfoType == Enum.InfoType.Bundle then
                    reject('Cannot prompt to purchase a bundle yet') -- TODO: Find a way to prompt bundle purchase
                else
                    reject(('Unsuported asset type %q passed to assetService.promptPurchase'):format(assetInfoType.Name))
                end

                while true do
                    local purchaser, id, infoType, purchased = assetService.promptPurchaseFinished:await()

                    if purchaser == player and id == assetId and infoType == assetInfoType then
                        return resolve(player, assetId, assetInfoType, purchased)
                    end
                end
            end)
        end

        function assetService.promptCancelSubscription(player, subscriptionId)
            return common.promptCancelSubscription(player, subscriptionId)
        end

        function assetService.getSubscriptionStatus(player, subscriptionId)
            return common.isPlayerSubscribed(player, subscriptionId)
        end

        function assetService.getOwnership(player, assetId, assetInfoType)
            return Promise.async(function(resolve, reject)
                if assetInfoType == Enum.InfoType.Asset then
                    common.playerOwnsAsset(player, assetId):andThen(resolve):catch(reject)
                elseif assetInfoType == Enum.InfoType.GamePass then
                    common.userOwnsGamePass(player.UserId, assetId):andThen(resolve):catch(reject)
                elseif assetInfoType == Enum.InfoType.Bundle then
                    reject('Cannot get bundle ownership yet. For now, check ownership of an asset that cannot be obtained without bundle purchase') -- TODO: Find a way to get bundle ownership
                else
                    reject(('Unsupported assset type %q passed to assetService.getOwnership'):format(assetInfoType.Name))
                end
            end)
        end

        function assetService.getDeveloperProducts(returnPages)
            return Promise.async(function(resolve, reject)
                common.getDeveloperProducts():andThen(function(pages)
                    if returnPages then
                        resolve(pages)
                    else
                        resolve(table.fromPages(pages, function(object)
                            return {
                                id = object.ProductId,
                                name = object.Name,
                                price = object.Price,
                                iconId = object.IconImageAssetId
                            }
                        end))
                    end
                end):catch(reject)
            end)
        end

        function assetService.setReceiptProcessor(fn)
            assetService.receiptProcessor = fn
        end
    end

    do -- // Setup
        local self = assetService

        self.onPromptPurchaseFinished = Signal.new()
        self.onPromptCancelSubscriptionFinished = Signal.new()

        if runService:IsServer() then
            local receiptProcessor = function(receiptInfo)
                local handler = self.receiptProcesssor

                if handler then
                    receiptInfo.receiptId = receiptInfo.PurchaseId
                    receiptInfo.placeId = receiptInfo.PlaceIdWherePurchased
                    receiptInfo.playerId = receiptInfo.PlayerId
                    receiptInfo.productId = receiptInfo.ProductId
                    receiptInfo.currencySpent = receiptInfo.CurrencySpent

                    local ok, result = pcall(handler, receiptInfo)

                    if ok then
                        if typeof(result) == 'EnumItem' and Enum.ProductPurchaseDecision.PurchaseGranted.EnumType == Enum.ProductPurchaseDecision then
                            return result
                        elseif result == true then
                            return Enum.ProductPurchaseDecision.PurchaseGranted
                        else
                            return Enum.ProductPurchaseDecision.NotProcessedYet
                        end
                    else
                        warn(('A purchase was made, but the receipt processor errored. Error: %s'):format(tostring(result)))
                    end
                else
                    warn(('A purchase was made, but no receipt processor exists. Purchase ID: %s'):format(tostring(receiptInfo.PurchaseId)))
                end

                return Enum.ProductPurchaseDecision.NotProcessedYet
            end

            marketService.ProcessReceipt = receiptProcessor
        end

        marketService.PromptGamePassPurchaseFinished:Connect(function(player, id, purchased)
            self.onPromptPurchaseFinished:fire(player, id, Enum.InfoType.GamePass, purchased)
        end)

        marketService.PromptPurchaseFinished:Connect(function(player, id, purchased)
            self.onPromptPurchaseFinished:fire(player, id, Enum.InfoType.Asset, purchased)
        end)

        marketService.PromptSubscriptionPurchaseFinished:Connect(function(player, id, purchased)
            self.onPromptPurchaseFinished:fire(player, id, Enum.InfoType.Subscription, purchased)
        end)

        marketService.PromptSubscriptionCancellationFinished:Connect(function(player, id, canceled)
            self.onPromptCancelSubscriptionFinished:fire(player, id, canceled)
        end)
    end

    return assetService
end