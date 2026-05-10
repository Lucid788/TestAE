return function(Core, State)
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.Transparency = 0.7
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Radius = State.fov
    FOVCircle.Visible = false

    local SilentFOVCircle = Drawing.new("Circle")
    SilentFOVCircle.Thickness = 2
    SilentFOVCircle.Transparency = 0.7
    SilentFOVCircle.Color = State.SilentAimState.FOVColor
    SilentFOVCircle.Radius = State.SilentAimState.FOV
    SilentFOVCircle.NumSides = 64
    SilentFOVCircle.Filled = false
    SilentFOVCircle.Visible = false

    local Window = Rayfield:CreateWindow({
        Name = "Aspect Rivals V.2",
        LoadingTitle = "Loading Rivals",
        LoadingSubtitle = "Developed by AE Dev Team",
        Theme = "Ocean",
        ConfigurationSaving = {
            Enabled = false,
            FolderName = nil,
            FileName = "AspectRivalsV2"
        },
        Discord = {
            Enabled = false,
            Invite = "JGPAsEHq3Q",
            RememberJoins = false
        },
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Main", nil)
    local VisualTab = Window:CreateTab("Visual", nil)
    local MovementTab = Window:CreateTab("Movement", nil)
    local WeaponTab = Window:CreateTab("Weapons", nil)
    local FunctionsTab = Window:CreateTab("Functions", nil)
    local SettingsTab = Window:CreateTab("Settings", nil)

    local function notify(title, content, duration)
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 2,
            Image = 17055169824,
        })
    end

    local function warn(title, content)
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = 3,
            Image = 15000498922,
        })
    end

    MainTab:CreateSection("Aimbot")

    MainTab:CreateToggle({
        Name = "Aimbot (Q)",
        CurrentValue = false,
        Flag = "AimbotToggle",
        Callback = function(Value)
            State.aimbotEnabled = Value
            if Value then
                notify("Aimbot", "Aimbot enabled (Q key)")
            else
                State.currentTarget = nil
                FOVCircle.Visible = false
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Aimbot Smoothness",
        Range = {0.1, 1.0},
        Increment = 0.1,
        Suffix = "Speed",
        CurrentValue = 0.6,
        Flag = "SmoothnessSlider",
        Callback = function(Value)
            State.smoothnessValue = Value
        end,
    })

    MainTab:CreateDropdown({
        Name = "Aimbot Aim Part",
        Options = {"HitboxHeadSmall", "HitboxBodySmall"},
        CurrentOption = {"HitboxHeadSmall"},
        MultipleOptions = false,
        Flag = "AimbotAimPart",
        Callback = function(Options)
            State.lockPart = Options[1]
        end,
    })

    MainTab:CreateToggle({
        Name = "No Keybind Aimbot",
        CurrentValue = false,
        Flag = "NoKeybindEnabled",
        Callback = function(Value)
            if not State.aimbotEnabled then
                warn("No Keybind", "Enable Aimbot first!")
                return
            end
            State.noKeybindEnabled = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "FOV Circle",
        CurrentValue = false,
        Flag = "FOVCircleEnabled",
        Callback = function(Value)
            if not State.aimbotEnabled then
                warn("FOV Circle", "Enable Aimbot first!")
                return
            end
            State.fovCircleEnabled = Value
            if not Value then
                FOVCircle.Visible = false
                State.showFOVCircle = false
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Flag = "ShowFOVCircle",
        Callback = function(Value)
            if not State.fovCircleEnabled then
                warn("FOV Circle", "Enable FOV Circle first!")
                return
            end
            State.showFOVCircle = Value
            FOVCircle.Visible = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "FOV Slider",
        Range = {10, 500},
        Increment = 10,
        Suffix = "FOV",
        CurrentValue = 90,
        Flag = "FOVSlider",
        Callback = function(Value)
            State.fov = Value
            FOVCircle.Radius = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = false,
        Flag = "TeamCheckToggle",
        Callback = function(Value)
            State.teamCheckEnabled = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Wall Check",
        CurrentValue = true,
        Flag = "WallCheckToggle",
        Callback = function(Value)
            State.wallCheckEnabled = Value
        end,
    })

    MainTab:CreateSection("Silent Aim")

    MainTab:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Flag = "SilentAimEnabled",
        Callback = function(Value)
            State.SilentAimState.Enabled = Value
            if Value then
                notify("Silent Aim", "Silent Aim enabled")
            end
        end,
    })

    MainTab:CreateDropdown({
        Name = "Target Part",
        Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "HitboxHeadSmall", "HitboxBodySmall"},
        CurrentOption = {"Head"},
        MultipleOptions = false,
        Flag = "SilentAimPart",
        Callback = function(Value)
            State.SilentAimState.LockPart = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = true,
        Flag = "SilentTeamCheck",
        Callback = function(Value)
            State.SilentAimState.TeamCheck = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "FOV Circle",
        CurrentValue = false,
        Flag = "SilentFOVEnabled",
        Callback = function(Value)
            State.SilentAimState.FOVEnabled = Value
            if not Value then
                SilentFOVCircle.Visible = false
                State.SilentAimState.FOVVisible = false
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Flag = "SilentShowFOV",
        Callback = function(Value)
            State.SilentAimState.FOVVisible = Value
            if SilentFOVCircle and State.SilentAimState.FOVEnabled then
                SilentFOVCircle.Visible = Value
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "FOV Radius",
        Range = {30, 500},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 100,
        Flag = "SilentFOVRadius",
        Callback = function(Value)
            State.SilentAimState.FOV = Value
            if SilentFOVCircle then
                SilentFOVCircle.Radius = Value
            end
        end,
    })

    MainTab:CreateColorPicker({
        Name = "FOV Color",
        Color = Color3.fromRGB(255, 0, 0),
        Flag = "SilentFOVColor",
        Callback = function(Value)
            State.SilentAimState.FOVColor = Value
            if SilentFOVCircle then
                SilentFOVCircle.Color = Value
            end
        end,
    })

    MainTab:CreateSection("Triggerbot")

    MainTab:CreateToggle({
        Name = "Triggerbot",
        CurrentValue = false,
        Flag = "TriggerbotToggle",
        Callback = function(Value)
            State.triggerbotEnabled = Value
            if Value then
                State.setupTriggerbot()
                notify("Triggerbot", "Triggerbot enabled")
            else
                State.removeTriggerbot()
            end
        end,
    })

    MainTab:CreateSection("Rage Bot")

    MainTab:CreateSlider({
        Name = "Attack Time",
        Range = {0.01, 1.0},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = 0.3,
        Flag = "RageAttackTimeSlider",
        Callback = function(Value)
            State.rageAttackTime = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Void Time",
        Range = {0.01, 1.0},
        Increment = 0.01,
        Suffix = "s",
        CurrentValue = 0.5,
        Flag = "RageVoidTimeSlider",
        Callback = function(Value)
            State.rageVoidTime = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Void Strength",
        Range = {1, 1000},
        Increment = 1,
        Suffix = "",
        CurrentValue = 50,
        Flag = "RageVoidStrengthSlider",
        Callback = function(Value)
            State.rageVoidStrength = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Desync Offset X",
        Range = {-10, 10},
        Increment = 0.1,
        Suffix = " studs",
        CurrentValue = 0,
        Flag = "RageOffsetXSlider",
        Callback = function(Value)
            State.rageOffsetX = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Desync Offset Y",
        Range = {-10, 10},
        Increment = 0.1,
        Suffix = " studs",
        CurrentValue = -2,
        Flag = "RageOffsetYSlider",
        Callback = function(Value)
            State.rageOffsetY = Value
        end,
    })

    MainTab:CreateSlider({
        Name = "Desync Offset Z",
        Range = {-10, 10},
        Increment = 0.1,
        Suffix = " studs",
        CurrentValue = -1,
        Flag = "RageOffsetZSlider",
        Callback = function(Value)
            State.rageOffsetZ = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Rage Bot (Desync)",
        CurrentValue = false,
        Flag = "RageBotToggle",
        Callback = function(Value)
            if Value then
                local success, err = State.startRageBot()
                if success then
                    notify("Rage Bot", "Rage Bot enabled!")
                else
                    warn("Rage Bot", "Failed: " .. tostring(err))
                end
            else
                State.stopRageBot()
                notify("Rage Bot", "Rage Bot disabled")
            end
        end,
    })

    VisualTab:CreateSection("ESP")

    VisualTab:CreateToggle({
        Name = "Box ESP",
        CurrentValue = false,
        Flag = "BoxESPToggle",
        Callback = function(Value)
            State.espBoxEnabled = Value
        end,
    })

    VisualTab:CreateColorPicker({
        Name = "Box ESP Color",
        Color = Color3.fromRGB(255, 0, 0),
        Flag = "BoxESPColor",
        Callback = function(Value)
            State.espBoxColor = Value
            for _, box in pairs(State.espBoxes) do
                box:Remove()
            end
            State.espBoxes = {}
        end,
    })

    VisualTab:CreateToggle({
        Name = "Line ESP",
        CurrentValue = false,
        Flag = "LineESPToggle",
        Callback = function(Value)
            State.espLineEnabled = Value
        end,
    })

    VisualTab:CreateColorPicker({
        Name = "Line ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Flag = "LineESPColor",
        Callback = function(Value)
            State.espLineColor = Value
            for _, line in pairs(State.espLines) do
                line:Remove()
            end
            State.espLines = {}
        end,
    })

    VisualTab:CreateToggle({
        Name = "ESP Team Check",
        CurrentValue = false,
        Flag = "ESPTeamCheckToggle",
        Callback = function(Value)
            State.espTeamCheckEnabled = Value
        end,
    })

    VisualTab:CreateSection("Other")

    VisualTab:CreateToggle({
        Name = "Anti Flashbang",
        CurrentValue = false,
        Flag = "AntiFlashbangToggle",
        Callback = function(Value)
            if Value then
                pcall(function()
                    local player = Core.Players.LocalPlayer
                    local Flashed = require(player.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.FighterInterface.Flashed)
                    Flashed.Flash = function() end
                end)
                notify("Anti Flashbang", "Enabled")
            else
                notify("Anti Flashbang", "Disabled (requires rejoin to restore)")
            end
        end,
    })

    VisualTab:CreateToggle({
        Name = "Third Person",
        CurrentValue = false,
        Flag = "ThirdPersonToggle",
        Callback = function(Value)
            State.thirdPersonEnabled = Value
            if Value then
                State.enableThirdPerson()
                notify("Third Person", "Enabled")
            else
                State.disableThirdPerson()
                notify("Third Person", "Disabled")
            end
        end,
    })

    VisualTab:CreateToggle({
        Name = "Unlock All",
        CurrentValue = false,
        Flag = "UnlockAllToggle",
        Callback = function(Value)
            if Value then
                loadstring(game:HttpGet("https://gist.githubusercontent.com/Lucid788/161ea645f847afed5870c652c3d3baf4/raw/32137f91e0d81ea08a7e74816cf0d8774bb296ac/Unlock%2520All%2520Backend"))()
                notify("Unlock All", "Executed!")
            end
        end,
    })

    VisualTab:CreateSection("Color Correction")

    VisualTab:CreateToggle({
        Name = "Color Correction",
        CurrentValue = false,
        Flag = "ColorCorrectionToggle",
        Callback = function(Value)
            State.ccEnabled = Value
            if Value then
                State.setupColorCorrection()
                notify("Color Correction", "Enabled")
            else
                State.removeColorCorrection()
            end
        end,
    })

    VisualTab:CreateColorPicker({
        Name = "Tint Color",
        Color = Color3.fromRGB(255, 255, 255),
        Flag = "CCTintColor",
        Callback = function(Value)
            State.ccTintColor = Value
            if State.ccEffect then
                State.ccEffect.TintColor = Value
            end
        end,
    })

    VisualTab:CreateSlider({
        Name = "Saturation",
        Range = {-1, 1},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = 0,
        Flag = "CCSaturation",
        Callback = function(Value)
            State.ccSaturation = Value
            if State.ccEffect then
                State.ccEffect.Saturation = Value
            end
        end,
    })

    VisualTab:CreateSlider({
        Name = "Contrast",
        Range = {-1, 1},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = 0,
        Flag = "CCContrast",
        Callback = function(Value)
            State.ccContrast = Value
            if State.ccEffect then
                State.ccEffect.Contrast = Value
            end
        end,
    })

    VisualTab:CreateSlider({
        Name = "Brightness",
        Range = {-1, 1},
        Increment = 0.1,
        Suffix = "",
        CurrentValue = 0,
        Flag = "CCBrightness",
        Callback = function(Value)
            State.ccBrightness = Value
            if State.ccEffect then
                State.ccEffect.Brightness = Value
            end
        end,
    })

    MovementTab:CreateSection("Fly")

    MovementTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Flag = "FlyToggle",
        Callback = function(Value)
            State.flyEnabled = Value
            if Value then
                Core.startMovementHeartbeat(State)
                notify("Fly", "Fly enabled")
            else
                if not State.speedEnabled and not State.jumpEnabled then
                    Core.stopMovementHeartbeat()
                end
                if Core.Players.LocalPlayer.Character then
                    Core.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.zero
                end
            end
        end,
    })

    MovementTab:CreateSlider({
        Name = "Fly Speed",
        Range = {1, 200},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Flag = "FlySpeedSlider",
        Callback = function(Value)
            State.flySpeed = Value
        end,
    })

    MovementTab:CreateSection("Movement")

    MovementTab:CreateToggle({
        Name = "Speed Boost",
        CurrentValue = false,
        Flag = "SpeedToggle",
        Callback = function(Value)
            State.speedEnabled = Value
            if Value then
                Core.startMovementHeartbeat(State)
            else
                if not State.flyEnabled and not State.jumpEnabled then
                    Core.stopMovementHeartbeat()
                end
            end
        end,
    })

    MovementTab:CreateSlider({
        Name = "Speed",
        Range = {16, 200},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = 16,
        Flag = "SpeedValueSlider",
        Callback = function(Value)
            State.speedValue = Value
        end,
    })

    MovementTab:CreateToggle({
        Name = "Jump Boost",
        CurrentValue = false,
        Flag = "JumpToggle",
        Callback = function(Value)
            State.jumpEnabled = Value
            if Value then
                Core.startMovementHeartbeat(State)
            else
                if not State.flyEnabled and not State.speedEnabled then
                    Core.stopMovementHeartbeat()
                end
            end
        end,
    })

    MovementTab:CreateSlider({
        Name = "Jump Power",
        Range = {16, 200},
        Increment = 1,
        Suffix = "Power",
        CurrentValue = 16,
        Flag = "JumpPowerSlider",
        Callback = function(Value)
            State.jumpPowerValue = Value
        end,
    })

    MovementTab:CreateSection("Slide Boost")

    MovementTab:CreateToggle({
        Name = "Slide Boost",
        CurrentValue = false,
        Flag = "SlideBoostToggle",
        Callback = function(Value)
            State.slideBoostEnabled = Value
            if not Value and State.slideBaseSpeed then
                local mech = Core.getMech()
                if mech then
                    local f = mech.LocalFighter
                    if f then
                        f:Set("SlidingSpeedMax", State.slideBaseSpeed)
                    end
                end
            end
        end,
    })

    MovementTab:CreateSlider({
        Name = "Boost Multiplier",
        Range = {1.0, 5.0},
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = 1.5,
        Flag = "SlideBoostSlider",
        Callback = function(Value)
            State.slideBoostMultiplier = Value
        end,
    })

    MovementTab:CreateSection("Other")

    MovementTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",
        Callback = function(Value)
            State.infiniteJumpEnabled = Value
            if Value then
                notify("Infinite Jump", "Enabled")
            end
        end,
    })

    MovementTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Flag = "NoclipToggle",
        Callback = function(Value)
            State.noclipEnabled = Value
            if Value then
                State.setupNoclip()
                notify("Noclip", "Enabled")
            else
                State.removeNoclip()
            end
        end,
    })

    MovementTab:CreateToggle({
        Name = "Tornado Mode",
        CurrentValue = false,
        Flag = "JerkToggle",
        Callback = function(Value)
            State.jerkEnabled = Value
            if Value then
                State.startJerkOff()
                notify("Tornado", "Tornado mode activated!")
            else
                State.stopJerkOff()
            end
        end,
    })

    WeaponTab:CreateSection("Fire Mods")

    WeaponTab:CreateToggle({
        Name = "Rapid Fire",
        CurrentValue = false,
        Flag = "RapidFireToggle",
        Callback = function(Value)
            if Value then
                local success, msg = State.enableRapidFire()
                if success then notify("Rapid Fire", msg) end
            else
                State.disableRapidFire()
                notify("Rapid Fire", "Disabled")
            end
        end,
    })

    WeaponTab:CreateToggle({
        Name = "No Recoil",
        CurrentValue = false,
        Flag = "NoRecoilToggle",
        Callback = function(Value)
            if Value then
                State.enableNoRecoil()
                notify("No Recoil", "Enabled")
            else
                State.disableNoRecoil()
            end
        end,
    })

    WeaponTab:CreateToggle({
        Name = "No Spread",
        CurrentValue = false,
        Flag = "NoSpreadToggle",
        Callback = function(Value)
            if Value then
                State.enableNoSpread()
                notify("No Spread", "Enabled")
            else
                State.disableNoSpread()
            end
        end,
    })

    WeaponTab:CreateToggle({
        Name = "Infinite Ammo",
        CurrentValue = false,
        Flag = "InfiniteAmmoToggle",
        Callback = function(Value)
            if Value then
                State.enableInfiniteAmmo()
                notify("Infinite Ammo", "Enabled")
            else
                State.disableInfiniteAmmo()
            end
        end,
    })

    WeaponTab:CreateSection("Projectile Mods")

    WeaponTab:CreateToggle({
        Name = "Projectile TP (Slingshot)",
        CurrentValue = false,
        Flag = "WallbangToggle",
        Callback = function(Value)
            if Value then
                local success, msg = State.enableWallbang()
                if success then notify("Projectile TP", msg) end
            else
                State.disableWallbang()
                notify("Projectile TP", "Disabled")
            end
        end,
    })

    WeaponTab:CreateToggle({
        Name = "Auto Attack",
        CurrentValue = false,
        Flag = "AutoAttackToggle",
        Callback = function(Value)
            if Value then
                local success, msg = State.enableAutoAttack()
                if success then notify("Auto Attack", msg) end
            else
                State.disableAutoAttack()
                notify("Auto Attack", "Disabled")
            end
        end,
    })

    FunctionsTab:CreateSection("Device Spoofer")

    FunctionsTab:CreateToggle({
        Name = "Device Spoofer",
        CurrentValue = false,
        Flag = "DeviceSpoofToggle",
        Callback = function(Value)
            if Value then
                State.enableDeviceSpoof()
                notify("Device Spoofer", "Spoofed as " .. State.selectedDevice)
            else
                State.disableDeviceSpoof()
                notify("Device Spoofer", "Disabled")
            end
        end,
    })

    FunctionsTab:CreateDropdown({
        Name = "Device Type",
        Options = {"Computer", "Mobile", "Console", "VR", "Car"},
        CurrentOption = {"Computer"},
        MultipleOptions = false,
        Flag = "DeviceTypeDropdown",
        Callback = function(Options)
            State.changeDevice(Options[1])
            if State.deviceSpoofEnabled then
                notify("Device Spoofer", "Changed to " .. Options[1])
            end
        end,
    })

    FunctionsTab:CreateSection("Matchmaking")

    FunctionsTab:CreateDropdown({
        Name = "Queue Mode",
        Options = {"1v1", "2v2", "3v3", "4v4", "5v5", "ranked_1v1", "ranked_2v2", "ranked_3v3"},
        CurrentOption = {"1v1"},
        MultipleOptions = false,
        Flag = "QueueModeDropdown",
        Callback = function(Options)
            State.selectedQueueMode = Options[1]
        end,
    })

    FunctionsTab:CreateButton({
        Name = "Join Selected Queue",
        Callback = function()
            local success, result = State.joinQueue()
            if not success then
                warn("Queue Error", result)
            else
                notify("Queue", "Joined " .. State.selectedQueueMode .. " queue!")
            end
        end,
    })

    FunctionsTab:CreateButton({
        Name = "Leave Queue",
        Callback = function()
            local success, result = State.leaveQueue()
            if not success then
                warn("Queue Error", result)
            else
                notify("Queue", "Left queue!")
            end
        end,
    })

    SettingsTab:CreateSection("Utility")

    SettingsTab:CreateButton({
        Name = "Unload Script",
        Callback = function()

            pcall(function() State.cleanup() end)
            
            if FOVCircle then FOVCircle:Remove() end
            if SilentFOVCircle then SilentFOVCircle:Remove() end
            
            for _, box in pairs(State.espBoxes or {}) do
                box:Remove()
            end
            for _, line in pairs(State.espLines or {}) do
                line:Remove()
            end
            
            Rayfield:Destroy()
            
            notify("Unload", "Script unloaded successfully!", 3)
        end,
    })

    return Window, FOVCircle, SilentFOVCircle
end
