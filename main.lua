-- Main Game Script for Roblox Multi-Game Hub
-- This script handles the core game mechanics and player management

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Game Configuration
local GAME_CONFIG = {
    RESPAWN_TIME = 5,
    MAX_HEALTH = 100,
    WALK_SPEED = 16,
    JUMP_POWER = 50,
    GRAVITY = 196.2
}

-- Game State
local gameState = {
    currentGame = "lobby",
    players = {},
    scores = {},
    gameActive = false
}

-- Player Setup Function
local function setupPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Set player properties
    humanoid.MaxHealth = GAME_CONFIG.MAX_HEALTH
    humanoid.Health = GAME_CONFIG.MAX_HEALTH
    humanoid.WalkSpeed = GAME_CONFIG.WALK_SPEED
    humanoid.JumpPower = GAME_CONFIG.JUMP_POWER
    
    -- Add player to game state
    gameState.players[player.UserId] = {
        name = player.Name,
        health = GAME_CONFIG.MAX_HEALTH,
        score = 0,
        team = "Neutral"
    }
    
    -- Create spawn effect
    local spawnEffect = Instance.new("Explosion")
    spawnEffect.Position = character.HumanoidRootPart.Position
    spawnEffect.BlastRadius = 0
    spawnEffect.BlastPressure = 0
    spawnEffect.Visible = true
    spawnEffect.Parent = workspace
    
    print(player.Name .. " has joined the game!")
end

-- Player Cleanup Function
local function cleanupPlayer(player)
    if gameState.players[player.UserId] then
        gameState.players[player.UserId] = nil
        print(player.Name .. " has left the game!")
    end
end

-- Health Management
local function onHealthChanged(player, newHealth)
    if gameState.players[player.UserId] then
        gameState.players[player.UserId].health = newHealth
        
        -- Check if player died
        if newHealth <= 0 then
            print(player.Name .. " has died!")
            
            -- Respawn after delay
            wait(GAME_CONFIG.RESPAWN_TIME)
            if player.Character then
                player.Character:BreakJoints()
            end
        end
    end
end

-- Score Management
local function addScore(player, points)
    if gameState.players[player.UserId] then
        gameState.players[player.UserId].score = gameState.players[player.UserId].score + points
        print(player.Name .. " earned " .. points .. " points! Total: " .. gameState.players[player.UserId].score)
    end
end

-- Game Mode Functions
local function startLobby()
    gameState.currentGame = "lobby"
    gameState.gameActive = false
    print("Welcome to the Multi-Game Hub! Choose a game mode.")
end

local function startBedWars()
    gameState.currentGame = "bedwars"
    gameState.gameActive = true
    print("Starting BedWars game mode!")
    
    -- Load BedWars specific code
    local bedwarsModule = require(script.Parent.games.bedwars)
    bedwarsModule.startGame()
end

local function startStealBrain()
    gameState.currentGame = "stealBrain"
    gameState.gameActive = true
    print("Starting Steal a Brain game mode!")
    
    -- Load Steal a Brain specific code
    local stealBrainModule = require(script.Parent.games.stealABraintrot)
    stealBrainModule.startGame()
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        -- Reset all players
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                player.Character:BreakJoints()
            end
        end
    elseif input.KeyCode == Enum.KeyCode.B then
        startBedWars()
    elseif input.KeyCode == Enum.KeyCode.S then
        startStealBrain()
    elseif input.KeyCode == Enum.KeyCode.L then
        startLobby()
    end
end)

-- Player Events
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(cleanupPlayer)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
    setupPlayer(player)
end

-- Health monitoring
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local currentHealth = humanoid.Health
            
            if gameState.players[player.UserId] and gameState.players[player.UserId].health ~= currentHealth then
                onHealthChanged(player, currentHealth)
            end
        end
    end
end)

-- Initialize lobby
startLobby()

print("Multi-Game Hub initialized! Press B for BedWars, S for Steal a Brain, L for Lobby, R to reset all players.")