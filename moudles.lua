-- Modules System for Roblox Multi-Game Hub
-- Shared utilities and helper functions used across all game modes

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

-- Utility Functions
local Utils = {}

-- Color Utilities
Utils.colors = {
    RED = Color3.fromRGB(255, 0, 0),
    BLUE = Color3.fromRGB(0, 0, 255),
    GREEN = Color3.fromRGB(0, 255, 0),
    YELLOW = Color3.fromRGB(255, 255, 0),
    PURPLE = Color3.fromRGB(255, 0, 255),
    ORANGE = Color3.fromRGB(255, 165, 0),
    WHITE = Color3.fromRGB(255, 255, 255),
    BLACK = Color3.fromRGB(0, 0, 0)
}

-- Random Utilities
Utils.random = {
    -- Generate random position within radius
    positionInRadius = function(center, radius)
        local angle = math.random() * math.pi * 2
        local distance = math.random() * radius
        local x = center.X + math.cos(angle) * distance
        local z = center.Z + math.sin(angle) * distance
        return Vector3.new(x, center.Y, z)
    end,
    
    -- Generate random color
    color = function()
        return Color3.fromRGB(
            math.random(0, 255),
            math.random(0, 255),
            math.random(0, 255)
        )
    end,
    
    -- Generate random string
    string = function(length)
        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        local result = ""
        for i = 1, length do
            local rand = math.random(1, #chars)
            result = result .. string.sub(chars, rand, rand)
        end
        return result
    end
}

-- Animation Utilities
Utils.animation = {
    -- Tween a part's properties
    tweenPart = function(part, properties, duration, easingStyle, easingDirection)
        local tweenInfo = TweenInfo.new(
            duration or 1,
            easingStyle or Enum.EasingStyle.Quad,
            easingDirection or Enum.EasingDirection.Out
        )
        local tween = TweenService:Create(part, tweenInfo, properties)
        tween:Play()
        return tween
    end,
    
    -- Pulse effect
    pulse = function(part, scale, duration)
        local originalSize = part.Size
        local tween1 = Utils.animation.tweenPart(part, {Size = originalSize * scale}, duration/2)
        tween1.Completed:Connect(function()
            Utils.animation.tweenPart(part, {Size = originalSize}, duration/2)
        end)
    end,
    
    -- Fade in/out
    fade = function(part, transparency, duration, callback)
        local tween = Utils.animation.tweenPart(part, {Transparency = transparency}, duration)
        if callback then
            tween.Completed:Connect(callback)
        end
        return tween
    end
}

-- Sound Utilities
Utils.sound = {
    -- Play sound at position
    playAtPosition = function(soundId, position, volume, pitch)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = volume or 0.5
        sound.Pitch = pitch or 1
        sound.Parent = workspace
        
        local attachment = Instance.new("Attachment")
        attachment.Position = position
        attachment.Parent = workspace.Terrain
        
        sound.Parent = attachment
        sound:Play()
        
        sound.Ended:Connect(function()
            sound:Destroy()
            attachment:Destroy()
        end)
    end,
    
    -- Play sound for player
    playForPlayer = function(player, soundId, volume, pitch)
        if player.Character and player.Character:FindFirstChild("Head") then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. soundId
            sound.Volume = volume or 0.5
            sound.Pitch = pitch or 1
            sound.Parent = player.Character.Head
            sound:Play()
            
            sound.Ended:Connect(function()
                sound:Destroy()
            end)
        end
    end
}

-- Effect Utilities
Utils.effects = {
    -- Create explosion effect
    explosion = function(position, blastRadius, blastPressure)
        local explosion = Instance.new("Explosion")
        explosion.Position = position
        explosion.BlastRadius = blastRadius or 10
        explosion.BlastPressure = blastPressure or 500000
        explosion.Visible = true
        explosion.Parent = workspace
        return explosion
    end,
    
    -- Create sparkle effect
    sparkles = function(position, count, lifetime)
        for i = 1, count or 10 do
            local sparkle = Instance.new("Part")
            sparkle.Name = "Sparkle"
            sparkle.Size = Vector3.new(0.2, 0.2, 0.2)
            sparkle.Position = position + Vector3.new(
                math.random(-5, 5),
                math.random(-5, 5),
                math.random(-5, 5)
            )
            sparkle.BrickColor = BrickColor.new(Utils.random.color())
            sparkle.Material = Enum.Material.Neon
            sparkle.Anchored = true
            sparkle.CanCollide = false
            sparkle.Parent = workspace
            
            -- Animate sparkle
            Utils.animation.tweenPart(sparkle, {
                Position = sparkle.Position + Vector3.new(
                    math.random(-10, 10),
                    math.random(5, 15),
                    math.random(-10, 10)
                ),
                Transparency = 1
            }, lifetime or 2)
            
            Debris:AddItem(sparkle, lifetime or 2)
        end
    end,
    
    -- Create trail effect
    trail = function(part, color, lifetime)
        local attachment = Instance.new("Attachment")
        attachment.Parent = part
        
        local trail = Instance.new("Trail")
        trail.Attachment0 = attachment
        trail.Attachment1 = attachment
        trail.Color = ColorSequence.new(color or Utils.colors.WHITE)
        trail.Transparency = NumberSequence.new(0, 1)
        trail.Lifetime = lifetime or 1
        trail.Parent = part
        
        return trail
    end
}

-- Player Utilities
Utils.player = {
    -- Get player from character
    fromCharacter = function(character)
        return Players:GetPlayerFromCharacter(character)
    end,
    
    -- Teleport player to position
    teleport = function(player, position)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end,
    
    -- Give player tool
    giveTool = function(player, toolName, toolId)
        local tool = Instance.new("Tool")
        tool.Name = toolName
        tool.RequiresHandle = false
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.BrickColor = BrickColor.new(Utils.colors.WHITE)
        handle.Parent = tool
        
        if toolId then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. toolId
            sound.Parent = handle
        end
        
        tool.Parent = player.Backpack
        return tool
    end,
    
    -- Heal player
    heal = function(player, amount)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + amount)
        end
    end,
    
    -- Damage player
    damage = function(player, amount)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            humanoid.Health = math.max(0, humanoid.Health - amount)
        end
    end
}

