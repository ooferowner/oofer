-- HOSTILE GUI: FULL-SCREEN PULSE + MATRIX REVEAL + OVERLAYED BINARY RAIN + CATEGORY TOGGLE + GLOBAL "oof" HIDE/SHOW BUTTON
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DECAL = "rbxassetid://86828470035784"
local FONT = Enum.Font.Arcade
local CONFIG_FILE = "oofer_config.json"

local Config = { UI = { CurrentCategory = nil }, Modules = {} }

local function Save()
	if writefile then
		local ok, json = pcall(function() return HttpService:JSONEncode(Config) end)
		if ok then pcall(function() writefile(CONFIG_FILE, json) end) end
	end
end

local function AutoFitText(label, maxSize)
	label.TextSize = maxSize
	label.TextWrapped = false
	label.ClipsDescendants = true
	local function shrink()
		label.TextSize = maxSize
		task.wait()
		while label.TextBounds.X > label.AbsoluteSize.X - 4 and label.TextSize > 8 do
			label.TextSize -= 1
			task.wait()
		end
	end
	shrink()
	label:GetPropertyChangedSignal("Text"):Connect(shrink)
	label:GetPropertyChangedSignal("AbsoluteSize"):Connect(shrink)
end

-- Matrix charset animation (load-in)
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

-- Full-screen pulsing blue background (no rotation)
local function CreateFullBackground(parent)
	local BG = Instance.new("Frame")
	BG.Size = UDim2.new(1, 0, 1, 0)
	BG.Position = UDim2.new(0, 0, 0, 0)
	BG.BackgroundTransparency = 0.5
	BG.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
	BG.BorderSizePixel = 0
	BG.ZIndex = 0
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

-- Utility: wait until AbsoluteSize is non-zero
local function WaitForSize(gui)
	if gui.AbsoluteSize.X <= 0 or gui.AbsoluteSize.Y <= 0 then
		repeat RunService.Heartbeat:Wait() until not gui.Parent or (gui.AbsoluteSize.X > 0 and gui.AbsoluteSize.Y > 0)
	end
end

-- Spawn a single vertical falling 0/1 stream OVER a label (overlay), clipped by the label bounds
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
	for i = 1, streamLength do
		lines[i] = tostring(math.random(0,1))
	end
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
			local tweenFade = TweenService:Create(stream, TweenInfo.new(fadeTime), {TextTransparency = 1})
			tweenFade:Play()
		end
	end)

	task.delay(fallTime + 0.05, function()
		if stream then stream:Destroy() end
	end)
end

-- Continuous loop to spawn random streams over a label
local function StartOverlayRain(overLabel, opts)
	opts = opts or {}
	local spawnRateMin = opts.rateMin or 0.06
	local spawnRateMax = opts.rateMax or 0.12

	task.spawn(function()
		WaitForSize(overLabel)
		if not overLabel.Parent then return end
		while overLabel.Parent do
			local w = overLabel.AbsoluteSize.X
			if w <= 0 then RunService.Heartbeat:Wait() else
				local textSize = math.max(10, math.floor(overLabel.TextSize))
				local colWidth = math.max(10, math.floor(textSize * 0.8))
				local x = math.random(0, math.max(0, w - colWidth))
				SpawnBinaryStream(overLabel, x, {
					length = opts.length or 30,
					textSize = opts.textSize or textSize,
					fallTime = opts.fallTime or 1.15
				})
				task.wait(math.random() * (spawnRateMax - spawnRateMin) + spawnRateMin)
			end
		end
	end)
end

-- GUI
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Main GUI (everything hostile lives here; we will toggle this on/off)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Name = "OOFER_GUI"
ScreenGui.Parent = playerGui

CreateFullBackground(ScreenGui)

-- Main hostile decal panel
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

-- Title (static text + load reveal + overlay rain)
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

-- Scrollable category list
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

-- PANEL TOGGLING + LAYOUT
local openPanels = {}   -- name -> Panel
local spawnedPanels = {} -- ordered list for layout
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

-- Exact category order
local CategoryList = { "Combat", "Blatant", "Render", "Utility", "World", "Friends", "Profiles", "Targets" }

-- Create category buttons (MatrixReveal; toggles panel open/close)
for _, name in ipairs(CategoryList) do
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, 0, 0, 36)
	Btn.BackgroundTransparency = 1
	Btn.Font = FONT
	Btn.TextColor3 = Color3.fromRGB(0,255,0)
	Btn.ZIndex = 2
	Btn.Parent = Scroll
	AutoFitText(Btn, 18)
	task.spawn(function()
		MatrixReveal(Btn, name, 0.02)
	end)
	Btn.MouseButton1Click:Connect(function()
		Config.UI.CurrentCategory = name
		Save()
		ToggleCategoryPanel(name)
	end)
end

-- GLOBAL "oof" TOGGLE (SEPARATE GUI SO IT STAYS CLICKABLE WHEN MAIN GUI IS HIDDEN)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.ResetOnSpawn = false
ToggleGui.IgnoreGuiInset = true
ToggleGui.Name = "OOF_TOGGLE"
ToggleGui.Parent = playerGui

local OofBtn = Instance.new("TextButton")
OofBtn.Size = UDim2.new(0, 44, 0, 22)
OofBtn.Position = UDim2.new(0, 8, 0, 8)
OofBtn.BackgroundTransparency = 1 -- no background
OofBtn.BorderSizePixel = 0
OofBtn.Font = FONT
OofBtn.Text = "oof"
OofBtn.TextColor3 = Color3.fromRGB(0, 255, 0)
OofBtn.TextStrokeTransparency = 0.2
OofBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
OofBtn.ZIndex = 100
OofBtn.Parent = ToggleGui

local isOpen = true
local function SetOpen(state)
	isOpen = state
	ScreenGui.Enabled = isOpen -- hides/shows EVERYTHING inside, including the pulsing blur
	-- Optional: visual cue on the toggle itself
	OofBtn.TextColor3 = isOpen and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 80, 80)
	OofBtn.Text = isOpen and "oof" or "OOF"
end

OofBtn.MouseButton1Click:Connect(function()
	SetOpen(not isOpen)
end)

-- Start in open state
SetOpen(true)
