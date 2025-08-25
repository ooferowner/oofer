local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

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
    {name = "Combat",   id = "rbxassetid://3926305904", offset = Vector2.new(4, 4)},
    {name = "Blatant",  id = "rbxassetid://3926305904", offset = Vector2.new(76, 4)},
    {name = "Render",   id = "rbxassetid://3926305904", offset = Vector2.new(112, 4)},
    {name = "Utility",  id = "rbxassetid://3926305904", offset = Vector2.new(184, 4)},
    {name = "World",    id = "rbxassetid://3926305904", offset = Vector2.new(220, 4)},
    {name = "Friends",  id = "rbxassetid://3926307971", offset = Vector2.new(184, 4)},
    {name = "Profiles", id = "rbxassetid://3926307971", offset = Vector2.new(292, 4)},
    {name = "Targets",  id = "rbxassetid://3926307971", offset = Vector2.new(148, 4)},
}

-- API
oofer = { Categories = {}, Connections = {}, _Panels = {}, _PanelContent = {} }
shared.oofer = oofer
vape = oofer -- alias for compatibility
oofer.gui = ScreenGui

function oofer:Clean(connOrFunc)
    if connOrFunc == nil then return end
    table.insert(self.Connections, connOrFunc)
end

function oofer:CreateNotification(title, text, duration, kind)
    print(("[oofer][%s][%s] %s"):format(kind or "info", tostring(title), tostring(text)))
end

-- Friends / Targets scaffolding for core
oofer.Categories.Friends = oofer.Categories.Friends or { Modules = {}, Options = {}, ListEnabled = {} }
oofer.Categories.Friends.Options["Use friends"] = oofer.Categories.Friends.Options["Use friends"] or { Enabled = false }
oofer.Categories.Friends.Options["Recolor visuals"] = oofer.Categories.Friends.Options["Recolor visuals"] or { Enabled = false }
oofer.Categories.Targets = oofer.Categories.Targets or { Modules = {}, Options = {}, ListEnabled = {} }

-- Internal: attach visible proxy to a node
local function attachVisibilityProxy(node)
    local proxy = { Visible = true }
    return setmetatable(proxy, {
        __newindex = function(t, k, v)
            rawset(t, k, v)
            if k == "Visible" and node then node.Visible = v end
        end
    })
end

-- Internal: create a module row in a panel
local function renderModuleRow(content, mod)
    -- Module button
    local ModBtn = Instance.new("TextButton")
    ModBtn.Size = UDim2.new(1, -8, 0, 30)
    ModBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ModBtn.Text = mod.Name
    ModBtn.Font = Enum.Font.Arcade
    ModBtn.TextSize = 16
    ModBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModBtn.AutoButtonColor = false
    ModBtn.Parent = content
    Instance.new("UICorner", ModBtn).CornerRadius = UDim.new(0, 6)

    -- ExtraText label (right side)
    local Extra = Instance.new("TextLabel")
    Extra.BackgroundTransparency = 1
    Extra.AnchorPoint = Vector2.new(1, 0.5)
    Extra.Position = UDim2.new(1, -10, 0.5, 0)
    Extra.Size = UDim2.new(0, 120, 1, 0)
    Extra.TextXAlignment = Enum.TextXAlignment.Right
    Extra.Font = Enum.Font.Arcade
    Extra.TextSize = 14
    Extra.TextColor3 = Color3.fromRGB(170, 170, 170)
    Extra.Parent = ModBtn

    task.spawn(function()
        while ModBtn.Parent do
            local ok, txt = pcall(mod.ExtraText)
            Extra.Text = ok and tostring(txt) or ""
            task.wait(0.2)
        end
    end)

    ModBtn.MouseButton1Click:Connect(function()
        mod.Enabled = not mod.Enabled
        local ok, err = pcall(mod.Function, mod.Enabled)
        if not ok then warn("[oofer] Module error:", mod.Name, err) end
        ModBtn.TextColor3 = mod.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
    end)

    mod._node = ModBtn

    -- Render sliders
    for _, slider in ipairs(mod.Sliders) do
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -10, 0, 30)
        Box.Text = ("%s: %s %s"):format(slider.Name, slider.Value, slider.Suffix(slider.Value))
        Box.TextColor3 = Color3.fromRGB(255,255,255)
        Box.BackgroundColor3 = Color3.fromRGB(30,30,30)
        Box.ClearTextOnFocus = false
        Box.Font = Enum.Font.Arcade
        Box.TextSize = 16
        Box.Parent = content
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

        slider.Object = attachVisibilityProxy(Box)

        Box.FocusLost:Connect(function()
            local num = tonumber(Box.Text:match("[%d%.]+"))
            if not num then
                Box.Text = ("%s: %s %s"):format(slider.Name, slider.Value, slider.Suffix(slider.Value))
                return
            end
            local clamped = math.clamp(num, slider.Min, slider.Max)
            slider.Value = clamped
            local ok, err = pcall(slider.Function, clamped)
            if not ok then warn("[oofer] Slider error:", slider.Name, err) end
            Box.Text = ("%s: %s %s"):format(slider.Name, clamped, slider.Suffix(clamped))
        end)
    end

    -- Render mini toggles
    for _, toggle in ipairs(mod.Toggles) do
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, -8, 0, 30)
        TBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TBtn.Text = toggle.Name
        TBtn.Font = Enum.Font.Arcade
        TBtn.TextSize = 16
        TBtn.TextColor3 = toggle.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        TBtn.AutoButtonColor = false
        TBtn.Parent = content
        Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 6)

        toggle.Object = attachVisibilityProxy(TBtn)

        TBtn.MouseButton1Click:Connect(function()
            toggle.Enabled = not toggle.Enabled
            local ok, err = pcall(toggle.Function, toggle.Enabled)
            if not ok then warn("[oofer] Toggle error:", toggle.Name, err) end
            TBtn.TextColor3 = toggle.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
        end)
    end
