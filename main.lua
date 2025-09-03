-- oofer_gui.lua — Single-file modular GUI (legit), draggable panels, session save, attached-style visuals

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Config (session; if a RemoteEvent "GuiConfig:Save" exists, it will be used to persist via server)
local Config = {
    UI = { Visible = true, Panels = {} },
    Modules = {}
}

-- Local config file (client-side persistence)
local CONFIG_FILE = "oofer_config.json"

-- optional: load initial config if server provides a StringValue at ReplicatedStorage.GuiConfigValue
do
    local val = ReplicatedStorage:FindFirstChild("GuiConfigValue")
    if val and val:IsA("StringValue") then
        local ok, data = pcall(function() return HttpService:JSONDecode(val.Value) end)
        if ok and typeof(data) == "table" then Config = data end
    end
end

-- Load local config if available (overrides server-provided defaults for client session)
do
    if readfile then
        local okRead, content = pcall(readfile, CONFIG_FILE)
        if okRead and type(content) == "string" and #content > 0 then
            local okJson, data = pcall(function() return HttpService:JSONDecode(content) end)
            if okJson and typeof(data) == "table" then
                Config = data
            end
        end
    end
end

local function Save()
    -- JSON encode current Config
    local ok, json = pcall(function() return HttpService:JSONEncode(Config) end)
    if not ok then return end

    -- Local save (client-side persistence)
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, json)
        end)
    end

    -- Optional server sync via RemoteEvent
    local saveRemote = ReplicatedStorage:FindFirstChild("GuiConfig:Save")
    if saveRemote and saveRemote:IsA("RemoteEvent") then
        saveRemote:FireServer(json)
    end
end

-- Visuals: Blur + Tint (local-only)
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
ScreenGui.IgnoreGuiInset = false
ScreenGui.Name = "OOFER_GUI"
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

-- Title (glitch text + rainbow pulse)
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
    while Title.Parent do
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
    while Title.Parent do
        local t = tick() * 0.5
        local r = math.clamp(math.floor(math.sin(t) * 127 + 128), 0, 255)
        local g = math.clamp(math.floor(math.sin(t + 2) * 127 + 128), 0, 255)
        local b = math.clamp(math.floor(math.sin(t + 4) * 127 + 128), 0, 255)
        Title.TextColor3 = Color3.fromRGB(r, g, b)
        for _, panel in pairs(ScreenGui:GetChildren()) do
            local header = panel:FindFirstChild("Header")
            if header then header.TextColor3 = Title.TextColor3 end
        end
        task.wait(0.05)
    end
end)

-- Sidebar container
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -8, 1, -40)
container.Position = UDim2.new(0, 4, 0, 35)
container.BackgroundTransparency = 1
container.Parent = Sidebar

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = container

-- Categories (visual parity with your attached)
local CategoryList = {
    {name = "Combat",   id = "rbxassetid://3926305904", offset = Vector2.new(4, 4)},
    {name = "Blatant",  id = "rbxassetid://3926305904", offset = Vector2.new(76, 4)},
    {name = "Render",   id = "rbxassetid://3926305904", offset = Vector2.new(112, 4)},
    {name = "Utility",  id = "rbxassetid://3926305904", offset = Vector2.new(184, 4)},
    {name = "World",    id = "rbxassetid://3926305904", offset = Vector2.new(220, 4)},
    {name = "Friends",  id = "rbxassetid://3926307971", offset = Vector2.new(184, 4)},
    {name = "Profiles", id = "rbxassetid://3926307971", offset = Vector2.new(292, 4)},
    {name = "Targets",  id = "rbxassetid://3926307971", offset = Vector2.new(148, 4)},
}

-- Draggable helper (fixed; no drift; saves offsets)
local function makeDraggable(header, frame, saveKey)
    local dragging = false
    local dragStart
    local startPos

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        Config.UI.Panels[saveKey] = {
                            X = frame.Position.X.Offset,
                            Y = frame.Position.Y.Offset
                        }
                        Save()
                    end
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                0, startPos.X.Offset + delta.X,
                0, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- API
local oofer = { Categories = {}, _Panels = {}, _PanelContent = {}, _Rendered = {}, _Rows = {} }
_G.oofer = oofer
oofer.gui = ScreenGui

local function ModCfg(name)
    Config.Modules[name] = Config.Modules[name] or { Enabled = false, Toggles = {}, Sliders = {} }
    Config.Modules[name].Toggles = Config.Modules[name].Toggles or {}
    Config.Modules[name].Sliders = Config.Modules[name].Sliders or {}
    return Config.Modules[name]
end

