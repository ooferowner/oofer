-- OOFER: Hostile GUI (fixed pixel sizes, zero autoscale) + mobile touch + left-edge swipe + RightShift hotkey
-- Full-screen pulse (very dark purple), Matrix reveal, binary rain overlay, category toggles, blur control, config save/load.

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Assets / constants
local DECAL = "rbxassetid://86828470035784"
local FONT = Enum.Font.Arcade
local CONFIG_FILE = "oofer_config.json"

-- Config
local Config = { UI = { CurrentCategory = nil }, Modules = {} }

local function Load()
	if readfile then
		local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
		if ok and data and #data > 0 then
			local ok2, parsed = pcall(function() return HttpService:JSONDecode(data) end)
			if ok2 and type(parsed) == "table" then
				for k, v in pairs(parsed) do Config[k] = v end
			end
		end
	end
end

local function Save()
	if writefile then
		local ok, json = pcall(function() return HttpService:JSONEncode(Config) end)
		if ok then pcall(function() writefile(CONFIG_FILE, json) end) end
	end
end

-- Utils
local function AutoFitText(label, maxSize)
	label.TextSize = maxSize
	label.TextWrapped = false
	label.ClipsDescendants = true
	local function shrink()
		label.TextSize = maxSize
		RunService.Heartbeat:Wait()
		while label.TextBounds.X > math.max(0, label.AbsoluteSize.X - 4) and label.TextSize > 8 do
			label.TextSize -= 1
			RunService.Heartbeat:Wait()
		end
	end
	shrink()
	label:GetPropertyChangedSignal("Text"):Connect(shrink)
	label:GetPropertyChangedSignal("AbsoluteSize"):Connect(shrink)
end

local function WaitForSize(gui)
	if not gui then return end
	if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then
		repeat
			RunService.Heartbeat:Wait()
		until not gui.Parent or (gui.AbsoluteSize.X > 0 and gui.AbsoluteSize.Y > 0)
	end
end

-- Visuals: Matrix reveal and rain
local MATRIX_CHARS = {"ｱ","ｲ","ｳ","ｴ","ｵ","ｶ","ｷ","ｸ","ｹ","ｺ","ｻ","ｼ","ｽ","ｾ","ｿ","ﾀ","ﾁ","ﾂ","ﾃ","ﾄ","ﾅ","ﾆ","ﾇ","ﾈ","ﾉ","ﾊ","ﾋ","ﾌ","ﾍ","ﾎ","ﾏ","ﾐ","ﾑ","ﾒ","ﾓ","ﾔ","ﾕ","ﾖ","ﾗ","ﾘ","ﾙ","ﾚ","ﾛ","ﾜ","ﾝ","0","1","2","3","4","5","6","7","8","9"}
local function MatrixReveal(label, finalText, delayPerChar)
	label.Text = ""
	local revealed = table.create(#finalText, "")
	for i = 1, #finalText do
		for _ = 1, 5 do
			local temp = table.concat(revealed) .. MATRIX_CHARS[math.random(1, #MATRIX_CHARS)]
			label.Text = temp
			task.wait(delayPerChar)
		end
		revealed[i] = string.sub(finalText, i, i)
		label.Text = table.concat(revealed)
	end
end

local function SpawnBinaryStream(overLabel, xPosPixels, opts)
	opts = opts or {}
	local streamLength = opts.length or 30
	local streamSize = opts.textSize or math.max(10, math.floor(overLabel.TextSize))
	local charHeight = math.ceil(streamSize * 0.9)
	local totalHeight = streamLength * charHeight
	local fallTime = opts.fallTime or 1.2
	local fadeTime = math.min(0.4, fallTime * 0.35)

	WaitForSize(overLabel)
	if not overLabel.Parent then return end

	local stream = Instance.new("TextLabel")
	stream.BackgroundTransparency = 1
	stream.Size = UDim2.new(0, streamSize, 0, totalHeight)
	stream.Position = UDim2.new(0, xPosPixels, 0, -totalHeight)
	stream.Font = FONT
	stream.TextSize = streamSize
	stream.TextXAlignment = Enum.TextXAlignment.Center
	stream.TextYAlignment = Enum.TextYAlignment.Top
	stream.TextColor3 = Color3.fromRGB(0, 255, 0)
	stream.TextStrokeTransparency = 0.3
	stream.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	stream.ZIndex = (overLabel.ZIndex or 1) + 1
	stream.Parent = overLabel

	local lines = table.create(streamLength)
	for i = 1, streamLength do lines[i] = tostring(math.random(0,1)) end
	stream.Text = table.concat(lines, "\n")

	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 255, 160)),
		ColorSequenceKeypoint.new(0.10, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 120, 0))
	}
	grad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 0.15),
		NumberSequenceKeypoint.new(0.20, 0.0),
		NumberSequenceKeypoint.new(0.80, 0.2),
		NumberSequenceKeypoint.new(1.00, 0.6)
	}
	grad.Parent = stream

	local targetY = overLabel.AbsoluteSize.Y + totalHeight
	TweenService:Create(stream, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
		Position = UDim2.new(0, xPosPixels, 0, targetY)
	}):Play()

	task.delay(math.max(0, fallTime - fadeTime), function()
		if stream and stream.Parent then
			TweenService:Create(stream, TweenInfo.new(fadeTime), {TextTransparency = 1}):Play()
		end
	end)

	task.delay(fallTime + 0.05, function() if stream then stream:Destroy() end end)
