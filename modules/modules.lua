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
    local mod = oofer.Categories.Blatant:CreateModule({
        Name = "Fly",
        Tooltip = "Lets you fly using WASD + Space/Ctrl",
        Function = function(state)
            local RS = game:GetService("RunService")
            local UIS = game:GetService("UserInputService")
            local LP = game.Players.LocalPlayer
            local HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

            if state then
                mod._flying = true
                mod._conn = RS.RenderStepped:Connect(function()
                    if not mod._flying or not HRP then return end
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.new()
                    if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
                    HRP.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * (mod._speed or 50) or Vector3.zero
                end)
            else
                mod._flying = false
                if mod._conn then mod._conn:Disconnect() mod._conn = nil end
                if HRP then HRP.Velocity = Vector3.zero end
            end
        end
    })

    -- Speed slider
    mod:CreateSlider({
        Name = "Speed",
        Min = 10,
        Max = 200,
        Default = 50,
        Suffix = function(v) return " studs/s" end,
        Function = function(value)
            mod._speed = value
        end
    })

    -- Noclip toggle
    mod:CreateToggle({
        Name = "Noclip",
        Default = true,
        Function = function(enabled)
            local RS = game:GetService("RunService")
            if enabled then
                mod._noclipConn = RS.Stepped:Connect(function()
                    local char = game.Players.LocalPlayer.Character
                    if char then
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if mod._noclipConn then mod._noclipConn:Disconnect() mod._noclipConn = nil end
            end
        end
    })
end)            
