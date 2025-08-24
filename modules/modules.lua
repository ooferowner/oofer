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
