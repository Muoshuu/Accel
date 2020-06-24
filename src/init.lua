local import = {} do
    import.modules = {}
    import.localDirectory = nil

    local importDebugger = {} do
        importDebugger.enabled = false

        function importDebugger.warn(str, ...)
            if importDebugger.enabled then
                warn(str:format(...))
            end
        end

        function importDebugger.print(str, ...)
            if importDebugger.enabled then
                print(str:format(...))
            end
        end
    end

    local function resolvePath(pathString, relativeInstance)
        local path = string.split(pathString, '/')
        local element = script

        for i, block in pairs(path) do
            importDebugger.warn('FROM %s', element and element:GetFullName() or 'nil')

            if not element then
                return nil, table.concat(path, '/', 1, i)
            end

            if i == 1 then
                if block == '.' then
                    element = relativeInstance or script

                    importDebugger.warn('-> SWITCH TO RELATIVE %s', element and element:GetFullName() or 'nil')

                    continue
                elseif block == '..' then
                    element = (relativeInstance or script).Parent

                    importDebugger.warn('-> USE RELATIVE %s', relativeInstance and relativeInstance:GetFullName() or 'nil')
                    importDebugger.warn('-> ASCEND INTO %s', element and element:GetFullName() or 'nil')

                    continue
                elseif block == '' then
                    element = game

                    importDebugger.warn('-> SWITCH TO ABSOLUTE %s', game.Name)

                    continue
                end
            end

            if block == '..' then
                element = element.Parent

                importDebugger.warn('-> ASCEND INTO %s', element and element:GetFullName() or 'nil')
            else
                if element == game then
                    local ok, service = pcall(game.GetService, game, block)

                    if ok then
                        element = service

                        importDebugger.warn('-> DESCEND INTO %s', element and element:GetFullName() or 'nil')
                    else
                        return nil, table.concat(path, '/', 1, i)
                    end
                else
                    local child = element:FindFirstChild(block)

                    if child then
                        element = child

                        importDebugger.warn('-> DESCEND INTO %s', element and element:GetFullName() or 'nil')
                    else
                        return nil, table.concat(path, '/', 1, i)
                    end
                end
            end
        end

        importDebugger.print('RESOLVED %s\n', element and element:GetFullName() or 'nil')

        return element
    end

    local function getImportWrapperFor(script)
        return function(path)
            return import(path, script)
        end
    end

    local function importModule(module)
        local data = require(module)

        if type(data) == 'function' then
            data = data(getImportWrapperFor(module))
        end

        import.modules[module] = data

        return data
    end

    function import:__call(arg, relativeInstance)
        local mode = typeof(arg)

        if mode == 'Instance' then
            if self.modules[arg] then
                return self.modules[arg]
            else
                if arg.ClassName == 'ModuleScript' then
                    return importModule(arg)
                else
                    error(('First argument to import must be either a string or a ModuleScript. Got %q'):format(tostring(arg)))
                end
            end
        elseif mode == 'string' then
            local module, failedAt = resolvePath(arg, relativeInstance)

            if module then
                return importModule(module)
            else
                local ok, service = pcall(function()
                    return game:GetService(arg)
                end)

                if ok then
                    return service
                end

                error(('Failed to resolve module from path %q at %q'):format(arg, tostring(failedAt)))
            end
        else
            error(('First argument to import must be either a string or a ModuleScript. Got %q'):format(tostring(arg)))
        end
    end

    setmetatable(import, import)

    for i, serviceModule in pairs(script:WaitForChild('Service'):GetChildren()) do
        import(serviceModule) -- // Initialize services
    end
end

return import