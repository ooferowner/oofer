-- OTTER CLIENT - Premium Modern GUI
-- Enhanced with glassmorphism, dynamic particles, and modern aesthetics

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

local clone, oldChar
local events = {}
local charAdded

-- Enhanced parent detection
local parentGui = CoreGui
pcall(function() 
    if typeof(gethui) == "function" then 
        parentGui = gethui() 
    elseif syn and syn.protect_gui then
        parentGui = CoreGui
    end 
end)

-- Modern premium color palette with glassmorphism
local N = {
    BG = Color3.fromRGB(15, 20, 35),          -- Deep navy
    PANEL = Color3.fromRGB(20, 28, 45),       -- Slightly lighter navy
    ITEM = Color3.fromRGB(25, 35, 55),        -- Medium navy
    HOVER = Color3.fromRGB(45, 60, 95),       -- Hover blue
    TEXT = Color3.fromRGB(250, 255, 270),     -- Crisp white
    SUBTEXT = Color3.fromRGB(180, 190, 210),  -- Muted text
    LINE = Color3.fromRGB(80, 120, 200),      -- Accent blue
    GLOW = Color3.fromRGB(100, 180, 255),     -- Electric blue
    DIM = Color3.fromRGB(10, 15, 25),         -- Very dark navy
    ACCENT = Color3.fromRGB(100, 200, 255),   -- Bright cyan-blue
    GLASS = Color3.fromRGB(255, 255, 255),    -- Glass overlay
    PARTICLE = Color3.fromRGB(120, 200, 255), -- Particle color
}

-- Enhanced metrics with modern proportions
local METRIC = {
    RRoot = 20, RPanel = 18, RCard = 16, RChip = 14, RSmall = 10,
    Pad = 20, Gap = 16, HeaderH = 70, FooterH = 85, ItemH = 42,
    Gear = 32, SliderBarH = 12, Cursor = 18,
    Shadows = {16, 10, 6}, ShadowAlpha = {0.9, 0.8, 0.6},
    TwinGap = 22, AnimSpeed = 0.3, GlassBlur = 20
}

-- Premium theme collection
local SCHEMES = {
    {name = "Arctic Blue", col = Color3.fromRGB(100, 200, 255)},
    {name = "Neon Purple", col = Color3.fromRGB(180, 100, 255)},
    {name = "Electric Cyan", col = Color3.fromRGB(0, 255, 200)},
    {name = "Plasma Pink", col = Color3.fromRGB(255, 100, 180)},
    {name = "Solar Orange", col = Color3.fromRGB(255, 150, 50)},
    {name = "Matrix Green", col = Color3.fromRGB(50, 255, 100)},
}

-- Enhanced registries
local Reg = { Emblem = {}, SelGlows = {}, TagStroke = nil, TagText = nil, Particles = {} }
local Twin = { map = {}, activeOrder = {} }
local Items = {}
local ButtonRoots = {}

-- Modern utility functions
local function roundCorner(p, r) 
    local u = Instance.new("UICorner") 
    u.CornerRadius = UDim.new(0, r) 
    u.Parent = p 
    return u
end

local function circleCorner(p) 
    local u = Instance.new("UICorner") 
    u.CornerRadius = UDim.new(1, 0) 
    u.Parent = p 
    return u
end

local function stroke(p, c, t, thk, mode) 
    local s = Instance.new("UIStroke")
    s.Color = c
    s.Thickness = thk or 1
    s.Transparency = t or 0.8
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function pad(p, l, t, r, b) 
    local x = Instance.new("UIPadding")
    x.PaddingLeft = UDim.new(0, l or 0)
    x.PaddingTop = UDim.new(0, t or 0)
    x.PaddingRight = UDim.new(0, r or 0)
    x.PaddingBottom = UDim.new(0, b or 0)
    x.Parent = p
    return x
end

-- Glassmorphism effect
local function applyGlass(obj, intensity)
    local glass = Instance.new("Frame")
    glass.Name = "GlassOverlay"
    glass.Size = UDim2.new(1, 0, 1, 0)
    glass.Position = UDim2.new(0, 0, 0, 0)
    glass.BackgroundColor3 = N.GLASS
    glass.BackgroundTransparency = 0.85 + (intensity or 0)
    glass.BorderSizePixel = 0
    glass.ZIndex = obj.ZIndex + 1
    glass.Parent = obj
    
    roundCorner(glass, obj:FindFirstChildOfClass("UICorner") and obj:FindFirstChildOfClass("UICorner").CornerRadius.Offset or 0)
    
    local glassGrad = Instance.new("UIGradient")
    glassGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 220, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 200, 255))
    })
    glassGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 0.88)
    })
    glassGrad.Rotation = 45
    glassGrad.Parent = glass
    
    return glass
end

-- Particle system for background ambiance
local function createParticleSystem(parent)
    local particles = {}
    
    for i = 1, 15 do
        local particle = Instance.new("Frame")
        particle.Name = "Particle"
        particle.Size = UDim2.fromOffset(math.random(2, 6), math.random(2, 6))
        particle.BackgroundColor3 = N.PARTICLE
        particle.BackgroundTransparency = math.random(70, 90) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = -5
        particle.Parent = parent
        circleCorner(particle)
        
        -- Random starting position
        particle.Position = UDim2.new(
            math.random(0, 100) / 100,
            math.random(-50, 50),
            math.random(0, 100) / 100,
            math.random(-50, 50)
        )
        
        table.insert(particles, particle)
        table.insert(Reg.Particles, particle)
    end
    
    -- Animate particles
    spawn(function()
        while parent.Parent do
            for _, particle in ipairs(particles) do
                if particle.Parent then
                    local newPos = UDim2.new(
                        math.random(0, 100) / 100,
                        math.random(-50, 50),
                        math.random(0, 100) / 100,
                        math.random(-50, 50)
                    )
                    
                    TweenService:Create(particle, TweenInfo.new(
                        math.random(5, 12),
                        Enum.EasingStyle.Sine,
                        Enum.EasingDirection.InOut
                    ), {
                        Position = newPos,
                        BackgroundTransparency = math.random(70, 95) / 100
                    }):Play()
                end
            end
            wait(2)
        end
    end)
    
    return particles
end