-- UI builders
local function addSliderUI(content, mod, slider)
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

    Box.FocusLost:Connect(function()
        local num = tonumber(Box.Text:match("[%d%.]+"))
        if not num then
            Box.Text = ("%s: %s %s"):format(slider.Name, slider.Value, slider.Suffix(slider.Value))
            return
        end
        local clamped = math.clamp(num, slider.Min, slider.Max)
        slider.Value = clamped
        ModCfg(mod.Name).Sliders[slider.Name] = clamped
        Save()
        local ok, err = pcall(slider.Function, clamped)
        if not ok then warn("[oofer] Slider error:", slider.Name, err) end
        Box.Text = ("%s: %s %s"):format(slider.Name, clamped, slider.Suffix(clamped))
    end)
end

local function addToggleUI(content, mod, toggle)
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

    TBtn.MouseButton1Click:Connect(function()
        toggle.Enabled = not toggle.Enabled
        ModCfg(mod.Name).Toggles[toggle.Name] = toggle.Enabled
        Save()
        local ok, err = pcall(toggle.Function, toggle.Enabled)
        if not ok then warn("[oofer] Toggle error:", toggle.Name, err) end
        TBtn.TextColor3 = toggle.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
    end)
end

local function renderModuleRow(content, mod)
    if oofer._Rendered[mod] then return end

    local ModBtn = Instance.new("TextButton")
    ModBtn.Size = UDim2.new(1, -8, 0, 30)
    ModBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ModBtn.Text = mod.Name
    ModBtn.Font = Enum.Font.Arcade
    ModBtn.TextSize = 16
    ModBtn.TextColor3 = mod.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
    ModBtn.AutoButtonColor = false
    ModBtn.Parent = content
    Instance.new("UICorner", ModBtn).CornerRadius = UDim.new(0, 6)

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
        ModCfg(mod.Name).Enabled = mod.Enabled
        Save()
        local ok, err = pcall(mod.Function, mod.Enabled)
        if not ok then warn("[oofer] Module error:", mod.Name, err) end
        ModBtn.TextColor3 = mod.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
    end)

    for _, slider in ipairs(mod.Sliders) do addSliderUI(content, mod, slider) end
    for _, toggle in ipairs(mod.Toggles) do addToggleUI(content, mod, toggle) end

    oofer._Rows[mod] = ModBtn
    oofer._Rendered[mod] = true
end

local function ensurePanel(catName, iIndex)
    local name = catName .. "Panel"
    if oofer._Panels[name] then return oofer._Panels[name], oofer._PanelContent[name] end

    local Panel = Instance.new("Frame")
    Panel.Name = name
    Panel.Size = UDim2.new(0, 200, 0, 400)

    -- Default next to sidebar; load saved position if any
    local saved = Config.UI.Panels[name]
    if saved and typeof(saved) == "table" and typeof(saved.X) == "number" and typeof(saved.Y) == "number" then
        Panel.Position = UDim2.new(0, saved.X, 0, saved.Y)
    else
        local defaultX = Sidebar.AbsolutePosition.X + 230 * ((iIndex or 1) - 1)
        local defaultY = Sidebar.AbsolutePosition.Y
        Panel.Position = UDim2.new(0, defaultX, 0, defaultY)
    end

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

    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    Content.Parent = Panel

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 4)
    UIList.Parent = Content

    makeDraggable(Header, Panel, name)

    oofer._Panels[name] = Panel
    oofer._PanelContent[name] = Content
    return Panel, Content
end

