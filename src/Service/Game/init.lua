return function(import)
    local common = import './Common'
    local assetService = import 'AssetService'
    local runService = import 'RunService'
    local table = import 'Table'

    local Promise = import 'Class/Promise'

    local gameService = {} do
        function gameService.createPlace(...)
            return common.createPlace(...)
        end

        function gameService.createPlaceFor(...)
            return common.createPlaceInPlayerInventory(...)
        end

        function gameService.savePlace()
            return common.savePlace()
        end

        function gameService.getPlaces(returnPages)
            return Promise.async(function(resolve, reject)
                common.getPlaces():andThen(function(pages)
                    if (returnPages) then
                        resolve(pages)
                    else
                        resolve(table.fromPages(pages, function(object)
                            return {
                                id = object.PlaceId,
                                name = object.Name
                            }
                        end))
                    end
                end):catch(reject)
            end)
        end

        function gameService.isLoaded()
            return game:IsLoaded()
        end

        function gameService.bindToClose(fn)
            game:BindToClose(fn)
        end
    end

    do -- // Init
        gameService.id = game.GameId
        gameService.creator = { id = game.CreatorId, type = game.CreatorType }
        gameService.place = { id = game.PlaceId, version = game.PlaceVersion }

        gameService.server = {
            id = game.JobId,

            loaded = Promise.async(function(resolve, reject)
                if (not game:IsLoaded()) then
                    game.Loaded:wait()
                end

                resolve()
            end)
        }

        if (runService:IsServer()) then
            gameService.server.reservedId = game.PrivateServerId
            gameService.server.ownerId = game.PrivateServerOwnerId

            gameService.server.isStandard = game.PrivateServerId == ''
            gameService.server.isPrivate = game.PrivateServerId ~= '' and game.PrivateServerOwnerId == 0
            gameService.server.isReserved = game.PrivateServerId ~= '' and game.PrivateServerOwnerId ~= 0
        end
    end

    return gameService
end