-- Enhanced Otter emblem with modern effects
local function makeOtterIcon(parent, sizePx)
    local root = Instance.new("Frame")
    root.Name = "OtterIcon"
    root.BackgroundTransparency = 1
    root.Size = UDim2.fromOffset(sizePx, sizePx)
    root.Parent = parent
    
    -- Outer glow rings
    for i = 1, 3 do
        local glowRing = Instance.new("Frame")
        glowRing.Name = "GlowRing" .. i
        glowRing.Size = UDim2.new(1, i * 8, 1, i * 8)
        glowRing.Position = UDim2.new(0, -i * 4, 0, -i * 4)
        glowRing.BackgroundColor3 = N.ACCENT
        glowRing.BackgroundTransparency = 0.8 + (i * 0.05)
        glowRing.BorderSizePixel = 0
        glowRing.ZIndex = -i
        glowRing.Parent = root
        circleCorner(glowRing)
    end
    
    -- Main emblem ring
    local ring = Instance.new("Frame")
    ring.Name = "Ring"
    ring.Size = UDim2.new(1, 0, 1, 0)
    ring.BackgroundColor3 = N.ACCENT
    ring.BorderSizePixel = 0
    ring.Parent = root
    circleCorner(ring)
    
    -- Advanced gradient for ring
    local ringGrad = Instance.new("UIGradient")
    ringGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 220, 255)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(100, 180, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(80, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 200, 255))
    })
    ringGrad.Rotation = 0
    ringGrad.Parent = ring
    
    -- Inner cutout with depth
    local inner = 0.65
    local cut = Instance.new("Frame")
    cut.Size = UDim2.new(inner, 0, inner, 0)
    cut.Position = UDim2.new((1-inner)/2, 0, (1-inner)/2, 0)
    cut.BackgroundColor3 = N.BG
    cut.BackgroundTransparency = 0.1
    cut.BorderSizePixel = 0
    cut.Parent = ring
    circleCorner(cut)
    
    -- Inner glow effect
    local innerGlow = Instance.new("Frame")
    innerGlow.Size = UDim2.new(0.85, 0, 0.85, 0)
    innerGlow.Position = UDim2.new(0.075, 0, 0.075, 0)
    innerGlow.BackgroundColor3 = N.GLOW
    innerGlow.BackgroundTransparency = 0.88
    innerGlow.BorderSizePixel = 0
    innerGlow.Parent = root
    circleCorner(innerGlow)
    
    table.insert(Reg.Emblem, {ring = ring, innerGlow = innerGlow})
    
    -- Continuous rotation animation
    spawn(function()
        while root.Parent do
            TweenService:Create(ringGrad, TweenInfo.new(8, Enum.EasingStyle.Linear), {
                Rotation = 360
            }):Play()
            
            TweenService:Create(innerGlow, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                BackgroundTransparency = 0.92
            }):Play()
            
            wait(8)
            ringGrad.Rotation = 0
        end
    end)
    
    return root
end

-- Create main GUI with modern enhancements
local gui = Instance.new("ScreenGui")
gui.Name = "OtterClient_Premium"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

-- Protection
pcall(function() 
    if syn and syn.protect_gui then 
        syn.protect_gui(gui) 
    end 
end)

-- Top layer for overlays
local Top = Instance.new("Frame")
Top.Name = "TopLayer"
Top.Size = UDim2.new(1, 0, 1, 0)
Top.BackgroundTransparency = 1
Top.ZIndex = 10000
Top.Parent = gui

-- Enhanced root holder
local rootHolder = Instance.new("Frame")
rootHolder.Size = UDim2.fromOffset(340, 520)
rootHolder.Position = UDim2.new(0.5, -170, 0.5, -260)
rootHolder.BackgroundTransparency = 1
rootHolder.Parent = gui

-- Advanced shadow system
for i, off in ipairs(METRIC.Shadows) do 
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, off/2, 1, off/2)
    s.Position = UDim2.new(0, off, 0, off)
    s.BackgroundColor3 = N.DIM
    s.BackgroundTransparency = METRIC.ShadowAlpha[i]
    s.ZIndex = -i
    s.Parent = rootHolder
    roundCorner(s, METRIC.RRoot)
end

-- Main root frame with glassmorphism
local root = Instance.new("Frame")
root.Name = "Root"
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3 = N.BG
root.BorderSizePixel = 0
root.Parent = rootHolder
roundCorner(root, METRIC.RRoot)
stroke(root, N.LINE, 0.75, 3)

-- Apply glass effect to root
applyGlass(root, 0.02)

-- Create particle system
createParticleSystem(root)

-- Drag functionality
local dragging = false
local dragStart = nil
local startPos = nil

root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = rootHolder.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        rootHolder.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Modern header design
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, METRIC.HeaderH)
header.BackgroundColor3 = N.BG
header.BackgroundTransparency = 0.1
header.BorderSizePixel = 0
header.Parent = root

-- Header gradient
local headerGrad = Instance.new("UIGradient")
headerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 25, 45))
})
headerGrad.Rotation = 90
headerGrad.Parent = header

-- Modern accent lines
local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, -40, 0, 3)
topAccent.Position = UDim2.new(0, 20, 0, 15)
topAccent.BackgroundColor3 = N.ACCENT
topAccent.BackgroundTransparency = 0.8
topAccent.BorderSizePixel = 0
topAccent.Parent = header
roundCorner(topAccent, 2)

local topAccentGrad = Instance.new("UIGradient")
topAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 150, 255))
})
topAccentGrad.Parent = topAccent

local bottomAccent = topAccent:Clone()
bottomAccent.Position = UDim2.new(0, 20, 1, -18)
bottomAccent.BackgroundTransparency = 0.85
bottomAccent.Parent = header

-- Enhanced emblem
local emblemHold = Instance.new("Frame")
emblemHold.BackgroundTransparency = 1
emblemHold.Size = UDim2.fromOffset(48, 48)
emblemHold.Position = UDim2.new(0.5, -24, 0.5, -24)
emblemHold.Parent = header

makeOtterIcon(emblemHold, 48)

-- Modern body layout
local body = Instance.new("Frame")
body.Size = UDim2.new(1, -(METRIC.Pad * 2), 1, -METRIC.HeaderH - METRIC.Pad - METRIC.FooterH)
body.Position = UDim2.new(0, METRIC.Pad, 0, METRIC.HeaderH + METRIC.Pad)
body.BackgroundTransparency = 1
body.Parent = root