-- Register categories and sidebar buttons
for idx, cat in ipairs(CategoryList) do
    local catName = cat.name
    oofer.Categories[catName] = oofer.Categories[catName] or { Modules = {} }

    local function createModule(self, data)
        local cfg = ModCfg(data.Name)
        local mod = {
            Name = data.Name,
            Tooltip = data.Tooltip or "",
            ExtraText = data.ExtraText or function() return "" end,
            Enabled = cfg.Enabled or false,
            Function = data.Function or function() end,
            Sliders = {},
            Toggles = {},
            SetEnabled = function(m, state)
                if m.Enabled == state then return end
                m.Enabled = state
                ModCfg(m.Name).Enabled = state
                Save()
                local ok, err = pcall(m.Function, state)
                if not ok then warn("[oofer] Module error:", m.Name, err) end
                if m._node then
                    m._node.TextColor3 = state and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
                end
            end
        }

        function mod:CreateSlider(opts)
            local mcfg = ModCfg(self.Name)
            local slider = {
                Name = opts.Name,
                Min = opts.Min or 0,
                Max = opts.Max or 100,
                Value = (mcfg.Sliders and mcfg.Sliders[opts.Name]) or opts.Default or 0,
                Suffix = opts.Suffix or function(v) return tostring(v) end,
                Function = opts.Function or function() end,
                Tooltip = opts.Tooltip or "",
            }
            table.insert(self.Sliders, slider)
            local content = oofer._PanelContent[catName .. "Panel"]
            if content and oofer._Rendered[self] then addSliderUI(content, self, slider) end
            return slider
        end

        function mod:CreateToggle(opts)
            local mcfg = ModCfg(self.Name)
            local toggle = {
                Name = opts.Name,
                Enabled = (mcfg.Toggles and mcfg.Toggles[opts.Name]) or opts.Default or false,
                Function = opts.Function or function() end,
                Tooltip = opts.Tooltip or "",
            }
            table.insert(self.Toggles, toggle)
            local content = oofer._PanelContent[catName .. "Panel"]
            if content and oofer._Rendered[self] then addToggleUI(content, self, toggle) end
            return toggle
        end

        table.insert(self.Modules, mod)

        if mod.Enabled then
            local ok, err = pcall(mod.Function, true)
            if not ok then warn("[oofer] Module init error:", mod.Name, err) end
        end

        local content = oofer._PanelContent[catName .. "Panel"]
        if content then renderModuleRow(content, mod) end

        return mod
    end

    oofer.Categories[catName].CreateModule = createModule
    oofer.Categories[catName].CreateButton = createModule

    -- Sidebar button
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -6, 0, 26)
    Btn.BackgroundTransparency = 1
    Btn.AutoButtonColor = false
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.Parent = container

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 18, 0, 18)
    Icon.Position = UDim2.new(0, 6, 0.5, -9)
    Icon.BackgroundTransparency = 1
    Icon.Image = cat.id
    Icon.ImageRectOffset = cat.offset
    Icon.ImageRectSize = Vector2.new(36, 36)
    Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    Icon.Parent = Btn

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = catName
    Label.Font = Enum.Font.Arcade
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Parent = Btn

    Btn.MouseEnter:Connect(function()
        Label.TextColor3 = Color3.fromRGB(0, 200, 255)
        Icon.ImageColor3 = Color3.fromRGB(0, 200, 255)
    end)
    Btn.MouseLeave:Connect(function()
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Icon.ImageColor3 = Color3.fromRGB(200, 200, 200)
    end)

    Btn.MouseButton1Click:Connect(function()
        local _, content = ensurePanel(catName, idx)
        content:ClearAllChildren()
        local UIL = Instance.new("UIListLayout")
        UIL.SortOrder = Enum.SortOrder.LayoutOrder
        UIL.Padding = UDim.new(0, 4)
        UIL.Parent = content
        for _, mod in ipairs(oofer.Categories[catName].Modules) do
            renderModuleRow(content, mod)
        end
    end)
end

-- Toggle GUI button (glitch text)
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
    while ToggleBtn.Parent do
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

local function setVisible(state)
    Config.UI.Visible = state
    Save()
    Sidebar.Visible = state
    for _, child in pairs(ScreenGui:GetChildren()) do
        if child:IsA("Frame") and child.Name:find("Panel") then
            child.Visible = state
        end
    end
    Blur.Enabled = state
    Tint.Enabled = state
end

setVisible(Config.UI.Visible ~= false)
ToggleBtn.MouseButton1Click:Connect(function()
    setVisible(not Sidebar.Visible)
end)

-- run helper
local function run(fn) task.spawn(fn) end

-- alias for vape parity
vape = oofer
_G.vape = vape

