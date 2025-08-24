run(function()
    local mod = oofer.Categories.Combat:CreateModule({
        Name = "KillAura",
        Description = "Auto-attacks nearby targets",
        Icon = "rbxassetid://14555796384"
    })

    mod:CreateToggle({
        Name = "Enabled",
        Flag = "KillAuraEnabled",
        Default = false
    })

    mod:CreateSlider({
        Name = "Range",
        Flag = "KillAuraRange",
        Default = 15,
        Min = 5,
        Max = 30
    })

    mod:CreateToggle({
        Name = "Target Players",
        Flag = "KillAuraPlayers",
        Default = true
    })

    mod:CreateToggle({
        Name = "Target Mobs",
        Flag = "KillAuraMobs",
        Default = false
    })
end)
