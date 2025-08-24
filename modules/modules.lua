run(function()
    local mod = oofer.Categories.Render:CreateModule({
        Name = "ESP",
        Tooltip = "Highlights players through walls",
        Function = function(state)
            if state then
                -- Enable ESP
                for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                    if plr ~= game.Players.LocalPlayer and plr.Character then
                        for _, part in ipairs(plr.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                highlight.Parent = part
                            end
                        end
                    end
                end
            else
                -- Disable ESP
                for _, highlight in ipairs(game:GetDescendants()) do
                    if highlight:IsA("Highlight") then
                        highlight:Destroy()
                    end
                end
            end
        end
    })

    -- Keybind row in settings
    mod:SetKeybind(Enum.KeyCode.E)

    -- Example toggle
    mod:CreateToggle({
        Name = "Show Team",
        Default = false,
        Function = function(enabled)
            -- Logic for showing teammates if needed
        end
    })

    -- Example slider
    mod:CreateSlider({
        Name = "Max Distance",
        Min = 50,
        Max = 1000,
        Default = 500,
        Suffix = function(v) return " studs" end,
        Function = function(value)
            -- Adjust ESP range logic
        end
    })
end)