local vbox = Instance.new("UIListLayout")
vbox.FillDirection = Enum.FillDirection.Vertical
vbox.SortOrder = Enum.SortOrder.LayoutOrder
vbox.Padding = UDim.new(0, METRIC.Gap)
vbox.Parent = body

-- Enhanced categories panel with glassmorphism
local catPanel = Instance.new("Frame")
catPanel.Name = "Panel"
catPanel.LayoutOrder = 1
catPanel.Size = UDim2.new(1, 0, 0, 340)
catPanel.BackgroundColor3 = N.PANEL
catPanel.BackgroundTransparency = 0.1
catPanel.BorderSizePixel = 0
catPanel.Parent = body
roundCorner(catPanel, METRIC.RPanel)
stroke(catPanel, N.LINE, 0.7, 2)
pad(catPanel, METRIC.Pad, METRIC.Pad, METRIC.Pad, METRIC.Pad)

-- Apply glass to panel
applyGlass(catPanel, 0.05)

-- Enhanced scrolling frame
local listFrame = Instance.new("ScrollingFrame")
listFrame.Name = "Categories"
listFrame.Size = UDim2.new(1, 0, 1, 0)
listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
listFrame.ScrollBarThickness = 8
listFrame.ScrollBarImageColor3 = N.ACCENT
listFrame.ScrollBarImageTransparency = 0.3
listFrame.BackgroundTransparency = 1
listFrame.BorderSizePixel = 0
listFrame.Parent = catPanel

local listLay = Instance.new("UIListLayout")
listLay.FillDirection = Enum.FillDirection.Vertical
listLay.SortOrder = Enum.SortOrder.LayoutOrder
listLay.Padding = UDim.new(0, 12)
listLay.Parent = listFrame

-- Fetch module data from GitHub
local modulesUrl = "https://raw.githubusercontent.com/ooferowner/oofer/main/moudles.lua"
local success, moduleData = pcall(function()
    local code = HttpService:GetAsync(modulesUrl)
    return loadstring(code)()
end)
if not success then
    warn("Failed to load modules from GitHub: " .. tostring(moduleData))
    moduleData = {}
end

-- Modern categories with enhanced visuals
local categories = {
    {name = "Combat", icon = "", color = Color3.fromRGB(255, 100, 100)},
    {name = "Movement", icon = "", color = Color3.fromRGB(100, 255, 150)},
    {name = "Player", icon = "", color = Color3.fromRGB(255, 200, 100)},
    {name = "Render", icon = "", color = Color3.fromRGB(150, 100, 255)},
    {name = "Ghost", icon = "", color = Color3.fromRGB(200, 200, 200)},
    {name = "Utility", icon = "", color = Color3.fromRGB(100, 200, 255)}
}

for i, catData in ipairs(categories) do
    catData.modules = moduleData[catData.name] and #moduleData[catData.name] or 0
    local btn = Instance.new("TextButton")
    btn.Name = catData.name
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 0, METRIC.ItemH)
    btn.BackgroundColor3 = N.ITEM
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 0
    btn.Parent = listFrame
    roundCorner(btn, 16)
    stroke(btn, catData.color, 0.8, 2)
    
    -- Advanced gradient
    local btnGrad = Instance.new("UIGradient")
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 45, 70)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 40, 65)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 50, 75))
    })
    btnGrad.Rotation = 135
    btnGrad.Parent = btn
    
    -- Glass overlay
    applyGlass(btn, 0.08)
    
    -- Modern icon
    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 16, 0.5, -15)
    icon.Text = catData.icon
    icon.TextSize = 20
    icon.TextColor3 = catData.color
    icon.Font = Enum.Font.GothamBold
    icon.Parent = btn
    
    -- Category name with better typography
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, -140, 1, -8)
    lbl.Position = UDim2.new(0, 55, 0, 4)
    lbl.Text = catData.name
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = N.TEXT
    lbl.Parent = btn
    
    -- Enhanced module count badge
    local badge = Instance.new("Frame")
    badge.Size = UDim2.new(0, 40, 0, 24)
    badge.Position = UDim2.new(1, -50, 0.5, -12)
    badge.BackgroundColor3 = catData.color
    badge.BackgroundTransparency = 0.85
    badge.BorderSizePixel = 0
    badge.Parent = btn
    roundCorner(badge, 12)
    stroke(badge, catData.color, 0.6, 1)
    
    local badgeText = Instance.new("TextLabel")
    badgeText.BackgroundTransparency = 1
    badgeText.Size = UDim2.new(1, 0, 1, 0)
    badgeText.Text = tostring(catData.modules)
    badgeText.TextColor3 = catData.color
    badgeText.TextSize = 13
    badgeText.Font = Enum.Font.GothamBold
    badgeText.Parent = badge
    
    -- Enhanced hover effects with modern animations
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, 6, 0, METRIC.ItemH + 4),
            BackgroundTransparency = 0.05
        }):Play()
        
        TweenService:Create(icon, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            TextSize = 24,
            Rotation = 5
        }):Play()
        
        TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            TextSize = 19
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, 0, 0, METRIC.ItemH),
            BackgroundTransparency = 0.15
        }):Play()
        
        TweenService:Create(icon, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            TextSize = 20,
            Rotation = 0
        }):Play()
        
        TweenService:Create(lbl, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            TextSize = 18
        }):Play()
    end)
    
    Items[catData.name] = {btn = btn, active = false, color = catData.color}
    table.insert(ButtonRoots, btn)
end

-- Modern footer with premium design
local footer = Instance.new("Frame")
footer.LayoutOrder = 2
footer.Size = UDim2.new(1, 0, 0, METRIC.FooterH)
footer.BackgroundTransparency = 1
footer.Parent = body

local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 1, 0)
bar.BackgroundColor3 = N.PANEL
bar.BackgroundTransparency = 0.1
bar.BorderSizePixel = 0
bar.Parent = footer
roundCorner(bar, METRIC.RPanel)
stroke(bar, N.LINE, 0.75, 2)
pad(bar, METRIC.Pad, METRIC.Pad, METRIC.Pad, METRIC.Pad)

-- Apply glass to footer
applyGlass(bar, 0.05)

