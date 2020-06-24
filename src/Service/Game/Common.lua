return function(import)
    local Promise = import 'Class/Promise'

    local assetService = import 'AssetService'

    return {
        createPlaceInPlayerInventory = Promise.promisify(function(...)
            return assetService:CreatePlaceInPlayerInventoryAsync(...)
        end),

        createPlace = Promise.promisify(function(...)
            return assetService:CreatePlaceAsync(...)
        end),

        savePlace = Promise.promisify(function(...)
            return assetService:SavePlace(...)
        end),

        getPlaces = Promise.promisify(function(...)
            return assetService:GetGamePlacesAsync(...)
        end)
    }
end