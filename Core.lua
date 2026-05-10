local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

function isSameTeam(targetPlayer)
    if not targetPlayer or targetPlayer == Players.LocalPlayer then return false end
    local playerTeamID = targetPlayer:GetAttribute("TeamID")
    local localTeamID = Players.LocalPlayer:GetAttribute("TeamID")
    return (playerTeamID and localTeamID) and (playerTeamID == localTeamID) or false
end

function isTargetVisible(targetPart)
    local character = Players.LocalPlayer.Character
    if not character then return false end
    local rayOrigin = character.Head.Position
    local rayDirection = (targetPart.Position - rayOrigin)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return raycastResult == nil
end

local cachedMech = nil
function getMech()
    if not cachedMech then
        pcall(function()
            cachedMech = require(Players.LocalPlayer.PlayerScripts.Controllers.MechanicsController)
        end)
    end
    return cachedMech
end

function setThirdPerson(enabled)
    local player = Players.LocalPlayer
    local cameraController = nil
    local success = pcall(function()
        cameraController = require(player.PlayerScripts.Controllers.CameraController)
    end)
    if not success then return end
    if cameraController and cameraController.CameraState then
        if enabled then
            cameraController.CameraState:_SetPOVState(cameraController.CameraState.States.ThirdPerson)
        else
            cameraController.CameraState:_SetPOVState(cameraController.CameraState.States.FirstPerson)
        end
    end
end

local movementHeartbeatConn = nil
local movementLastUpdate = 0

function startMovementHeartbeat(movementData)
    if movementHeartbeatConn then return end
    movementHeartbeatConn = RunService.Heartbeat:Connect(function(deltaTime)
        local now = tick()
        if now - movementLastUpdate < 0.03 then return end
        movementLastUpdate = now
        
        local char = Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        if movementData.flyEnabled then
            local moveDir = Vector3.zero
            local cam = workspace.CurrentCamera
            if movementData.flyKeys.W then moveDir += cam.CFrame.LookVector end
            if movementData.flyKeys.S then moveDir -= cam.CFrame.LookVector end
            if movementData.flyKeys.A then moveDir -= cam.CFrame.RightVector end
            if movementData.flyKeys.D then moveDir += cam.CFrame.RightVector end
            if movementData.flyKeys.LeftShift then moveDir -= Vector3.new(0,1,0) end
            if movementData.flyKeys.Space then moveDir += Vector3.new(0,1,0) end
            root.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * movementData.flySpeed or Vector3.zero
        end

        if not movementData.flyEnabled and movementData.speedEnabled then
            local moveDir = Vector3.zero
            local cam = workspace.CurrentCamera
            if movementData.speedKeys.W then moveDir += cam.CFrame.LookVector end
            if movementData.speedKeys.S then moveDir -= cam.CFrame.LookVector end
            if movementData.speedKeys.A then moveDir -= cam.CFrame.RightVector end
            if movementData.speedKeys.D then moveDir += cam.CFrame.RightVector end
            moveDir = Vector3.new(moveDir.X, 0, moveDir.Z)
            if moveDir.Magnitude > 0 then
                root.Velocity = Vector3.new(moveDir.Unit.X * movementData.speedValue, root.Velocity.Y, moveDir.Unit.Z * movementData.speedValue)
            end
        end

        if not movementData.flyEnabled and not movementData.speedEnabled and movementData.jumpEnabled then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if humanoid.FloorMaterial ~= Enum.Material.Air or movementData.infiniteJumpEnabled then
                    root.Velocity = Vector3.new(root.Velocity.X, movementData.jumpPowerValue, root.Velocity.Z)
                end
            end
        end

        if movementData.infiniteJumpEnabled then
            pcall(function()
                local mech = getMech()
                if mech then
                    local item = mech.LocalFighter and mech.LocalFighter.EquippedItem
                    if item and item.Info then
                        item.Info.MaxDoubleJumps = 1000
                    end
                end
            end)
        end

        if movementData.slideBoostEnabled then
            local mech = getMech()
            if mech then
                local f = mech.LocalFighter
                if f then
                    if not movementData.slideBaseSpeed then
                        movementData.slideBaseSpeed = f:Get("SlidingSpeedMax") or 3
                    end
                    f:Set("SlidingSpeedMax", movementData.slideBaseSpeed * movementData.slideBoostMultiplier)
                end
            end
        end
    end)
end

function stopMovementHeartbeat()
    if movementHeartbeatConn then
        movementHeartbeatConn:Disconnect()
        movementHeartbeatConn = nil
    end
end

return {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    Lighting = Lighting,
    isSameTeam = isSameTeam,
    isTargetVisible = isTargetVisible,
    getMech = getMech,
    setThirdPerson = setThirdPerson,
    startMovementHeartbeat = startMovementHeartbeat,
    stopMovementHeartbeat = stopMovementHeartbeat,
}
