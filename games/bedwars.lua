-- BedWars Game Mode for Roblox Multi-Game Hub
-- A team-based game where players protect their bed while trying to destroy others

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Teams = game:GetService("Teams")

-- BedWars Configuration
local BEDWARS_CONFIG = {
    TEAM_COLORS = {
        Red = Color3.fromRGB(255, 0, 0),
        Blue = Color3.fromRGB(0, 0, 255),
        Green = Color3.fromRGB(0, 255, 0),
        Yellow = Color3.fromRGB(255, 255, 0)
    },
    BED_POSITIONS = {
        Red = Vector3.new(-50, 5, -50),
        Blue = Vector3.new(50, 5, 50),
        Green = Vector3.new(-50, 5, 50),
        Yellow = Vector3.new(50, 5, -50)
    },
    SPAWN_POSITIONS = {
        Red = Vector3.new(-50, 10, -50),
        Blue = Vector3.new(50, 10, 50),
        Green = Vector3.new(-50, 10, 50),
        Yellow = Vector3.new(50, 10, -50)
    },
    GAME_DURATION = 600, -- 10 minutes
    RESPAWN_TIME = 5
}

-- Game State
local bedwarsState = {
    gameActive = false,
    startTime = 0,
    teams = {},
    beds = {},
    eliminatedTeams = {}
}

-- Create Team
local function createTeam(teamName, color)
    local team = Instance.new("Team")
    team.Name = teamName
    team.TeamColor = BrickColor.new(color)
    team.Parent = game:GetService("Teams")
    return team
end

-- Create Bed
local function createBed(teamName, position)
    local bed = Instance.new("Model")
    bed.Name = teamName .. "Bed"
    bed.Parent = workspace
    
    -- Bed base
    local bedBase = Instance.new("Part")
    bedBase.Name = "BedBase"
    bedBase.Size = Vector3.new(6, 1, 4)
    bedBase.Position = position
    bedBase.Anchored = true
    bedBase.BrickColor = BrickColor.new(BEDWARS_CONFIG.TEAM_COLORS[teamName])
    bedBase.Material = Enum.Material.Wood
    bedBase.Parent = bed
    
    -- Bed headboard
    local headboard = Instance.new("Part")
    headboard.Name = "Headboard"
    headboard.Size = Vector3.new(6, 3, 1)
    headboard.Position = position + Vector3.new(0, 2, 2)
    headboard.Anchored = true
    headboard.BrickColor = BrickColor.new(BEDWARS_CONFIG.TEAM_COLORS[teamName])
    headboard.Material = Enum.Material.Wood
    headboard.Parent = bed
    
    -- Bed protection zone
    local protectionZone = Instance.new("Part")
    protectionZone.Name = "ProtectionZone"
    protectionZone.Size = Vector3.new(12, 1, 8)
    protectionZone.Position = position
    protectionZone.Anchored = true
    protectionZone.Transparency = 0.8
    protectionZone.BrickColor = BrickColor.new(BEDWARS_CONFIG.TEAM_COLORS[teamName])
    protectionZone.CanCollide = false
    protectionZone.Parent = bed
    
    -- Add bed to state
    bedwarsState.beds[teamName] = {
        model = bed,
        position = position,
        destroyed = false
    }
    
    return bed
end

-- Assign Player to Team
local function assignPlayerToTeam(player, teamName)
    local team = Teams:FindFirstChild(teamName)
    if team then
        player.Team = team
        player.TeamColor = team.TeamColor
        
        -- Teleport to team spawn
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(BEDWARS_CONFIG.SPAWN_POSITIONS[teamName])
        end
    end
end

-- Check Bed Destruction
local function checkBedDestruction()
    for teamName, bedData in pairs(bedwarsState.beds) do
        if not bedData.destroyed and bedData.model.Parent == nil then
            bedData.destroyed = true
            print(teamName .. " team's bed has been destroyed!")
            
            -- Eliminate team members who die
            for _, player in pairs(Players:GetPlayers()) do
                if player.Team and player.Team.Name == teamName then
                    -- Mark for elimination on next death
                    player:SetAttribute("EliminatedOnDeath", true)
                end
            end
        end
    end
end

-- Handle Player Death
local function onPlayerDied(player)
    if player:GetAttribute("EliminatedOnDeath") then
        -- Player is eliminated
        table.insert(bedwarsState.eliminatedTeams, player.Team.Name)
        print(player.Name .. " has been eliminated!")
        
        -- Check for game end
        local remainingTeams = 0
        for teamName, _ in pairs(bedwarsState.teams) do
            local teamEliminated = false
            for _, eliminatedTeam in pairs(bedwarsState.eliminatedTeams) do
                if eliminatedTeam == teamName then
                    teamEliminated = true
                    break
                end
            end
            if not teamEliminated then
                remainingTeams = remainingTeams + 1
            end
        end
        
        if remainingTeams <= 1 then
            endBedWarsGame()
        end
    else
        -- Normal respawn
        wait(BEDWARS_CONFIG.RESPAWN_TIME)
        if player.Character then
            player.Character:BreakJoints()
        end
    end
end

-- End BedWars Game
local function endBedWarsGame()
    bedwarsState.gameActive = false
    print("BedWars game ended!")
    
    -- Find winning team
    local winningTeam = nil
    for teamName, _ in pairs(bedwarsState.teams) do
        local teamEliminated = false
        for _, eliminatedTeam in pairs(bedwarsState.eliminatedTeams) do
            if eliminatedTeam == teamName then
                teamEliminated = true
                break
            end
        end
        if not teamEliminated then
            winningTeam = teamName
            break
        end
    end
    
    if winningTeam then
        print(winningTeam .. " team wins!")
    else
        print("Game ended in a draw!")
    end
    
    -- Clean up
    for _, bedData in pairs(bedwarsState.beds) do
        if bedData.model then
            bedData.model:Destroy()
        end
    end
end

-- Start BedWars Game
local function startBedWarsGame()
    print("Starting BedWars game!")
    
    -- Reset state
    bedwarsState.gameActive = true
    bedwarsState.startTime = tick()
    bedwarsState.teams = {}
    bedwarsState.beds = {}
    bedwarsState.eliminatedTeams = {}
    
    -- Create teams
    for teamName, color in pairs(BEDWARS_CONFIG.TEAM_COLORS) do
        local team = createTeam(teamName, color)
        bedwarsState.teams[teamName] = team
        
        -- Create bed for team
        createBed(teamName, BEDWARS_CONFIG.BED_POSITIONS[teamName])
    end
    
    -- Assign players to teams
    local playerList = Players:GetPlayers()
    for i, player in pairs(playerList) do
        local teamNames = {"Red", "Blue", "Green", "Yellow"}
        local teamIndex = ((i - 1) % #teamNames) + 1
        assignPlayerToTeam(player, teamNames[teamIndex])
    end
    
    -- Start game loop
    spawn(function()
        while bedwarsState.gameActive and tick() - bedwarsState.startTime < BEDWARS_CONFIG.GAME_DURATION do
            checkBedDestruction()
            wait(1)
        end
        
        if bedwarsState.gameActive then
            endBedWarsGame()
        end
    end)
end

-- Player Events
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            onPlayerDied(player)
        end)
    end)
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                onPlayerDied(player)
            end)
        end
    end
end

-- Export functions
local BedWars = {
    startGame = startBedWarsGame,
    endGame = endBedWarsGame,
    isGameActive = function() return bedwarsState.gameActive end
}

return BedWars