end

local function StartOverlayRain(overLabel, opts)
	opts = opts or {}
	local spawnRateMin = opts.rateMin or 0.06
	local spawnRateMax = opts.rateMax or 0.12

	task.spawn(function()
		WaitForSize(overLabel)
		if not overLabel.Parent then return end
		while overLabel.Parent do
			local w = overLabel.AbsoluteSize.X
			if w > 0 then
				local textSize = math.max(10, math.floor(overLabel.TextSize))
				local colWidth = math.max(10, math.floor(textSize * 0.8))
				local x = math.random(0, math.max(0, w - colWidth))
				SpawnBinaryStream(overLabel, x, {
					length = opts.length or 30,
					textSize = opts.textSize or textSize,
					fallTime = opts.fallTime or 1.15
				})
				task.wait(math.random() * (spawnRateMax - spawnRateMin) + spawnRateMin)
			else
				RunService.Heartbeat:Wait()
			end
		end
	end)
end

-- Background pulse (very dark purple, fixed coverage)
local function CreateFullBackground(parent)
	local BG = Instance.new("Frame")
	BG.Name = "HostilePulse"
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.Position = UDim2.new(0, 0, 0, 0)
	BG.BackgroundColor3 = Color3.fromRGB(15, 0, 25) -- near-black purple
	BG.BackgroundTransparency = 0.4
	BG.BorderSizePixel = 0
	BG.ZIndex = 0
	BG.Parent = parent

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 0, 30)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(40, 0, 60)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(20, 0, 30))
	}
	grad.Rotation = 35
	grad.Parent = BG

	local Cross = Instance.new("Frame")
	Cross.Name = "CrossLayer"
	Cross.Size = UDim2.new(1, 0, 1, 0)
	Cross.BackgroundColor3 = Color3.fromRGB(10, 0, 20)
	Cross.BackgroundTransparency = 0.65
	Cross.BorderSizePixel = 0
	Cross.ZIndex = 0
	Cross.Parent = BG

	local crossGrad = Instance.new("UIGradient")
	crossGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(15, 0, 25)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(35, 0, 55)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(15, 0, 25))
	}
	crossGrad.Rotation = 305
	crossGrad.Parent = Cross

	local Sweep = Instance.new("Frame")
	Sweep.Name = "Sweep"
	Sweep.Size = UDim2.new(1, 0, 1, 0)
	Sweep.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
	Sweep.BackgroundTransparency = 0.93
	Sweep.BorderSizePixel = 0
	Sweep.ZIndex = 1
	Sweep.Parent = BG

	local sweepGrad = Instance.new("UIGradient")
	sweepGrad.Rotation = 20
	sweepGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 0, 180)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(180, 0, 255)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(120, 0, 180))
	}
	sweepGrad.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0.00, 1.0),
		NumberSequenceKeypoint.new(0.40, 0.85),
		NumberSequenceKeypoint.new(0.50, 0.65),
		NumberSequenceKeypoint.new(0.60, 0.85),
		NumberSequenceKeypoint.new(1.00, 1.0)
	}
	sweepGrad.Offset = Vector2.new(-1, 0)
	sweepGrad.Parent = Sweep

	task.spawn(function()
		while BG.Parent do
			TweenService:Create(BG, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.28}):Play()
			TweenService:Create(Cross, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.50}):Play()
			TweenService:Create(grad, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 55}):Play()
			TweenService:Create(crossGrad, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 325}):Play()
			TweenService:Create(sweepGrad, TweenInfo.new(2.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)}):Play()
			task.wait(2.0)
			TweenService:Create(BG, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.50}):Play()
			TweenService:Create(Cross, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.68}):Play()
			TweenService:Create(grad, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 25}):Play()
			TweenService:Create(crossGrad, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = 295}):Play()
			TweenService:Create(sweepGrad, TweenInfo.new(2.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Offset = Vector2.new(-1, 0)}):Play()
			task.wait(2.0)
		end
	end)

	return BG
end

