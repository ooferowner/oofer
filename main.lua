--// Main API
local mainapi = {
    Categories = {},
    Connections = {},
    _Panels = {},
    _PanelContent = {},
    gui = nil
}

-- Simple run() executor for hostile modules
local queuedModules = {}
function run(fn)
    table.insert(queuedModules, fn)
end
local function executeModules()
    for _, fn in ipairs(queuedModules) do
        local ok, err = pcall(fn)
        if not ok then
            warn("[oofer] Module error:", err)
        end
    end
end

-- Category + Module API
function mainapi:CreateCategory(name)
    local cat = {}
    cat.Name = name
    cat.Modules = {}

    function cat:CreateButton(data)
        local btn = {
            Name = data.Name,
            Tooltip = data.Tooltip or "",
            ExtraText = data.ExtraText or function() return "" end,
            Callback = data.Function or function() end,
            Toggles = {},
            Sliders = {}
        }
        function btn:CreateToggle(tdata)
            local toggle = {
                Name = tdata.Name,
                Enabled = tdata.Default or false,
                Tooltip = tdata.Tooltip or "",
                Callback = tdata.Function or function() end
            }
            table.insert(self.Toggles, toggle)
            return toggle
        end
        function btn:CreateSlider(sdata)
            local slider = {
                Name = sdata.Name,
                Value = sdata.Default or sdata.Min,
                Min = sdata.Min,
                Max = sdata.Max,
                Tooltip = sdata.Tooltip or "",
                Callback = sdata.Function or function() end
            }
            table.insert(self.Sliders, slider)
            return slider
        end
        table.insert(self.Modules, btn)
        return btn
    end

    self.Categories[name] = cat
    return cat
end

--// Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// Blur + Tint
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

--// ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
mainapi.gui = ScreenGui

--// Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 0, 400)
Sidebar.Position = UDim2.new(0, 20, 0.25, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = ScreenGui
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

--// Title
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
        for _ = 1, #text do
            display ..= string.char(math.random(33, 126))
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
        local r = math.clamp(math.floor(math.sin(t) * 127 + 128), 0, 255)
        local g = math.clamp(math.floor(math.sin(t + 2) * 127 + 128), 0, 255)
        local b = math.clamp(math.floor(math.sin(t + 4) * 127 + 128), 0, 255)
        Title.TextColor3 = Color3.fromRGB(r, g, b)
        for _, panel in pairs(ScreenGui:GetChildren()) do
            local header = panel:FindFirstChild("Header")
            if header then header.TextColor3 = Color3.fromRGB(r, g, b) end
        end
        task.wait(0.05)
    end
end)

--// Container
local container = Instance.new("Frame", Sidebar)
container.Size = UDim2.new(1, -8, 1, -40)
container.Position = UDim2.new(0, 4, 0, 35)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)

--// Categories
local Categories = {
    {name = "Combat",   id = "rbxassetid://3926305904", offset = Vector2.new(4, 4)},
    {name = "Blatant",  id = "rbxassetid://3926305904", offset = Vector2.new(76, 4)},
    {name = "Render",   id = "rbxassetid://3926305904", offset = Vector2.new(112, 4)},
    {name = "Utility",  id = "rbxassetid://3926305904", offset = Vector2.new(184, 4)},
    {name = "World",    id = "rbxassetid://3926305904", offset = Vector2.new(220, 4)},
    {name = "Friends",  id = "rbxassetid://3926307971", offset = Vector2.new(184, 4)},
    {name = "Profiles", id = "rbxassetid://3926307971", offset = Vector2.new(292, 4)},
    {name = "Targets",  id = "rbxassetid://3926307971", offset = Vector2.new(148, 4)},
}

--// Panel Creation
local function ensurePanel(catName, iIndex)
    local name = catName .. "Panel"
    if mainapi._Panels[name] then return mainapi._Panels[name], mainapi._PanelContent[name] end

    local Panel = Instance.new("Frame")
    Panel.Name = name
    Panel.Size = UDim2.new(0, 200, 0, 400)
    Panel.Position = UDim2.new(0, Sidebar.Position.X.Offset + (230 * (iIndex or 1)), Sidebar.Position.Y.Scale, Sidebar.Position.Y.Offset)
    Panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Panel.BackgroundTransparency = 0.2
    Panel.BorderSizePixel = 0
    Panel.Parent = ScreenGui
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 6)

    local Header = Instance.new("TextLabel")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Header.Text = catName
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

    mainapi._Panels[name] = Panel
    mainapi._PanelContent[name] = Content
    return Panel, Content
end

--// Sidebar Buttons
for idx, cat in ipairs(Categories) do
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
        ensurePanel(cat.name, idx)
    end)

    -- Register category in API
    mainapi:CreateCategory(cat.name)
end

--// Toggle GUI Button
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
        for _ = 1, #text do
            display ..= string.char(math.random(33, 126))
        end
        ToggleBtn.Text = display
        task.wait(0.05)
        ToggleBtn.Text = text
        task.wait(0.1)
    end
end)

local Visible = true
local function setVisible(state)
    Visible = state
    Sidebar.Visible = state
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Panel") then
            child.Visible = state
        end
    end
    Blur.Enabled = state
    Tint.Enabled = state
end

ToggleBtn.MouseButton1Click:Connect(function()
    setVisible(not Visible)
end)

--// Execute hostile modules
executeModules()

return mainapi
