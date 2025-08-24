run(function()
    local fb = oofer.Categories.Render:CreateModule({
        Name = "Fullbright",
        Tooltip = "Max brightness & night vision",
        Function = function(state)
            if state then
                game:GetService("Lighting").Brightness = 2
                game:GetService("Lighting").ClockTime = 14
                game:GetService("Lighting").FogEnd = 1e6
                game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                print("Fullbright ON")
            else
                game:GetService("Lighting").Brightness = 1
                game:GetService("Lighting").ClockTime = 12
                game:GetService("Lighting").FogEnd = 1000
                game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
                print("Fullbright OFF")
            end
        end
    })

    fb:CreateToggle({
        Name = "Dynamic Update",
        Default = false,
        Function = function(val)
            if val then
                fb._conn = game:GetService("RunService").RenderStepped:Connect(function()
                    game:GetService("Lighting").Brightness = 2
                    game:GetService("Lighting").ClockTime = 14
                    game:GetService("Lighting").FogEnd = 1e6
                    game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
                end)
            else
                if fb._conn then
                    fb._conn:Disconnect()
                    fb._conn = nil
                end
            end
        end
    })
end)
-- KillAura (Optimised)
run(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")

    local KillAuraModule
    local RangeSlider, AngleSlider, UpdateRateSlider, MaxTargetsSlider
    local Attacking = false
    local LastAttack = 0

    -- Simple target finder
    local function getTargets()
        local targets = {}
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return targets end

        local myPos = myChar.HumanoidRootPart.Position
        local myLook = myChar.HumanoidRootPart.CFrame.LookVector * Vector3.new(1, 0, 1)

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local root = plr.Character.HumanoidRootPart
                local delta = root.Position - myPos
                local dist = delta.Magnitude
                if dist <= RangeSlider.Value then
                    local angle = math.deg(math.acos(myLook:Dot((delta * Vector3.new(1, 0, 1)).Unit)))
                    if angle <= (AngleSlider.Value / 2) then
                        table.insert(targets, {Player = plr, Distance = dist})
                        if #targets >= MaxTargetsSlider.Value then break end
                    end
                end
            end
        end

        table.sort(targets, function(a, b) return a.Distance < b.Distance end)
        return targets
    end

    -- Attack loop
    local function attackLoop()
        RunService.Heartbeat:Connect(function()
            if not KillAuraModule.Enabled then return end
            if tick() - LastAttack < (1 / UpdateRateSlider.Value) then return end

            local targets = getTargets()
            if #targets > 0 then
                Attacking = true
                for _, t in ipairs(targets) do
                    -- Replace this with your executor's remote firing logic
                    print("[KillAura] Attacking:", t.Player.Name, "Dist:", math.floor(t.Distance*10)/10)
                end
                LastAttack = tick()
            else
                Attacking = false
            end
        end)
    end

    -- Create module in Combat category
    KillAuraModule = oofer.Categories.Combat:CreateModule({
        Name = "KillAura",
        Tooltip = "Automatically attacks nearby players",
        ExtraText = function()
            return string.format("R: %d | A: %d°", RangeSlider.Value, AngleSlider.Value)
        end,
        Function = function(state)
            if state then
                print("KillAura Enabled")
            else
                print("KillAura Disabled")
                Attacking = false
            end
        end
    })

    -- Sliders
    RangeSlider = KillAuraModule:CreateSlider({
        Name = "Attack Range",
        Min = 5,
        Max = 20,
        Default = 15,
        Suffix = function(v) return " studs" end,
        Function = function(v) print("Range set to", v) end
    })

    AngleSlider = KillAuraModule:CreateSlider({
        Name = "Max Angle",
        Min = 30,
        Max = 360,
        Default = 360,
        Suffix = function(v) return "°" end,
        Function = function(v) print("Angle set to", v) end
    })

    UpdateRateSlider = KillAuraModule:CreateSlider({
        Name = "Update Rate",
        Min = 1,
        Max = 60,
        Default = 20,
        Suffix = function(v) return "hz" end,
        Function = function(v) print("Update rate set to", v) end
    })

    MaxTargetsSlider = KillAuraModule:CreateSlider({
        Name = "Max Targets",
        Min = 1,
        Max = 5,
        Default = 3,
        Function = function(v) print("Max targets set to", v) end
    })

    -- Start loop
    attackLoop()
end)