-- Blur control (lighter when closed, fixed size when open)
local BLUR_NAME = "OOFER_BLUR"
local function GetOrCreateBlur()
	local blur = Lighting:FindFirstChild(BLUR_NAME)
	if not blur then
		blur = Instance.new("BlurEffect")
		blur.Name = BLUR_NAME
		blur.Size = 0
		blur.Enabled = false
		blur.Parent = Lighting
	end
	return blur
end

local function SetBlurEnabled(state)
	local blur = GetOrCreateBlur()
	local targetSize = state and 18 or 0
	if state then
		blur.Enabled = true
	end
	TweenService:Create(blur, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	if not state then
		task.delay(0.26, function() if blur then blur.Enabled = false end end)
	end
end

-- GUI roots
Load()

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "OOFER_GUI"
ScreenGui.Parent = playerGui

local BG = CreateFullBackground(ScreenGui)

-- Main panel (fixed pixels)
local HostilePanel = Instance.new("ImageLabel")
HostilePanel.Size = UDim2.new(0, 280, 0, 420)
HostilePanel.Position = UDim2.new(0.3, 0, 0.3, 0)
HostilePanel.BackgroundTransparency = 1
HostilePanel.Image = DECAL
HostilePanel.ScaleType = Enum.ScaleType.Fit
HostilePanel.ClipsDescendants = true
HostilePanel.Active = true
HostilePanel.Draggable = true
HostilePanel.ZIndex = 1
HostilePanel.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -8, 0, 36)
Title.Position = UDim2.new(0, 4, 0, 4)
Title.BackgroundTransparency = 1
Title.Font = FONT
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.TextStrokeTransparency = 0
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.ZIndex = 2
Title.Parent = HostilePanel
AutoFitText(Title, 20)

task.spawn(function()
	MatrixReveal(Title, "OOFER", 0.03)
	task.wait(0.35)
	Title.Text = "OOFER"
	StartOverlayRain(Title, {
		length = 30,
		textSize = Title.TextSize,
		fallTime = 1.15,
		rateMin = 0.06,
		rateMax = 0.12
	})
end)

-- Category scroller
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -12, 1, -50)
Scroll.Position = UDim2.new(0, 6, 0, 46)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4 -- fixed
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 2
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.Parent = HostilePanel

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = Scroll

-- Category panels management
local openPanels = {}     -- name -> Panel
local spawnedPanels = {}  -- ordered for layout
local panelSpacing = 10

local function LayoutPanels()
	WaitForSize(HostilePanel)
	local baseX = HostilePanel.AbsolutePosition.X + HostilePanel.AbsoluteSize.X + panelSpacing
	local y = HostilePanel.AbsolutePosition.Y
	local x = baseX
	for _, p in ipairs(spawnedPanels) do
		if p and p.Parent then
			p.Position = UDim2.fromOffset(x, y)
			x = x + p.AbsoluteSize.X + panelSpacing
		end
	end
end

HostilePanel:GetPropertyChangedSignal("Position"):Connect(LayoutPanels)
HostilePanel:GetPropertyChangedSignal("AbsoluteSize"):Connect(LayoutPanels)

local function CreateCategoryPanel(name)
	local Panel = Instance.new("ImageLabel")
	Panel.Size = UDim2.new(0, 280, 0, 420)
	Panel.BackgroundTransparency = 1
	Panel.Image = DECAL
	Panel.ScaleType = Enum.ScaleType.Fit
	Panel.ClipsDescendants = true
	Panel.Active = true
	Panel.Draggable = true
	Panel.ZIndex = 1
	Panel.Parent = ScreenGui

	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -8, 0, 36)
	Header.Position = UDim2.new(0, 4, 0, 4)
	Header.BackgroundTransparency = 1
	Header.Font = FONT
	Header.TextColor3 = Color3.fromRGB(255, 255, 0)
	Header.TextStrokeTransparency = 0
	Header.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	Header.ZIndex = 2
	Header.Parent = Panel
	AutoFitText(Header, 20)

	task.spawn(function()
		MatrixReveal(Header, name, 0.02)
		task.wait(0.3)
		Header.Text = name
		StartOverlayRain(Header, {
			length = 24,
			textSize = Header.TextSize,
			fallTime = 1.0,
			rateMin = 0.07,
			rateMax = 0.14
		})
	end)

	return Panel
end

local function ToggleCategoryPanel(name)
	if openPanels[name] and openPanels[name].Parent then
		local panel = openPanels[name]
		openPanels[name] = nil
		for i, p in ipairs(spawnedPanels) do
			if p == panel then
				table.remove(spawnedPanels, i)
				break
			end
		end
		panel:Destroy()
		LayoutPanels()
	else
		local panel = CreateCategoryPanel(name)
		table.insert(spawnedPanels, panel)
		openPanels[name] = panel
		LayoutPanels()
	end
end

local CategoryList = { "Combat", "Blatant", "Render", "Utility", "World", "Friends", "Profiles", "Targets" }

