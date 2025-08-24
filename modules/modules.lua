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
    local mod = oofer.Categories.Combat:CreateModule({
        Name = "Kill Aura",
        Tooltip = "Automatically attacks nearby players within range",
        Function = function(state)
            if state then
                mod._loop = game:GetService("RunService").Heartbeat:Connect(function()
                    local lp = game:GetService("Players").LocalPlayer
                    local char = lp.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

                    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                            local targetRoot = player.Character.HumanoidRootPart
                            local myRoot = char.HumanoidRootPart
                            local distance = (targetRoot.Position - myRoot.Position).Magnitude
                            if distance <= mod._range then
                                if mod._face then
                                    myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
                                end
                                player.Character.Humanoid:TakeDamage(mod._damage)
                            end
                        end
                    end
                end)
            else
                if mod._loop then
                    mod._loop:Disconnect()
                    mod._loop = nil
                end
            end
        end
    })

    mod._range = 18
    mod._damage = 5
    mod._face = true

    mod:CreateToggle({
        Name = "Face Target",
        Default = true,
        Function = function(enabled)
            mod._face = enabled
        end
    })

    mod:CreateSlider({
        Name = "Attack Range",
        Min = 5,
        Max = 25,
        Default = 18,
        Suffix = function(v) return " studs" end,
        Function = function(val)
            mod._range = val
        end
    })

    mod:CreateSlider({
        Name = "Damage",
        Min = 1,
        Max = 20,
        Default = 5,
        Suffix = function(v) return " HP" end,
        Function = function(val)
            mod._damage = val
        end
    })
end)
            

  
