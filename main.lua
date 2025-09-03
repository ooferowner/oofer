run(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")

    local lp = Players.LocalPlayer
    local cam = Workspace.CurrentCamera

    -- Blur layer
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Enabled = false
    blur.Parent = Lighting

    -- Optional DOF for extra realism
    local dof = Instance.new("DepthOfFieldEffect")
    dof.Enabled = false
    dof.FocusDistance = 0
    dof.InFocusRadius = 10
    dof.FarIntensity = 0.5
    dof.Parent = Lighting

    local BGBlur = oofer.Categories.Render:CreateButton({
        Name = "Background Blur",
        Function = function(state)
            blur.Enabled = state
            dof.Enabled = state
            if state then
                task.spawn(function()
                    while BGBlur.Enabled do
                        local char = lp.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            -- Distance from camera to character
                            local dist = (cam.CFrame.Position - hrp.Position).Magnitude
                            -- Blur more when camera is farther away
                            blur.Size = math.clamp((dist - 5) * 0.8, 0, 56)
                            -- Keep DOF focus locked on character
                            dof.FocusDistance = dist
                        end
                        task.wait(0.05)
                    end
                end)
            end
        end,
        Tooltip = "Keeps your character in focus, blurs background dynamically"
    })
end)