-- requested test logic
run(function()
    local ThisIsATest
    local ThisIsATestSlider
    local ThisIsATestMiniToggle
    ThisIsATest = vape.Categories.World:CreateButton({
        Name = 'Testing',
        Function = function(callback)
            if callback then
                print(callback)
                print(ThisIsATestSlider.Value)
                print(ThisIsATestMiniToggle.Enabled)
            end
        end,
        Tooltip = 'This is a test -- ignore ts module gng',
        ExtraText = function()
            return 'Test #1'
        end
    })
    ThisIsATestSlider = ThisIsATest:CreateSlider({
        Name = 'Value',
        Min = 1,
        Max = 99,
        Default = 50,
        Suffix = function(val)
            return val == 1 and 'stud' or 'studs'
        end,
        Function = function(val)
            print(val)
        end,
        Tooltip = 'Testing!!'
    })
    ThisIsATestMiniToggle = ThisIsATest:CreateToggle({
        Name = 'Toggle',
        Function = function(val)
            print(val)
        end,
        Tooltip = 'Bla bla'
    })
end)
run(function()
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local lightPart, light
    local followPlayer = true

    local mod = oofer.Categories.World:CreateButton({
        Name = 'Personal Light',
        Function = function(enabled)
            if enabled then
                if not lightPart then
                    lightPart = Instance.new("Part")
                    lightPart.Anchored = true
                    lightPart.CanCollide = false
                    lightPart.Transparency = 1
                    lightPart.Size = Vector3.new(1,1,1)
                    lightPart.Parent = workspace

                    light = Instance.new("PointLight")
                    light.Range = 20
                    light.Brightness = 5
                    light.Color = Color3.fromRGB(255, 255, 200)
                    light.Parent = lightPart
                end
                light.Enabled = true
                task.spawn(function()
                    while mod.Enabled and lightPart do
                        if followPlayer and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            lightPart.Position = lp.Character.HumanoidRootPart.Position
                        end
                        task.wait(0.05)
                    end
                end)
            else
                if light then light.Enabled = false end
            end
        end,
        Tooltip = 'Creates a movable light source around you',
        ExtraText = function()
            return light and string.format("B:%.1f", light.Brightness) or ""
        end
    })

    -- Collapsible settings group
    makeCollapsible(mod, function(parent)
        local brightness = mod:CreateSlider({
            Name = 'Brightness',
            Min = 1,
            Max = 10,
            Default = 5,
            Suffix = function() return "" end,
            Function = function(val)
                if light then light.Brightness = val end
            end,
            Tooltip = 'Adjust light brightness'
        })
        brightness._node.Parent = parent

        local follow = mod:CreateToggle({
            Name = 'Follow Player',
            Default = true,
            Function = function(val) followPlayer = val end,
            Tooltip = 'If off, light stays where it was last placed'
        })
        follow._node.Parent = parent
    end)
end)
run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local lp = Players.LocalPlayer

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "HostileFPS"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = lp:WaitForChild("PlayerGui")

    -- FPS Label
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 140, 0, 40)
    fpsLabel.Position = UDim2.new(0, 0, 0.5, -20) -- left center
    fpsLabel.AnchorPoint = Vector2.new(0, 0.5)
    fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- black background
    fpsLabel.BackgroundTransparency = 0.3 -- slightly see‑through
    fpsLabel.Font = Enum.Font.Arcade
    fpsLabel.TextSize = 28
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- green text
    fpsLabel.TextStrokeTransparency = 0.2
    fpsLabel.Text = "FPS: 0"
    fpsLabel.Parent = gui

    -- FPS calculation
    local frames, fps, lastTime = 0, 0, tick()
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - lastTime >= 1 then
            fps = frames
            frames = 0
            lastTime = now
            fpsLabel.Text = "FPS: " .. fps
        end
    end)
end)
run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")

    local lp = Players.LocalPlayer
    local cam = Workspace.CurrentCamera

    -- Blur layer
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Enabled = false
    blur.Parent = Lighting

    -- Optional DOF for extra realism
    local dof = Instance.new("DepthOfFieldEffect")
    dof.Enabled = false
    dof.FocusDistance = 0
    dof.InFocusRadius = 10
    dof.FarIntensity = 0.5
    dof.Parent = Lighting

    local BGBlur = oofer.Categories.Render:CreateButton({
        Name = "Background Blur",
        Function = function(state)
            blur.Enabled = state
            dof.Enabled = state
            if state then
                task.spawn(function()
                    while BGBlur.Enabled do
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Distance from camera to character
                            local dist = (cam.CFrame.Position - hrp.Position).Magnitude
                            -- Blur more when camera is farther away
                            blur.Size = math.clamp((dist - 5) * 0.8, 0, 56)
                            -- Keep DOF focus locked on character
                            dof.FocusDistance = dist
                        end
                        task.wait(0.05)
                    end
                end)
            end
        end,
        Tooltip = "Keeps your character in focus, blurs background dynamically"
    })
end)

----------------------------------------------------------------
-- Auto-open first category panel on start
----------------------------------------------------------------
local firstCat = CategoryList[1] and CategoryList[1].name
if firstCat then
    local _, content = ensurePanel(firstCat, 1)
    content:ClearAllChildren()
    local UIL = Instance.new("UIListLayout")
    UIL.SortOrder = Enum.SortOrder.LayoutOrder
    UIL.Padding = UDim.new(0, 4)
    UIL.Parent = content
    for _, mod in ipairs(oofer.Categories[firstCat].Modules) do
        renderModuleRow(content, mod)
    end
end

print("[OOFER GUI] Loaded with", #CategoryList, "categories and", 
    (function()
        local count = 0
        for _, cat in pairs(oofer.Categories) do
            count += #cat.Modules
        end
        return count
    end)(), "modules.")
