-- Steal a Brain Game Mode for Roblox Multi-Game Hub
-- A collection-based game where players gather brains while avoiding obstacles

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Steal a Brain Configuration
local BRAIN_CONFIG = {
    BRAIN_SPAWN_RATE = 2, -- seconds between spawns
    MAX_BRAINS = 20,
    BRAIN_VALUE = 10,
    BRAIN_SIZE = Vector3.new(2, 2, 2),
    BRAIN_COLOR = Color3.fromRGB(255, 100, 255),
    BRAIN_MATERIAL = Enum.Material.Neon,
    SPAWN_RADIUS = 100,
    GAME_DURATION = 300, -- 5 minutes
    POWER_UP_CHANCE = 0.1 -- 10% chance for power-up
}

-- Power-up types
local POWER_UPS = {
    SPEED_BOOST = {
        name = "Speed Boost",
        duration = 10,
        effect = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 32
            end
        end,
        cleanup = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    },
    JUMP_BOOST = {
        name = "Jump Boost",
        duration = 15,
        effect = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = 100
            end
        end,
        cleanup = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = 50
            end
        end
    },
    INVISIBILITY = {
        name = "Invisibility",
        duration = 8,
        effect = function(player)
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.8
                    end
                end
            end
        end,
        cleanup = function(player)
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    end
                end
            end
        end
    }
}

-- Game State
local brainState = {
    gameActive = false,
    startTime = 0,
    brains = {},
    playerScores = {},
    powerUps = {},
    spawnTimer = 0
}

-- Create Brain
local function createBrain(position)
    local brain = Instance.new("Part")
    brain.Name = "Brain"
    brain.Size = BRAIN_CONFIG.BRAIN_SIZE
    brain.Position = position
    brain.Anchored = true
    brain.BrickColor = BrickColor.new(BRAIN_CONFIG.BRAIN_COLOR)
    brain.Material = BRAIN_CONFIG.BRAIN_MATERIAL
    brain.Shape = Enum.PartType.Ball
    brain.CanCollide = false
    brain.Parent = workspace
    
    -- Add brain glow effect
    local pointLight = Instance.new("PointLight")
    pointLight.Color = BRAIN_CONFIG.BRAIN_COLOR
    pointLight.Brightness = 2
    pointLight.Range = 10
    pointLight.Parent = brain
    
    -- Add floating animation
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
    bodyPosition.Position = position
    bodyPosition.Parent = brain
    
    -- Animate floating
    spawn(function()
        while brain.Parent do
            local t = tick()
            bodyPosition.Position = position + Vector3.new(0, math.sin(t * 2) * 2, 0)
            wait(0.1)
        end
    end)
    
    -- Add collection detection
    local collectionBox = Instance.new("Part")
    collectionBox.Name = "CollectionBox"
    collectionBox.Size = Vector3.new(4, 4, 4)
    collectionBox.Position = position
    collectionBox.Anchored = true
    collectionBox.Transparency = 1
    collectionBox.CanCollide = false
    collectionBox.Parent = brain
    
    local collectionTouched = false
    collectionBox.Touched:Connect(function(hit)
        if collectionTouched then return end
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid and hit.Parent:FindFirstChild("Head") then
            collectionTouched = true
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                collectBrain(player, brain)
            end
        end
    end)
    
    -- Add to state
    table.insert(brainState.brains, brain)
    
    -- Auto-remove after 30 seconds
    Debris:AddItem(brain, 30)
    
    return brain
end

-- Collect Brain
local function collectBrain(player, brain)
    -- Add score
    if not brainState.playerScores[player.UserId] then
        brainState.playerScores[player.UserId] = 0
    end
    brainState.playerScores[player.UserId] = brainState.playerScores[player.UserId] + BRAIN_CONFIG.BRAIN_VALUE
    
    -- Check for power-up
    if math.random() < BRAIN_CONFIG.POWER_UP_CHANCE then
        givePowerUp(player)
    end
    
    -- Create collection effect
    local explosion = Instance.new("Explosion")
    explosion.Position = brain.Position
    explosion.BlastRadius = 0
    explosion.BlastPressure = 0
    explosion.Visible = true
    explosion.Parent = workspace
    
    -- Remove brain
    brain:Destroy()
    
    -- Remove from state
    for i, b in pairs(brainState.brains) do
        if b == brain then
            table.remove(brainState.brains, i)
            break
        end
    end
    
    print(player.Name .. " collected a brain! Score: " .. brainState.playerScores[player.UserId])
