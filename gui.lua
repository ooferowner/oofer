-- GUI System for Roblox Multi-Game Hub
-- Handles all user interface elements including health, score, and game controls

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI Configuration
local GUI_CONFIG = {
    HEALTH_BAR_COLOR = Color3.fromRGB(0, 255, 0),
    HEALTH_BAR_DANGER_COLOR = Color3.fromRGB(255, 0, 0),
    SCORE_COLOR = Color3.fromRGB(255, 255, 0),
    BACKGROUND_COLOR = Color3.fromRGB(0, 0, 0),
    TEXT_COLOR = Color3.fromRGB(255, 255, 255)
}

-- Create Main GUI
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Health Bar Frame
    local healthFrame = Instance.new("Frame")
    healthFrame.Name = "HealthFrame"
    healthFrame.Size = UDim2.new(0, 200, 0, 30)
    healthFrame.Position = UDim2.new(0, 10, 0, 10)
    healthFrame.BackgroundColor3 = GUI_CONFIG.BACKGROUND_COLOR
    healthFrame.BorderSizePixel = 2
    healthFrame.BorderColor3 = GUI_CONFIG.TEXT_COLOR
    healthFrame.Parent = screenGui
    
    -- Health Bar
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = GUI_CONFIG.HEALTH_BAR_COLOR
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthFrame
    
    -- Health Text
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.Position = UDim2.new(0, 0, 0, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = "Health: 100/100"
    healthText.TextColor3 = GUI_CONFIG.TEXT_COLOR
    healthText.TextScaled = true
    healthText.Font = Enum.Font.SourceSansBold
    healthText.Parent = healthFrame
    
    -- Score Frame
    local scoreFrame = Instance.new("Frame")
    scoreFrame.Name = "ScoreFrame"
    scoreFrame.Size = UDim2.new(0, 200, 0, 30)
    scoreFrame.Position = UDim2.new(0, 10, 0, 50)
    scoreFrame.BackgroundColor3 = GUI_CONFIG.BACKGROUND_COLOR
    scoreFrame.BorderSizePixel = 2
    scoreFrame.BorderColor3 = GUI_CONFIG.TEXT_COLOR
    scoreFrame.Parent = screenGui
    
    -- Score Text
    local scoreText = Instance.new("TextLabel")
    scoreText.Name = "ScoreText"
    scoreText.Size = UDim2.new(1, 0, 1, 0)
    scoreText.Position = UDim2.new(0, 0, 0, 0)
    scoreText.BackgroundTransparency = 1
    scoreText.Text = "Score: 0"
    scoreText.TextColor3 = GUI_CONFIG.SCORE_COLOR
    scoreText.TextScaled = true
    scoreText.Font = Enum.Font.SourceSansBold
    scoreText.Parent = scoreFrame
    
    -- Game Mode Display
    local gameModeFrame = Instance.new("Frame")
    gameModeFrame.Name = "GameModeFrame"
    gameModeFrame.Size = UDim2.new(0, 300, 0, 40)
    gameModeFrame.Position = UDim2.new(0, 10, 0, 90)
    gameModeFrame.BackgroundColor3 = GUI_CONFIG.BACKGROUND_COLOR
    gameModeFrame.BorderSizePixel = 2
    gameModeFrame.BorderColor3 = GUI_CONFIG.TEXT_COLOR
    gameModeFrame.Parent = screenGui
    
    local gameModeText = Instance.new("TextLabel")
    gameModeText.Name = "GameModeText"
    gameModeText.Size = UDim2.new(1, 0, 1, 0)
    gameModeText.Position = UDim2.new(0, 0, 0, 0)
    gameModeText.BackgroundTransparency = 1
    gameModeText.Text = "Current Game: Lobby"
    gameModeText.TextColor3 = GUI_CONFIG.TEXT_COLOR
    gameModeText.TextScaled = true
    gameModeText.Font = Enum.Font.SourceSansBold
    gameModeText.Parent = gameModeFrame
    
    -- Controls Display
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "ControlsFrame"
    controlsFrame.Size = UDim2.new(0, 400, 0, 120)
    controlsFrame.Position = UDim2.new(1, -410, 0, 10)
    controlsFrame.BackgroundColor3 = GUI_CONFIG.BACKGROUND_COLOR
    controlsFrame.BorderSizePixel = 2
    controlsFrame.BorderColor3 = GUI_CONFIG.TEXT_COLOR
    controlsFrame.Parent = screenGui
    
    local controlsText = Instance.new("TextLabel")
    controlsText.Name = "ControlsText"
    controlsText.Size = UDim2.new(1, 0, 1, 0)
    controlsText.Position = UDim2.new(0, 0, 0, 0)
    controlsText.BackgroundTransparency = 1
    controlsText.Text = "CONTROLS:\nB - Start BedWars\nS - Start Steal a Brain\nL - Return to Lobby\nR - Reset All Players"
    controlsText.TextColor3 = GUI_CONFIG.TEXT_COLOR
    controlsText.TextScaled = true
    controlsText.Font = Enum.Font.SourceSans
    controlsText.TextXAlignment = Enum.TextXAlignment.Left
    controlsText.TextYAlignment = Enum.TextYAlignment.Top
    controlsText.Parent = controlsFrame
    
    return screenGui
end

-- Update Health Display
local function updateHealth(health, maxHealth)
    local screenGui = playerGui:FindFirstChild("GameGUI")
    if not screenGui then return end
    
    local healthFrame = screenGui:FindFirstChild("HealthFrame")
    local healthBar = healthFrame and healthFrame:FindFirstChild("HealthBar")
    local healthText = healthFrame and healthFrame:FindFirstChild("HealthText")
    
    if healthBar and healthText then
        local healthPercent = health / maxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        healthText.Text = "Health: " .. math.floor(health) .. "/" .. maxHealth
        
        -- Change color based on health
        if healthPercent < 0.3 then
            healthBar.BackgroundColor3 = GUI_CONFIG.HEALTH_BAR_DANGER_COLOR
        else
            healthBar.BackgroundColor3 = GUI_CONFIG.HEALTH_BAR_COLOR
        end
        
        -- Animate health bar
        local tween = TweenService:Create(healthBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(healthPercent, 0, 1, 0)
        })
        tween:Play()
    end
