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
        Name = "AutoClicker",
        Tooltip = "Hold attack button to automatically click",
        Function = function(state)
            local RS = game:GetService("RunService")
            local UIS = game:GetService("UserInputService")

            if state then
                mod._running = true
                mod._conn = UIS.InputBegan:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        mod._clickLoop = RS.RenderStepped:Connect(function()
                            if not mod._running then return end
                            if mod._blockMode then
                                -- hostile block placement logic here
                            else
                                -- hostile sword swing logic here
                            end
                            task.wait(1 / (mod._blockMode and mod._blockCPS or mod._cps))
                        end)
                    end
                end)
                mod._endConn = UIS.InputEnded:Connect(function(input, gp)
                    if gp then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if mod._clickLoop then
                            mod._clickLoop:Disconnect()
                            mod._clickLoop = nil
                        end
                    end
                end)
            else
                mod._running = false
                if mod._clickLoop then mod._clickLoop:Disconnect() mod._clickLoop = nil end
                if mod._conn then mod._conn:Disconnect() mod._conn = nil end
                if mod._endConn then mod._endConn:Disconnect() mod._endConn = nil end
            end
        end
    })

    -- CPS slider (click/drag to change)
    mod:CreateSlider({
        Name = "CPS",
        Min = 1,
        Max = 20,
        Default = 12,
        Suffix = function(v) return "" end,
        Function = function(value)
            mod._cps = value
        end
    })

    -- Place Blocks toggle (click to change)
    mod:CreateToggle({
        Name = "Place Blocks",
        Default = true,
        Function = function(enabled)
            mod._blockMode = enabled
        end
    })

    -- Block CPS slider (click/drag to change)
    mod:CreateSlider({
        Name = "Block CPS",
        Min = 1,
        Max = 20,
        Default = 12,
        Suffix = function(v) return "" end,
        Function = function(value)
            mod._blockCPS = value
        end
    })
end)
            

  