end

-- Give Power-up
local function givePowerUp(player)
    local powerUpNames = {"SPEED_BOOST", "JUMP_BOOST", "INVISIBILITY"}
    local powerUpName = powerUpNames[math.random(1, #powerUpNames)]
    local powerUp = POWER_UPS[powerUpName]
    
    if powerUp then
        -- Apply power-up effect
        powerUp.effect(player)
        
        -- Store power-up for cleanup
        brainState.powerUps[player.UserId] = {
            type = powerUpName,
            endTime = tick() + powerUp.duration
        }
        
        print(player.Name .. " got " .. powerUp.name .. "!")
        
        -- Clean up after duration
        spawn(function()
            wait(powerUp.duration)
            if brainState.powerUps[player.UserId] and brainState.powerUps[player.UserId].type == powerUpName then
                powerUp.cleanup(player)
                brainState.powerUps[player.UserId] = nil
                print(player.Name .. "'s " .. powerUp.name .. " wore off!")
            end
        end)
    end
end

-- Spawn Brain
local function spawnBrain()
    if #brainState.brains >= BRAIN_CONFIG.MAX_BRAINS then
        return
    end
    
    -- Random position within spawn radius
    local angle = math.random() * math.pi * 2
    local distance = math.random() * BRAIN_CONFIG.SPAWN_RADIUS
    local x = math.cos(angle) * distance
    local z = math.sin(angle) * distance
    local y = 5 -- Spawn above ground
    
    local position = Vector3.new(x, y, z)
    createBrain(position)
end

-- Update Power-ups
local function updatePowerUps()
    local currentTime = tick()
    for playerId, powerUpData in pairs(brainState.powerUps) do
        if currentTime >= powerUpData.endTime then
            local player = Players:GetPlayerByUserId(playerId)
            if player then
                local powerUp = POWER_UPS[powerUpData.type]
                if powerUp then
                    powerUp.cleanup(player)
                end
            end
            brainState.powerUps[playerId] = nil
        end
    end
end

-- End Steal a Brain Game
local function endStealBrainGame()
    brainState.gameActive = false
    print("Steal a Brain game ended!")
    
    -- Find winner
    local winner = nil
    local highestScore = 0
    for playerId, score in pairs(brainState.playerScores) do
        if score > highestScore then
            highestScore = score
            winner = Players:GetPlayerByUserId(playerId)
        end
    end
    
    if winner then
        print(winner.Name .. " wins with " .. highestScore .. " points!")
    else
        print("No winner - no brains were collected!")
    end
    
    -- Clean up all brains
    for _, brain in pairs(brainState.brains) do
        if brain and brain.Parent then
            brain:Destroy()
        end
    end
    
    -- Clean up all power-ups
    for playerId, _ in pairs(brainState.powerUps) do
        local player = Players:GetPlayerByUserId(playerId)
        if player then
            for _, powerUp in pairs(POWER_UPS) do
                powerUp.cleanup(player)
            end
        end
    end
    
    -- Reset state
    brainState.brains = {}
    brainState.playerScores = {}
    brainState.powerUps = {}
end

-- Start Steal a Brain Game
local function startStealBrainGame()
    print("Starting Steal a Brain game!")
    
    -- Reset state
    brainState.gameActive = true
    brainState.startTime = tick()
    brainState.brains = {}
    brainState.playerScores = {}
    brainState.powerUps = {}
    brainState.spawnTimer = 0
    
    -- Spawn initial brains
    for i = 1, 5 do
        spawnBrain()
    end
    
    -- Start game loop
    spawn(function()
        while brainState.gameActive and tick() - brainState.startTime < BRAIN_CONFIG.GAME_DURATION do
            brainState.spawnTimer = brainState.spawnTimer + 1
            
            if brainState.spawnTimer >= BRAIN_CONFIG.BRAIN_SPAWN_RATE then
                spawnBrain()
                brainState.spawnTimer = 0
            end
            
            updatePowerUps()
            wait(1)
        end
        
        if brainState.gameActive then
            endStealBrainGame()
        end
    end)
end

-- Export functions
local StealBrain = {
    startGame = startStealBrainGame,
    endGame = endStealBrainGame,
    isGameActive = function() return brainState.gameActive end,
    getPlayerScore = function(playerId) return brainState.playerScores[playerId] or 0 end
}

return StealBrain