for _, name in ipairs(CategoryList) do
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 36) -- fixed height
	Btn.BackgroundTransparency = 1
	Btn.Font = FONT
	Btn.TextColor3 = Color3.fromRGB(0,255,0)
	Btn.ZIndex = 2
	Btn.AutoButtonColor = true
	Btn.Parent = Scroll
	AutoFitText(Btn, 18)
	task.spawn(function() MatrixReveal(Btn, name, 0.02) end)
	Btn.MouseButton1Click:Connect(function()
		Config.UI.CurrentCategory = name
		Save()
		ToggleCategoryPanel(name)
	end)
end

-- Global Open/Close toggle (left-center), RightShift hotkey, mobile swipe
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.ResetOnSpawn = false
ToggleGui.IgnoreGuiInset = true
ToggleGui.Name = "OOF_TOGGLE"
ToggleGui.Parent = playerGui

local OofBtn = Instance.new("TextButton")
OofBtn.Size = UDim2.new(0, 100, 0, 28)
OofBtn.AnchorPoint = Vector2.new(0, 0.5)
OofBtn.Position = UDim2.new(0, 8, 0.5, 0)
OofBtn.BackgroundTransparency = 1
OofBtn.BorderSizePixel = 0
OofBtn.Font = FONT
OofBtn.Text = "Open/Close"
OofBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
OofBtn.TextStrokeTransparency = 0.2
OofBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
OofBtn.ZIndex = 100
OofBtn.Parent = ToggleGui

local SwipeZone = Instance.new("Frame")
SwipeZone.Name = "SwipeZone"
SwipeZone.AnchorPoint = Vector2.new(0, 0.5)
SwipeZone.Size = UDim2.new(0, 12, 1, 0) -- fixed 12px edge
SwipeZone.Position = UDim2.new(0, 0, 0.5, 0)
SwipeZone.BackgroundTransparency = 1
SwipeZone.Active = true
SwipeZone.ZIndex = 99
SwipeZone.Parent = ToggleGui

local isOpen = true
local function SetOpen(state)
	isOpen = state
	ScreenGui.Enabled = isOpen
	SetBlurEnabled(isOpen)
	OofBtn.TextColor3 = isOpen and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
end

OofBtn.MouseButton1Click:Connect(function()
	SetOpen(not isOpen)
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		SetOpen(not isOpen)
	end
end)

-- Mobile swipe toggle (fixed threshold)
if UserInputService.TouchEnabled then
	local tracking = false
	local startPos = nil
	local toggled = false
	local threshold = 40

	SwipeZone.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tracking = true
			toggled = false
			startPos = input.Position
		end
	end)

	SwipeZone.InputChanged:Connect(function(input)
		if tracking and input.UserInputType == Enum.UserInputType.Touch and startPos then
			local dx = input.Position.X - startPos.X
			if math.abs(dx) > threshold and not toggled then
				toggled = true
				SetOpen(not isOpen)
			end
		end
	end)

	SwipeZone.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tracking = false
			startPos = nil
			toggled = false
		end
	end)