-- Enhanced settings button
local settingsBtn = Instance.new("TextButton")
settingsBtn.BackgroundTransparency = 1
settingsBtn.AutoButtonColor = false
settingsBtn.Text = ""
settingsBtn.Size = UDim2.new(0, 45, 0, 45)
settingsBtn.Position = UDim2.new(0, 5, 0.5, -22.5)
settingsBtn.Parent = bar
table.insert(ButtonRoots, settingsBtn)

local settingsCircle = Instance.new("Frame")
settingsCircle.Size = UDim2.new(0, 45, 0, 45)
settingsCircle.Position = UDim2.new(0, 0, 0, 0)
settingsCircle.BackgroundColor3 = N.ITEM
settingsCircle.BackgroundTransparency = 0.2
settingsCircle.BorderSizePixel = 0
settingsCircle.Parent = settingsBtn
roundCorner(settingsCircle, 22.5)
stroke(settingsCircle, N.ACCENT, 0.6, 2)

-- Settings gear with modern design
local gear = Instance.new("TextLabel")
gear.BackgroundTransparency = 1
gear.Size = UDim2.new(0, 24, 0, 24)
gear.Position = UDim2.new(0.5, -12, 0.5, -12)
gear.Text = ""
gear.TextSize = 20
gear.TextColor3 = N.ACCENT
gear.Font = Enum.Font.GothamBold
gear.Parent = settingsCircle

-- Gear animation
spawn(function()
    while gear.Parent do
        TweenService:Create(gear, TweenInfo.new(6, Enum.EasingStyle.Linear), {
            Rotation = 360
        }):Play()
        wait(6)
        gear.Rotation = 0
    end
end)

-- Enhanced themes button
local themesBtn = Instance.new("TextButton")
themesBtn.Size = UDim2.new(0, 140, 0, 38)
themesBtn.Position = UDim2.new(1, -140, 0, 12)
themesBtn.BackgroundColor3 = N.ITEM
themesBtn.BackgroundTransparency = 0.2
themesBtn.AutoButtonColor = false
themesBtn.Text = ""
themesBtn.BorderSizePixel = 0
themesBtn.Parent = bar
roundCorner(themesBtn, 19)
stroke(themesBtn, N.ACCENT, 0.6, 2)

-- Apply glass to themes button
applyGlass(themesBtn, 0.1)

local themesText = Instance.new("TextLabel")
themesText.BackgroundTransparency = 1
themesText.Size = UDim2.new(1, -10, 1, 0)
themesText.Position = UDim2.new(0, 5, 0, 0)
themesText.Text = "THEMES"
themesText.Font = Enum.Font.GothamBold
themesText.TextSize = 15
themesText.TextColor3 = N.TEXT
themesText.Parent = themesBtn

table.insert(ButtonRoots, themesBtn)

-- Enhanced hover effects for footer
settingsBtn.MouseEnter:Connect(function()
    TweenService:Create(settingsCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 50, 0, 50),
        BackgroundTransparency = 0.05
    }):Play()
    
    TweenService:Create(gear, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        TextSize = 22
    }):Play()
end)

settingsBtn.MouseLeave:Connect(function()
    TweenService:Create(settingsCircle, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 45, 0, 45),
        BackgroundTransparency = 0.2
    }):Play()
    
    TweenService:Create(gear, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        TextSize = 20
    }):Play()
end)

themesBtn.MouseEnter:Connect(function()
    TweenService:Create(themesBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 148, 0, 42),
        Position = UDim2.new(1, -148, 0, 10),
        BackgroundTransparency = 0.05
    }):Play()
    
    TweenService:Create(themesText, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        TextSize = 16
    }):Play()
end)

themesBtn.MouseLeave:Connect(function()
    TweenService:Create(themesBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 140, 0, 38),
        Position = UDim2.new(1, -140, 0, 12),
        BackgroundTransparency = 0.2
    }):Play()
    
    TweenService:Create(themesText, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        TextSize = 15
    }):Play()
end)

-- Epic startup animation sequence
spawn(function()
    wait(0.1)
    
    -- Initial hidden state
    rootHolder.Size = UDim2.fromOffset(0, 0)
    rootHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    rootHolder.Rotation = -15
    
    -- Epic entrance with rotation and scale
    TweenService:Create(rootHolder, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(340, 520),
        Position = UDim2.new(0.5, -170, 0.5, -260),
        Rotation = 0
    }):Play()
    
    wait(0.4)
    
    -- Staggered category animations with bounce
    for i, catData in ipairs(categories) do
        local item = Items[catData.name]
        if item and item.btn then
            item.btn.Position = UDim2.new(0, -400, 0, (i-1) * (METRIC.ItemH + 12))
            item.btn.BackgroundTransparency = 1
            item.btn.Rotation = -10
            
            TweenService:Create(item.btn, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 0.15,
                Rotation = 0
            }):Play()
            
            wait(0.12)
        end
    end
    
    wait(0.3)
    
    -- Footer slide-up animation
    footer.Position = UDim2.new(0, 0, 1, 150)
    TweenService:Create(footer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    -- Particle burst effect
    wait(0.2)
    for i = 1, 8 do
        local burst = Instance.new("Frame")
        burst.Size = UDim2.fromOffset(4, 4)
        burst.Position = UDim2.new(0.5, math.random(-50, 50), 0.5, math.random(-50, 50))
        burst.BackgroundColor3 = N.ACCENT
        burst.BorderSizePixel = 0
        burst.Parent = root
        circleCorner(burst)
        
        TweenService:Create(burst, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, math.random(-200, 200), 0.5, math.random(-200, 200))
        }):Play()
        
        spawn(function()
            wait(1.5)
            if burst.Parent then burst:Destroy() end
        end)
    end
end)

