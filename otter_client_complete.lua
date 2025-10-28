-- OTTER CLIENT - Complete All-in-One Script
-- No GitHub Required - Everything Built-in
-- Version: 2.0.0 - Ultimate Edition

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- Enhanced parent detection
local parentGui = CoreGui
pcall(function() 
    if typeof(gethui) == "function" then 
        parentGui = gethui() 
    elseif syn and syn.protect_gui then
        parentGui = CoreGui
    elseif getgenv and getgenv().gethui then
        parentGui = getgenv().gethui()
    elseif KRNL_LOADED then
        parentGui = gethui()
    end
end)

-- Mobile detection
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- Enhanced color palettes with more themes
local ColorPalettes = {
    ElectricBlue = {
        BG = Color3.fromRGB(3, 7, 16), PANEL = Color3.fromRGB(9, 14, 26), ITEM = Color3.fromRGB(14, 21, 36),
        HOVER = Color3.fromRGB(28, 42, 68), TEXT = Color3.fromRGB(0, 191, 255), SUBTEXT = Color3.fromRGB(135, 150, 175),
        LINE = Color3.fromRGB(45, 85, 160), GLOW = Color3.fromRGB(65, 130, 205), DIM = Color3.fromRGB(1, 3, 12),
        ACCENT = Color3.fromRGB(0, 191, 255), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(85, 150, 205),
        BLOOM = Color3.fromRGB(115, 195, 250), IRIDESCENT = Color3.fromRGB(200, 200, 255), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    Dark = {
        BG = Color3.fromRGB(18, 18, 18), PANEL = Color3.fromRGB(28, 28, 28), ITEM = Color3.fromRGB(38, 38, 38),
        HOVER = Color3.fromRGB(48, 48, 48), TEXT = Color3.fromRGB(255, 255, 255), SUBTEXT = Color3.fromRGB(180, 180, 180),
        LINE = Color3.fromRGB(80, 80, 80), GLOW = Color3.fromRGB(100, 100, 100), DIM = Color3.fromRGB(8, 8, 8),
        ACCENT = Color3.fromRGB(52, 152, 219), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(80, 80, 80),
        BLOOM = Color3.fromRGB(120, 120, 120), IRIDESCENT = Color3.fromRGB(120, 120, 180), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    NeonGreen = {
        BG = Color3.fromRGB(5, 10, 5), PANEL = Color3.fromRGB(10, 20, 10), ITEM = Color3.fromRGB(15, 30, 15),
        HOVER = Color3.fromRGB(25, 50, 25), TEXT = Color3.fromRGB(0, 255, 0), SUBTEXT = Color3.fromRGB(100, 200, 100),
        LINE = Color3.fromRGB(50, 150, 50), GLOW = Color3.fromRGB(100, 255, 100), DIM = Color3.fromRGB(2, 5, 2),
        ACCENT = Color3.fromRGB(0, 255, 0), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(100, 255, 100),
        BLOOM = Color3.fromRGB(150, 255, 150), IRIDESCENT = Color3.fromRGB(200, 255, 200), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    PurpleHaze = {
        BG = Color3.fromRGB(10, 5, 15), PANEL = Color3.fromRGB(20, 10, 30), ITEM = Color3.fromRGB(30, 15, 45),
        HOVER = Color3.fromRGB(50, 25, 75), TEXT = Color3.fromRGB(200, 0, 255), SUBTEXT = Color3.fromRGB(150, 100, 200),
        LINE = Color3.fromRGB(100, 50, 150), GLOW = Color3.fromRGB(255, 100, 255), DIM = Color3.fromRGB(5, 2, 8),
        ACCENT = Color3.fromRGB(200, 0, 255), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(200, 100, 255),
        BLOOM = Color3.fromRGB(255, 150, 255), IRIDESCENT = Color3.fromRGB(255, 200, 255), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    FireRed = {
        BG = Color3.fromRGB(15, 5, 5), PANEL = Color3.fromRGB(25, 10, 10), ITEM = Color3.fromRGB(35, 15, 15),
        HOVER = Color3.fromRGB(55, 25, 25), TEXT = Color3.fromRGB(255, 50, 0), SUBTEXT = Color3.fromRGB(200, 100, 80),
        LINE = Color3.fromRGB(150, 50, 30), GLOW = Color3.fromRGB(255, 100, 50), DIM = Color3.fromRGB(7, 2, 2),
        ACCENT = Color3.fromRGB(255, 50, 0), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(255, 100, 50),
        BLOOM = Color3.fromRGB(255, 150, 100), IRIDESCENT = Color3.fromRGB(255, 200, 150), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    OceanBlue = {
        BG = Color3.fromRGB(5, 15, 25), PANEL = Color3.fromRGB(10, 25, 40), ITEM = Color3.fromRGB(15, 35, 55),
        HOVER = Color3.fromRGB(25, 55, 80), TEXT = Color3.fromRGB(0, 150, 255), SUBTEXT = Color3.fromRGB(100, 180, 220),
        LINE = Color3.fromRGB(50, 120, 180), GLOW = Color3.fromRGB(100, 200, 255), DIM = Color3.fromRGB(2, 7, 12),
        ACCENT = Color3.fromRGB(0, 150, 255), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(100, 200, 255),
        BLOOM = Color3.fromRGB(150, 220, 255), IRIDESCENT = Color3.fromRGB(200, 230, 255), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    SunsetOrange = {
        BG = Color3.fromRGB(20, 10, 5), PANEL = Color3.fromRGB(30, 15, 10), ITEM = Color3.fromRGB(40, 20, 15),
        HOVER = Color3.fromRGB(60, 35, 25), TEXT = Color3.fromRGB(255, 140, 0), SUBTEXT = Color3.fromRGB(220, 160, 100),
        LINE = Color3.fromRGB(180, 100, 50), GLOW = Color3.fromRGB(255, 180, 80), DIM = Color3.fromRGB(10, 5, 2),
        ACCENT = Color3.fromRGB(255, 140, 0), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(255, 180, 80),
        BLOOM = Color3.fromRGB(255, 200, 120), IRIDESCENT = Color3.fromRGB(255, 220, 180), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    Cyberpunk = {
        BG = Color3.fromRGB(0, 0, 0), PANEL = Color3.fromRGB(10, 0, 20), ITEM = Color3.fromRGB(20, 0, 40),
        HOVER = Color3.fromRGB(40, 0, 80), TEXT = Color3.fromRGB(255, 0, 255), SUBTEXT = Color3.fromRGB(200, 0, 200),
        LINE = Color3.fromRGB(100, 0, 200), GLOW = Color3.fromRGB(255, 0, 255), DIM = Color3.fromRGB(0, 0, 0),
        ACCENT = Color3.fromRGB(255, 0, 255), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(255, 0, 255),
        BLOOM = Color3.fromRGB(255, 100, 255), IRIDESCENT = Color3.fromRGB(255, 200, 255), SHADOW = Color3.fromRGB(0, 0, 0)
    },
    Matrix = {
        BG = Color3.fromRGB(0, 0, 0), PANEL = Color3.fromRGB(0, 10, 0), ITEM = Color3.fromRGB(0, 20, 0),
        HOVER = Color3.fromRGB(0, 40, 0), TEXT = Color3.fromRGB(0, 255, 0), SUBTEXT = Color3.fromRGB(0, 200, 0),
        LINE = Color3.fromRGB(0, 100, 0), GLOW = Color3.fromRGB(0, 255, 0), DIM = Color3.fromRGB(0, 0, 0),
        ACCENT = Color3.fromRGB(0, 255, 0), GLASS = Color3.fromRGB(255, 255, 255), PARTICLE = Color3.fromRGB(0, 255, 0),
        BLOOM = Color3.fromRGB(0, 255, 100), IRIDESCENT = Color3.fromRGB(100, 255, 100), SHADOW = Color3.fromRGB(0, 0, 0)
    }
}

-- Enhanced theme system
local Themes = {}
for themeName, colors in pairs(ColorPalettes) do
    Themes[themeName] = {
        colors = colors,
        gradients = {
            main = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.BG), ColorSequenceKeypoint.new(1, colors.PANEL)}),
            primary2 = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.ACCENT), ColorSequenceKeypoint.new(1, colors.GLOW)}),
            primary3 = ColorSequence.new({ColorSequenceKeypoint.new(0, colors.LINE), ColorSequenceKeypoint.new(1, colors.BLOOM)})
        }
    }
end

-- Enhanced metrics
local METRIC = {
    RRoot = 28, RPanel = 22, RCard = 18, RChip = 16, RSmall = 14,
    Pad = 32, Gap = 20, HeaderH = 85, ItemH = 40, SubItemH = 30,
    Gear = 38, SliderBarH = 16, Cursor = 20,
    Shadows = {32, 20, 14, 10}, ShadowAlpha = {0.90, 0.80, 0.60, 0.40},
    TwinGap = 30, AnimSpeed = 0.28, GlassBlur = 50, BloomIntensity = 0.20,
    GUISize = UDim2.fromOffset(220, 500), PanelSize = UDim2.fromOffset(220, 400), SubPanelSize = UDim2.fromOffset(180, 300)
}

-- Enhanced audio system
local AudioManager = {
    sounds = {}, enabled = true,
    init = function(self)
        local soundIds = {startup = "131961136", hover = "17208348006", click = "4526034708", notification = "3442983711"}
        for name, id in pairs(soundIds) do
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. id
            sound.Volume = name == "startup" and 0.6 or (name == "hover" and 0.4 or (name == "click" and 0.5 or 0.7))
            sound.Parent = SoundService
            self.sounds[name] = sound
        end
    end,
    play = function(self, soundName)
        if self.enabled and self.sounds[soundName] then
            pcall(function() self.sounds[soundName]:Play() end)
        end
    end,
    setEnabled = function(self, enabled)
        self.enabled = enabled
        for _, sound in pairs(self.sounds) do
            sound.Volume = enabled and (sound.Volume > 0 and sound.Volume or 0.5) or 0
        end
    end
}

-- Enhanced utilities
local Utils = {
    roundCorner = function(p, r) local u = Instance.new("UICorner"); u.CornerRadius = r; u.Parent = p; return u end,
    circleCorner = function(p) local u = Instance.new("UICorner"); u.CornerRadius = UDim.new(1, 0); u.Parent = p; return u end,
    stroke = function(p, c, t, thk, mode)
        local s = Instance.new("UIStroke"); s.Color = c; s.Thickness = thk or 1; s.Transparency = t or 0.8
        s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border; s.Parent = p; return s
    end,
    pad = function(p, l, t, r, b)
        local x = Instance.new("UIPadding")
        x.PaddingLeft = UDim.new(0, l or 0); x.PaddingTop = UDim.new(0, t or 0)
        x.PaddingRight = UDim.new(0, r or 0); x.PaddingBottom = UDim.new(0, b or 0); x.Parent = p; return x
    end,
    applyGradient = function(frame, gradKey, theme)
        local grad = Instance.new("UIGradient"); grad.Rotation = 45; grad.Parent = frame
        if theme and theme.gradients[gradKey] then grad.Color = theme.gradients[gradKey] end; return grad
    end,
    applyGlass = function(obj, intensity)
        local glass = Instance.new("Frame"); glass.Name = "GlassOverlay"; glass.Size = UDim2.new(1, 0, 1, 0)
        glass.Position = UDim2.new(0, 0, 0, 0); glass.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        glass.BackgroundTransparency = 0.75 + (intensity or 0); glass.BorderSizePixel = 0; glass.ZIndex = obj.ZIndex + 1; glass.Parent = obj
        local corner = obj:FindFirstChildOfClass("UICorner"); if corner then corner:Clone().Parent = glass end
        local glassGrad = Instance.new("UIGradient")
        glassGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 150, 195))})
        glassGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(1, 0.80)})
        glassGrad.Rotation = 50; glassGrad.Parent = glass; return glass
    end,
    createRipple = function(parent, pos, color)
        local ripple = Instance.new("Frame"); ripple.Size = UDim2.fromOffset(0, 0); ripple.Position = UDim2.new(0, pos.X, 0, pos.Y)
        ripple.BackgroundColor3 = color or Color3.fromRGB(0, 191, 255); ripple.BackgroundTransparency = 0.55; ripple.BorderSizePixel = 0
        ripple.ZIndex = parent.ZIndex + 2; ripple.Parent = parent; Utils.circleCorner(ripple)
        TweenService:Create(ripple, TweenInfo.new(0.7, Enum.EasingStyle.Quint), {
            Size = UDim2.fromOffset(110, 110), Position = UDim2.new(0, pos.X - 55, 0, pos.Y - 55),
            BackgroundTransparency = 1, Rotation = 180
        }):Play()
        task.delay(0.7, function() if ripple.Parent then ripple:Destroy() end end)
    end,
    createParticle = function(parent, count)
        local particles = {}
        for i = 1, count or 25 do
            local particle = Instance.new("Frame")
            particle.Name = "Particle"; particle.Size = UDim2.fromOffset(math.random(2, 14), math.random(2, 14))
            particle.BackgroundColor3 = Color3.fromRGB(85, 150, 205); particle.BackgroundTransparency = math.random(78, 92) / 100
            particle.BorderSizePixel = 0; particle.ZIndex = -6; particle.Parent = parent; Utils.circleCorner(particle)
            particle.Position = UDim2.new(math.random(0, 100) / 100, math.random(-35, 35), math.random(0, 100) / 100, math.random(-35, 35))
            table.insert(particles, particle)
        end
        spawn(function()
            while parent.Parent do
                for _, particle in ipairs(particles) do
                    if particle.Parent then
                        local newPos = UDim2.new(math.random(0, 100) / 100, math.random(-35, 35), math.random(0, 100) / 100, math.random(-35, 35))
                        TweenService:Create(particle, TweenInfo.new(math.random(7, 15), Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
                            Position = newPos, BackgroundTransparency = math.random(83, 99) / 100,
                            Rotation = math.random(-400, 400), Size = UDim2.fromOffset(math.random(1, 16), math.random(1, 16))
                        }):Play()
                    end
                end
                task.wait(2.5)
            end
        end)
        return particles
    end
}

