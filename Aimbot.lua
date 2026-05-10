return function(Core, State)
    local Players = Core.Players
    local RunService = Core.RunService
    local UserInputService = Core.UserInputService
    local isSameTeam = Core.isSameTeam
    local isTargetVisible = Core.isTargetVisible

    function State.getClosest()
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local closestTarget = nil
        local closestDistance = math.huge
        local localPlayer = Players.LocalPlayer
        local maxDistance = 400
        if not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        local screenCenter = camera.ViewportSize / 2
        
        local players = Players:GetPlayers()
        for i = 1, #players do
            local player = players[i]
            if player ~= localPlayer then
                local character = player.Character
                if character and not character:FindFirstChild("ForceField") then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0.09 then
                        if not State.teamCheckEnabled or not isSameTeam(player) then
                            local part = character:FindFirstChild(State.lockPart)
                            if part then
                                local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
                                if onScreen then
                                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                                    local distFromCenter = (screenPos - screenCenter).Magnitude
                                    if not State.fovCircleEnabled or distFromCenter <= State.fov then
                                        if distFromCenter < closestDistance then
                                            local distance = (character.HumanoidRootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                                            if distance <= maxDistance then
                                                if not State.wallCheckEnabled or isTargetVisible(part) then
                                                    closestDistance = distFromCenter
                                                    closestTarget = player
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    function State.getClosestSilent()
        local camera = workspace.CurrentCamera
        if not camera then return nil end
        local screenCenter = camera.ViewportSize / 2
        local closestTarget = nil
        local closestDistance = State.SilentAimState.FOVEnabled and State.SilentAimState.FOV or math.huge
        local maxDistance = 400
        local char = Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("Head") then return nil end
        local myHead = char.Head.Position
        
        local players = Players:GetPlayers()
        for i = 1, #players do
            local player = players[i]
            if player ~= Players.LocalPlayer then
                local character = player.Character
                if character and not character:FindFirstChild("ForceField") then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
                        if not State.SilentAimState.TeamCheck or not isSameTeam(player) then
                            local head = character:FindFirstChild("Head")
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            if hrp and head then
                                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                                if onScreen then
                                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                                    local distFromCenter = (screenVector - screenCenter).Magnitude
                                    if not State.SilentAimState.FOVEnabled or distFromCenter <= State.SilentAimState.FOV then
                                        if distFromCenter <= maxDistance then
                                            local direction = (head.Position - myHead).Unit
                                            local distance = (head.Position - myHead).Magnitude
                                            local raycastParams = RaycastParams.new()
                                            raycastParams.FilterDescendantsInstances = {char}
                                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                            raycastParams.IgnoreWater = true
                                            local result = workspace:Raycast(myHead, direction * distance, raycastParams)
                                            local isVisible = (result == nil) or (result.Instance and result.Instance:IsDescendantOf(character))
                                            if isVisible and distFromCenter < closestDistance then
                                                closestDistance = distFromCenter
                                                closestTarget = player
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return closestTarget
    end

    function State.lockOntoTarget(target)
        if not target or not target.Character then
            State.targetLocked = false
            return
        end
        
        local camera = workspace.CurrentCamera
        local aimPart = target.Character:FindFirstChild(State.lockPart)
        if not aimPart then
            State.targetLocked = false
            return
        end
        
        local aimPos = aimPart.Position
        local currentScreenPos = camera:WorldToViewportPoint(aimPos)
        
        if not State.targetLocked or State.currentTarget ~= target then
            State.smoothedTargetPos = Vector2.new(currentScreenPos.X, currentScreenPos.Y)
            State.targetLocked = true
        else
            State.smoothedTargetPos = State.smoothedTargetPos:Lerp(
                Vector2.new(currentScreenPos.X, currentScreenPos.Y), 0.15
            )
        end
        
        local mousePos = UserInputService:GetMouseLocation()
        local delta = State.smoothedTargetPos - mousePos
        local moveFraction = math.clamp(State.smoothnessValue, 0.05, 1.0)
        
        if delta.Magnitude > 1 then
            mousemoverel(delta.X * moveFraction, delta.Y * moveFraction)
        end
    end

    local lastTriggerTime = 0
    function State.setupTriggerbot()
        RunService:BindToRenderStep("Triggerbot", 0, function()
            if not State.triggerbotEnabled then return end
            
            if tick() - lastTriggerTime < 0.05 then return end
            lastTriggerTime = tick()
            
            local camera = workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {Players.LocalPlayer.Character}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            
            if result then
                local hit = result.Instance
                local hum = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
                if hum and hum.Parent ~= Players.LocalPlayer.Character and hum.Health > 0.1
                   and (not State.teamCheckEnabled or not isSameTeam(Players:GetPlayerFromCharacter(hum.Parent))) then
                    pcall(function()
                        mouse1press()
                        task.delay(0.01, mouse1release)
                    end)
                end
            end
        end)
    end

    function State.removeTriggerbot()
        RunService:UnbindFromRenderStep("Triggerbot")
    end
end
