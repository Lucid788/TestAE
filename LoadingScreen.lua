return function()
    local TweenService = game:GetService("TweenService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "AspectLoadingScreen"
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.IgnoreGuiInset = true
    loadingGui.ResetOnSpawn = false
    loadingGui.Parent = player:WaitForChild("PlayerGui")

    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.3
    background.BorderSizePixel = 0
    background.Parent = loadingGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 200, 50)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = background

    local corners = {}
    local cornerPositions = {
        {0, 0, 0, 0},
        {1, -30, 0, 0},
        {0, 0, 1, -30},
        {1, -30, 1, -30}
    }
    
    for i = 1, #cornerPositions do
        local pos = cornerPositions[i]
        local corner = Instance.new("Frame")
        corner.Size = UDim2.new(0, 30, 0, 30)
        corner.Position = UDim2.new(pos[1], pos[2], pos[3], pos[4])
        corner.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        corner.BorderSizePixel = 0
        corner.Parent = mainFrame
        corners[i] = corner
    end

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 70)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "ASPECT HUB"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 42
    title.Font = Enum.Font.GothamBlack
    title.TextStrokeTransparency = 0.3
    title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    title.Parent = mainFrame

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 90)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "DEVELOPED BY AE DEV TEAM"
    subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    subtitle.TextSize = 20
    subtitle.Font = Enum.Font.GothamMedium
    subtitle.TextTransparency = 0.3
    subtitle.Parent = mainFrame

    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0.5, -15)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Initializing systems..."
    loadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.Gotham
    loadingText.TextTransparency = 0.2
    loadingText.Parent = mainFrame

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0.7, 0, 0, 6)
    barBg.Position = UDim2.new(0.15, 0, 0.7, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 1
    barBg.BorderColor3 = Color3.fromRGB(80, 80, 80)
    barBg.Parent = mainFrame

    local loadingBar = Instance.new("Frame")
    loadingBar.Size = UDim2.new(0, 0, 1, 0)
    loadingBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    loadingBar.BorderSizePixel = 0
    loadingBar.Parent = barBg

    local percentText = Instance.new("TextLabel")
    percentText.Size = UDim2.new(1, 0, 0, 30)
    percentText.Position = UDim2.new(0, 0, 1, 8)
    percentText.BackgroundTransparency = 1
    percentText.Text = "0%"
    percentText.TextColor3 = Color3.fromRGB(200, 200, 200)
    percentText.TextSize = 14
    percentText.Font = Enum.Font.Gotham
    percentText.TextXAlignment = Enum.TextXAlignment.Center
    percentText.Parent = barBg

    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(1, 0, 0, 20)
    versionText.Position = UDim2.new(0, 0, 1, 40)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v2.0.0"
    versionText.TextColor3 = Color3.fromRGB(150, 150, 150)
    versionText.TextSize = 12
    versionText.Font = Enum.Font.Gotham
    versionText.TextTransparency = 0.5
    versionText.Parent = background

    local phrases = {
        "Initializing systems...",
        "Loading modules...",
        "Connecting to server...",
        "Authenticating...",
        "Loading configurations...",
        "Starting enchantments...",
        "Almost ready...",
        "Welcome!"
    }

    local function fadeOutAndDestroy()

        local tweens = {
            TweenService:Create(background, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}),
            TweenService:Create(mainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}),
            TweenService:Create(title, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}),
            TweenService:Create(subtitle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}),
            TweenService:Create(loadingText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}),
            TweenService:Create(barBg, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}),
            TweenService:Create(percentText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}),
            TweenService:Create(versionText, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}),
        }

        for _, corner in ipairs(corners) do
            table.insert(tweens, TweenService:Create(corner, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}))
        end

        for _, tween in ipairs(tweens) do
            tween:Play()
        end

        task.wait(0.8)
        pcall(function()
            loadingGui:Destroy()
        end)
    end

    local duration = 5
    local barTween = TweenService:Create(
        loadingBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
        {Size = UDim2.new(1, 0, 1, 0)}
    )
    barTween:Play()

    barTween.Completed:Connect(function()
        fadeOutAndDestroy()
    end)

    task.spawn(function()
        local startTime = tick()
        local elapsed = 0
        while elapsed < duration do
            elapsed = tick() - startTime
            local progress = math.min(1, elapsed / duration)
            percentText.Text = math.floor(progress * 100) .. "%"
            task.wait(0.05)
        end
        percentText.Text = "100%"
    end)

    task.spawn(function()
        for i = 2, #phrases do
            task.wait(0.65)
            if loadingText then
                loadingText.Text = phrases[i]

                loadingText.TextTransparency = 0
                TweenService:Create(loadingText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()
            end
        end
    end)

    task.delay(6, function()
        if loadingGui and loadingGui.Parent then
            pcall(function()
                fadeOutAndDestroy()
            end)
        end
    end)

    return loadingGui
end
