return function(import)
    local rbxDebug = debug

    local scriptContext = import 'ScriptContext'
    local logService = import 'LogService'

    local console = {} do
        console.profileBegin = rbxDebug.profilebegin
        console.profileEnd = rbxDebug.profileend
        console.traceback = rbxDebug.traceback

        console.print = print
        console.warn = warn
        console.error = error
        console.assert = assert

        console.onError = scriptContext.Error
        console.onOutput = logService.MessageOut

        function console.printf(str, ...)
            print(str:format(...))
        end

        function console.warnf(str, ...)
            warn(str:format(...))
        end

        function console.errorf(str, ...)
            error(str:format(...))
        end

        function console.assertf(condition, str, ...)
            assert(condition, str:format(...))
        end

        function console.getLogHistory()
            return logService:GetLogHistory()
        end
    end

    return console
end