local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Blur + Tint
local Blur = Instance.new("BlurEffect")
Blur.Size = 25
Blur.Enabled = true
Blur.Parent = Lighting

local Tint = Instance.new("ColorCorrectionEffect")
Tint.TintColor = Color3.fromRGB(180, 0, 255)
Tint.Saturation = 0.3
Tint.Brightness = -0.05
Tint.Enabled = true
Tint.Parent = Lighting

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 0, 400)
Sidebar.Position = UDim2.new(0, 20, 0.25, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ScreenGui
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = ""
Title.Font = Enum.Font.Arcade
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.BorderSizePixel = 0
Title.Parent = Sidebar

task.spawn(function()
    local text = "OOFER"
    while true do
        local display = ""
        for i = 1, #text do
            display = display .. string.char(math.random(33, 126))
        end
        Title.Text = display
        task.wait(0.05)
        Title.Text = text
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        local t = tick() * 0.5
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        Title.TextColor3 = Color3.fromRGB(r, g, b)
        for _, panel in pairs(ScreenGui:GetChildren()) do
            if panel:FindFirstChild("Header") then
                panel.Header.TextColor3 = Color3.fromRGB(r, g, b)
            end
        end
        task.wait(0.05)
    end
end)

-- Container
local container = Instance.new("Frame", Sidebar)
container.Size = UDim2.new(1, -8, 1, -40)
container.Position = UDim2.new(0, 4, 0, 35)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)

-- Categories
local Categories = {
    {name = "Combat",    id = "rbxassetid://3926305904", offset = Vector2.new(4, 4)},
    {name = "Blatant",   id = "rbxassetid://3926305904", offset = Vector2.new(76, 4)},
    {name = "Render",    id = "rbxassetid://3926305904", offset = Vector2.new(112, 4)},
    {name = "Utility",   id = "rbxassetid://3926305904", offset = Vector2.new(184, 4)},
    {name = "World",     id = "rbxassetid://3926305904", offset = Vector2.new(220, 4)},
    {name = "Friends",   id = "rbxassetid://3926307971", offset = Vector2.new(184, 4)},
    {name = "Profiles",  id = "rbxassetid://3926307971", offset = Vector2.new(292, 4)},
    {name = "Targets",   id = "rbxassetid://3926307971", offset = Vector2.new(148, 4)},
}

-- Module API (GLOBAL oofer so modules can see it)
oofer = { Categories = {} }
for _, cat in ipairs(Categories) do
    oofer.Categories[cat.name] = {
        Modules = {},
        CreateModule = function(self, data)
            local mod = {
                Name = data.Name,
                Tooltip = data.Tooltip or "",
                ExtraText = data.ExtraText or function() return "" end,
                Enabled = false,
                Function = data.Function or function() end,
                Sliders = {},
                Toggles = {}
            }
            function mod:CreateSlider(opts)
                local slider = {
                    Name = opts.Name,
                    Min = opts.Min or 0,
                    Max = opts.Max or 100,
                    Value = opts.Default or 0,
                    Suffix = opts.Suffix or function(v) return tostring(v) end,
                    Function = opts.Function or function() end,
                    Tooltip = opts.Tooltip or ""
                }
                table.insert(self.Sliders, slider)
                return slider
            end
            function mod:CreateToggle(opts)
                local toggle = {
                    Name = opts.Name,
                    Enabled = opts.Default or false,
                    Function = opts.Function or function() end,
                    Tooltip = opts.Tooltip or ""
                }
                table.insert(self.Toggles, toggle)
                return toggle
            end
            table.insert(self.Modules, mod)
            return mod
        end
    }
end

-- Draggable
local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    local UserInputService = game:GetService("UserInputService")
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end
MakeDraggable(Sidebar, Title)

