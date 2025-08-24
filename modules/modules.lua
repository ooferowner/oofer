-- KillAura Module
run(function()
    local KillAuraModule
    local RangeSlider
    local CooldownSlider

    KillAuraModule = oofer.Categories.Combat:CreateModule({
        Name = 'KillAura',
        Tooltip = 'Automatically attacks nearby players',
        ExtraText = function()
            return "Range: " .. RangeSlider.Value .. " | CD: " .. CooldownSlider.Value
        end,
        Function = function(enabled)
            if enabled then
                print("KillAura Enabled | Range:", RangeSlider.Value, "| Cooldown:", CooldownSlider.Value)
                -- Start KillAura logic here
            else
                print("KillAura Disabled")
                -- Stop KillAura logic here
            end
        end
    })

    RangeSlider = KillAuraModule:CreateSlider({
        Name = 'Attack Range',
        Min = 5,
        Max = 20,
        Default = 15,
        Suffix = function(val) return " studs" end,
        Function = function(val)
            print("KillAura range set to", val)
            -- Update range logic here
        end
    })

    CooldownSlider = KillAuraModule:CreateSlider({
        Name = 'Cooldown',
        Min = 0.05,
        Max = 1,
        Default = 0.2,
        Suffix = function(val) return "s" end,
        Function = function(val)
            print("KillAura cooldown set to", val)
            -- Update cooldown logic here
        end
    })
end)
