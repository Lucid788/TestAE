return function(Core, State, FOVCircle, SilentFOVCircle)
    local Players = Core.Players
    local RunService = Core.RunService
    local Lighting = Core.Lighting
    local setThirdPerson = Core.setThirdPerson

    function State.updateESP(camera)
        local now = tick()
        if not State.espBoxEnabled and not State.espLineEnabled then return end
        if now - (State.lastESPSweep or 0) < 0.15 then return end
        State.lastESPSweep = now
        
        local localPlayer = Players.LocalPlayer
        local players = Players:GetPlayers()
        
        for i = 1, #players do
            local plr = players[i]
            if plr ~= localPlayer then
                local char = plr.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then

                    if State.espBoxEnabled then
                        local box = State.espBoxes[plr]
                        if not box then
                            box = Drawing.new("Square")
                            box.Thickness = 1
                            box.Transparency = 1
                            box.Filled = false
                            State.espBoxes[plr] = box
                        end
                        box.Color = State.espBoxColor
                        local v, onScreen = camera:WorldToViewportPoint(root.Position)
                        if onScreen then
                            local h, w = 5, 3
                            local tl = camera:WorldToViewportPoint(root.Position + Vector3.new(-w/2, h/2, 0))
                            local br = camera:WorldToViewportPoint(root.Position + Vector3.new(w/2, -h/2, 0))
                            box.Size = Vector2.new(math.abs(tl.X - br.X), math.abs(tl.Y - br.Y))
                            box.Position = Vector2.new(math.min(tl.X, br.X), math.min(tl.Y, br.Y))
                            box.Visible = true
                        else
                            box.Visible = false
                        end
                    end
                    
                    if State.espLineEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local line = State.espLines[plr]
                        if not line then
                            line = Drawing.new("Line")
                            line.Thickness = 1.5
                            line.Transparency = 1
                            State.espLines[plr] = line
                        end
                        local localRoot = localPlayer.Character.HumanoidRootPart
                        local distance = (root.Position - localRoot.Position).Magnitude
                        if distance <= 225 then
                            local sp = camera:WorldToViewportPoint(localRoot.Position)
                            local ep = camera:WorldToViewportPoint(root.Position)
                            if sp.Z > 0 and ep.Z > 0 then
                                line.From = Vector2.new(sp.X, sp.Y)
                                line.To = Vector2.new(ep.X, ep.Y)
                                line.Color = State.espLineColor
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                else
                    if State.espBoxes[plr] then State.espBoxes[plr].Visible = false end
                    if State.espLines[plr] then State.espLines[plr].Visible = false end
                end
            end
        end
    end

    function State.updateFOVCircle(camera)
        if FOVCircle then
            FOVCircle.Position = camera.ViewportSize / 2
        end
        if SilentFOVCircle then
            if State.SilentAimState.Enabled and State.SilentAimState.FOVEnabled and State.SilentAimState.FOVVisible then
                SilentFOVCircle.Position = camera.ViewportSize / 2
                SilentFOVCircle.Visible = true
            else
                SilentFOVCircle.Visible = false
            end
        end
    end

    function State.setupAntiFlashbang()
        local player = Players.LocalPlayer
        local Flashed = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.Flashed)
        Flashed.Flash = function() end
    end

    State.thirdPersonConnection = nil
    function State.enableThirdPerson()
        setThirdPerson(true)
        if Players.LocalPlayer.Character then
            task.wait(0.1)
            setThirdPerson(true)
        end
        State.thirdPersonConnection = Players.LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.1)
            setThirdPerson(true)
        end)
    end

    function State.disableThirdPerson()
        setThirdPerson(false)
        if State.thirdPersonConnection then
            State.thirdPersonConnection:Disconnect()
            State.thirdPersonConnection = nil
        end
    end

    function State.setupColorCorrection()
        if not State.ccEffect then
            State.ccEffect = Instance.new("ColorCorrectionEffect")
            State.ccEffect.Parent = Lighting
        end
        State.ccEffect.TintColor = State.ccTintColor
        State.ccEffect.Saturation = State.ccSaturation
        State.ccEffect.Contrast = State.ccContrast
        State.ccEffect.Brightness = State.ccBrightness
    end

    function State.removeColorCorrection()
        if State.ccEffect then
            State.ccEffect:Destroy()
            State.ccEffect = nil
        end
    end
end