-- Category buttons
local PanelXOffset = 230
for i, cat in ipairs(Categories) do
    local Btn = Instance.new("TextButton", container)
    Btn.Size = UDim2.new(1, -6, 0, 26)
    Btn.BackgroundTransparency = 1
    Btn.AutoButtonColor = false
    Btn.Text = ""
    Btn.BorderSizePixel = 0

    local Icon = Instance.new("ImageLabel", Btn)
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Position = UDim2.new(0, 6, 0.5, -9)
    Icon.BackgroundTransparency = 1
    Icon.Image = cat.id
    Icon.ImageRectOffset = cat.offset
    Icon.ImageRectSize = Vector2.new(36, 36)
    Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)

    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = cat.name
    Label.Font = Enum.Font.Arcade
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)

    Btn.MouseEnter:Connect(function()
        Label.TextColor3 = Color3.fromRGB(0, 200, 255)
        Icon.ImageColor3 = Color3.fromRGB(0, 200, 255)
    end)
    Btn.MouseLeave:Connect(function()
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    end)

    Btn.MouseButton1Click:Connect(function()
        if ScreenGui:FindFirstChild(cat.name .. "Panel") then return end
        local Panel = Instance.new("Frame")
        Panel.Name = cat.name .. "Panel"
        Panel.Size = UDim2.new(0, 200, 0, 400)
        Panel.Position = UDim2.new(
            Sidebar.Position.X.Scale,
            Sidebar.Position.X.Offset + PanelXOffset * i,
            Sidebar.Position.Y.Scale,
            Sidebar.Position.Y.Offset
        )
        Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        Panel.BackgroundTransparency = 0.2
        Panel.BorderSizePixel = 0
        Panel.Parent = ScreenGui
        Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 6)

        local Header = Instance.new("TextLabel")
        Header.Name = "Header"
        Header.Size = UDim2.new(1, 0, 0, 30)
        Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Header.Text = cat.name
        Header.Font = Enum.Font.Arcade
        Header.TextSize = 18
        Header.TextColor3 = Color3.fromRGB(255, 255, 255)
        Header.BorderSizePixel = 0
        Header.Parent = Panel

        local Content = Instance.new("ScrollingFrame", Panel)
        Content.Size = UDim2.new(1, 0, 1, -30)
        Content.Position = UDim2.new(0, 0, 0, 30)
        Content.BackgroundTransparency = 1
        Content.ScrollBarThickness = 4

        local UIList = Instance.new("UIListLayout", Content)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, 4)

        task.spawn(function()
            while Panel.Parent do
                local MatrixChar = Instance.new("TextLabel")
                MatrixChar.Size = UDim2.new(0, 14, 0, 14)
                MatrixChar.Position = UDim2.new(math.random(), 0, 0, -20)
                MatrixChar.BackgroundTransparency = 1
                MatrixChar.Font = Enum.Font.Code
                MatrixChar.TextSize = 14
                MatrixChar.TextColor3 = Color3.fromRGB(0, 255, 0)
                MatrixChar.Text = string.char(math.random(33, 126))
                MatrixChar.Parent = Panel

                task.spawn(function()
                    for y = -20, 420, 10 do
                        if not MatrixChar.Parent then break end
                        MatrixChar.Position = UDim2.new(MatrixChar.Position.X.Scale, 0, 0, y)
                        task.wait(0.03)
                    end
                    MatrixChar:Destroy()
                end)

                task.wait(0.1)
            end
        end)

        local categoryData = oofer.Categories[cat.name]
        if categoryData then
            for _, mod in ipairs(categoryData.Modules) do
                local ModBtn = Instance.new("TextButton")
                ModBtn.Size = UDim2.new(1, -8, 0, 30)
                ModBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                ModBtn.Text = mod.Name
                ModBtn.Font = Enum.Font.Arcade
                ModBtn.TextSize = 16
                ModBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ModBtn.AutoButtonColor = false
                ModBtn.Parent = Content
                Instance.new("UICorner", ModBtn).CornerRadius = UDim.new(0, 6)

                ModBtn.MouseButton1Click:Connect(function()
                    mod.Enabled = not mod.Enabled
                    mod.Function(mod.Enabled)
                    ModBtn.TextColor3 = mod.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
                end)

                for _, slider in ipairs(mod.Sliders) do
                    local Box = Instance.new("TextBox")
                    Box.Size = UDim2.new(1, -10, 0, 30)
                    Box.Text = slider.Name .. ": " .. slider.Value
                    Box.TextColor3 = Color3.fromRGB(255,255,255)
                    Box.BackgroundColor3 = Color3.fromRGB(30,30,30)
                    Box.ClearTextOnFocus = false
                    Box.Font = Enum.Font.Arcade
                    Box.TextSize = 16
                    Box.Parent = Content
                    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

                    Box.FocusLost:Connect(function()
                        local val = tonumber(Box.Text:match("[%d%.]+"))
                        if val then
                            val = math.clamp(val, slider.Min, slider.Max)
                            slider.Value = val
                            slider.Function(val)
                            Box.Text = slider.Name .. ": " .. val .. " " .. slider.Suffix(val)
                        else
                            Box.Text = slider.Name .. ": " .. slider.Value
                        end
                    end)
                end

                for _, toggle in ipairs(mod.Toggles) do
                    local TBtn = Instance.new("TextButton")
                    TBtn.Size = UDim2.new(1, -8, 0, 30)
                    TBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    TBtn.Text = toggle.Name
                    TBtn.Font = Enum.Font.Arcade
                    TBtn.TextSize = 16
                    TBtn.TextColor3 = toggle.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
                    TBtn.AutoButtonColor = false
                    TBtn.Parent = Content
                    Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 6)

                    TBtn.MouseButton1Click:Connect(function()
                        toggle.Enabled = not toggle.Enabled
                        toggle.Function(toggle.Enabled)
                        TBtn.TextColor3 = toggle.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
                    end)
                end
            end
        end

        MakeDraggable(Panel, Header)
    end)
end

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.Text = ""
ToggleBtn.TextSize = 18
ToggleBtn.Font = Enum.Font.Arcade
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

task.spawn(function()
    local text = "OOF"
    while true do
        local display = ""
        for i = 1, #text do
            display = display .. string.char(math.random(33, 126))
        end
        ToggleBtn.Text = display
        task.wait(0.05)
        ToggleBtn.Text = text
        task.wait(0.1)
    end
end)

local Visible = true
ToggleBtn.MouseButton1Click:Connect(function()
    Visible = not Visible
    Sidebar.Visible = Visible
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Panel") then
            child.Visible = Visible
        end
    end
    Blur.Enabled = Visible
    Tint.Enabled = Visible
end)

-- GLOBAL run helper so modules.lua can call run(function() ... end)
function run(func)
    task.spawn(func)
end

-- Single-file GitHub loader (loads after GUI+run exist)
local rawUrl = "https://raw.githubusercontent.com/ooferowner/oofer/main/modules/modules.lua"

local ok, err = pcall(function()
    loadstring(game:HttpGet(rawUrl, true))()
end)

if not ok then
    warn("[Module Loader] Failed to load modules.lua:", err)
else
    print("[Module Loader] Loaded modules.lua")
end