-- Enhanced module functionality
local function handleModuleToggle(category, moduleName, enabled)
    if category == "Movement" then
        if moduleName == "Speed" and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = enabled and 60 or 16
        elseif moduleName == "HighJump" and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = enabled and 150 or 50
        elseif moduleName == "Fly" then
            print("Fly module:", enabled and "ENABLED" or "DISABLED")
        end
    elseif category == "Render" then
        if moduleName == "Fullbright" then
            if enabled then
                Lighting.Brightness = 8
                Lighting.FogEnd = 2000000
            else
                Lighting.Brightness = 1
                Lighting.FogEnd = 100000
            end
        elseif moduleName == "ESP" then
            print("ESP module:", enabled and "ENABLED" or "DISABLED")
        end
    elseif category == "Combat" then
        if moduleName == "KillAura" then
            print("KillAura module:", enabled and "ENABLED" or "DISABLED")
        elseif moduleName == "Reach" then
            print("Reach module:", enabled and "ENABLED" or "DISABLED")
        end
    elseif category == "Utility" and moduleName == "AnticheatBypass" then
        local function createClone()
            repeat task.wait() until player.Character ~= nil
            if player.Character.Humanoid.Health <= 0 then
                return
            end
            player.Character.Archivable = true
            local oldChar = player.Character
            local clone = player.Character:Clone()
            clone.Parent = workspace
            clone:SetAttribute("isClone", true)
            clone.Humanoid.DisplayName = " "
            
            for i,v in next, clone:GetDescendants() do
                for i2, v2 in next, player.Character:GetDescendants() do
                    if v2:IsA('Decal') then
                        v2.Transparency = 1
                    end
                    if (v:IsA("Part") or v:IsA("BasePart")) and (v2:IsA("Part") or v2:IsA("BasePart")) then
                        local constraint = Instance.new("NoCollisionConstraint", v)
                        constraint.Part0 = v
                        constraint.Part1 = v2
                        v2.Transparency = 1
                    end
                end
            end

            oldChar.PrimaryPart.Transparency = 0.5
            pcall(function()
                oldChar.Head.face.Transparency = 1
            end)
            return clone, oldChar
        end

        local function modifyCharacter(character)
            task.wait()
            clone, oldChar = createClone()
            local cam = workspace.CurrentCamera

            if clone then
                oldChar = player.Character
                cam.CameraSubject = clone
                player.Character = clone

                clone.Animate.Enabled = false
                clone.Animate.Enabled = true

                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {character, clone}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                local lastTP = tick()
                table.insert(events, RunService.Heartbeat:Connect(function(delta)
                    if not clone or not clone:FindFirstChild('PrimaryPart') then
                        return end
                    
                    if not character or not character:FindFirstChild('PrimaryPart') then
                        return end
                    
                    pcall(function()
                        if not isnetworkowner(character.PrimaryPart) then
                            clone.PrimaryPart.CFrame = character.PrimaryPart.CFrame
                        else
                            if (tick() - lastTP) > 0.51 then
                                TweenService:Create(character.PrimaryPart, TweenInfo.new(0.65), {CFrame = clone.PrimaryPart.CFrame}):Play()
                                lastTP = tick()
                            end

                            character.PrimaryPart.CFrame = CFrame.new(character.PrimaryPart.CFrame.X, clone.PrimaryPart.CFrame.Y, character.PrimaryPart.CFrame.Z)
                            character.PrimaryPart.Velocity = Vector3.new(0, clone.PrimaryPart.Velocity.Y, 0)
                        end
                    end)
                end))
            end
        end

        if enabled then
            charAdded = player.CharacterAdded:Connect(function(character)
                repeat task.wait(1) until character
                if character:GetAttribute("isClone") then return end
                
                modifyCharacter(character)
            end)

            if player.Character then
                modifyCharacter(player.Character)
            end
        else
            if charAdded then
                charAdded:Disconnect()
            end

            for i,v in pairs(events) do
                v:Disconnect()
            end
            events = {}

            if oldChar then
                for i,v in pairs(oldChar:GetChildren()) do
                    pcall(function()
                        v.Transparency = 0
                    end)
                end
                if player.Character then
                    player.Character.PrimaryPart.Transparency = 1
                end
                player.Character = oldChar

                workspace.CurrentCamera.CameraSubject = player.Character
                if clone then
                    clone:Destroy()
                end
            end
        end
    end
    
    print("[OTTER] " .. category .. " -> " .. moduleName .. ":", enabled and "ON" or "OFF")
end

