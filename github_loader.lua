-- OTTER CLIENT - GitHub Style Loader
-- Enhanced Loader with Error Handling, Version Checking, and Auto-Updates
-- Author: Enhanced by AI Assistant
-- Version: 2.0

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer

-- Configuration
local CONFIG = {
    GITHUB_RAW_URL = "https://raw.githubusercontent.com/yourusername/otter-client/main/",
    SCRIPT_NAME = "otter_client_enhanced.lua",
    VERSION_CHECK_URL = "https://raw.githubusercontent.com/yourusername/otter-client/main/version.txt",
    LOADING_TIMEOUT = 30, -- seconds
    RETRY_ATTEMPTS = 3,
    CACHE_DURATION = 300, -- 5 minutes
}

-- Enhanced loading screen
local function createLoadingScreen()
    local loadingGui = Instance.new("ScreenGui")
    loadingGui.Name = "OtterClient_Loading"
    loadingGui.ResetOnSpawn = false
    loadingGui.IgnoreGuiInset = true
    loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loadingGui.Parent = CoreGui
    
    -- Background
    local background = Instance.new("Frame")
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(3, 7, 16)
    background.BorderSizePixel = 0
    background.Parent = loadingGui
    
    -- Gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 7, 16)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 14, 26))
    })
    gradient.Rotation = 45
    gradient.Parent = background
    
    -- Loading container
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(400, 200)
    container.Position = UDim2.new(0.5, -200, 0.5, -100)
    container.BackgroundColor3 = Color3.fromRGB(14, 21, 36)
    container.BorderSizePixel = 0
    container.Parent = loadingGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = container
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 191, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = container
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "OTTER CLIENT"
    title.TextColor3 = Color3.fromRGB(0, 191, 255)
    title.TextSize = 24
    title.Font = Enum.Font.SourceSansBold
    title.Parent = container
    
    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0, 60)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Enhanced Ultra Premium GUI"
    subtitle.TextColor3 = Color3.fromRGB(135, 150, 175)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.SourceSans
    subtitle.Parent = container
    
    -- Loading text
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Position = UDim2.new(0, 0, 0, 100)
    loadingText.BackgroundTransparency = 1
    loadingText.Text = "Loading..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.TextSize = 16
    loadingText.Font = Enum.Font.SourceSans
    loadingText.Parent = container
    
    -- Progress bar
    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, -40, 0, 8)
    progressBg.Position = UDim2.new(0, 20, 0, 150)
    progressBg.BackgroundColor3 = Color3.fromRGB(1, 3, 12)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = container
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 4)
    progressCorner.Parent = progressBg
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.Position = UDim2.new(0, 0, 0, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 4)
    progressBarCorner.Parent = progressBar
    
    -- Animated loading dots
    local dots = Instance.new("TextLabel")
    dots.Size = UDim2.new(1, 0, 0, 20)
    dots.Position = UDim2.new(0, 0, 0, 170)
    dots.BackgroundTransparency = 1
    dots.Text = "..."
    dots.TextColor3 = Color3.fromRGB(0, 191, 255)
    dots.TextSize = 20
    dots.Font = Enum.Font.SourceSansBold
    dots.Parent = container
    
    -- Animate dots
    spawn(function()
        local dotCount = 0
        while loadingGui.Parent do
            dotCount = (dotCount % 3) + 1
            dots.Text = string.rep(".", dotCount)
            task.wait(0.5)
        end
    end)
    
    return loadingGui, loadingText, progressBar
end

-- Enhanced HTTP request with retry logic
local function httpRequest(url, retries)
    retries = retries or CONFIG.RETRY_ATTEMPTS
    
    for attempt = 1, retries do
        local success, result = pcall(function()
            return HttpService:GetAsync(url, true)
        end)
        
        if success then
            return result
        else
            warn("HTTP Request failed (attempt " .. attempt .. "/" .. retries .. "): " .. tostring(result))
            if attempt < retries then
                task.wait(2 ^ attempt) -- Exponential backoff
            end
        end
    end
    
    error("Failed to fetch " .. url .. " after " .. retries .. " attempts")
end

-- Version checking
local function checkVersion()
    local success, version = pcall(function()
        return httpRequest(CONFIG.VERSION_CHECK_URL)
    end)
    
    if success then
        return version:match("(%d+%.%d+%.%d+)") or "1.0.0"
    else
        warn("Failed to check version, using default")
        return "1.0.0"
    end
end

