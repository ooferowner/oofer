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

