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
                -- wait for character + root
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart", 2)
                local hum = char:FindFirstChildOfClass("Humanoid")
                local cam = workspace.CurrentCamera
                if not (root and hum and cam) then
                    warn("[Fly] Missing parts, cannot start")
                    return
                end

                hum:ChangeState(Enum.HumanoidStateType.Freefall)

                mod._loop = RunService.Heartbeat:Connect(function()
                    if not (root and root.Parent) then return end
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