end

-- Create panels on-demand and remember content containers
local function ensurePanel(catName, iIndex)
    local name = catName .. "Panel"
    if oofer._Panels[name] then return oofer._Panels[name], oofer._PanelContent[name] end

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

    -- Draggable via header
    local dragging, dragInput, dragStart, startPos
    local UIS = game:GetService("UserInputService")
    local function update(input)
        local delta = input.Position - dragStart
        Panel.Position = UDim2.new(Panel.Position.X.Scale, Panel.Position.X.Offset + delta.X, Panel.Position.Y.Scale, Panel.Position.Y.Offset + delta.Y)
    end
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Panel.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    -- Save references
    oofer._Panels[name] = Panel
    oofer._PanelContent[name] = Content

    return Panel, Content
end

-- Public category registration + CreateButton/CreateModule
for idx, cat in ipairs(Categories) do
    local catName = cat.name
    oofer.Categories[catName] = oofer.Categories[catName] or { Modules = {} }

    local function createModule(self, data)
        local mod = {
            Name = data.Name,
            Tooltip = data.Tooltip or "",
            ExtraText = data.ExtraText or function() return "" end,
            Enabled = false,
            Function = data.Function or function() end,
            Sliders = {},
            Toggles = {},
            SetEnabled = function(m, state)
                if m.Enabled == state then return end
                m.Enabled = state
                local ok, err = pcall(m.Function, state)
                if not ok then warn("[oofer] Module error:", m.Name, err) end
                if m._node then
                    m._node.TextColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
                end
            end
        }

        function mod:CreateSlider(opts)
            local slider = {
                Name = opts.Name,
                Min = opts.Min or 0,
                Max = opts.Max or 100,
                Value = opts.Default or 0,
                Suffix = opts.Suffix or function(v) return tostring(v) end,
                Function = opts.Function or function() end,
                Tooltip = opts.Tooltip or "",
                Object = nil
            }
            table.insert(self.Sliders, slider)
            -- If panel is already open, render immediately
            local content = oofer._PanelContent[catName .. "Panel"]
            if content then renderModuleRow(content, self) end
            return slider
        end

        function mod:CreateToggle(opts)
            local toggle = {
                Name = opts.Name,
                Enabled = opts.Default or false,
                Function = opts.Function or function() end,
                Tooltip = opts.Tooltip or "",
                Object = nil
            }
            table.insert(self.Toggles, toggle)
            local content = oofer._PanelContent[catName .. "Panel"]
            if content then renderModuleRow(content, self) end
            return toggle
        end

        table.insert(self.Modules, mod)

        -- If panel exists, append UI for this module now
        local content = oofer._PanelContent[catName .. "Panel"]
        if content then renderModuleRow(content, mod) end

        return mod
    end

    -- API names
    oofer.Categories[catName].CreateButton = createModule
    oofer.Categories[catName].CreateModule = createModule

    -- Sidebar button
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
    Label.Text = catName
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
        local panel, content = ensurePanel(catName, idx)
        -- Render any not-yet-rendered modules
        content:ClearAllChildren()
        local UIList = Instance.new("UIListLayout", content)
        UIList.SortOrder = Enum.SortOrder.LayoutOrder
        UIList.Padding = UDim.new(0, 4)
        for _, mod in ipairs(oofer.Categories[catName].Modules) do
            renderModuleRow(content, mod)
        end
    end)
end

-- Toggle key/button
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

ToggleBtn.MouseButton1Click:Connect(function() setVisible(not Visible) end)

-- GLOBAL run helper so modules.lua can call run(function() ... end)
function run(func) task.spawn(func) end

-- Single-file GitHub loader (loads after GUI+run exist)
local rawUrl = "https://raw.githubusercontent.com/ooferowner/oofer/main/modules/modules.lua"
local ok, err = pcall(function() loadstring(game:HttpGet(rawUrl, true))() end)
if not ok then
    warn("[Module Loader] Failed to load modules.lua:", err)
else
    print("[Module Loader] Loaded modules.lua")
end
