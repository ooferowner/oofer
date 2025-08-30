run(function()
    -- Create main button in Combat category
    local VelocityBoost = mainapi.Categories.Combat:CreateButton({
        Name = "Velocity Boost",
        Tooltip = "Adds hostile velocity when attacking",
        ExtraText = function()
            return "v1.0"
        end,
        Keybind = Enum.KeyCode.V, -- default keybind
        Function = function(state)
            print("[VelocityBoost] Activated via button/keybind")
        end
    })

    -- Toggle: Auto Apply
    local AutoToggle = VelocityBoost:CreateToggle({
        Name = "Auto Apply",
        Default = true,
        Tooltip = "Automatically apply boost on hit",
        Keybind = Enum.KeyCode.B, -- toggle keybind
        Function = function(enabled, fromKey)
            print("[VelocityBoost] Auto Apply:", enabled, "Triggered by key:", fromKey)
        end
    })

    -- Slider: Boost Amount
    local BoostAmount = VelocityBoost:CreateSlider({
        Name = "Boost Amount",
        Min = 10,
        Max = 100,
        Default = 50,
        Tooltip = "Controls how much velocity is added",
        Function = function(val)
            print("[VelocityBoost] Boost set to:", val)
        end
    })
end)
