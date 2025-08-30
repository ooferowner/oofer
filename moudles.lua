run(function()
    local VelocityBoost
    local BoostAmount
    local AutoToggle

    VelocityBoost = oofer.Categories.Combat:CreateButton({
        Name = "Velocity Boost",
        Tooltip = "Applies extra velocity when attacking",
        ExtraText = function()
            return "v1.2"
        end,
        Function = function(state)
            print("Velocity Boost:", state)
            print("Boost Amount:", BoostAmount.Value)
            print("Auto Toggle:", AutoToggle.Enabled)
        end
    })

    BoostAmount = VelocityBoost:CreateSlider({
        Name = "Boost Amount",
        Min = 10,
        Max = 100,
        Default = 50,
        Suffix = function(val)
            return val .. "%"
        end,
        Function = function(val)
            print("Boost set to:", val)
        end,
        Tooltip = "Controls how much velocity is added"
    })

    AutoToggle = VelocityBoost:CreateToggle({
        Name = "Auto Apply",
        Default = true,
        Function = function(val)
            print("Auto Apply:", val)
        end,
        Tooltip = "Automatically apply boost on hit"
    })
end)
