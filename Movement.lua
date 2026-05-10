return function(Core, State)
    local RunService = Core.RunService
    local UserInputService = Core.UserInputService

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then State.flyKeys.W = true; State.speedKeys.W = true end
        if k == Enum.KeyCode.A then State.flyKeys.A = true; State.speedKeys.A = true end
        if k == Enum.KeyCode.S then State.flyKeys.S = true; State.speedKeys.S = true end
        if k == Enum.KeyCode.D then State.flyKeys.D = true; State.speedKeys.D = true end
        if k == Enum.KeyCode.Space then State.flyKeys.Space = true end
        if k == Enum.KeyCode.LeftShift then State.flyKeys.LeftShift = true end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        local k = input.KeyCode
        if k == Enum.KeyCode.W then State.flyKeys.W = false; State.speedKeys.W = false end
        if k == Enum.KeyCode.A then State.flyKeys.A = false; State.speedKeys.A = false end
        if k == Enum.KeyCode.S then State.flyKeys.S = false; State.speedKeys.S = false end
        if k == Enum.KeyCode.D then State.flyKeys.D = false; State.speedKeys.D = false end
        if k == Enum.KeyCode.Space then State.flyKeys.Space = false end
        if k == Enum.KeyCode.LeftShift then State.flyKeys.LeftShift = false end
    end)

    function State.setupNoclip()
        RunService:BindToRenderStep("Noclip", 0, function()
            if State.noclipEnabled and Players.LocalPlayer.Character then
                for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end

    function State.removeNoclip()
        RunService:UnbindFromRenderStep("Noclip")
        if Players.LocalPlayer.Character then
            for _, part in pairs(Players.LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end