-- Enhanced twin panel system with modern design
local function buildTwinPanel(titleText)
    local scr = Instance.new("ScreenGui")
    scr.Name = "TwinPanel_" .. titleText
    scr.ResetOnSpawn = false
    scr.IgnoreGuiInset = true
    scr.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    scr.Parent = parentGui
    
    pcall(function() 
        if syn and syn.protect_gui then 
            syn.protect_gui(scr) 
        end 
    end)
    
    local size = rootHolder.AbsoluteSize
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.fromOffset(size.X, size.Y)
    holder.Parent = scr
    
    -- Advanced shadow system
    for i, off in ipairs(METRIC.Shadows) do 
        local s = Instance.new("Frame")
        s.Size = UDim2.new(1, off/2, 1, off/2)
        s.Position = UDim2.new(0, off, 0, off)
        s.BackgroundColor3 = N.DIM
        s.BackgroundTransparency = METRIC.ShadowAlpha[i]
        s.ZIndex = -i
        s.Parent = holder
        roundCorner(s, METRIC.RRoot)
    end
    
    local rootP = Instance.new("Frame")
    rootP.Name = "TwinRoot"
    rootP.Size = UDim2.new(1, 0, 1, 0)
    rootP.BackgroundColor3 = N.BG
    rootP.BackgroundTransparency = 0.05
    rootP.BorderSizePixel = 0
    rootP.Parent = holder
    roundCorner(rootP, METRIC.RRoot)
    stroke(rootP, N.LINE, 0.7, 3)
    
    -- Apply glassmorphism to twin panel
    applyGlass(rootP, 0.03)
    
    -- Create particle system for twin panel
    createParticleSystem(rootP)
    
    -- Modern twin header
    local headerP = Instance.new("Frame")
    headerP.Size = UDim2.new(1, 0, 0, METRIC.HeaderH)
    headerP.BackgroundColor3 = N.BG
    headerP.BackgroundTransparency = 0.2
    headerP.BorderSizePixel = 0
    headerP.Parent = rootP
    
    local headerGradP = Instance.new("UIGradient")
    headerGradP.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 25, 45))
    })
    headerGradP.Rotation = 90
    headerGradP.Parent = headerP
    
    -- Enhanced title design with category color
    local categoryData = nil
    for _, cat in ipairs(categories) do
        if cat.name == titleText then
            categoryData = cat
            break
        end
    end
    
    local titleAccent = Instance.new("Frame")
    titleAccent.Size = UDim2.new(0, 8, 0, 35)
    titleAccent.Position = UDim2.new(0, METRIC.Pad, 0.5, -17.5)
    titleAccent.BackgroundColor3 = categoryData and categoryData.color or N.ACCENT
    titleAccent.BorderSizePixel = 0
    titleAccent.Parent = headerP
    roundCorner(titleAccent, 4)
    
    local accentGrad = Instance.new("UIGradient")
    accentGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, categoryData and categoryData.color or N.ACCENT),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    })
    accentGrad.Rotation = 90
    accentGrad.Parent = titleAccent
    
    -- Modern title capsule
    local titleCapsule = Instance.new("Frame")
    titleCapsule.Size = UDim2.new(0, 200, 0, 35)
    titleCapsule.Position = UDim2.new(0, METRIC.Pad + 20, 0.5, -17.5)
    titleCapsule.BackgroundColor3 = N.ITEM
    titleCapsule.BackgroundTransparency = 0.15
    titleCapsule.BorderSizePixel = 0
    titleCapsule.Parent = headerP
    roundCorner(titleCapsule, 17.5)
    stroke(titleCapsule, categoryData and categoryData.color or N.ACCENT, 0.6, 2)
    
    applyGlass(titleCapsule, 0.1)
    
    local titleIcon = Instance.new("TextLabel")
    titleIcon.BackgroundTransparency = 1
    titleIcon.Size = UDim2.new(0, 30, 1, 0)
    titleIcon.Position = UDim2.new(0, 15, 0, 0)
    titleIcon.Text = categoryData and categoryData.icon or ""
    titleIcon.TextSize = 18
    titleIcon.TextColor3 = categoryData and categoryData.color or N.ACCENT
    titleIcon.Font = Enum.Font.GothamBold
    titleIcon.Parent = titleCapsule
    
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 45, 0, 0)
    titleLbl.Text = string.upper(titleText)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 16
    titleLbl.TextColor3 = N.TEXT
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = titleCapsule
    
    -- Enhanced scrolling body
    local scBody = Instance.new("ScrollingFrame")
    scBody.Name = "ScrollBody"
    scBody.Size = UDim2.new(1, -(METRIC.Pad * 2), 1, -METRIC.HeaderH - METRIC.Pad - 20)
    scBody.Position = UDim2.new(0, METRIC.Pad, 0, METRIC.HeaderH + METRIC.Pad)
    scBody.BackgroundColor3 = N.PANEL
    scBody.BackgroundTransparency = 0.15
    scBody.BorderSizePixel = 0
    scBody.ScrollBarThickness = 10
    scBody.ScrollBarImageColor3 = categoryData and categoryData.color or N.ACCENT
    scBody.ScrollBarImageTransparency = 0.4
    scBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scBody.Parent = rootP
    roundCorner(scBody, METRIC.RPanel)
    stroke(scBody, N.LINE, 0.7, 2)
    pad(scBody, METRIC.Pad, METRIC.Pad, METRIC.Pad, METRIC.Pad)
    
    applyGlass(scBody, 0.08)
    
    local stack = Instance.new("UIListLayout")
    stack.FillDirection = Enum.FillDirection.Vertical
    stack.SortOrder = Enum.SortOrder.LayoutOrder
    stack.Padding = UDim.new(0, 14)
    stack.Parent = scBody
    
    local modules = moduleData[titleText] or {}
    
    for i, module in ipairs(modules) do
        local moduleFrame = Instance.new("Frame")
        moduleFrame.Size = UDim2.new(1, 0, 0, 52)
        moduleFrame.BackgroundColor3 = N.ITEM
        moduleFrame.BackgroundTransparency = 0.1
        moduleFrame.BorderSizePixel = 0
        moduleFrame.Parent = scBody
        roundCorner(moduleFrame, 14)
        stroke(moduleFrame, categoryData and categoryData.color or N.ACCENT, 0.85, 1)
        
        applyGlass(moduleFrame, 0.12)
        
        local moduleGrad = Instance.new("UIGradient")
        moduleGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 45, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 50, 75))
        })
        moduleGrad.Rotation = 90
        moduleGrad.Parent = moduleFrame
        
        local moduleName = Instance.new("TextLabel")
        moduleName.BackgroundTransparency = 1
        moduleName.Size = UDim2.new(0, 200, 0, 22)
        moduleName.Position = UDim2.new(0, 16, 0, 6)
        moduleName.Text = module.name
        moduleName.TextColor3 = N.TEXT
        moduleName.TextSize = 16
        moduleName.Font = Enum.Font.GothamBold
        moduleName.TextXAlignment = Enum.TextXAlignment.Left
        moduleName.Parent = moduleFrame
        
        local moduleDesc = Instance.new("TextLabel")
        moduleDesc.BackgroundTransparency = 1
        moduleDesc.Size = UDim2.new(0, 200, 0, 16)
        moduleDesc.Position = UDim2.new(0, 16, 0, 28)
        moduleDesc.Text = module.desc
        moduleDesc.TextColor3 = N.SUBTEXT
        moduleDesc.TextSize = 12
        moduleDesc.Font = Enum.Font.Gotham
        moduleDesc.TextXAlignment = Enum.TextXAlignment.Left
        moduleDesc.Parent = moduleFrame
        
        -- Keybind display
        local keybind = Instance.new("Frame")
        keybind.Size = UDim2.new(0, 35, 0, 18)
        keybind.Position = UDim2.new(1, -110, 0, 6)
        keybind.BackgroundColor3 = categoryData and categoryData.color or N.ACCENT
        keybind.BackgroundTransparency = 0.8
        keybind.BorderSizePixel = 0
        keybind.Parent = moduleFrame
        roundCorner(keybind, 9)
        
        local keybindText = Instance.new("TextLabel")
        keybindText.BackgroundTransparency = 1
        keybindText.Size = UDim2.new(1, 0, 1, 0)
        keybindText.Text = module.keybind or "?"
        keybindText.TextColor3 = categoryData and categoryData.color or N.ACCENT
        keybindText.TextSize = 10
        keybindText.Font = Enum.Font.GothamBold
        keybindText.Parent = keybind
        
        -- Enhanced toggle switch
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 65, 0, 26)
        toggle.Position = UDim2.new(1, -75, 0.5, -13)
        toggle.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
        toggle.BackgroundTransparency = 0.1
        toggle.Text = "OFF"
        toggle.TextColor3 = N.SUBTEXT
        toggle.TextSize = 12
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.AutoButtonColor = false
        toggle.Parent = moduleFrame
        roundCorner(toggle, 13)
        stroke(toggle, N.LINE, 0.7, 1)
        
        local enabled = false
        
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            
            local targetColor = enabled and (categoryData and categoryData.color or N.ACCENT) or Color3.fromRGB(40, 50, 70)
            local targetTextColor = enabled and Color3.fromRGB(255, 255, 255) or N.SUBTEXT
            local targetText = enabled and "ON" or "OFF"
            local targetTransparency = enabled and 0.05 or 0.1
            
            TweenService:Create(toggle, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
                BackgroundColor3 = targetColor,
                BackgroundTransparency = targetTransparency
            }):Play()
            
            TweenService:Create(toggle, TweenInfo.new(0.2), {
                TextColor3 = targetTextColor
            }):Play()
            
            toggle.Text = targetText
            
            -- Module activation glow effect
            if enabled then
                local activationRing = Instance.new("Frame")
                activationRing.Size = UDim2.new(1, 8, 1, 8)
                activationRing.Position = UDim2.new(0, -4, 0, -4)
                activationRing.BackgroundColor3 = categoryData and categoryData.color or N.ACCENT
                activationRing.BackgroundTransparency = 0.7
                activationRing.BorderSizePixel = 0
                activationRing.ZIndex = -1
                activationRing.Parent = moduleFrame
                roundCorner(activationRing, 18)
                
                TweenService:Create(activationRing, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {
                    BackgroundTransparency = 0.95,
                    Size = UDim2.new(1, 16, 1, 16),
                    Position = UDim2.new(0, -8, 0, -8)
                }):Play()
                
                spawn(function()
                    wait(0.8)
                    if activationRing.Parent then
                        activationRing:Destroy()
                    end
                end)
                
                -- Screen flash effect
                local flash = Instance.new("Frame")
                flash.Size = UDim2.new(1, 0, 1, 0)
                flash.BackgroundColor3 = categoryData and categoryData.color or N.ACCENT
                flash.BackgroundTransparency = 0.92
                flash.BorderSizePixel = 0
                flash.ZIndex = 1000
                flash.Parent = rootP
                
                TweenService:Create(flash, TweenInfo.new(0.3), {
                    BackgroundTransparency = 1
                }):Play()
                
                spawn(function()
                    wait(0.3)
                    if flash.Parent then flash:Destroy() end
                end)
            end
            
            handleModuleToggle(titleText, module.name, enabled)
        end)
        
        -- Enhanced hover effects
        moduleFrame.MouseEnter:Connect(function()
            TweenService:Create(moduleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 6, 0, 56),
                BackgroundTransparency = 0.05
            }):Play()
            
            TweenService:Create(moduleName, TweenInfo.new(0.25), {
                TextSize = 17
            }):Play()
        end)
        
        moduleFrame.MouseLeave:Connect(function()
            TweenService:Create(moduleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundTransparency = 0.1
            }):Play()
            
            TweenService:Create(moduleName, TweenInfo.new(0.25), {
                TextSize = 16
            }):Play()
        end)
    end
    
    Twin.map[titleText] = {
        gui = scr, 
        holder = holder, 
        root = rootP,
        category = categoryData
    }
    
    return Twin.map[titleText]
