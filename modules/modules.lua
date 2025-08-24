-- ESP Module
run(function()
    local ESPModule
    local ThicknessSlider

    ESPModule = oofer.Categories.Render:CreateModule({
        Name = 'ESP',
        Tooltip = 'Highlights all players through walls',
        ExtraText = function()
            return "Thickness: " .. ThicknessSlider.Value
        end,
        Function = function(enabled)
            if enabled then
                print("ESP Enabled | Thickness:", ThicknessSlider.Value)
                -- ESP logic here
            else
                print("ESP Disabled")
                -- Disable ESP logic here
            end
        end
    })

    ThicknessSlider = ESPModule:CreateSlider({
        Name = 'Outline Thickness',
        Min = 1,
        Max = 5,
        Default = 2,
        Suffix = function(val) return "px" end,
        Function = function(val)
            print("ESP Thickness set to", val)
            -- Update ESP thickness logic here
        end
    })
end)
