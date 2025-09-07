-- OOFER: Full hostile GUI with Open/Close toggle (left-center), RightShift hotkey, and blur control
-- Delivers: full-screen pulse, matrix reveal, overlay binary rain, category panels, global hide/show

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
		task.wait()
		while label.TextBounds.X > label.AbsoluteSize.X - 4 and label.TextSize > 8 do
			label.TextSize -= 1
			RunService.Heartbeat:Wait()
		end
	end
	shrink()
	label:GetPropertyChangedSignal("Text"):Connect(shrink)
	label:GetPropertyChangedSignal("AbsoluteSize"):Connect(shrink)
end

local function WaitForSize(gui)
	if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then
		repeat RunService.Heartbeat:Wait() until not gui.Parent or (gui.AbsoluteSize.X > 0 and gui.AbsoluteSize.Y > 0)
	end
end

-- Matrix reveal
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

-- Background pulse
local function CreateFullBackground(parent)
	local BG = Instance.new("Frame")
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.Position = UDim2.new(0, 0, 0, 0)
	BG.BackgroundTransparency = 0.5
	BG.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
	BG.BorderSizePixel = 0
	BG.ZIndex = 0
	BG.Name = "HostilePulse"
	BG.Parent = parent

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 50, 150))
	}
	grad.Parent = BG

	task.spawn(function()
		while BG.Parent do
			local tweenIn = TweenService:Create(BG, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.2})
			tweenIn:Play(); tweenIn.Completed:Wait()
			local tweenOut = TweenService:Create(BG, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0.5})
			tweenOut:Play(); tweenOut.Completed:Wait()
		end
	end)
end

-- Binary rain overlay
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
	local tweenFall = TweenService:Create(stream, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
		Position = UDim2.new(0, xPosPixels, 0, targetY)
	})
	tweenFall:Play()

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

-- Blur control
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
	if state then
		blur.Enabled = true
		TweenService:Create(blur, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 18}):Play()
	else
		TweenService:Create(blur, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = 0}):Play()
		task.delay(0.22, function() if blur then blur.Enabled = false end end)
	end
end

-- GUI roots
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "OOFER_GUI"
ScreenGui.Parent = playerGui

CreateFullBackground(ScreenGui)

-- Main panel
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
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 2
Scroll.Parent = HostilePanel

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = Scroll

-- Category panels + layout
local openPanels = {}     -- name -> Panel
local spawnedPanels = {}  -- ordered list for layout
local panelSpacing = 10

local function LayoutPanels()
	WaitForSize(HostilePanel)
	local x = HostilePanel.AbsolutePosition.X + HostilePanel.AbsoluteSize.X + panelSpacing
	local y = HostilePanel.AbsolutePosition.Y
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
			if p == panel then table.remove(spawnedPanels, i) break end
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
	Btn.Size = UDim2.new(1, 0, 0, 36)
	Btn.BackgroundTransparency = 1
	Btn.Font = FONT
	Btn.TextColor3 = Color3.fromRGB(0,255,0)
	Btn.ZIndex = 2
	Btn.Parent = Scroll
	AutoFitText(Btn, 18)
	task.spawn(function() MatrixReveal(Btn, name, 0.02) end)
	Btn.MouseButton1Click:Connect(function()
		Config.UI.CurrentCategory = name
		Save()
		ToggleCategoryPanel(name)
	end)
end

-- Global Open/Close toggle (left-center, no background) + RightShift hotkey
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.ResetOnSpawn = false
ToggleGui.IgnoreGuiInset = true
ToggleGui.Name = "OOF_TOGGLE"
ToggleGui.Parent = playerGui

local OofBtn = Instance.new("TextButton")
OofBtn.Size = UDim2.new(0, 100, 0, 28)
OofBtn.AnchorPoint = Vector2.new(0, 0.5)
OofBtn.Position = UDim2.new(0, 8, 0.5, 0) -- left edge, vertical middle
OofBtn.BackgroundTransparency = 1
OofBtn.BorderSizePixel = 0
OofBtn.Font = FONT
OofBtn.Text = "Open/Close"
OofBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
OofBtn.TextStrokeTransparency = 0.2
OofBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
OofBtn.ZIndex = 100
OofBtn.Parent = ToggleGui

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

-- Initialize
SetOpen(true)