end

-- Twin panel management with enhanced animations
local function mainAbs() 
    local p = rootHolder.AbsolutePosition 
    local s = rootHolder.AbsoluteSize 
    return p, s 
end

local function layoutActivePanels()
    local p, s = mainAbs()
    local baseX = p.X + s.X + METRIC.TwinGap
    local y = p.Y
    
    for idx, catName in ipairs(Twin.activeOrder) do 
        local P = Twin.map[catName]
        if P and P.holder.Visible then 
            local x = baseX + (idx-1) * (s.X + METRIC.TwinGap)
            P.holder.Position = UDim2.fromOffset(x, y)
            P.holder.Size = UDim2.fromOffset(s.X, s.Y)
        end 
    end
end

local function setButtonActive(name, active)
    local it = Items[name]
    if not it then return end
    it.active = active
    
    if active then
        TweenService:Create(it.btn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0.05,
            Size = UDim2.new(1, 8, 0, METRIC.ItemH + 6)
        }):Play()
        
        -- Add active glow
        local glow = Instance.new("Frame")
        glow.Name = "ActiveGlow"
        glow.Size = UDim2.new(1, 12, 1, 12)
        glow.Position = UDim2.new(0, -6, 0, -6)
        glow.BackgroundColor3 = it.color
        glow.BackgroundTransparency = 0.8
        glow.BorderSizePixel = 0
        glow.ZIndex = -1
        glow.Parent = it.btn
        roundCorner(glow, 22)
        
        it.glow = glow
    else
        TweenService:Create(it.btn, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            BackgroundTransparency = 0.15,
            Size = UDim2.new(1, 0, 0, METRIC.ItemH)
        }):Play()
        
        if it.glow then
            TweenService:Create(it.glow, TweenInfo.new(0.4), {
                BackgroundTransparency = 1
            }):Play()
            
            spawn(function()
                wait(0.4)
                if it.glow and it.glow.Parent then
                    it.glow:Destroy()
                    it.glow = nil
                end
            end)
        end
    end
end

local function addActive(name) 
    for _, n in ipairs(Twin.activeOrder) do 
        if n == name then return end 
    end 
    table.insert(Twin.activeOrder, name) 
end

local function removeActive(name) 
    for i, n in ipairs(Twin.activeOrder) do 
        if n == name then 
            table.remove(Twin.activeOrder, i)
            return 
        end 
    end 
end

