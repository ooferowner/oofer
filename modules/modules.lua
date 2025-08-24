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
	local Killaura: table = {["Enabled"] = false};
	local Targets: table = {Players = {["Enabled"] = false}};
	local Sort: table = {};
	local SwingRange: table = {};
	local AttackRange: table = {};
	local ChargeTime: table = {};
	local UpdateRate: table = {["Value"] = 540};
	local AngleSlider: table = {["Value"] = 360};
	local MaxTargets: table = {["Value"] = 5};
	local Mouse: table = {};
	local Swing: table = {};
	local GUI: table = {};
	local BoxSwingColor: table = {};
	local BoxAttackColor: table = {};
	local ParticleTexture: table = {};
	local ParticleColor1: table = {};
	local ParticleColor2: table = {};
	local ParticleSize: table = {};
	local Face: table = {};
	local Animation: table = {};
	local AnimationMode: table = {};
	local AnimationSpeed: table = {};
	local AnimationTween: table = {};
	local Limit: table = {};
	local LegitAura: table? = {}
	local Particles: table?, Boxes: table? = {}, {}
	local anims: any, AnimDelay: any, AnimTween: any, armC0: any = oofer.Libraries.auraanims, tick()
	local AttackRemote: any = {FireServer = function() end};
	task.spawn(function()
		AttackRemote = bedwars.Client:Get(remotes.AttackEntity).instance;
	end);
	local lastSwingServerTime: number = 0;
	local lastSwingServerTimeDelta: number = 0;
	local function getAttackData(): (any, any)
		if Mouse["Enabled"] then
			if not inputService:IsMouseButtonPressed(0) then return false; end;
		end;
		if GUI["Enabled"] then
			if bedwars.AppController:isLayerOpen(bedwars.UILayers.MAIN) then return false; end;
		end;

		local sword: any = Limit["Enabled"] and store.hand or store.tools.sword;
		if not sword or not sword.tool then return false; end;

		local meta: any = bedwars.ItemMeta[sword.tool["Name"]];
		if Limit["Enabled"] then
			if store.hand.toolType ~= 'sword' or bedwars.DaoController.chargingMaid then return false; end;
		end;
		if LegitAura["Enabled"] then
			if (tick() - bedwars.SwordController.lastSwing) > 0.2 then return false; end;
		end;
		return sword, meta;
	end;
	local killaurarangecirclepart: Instance? = nil;
	local killaurarangecircle: table = {};
	local killauracolor: table = {};
	Killaura = oofer.Categories.Blatant:CreateModule({
		["Name"] = 'Killaura',
		["Function"] = function(callback: boolean): void
			if callback then
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = Limit.Enabled
					end)
				end
				if inputService.TouchEnabled then 
					pcall(function() 
						lplr.PlayerGui.MobileUI['2'].Visible = Limit["Enabled"];
					end); 
				end;
				if Animation["Enabled"] then
					local fake: any = {
						Controllers = {
							ViewmodelController = {
								isVisible = function()
									return not Attacking
								end,
								playAnimation = function(...)
									if not Attacking then
										bedwars.ViewmodelController:playAnimation(select(2, ...))
									end;
								end;
							}
						}
					};
					if killaurarangecircle["Enabled"] and killaurarangecirclepart == nil and Killaura["Enabled"] then
			                    	killaurarangecirclepart = Instance.new("MeshPart");
			                    	killaurarangecirclepart.MeshId = "rbxassetid://3726303797";
			                    	killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
			                    	killaurarangecirclepart.CanCollide = false;
			                    	killaurarangecirclepart.Anchored = true;
			                    	killaurarangecirclepart.Material = Enum.Material.Neon;
			                    	killaurarangecirclepart.Size = Vector3.new(AttackRange.Value * 0.7, 0.01, AttackRange.Value * 0.7);
			                    	killaurarangecirclepart.Parent = gameCamera;
			                    	bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true);
			                end;

					task.spawn(function()
						local started: boolean = false;
						repeat
							if Attacking then
								if not armC0 then 
									armC0 = gameCamera.Viewmodel.RightHand.RightWrist.C0; 
								end;
								local first: any = not started;
								started = true;

								if AnimationMode["Value"]== 'Random' then
									anims.Random = {{CFrame = CFrame.Angles(math.rad(math.random(1, 360)), math.rad(math.random(1, 360)), math.rad(math.random(1, 360))), Time = 0.12}};
								end;

								for _, v in anims[AnimationMode["Value"]] do
									AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(first and (AnimationTween["Enabled"] and 0.001 or 0.1) or v.Time / AnimationSpeed["Value"], Enum.EasingStyle.Linear), {
										C0 = armC0 * v.CFrame
									});
									AnimTween:Play();
									AnimTween.Completed:Wait();
									first = false;
									if (not Killaura["Enabled"]) or (not Attacking) then break; end;
								end;
							elseif started then
								started = false;
								AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween["Enabled"] and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
									C0 = armC0
								});
								AnimTween:Play()
							end;

							if not started then 
								task.wait(1 / UpdateRate["Value"]);
							end;
						until (not Killaura["Enabled"]) or (not Animation["Enabled"]);
					end);
				end;

				local swingCooldown: number = 0;
				lastSwingServerTime = Workspace:GetServerTimeNow();
                		lastSwingServerTimeDelta = 0;				
				repeat
					if killaurarangecircle["Enabled"] and killaurarangecirclepart then
			                        if entitylib.isAlive and entitylib.character.HumanoidRootPart then
			                            	killaurarangecirclepart.Position = entitylib.character.HumanoidRootPart.Position - Vector3.new(0, entitylib.character.Humanoid.HipHeight, 0)
			                        end
			                end
					local attacked: any, sword: any, meta: any = {}, getAttackData();
					Attacking = false;
					store.KillauraTarget = nil;
					if sword then
						local plrs: any = entitylib.AllPosition({
							Range = SwingRange.Value,
							Wallcheck = Targets.Walls.Enabled or nil,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = MaxTargets.Value,
							Sort = sortmethods[Sort.Value]
						});

						if #plrs > 0 then
							switchItem(sword.tool, 0);
							local selfpos: Vector3? = entitylib.character.RootPart.Position;
							local localfacing: Vector3? = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1);

							for _: any, v: any in plrs do
								if workspace:GetServerTimeNow() - bedwars.SwordController.lastAttack < ChargeTime.Value then continue end				
								local delta: number? = (v.RootPart.Position - selfpos);
								local angle: number? = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit));
								if angle > (math.rad(AngleSlider["Value"]) / 2) then continue; end;

								table.insert(attacked, {
									Entity = v,
									Check = delta.Magnitude > AttackRange.Value and BoxSwingColor or BoxAttackColor
								});
								targetinfo.Targets[v] = tick() + 1;

								if not Attacking then
									Attacking = true;
									store.KillauraTarget = v;
									if not Swing["Enabled"] and AnimDelay <= tick() and not LegitAura["Enabled"] then
										AnimDelay = tick() + (meta.sword.respectAttackSpeedForEffects and meta.sword.attackSpeed or 0.25);
										bedwars.SwordController:playSwordEffect(meta, false);
										if meta.displayName:find(' Scythe') then 
											bedwars.ScytheController:playLocalAnimation();
										end;

										if oofer.ThreadFix then 
											setthreadidentity(8); 
										end;
									end;
								end;

								if delta.Magnitude > AttackRange["Value"] then continue; end;
								if delta.Magnitude < 14.4 and (tick() - swingCooldown) < ChargeTime["Value"] then continue; end;
								local actualRoot: any = v.Character.PrimaryPart;
								if actualRoot then
									local dir: any = CFrame.lookAt(selfpos, actualRoot.Position).LookVector;
									local pos: any = selfpos + dir * math.max(delta.Magnitude - 14.399, 0);
									swingCooldown = tick();
									bedwars.SwordController.lastAttack = workspace:GetServerTimeNow()
                                    					bedwars.SwordController.lastSwingServerTime = workspace:GetServerTimeNow()
									lastSwingServerTimeDelta = workspace:GetServerTimeNow() - lastSwingServerTime
                                    					lastSwingServerTime = workspace:GetServerTimeNow()
									store.attackReach = (delta.Magnitude * 100) // 1 / 100;
									store.attackReachUpdate = tick() + 1;

									if delta.Magnitude < 14.4 and ChargeTime["Value"] > 0.11 then
										AnimDelay = tick();
									end;

									AttackRemote:FireServer({
										weapon = sword.tool,
										chargedAttack = {chargeRatio = 0},
										lastSwingServerTimeDelta = lastSwingServerTimeDelta,
										entityInstance = v.Character,
										validate = {
											raycast = {
												cameraPosition = {value = pos},
												cursorDirection = {value = dir}
											},
											targetPosition = {value = actualRoot.Position},
											selfPosition = {value = pos}
										}
									});
								end;
							end;
						end;
					end;

					for i: any, v: any in Boxes do
						v.Adornee = attacked[i] and attacked[i].Entity.RootPart or nil
						if v.Adornee then
							v.Color3 = Color3.fromHSV(attacked[i].Check.Hue, attacked[i].Check.Sat, attacked[i].Check.Value)
							v.Transparency = 1 - attacked[i].Check.Opacity
						end;
					end;

					for i: any, v: any in Particles do
						v.Position = attacked[i] and attacked[i].Entity.RootPart.Position or Vector3.new(9e9, 9e9, 9e9);
						v.Parent = attacked[i] and gameCamera or nil;
					end;

					if Face["Enabled"] and attacked[1] then
						local vec: Vector3? = attacked[1].Entity.RootPart.Position * Vector3.new(1, 0, 1);
						entitylib.character.RootPart.CFrame = CFrame.lookAt(entitylib.character.RootPart.Position, Vector3.new(vec.X, entitylib.character.RootPart.Position.Y + 0.001, vec.Z));
					end;

					--#attacked > 0 and #attacked * 0.02 or
					task.wait(1 / UpdateRate.Value);
				until not Killaura.Enabled;
			else
				if killaurarangecirclepart then 
				        killaurarangecirclepart:Destroy();
				        killaurarangecirclepart = nil;
				end;
				store.KillauraTarget = nil
				for _, v in Boxes do
					v.Adornee = nil;
				end;
				for _, v in Particles do
					v.Parent = nil;
				end;
				if inputService.TouchEnabled then
					pcall(function()
						lplr.PlayerGui.MobileUI['2'].Visible = true;
					end);
				end;
				debug.setupvalue(oldSwing or bedwars.SwordController.playSwordEffect, 6, bedwars.Knit);
				debug.setupvalue(bedwars.ScytheController.playLocalAnimation, 3, bedwars.Knit);
				Attacking = false;
				if armC0 then
					AnimTween = tweenService:Create(gameCamera.Viewmodel.RightHand.RightWrist, TweenInfo.new(AnimationTween.Enabled and 0.001 or 0.3, Enum.EasingStyle.Exponential), {
						C0 = armC0
					});
					AnimTween:Play();
				end;
			end;
		end,
		["ExtraText"] = function() return "Public" end;
		["Tooltip"] = 'Attack players around you\nwithout aiming at them.'
	})
	Targets = Killaura:CreateTargets({
		["Players"] = true, 
		["NPCs"] = true
	});
	local methods: table = {'Damage', 'Distance'}
	for i in sortmethods do
		if not table.find(methods, i) then
			table.insert(methods, i);
		end;
	end;
	SwingRange = Killaura:CreateSlider({
		["Name"] = 'Swing range',
		["Min"] = 1,
		["Max"] = 18,
		["Default"] = 18,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AttackRange = Killaura:CreateSlider({
		["Name"] = 'Attack range',
		["Min"] = 1,
		["Max"] = 18,
		["Default"] = 18,
		["Suffix"] = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	ChargeTime = Killaura:CreateSlider({
		["Name"] = 'Charge time',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.42,
		["Decimal"] = 100
	})
	AngleSlider = Killaura:CreateSlider({
		["Name"] = 'Max angle',
		["Min"] = 1,
		["Max"] = 360,
		["Default"] = 360
	})
	UpdateRate = Killaura:CreateSlider({
		["Name"] = 'Update rate',
		["Min"] = 1,
		["Max"] = 540,
		["Default"] = 60,
		["Suffix"] = 'hz'
	})
	MaxTargets = Killaura:CreateSlider({
		["Name"] = 'Entities',
		["Min"] = 1,
		["Max"] = 10,
		["Default"] = 5
	})
	Sort = Killaura:CreateDropdown({
		["Name"] = 'Target Mode',
		["List"] = methods
	})
	killaurarangecircle = Killaura:CreateToggle({
        	Name = "Range Visualizer",
        	Function = function(callback: boolean): void
            		if callback then 
                		killaurarangecirclepart = Instance.new("MeshPart")
		                killaurarangecirclepart.MeshId = "rbxassetid://3726303797"
		                killaurarangecirclepart.Color = Color3.fromHSV(killauracolor["Hue"], killauracolor["Sat"], killauracolor.Value)
		                killaurarangecirclepart.CanCollide = false
		                killaurarangecirclepart.Anchored = true
		                killaurarangecirclepart.Material = Enum.Material.Neon
		                killaurarangecirclepart.Size = Vector3.new(AttackRange.Value * 0.7, 0.01, AttackRange.Value * 0.7)
		                if Killaura.Enabled then 
		                    	killaurarangecirclepart.Parent = gameCamera
		                end
		                bedwars.QueryUtil:setQueryIgnored(killaurarangecirclepart, true)
            		else
		                if killaurarangecirclepart then 
		                    	killaurarangecirclepart:Destroy()
		                    	killaurarangecirclepart = nil
		                end
            		end
        	end
    	})
    	killauracolor = Killaura:CreateColorSlider({
         	Name = 'colour',
         	Darker = true,
		DefaultHue = 0.6,
		DefaultOpacity = 0.5,
		Visible = true
	})
	Mouse = Killaura:CreateToggle({["Name"] = 'Require mouse down'})
	Swing = Killaura:CreateToggle({["Name"] = 'No Swing'})
	GUI = Killaura:CreateToggle({["Name"] = 'GUI check'})
	Killaura:CreateToggle({
		["Name"] = 'Show target',
		["Function"] = function(callback: boolean): void
			BoxSwingColor.Object.Visible = callback
			BoxAttackColor.Object.Visible = callback
			if callback then
				for i = 1, 10 do
					local box: BoxHandleAdornment = Instance.new('BoxHandleAdornment');
					box.Adornee = nil;
					box.AlwaysOnTop = true;
					box.Size = Vector3.new(6, 8, 6);
					box.CFrame = CFrame.new(0, -0.5, 0);
					box.ZIndex = 0;
					box.Parent = oofer.gui;
					Boxes[i] = box;
				end;
			else
				for _, v in Boxes do 
					v:Destroy();
				end;
				table.clear(Boxes);
			end;
		end;
	})
	BoxSwingColor = Killaura:CreateColorSlider({
		["Name"] = 'Target Color',
		["Darker"] = true,
		["DefaultHue"] = 0.6,
		["DefaultOpacity"] = 0.5,
		["Visible"] = false
	});
	BoxAttackColor = Killaura:CreateColorSlider({
		["Name"] = 'Attack Color',
		["Darker"] = true,
		["DefaultOpacity"] = 0.5,
		["Visible"] = false
	});
	Killaura:CreateToggle({
		["Name"] = 'Target particles',
		["Function"] = function(callback: boolean): void
			ParticleTexture.Object.Visible = callback;
			ParticleColor1.Object.Visible = callback;
			ParticleColor2.Object.Visible = callback;
			ParticleSize.Object.Visible = callback;
			if callback then
				for i = 1, 10 do
					local part: Part = Instance.new('Part');
					part.Size = Vector3.new(2, 4, 2);
					part.Anchored = true;
					part.CanCollide = false;
					part.Transparency = 1;
					part.CanQuery = false;
					part.Parent = Killaura["Enabled"] and gameCamera or nil;
					local particles: ParticleEmitter = Instance.new('ParticleEmitter');
					particles.Brightness = 1.5;
					particles.Size = NumberSequence.new(ParticleSize["Value"]);
					particles.Shape = Enum.ParticleEmitterShape.Sphere;
					particles.Texture = ParticleTexture["Value"];
					particles.Transparency = NumberSequence.new(0);
					particles.Lifetime = NumberRange.new(0.4);
					particles.Speed = NumberRange.new(16);
					particles.Rate = 128;
					particles.Drag = 16;
					particles.ShapePartial = 1;
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)), 
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					});
					particles.Parent = part;
					Particles[i] = part;
				end;
			else
				for _, v in Particles do 
					v:Destroy();
				end;
				table.clear(Particles);
			end;
		end;
	})
	ParticleTexture = Killaura:CreateTextBox({
		["Name"] = 'Texture',
		["Default"] = 'rbxassetid://14736249347',
		["Function"] = function()
			for _, v in Particles do
				v.ParticleEmitter.Texture = ParticleTexture["Value"]
			end
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	ParticleColor1 = Killaura:CreateColorSlider({
		["Name"] = 'Color Begin',
		["Function"] = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)), 
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
				});
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	})
	ParticleColor2 = Killaura:CreateColorSlider({
		["Name"] = 'Color End',
		["Function"] = function(hue, sat, val)
			for _, v in Particles do
				v.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)), 
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				});
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	ParticleSize = Killaura:CreateSlider({
		["Name"] = 'Size',
		["Min"] = 0,
		["Max"] = 1,
		["Default"] = 0.2,
		["Decimal"] = 100,
		["Function"] = function(val)
			for _, v in Particles do
				v.ParticleEmitter.Size = NumberSequence.new(val);
			end;
		end,
		["Darker"] = true,
		["Visible"] = false
	});
	Face = Killaura:CreateToggle({["Name"] = 'Face target'})
	Animation = Killaura:CreateToggle({
		["Name"] = 'Custom Animation',
		["Function"] = function(callback: boolean): void
			AnimationMode.Object.Visible = callback;
			AnimationTween.Object.Visible = callback;
			AnimationSpeed.Object.Visible = callback;
			if Killaura["Enabled"] then
				Killaura:Toggle();
				Killaura:Toggle();
			end;
		end;
	})
	local animnames: table = {}
	for i in anims do 
		table.insert(animnames, i);
	end;
	AnimationMode = Killaura:CreateDropdown({
		["Name"] = 'Animation Mode',
		["List"] = animnames,
		["Darker"] = true,
		["Visible"] = false
	})
	AnimationSpeed = Killaura:CreateSlider({
		["Name"] = 'Animation Speed',
		["Min"] = 0,
		["Max"] = 2,
		["Default"] = 1,
		["Decimal"] = 10,
		["Darker"] = true,
		["Visible"] = false
	})
	AnimationTween = Killaura:CreateToggle({
		["Name"] = 'No Tween',
		["Darker"] = true,
		["Visible"] = false
	})
	Limit = Killaura:CreateToggle({
		["Name"] = 'Limit to items',
		["Function"] = function(callback: boolean): void
			if inputService.TouchEnabled and Killaura["Enabled"] then 
				pcall(function() 
					lplr.PlayerGui.MobileUI['2'].Visible = callback;
				end);
			end;
		end,
		["Tooltip"] = 'Only attacks when the sword is held'
	});
	--[[LegitAura = Killaura:CreateToggle({
		Name = 'Swing only',
		Tooltip = 'Only attacks while swinging manually'
	})]]
end)
            

  