-- Enhanced theme manager
local ThemeManager = {
    currentTheme = "ElectricBlue", colorRegistries = {}, gradientRegistries = {},
    registerColor = function(self, obj, prop, colorKey)
        if not self.colorRegistries[colorKey] then self.colorRegistries[colorKey] = {} end
        table.insert(self.colorRegistries[colorKey], {obj = obj, prop = prop})
    end,
    registerGradient = function(self, obj, gradKey)
        if not self.gradientRegistries[gradKey] then self.gradientRegistries[gradKey] = {} end
        table.insert(self.gradientRegistries[gradKey], obj)
    end,
    applyTheme = function(self, themeName)
        local theme = Themes[themeName]; if not theme then return end
        self.currentTheme = themeName; local colors = theme.colors
        for colorKey, objList in pairs(self.colorRegistries) do
            local color = colors[colorKey]; if color then
                for _, data in ipairs(objList) do pcall(function() data.obj[data.prop] = color end) end
            end
        end
        for gradKey, objList in pairs(self.gradientRegistries) do
            local gradSeq = theme.gradients[gradKey]; if gradSeq then
                for _, obj in ipairs(objList) do pcall(function() if obj:IsA("UIGradient") then obj.Color = gradSeq end end) end
            end
        end
    end
}

-- Enhanced notification system
local NotificationManager = {
    notifications = {},
    show = function(self, text, color, duration)
        duration = duration or 3; local notif = Instance.new("Frame")
        notif.Size = UDim2.fromOffset(280, 62); notif.Position = UDim2.new(1, 50, 0, 50 + (#self.notifications * 70))
        notif.BackgroundColor3 = color or Color3.fromRGB(0, 191, 255); notif.BackgroundTransparency = 1; notif.BorderSizePixel = 0
        notif.Parent = CoreGui; Utils.roundCorner(notif, UDim.new(0, 20)); Utils.stroke(notif, Color3.fromRGB(255, 255, 255), 0.50, 3)
        local notifText = Instance.new("TextLabel"); notifText.BackgroundTransparency = 1; notifText.Size = UDim2.new(1, -45, 1, 0)
        notifText.Position = UDim2.new(0, 22, 0, 0); notifText.Text = text; notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifText.TextSize = 16; notifText.Font = Enum.Font.SourceSansBold; notifText.TextWrapped = true
        notifText.TextXAlignment = Enum.TextXAlignment.Left; notifText.TextTransparency = 1; notifText.Parent = notif
        TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.01}):Play()
        TweenService:Create(notifText, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        TweenService:Create(notif, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -300, 0, 50 + (#self.notifications * 70))}):Play()
        table.insert(self.notifications, notif)
        task.delay(duration + 0.5, function()
            TweenService:Create(notif, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 50, 0, 50 + (#self.notifications * 70)), BackgroundTransparency = 1}):Play()
            TweenService:Create(notifText, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
            task.wait(0.8); if notif.Parent then notif:Destroy() end
            for i, n in ipairs(self.notifications) do if n == notif then table.remove(self.notifications, i); break end end
        end)
    end
}

-- Initialize audio
AudioManager:init()

-- Main GUI creation
local gui = Instance.new("ScreenGui")
gui.Name = "OtterClient_Complete"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = parentGui

pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)

-- Enhanced main API
local MainAPI = {
    Categories = {}, Modules = {}, gui = gui, themeManager = ThemeManager,
    notificationManager = NotificationManager, audioManager = AudioManager
}

-- Create main GUI elements
local function createMainGUI()
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"; toggleBtn.Size = UDim2.fromOffset(56, 56); toggleBtn.Position = UDim2.new(0.5, -28, 0, 40)
    toggleBtn.BackgroundColor3 = ColorPalettes.ElectricBlue.ITEM; ThemeManager:registerColor(toggleBtn, "BackgroundColor3", "ITEM")
    toggleBtn.BackgroundTransparency = 0.08; toggleBtn.AutoButtonColor = false; toggleBtn.Text = ""; toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = gui; Utils.circleCorner(toggleBtn); Utils.stroke(toggleBtn, ColorPalettes.ElectricBlue.ACCENT, 0.35, 3)
    Utils.applyGlass(toggleBtn, 0.14)
    
    local rootHolder = Instance.new("Frame")
    rootHolder.Size = METRIC.GUISize; rootHolder.Position = UDim2.new(0.5, -110, 0.5, -250); rootHolder.BackgroundTransparency = 1; rootHolder.Parent = gui
    
    for i, off in ipairs(METRIC.Shadows) do 
        local s = Instance.new("Frame"); s.Size = UDim2.new(1, off/2, 1, off/2); s.Position = UDim2.new(0, off, 0, off)
        s.BackgroundColor3 = ColorPalettes.ElectricBlue.SHADOW; ThemeManager:registerColor(s, "BackgroundColor3", "SHADOW")
        s.BackgroundTransparency = METRIC.ShadowAlpha[i]; s.ZIndex = -i; s.Parent = rootHolder; Utils.roundCorner(s, UDim.new(0, METRIC.RRoot))
    end
    
    local root = Instance.new("Frame")
    root.Name = "Root"; root.Size = UDim2.new(1, 0, 1, 0); root.BackgroundColor3 = ColorPalettes.ElectricBlue.BG
    ThemeManager:registerColor(root, "BackgroundColor3", "BG"); root.BorderSizePixel = 0; root.Parent = rootHolder
    Utils.roundCorner(root, UDim.new(0, METRIC.RRoot)); Utils.stroke(root, ColorPalettes.ElectricBlue.LINE, 0.50, 4)
    
    local mainGrad = Utils.applyGradient(root, "main", Themes.ElectricBlue); ThemeManager:registerGradient(mainGrad, "main")
    Utils.applyGlass(root, 0.005)
    Utils.createParticle(root, 25)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, METRIC.HeaderH); header.BackgroundColor3 = ColorPalettes.ElectricBlue.BG
    ThemeManager:registerColor(header, "BackgroundColor3", "BG"); header.BackgroundTransparency = 0.01; header.BorderSizePixel = 0; header.Parent = root
    
    local headerGrad = Utils.applyGradient(header, "primary2", Themes.ElectricBlue); ThemeManager:registerGradient(headerGrad, "primary2")
    
    local emblem = Instance.new("ImageLabel")
    emblem.Name = "MainEmblem"; emblem.BackgroundTransparency = 1; emblem.Size = UDim2.new(1, 0, 1, 0); emblem.Position = UDim2.new(0, 0, 0, 0)
    emblem.Image = "rbxassetid://71006324104371"; emblem.ImageColor3 = ColorPalettes.ElectricBlue.ACCENT
    ThemeManager:registerColor(emblem, "ImageColor3", "ACCENT"); emblem.ScaleType = Enum.ScaleType.Stretch; emblem.Parent = header
    
    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, -METRIC.HeaderH); body.Position = UDim2.new(0, 0, 0, METRIC.HeaderH); body.BackgroundTransparency = 1; body.Parent = root
    
    local scrollBody = Instance.new("ScrollingFrame")
    scrollBody.Name = "CategoryScroll"; scrollBody.Size = UDim2.new(1, 0, 1, 0); scrollBody.BackgroundTransparency = 1; scrollBody.BorderSizePixel = 0
    scrollBody.ScrollBarThickness = 6; scrollBody.ScrollBarImageColor3 = ColorPalettes.ElectricBlue.LINE
    ThemeManager:registerColor(scrollBody, "ScrollBarImageColor3", "LINE"); scrollBody.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollBody.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollBody.Parent = body
    
    local mainCategoryFrame = Instance.new("Frame")
    mainCategoryFrame.Name = "MainCategoryFrame"; mainCategoryFrame.BackgroundTransparency = 1; mainCategoryFrame.Size = UDim2.new(1, 0, 0, 0)
    mainCategoryFrame.AutomaticSize = Enum.AutomaticSize.Y; mainCategoryFrame.Parent = scrollBody
    
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.FillDirection = Enum.FillDirection.Vertical; mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
    mainLayout.Padding = UDim.new(0, 12); mainLayout.Parent = mainCategoryFrame
    
    Utils.pad(mainCategoryFrame, 16, 16, 16, 16)
    
    return rootHolder, root, mainCategoryFrame, toggleBtn
end

-- Enhanced slider component
local function createSlider(modulesettings, parent)
    local sliderapi = {Value = modulesettings.Default or modulesettings.Min, Min = modulesettings.Min, Max = modulesettings.Max, Decimal = modulesettings.Decimal or 0}
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = modulesettings.Name .. "Slider"; sliderButton.Size = UDim2.new(1, 0, 0, METRIC.SubItemH)
    sliderButton.BackgroundColor3 = ColorPalettes.ElectricBlue.ITEM; ThemeManager:registerColor(sliderButton, "BackgroundColor3", "ITEM")
    sliderButton.BackgroundTransparency = 0.08; sliderButton.BorderSizePixel = 0; sliderButton.Text = ""; sliderButton.Parent = parent
    Utils.roundCorner(sliderButton, UDim.new(0, METRIC.RSmall)); Utils.applyGradient(sliderButton, "main", Themes.ElectricBlue)
    
    local sliderTitle = Instance.new("TextLabel")
    sliderTitle.Size = UDim2.new(0, 100, 1, 0); sliderTitle.Position = UDim2.new(0, 12, 0, 0); sliderTitle.BackgroundTransparency = 1
    sliderTitle.Text = modulesettings.Name; sliderTitle.TextColor3 = ColorPalettes.ElectricBlue.TEXT
    ThemeManager:registerColor(sliderTitle, "TextColor3", "TEXT"); sliderTitle.TextSize = 14; sliderTitle.Font = Enum.Font.SourceSans
    sliderTitle.TextXAlignment = Enum.TextXAlignment.Left; sliderTitle.Parent = sliderButton
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 1, 0); valueLabel.Position = UDim2.new(1, -70, 0, 0); valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(sliderapi.Value); valueLabel.TextColor3 = ColorPalettes.ElectricBlue.SUBTEXT
    ThemeManager:registerColor(valueLabel, "TextColor3", "SUBTEXT"); valueLabel.TextSize = 14; valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right; valueLabel.Parent = sliderButton
    
    local sliderBkg = Instance.new("Frame")
    sliderBkg.Size = UDim2.new(1, -24, 0, 4); sliderBkg.Position = UDim2.new(0, 12, 0.5, -2)
    sliderBkg.BackgroundColor3 = ColorPalettes.ElectricBlue.DIM; ThemeManager:registerColor(sliderBkg, "BackgroundColor3", "DIM")
    sliderBkg.BorderSizePixel = 0; sliderBkg.Parent = sliderButton
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((sliderapi.Value - modulesettings.Min) / (modulesettings.Max - modulesettings.Min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0); sliderFill.BackgroundColor3 = ColorPalettes.ElectricBlue.ACCENT
    ThemeManager:registerColor(sliderFill, "BackgroundColor3", "ACCENT"); sliderFill.BorderSizePixel = 0; sliderFill.Parent = sliderBkg
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 12, 1, 0); sliderKnob.Position = UDim2.new((sliderapi.Value - modulesettings.Min) / (modulesettings.Max - modulesettings.Min), -6, 0, 0)
    sliderKnob.BackgroundColor3 = ColorPalettes.ElectricBlue.BG; ThemeManager:registerColor(sliderKnob, "BackgroundColor3", "BG")
    sliderKnob.BorderSizePixel = 0; sliderKnob.Parent = sliderBkg; Utils.roundCorner(sliderKnob, UDim.new(0, 6))
    
    local dragging = false
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; local mousePos = input.Position.X; local bkgPos = sliderBkg.AbsolutePosition.X
            local bkgSize = sliderBkg.AbsoluteSize.X; local relativePos = math.clamp((mousePos - bkgPos) / bkgSize, 0, 1)
            local newValue = modulesettings.Min + relativePos * (modulesettings.Max - modulesettings.Min)
            sliderapi.Value = math.floor(newValue * math.pow(10, sliderapi.Decimal)) / math.pow(10, sliderapi.Decimal)
            sliderapi:SetValue(sliderapi.Value)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X; local bkgPos = sliderBkg.AbsolutePosition.X
            local bkgSize = sliderBkg.AbsoluteSize.X; local relativePos = math.clamp((mousePos - bkgPos) / bkgSize, 0, 1)
            local newValue = modulesettings.Min + relativePos * (modulesettings.Max - modulesettings.Min)
            sliderapi.Value = math.floor(newValue * math.pow(10, sliderapi.Decimal)) / math.pow(10, sliderapi.Decimal)
            sliderapi:SetValue(sliderapi.Value)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    function sliderapi:SetValue(value)
        self.Value = math.clamp(value, self.Min, self.Max)
        local relativePos = (self.Value - self.Min) / (self.Max - self.Min)
        TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativePos, 0, 1, 0)}):Play()
        TweenService:Create(sliderKnob, TweenInfo.new(0.1), {Position = UDim2.new(relativePos, -6, 0, 0)}):Play()
        valueLabel.Text = tostring(self.Value)
        if modulesettings.Function then modulesettings.Function(self.Value) end
    end
    
    sliderapi:SetValue(sliderapi.Value); Utils.applyGlass(sliderButton, 0.1); return sliderapi
