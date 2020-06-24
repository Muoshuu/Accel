return function(import)
    local Promise = import 'Class/Promise'

    local guiService = import 'GuiService'
    local starterGui = import 'StarterGui'
    local userInputService = import 'UserInputService'
    local contextActionService = import 'ContextActionService'
    local hapticService = import 'HapticService'
    local localizationService = import 'LocalizationService'
    local vrService = import 'VRService'

    local function safeIndex(object, key)
        local ok, value = pcall(function() return object[key] end)

        if (ok) then
            return value, true
        else
            return nil, false
        end
    end

    local getFirstValue = function(key, objects)
        for i, object in pairs(objects) do
            local value = safeIndex(object, key)

            if (value) then
                return value, object
            end
        end
    end

    local getObjectWithKey = function(key, objects)
        for i, object in pairs(objects) do
            local value, exists = safeIndex(object, key)

            if (exists) then
                return object
            end
        end
    end

    local function proxy(...)
        local objects = {...}

        return setmetatable({}, {
            __index = function(self, key)
                local value, object = getFirstValue(key, objects)

                if (type(value) == 'function') then
                    rawset(self, key, function(self, ...)
                        return value(object, ...)
                    end)

                    return self[key]
                else
                    return value
                end
            end,

            __newindex = function(self, key, value)
                local object = getObjectWithKey(key, objects)

                if (object) then
                    object[key] = value
                end
            end
        })
    end

    local interfaceService = {} do
        do -- // Localization Service
            function interfaceService.getTranslatorForLocale(locale)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(localizationService.GetTranslatorForLocaleAsync, localizationService, locale)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function interfaceService.getTranslatorForPlayer(player)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(localizationService.GetTranslatorForPlayerAsync, localizationService, player)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end

            function interfaceService.getCountryRegionForPlayer(player)
                return Promise.async(function(resolve, reject)
                    local ok, result = pcall(localizationService.GetCountryRegionForPlayerAsync, localizationService, player)

                    if (ok) then
                        resolve(result)
                    else
                        reject(result)
                    end
                end)
            end
        end

        do -- // Haptic Service
            interfaceService.haptics = proxy(hapticService)
        end

        do -- // VR Service
            interfaceService.vr = proxy(vrService)
        end

        do -- // Gui Service & StarterGui
            interfaceService.gui = proxy(starterGui, guiService)
        end

        do -- // UserInput & ContextAction Services
            interfaceService.input = proxy(userInputService, contextActionService)
        end
    end

    return interfaceService
end