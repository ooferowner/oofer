-- Hostile GUI Shell by dracule_
local gui = Instance.new("ScreenGui")
gui.Name = "HostileShell"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local panels = {}
local currentZ = 10
local tabNames = { "Blatant", "Combat", "Render", "Settings", "Utility" }

-- Store module update functions for reload
local moduleUpdaters = {}

local function enableDrag(frame, dragArea)
    local dragging, dragStart, startPos = false
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and frame.Visible then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

for _, name in ipairs(tabNames) do
    local panel = Instance.new("ScrollingFrame")
    panel.Name = name .. "Panel"
    panel.Size = UDim2.new(0, 220, 0, 520)
    panel.Position = UDim2.new(0.5, 120, 0.5, -260)
    panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    panel.BackgroundTransparency = 0.3
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 2
    panel.CanvasSize = UDim2.new(0, 0, 0, 1000)
    panel.ScrollingDirection = Enum.ScrollingDirection.Y
    panel.ScrollBarThickness = 4
    panel.ScrollBarImageColor3 = Color3.fromRGB(120, 0, 180)
    panel.ClipsDescendants = true
    panel.Parent = gui

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    header.BorderSizePixel = 0
    header.Font = Enum.Font.SciFi
    header.TextSize = 18
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.Text = name
    header.TextXAlignment = Enum.TextXAlignment.Center
    header.ZIndex = 3
    header.Parent = panel

    enableDrag(panel, header)

    local yTrack = Instance.new("IntValue")
    yTrack.Name = "NextModuleY"
    yTrack.Value = 50
    yTrack.Parent = panel

    yTrack:GetPropertyChangedSignal("Value"):Connect(function()
        panel.CanvasSize = UDim2.new(0, 0, 0, yTrack.Value + 20)
    end)

    panels[name] = panel
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 220, 0, 520)
main.Position = UDim2.new(0.5, -110, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
main.BackgroundTransparency = 0.3
main.BorderSizePixel = 0
main.Active = true
main.Draggable = false
main.Parent = gui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
topBar.BackgroundTransparency = 0.1
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Active = true
topBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SciFi
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 3
title.Parent = topBar

local glitchFrames = { "00fΞr", "0Øfer", "O0fΞr", "0⚡fer", "00fΞr", "00f3r", "0Ofer", "00fer" }
spawn(function()
    while true do
        for _, text in ipairs(glitchFrames) do
            title.Text = text
            wait(0.08)
        end
    end
end)

for i, name in ipairs(tabNames) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, -20, 0, 90)
    tab.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * 90)
    tab.BackgroundTransparency = 0.2
    tab.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
    tab.Text = name
    tab.Font = Enum.Font.SciFi
    tab.TextSize = 22
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.ZIndex = 2
    tab.Parent = main

    tab.MouseButton1Click:Connect(function()
        local panel = panels[name]
        if panel then
            panel.Visible = not panel.Visible
            if panel.Visible then
                currentZ += 1
                panel.ZIndex = currentZ
                for _, child in ipairs(panel:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child.ZIndex = currentZ + 1
                    end
                end
            else
                panel.ZIndex = 2
                for _, child in ipairs(panel:GetChildren()) do
                    if child:IsA("GuiObject") then
                        child.ZIndex = 3
                    end
                end
            end
        end
    end)
end

local bottomBar = Instance.new("Frame")
bottomBar.Size = UDim2.new(1, 0, 0, 30)
bottomBar.Position = UDim2.new(0, 0, 1, -30)
bottomBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bottomBar.BackgroundTransparency = 0.4
bottomBar.BorderSizePixel = 0
bottomBar.ZIndex = 2
bottomBar.Parent = main

enableDrag(main, topBar)

local oofButton = Instance.new("TextButton")
oofButton.Size = UDim2.new(0, 100, 0, 32)
oofButton.Position = UDim2.new(1, -110, 0, 10)
oofButton.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
oofButton.BorderSizePixel = 0
oofButton.Font = Enum.Font.SciFi
oofButton.TextSize = 18
oofButton.TextColor3 = Color3.fromRGB(255, 255, 255)
oofButton.Text = "OOF"
oofButton.ZIndex = 999
oofButton.Parent = gui

local oofState = true
local oofGlitchFrames = { "O⚡F", "ØØF", "0O0F", "O0FΞ", "OOF" }

oofButton.MouseButton1Click:Connect(function()
    oofState = not oofState
    main.Visible = oofState
    for _, panel in pairs(panels) do
        panel.Visible = oofState
    end
end)

spawn(function()
    while true do
        for _, text in ipairs(oofGlitchFrames) do
            oofButton.Text = text
            oofButton.Size = UDim2.new(0, 100 + math.random(-2, 2), 0, 32 + math.random(-1, 1))
            wait(0.07)
        end
    end
end)
-- 🔧 Required Setup
local CombatPanel = panels["Combat"]
if not CombatPanel:FindFirstChild("NextModuleY") then
    local yTrack = Instance.new("IntValue")
    yTrack.Name = "NextModuleY"
    yTrack.Value = 50
    yTrack.Parent = CombatPanel
end

local moduleName = "KillAura"
local keybind = Enum.KeyCode.R
local player = game.Players.LocalPlayer
local active = player:GetAttribute(moduleName .. "Active") or false

-- 🔁 Main Toggle Button
local moduleLabel = Instance.new("TextButton")
moduleLabel.Size = UDim2.new(1, -20, 0, 32)
moduleLabel.Position = UDim2.new(0, 10, 0, CombatPanel.NextModuleY.Value)
moduleLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
moduleLabel.BorderSizePixel = 0
moduleLabel.Font = Enum.Font.SciFi
moduleLabel.TextSize = 20
moduleLabel.TextColor3 = active and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 255, 255)
moduleLabel.Text = moduleName
moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
moduleLabel.ZIndex = CombatPanel.ZIndex + 2
moduleLabel.Parent = CombatPanel