end

-- Enhanced color slider component
local function createColorSlider(modulesettings, parent)
    local colorapi = {Hue = modulesettings.DefaultHue or 0, Sat = modulesettings.DefaultSat or 1, Value = modulesettings.DefaultValue or 1, Opacity = modulesettings.DefaultOpacity or 1}
    
    local colorButton = Instance.new("TextButton")
    colorButton.Name = modulesettings.Name .. "ColorSlider"; colorButton.Size = UDim2.new(1, 0, 0, METRIC.SubItemH)
    colorButton.BackgroundColor3 = ColorPalettes.ElectricBlue.ITEM; ThemeManager:registerColor(colorButton, "BackgroundColor3", "ITEM")
    colorButton.BackgroundTransparency = 0.08; colorButton.BorderSizePixel = 0; colorButton.Text = ""; colorButton.Parent = parent
    Utils.roundCorner(colorButton, UDim.new(0, METRIC.RSmall)); Utils.applyGradient(colorButton, "main", Themes.ElectricBlue)
    
    local colorTitle = Instance.new("TextLabel")
    colorTitle.Size = UDim2.new(0, 80, 1, 0); colorTitle.Position = UDim2.new(0, 12, 0, 0); colorTitle.BackgroundTransparency = 1
    colorTitle.Text = modulesettings.Name; colorTitle.TextColor3 = ColorPalettes.ElectricBlue.TEXT
    ThemeManager:registerColor(colorTitle, "TextColor3", "TEXT"); colorTitle.TextSize = 14; colorTitle.Font = Enum.Font.SourceSans
    colorTitle.TextXAlignment = Enum.TextXAlignment.Left; colorTitle.Parent = colorButton
    
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 20, 0, 20); colorPreview.Position = UDim2.new(1, -50, 0.5, -10)
    colorPreview.BackgroundColor3 = Color3.fromHSV(colorapi.Hue, colorapi.Sat, colorapi.Value); colorPreview.BorderSizePixel = 0; colorPreview.Parent = colorButton
    Utils.roundCorner(colorPreview, UDim.new(0, 4))
    
    local colorBkg = Instance.new("Frame")
    colorBkg.Size = UDim2.new(1, -24, 0, 4); colorBkg.Position = UDim2.new(0, 12, 0.5, 8)
    colorBkg.BackgroundColor3 = ColorPalettes.ElectricBlue.DIM; ThemeManager:registerColor(colorBkg, "BackgroundColor3", "DIM")
    colorBkg.BorderSizePixel = 0; colorBkg.Parent = colorButton
    
    local colorGradient = Instance.new("UIGradient")
    colorGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, colorapi.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(colorapi.Hue, colorapi.Sat, colorapi.Value))})
    colorGradient.Parent = colorBkg
    
    local colorFill = Instance.new("Frame")
    colorFill.Size = UDim2.new(colorapi.Hue, 0, 1, 0); colorFill.BackgroundTransparency = 1; colorFill.Parent = colorBkg
    
    local colorKnob = Instance.new("Frame")
    colorKnob.Size = UDim2.new(0, 12, 1, 0); colorKnob.Position = UDim2.new(colorapi.Hue, -6, 0, 0)
    colorKnob.BackgroundColor3 = ColorPalettes.ElectricBlue.BG; ThemeManager:registerColor(colorKnob, "BackgroundColor3", "BG")
    colorKnob.BorderSizePixel = 0; colorKnob.Parent = colorFill; Utils.roundCorner(colorKnob, UDim.new(0, 6))
    
    local dragging = false
    colorButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; local mousePos = input.Position.X; local bkgPos = colorBkg.AbsolutePosition.X
            local bkgSize = colorBkg.AbsoluteSize.X; local relativePos = math.clamp((mousePos - bkgPos) / bkgSize, 0, 1)
            colorapi.Hue = relativePos; colorapi.Sat = math.max(0.5, colorapi.Sat + (relativePos - 0.5) * 0.1)
            colorapi.Value = math.max(0.3, colorapi.Value + (relativePos - 0.5) * 0.2); colorapi:SetValue(colorapi.Hue)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X; local bkgPos = colorBkg.AbsolutePosition.X
            local bkgSize = colorBkg.AbsoluteSize.X; local relativePos = math.clamp((mousePos - bkgPos) / bkgSize, 0, 1)
            colorapi.Hue = relativePos; colorapi.Sat = math.max(0.5, colorapi.Sat + (relativePos - 0.5) * 0.1)
            colorapi.Value = math.max(0.3, colorapi.Value + (relativePos - 0.5) * 0.2); colorapi:SetValue(colorapi.Hue)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    function colorapi:SetValue(hue)
        self.Hue = math.clamp(hue or self.Hue, 0, 1)
        TweenService:Create(colorFill, TweenInfo.new(0.1), {Size = UDim2.new(self.Hue, 0, 1, 0)}):Play()
        TweenService:Create(colorKnob, TweenInfo.new(0.1), {Position = UDim2.new(self.Hue, -6, 0, 0)}):Play()
        local currentColor = Color3.fromHSV(self.Hue, self.Sat, self.Value)
        colorPreview.BackgroundColor3 = currentColor
        colorGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)), ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))})
        if modulesettings.Function then modulesettings.Function(self.Hue, self.Sat, self.Value) end
    end
    
    Utils.applyGlass(colorButton, 0.1); return colorapi
