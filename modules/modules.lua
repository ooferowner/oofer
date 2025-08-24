run(function()
    local mod = oofer.Categories.Render:CreateModule({
        Name = "Fullbright",
        Tooltip = "Forces maximum brightness in all environments",
        Function = function(state)
            if state then
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").ClockTime = 14
                game:GetService("Lighting").FogEnd = 1e6
            else
                -- Reset to default Roblox lighting
                game:GetService("Lighting").Brightness = 1
                game:GetService("Lighting").ClockTime = 12
                game:GetService("Lighting").FogEnd = 1000
            end
        end
    })

    -- Toggle to keep Fullbright locked on
    mod:CreateToggle({
        Name = "Lock Time",
        Default = true,
        Function = function(enabled)
            if enabled then
                mod._timeLoop = game:GetService("RunService").RenderStepped:Connect(function()
                    game:GetService("Lighting").ClockTime = 14
                end)
            else
                if mod._timeLoop then
                    mod._timeLoop:Disconnect()
                    mod._timeLoop = nil
                end
            end
        end
    })

    -- Slider to adjust brightness
    mod:CreateSlider({
        Name = "Brightness",
        Min = 1,
        Max = 5,
        Default = 2,
        Suffix = function(v) return "" end,
        Function = function(value)
            game:GetService("Lighting").Brightness = value
        end
    })
end)
run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local mod = oofer.Categories.Render:CreateModule({
        Name = "Fly",
        Tooltip = "WASD + Space/LeftCtrl flight. Noclip optional.",
        Function = function(state)
            if state then
                -- start fly loop
                mod._loop = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local cam = workspace.CurrentCamera
                    if not (char and root and hum and cam) then return end

                    hum:ChangeState(Enum.HumanoidStateType.Freefall)

                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector

                    local dir = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += look end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= look end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += right end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= right end
                    dir = Vector3.new(dir.X, 0, dir.Z)
                    if dir.Magnitude > 0 then dir = dir.Unit end

                    local up = 0
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up += 1 end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then up -= 1 end

                    local vel = (dir * mod._speed) + Vector3.new(0, up * mod._vSpeed, 0)
                    local currentY = root.AssemblyLinearVelocity.Y
                    root.AssemblyLinearVelocity = Vector3.new(vel.X, mod._hover and vel.Y or currentY, vel.Z)
                end)

                if mod._noclip then
                    mod._noclipConn = RunService.Stepped:Connect(function()
                        local char = LocalPlayer.Character
                        if not char then return end
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                end
            else
                -- stop fly loop
                if mod._loop then mod._loop:Disconnect() mod._loop = nil end
                if mod._noclipConn then mod._noclipConn:Disconnect() mod._noclipConn = nil end

                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
                end
            end
        end
    })

    -- defaults
    mod._speed = 60
    mod._vSpeed = 60
    mod._noclip = true
    mod._hover = true

    -- controls
    mod:CreateToggle({
        Name = "Noclip",
        Default = true,
        Function = function(enabled)
            mod._noclip = enabled
            if not mod.Enabled then return end
            if enabled and not mod._noclipConn then
                mod._noclipConn = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if not char then return end
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end)
            elseif not enabled and mod._noclipConn then
                mod._noclipConn:Disconnect()
                mod._noclipConn = nil
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = true end
                    end
                end
            end
        end
    })

    mod:CreateToggle({
        Name = "Hover",
        Default = true,
        Function = function(enabled)
            mod._hover = enabled
        end
    })

    mod:CreateSlider({
        Name = "Speed",
        Min = 10,
        Max = 200,
        Default = 60,
        Suffix = function(v) return " studs/s" end,
        Function = function(val)
            mod._speed = val
        end
    })

    mod:CreateSlider({
        Name = "Vertical Speed",
        Min = 10,
        Max = 200,
        Default = 60,
        Suffix = function(v) return " studs/s" end,
        Function = function(val)
            mod._vSpeed = val
        end
    })
end)