CombatPanel.NextModuleY.Value += 34

-- ⚙️ Settings Frame
local settingsFrame = Instance.new("Frame")
settingsFrame.Size = UDim2.new(1, -20, 0, 64)
settingsFrame.Position = UDim2.new(0, 10, 0, CombatPanel.NextModuleY.Value)
settingsFrame.BackgroundTransparency = 1
settingsFrame.Visible = false
settingsFrame.ZIndex = CombatPanel.ZIndex + 1
settingsFrame.Parent = CombatPanel

CombatPanel.NextModuleY.Value += 64

-- 🔑 Keybind Button
local keybindButton = Instance.new("TextButton")
keybindButton.Size = UDim2.new(1, 0, 0, 32)
keybindButton.Position = UDim2.new(0, 0, 0, 0)
keybindButton.BackgroundTransparency = 1
keybindButton.Font = Enum.Font.SciFi
keybindButton.TextSize = 18
keybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
keybindButton.Text = "Keybind: [" .. keybind.Name .. "]"
keybindButton.ZIndex = settingsFrame.ZIndex + 1
keybindButton.Parent = settingsFrame

keybindButton.MouseButton1Click:Connect(function()
    keybindButton.Text = "Press any key..."
    local conn
    conn = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            keybind = input.KeyCode
            keybindButton.Text = "Keybind: [" .. keybind.Name .. "]"
            conn:Disconnect()
        end
    end)
end)

-- ⚔️ Combat Logic
local function attackLoop()
    spawn(function()
        while true do
            task.wait(0.2)
            if active then
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then continue end

                for _, target in ipairs(game.Players:GetPlayers()) do
                    if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (target.Character.HumanoidRootPart.Position - root.Position).Magnitude
                        if dist <= 18 then
                            char:SetPrimaryPartCFrame(CFrame.lookAt(root.Position, target.Character.HumanoidRootPart.Position))
                            local remote = require(game:GetService("ReplicatedStorage"):WaitForChild("TS"):WaitForChild("remotes"):WaitForChild("default"):WaitForChild("ClientStore")).AttackEntity
                            remote:FireServer({["entity"] = target.Character})
                            break
                        end
                    end
                end
            end
        end
    end)
end

-- 🔁 Toggle State Logic
local function updateState(state)
    active = state
    player:SetAttribute(moduleName .. "Active", active)
    moduleLabel.TextColor3 = active and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 255, 255)
end

updateState(active)
attackLoop()

-- 🔥 Keybind Activation
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == keybind then
        updateState(not active)
    end
end)

-- 🖱️ Double-click / Long-press to open settings
local lastClick = 0
moduleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local now = tick()
        if now - lastClick < 0.3 then
            settingsFrame.Visible = not settingsFrame.Visible
        end
        lastClick = now
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local hold = tick()
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                if tick() - hold > 0.5 then
                    settingsFrame.Visible = not settingsFrame.Visible
                end
                conn:Disconnect()
            end
        end)
    end
end)

-- 💬 Injection Message
game.StarterGui:SetCore("SendNotification", {
    Title = "Hostile Module",
    Text = "Kill Aura injected",
    Duration = 4
})