end

-- Create enhanced category system
function MainAPI:CreateCategory(categorySettings)
    local categoryAPI = {Type = 'Category', PanelHolder = nil, PredefinedModules = {}, Modules = {}}
    
    local catButton = Instance.new("TextButton")
    catButton.Name = categorySettings.Name.."Button"; catButton.Size = UDim2.new(1, 0, 0, METRIC.ItemH)
    catButton.BackgroundColor3 = ColorPalettes.ElectricBlue.ITEM; ThemeManager:registerColor(catButton, "BackgroundColor3", "ITEM")
    catButton.BackgroundTransparency = 0.08; catButton.AutoButtonColor = false; catButton.Text = ""; catButton.BorderSizePixel = 0
    catButton.Parent = self.mainCategoryFrame; Utils.roundCorner(catButton, UDim.new(0, METRIC.RChip))
    
    local catGrad = Utils.applyGradient(catButton, "primary3", Themes.ElectricBlue); ThemeManager:registerGradient(catGrad, "primary3")
    
    local catIcon = Instance.new("ImageLabel")
    catIcon.Name = "Icon"; catIcon.Size = UDim2.fromOffset(24, 24); catIcon.Position = UDim2.fromOffset(10, 8)
    catIcon.BackgroundTransparency = 1; catIcon.Image = categorySettings.icon; catIcon.ImageColor3 = ColorPalettes.ElectricBlue.TEXT
    ThemeManager:registerColor(catIcon, "ImageColor3", "TEXT"); catIcon.Parent = catButton
    
    local catText = Instance.new("TextLabel")
    catText.Size = UDim2.new(1, -40, 1, 0); catText.Position = UDim2.new(0, 40, 0, 0); catText.BackgroundTransparency = 1
    catText.Text = categorySettings.Name; catText.TextColor3 = ColorPalettes.ElectricBlue.TEXT
    ThemeManager:registerColor(catText, "TextColor3", "TEXT"); catText.TextSize = 16; catText.Font = Enum.Font.SourceSansBold
    catText.TextXAlignment = Enum.TextXAlignment.Left; catText.Parent = catButton
    
    catButton.MouseEnter:Connect(function()
        AudioManager:play("hover")
        TweenService:Create(catButton, TweenInfo.new(0.30, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.005}):Play()
        catIcon.ImageTransparency = 0.2
    end)

    catButton.MouseLeave:Connect(function()
        TweenService:Create(catButton, TweenInfo.new(0.30, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.08}):Play()
        catIcon.ImageTransparency = 0
    end)
    
    catButton.MouseButton1Click:Connect(function()
        AudioManager:play("click"); Utils.createRipple(catButton, Vector2.new(30, METRIC.ItemH / 2))
        self.notificationManager:show("Opening " .. categorySettings.Name .. " panel...", ColorPalettes.ElectricBlue.ACCENT)
    end)
    
    categoryAPI.Button = catButton; self.Categories[categorySettings.Name] = categoryAPI; return categoryAPI
