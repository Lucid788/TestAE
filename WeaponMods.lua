return function(Core, State)
    local Players = Core.Players
    local RunService = Core.RunService

    State.rapidFireEnabled = false
    State.rapidFireHooked = false
    State.rapidFireBackup = {}
    
    local rapidFireInitialized = false

    function State.enableRapidFire()
        if State.rapidFireEnabled then return true, "Already enabled" end
        State.rapidFireEnabled = true

        if not rapidFireInitialized then
            rapidFireInitialized = true
            
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
                                pcall(function() 
                                    Gun = require(gunScript) 
                                end)
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
                        if self._fire_cooldown then
                            self._fire_cooldown = 0
                        end
                        if self._attack_speed then
                            self._attack_speed = 0
                        end
                        return oldUpdate(self, dt, ...)
                    end
                    State.rapidFireHooked = true
                elseif getgc then

                    task.spawn(function()
                        while State.rapidFireEnabled do
                            local success = false
                            for _, tbl in ipairs(getgc(true)) do
                                if not State.rapidFireEnabled then break end
                                if type(tbl) == "table" then
                                    for k, v in pairs(tbl) do
                                        if type(k) == "string" then
                                            local lower = k:lower()
                                            if lower:find("cooldown") or lower:find("shoot") or lower:find("fire") or lower:find("attack_speed") then

                                                if not State.rapidFireBackup[tbl] then
                                                    State.rapidFireBackup[tbl] = {}
                                                end
                                                if State.rapidFireBackup[tbl][k] == nil then
                                                    State.rapidFireBackup[tbl][k] = v
                                                end
                                                pcall(function() tbl[k] = 0 end)
                                                success = true
                                            end
                                        end
                                    end
                                end
                                task.wait()
                            end
                            if not success then task.wait(0.5) end
                        end
                    end)
                    State.rapidFireHooked = true
                end
            end)
        end

        return true, "Rapid Fire enabled"
    end

    function State.disableRapidFire()
        State.rapidFireEnabled = false

        if State.rapidFireBackup then
            for tbl, attrs in pairs(State.rapidFireBackup) do
                if type(tbl) == "table" then
                    for attr, originalValue in pairs(attrs) do
                        pcall(function()
                            tbl[attr] = originalValue
                        end)
                    end
                end
            end
            State.rapidFireBackup = {}
        end
    end

    State.wallbangEnabled = false
    State.wallbangConnections = {}
    State.currentTargetHitbox = nil

    function State.enableWallbang()
        if State.wallbangEnabled then return true, "Already enabled" end
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
            if not State.wallbangEnabled then return end
            
            local n = v.Name
            if n == "CoreProjectile" or n == "Slingshot" or n:lower():find("projectile") then
                task.spawn(function()
                    local start = tick()
                    while v and v.Parent and (tick() - start) < 2 do
                        if not State.wallbangEnabled or not State.currentTargetHitbox then break end
                        
                        pcall(function()
                            v.CFrame = State.currentTargetHitbox.CFrame
                            v.AssemblyLinearVelocity = Vector3.zero
                        end)
                        
                        pcall(function() 
                            firetouchinterest(State.currentTargetHitbox, v, 0) 
                        end)
                        pcall(function() 
                            firetouchinterest(State.currentTargetHitbox, v, 1) 
                        end)
                        
                        task.wait()
                    end
                end)
            end
        end)

        State.wallbangConnections = {updateConn, projectileConn}
        return true, "Wallbang enabled"
    end

    function State.disableWallbang()
        State.wallbangEnabled = false
        
        task.wait(0.2)
        
        if State.wallbangConnections then
            for _, conn in ipairs(State.wallbangConnections) do
                pcall(function() conn:Disconnect() end)
            end
            State.wallbangConnections = {}
        end
        
        State.currentTargetHitbox = nil
    end

    State.autoAttackEnabled = false
    State.autoAttackConnection = nil

    function State.enableAutoAttack()
        if State.autoAttackEnabled then return true, "Already enabled" end
        
        State.autoAttackEnabled = true
        
        State.autoAttackConnection = RunService.Heartbeat:Connect(function()
            if not State.autoAttackEnabled then return end
            
            pcall(function()
                local char = Players.LocalPlayer.Character
                if not char then return end
                
                local closestEnemy = nil
                local closestDistance = 15
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer and player.Character then
                        local hum = player.Character:FindFirstChild("Humanoid")
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if hum and hum.Health > 0 and hrp and not player.Character:FindFirstChildOfClass("ForceField") then
                            if not State.teamCheckEnabled or not Core.isSameTeam(player) then
                                local myHrp = char:FindFirstChild("HumanoidRootPart")
                                if myHrp then
                                    local dist = (myHrp.Position - hrp.Position).Magnitude
                                    if dist < closestDistance then
                                        closestDistance = dist
                                        closestEnemy = player
                                    end
                                end
                            end
                        end
                    end
                end
                
                if closestEnemy then

                    local args = {
                        [1] = closestEnemy.Character,
                    }

                    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                    if remotes then
                        local combatRemote = remotes:FindFirstChild("Combat") or remotes:FindFirstChild("Attack")
                        if combatRemote then
                            pcall(function()
                                combatRemote:FireServer(unpack(args))
                            end)
                        end
                    end
                end
            end)
        end)
        
        return true, "Auto Attack enabled"
    end

    function State.disableAutoAttack()
        State.autoAttackEnabled = false
        
        if State.autoAttackConnection then
            State.autoAttackConnection:Disconnect()
            State.autoAttackConnection = nil
        end
    end

    State.noRecoilEnabled = false
    local noRecoilInitialized = false

    function State.enableNoRecoil()
        if State.noRecoilEnabled then return true, "Already enabled" end
        State.noRecoilEnabled = true

        if not noRecoilInitialized then
            noRecoilInitialized = true
            
            task.spawn(function()

                while State.noRecoilEnabled do
                    pcall(function()
                        local camera = workspace.CurrentCamera
                        if camera then

                            for _, child in ipairs(camera:GetChildren()) do
                                if child:IsA("CameraShaker") or child.Name:lower():find("shake") then
                                    child:Destroy()
                                end
                            end
                            
                            local rs = game:GetService("ReplicatedStorage")
                            local modules = rs:FindFirstChild("Modules")
                            if modules then
                                local recoilModule = modules:FindFirstChild("Recoil") or modules:FindFirstChild("CameraRecoil")
                                if recoilModule then
                                    local recoil = require(recoilModule)
                                    if recoil.ApplyRecoil then
                                        recoil.ApplyRecoil = function() end
                                    end
                                    if recoil.Shake then
                                        recoil.Shake = function() end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
        
        return true, "No Recoil enabled"
    end

    function State.disableNoRecoil()
        State.noRecoilEnabled = false
    end

    State.noSpreadEnabled = false

    function State.enableNoSpread()
        if State.noSpreadEnabled then return true, "Already enabled" end
        State.noSpreadEnabled = true
        
        task.spawn(function()
            while State.noSpreadEnabled do
                pcall(function()

                    for _, tbl in ipairs(getgc(true)) do
                        if not State.noSpreadEnabled then break end
                        if type(tbl) == "table" then
                            for k, v in pairs(tbl) do
                                if type(k) == "string" then
                                    local lower = k:lower()
                                    if lower:find("spread") or lower:find("bullet_spread") then
                                        pcall(function() tbl[k] = 0 end)
                                    end
                                end
                            end
                        end
                        task.wait()
                    end
                end)
                task.wait(2)
            end
        end)
        
        return true, "No Spread enabled"
    end

    function State.disableNoSpread()
        State.noSpreadEnabled = false
    end

    State.infiniteAmmoEnabled = false

    function State.enableInfiniteAmmo()
        if State.infiniteAmmoEnabled then return true, "Already enabled" end
        State.infiniteAmmoEnabled = true
        
        task.spawn(function()
            while State.infiniteAmmoEnabled do
                pcall(function()
                    local mech = Core.getMech()
                    if mech then
                        local item = mech.LocalFighter and mech.LocalFighter.EquippedItem
                        if item then

                            if item:Get("Ammo") then
                                item:Set("Ammo", 999)
                            end
                            if item:Get("MaxAmmo") then
                                item:Set("MaxAmmo", 999)
                            end
                            if item:Get("CurrentAmmo") then
                                item:Set("CurrentAmmo", 999)
                            end
                            
                            if item.Info then
                                if item.Info.Ammo ~= nil then
                                    item.Info.Ammo = 999
                                end
                                if item.Info.MaxAmmo ~= nil then
                                    item.Info.MaxAmmo = 999
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
        
        return true, "Infinite Ammo enabled"
    end

    function State.disableInfiniteAmmo()
        State.infiniteAmmoEnabled = false
    end

    function State.initWeaponMods()

    end

    function State.cleanupWeaponMods()
        State.disableRapidFire()
        State.disableWallbang()
        State.disableAutoAttack()
        State.disableNoRecoil()
        State.disableNoSpread()
        State.disableInfiniteAmmo()
    end
end