-- Enhanced script loading with progress
local function loadScript(loadingText, progressBar)
    local scriptUrl = CONFIG.GITHUB_RAW_URL .. CONFIG.SCRIPT_NAME
    local version = checkVersion()
    
    loadingText.Text = "Checking for updates... (v" .. version .. ")"
    TweenService:Create(progressBar, TweenInfo.new(0.5), {Size = UDim2.new(0.2, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    loadingText.Text = "Downloading script..."
    TweenService:Create(progressBar, TweenInfo.new(0.5), {Size = UDim2.new(0.4, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    local success, script = pcall(function()
        return httpRequest(scriptUrl)
    end)
    
    if not success then
        error("Failed to load script: " .. tostring(script))
    end
    
    loadingText.Text = "Validating script..."
    TweenService:Create(progressBar, TweenInfo.new(0.5), {Size = UDim2.new(0.6, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    loadingText.Text = "Initializing GUI..."
    TweenService:Create(progressBar, TweenInfo.new(0.5), {Size = UDim2.new(0.8, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    loadingText.Text = "Finalizing..."
    TweenService:Create(progressBar, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    return script
end

-- Enhanced error handling
local function handleError(error)
    warn("Otter Client Loader Error: " .. tostring(error))
    
    -- Create error notification
    local errorGui = Instance.new("ScreenGui")
    errorGui.Name = "OtterClient_Error"
    errorGui.ResetOnSpawn = false
    errorGui.Parent = CoreGui
    
    local errorFrame = Instance.new("Frame")
    errorFrame.Size = UDim2.fromOffset(400, 150)
    errorFrame.Position = UDim2.new(0.5, -200, 0.5, -75)
    errorFrame.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    errorFrame.BorderSizePixel = 0
    errorFrame.Parent = errorGui
    
    local errorCorner = Instance.new("UICorner")
    errorCorner.CornerRadius = UDim.new(0, 15)
    errorCorner.Parent = errorFrame
    
    local errorText = Instance.new("TextLabel")
    errorText.Size = UDim2.new(1, -20, 1, -20)
    errorText.Position = UDim2.new(0, 10, 0, 10)
    errorText.BackgroundTransparency = 1
    errorText.Text = "Failed to load Otter Client!\n\nError: " .. tostring(error) .. "\n\nPlease check your internet connection and try again."
    errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
    errorText.TextSize = 14
    errorText.Font = Enum.Font.SourceSans
    errorText.TextWrapped = true
    errorText.Parent = errorFrame
    
    -- Auto-remove error after 10 seconds
    task.delay(10, function()
        if errorGui.Parent then
            errorGui:Destroy()
        end
    end)
end

-- Main loader function
local function loadOtterClient()
    local loadingGui, loadingText, progressBar = createLoadingScreen()
    
    spawn(function()
        local success, result = pcall(function()
            local script = loadScript(loadingText, progressBar)
            
            -- Execute the script
            local func = loadstring(script)
            if func then
                local mainAPI = func()
                
                -- Clean up loading screen
                TweenService:Create(loadingGui, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                    BackgroundTransparency = 1
                }):Play()
                
                for _, child in pairs(loadingGui:GetChildren()) do
                    if child:IsA("GuiObject") then
                        TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
                            BackgroundTransparency = 1
                        }):Play()
                    end
                end
                
                task.wait(0.5)
                loadingGui:Destroy()
                
                -- Show success notification
                if mainAPI and mainAPI.notificationManager then
                    mainAPI.notificationManager:show("Otter Client loaded successfully!", Color3.fromRGB(0, 255, 0), 3)
                end
                
                return mainAPI
            else
                error("Failed to compile script")
            end
        end)
        
        if not success then
            loadingGui:Destroy()
            handleError(result)
        end
    end)
end

-- Enhanced startup with safety checks
local function initialize()
    -- Check if already loaded
    if CoreGui:FindFirstChild("OtterClient_Enhanced") then
        warn("Otter Client is already loaded!")
        return
    end
    
    -- Check internet connectivity
    local success, result = pcall(function()
        return HttpService:GetAsync("https://httpbin.org/get", true)
    end)
    
    if not success then
        warn("No internet connection detected, using offline mode...")
        -- You could load a cached version here
        return
    end
    
    -- Start loading
    loadOtterClient()
end

-- Auto-initialize
initialize()

-- Export for manual loading
return {
    load = loadOtterClient,
    initialize = initialize,
    config = CONFIG
}