end

-- Initialize GUI
local rootHolder, root, mainCategoryFrame, toggleBtn = createMainGUI()
MainAPI.mainCategoryFrame = mainCategoryFrame

-- Create categories with enhanced modules
local combat = MainAPI:CreateCategory({Name = "Combat", icon = "rbxassetid://73934627824933"})
local blatant = MainAPI:CreateCategory({Name = "Blatant", icon = "rbxassetid://79598565620574"})
local render = MainAPI:CreateCategory({Name = "Render", icon = "rbxassetid://122258380658046"})
local utility = MainAPI:CreateCategory({Name = "Utility", icon = "rbxassetid://120818383743404"})
local world = MainAPI:CreateCategory({Name = "World", icon = "rbxassetid://83404487122052"})
local settings = MainAPI:CreateCategory({Name = "Settings", icon = "rbxassetid://6031097227"})

-- Enhanced toggle functionality
local function toggleGUI()
    local isVisible = rootHolder.Visible
    if isVisible then
        TweenService:Create(rootHolder, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.fromOffset(0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -130
        }):Play()
        task.delay(0.8, function() rootHolder.Visible = false; rootHolder.Rotation = 0 end)
    else
        rootHolder.Visible = true; rootHolder.Size = UDim2.fromOffset(0, 0); rootHolder.Position = UDim2.new(0.5, 0, 0.5, 0); rootHolder.Rotation = 130
        TweenService:Create(rootHolder, TweenInfo.new(1.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = METRIC.GUISize, Position = UDim2.new(0.5, -110, 0.5, -250), Rotation = 0
        }):Play()
    end
end

-- Input handling
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        AudioManager:play("startup"); toggleGUI()
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    AudioManager:play("click"); Utils.createRipple(toggleBtn, Vector2.new(28, 28)); AudioManager:play("startup"); toggleGUI()
end)

-- Enhanced startup animation
spawn(function()
    task.wait(0.05); rootHolder.Size = UDim2.fromOffset(0, 0); rootHolder.Position = UDim2.new(0.5, 0, 0.5, 0); rootHolder.Rotation = -35
    TweenService:Create(rootHolder, TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = METRIC.GUISize, Position = UDim2.new(0.5, -110, 0.5, -250), Rotation = 0
    }):Play()
    AudioManager:play("startup"); task.wait(1.4)
    MainAPI.notificationManager:show("🦦 OTTER CLIENT COMPLETE - Welcome " .. player.DisplayName .. "! Press RightShift to toggle.", ColorPalettes.ElectricBlue.IRIDESCENT, 5)
end)

-- Apply initial theme
ThemeManager:applyTheme("ElectricBlue")

print("🦦 Otter Client Complete loaded successfully!")
print("Press RightShift to toggle GUI")
print("Features: 9 Themes, Enhanced UI, Audio System, Notifications, Particles")

return MainAPI