end
-- === OOFER hostile module API (PC+Mobile) — deep-neat, overlay-aware, centered sliders, bigger text, no extra label ===
do
    -- constants
    local DOUBLE_TOUCH = 0.28
    local DOUBLE_MOUSE = 0.30
    local MOVE_THRESHOLD = 8
    local TIP_DELAY = 0.08

    -- category provisioning
    local function EnsureCategory(name)
        local panel = openPanels[name]
        if not panel or not panel.Parent then
            panel = CreateCategoryPanel(name)
            table.insert(spawnedPanels, panel)
            openPanels[name] = panel
            LayoutPanels()
        end
        local content = panel:FindFirstChild("Content")
        if not content then
            content = Instance.new("Frame")
            content.Name = "Content"
            content.BackgroundTransparency = 1
            content.ClipsDescendants = true
            content.ZIndex = 2
            content.Size = UDim2.new(1, -12, 1, -56)
            content.Position = UDim2.new(0, 6, 0, 50)
            content.Parent = panel

            local list = Instance.new("UIListLayout")
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Padding = UDim.new(0, 6)
            list.Parent = content
        end
        return panel, content
    end

    -- overlay panel
    local function CreateSettingsPanel(parentPanel, titleText)
        WaitForSize(parentPanel)

        local overlay = Instance.new("Frame")
        overlay.Name = "SettingsOverlay"
        overlay.BackgroundTransparency = 1
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.Position = UDim2.new(0, 0, 0, 0)
        overlay.ZIndex = 20
        overlay.ClipsDescendants = true
        overlay.Active = true
        overlay.Parent = parentPanel

        parentPanel:SetAttribute("OverlayOpen", true)

        local Shade = Instance.new("Frame")
        Shade.BackgroundColor3 = Color3.fromRGB(10, 0, 20)
        Shade.BackgroundTransparency = 0.35
        Shade.BorderSizePixel = 0
        Shade.Size = UDim2.new(1, 0, 1, 0)
        Shade.ZIndex = 20
        Shade.Parent = overlay

        local Panel = Instance.new("ImageLabel")
        Panel.Name = "SettingsPanel"
        Panel.BackgroundTransparency = 1
        Panel.Image = DECAL
        Panel.ScaleType = Enum.ScaleType.Fit
        Panel.Size = UDim2.new(0, 260, 1, -14)
        Panel.Position = UDim2.new(1, 12, 0, 7)
        Panel.ZIndex = 21
        Panel.ClipsDescendants = true
        Panel.Parent = overlay

        local Header = Instance.new("TextLabel")
        Header.Size = UDim2.new(1, -8, 0, 34)
        Header.Position = UDim2.new(0, 4, 0, 4)
        Header.BackgroundTransparency = 1
        Header.Font = FONT
        Header.TextColor3 = Color3.fromRGB(0, 255, 160)
        Header.TextStrokeTransparency = 0
        Header.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        Header.ZIndex = 22
        Header.Parent = Panel
        AutoFitText(Header, 22)

        task.spawn(function()
            MatrixReveal(Header, titleText or "SETTINGS", 0.02)
            task.wait(0.25)
            Header.Text = titleText or "SETTINGS"
            StartOverlayRain(Header, {
                length = 22, textSize = Header.TextSize, fallTime = 1.0, rateMin = 0.07, rateMax = 0.14
            })
        end)

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 60, 0, 22)
        CloseBtn.Position = UDim2.new(1, -64, 0, 6)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Font = FONT
        CloseBtn.Text = "CLOSE"
        CloseBtn.TextSize = 18
        CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        CloseBtn.TextStrokeTransparency = 0
        CloseBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        CloseBtn.ZIndex = 23
        CloseBtn.Parent = Panel
        AutoFitText(CloseBtn, 18)

        local Content = Instance.new("ScrollingFrame")
        Content.Name = "Body"
        Content.Size = UDim2.new(1, -10, 1, -48)
        Content.Position = UDim2.new(0, 5, 0, 42)
        Content.BackgroundTransparency = 1
        Content.BorderSizePixel = 0
        Content.ScrollBarThickness = 4
        Content.ScrollingDirection = Enum.ScrollingDirection.Y
        Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Content.CanvasSize = UDim2.new(0, 0, 0, 0)
        Content.ZIndex = 22
        Content.ClipsDescendants = true
        Content.Parent = Panel

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 4)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 4)
        pad.Parent = Content

        local list = Instance.new("UIListLayout")
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Padding = UDim.new(0, 6)
        list.Parent = Content

        TweenService:Create(Panel, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -272, 0, 7)
        }):Play()

        local function Close()
            TweenService:Create(Panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 12, 0, 7)
            }):Play()
            TweenService:Create(Shade, TweenInfo.new(0.16), {BackgroundTransparency = 1}):Play()
            task.delay(0.2, function()
                if overlay then overlay:Destroy() end
                if parentPanel then parentPanel:SetAttribute("OverlayOpen", false) end
            end)
        end

        CloseBtn.MouseButton1Click:Connect(Close)
        Shade.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                local p = i.Position
                local ax, ay = Panel.AbsolutePosition.X, Panel.AbsolutePosition.Y
                local aw, ah = Panel.AbsoluteSize.X, Panel.AbsoluteSize.Y
                if not (p.X >= ax and p.X <= ax + aw and p.Y >= ay and p.Y <= ay + ah) then
                    Close()
                end
            end
        end)

        return Content, Close
    end

    -- ui helpers
    local function mkLabel(parent, text, size, color, stroke, align)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Font = FONT
        l.Text = text or ""
        l.TextSize = size or 16
        l.TextColor3 = color or Color3.fromRGB(0,255,0)
        l.TextStrokeTransparency = stroke and 0 or 1
        l.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.ZIndex = 3
        l.Parent = parent
        return l
    end
    local function mkButton(parent)
        local b = Instance.new("TextButton")
        b.BackgroundTransparency = 1
        b.Font = FONT
        b.Text = ""
        b.TextSize = 1
        b.AutoButtonColor = true
        b.ZIndex = 4
        b.Parent = parent
        return b
    end
    local function mkRow(parent, height)
        local r = Instance.new("Frame")
        r.BackgroundTransparency = 1
        r.ClipsDescendants = true
        r.Size = UDim2.new(1, 0, 0, height or 36)
        r.ZIndex = 2
        r.Parent = parent
        return r
    end
    local function mkDivider(parent)
        local d = Instance.new("Frame")
        d.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
        d.BackgroundTransparency = 0.35
        d.BorderSizePixel = 0
        d.Size = UDim2.new(1, 0, 0, 1)
        d.ZIndex = 2
        d.Parent = parent
        return d
    end
    local function round(n) return math.floor(n + 0.5) end

    -- shared slider (auto-centered)
    local function BuildContainedSlider(row, opts)
        opts = opts or {}
        local min = tonumber(opts.Min) or 0
        local max = tonumber(opts.Max) or 100
        local step = tonumber(opts.Step) or 1
        local val = math.clamp(((tonumber(opts.Default) or min) // step) * step, min, max)
        local onChange = type(opts.Function) == "function" and opts.Function or function() end
        local suffix = type(opts.Suffix) == "function" and opts.Suffix or function() return "" end
        local name = opts.Name or "Slider"
        local z = opts.Z or 24

        -- centered container inside the provided row
        local inner = Instance.new("Frame")
        inner.BackgroundTransparency = 1
        inner.Size = UDim2.new(0, 232, 1, 0)
        inner.AnchorPoint = Vector2.new(0.5, 0.5)
        inner.Position = UDim2.new(0.5, 0, 0.5, 0)
        inner.ZIndex = z
        inner.Parent = row

        local lab = mkLabel(inner, name, 17, Color3.fromRGB(0,255,0), true, Enum.TextXAlignment.Left)
        lab.Size = UDim2.new(1, 0, 0, 16)
        lab.Position = UDim2.new(0, 0, 0, 0)
        lab.ZIndex = z

        local bar = Instance.new("Frame")
        bar.Name = "Track"
        bar.BackgroundColor3 = Color3.fromRGB(40,0,60)
        bar.BackgroundTransparency = 0.2
        bar.BorderSizePixel = 0
        bar.ZIndex = z
        bar.ClipsDescendants = true
        bar.Size = UDim2.new(1, 0, 0, 18)
        bar.Position = UDim2.new(0, 0, 0, 20)
        bar.Parent = inner

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.BackgroundColor3 = Color3.fromRGB(160,0,220)
        fill.BackgroundTransparency = 0.1
        fill.BorderSizePixel = 0
        fill.ZIndex = z + 1
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.Parent = bar

        local thumb = Instance.new("Frame")
        thumb.Name = "Thumb"
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.BackgroundColor3 = Color3.fromRGB(210,50,255)
        thumb.BorderSizePixel = 0
        thumb.Size = UDim2.new(0, 10, 0, 10)
        thumb.Position = UDim2.new(0, 0, 0.5, 0)
        thumb.ZIndex = z + 2
        thumb.Parent = bar
        local uic = Instance.new("UICorner"); uic.CornerRadius = UDim.new(0, 5); uic.Parent = thumb

        local valLabel = Instance.new("TextLabel")
        valLabel.BackgroundTransparency = 1
        valLabel.Font = FONT
        valLabel.Text = ""
        valLabel.TextScaled = true
        valLabel.TextColor3 = Color3.fromRGB(255,255,255)
        valLabel.TextStrokeTransparency = 0
        valLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        valLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        valLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        valLabel.Size = UDim2.new(1, -6, 1, -4)
        valLabel.ZIndex = z + 3
        valLabel.Parent = bar
        do
            local szc = Instance.new("UITextSizeConstraint")
            szc.MinTextSize = 11
            szc.MaxTextSize = 18
            szc.Parent = valLabel
        end

        local hit = Instance.new("TextButton")
        hit.BackgroundTransparency = 1
        hit.TextTransparency = 1
        hit.AutoButtonColor = false
        hit.ZIndex = z + 4
        hit.Size = UDim2.new(1, 0, 1, 10)
        hit.Position = UDim2.new(0, 0, 0, -5)
        hit.Parent = bar

        local function quantize(v)
            v = math.clamp(v, min, max)
            local snapped = (round((v - min) / step) * step) + min
            return math.clamp(snapped, min, max)
        end

        local function setVisual(v)
            local range = math.max(1, (max - min))
            local alpha = (v - min) / range
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
            local suf = suffix(v)
            valLabel.Text = tostring(v) .. (suf ~= "" and (" " .. tostring(suf)) or "")
            local covered = alpha > 0.35 and alpha < 0.65
            if covered then
                valLabel.TextColor3 = Color3.fromRGB(0,0,0)
                valLabel.TextStrokeColor3 = Color3.fromRGB(255,255,255)
            else
                valLabel.TextColor3 = Color3.fromRGB(255,255,255)
                valLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
            end
        end

        local dragging = false
        local function setFromX(x)
            local ax = bar.AbsolutePosition.X
            local aw = math.max(1, bar.AbsoluteSize.X)
            local rel = math.clamp((x - ax) / aw, 0, 1)
            local v = quantize(min + rel * (max - min))
            if v ~= val then
                val = v
                setVisual(val)
                task.spawn(function()
                    local ok, err = pcall(onChange, val)
                    if not ok then warn("[OOFER] Slider error ("..name.."): "..tostring(err)) end
                end)
            else
                setVisual(val)
            end
        end

        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                setFromX(i.Position.X)
            end
        end)
        hit.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                setFromX(i.Position.X)
            end
        end)
        hit.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        setVisual(val)

        return {
            Value = val,
            SetValue = function(_, v)
                val = quantize(v)
                setVisual(val)
                onChange(val)
            end
        }
    end

    -- helpers: panel, tooltip, tap
    local function nearestPanel(i: Instance): GuiObject?
        local p = i
        while p do
            if p:IsA("GuiObject") and p:FindFirstChild("SettingsOverlay") then return p end
            if p:IsA("ImageLabel") and p.Name ~= "" then return p end
            p = p.Parent
        end
        return nil
    end

    local function overlayOpen(panel: Instance?): boolean
        return panel and panel:GetAttribute("OverlayOpen") == true or false
    end

    local function AttachTooltip(row: GuiObject, hit: GuiButton, text: string)
        local tip = mkLabel(row, text, 15, Color3.fromRGB(180,180,255), false, Enum.TextXAlignment.Center)
        tip.Visible = false
        tip.Size = UDim2.new(1, -8, 0, 16)
        tip.Position = UDim2.new(0, 4, 1, -16)
        tip.TextTransparency = 0.15
        tip.ZIndex = math.max(row.ZIndex + 1, 5)
        tip.TextTruncate = Enum.TextTruncate.AtEnd

        local panel = nearestPanel(row)
        local armed = false
        local timer = nil

        local function hide()
            if timer then timer:Disconnect(); timer = nil end
            armed = false
            tip.Visible = false
        end
        local function armShow(delaySec)
            if overlayOpen(panel) then return end
            armed = true
            if timer then timer:Disconnect(); timer = nil end
            local dt = 0
            timer = game:GetService("RunService").Heartbeat:Connect(function(step)
                if not armed then timer:Disconnect(); timer = nil; return end
                dt += step
                if dt >= delaySec then
                    tip.Visible = true
                    timer:Disconnect(); timer = nil
                end
            end)
        end

        hit.MouseEnter:Connect(function() armShow(TIP_DELAY) end)
        hit.MouseLeave:Connect(hide)
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then
                if not overlayOpen(panel) then tip.Visible = true end
            end
        end)
        hit.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Touch then hide() end
        end)
        if panel then panel:GetAttributeChangedSignal("OverlayOpen"):Connect(hide) end
    end

    local function nearestScroll(i: Instance): ScrollingFrame?
        local p = i.Parent
        while p do
            if p:IsA("ScrollingFrame") then return p end
            p = p.Parent
        end
        return nil
    end

    local function AttachTap(hit: GuiButton, row: GuiObject, panel: GuiObject, onSingle: ()->(), onDouble: ()->())
        local uis = game:GetService("UserInputService")
        local doubleWindow = uis.TouchEnabled and DOUBLE_TOUCH or DOUBLE_MOUSE

        local lastTap = 0.0
        local pendingId = 0
        local pressing = false
        local canceled = false
        local startPos: Vector2? = nil

        local function dist(a: Vector2, b: Vector2)
            local dx, dy = a.X - b.X, a.Y - b.Y
            return math.sqrt(dx*dx + dy*dy)
        end

        local scroll = nearestScroll(row)
        if scroll then
            scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                if pressing then canceled = true end
            end)
        end

        local function fireSingle()
            if overlayOpen(panel) then return end
            onSingle()
        end
        local function fireDouble()
            onDouble()
        end

        hit.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            pressing = true
            canceled = false
            startPos = Vector2.new(input.Position.X, input.Position.Y)

            local now = os.clock()
            if (now - lastTap) <= doubleWindow then
                pendingId += 1
                lastTap = 0
                fireDouble()
            else
                lastTap = now
                local myId = pendingId + 1
                pendingId = myId
                task.delay(doubleWindow, function()
                    if pendingId == myId and not canceled then
                        fireSingle()
                    end
                end)
            end
        end)

        hit.InputChanged:Connect(function(input)
            if not pressing then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if startPos and dist(Vector2.new(input.Position.X, input.Position.Y), startPos) > MOVE_THRESHOLD then
                canceled = true
            end
        end)

        hit.InputEnded:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            pressing = false
        end)
    end

    -- category proxy (no extra label, centered row, bigger title)
    local CategoryProxy = {}
    CategoryProxy.__index = CategoryProxy

    function CategoryProxy:CreateButton(opts)
        opts = opts or {}
        local name = opts.Name or "Module"
        local tooltip = opts.Tooltip
        local onToggle = type(opts.Function) == "function" and opts.Function or function() end
        local buildDefs = type(opts.Build) == "function" and opts.Build or nil
        local onSettings = type(opts.OnSettings) == "function" and opts.OnSettings or nil

        local panel, content = EnsureCategory(self.Name)
        local row = mkRow(content, 40)

        local inner = Instance.new("Frame")
        inner.BackgroundTransparency = 1
        inner.Size = UDim2.new(0, 232, 1, 0)
        inner.AnchorPoint = Vector2.new(0.5, 0.5)
        inner.Position = UDim2.new(0.5, 0, 0.5, 0)
        inner.ZIndex = 3
        inner.Parent = row

        local title = mkLabel(inner, name, 22, Color3.fromRGB(0,255,0), true, Enum.TextXAlignment.Center)
        title.Size = UDim2.new(1, 0, 1, -8)
        title.Position = UDim2.new(0, 0, 0, 0)
        title.TextTruncate = Enum.TextTruncate.AtEnd
        AutoFitText(title, 22)

        local hit = mkButton(inner)
        hit.Size = UDim2.new(1, 0, 1, 0)

        if tooltip then
            AttachTooltip(inner, hit, tooltip)
        end

        local Module = { Enabled = false, __defs = {} }

        function Module:CreateSlider(s)
            s = s or {}
            table.insert(self.__defs, { kind = "slider", opts = s })
            return { Value = s.Default or s.Min or 0, SetValue = function() end }
        end

        if buildDefs then
            local ok, err = pcall(buildDefs, Module)
            if not ok then warn("[OOFER] Build defs error ("..name.."): "..tostring(err)) end
        end

        local function renderState()
            title.TextColor3 = Module.Enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(120,200,120)
        end

        local function fireToggle()
            Module.Enabled = not Module.Enabled
            renderState()
            task.spawn(function()
                local ok, err = pcall(onToggle, Module.Enabled)
                if not ok then warn("[OOFER] Module error ("..name.."): "..tostring(err)) end
            end)
        end

        local function fireSettings()
            local body, closeFn = CreateSettingsPanel(panel, name .. " SETTINGS")

            local function sRow(height)
                local r = Instance.new("Frame")
                r.BackgroundTransparency = 1
                r.ClipsDescendants = true
                r.Size = UDim2.new(1, -8, 0, height or 48)
                r.Position = UDim2.new(0, 4, 0, 0)
                r.ZIndex = 23
                r.Parent = body
                return r
            end
            local function sDivider()
                local d = Instance.new("Frame")
                d.BackgroundColor3 = Color3.fromRGB(40, 0, 60)
                d.BackgroundTransparency = 0.35
                d.BorderSizePixel = 0
                d.Size = UDim2.new(1, -8, 0, 1)
                d.Position = UDim2.new(0, 4, 0, 0)
                d.ZIndex = 23
                d.Parent = body
                return d
            end

            for _, d in ipairs(Module.__defs) do
                if d.kind == "slider" then
                    local s = d.opts or {}
                    local r = sRow(48)
                    BuildContainedSlider(r, {
                        Name = s.Name, Min = s.Min, Max = s.Max, Default = s.Default, Step = s.Step,
                        Function = s.Function, Suffix = s.Suffix, Z = 24
                    })
                    sDivider()
                end
            end

            if onSettings then
                local API = { Close = function() if closeFn then closeFn() end end }
                local ok, err = pcall(onSettings, Module, API)
                if not ok then warn("[OOFER] Settings build error ("..name.."): "..tostring(err)) end
            end
        end

        AttachTap(hit, inner, panel, fireToggle, fireSettings)

        mkDivider(content)

        task.spawn(function()
            while row.Parent do
                renderState()
                task.wait(0.25)
            end
        end)

        return Module
    end

    -- public surface
    oofer = {
        Categories = setmetatable({}, {
            __index = function(_, key)
                return setmetatable({ Name = tostring(key) }, CategoryProxy)
            end
        })
    }
end

-- example (kept minimal; safe to remove if you inject your own)
do
    local function run(fn) fn() end
    run(function()
        local Mod = oofer.Categories.Render:CreateButton({
            Name = 'Testing',
            Tooltip = 'Adjust value inside the panel (double-click/tap)',
            Function = function(enabled)
                print("Testing Enabled:", enabled)
            end,
            Build = function(module)
                module:CreateSlider({
                    Name = 'Value',
                    Min = 1, Max = 99, Default = 71, Step = 1,
                    Suffix = function(v) return v == 1 and 'stud' or 'studs' end,
                    Function = function(v) print("Value:", v) end
                })
            end
        })
    end)
end
-- Initialize
SetOpen(true)