local function showTwin(name)
    local P = Twin.map[name]
    if not P then 
        P = buildTwinPanel(name)
    end
    
    addActive(name)
    local p, s = mainAbs()
    local idx = 1
    for i, n in ipairs(Twin.activeOrder) do 
        if n == name then 
            idx = i 
            break 
        end 
    end
    
    local startX = p.X + s.X + METRIC.TwinGap + (idx-1) * (s.X + METRIC.TwinGap)
    
    P.holder.Visible = true
    P.holder.Position = UDim2.fromOffset(startX + 50, p.Y - 30)
    P.holder.Size = UDim2.fromOffset(s.X * 0.8, s.Y * 0.8)
    P.holder.Rotation = 10
    
    -- Epic twin panel entrance
    TweenService:Create(P.holder, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(startX, p.Y),
        Size = UDim2.fromOffset(s.X, s.Y),
        Rotation = 0
    }):Play()
    
    setButtonActive(name, true)
    layoutActivePanels()
end

local function hideTwin(name)
    local P = Twin.map[name]
    if not P or not P.holder.Visible then return end
    
    local cur = P.holder.Position
    
    TweenService:Create(P.holder, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Position = UDim2.fromOffset(cur.X.Offset + 50, cur.Y.Offset - 30),
        Size = UDim2.new(0.8, 0, 0.8, 0),
        Rotation = -10
    }):Play()
    
    spawn(function()
        wait(0.4)
        P.holder.Visible = false
        removeActive(name)
        setButtonActive(name, false)
        layoutActivePanels()
    end)
end

-- Connect category buttons
for name, it in pairs(Items) do 
    it.btn.MouseButton1Click:Connect(function() 
        if it.active then 
            hideTwin(name) 
        else 
            showTwin(name) 
        end 
    end) 
end

-- Continuous layout updates
RunService.RenderStepped:Connect(function() 
    if #Twin.activeOrder > 0 then 
        layoutActivePanels() 
    end 
end)

-- Enhanced theme system with dynamic colors
spawn(function()
    while gui.Parent do
        -- Rotate through theme colors
        for _, scheme in ipairs(SCHEMES) do
            -- Gradually shift accent colors
            for _, emblem in ipairs(Reg.Emblem) do
                if emblem.ring and emblem.ring.Parent then
                    local grad = emblem.ring:FindFirstChildOfClass("UIGradient")
                    if grad then
                        TweenService:Create(grad, TweenInfo.new(3, Enum.EasingStyle.Sine), {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, scheme.col),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                ColorSequenceKeypoint.new(1, scheme.col)
                            })
                        }):Play()
                    end
                end
            end
            
            wait(8)
        end
    end
end)

-- Enhanced particle animation
spawn(function()
    while gui.Parent do
        for _, particle in ipairs(Reg.Particles) do
            if particle.Parent then
                -- Gentle floating animation
                TweenService:Create(particle, TweenInfo.new(
                    math.random(3, 8),
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true
                ), {
                    BackgroundTransparency = math.random(80, 95) / 100,
                    Rotation = math.random(-360, 360)
                }):Play()
            end
        end
        wait(1)
    end
end)

-- Right Shift toggle with enhanced animation
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local isVisible = rootHolder.Visible
        
        if isVisible then
            -- Hide with spin effect
            TweenService:Create(rootHolder, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Rotation = -90
            }):Play()
            
            spawn(function()
                wait(0.5)
                rootHolder.Visible = false
                rootHolder.Rotation = 0
            end)
        else
            -- Show with dramatic entrance
            rootHolder.Visible = true
            rootHolder.Size = UDim2.fromOffset(0, 0)
            rootHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
            rootHolder.Rotation = 90
            
            TweenService:Create(rootHolder, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(340, 520),
                Position = UDim2.new(0.5, -170, 0.5, -260),
                Rotation = 0
            }):Play()
        end
        
        -- Hide all twin panels when main GUI is hidden
        if isVisible then
            for _, P in pairs(Twin.map) do
                if P.holder.Visible then
                    P.holder.Visible = false
                end
            end
            Twin.activeOrder = {}
            for name, item in pairs(Items) do
                setButtonActive(name, false)
            end
        end
    end
end)

-- Enhanced notification system
local function showNotification(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(250, 50)
    notif.Position = UDim2.new(1, -270, 0, 20)
    notif.BackgroundColor3 = color or N.ACCENT
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.Parent = Top
    roundCorner(notif, 25)
    stroke(notif, Color3.fromRGB(255, 255, 255), 0.8, 2)
    
    applyGlass(notif, 0.05)
    
    local notifText = Instance.new("TextLabel")
    notifText.BackgroundTransparency = 1
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.Text = text
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.TextSize = 14
    notifText.Font = Enum.Font.GothamBold
    notifText.TextWrapped = true
    notifText.Parent = notif
    
    -- Slide in animation
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -270, 0, 20)
    }):Play()
    
    -- Auto hide after 3 seconds
    spawn(function()
        wait(3)
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(notifText, TweenInfo.new(0.3), {
            TextTransparency = 1
        }):Play()
        
        wait(0.3)
        if notif.Parent then notif:Destroy() end
    end)
end

-- Connect theme button
themesBtn.MouseButton1Click:Connect(function()
    local currentScheme = SCHEMES[math.random(1, #SCHEMES)]
    N.ACCENT = currentScheme.col
    
    showNotification("Theme changed to " .. currentScheme.name, currentScheme.col)
    
    -- Apply new theme colors
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant:IsA("UIStroke") and descendant.Color == N.LINE then
            TweenService:Create(descendant, TweenInfo.new(0.5), {
                Color = currentScheme.col
            }):Play()
        end
    end
end)

-- Connect settings button
settingsBtn.MouseButton1Click:Connect(function()
    showNotification("Settings panel coming soon!", N.ACCENT)
end)

-- Final initialization with enhanced effects
spawn(function()
    wait(0.2)
    rootHolder.Visible = false
    wait(0.1)
    rootHolder.Visible = true
    
    -- Success notification
    wait(2)
    showNotification("OTTER CLIENT LOADED SUCCESSFULLY", Color3.fromRGB(100, 255, 150))
    
    print("")
    print(" OTTER CLIENT - Premium Modern GUI")
    print("")
    print(" Enhanced with glassmorphism effects")
    print(" Dynamic particle system")
    print(" Advanced gradient animations")
    print(" Smooth transitions and interactions")
    print("")
    print(" CONTROLS:")
    print(" Click categories to open module panels")
    print(" Right Shift to toggle GUI visibility")
    print(" Hover for interactive animations")
    print("")
end)
