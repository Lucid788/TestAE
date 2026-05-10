return function(Core, State)
    local Players = Core.Players
    local RunService = Core.RunService
    local getMech = Core.getMech
    local setThirdPerson = Core.setThirdPerson

    State.jerkEnabled = false
    State.jerkTrack = nil
    State.tornadoAnimId = nil
    State.tornadoAnimObj = nil
    State.tornadoSpeed = 1

    local function getTornadoAnim()
        if State.tornadoAnimId then return State.tornadoAnimId end
        local objs = game:GetObjects("rbxassetid://92281817840531")
        for i = 1, #objs do
            if objs[i]:IsA("Animation") then
                State.tornadoAnimObj = objs[i]
                State.tornadoAnimId = State.tornadoAnimObj.AnimationId
                return State.tornadoAnimId
            end
        end
        return "rbxassetid://92281817840531"
    end

    function State.stopJerkOff()
        if State.jerkTrack then
            pcall(function()
                State.jerkTrack:Stop()
                State.jerkTrack:Destroy()
            end)
            State.jerkTrack = nil
        end
    end

    function State.startJerkOff()
        local character = Players.LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        State.stopJerkOff()

        local function playAnim(char)
            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if not hum then return end
            
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end

            local animId = getTornadoAnim()
            local animation = Instance.new("Animation")
            animation.AnimationId = animId

            State.jerkTrack = hum:LoadAnimation(animation)
            State.jerkTrack.Priority = Enum.AnimationPriority.Action4
            State.jerkTrack:Play()
            State.jerkTrack:AdjustSpeed(State.tornadoSpeed)
            
            State.jerkTrack.Stopped:Connect(function()
                if State.jerkEnabled and Players.LocalPlayer.Character == char then
                    playAnim(char)
                end
            end)
        end

        playAnim(character)
    end

    State.deviceSpoofEnabled = false
    State.selectedDevice = "Computer"
    State.deviceSpoofs = {
        Computer = "MouseKeyboard",
        Mobile = "Touch",
        Console = "Gamepad",
        VR = "VR",
        Car = "VR",
    }
    State.originalVRImage = nil
    State.originalVRCenterImage = nil

    local cachedConstants = nil
    local function getConstants()
        if not cachedConstants then
            pcall(function()
                cachedConstants = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("CONSTANTS"))
            end)
        end
        return cachedConstants
    end

    function State.applyDeviceSpoof()
        if not State.deviceSpoofEnabled then return end
        
        local spoofType = State.deviceSpoofs[State.selectedDevice]
        pcall(function()
            game:GetService("ReplicatedStorage")
                :WaitForChild("Remotes")
                :WaitForChild("Replication")
                :WaitForChild("Fighter")
                :WaitForChild("SetControls")
                :FireServer(spoofType)
        end)

        local constants = getConstants()
        if not constants then return end

        if State.selectedDevice == "Car" then
            if not State.originalVRImage then
                State.originalVRImage = constants.CONTROLS_IMAGES.VR
                State.originalVRCenterImage = constants.CONTROLS_IMAGES_CENTERED.VR
            end
            local carImg = "rbxassetid://438219158"
            constants.CONTROLS_IMAGES.VR = carImg
            constants.CONTROLS_IMAGES_CENTERED.VR = carImg
        else
            if State.originalVRImage then
                constants.CONTROLS_IMAGES.VR = State.originalVRImage
                constants.CONTROLS_IMAGES_CENTERED.VR = State.originalVRCenterImage
            end
        end
    end

    function State.enableDeviceSpoof()
        State.deviceSpoofEnabled = true
        State.applyDeviceSpoof()
    end

    function State.disableDeviceSpoof()
        State.deviceSpoofEnabled = false
        
        if State.originalVRImage then
            local constants = getConstants()
            if constants then
                constants.CONTROLS_IMAGES.VR = State.originalVRImage
                constants.CONTROLS_IMAGES_CENTERED.VR = State.originalVRCenterImage
            end
        end
    end

    function State.changeDevice(deviceType)
        State.selectedDevice = deviceType
        if State.deviceSpoofEnabled then
            State.applyDeviceSpoof()
        end
    end

    State.selectedQueueMode = "1v1"
    State.JoinQueueRF = nil
    State.LeaveQueueRE = nil

    function State.initMatchmaking()
        local RepStorage = game:GetService("ReplicatedStorage")
        local Remotes = RepStorage:WaitForChild("Remotes")
        local Matchmaking = Remotes:WaitForChild("Matchmaking")

        task.spawn(function()
            repeat
                State.JoinQueueRF = Matchmaking:FindFirstChild("JoinQueue")
                State.LeaveQueueRE = Matchmaking:FindFirstChild("LeaveQueue")
                task.wait(0.1)
            until State.JoinQueueRF 
                and State.JoinQueueRF.ClassName == "RemoteFunction"
                and State.LeaveQueueRE 
                and State.LeaveQueueRE.ClassName == "RemoteEvent"
        end)
    end

    function State.joinQueue(queueMode)
        if not State.JoinQueueRF then
            return false, "JoinQueue RemoteFunction not loaded"
        end
        
        local queue = queueMode or State.selectedQueueMode
        
        return pcall(function()
            return State.JoinQueueRF:InvokeServer(queue)
        end)
    end

    function State.leaveQueue()
        if not State.LeaveQueueRE then
            return false, "LeaveQueue RemoteEvent not loaded"
        end
        
        return pcall(function()
            State.LeaveQueueRE:FireServer()
        end)
    end

    function State.unlockAll()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/Lucid788/161ea645f847afed5870c652c3d3baf4/raw/32137f91e0d81ea08a7e74816cf0d8774bb296ac/Unlock%2520All%2520Backend"))()
    end

    function State.setupAntiFlashbang()
        pcall(function()
            local player = Players.LocalPlayer
            local Flashed = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.Flashed)
            Flashed.Flash = function() end
        end)
    end

    local silentAimHookInitialized = false

    function State.initSilentAimHook()
        if silentAimHookInitialized then return end
        silentAimHookInitialized = true

        task.spawn(function()
            local rs = game:GetService("ReplicatedStorage")
            local utilModule = rs:FindFirstChild("Modules")
            if not utilModule then return end
            utilModule = utilModule:FindFirstChild("Utility")
            if not utilModule then return end
            
            local util = require(utilModule)
            local oldRaycast = util.Raycast

            local cachedTarget = nil
            local lastCacheTime = 0

            util.Raycast = function(self, origin, direction, length, filter, filterType, visualize)
                if State.SilentAimState and State.SilentAimState.Enabled and length > 100 and filter then
                    local now = tick()
                    if now - lastCacheTime > 0.1 then
                        cachedTarget = State.getClosestSilent and State.getClosestSilent()
                        lastCacheTime = now
                    end
                    
                    if cachedTarget and cachedTarget.Character then
                        local hitPart = cachedTarget.Character:FindFirstChild(State.SilentAimState.LockPart)
                        if hitPart then
                            return {
                                Position = hitPart.Position,
                                Distance = (hitPart.Position - origin).Magnitude,
                                Instance = hitPart,
                                Material = hitPart.Material,
                                Normal = Vector3.yAxis
                            }
                        end
                    end
                end
                return oldRaycast(self, origin, direction, length, filter, filterType, visualize)
            end
        end)
    end

    State.wallbangEnabled = false
    State.wallbangConnections = {}
    State.currentTargetHitbox = nil

    function State.enableWallbang()
        if State.wallbangEnabled then return end
        State.wallbangEnabled = true

        task.wait(0.3)

        local updateConn = RunService.Heartbeat:Connect(function()
            if not State.wallbangEnabled then return end
            
            local lp = Players.LocalPlayer
            local myEnvAttr = lp:GetAttribute("EnvironmentID")
            if not myEnvAttr then
                State.currentTargetHitbox = nil
                return
            end
            
            local myEnv = string.byte(myEnvAttr)
            local myTeam = string.byte(lp:GetAttribute("TeamID") or "\0")
            local gPlaceId = game.PlaceId
            local isSpecial = (gPlaceId == 129604661913557 or gPlaceId == 71874690745115)
            
            local found = nil
            local playerList = Players:GetPlayers()
            
            for i = 1, #playerList do
                local v = playerList[i]
                if v ~= lp and v.Character and v:GetAttribute("EnvironmentID") then
                    local hEnv = string.byte(v:GetAttribute("EnvironmentID"))
                    local hTeam = string.byte(v:GetAttribute("TeamID") or "\0")
                    
                    local valid = false
                    if isSpecial then
                        if hEnv == myEnv then valid = true end
                    else
                        if hEnv == myEnv and hTeam ~= myTeam then valid = true end
                    end
                    
                    if valid then
                        local hum = v.Character:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            found = v.Character:FindFirstChild("HitboxHeadSmall") 
                                or v.Character:FindFirstChild("HitboxHead") 
                                or v.Character:FindFirstChild("Head") 
                                or v.Character:FindFirstChild("HumanoidRootPart")
                            if found then break end
                        end
                    end
                end
            end
            
            State.currentTargetHitbox = found
        end)

        local projectileConn = workspace.ChildAdded:Connect(function(v)
            pcall(function()
                if not State.wallbangEnabled then return end
                local n = v.Name
                if n == "CoreProjectile" or n == "Slingshot" then
                    task.spawn(function()
                        local start = tick()
                        while v and v.Parent and (tick() - start) < 2 do
                            if State.wallbangEnabled and State.currentTargetHitbox then
                                v.CFrame = State.currentTargetHitbox.CFrame
                                v.AssemblyLinearVelocity = Vector3.zero
                                pcall(function() firetouchinterest(State.currentTargetHitbox, v, 0) end)
                                pcall(function() firetouchinterest(State.currentTargetHitbox, v, 1) end)
                            end
                            task.wait()
                        end
                    end)
                end
            end)
        end)

        State.wallbangConnections = {updateConn, projectileConn}
    end

    function State.disableWallbang()
        State.wallbangEnabled = false
        
        task.wait(0.2)
        
        for _, conn in ipairs(State.wallbangConnections) do
            pcall(function() conn:Disconnect() end)
        end
        State.wallbangConnections = {}
        State.currentTargetHitbox = nil
    end

    State.rapidFireEnabled = false
    State.rapidFireHooked = false

    function State.enableRapidFire()
        if State.rapidFireEnabled or State.rapidFireHooked then return end
        State.rapidFireEnabled = true

        task.spawn(function()
            local Gun = nil
            local found = false
            local attempts = 0

            while attempts < 60 and not found do
                attempts = attempts + 1
                
                local rs = game:GetService("ReplicatedStorage")
                if rs:FindFirstChild("Modules") then
                    local itemTypes = rs.Modules:FindFirstChild("ItemTypes")
                    if itemTypes then
                        local gunScript = itemTypes:FindFirstChild("Gun")
                        if gunScript then
                            pcall(function() Gun = require(gunScript) end)
                            if Gun then found = true end
                        end
                    end
                end

                if not found then
                    pcall(function()
                        local psModules = Players.LocalPlayer.PlayerScripts:FindFirstChild("Modules")
                        if psModules then
                            local psItemTypes = psModules:FindFirstChild("ItemTypes")
                            if psItemTypes then
                                local psGun = psItemTypes:FindFirstChild("Gun")
                                if psGun then
                                    Gun = require(psGun)
                                    if Gun then found = true end
                                end
                            end
                        end
                    end)
                end

                if not found then
                    task.wait(0.1)
                end
            end

            if Gun and Gun.Update then
                local oldUpdate = Gun.Update
                Gun.Update = function(self, dt, ...)
                    if State.rapidFireEnabled and self._shoot_cooldown then
                        self._shoot_cooldown = 0
                    end
                    return oldUpdate(self, dt, ...)
                end
                State.rapidFireHooked = true
            elseif getgc then

                task.delay(1, function()
                    if not State.rapidFireEnabled then return end
                    for _, tbl in ipairs(getgc(true)) do
                        if type(tbl) == "table" then
                            for k, v in pairs(tbl) do
                                if type(k) == "string" and (k:lower():find("cooldown") or k:lower():find("shoot")) then
                                    pcall(function() tbl[k] = 0 end)
                                end
                            end
                        end
                        task.wait()
                    end
                end)
            end
        end)
    end

    function State.disableRapidFire()
        State.rapidFireEnabled = false
    end

    function State.initMisc()
        State.initMatchmaking()
        State.initSilentAimHook()
    end

    function State.cleanupMisc()
        State.stopJerkOff()
        State.disableDeviceSpoof()
        State.disableWallbang()
        State.disableRapidFire()
    end
end
