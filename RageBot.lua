return function(Core, State)
    local Players = Core.Players
    local RunService = Core.RunService
    local getMech = Core.getMech

    State.rageBotEnabled = false
    State.rageBotConnections = {}
    
    State.rageAttackTime = 0.3
    State.rageVoidTime = 0.5
    State.rageVoidStrength = 50
    
    State.rageOffsetX = 0
    State.rageOffsetY = -2
    State.rageOffsetZ = -1

    local function isReadySpawn(v, lplr, spawnTimes)
        if not v or not v.Character or v == lplr then return false end
        local hum = v.Character:FindFirstChild("Humanoid")
        local hrp = v.Character:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp and hum.Health > 0) then return false end
        if v:GetAttribute("TeamID") == lplr:GetAttribute("TeamID") then return false end
        if (tick() - (spawnTimes[v.UserId] or 0) < 5.5) then return false end
        if v.Character:FindFirstChildOfClass("ForceField") then return false end
        return true
    end

    local function getClosestTarget(players, lplr, spawnTimes)
        local t, d = nil, math.huge
        if not lplr.Character or not lplr.Character:FindFirstChild("HumanoidRootPart") then return nil end
        local myPos = lplr.Character.HumanoidRootPart.Position
        local playerList = players:GetPlayers()
        for i = 1, #playerList do
            local v = playerList[i]
            if isReadySpawn(v, lplr, spawnTimes) then
                local mag = (myPos - v.Character.HumanoidRootPart.Position).Magnitude
                if mag < d then
                    d = mag
                    t = v
                end
            end
        end
        return t
    end

    local function getStrategy(targetPlayer)
        local viewModels = workspace:FindFirstChild("ViewModels")
        if not viewModels or not targetPlayer then return "attack" end
        local pName = targetPlayer.Name
        local children = viewModels:GetChildren()
        for i = 1, #children do
            local model = children[i]
            if model:IsA("Model") and model.Name:find(pName) then
                local separator = model.Name:find(" - ", 1, true)
                if separator then
                    local name = model.Name:sub(separator + 3):lower()
                    if name:find("katana") then return "wait" end
                    if name:find("riot") or name:find("shield") then return "backstep" end
                end
            end
        end
        return "attack"
    end

    local function hasSlingshot(lplr)
        local viewModels = workspace:FindFirstChild("ViewModels")
        if not viewModels then return false end
        local firstPerson = viewModels:FindFirstChild("FirstPerson")
        if not firstPerson then return false end
        local pName = lplr.Name
        local children = firstPerson:GetChildren()
        for i = 1, #children do
            local model = children[i]
            if model:IsA("Model") and model.Name:find(pName) and model.Name:lower():find("slingshot") then
                return true
            end
        end
        return false
    end

    local function applyVoidTeleport(hrp, strength)
        strength = math.min(strength, 1000)
        local radius = 50 + (strength * 5)
        local pos = hrp.Position + Vector3.new(
            math.random(-radius, radius),
            math.random(-radius, radius),
            math.random(-radius, radius)
        )
        hrp.CFrame = CFrame.new(pos) * CFrame.Angles(
            math.rad(math.random(-180, 180)),
            math.rad(math.random(-180, 180)),
            math.rad(math.random(-180, 180))
        )
    end

    local function initRageBot()
        local rs = game:GetService("ReplicatedStorage")
        local lplr = Players.LocalPlayer
        
        local utilModule = rs:FindFirstChild("Modules")
        if not utilModule then return false, "Modules not found" end
        
        local util = utilModule:FindFirstChild("Utility")
        if not util then return false, "Utility not found" end
        
        local enumsModule = rs.Modules:FindFirstChild("EnumLibrary")
        if not enumsModule then return false, "EnumLibrary not found" end
        
        local fighterController = lplr.PlayerScripts:FindFirstChild("Controllers")
        if not fighterController then return false, "Controllers not found" end
        
        local fighter = fighterController:FindFirstChild("FighterController")
        if not fighter then return false, "FighterController not found" end
        
        local utilReq = require(util)
        local enums = require(enumsModule)
        local fighterReq = require(fighter)
        
        local spawnTimes = {}
        local currentTarget = nil
        local targetStartTime = 0
        local clientc, clientv, clientva
        local phase = "attack"
        local phaseStartTime = tick()
        local lastLogTime = 0
        local lastTargetCheck = 0
        local lastStrategyTime = 0
        local cachedStrategy = "attack"
        local cachedSlingshot = false
        
        local function track(p)
            p.CharacterAdded:Connect(function()
                spawnTimes[p.UserId] = tick()
            end)
            if p.Character then
                spawnTimes[p.UserId] = tick()
            end
        end
        
        Players.PlayerAdded:Connect(track)
        local playerList = Players:GetPlayers()
        for i = 1, #playerList do
            track(playerList[i])
        end
        
        local fpsUpdateElapsed = 0
        local fpsUpdateFrameCount = 0
        local cachedFps = 60
        local fpsUpdateInterval = 10
        
        local lastHeartbeat = nil
        local attackHeartbeatConn = RunService.Heartbeat:Connect(function(deltaTime)
            if not State.rageBotEnabled then return end
            
            fpsUpdateElapsed = fpsUpdateElapsed + deltaTime
            fpsUpdateFrameCount = fpsUpdateFrameCount + 1
            if fpsUpdateElapsed >= fpsUpdateInterval then
                cachedFps = fpsUpdateFrameCount / fpsUpdateElapsed
                fpsUpdateElapsed = 0
                fpsUpdateFrameCount = 0
            end
            
            local dynamicInterval = math.max(0.005, 1 / (cachedFps + 10))
            local now = tick()
            if lastHeartbeat and (now - lastHeartbeat) < dynamicInterval then return end
            lastHeartbeat = now
            
            if now - lastLogTime > 5 then
                lastLogTime = now
                print(string.format("[RageBot] FPS: %d | Interval: %.3fs | Phase: %s | Target: %s",
                    cachedFps, dynamicInterval, phase, currentTarget and currentTarget.Name or "None"))
            end
            
            local char = lplr.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            clientc = hrp.CFrame
            clientv = hrp.AssemblyLinearVelocity
            clientva = hrp.AssemblyAngularVelocity
            
            if not fighterReq or not fighterReq.LocalFighter then return end
            local item = fighterReq.LocalFighter.EquippedItem
            if not item then return end
            
            if now - lastTargetCheck > 0.2 then
                lastTargetCheck = now
                if not currentTarget or not isReadySpawn(currentTarget, lplr, spawnTimes) or (now - targetStartTime > 10) then
                    currentTarget = getClosestTarget(Players, lplr, spawnTimes)
                    targetStartTime = now
                end
            end
            
            if not currentTarget then
                phase = "void"
                return
            end
            
            if now - lastStrategyTime > 0.3 then
                lastStrategyTime = now
                cachedStrategy = getStrategy(currentTarget)
                cachedSlingshot = hasSlingshot(lplr)
            end
            
            if cachedStrategy == "wait" then return end
            
            if cachedSlingshot then
                phase = "void"
                applyVoidTeleport(hrp, State.rageVoidStrength)
                local camCF = CFrame.lookAt(
                    workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 100,
                    workspace.CurrentCamera.CFrame.Position
                )
                local cameradata = {[utf8.char(1)] = {
                    [utf8.char(0)] = utilReq:EncodeCFrame(workspace.CurrentCamera.CFrame),
                    [utf8.char(1)] = utilReq:EncodeCFrame(camCF),
                    [utf8.char(2)] = workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 50,
                    [utf8.char(3)] = utilReq:EncodeCFrame(CFrame.new(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 50))
                }}
                pcall(function()
                    rs.Remotes.Replication.Fighter.UseItem:FireServer(
                        item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil
                    )
                end)
                return
            end
            
            if phase == "attack" and (now - phaseStartTime > State.rageAttackTime) then
                phase = "void"
                phaseStartTime = now
            elseif phase == "void" and (now - phaseStartTime > State.rageVoidTime) then
                phase = "attack"
                phaseStartTime = now
            end
            
            if phase == "attack" then
                local targetHead = currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
                if not targetHead then return end
                
                local pos = targetHead.Position
                    + targetHead.CFrame.RightVector * (State.rageOffsetX or 0)
                    + targetHead.CFrame.UpVector * (State.rageOffsetY or -2)
                    + targetHead.CFrame.LookVector * (State.rageOffsetZ or -1)
                
                hrp.CFrame = CFrame.new(pos, targetHead.Position)
                
                local camCF = CFrame.lookAt(targetHead.Position + Vector3.new(0, 2, 0), targetHead.Position)
                local cameradata = {[utf8.char(1)] = {
                    [utf8.char(0)] = utilReq:EncodeCFrame(workspace.CurrentCamera.CFrame),
                    [utf8.char(1)] = utilReq:EncodeCFrame(camCF),
                    [utf8.char(2)] = targetHead,
                    [utf8.char(3)] = utilReq:EncodeCFrame(targetHead.CFrame:ToObjectSpace(CFrame.new(targetHead.Position)))
                }}
                pcall(function()
                    rs.Remotes.Replication.Fighter.UseItem:FireServer(
                        item:Get("ObjectID"), enums:ToEnum("StartShooting"), cameradata, nil
                    )
                end)
            else
                applyVoidTeleport(hrp, State.rageVoidStrength)
            end
        end)
        
        local renderConn = RunService:BindToRenderStep("DesyncSync", Enum.RenderPriority.First.Value, function()
            if not State.rageBotEnabled then return end
            if clientc and lplr.Character then
                local hrp = lplr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    pcall(function()
                        hrp.CFrame = clientc
                        hrp.AssemblyLinearVelocity = clientv or Vector3.zero
                        hrp.AssemblyAngularVelocity = clientva or Vector3.zero
                    end)
                end
            end
        end)
        
        State.rageBotConnections = {attackHeartbeatConn, renderConn}
        return true
    end

    local maxAttempts = 50
    local attempt = 0
    local retryConnection = nil

    function State.startRageBot()
        if State.rageBotEnabled then
            return false, "Already running"
        end
        
        State.rageBotEnabled = true
        attempt = 0
        
        local success, err = initRageBot()
        
        if success then
            return true
        end
        
        if retryConnection then
            retryConnection:Disconnect()
        end
        
        retryConnection = RunService.Heartbeat:Connect(function()
            if not State.rageBotEnabled then
                retryConnection:Disconnect()
                return
            end
            
            attempt = attempt + 1
            if attempt >= maxAttempts then
                retryConnection:Disconnect()
                State.rageBotEnabled = false
                return
            end
            
            local success2, err2 = initRageBot()
            if success2 then
                retryConnection:Disconnect()
            end
        end)
        
        return false, err
    end

    function State.stopRageBot()
        State.rageBotEnabled = false
        
        if retryConnection then
            retryConnection:Disconnect()
            retryConnection = nil
        end
        
        if State.rageBotConnections then
            for _, conn in ipairs(State.rageBotConnections) do
                pcall(function() conn:Disconnect() end)
            end
            State.rageBotConnections = {}
        end
        
        task.wait(0.3)
        
        pcall(function()
            local char = Players.LocalPlayer.Character
            if char then
                char:PivotTo(char:GetPivot())
            end
        end)
    end

    function State.cleanupRageBot()
        State.stopRageBot()
        State.rageBotEnabled = false
        State.rageBotConnections = {}
    end
end
