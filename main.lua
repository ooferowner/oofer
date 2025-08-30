--// Main API
local mainapi = {
    Categories = {},
    Connections = {},
    _Panels = {},
    _PanelContent = {},
    _Keybinds = {},
    _ListeningForBind = nil,
    gui = nil,
    Accent = Color3.fromRGB(0, 200, 255),
    ColorCycleEnabled = true
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

-- Accent setter
function mainapi:SetAccent(color)
    self.Accent = color
    for _, inst in ipairs(self.gui:GetDescendants()) do
        if inst:IsA("TextLabel") or inst:IsA("TextButton") then
            if inst:GetAttribute("AccentText") then
                inst.TextColor3 = color
            end
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            if inst:GetAttribute("AccentImage") then
                inst.ImageColor3 = color
            end
        elseif inst:IsA("Frame") then
            if inst:GetAttribute("AccentBg") then
                inst.BackgroundColor3 = color
            end
        end
    end
end

-- Keybind engine
function mainapi:_BindKey(keyCode, binderId, callback)
    self._Keybinds[keyCode] = self._Keybinds[keyCode] or {}
    self._Keybinds[keyCode][binderId] = callback
end
function mainapi:_UnbindKey(keyCode, binderId)
    if self._Keybinds[keyCode] then
        self._Keybinds[keyCode][binderId] = nil
        if next(self._Keybinds[keyCode]) == nil then
            self._Keybinds[keyCode] = nil
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
            Sliders = {},
            KeyCode = data.Keybind or nil,
            _BinderId = ("B_%s_%s"):format(self.Name, data.Name)
        }

        function btn:SetKeybind(keyCode)
            if self.KeyCode then
                mainapi:_UnbindKey(self.KeyCode, self._BinderId)
            end
            self.KeyCode = keyCode
            if keyCode then
                mainapi:_BindKey(keyCode, self._BinderId, function()
                    self:Toggle()
                end)
            end
            if self._KeyLabel then
                self._KeyLabel.Text = keyCode and keyCode.Name or "None"
            end
        end

        function btn:Toggle()
            -- Primary action for the button (treat as toggle press)
            local ok, err = pcall(self.Callback, true)
            if not ok then warn("[oofer] Button error:", err) end
        end

        function btn:CreateToggle(tdata)
            local toggle = {
                Name = tdata.Name,
                Enabled = tdata.Default or false,
                Tooltip = tdata.Tooltip or "",
                Callback = tdata.Function or function() end,
                KeyCode = tdata.Keybind or nil,
                _BinderId = ("T_%s_%s_%s"):format(cat.Name, btn.Name, tdata.Name)
            }
            function toggle:SetKeybind(keyCode)
                if self.KeyCode then
                    mainapi:_UnbindKey(self.KeyCode, self._BinderId)
                end
                self.KeyCode = keyCode
                if keyCode then
                    mainapi:_BindKey(keyCode, self._BinderId, function()
                        self:Set(not self.Enabled, true)
                    end)
                end
                if self._KeyLabel then
                    self._KeyLabel.Text = keyCode and keyCode.Name or "None"
                end
            end
            function toggle:Set(state, fromKey)
                self.Enabled = state
                if self._Switch then
                    self._Switch.BackgroundColor3 = state and Color3.fromRGB(30, 180, 90) or Color3.fromRGB(70, 70, 70)
                end
                local ok, err = pcall(self.Callback, state, fromKey == true)
                if not ok then warn("[oofer] Toggle error:", err) end
            end
            table.insert(btn.Toggles, toggle)
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
            function slider:Set(val)
                val = math.clamp(val, self.Min, self.Max)
                self.Value = val
                if self._Fill then
                    local pct = (val - self.Min) / (self.Max - self.Min)
                    self._Fill.Size = UDim2.new(pct, 0, 1, 0)
                end
                local ok, err = pcall(self.Callback, val)
                if not ok then warn("[oofer] Slider error:", err) end
            end
            table.insert(btn.Sliders, slider)
            return slider
        end

        -- Register button
        table.insert(self.Modules, btn)

        -- UI build (deferred until panels exist)
        task.defer(function()
            local ensure = mainapi._EnsurePanel
            if not ensure then return end
            local _, Content = ensure(cat.Name)

            local Row = Instance.new("Frame")
            Row.Name = btn.Name
            Row.Size = UDim2.new(1, -8, 0, 64)
            Row.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Row.BorderSizePixel = 0
            Row.Parent = Content
            Row:SetAttribute("AccentBg", true)
            Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

            local Header = Instance.new("TextLabel")
            Header.Name = "Header"
            Header.Size = UDim2.new(1, -90, 0, 24)
            Header.Position = UDim2.new(0, 8, 0, 6)
            Header.BackgroundTransparency = 1
            Header.Font = Enum.Font.Arcade
            Header.TextSize = 16
            Header.TextXAlignment = Enum.TextXAlignment.Left
            Header.Text = btn.Name
            Header.TextColor3 = Color3.fromRGB(255, 255, 255)
            Header.Parent = Row
            Header:SetAttribute("AccentText", true)

            local Extra = Instance.new("TextLabel")
            Extra.Size = UDim2.new(0, 60, 0, 20)
            Extra.Position = UDim2.new(1, -168, 0, 8)
            Extra.BackgroundTransparency = 1
            Extra.Font = Enum.Font.Arcade
            Extra.TextSize = 14
            Extra.TextXAlignment = Enum.TextXAlignment.Right
            Extra.Text = tostring(btn.ExtraText())
            Extra.TextColor3 = Color3.fromRGB(180, 180, 180)
            Extra.Parent = Row

            local KeyBtn = Instance.new("TextButton")
            KeyBtn.Size = UDim2.new(0, 68, 0, 20)
            KeyBtn.Position = UDim2.new(1, -92, 0, 8)
            KeyBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            KeyBtn.BorderSizePixel = 0
            KeyBtn.Font = Enum.Font.Arcade
            KeyBtn.TextSize = 14
            KeyBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
            KeyBtn.Text = "Bind"
            KeyBtn.Parent = Row
            Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Size = UDim2.new(0, 68, 0, 20)
            KeyLabel.Position = UDim2.new(1, -20 - 68, 0, 8)
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Font = Enum.Font.Arcade
            KeyLabel.TextSize = 14
            KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
            KeyLabel.Text = "None"
            KeyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
            KeyLabel.Parent = Row
            btn._KeyLabel = KeyLabel

            local Area = Instance.new("Frame")
            Area.Size = UDim2.new(1, -16, 0, 28)
            Area.Position = UDim2.new(0, 8, 0, 30)
            Area.BackgroundTransparency = 1
            Area.Parent = Row
            local UIL = Instance.new("UIListLayout", Area)
            UIL.FillDirection = Enum.FillDirection.Horizontal
            UIL.Padding = UDim.new(0, 6)
            UIL.SortOrder = Enum.SortOrder.LayoutOrder

            -- Build toggles
            for _, t in ipairs(btn.Toggles) do
                local TWrap = Instance.new("Frame")
                TWrap.Size = UDim2.new(0, 130, 1, 0)
                TWrap.BackgroundTransparency = 1
                TWrap.Parent = Area

                local Switch = Instance.new("TextButton")
                Switch.Size = UDim2.new(0, 24, 1, 0)
                Switch.BackgroundColor3 = t.Enabled and Color3.fromRGB(30, 180, 90) or Color3.fromRGB(70, 70, 70)
                Switch.Text = ""
                Switch.BorderSizePixel = 0
                Switch.Parent = TWrap
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 4)

                local TLabel = Instance.new("TextLabel")
                TLabel.Size = UDim2.new(1, -30, 1, 0)
                TLabel.Position = UDim2.new(0, 30, 0, 0)
                TLabel.BackgroundTransparency = 1
                TLabel.Font = Enum.Font.Arcade
                TLabel.TextSize = 14
                TLabel.TextXAlignment = Enum.TextXAlignment.Left
                TLabel.Text = t.Name
                TLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                TLabel.Parent = TWrap

                t._Switch = Switch

                Switch.MouseButton1Click:Connect(function()
                    t:Set(not t.Enabled)
                end)

                -- Toggle keybind small button
                local TKey = Instance.new("TextButton")
                TKey.Size = UDim2.new(0, 40, 1, 0)
                TKey.Position = UDim2.new(1, -42, 0, 0)
                TKey.AnchorPoint = Vector2.new(0, 0)
                TKey.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                TKey.BorderSizePixel = 0
                TKey.Font = Enum.Font.Arcade
                TKey.TextSize = 12
                TKey.TextColor3 = Color3.fromRGB(200, 200, 200)
                TKey.Text = "Key"
                TKey.Parent = TWrap
                Instance.new("UICorner", TKey).CornerRadius = UDim.new(0, 4)

                local TKeyLabel = Instance.new("TextLabel")
                TKeyLabel.Size = UDim2.new(0, 40, 1, 0)
                TKeyLabel.Position = UDim2.new(1, 2, 0, 0)
                TKeyLabel.BackgroundTransparency = 1
                TKeyLabel.Font = Enum.Font.Arcade
                TKeyLabel.TextSize = 12
                TKeyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                TKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
                TKeyLabel.Text = t.KeyCode and t.KeyCode.Name or "None"
                TKeyLabel.Parent = TWrap
                t._KeyLabel = TKeyLabel

                TKey.MouseButton1Click:Connect(function()
                    mainapi._ListeningForBind = { target = t }
                    TKey.Text = "..."
                end)

                if t.KeyCode then
                    t:SetKeybind(t.KeyCode)
                end
            end

            -- Build sliders
            for _, s in ipairs(btn.Sliders) do
                local SWrap = Instance.new("Frame")
                SWrap.Size = UDim2.new(0, 200, 1, 0)
                SWrap.BackgroundTransparency = 1
                SWrap.Parent = Area

                local SLabel = Instance.new("TextLabel")
                SLabel.Size = UDim2.new(0, 80, 1, 0)
                SLabel.BackgroundTransparency = 1
                SLabel.Font = Enum.Font.Arcade
                SLabel.TextSize = 14
                SLabel.TextXAlignment = Enum.TextXAlignment.Left
                SLabel.Text = s.Name
                SLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                SLabel.Parent = SWrap

                local Bar = Instance.new("Frame")
                Bar.Size = UDim2.new(0, 110, 0, 18)
                Bar.Position = UDim2.new(0, 84, 0.5, -9)
                Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Bar.BorderSizePixel = 0
                Bar.Parent = SWrap
                Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((s.Value - s.Min) / (s.Max - s.Min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Fill.BorderSizePixel = 0
                Fill.Parent = Bar
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)

                s._Fill = Fill

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local connMove, connEnd
                        local function update(x)
                            local rel = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                            local val = math.floor(s.Min + rel * (s.Max - s.Min) + 0.5)
                            s:Set(val)
                        end
                        update(game:GetService("UserInputService"):GetMouseLocation().X)
                        connMove = game:GetService("UserInputService").InputChanged:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseMovement then
                                update(i.Position.X)
                            end
                        end)
                        connEnd = game:GetService("UserInputService").InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                                if connMove then connMove:Disconnect() end
                                if connEnd then connEnd:Disconnect() end
                            end
                        end)
                    end
                end)
            end

            -- Key capture for button-level bind
            KeyBtn.MouseButton1Click:Connect(function()
                mainapi._ListeningForBind = { target = btn }
                KeyBtn.Text = "..."
            end)

            if btn.KeyCode then
                btn:SetKeybind(btn.KeyCode)
            end

            mainapi:SetAccent(mainapi.Accent)
        end)

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
Title:SetAttribute("AccentText", true)

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
        if mainapi.ColorCycleEnabled then
            local t = tick() * 0.5
            local r = math.clamp(math.floor(math.sin(t) * 127 + 128), 0, 255)
            local g = math.clamp(math.floor(math.sin(t + 2) * 127 + 128), 0, 255)
            local b = math.clamp(math.floor(math.sin(t + 4) * 127 + 128), 0, 255)
            local color = Color3.fromRGB(r, g, b)
            Title.TextColor3 = color
            for _, panel in pairs(ScreenGui:GetChildren()) do
                local header = panel:FindFirstChild("Header")
                if header then header.TextColor3 = color end
            end
            mainapi.Accent = color
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
    Header.TextColor3 = mainapi.Accent
    Header.BorderSizePixel = 0
    Header.Parent = Panel
    Header:SetAttribute("AccentText", true)

    local Content = Instance.new("ScrollingFrame", Panel)
    Content.Size = UDim2.new(1, 0, 1, -30)
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 4
    local UIList = Instance.new("UIListLayout", Content)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)

    mainapi._Panels[name] = Panel
    mainapi._PanelContent[name] = Content
    return Panel, Content
end
mainapi._EnsurePanel = ensurePanel

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
    Icon:SetAttribute("AccentImage", true)

    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -28, 1, 0)
    Label.Position = UDim2.new(0, 28, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = cat.name
    Label.Font = Enum.Font.Arcade
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label:SetAttribute("AccentText", true)

    Btn.MouseEnter:Connect(function()
        Label.TextColor3 = mainapi.Accent
        Icon.ImageColor3 = mainapi.Accent
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

--// Keybind listener
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if mainapi._ListeningForBind then
        local target = mainapi._ListeningForBind.target
        if input.UserInputType == Enum.UserInputType.Keyboard then
            target:SetKeybind(input.KeyCode)
            mainapi._ListeningForBind = nil
        end
        return
    end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local binds = mainapi._Keybinds[input.KeyCode]
        if binds then
            for _, cb in pairs(binds) do
                cb()
            end
        end
    end
end)

--// Load hostile modules
local success, err = pcall(function()
    loadstring(readfile("modules.lua"))()
end)
if not success then
    warn("[oofer] Failed to load modules.lua:", err)
end

--// Execute hostile modules
executeModules()

return mainapi