-- Math Utilities
Utils.math = {
    -- Clamp value between min and max
    clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end,
    
    -- Linear interpolation
    lerp = function(a, b, t)
        return a + (b - a) * t
    end,
    
    -- Distance between two points
    distance = function(pos1, pos2)
        return (pos1 - pos2).Magnitude
    end,
    
    -- Angle between two vectors
    angle = function(v1, v2)
        return math.acos(v1:Dot(v2) / (v1.Magnitude * v2.Magnitude))
    end
}

-- String Utilities
Utils.string = {
    -- Format number with commas
    formatNumber = function(num)
        local formatted = tostring(num)
        local k
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end,
    
    -- Capitalize first letter
    capitalize = function(str)
        return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
    end,
    
    -- Split string by delimiter
    split = function(str, delimiter)
        local result = {}
        local pattern = "(.-)" .. delimiter
        local lastEnd = 1
        local s, e, cap = str:find(pattern, 1)
        while s do
            if s ~= 1 or cap ~= "" then
                table.insert(result, cap)
            end
            lastEnd = e + 1
            s, e, cap = str:find(pattern, lastEnd)
        end
        if lastEnd <= #str then
            cap = str:sub(lastEnd)
            table.insert(result, cap)
        end
        return result
    end
}

-- Table Utilities
Utils.table = {
    -- Deep copy table
    deepCopy = function(original)
        local copy = {}
        for key, value in pairs(original) do
            if type(value) == "table" then
                copy[key] = Utils.table.deepCopy(value)
            else
                copy[key] = value
            end
        end
        return copy
    end,
    
    -- Shuffle table
    shuffle = function(t)
        local shuffled = Utils.table.deepCopy(t)
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        return shuffled
    end,
    
    -- Get random element from table
    random = function(t)
        return t[math.random(1, #t)]
    end
}

-- Time Utilities
Utils.time = {
    -- Format seconds to MM:SS
    formatSeconds = function(seconds)
        local minutes = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", minutes, secs)
    end,
    
    -- Get current timestamp
    timestamp = function()
        return os.time()
    end,
    
    -- Wait for condition
    waitFor = function(condition, timeout)
        local startTime = tick()
        while not condition() do
            if timeout and tick() - startTime > timeout then
                return false
            end
            wait(0.1)
        end
        return true
    end
}

-- Export the Utils module
return Utils