end

-- Update Score Display
local function updateScore(score)
    local screenGui = playerGui:FindFirstChild("GameGUI")
    if not screenGui then return end
    
    local scoreFrame = screenGui:FindFirstChild("ScoreFrame")
    local scoreText = scoreFrame and scoreFrame:FindFirstChild("ScoreText")
    
    if scoreText then
        scoreText.Text = "Score: " .. score
        
        -- Animate score change
        local tween = TweenService:Create(scoreText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            TextColor3 = GUI_CONFIG.SCORE_COLOR
        })
        tween:Play()
    end
end

-- Update Game Mode Display
local function updateGameMode(gameMode)
    local screenGui = playerGui:FindFirstChild("GameGUI")
    if not screenGui then return end
    
    local gameModeFrame = screenGui:FindFirstChild("GameModeFrame")
    local gameModeText = gameModeFrame and gameModeFrame:FindFirstChild("GameModeText")
    
    if gameModeText then
        gameModeText.Text = "Current Game: " .. gameMode
        
        -- Animate game mode change
        local tween = TweenService:Create(gameModeText, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            TextColor3 = GUI_CONFIG.TEXT_COLOR
        })
        tween:Play()
    end
end

-- Show Notification
local function showNotification(message, duration)
    local screenGui = playerGui:FindFirstChild("GameGUI")
    if not screenGui then return end
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 50)
    notification.Position = UDim2.new(0.5, -150, 0, 50)
    notification.BackgroundColor3 = GUI_CONFIG.BACKGROUND_COLOR
    notification.BorderSizePixel = 2
    notification.BorderColor3 = GUI_CONFIG.TEXT_COLOR
    notification.Parent = screenGui
    
    local notificationText = Instance.new("TextLabel")
    notificationText.Name = "NotificationText"
    notificationText.Size = UDim2.new(1, 0, 1, 0)
    notificationText.Position = UDim2.new(0, 0, 0, 0)
    notificationText.BackgroundTransparency = 1
    notificationText.Text = message
    notificationText.TextColor3 = GUI_CONFIG.TEXT_COLOR
    notificationText.TextScaled = true
    notificationText.Font = Enum.Font.SourceSansBold
    notificationText.Parent = notification
    
    -- Animate notification
    local tween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -150, 0, 50)
    })
    tween:Play()
    
    -- Remove notification after duration
    wait(duration or 3)
    local fadeTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -150, 0, -60)
    })
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        notification:Destroy()
    end)
end

-- Initialize GUI
local function initializeGUI()
    createMainGUI()
    updateHealth(100, 100)
    updateScore(0)
    updateGameMode("Lobby")
    showNotification("Welcome to Multi-Game Hub!", 3)
end

-- Export functions for use by other scripts
local GUI = {
    updateHealth = updateHealth,
    updateScore = updateScore,
    updateGameMode = updateGameMode,
    showNotification = showNotification,
    initialize = initializeGUI
}

return GUI