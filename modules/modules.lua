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
    local AttackRemote

    -- Async grab of BedWars attack remote
    task.spawn(function()
        repeat
            task.wait()
            pcall(function()
                AttackRemote = bedwars and remotes and bedwars.Client:Get(remotes.AttackEntity).instance
            end)
        until AttackRemote and type(AttackRemote.FireServer) == "function"
    end)

    local mod = oofer.Categories.Render:CreateModule({ -- same category as Fullbright
        Name = "Kill Aura",
        Tooltip = "Automatically attacks nearby players using BedWars remote",
        Function = function(state)
            if state then
                -- Mark enabled immediately so GUI turns green
                mod.Enabled = true

                -- Start loop once remote is ready
                task.spawn(function()
                    repeat task.wait() until AttackRemote and type(AttackRemote.FireServer) == "function"
                    if not mod.Enabled then return end -- user turned it off while waiting

                    mod._loop = game:GetService("RunService").Heartbeat:Connect(function()
                        local lp = game:GetService("Players").LocalPlayer
                        local char = lp.Character
                        local myRoot = char and char:FindFirstChild("HumanoidRootPart")
                        if not myRoot then return end

                        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                            if player ~= lp and player.Character then
                                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                local hum = player.Character:FindFirstChild("Humanoid")
                                if targetRoot and hum then
                                    local dist = (targetRoot.Position - myRoot.Position).Magnitude
                                    if dist <= mod._range then
                                        if mod._face then
                                            myRoot.CFrame = CFrame.new(
                                                myRoot.Position,
                                                Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z)
                                            )
                                        end
                                        AttackRemote:FireServer({
                                            weapon = getHeldItem and getHeldItem() or nil,
                                            entityInstance = player.Character,
                                            validate = {
                                                raycast = {
                                                    cameraPosition = workspace.CurrentCamera.CFrame.Position,
                                                    cursorDirection = (targetRoot.Position - workspace.CurrentCamera.CFrame.Position).Unit
                                                },
                                                targetPosition = targetRoot.Position,
                                                selfPosition = myRoot.Position
                                            }
                                        })
                                    end
                                end
                            end
                        end
                    end)
                end)
            else
                mod.Enabled = false
                if mod._loop then
                    mod._loop:Disconnect()
                    mod._loop = nil
                end
            end
        end
    })

    -- Defaults
    mod._range = 18
    mod._face = true

    -- Face Target toggle
    mod:CreateToggle({
        Name = "Face Target",
        Default = true,
        Function = function(enabled)
            mod._face = enabled
        end
    })

    -- Range slider
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
end)

