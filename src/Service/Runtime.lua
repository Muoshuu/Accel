return function(import)
    local runService = import 'RunService'

    local runtimeService = {} do
        runtimeService.renderStepped = runService.RenderStepped
        runtimeService.heartbeat = runService.Heartbeat
        runtimeService.stepped = runService.Stepped

        runtimeService.isServer = runService:IsServer()
        runtimeService.isClient = runService:IsClient()
        runtimeService.isStudio = runService:IsStudio()

        function runtimeService.bindToRenderStepped(fn, priority)
            if priority then
                local name = tostring(tick())

                runService:BindToRenderStep(name, priority, fn)

                return { connected = true, Disconnect = function(self)
                    self.connected = false

                    runService:UnbindFromRenderStep(name)
                end }
            else
                return runService.RenderStepped:Connect(fn)
            end
        end

        function runtimeService.bindToHeartbeat(fn)
            return runService.Heartbeat:Connect(fn)
        end

        function runtimeService.bindToStepped(fn)
            return runService.Stepped:Connect(fn)
        end
    end

    return runtimeService
end