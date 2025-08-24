-- modules.lua — oofer all-in-one core (converted)

-- bootstrap helpers
local run = function(func) func() end
local cloneref = cloneref or function(obj) return obj end

-- global core
oofer = rawget(_G, "oofer") or {}
oofer.Modules = oofer.Modules or {}

-- events hub (autovivified)
local ooferEvents = setmetatable({}, {
    __index = function(self, index)
        self[index] = Instance.new('BindableEvent')
        return self[index]
    end
})
oofer.Modules.Events = ooferEvents

-- services
local playersService       = cloneref(game:GetService('Players'))
local replicatedStorage    = cloneref(game:GetService('ReplicatedStorage'))
local runService           = cloneref(game:GetService('RunService'))
local inputService         = cloneref(game:GetService('UserInputService'))
local tweenService         = cloneref(game:GetService('TweenService'))
local httpService          = cloneref(game:GetService('HttpService'))
local textChatService      = cloneref(game:GetService('TextChatService'))
local collectionService    = cloneref(game:GetService('CollectionService'))
local contextActionService = cloneref(game:GetService('ContextActionService'))
local guiService           = cloneref(game:GetService('GuiService'))
local coreGui              = cloneref(game:GetService('CoreGui'))
local starterGui           = cloneref(game:GetService('StarterGui'))
local lplr                 = playersService.LocalPlayer
local gameCamera           = workspace.CurrentCamera

local isnetworkowner = identifyexecutor and table.find({'AWP', 'Nihon'}, ({identifyexecutor()})[1]) and isnetworkowner or function() return true end

-- oofer shared libs (replace vape.*)
local host = rawget(shared, "oofer") or {}
local entitylib     = host.Libraries and host.Libraries.entity
local targetinfo    = host.Libraries and host.Libraries.targetinfo
local sessioninfo   = host.Libraries and host.Libraries.sessioninfo
local uipallet      = host.Libraries and host.Libraries.uipallet
local tween         = host.Libraries and host.Libraries.tween
local color         = host.Libraries and host.Libraries.color
local whitelist     = host.Libraries and host.Libraries.whitelist
local prediction    = host.Libraries and host.Libraries.prediction
local getfontsize   = host.Libraries and host.Libraries.getfontsize
local getcustomasset= host.Libraries and host.Libraries.getcustomasset

-- store
local store = {
    attackReach = 0,
    attackReachUpdate = tick(),
    damageBlockFail = tick(),
    hand = {},
    inventory = {
        inventory = {
            items = {},
            armor = {}
        },
        hotbar = {}
    },
    inventories = {},
    matchState = 0,
    queueType = 'bedwars_test',
    tools = {}
}

-- locals/registries
local Reach, HitBoxes, InfiniteFly = {}, {}, {}
local TrapDisabler
local AntiFallPart
local bedwars, remotes, sides, oldinvrender, oldSwing = {}, {}, {}

-- blur asset helper (kept for parity)
local function addBlur(parent)
    local blur = Instance.new('ImageLabel')
    blur.Name = 'Blur'
    blur.Size = UDim2.new(1, 89, 1, 52)
    blur.Position = UDim2.fromOffset(-48, -31)
    blur.BackgroundTransparency = 1
    blur.Image = getcustomasset and getcustomasset('newvape/assets/new/blur.png') or ""
    blur.ScaleType = Enum.ScaleType.Slice
    blur.SliceCenter = Rect.new(52, 31, 261, 502)
    blur.Parent = parent
    return blur
end
oofer.Modules.AddBlur = addBlur

-- collection watcher
local function collection(tags, module, customadd, customremove)
    tags = typeof(tags) ~= 'table' and {tags} or tags
    local objs, connections = {}, {}

    for _, tag in tags do
        table.insert(connections, collectionService:GetInstanceAddedSignal(tag):Connect(function(v)
            if customadd then customadd(objs, v, tag) return end
            table.insert(objs, v)
        end))
        table.insert(connections, collectionService:GetInstanceRemovedSignal(tag):Connect(function(v)
            if customremove then customremove(objs, v, tag) return end
            v = table.find(objs, v)
            if v then table.remove(objs, v) end
        end))
        for _, v in collectionService:GetTagged(tag) do
            if customadd then customadd(objs, v, tag) continue end
            table.insert(objs, v)
        end
    end

    local cleanFunc = function(self)
        for _, v in connections do v:Disconnect() end
        table.clear(connections); table.clear(objs); table.clear(self)
    end
    if module and module.Clean then module:Clean(cleanFunc) end
    return objs, cleanFunc
end
oofer.Modules.Collection = collection

-- inventory/meta helpers
local function getBestArmor(slot)
    local closest, mag = nil, 0
    for _, item in store.inventory.inventory.items do
        local meta = item and bedwars.ItemMeta[item.itemType] or {}
        if meta.armor and meta.armor.slot == slot then
            local newmag = (meta.armor.damageReductionMultiplier or 0)
            if newmag > mag then closest, mag = item, newmag end
        end
    end
    return closest
end

local function getBow()
    local bestBow, bestBowSlot, bestBowDamage = nil, nil, 0
    for slot, item in store.inventory.inventory.items do
        local bowMeta = bedwars.ItemMeta[item.itemType].projectileSource
        if bowMeta and table.find(bowMeta.ammoItemTypes, 'arrow') then
            local bowDamage = bedwars.ProjectileMeta[bowMeta.projectileType('arrow')].combat.damage or 0
            if bowDamage > bestBowDamage then
                bestBow, bestBowSlot, bestBowDamage = item, slot, bowDamage
            end
        end
    end
    return bestBow, bestBowSlot
end

local function getItem(itemName, inv)
    for slot, item in (inv or store.inventory.inventory.items) do
        if item.itemType == itemName then
            return item, slot
        end
    end
    return nil
end

local function getRoactRender(func)
    return debug.getupvalue(debug.getupvalue(debug.getupvalue(func, 3).render, 2).render, 1)
end

local function getSword()
    local bestSword, bestSwordSlot, bestSwordDamage = nil, nil, 0
    for slot, item in store.inventory.inventory.items do
        local swordMeta = bedwars.ItemMeta[item.itemType].sword
        if swordMeta then
            local swordDamage = swordMeta.damage or 0
            if swordDamage > bestSwordDamage then
                bestSword, bestSwordSlot, bestSwordDamage = item, slot, swordDamage
            end
        end
    end
    return bestSword, bestSwordSlot
end

local function getTool(breakType)
    local bestTool, bestToolSlot, bestToolDamage = nil, nil, 0
    for slot, item in store.inventory.inventory.items do
        local toolMeta = bedwars.ItemMeta[item.itemType].breakBlock
        if toolMeta then
            local toolDamage = toolMeta[breakType] or 0
            if toolDamage > bestToolDamage then
                bestTool, bestToolSlot, bestToolDamage = item, slot, toolDamage
            end
        end
    end
    return bestTool, bestToolSlot
end

local function getWool(inv)
    for _, wool in (inv or store.inventory.inventory.items) do
        if wool.itemType:find('wool') then
            return wool and wool.itemType, wool and wool.amount
        end
    end
end

local function getStrength(plr)
    if not plr.Player then return 0 end
    local strength = 0
    for _, v in (store.inventories[plr.Player] or {items = {}}).items do
        local itemmeta = bedwars.ItemMeta[v.itemType]
        if itemmeta and itemmeta.sword and itemmeta.sword.damage > strength then
            strength = itemmeta.sword.damage
        end
    end
    return strength
end

local function getPlacedBlock(pos)
    if not pos then return end
    local roundedPosition = bedwars.BlockController:getBlockPosition(pos)
    return bedwars.BlockController:getStore():getBlockAt(roundedPosition), roundedPosition
end

local function getBlocksInPoints(s, e)
    local blocks, list = bedwars.BlockController:getStore(), {}
    for x = s.X, e.X do
        for y = s.Y, e.Y do
            for z = s.Z, e.Z do
                local vec = Vector3.new(x, y, z)
                if blocks:getBlockAt(vec) then table.insert(list, vec * 3) end
            end
        end
    end
    return list
end

local function getNearGround(range)
    range = Vector3.new(3, 3, 3) * (range or 10)
    local localPosition, mag, closest = entitylib.character.RootPart.Position, 60
    local blocks = getBlocksInPoints(bedwars.BlockController:getBlockPosition(localPosition - range), bedwars.BlockController:getBlockPosition(localPosition + range))
    for _, v in blocks do
        if not getPlacedBlock(v + Vector3.new(0, 3, 0)) then
            local newmag = (localPosition - v).Magnitude
            if newmag < mag then mag, closest = newmag, v + Vector3.new(0, 3, 0) end
        end
    end
    table.clear(blocks)
    return closest
end

local function getShieldAttribute(char)
    local returned = 0
    for name, val in char:GetAttributes() do
        if name:find('Shield') and type(val) == 'number' and val > 0 then
            returned += val
        end
    end
    return returned
end

local function getSpeed()
    local multi, increase, modifiers = 0, true, bedwars.SprintController:getMovementStatusModifier():getModifiers()
    for v in modifiers do
        local val = v.constantSpeedMultiplier and v.constantSpeedMultiplier or 0
        if val and val > math.max(multi, 1) then
            increase = false
            multi = val - (0.06 * math.round(val))
        end
    end
    for v in modifiers do
        multi += math.max((v.moveSpeedMultiplier or 0) - 1, 0)
    end
    if multi > 0 and increase then
        multi += 0.16 + (0.02 * math.round(multi))
    end
    return 20 * (multi + 1)
end

local function getTableSize(tab)
    local ind = 0
    for _ in tab do ind += 1 end
    return ind
end

local function hotbarSwitch(slot)
    if slot and store.inventory.hotbarSlot ~= slot then
        bedwars.Store:dispatch({ type = 'InventorySelectHotbarSlot', slot = slot })
        ooferEvents.InventoryChanged:Fire()
        return true
    end
    return false
end

local function isFriend(plr, recolor)
    if oofer.Categories and oofer.Categories.Friends and oofer.Categories.Friends.Options and oofer.Categories.Friends.Options['Use friends'] and oofer.Categories.Friends.Options['Use friends'].Enabled then
        local friend = table.find(oofer.Categories.Friends.ListEnabled, plr.Name) and true
        if recolor then
            friend = friend and oofer.Categories.Friends.Options['Recolor visuals'] and oofer.Categories.Friends.Options['Recolor visuals'].Enabled
        end
        return friend
    end
    return nil
end

local function isTarget(plr)
    return oofer.Categories and oofer.Categories.Targets and table.find(oofer.Categories.Targets.ListEnabled, plr.Name) and true
end

local function notif(...) return (oofer.CreateNotification and oofer:CreateNotification(...)) end

local function removeTags(str)
    str = str:gsub('<br%s*/>', '\n')
    return (str:gsub('<[^<>]->', ''))
end

local function roundPos(vec)
    return Vector3.new(math.round(vec.X / 3) * 3, math.round(vec.Y / 3) * 3, math.round(vec.Z / 3) * 3)
end

local function switchItem(tool, delayTime)
    delayTime = delayTime or 0.05
    local check = lplr.Character and lplr.Character:FindFirstChild('HandInvItem') or nil
    if check and check.Value ~= tool and tool.Parent ~= nil then
        -- intentionally left inert; wire your own safe call here if needed
        -- bedwars.Client:Get(remotes.EquipItem):CallServerAsync({hand = tool})
        check.Value = tool
        if delayTime > 0 then task.wait(delayTime) end
        return true
    end
end

local function waitForChildOfType(obj, name, timeout, prop)
    local check, returned = tick() + timeout
    repeat
        returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
        if returned and returned.Name ~= 'UpperTorso' or check < tick() then break end
        task.wait()
    until false
    return returned
end

-- friction handling
local frictionTable, oldfrict = {}, {}
local frictionConnection
local frictionState

local function modifyVelocity(v)
    if v:IsA('BasePart') and v.Name ~= 'HumanoidRootPart' and not oldfrict[v] then
        oldfrict[v] = v.CustomPhysicalProperties or 'none'
        v.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1)
    end
end

local function updateVelocity(force)
    local newState = getTableSize(frictionTable) > 0
    if frictionState ~= newState or force then
        if frictionConnection then frictionConnection:Disconnect() end
        if newState then
            if entitylib and entitylib.isAlive then
                for _, v in entitylib.character.Character:GetDescendants() do
                    modifyVelocity(v)
                end
                frictionConnection = entitylib.character.Character.DescendantAdded:Connect(modifyVelocity)
            end
        else
            for i, v in oldfrict do
                i.CustomPhysicalProperties = v ~= 'none' and v or nil
            end
            table.clear(oldfrict)
        end
    end
    frictionState = newState
end

-- kit sort order
local kitorder = { hannah = 5, spirit_assassin = 4, dasher = 3, jade = 2, regent = 1 }

-- sort methods
local sortmethods = {
    Damage = function(a, b)
        return a.Entity.Character:GetAttribute('LastDamageTakenTime') < b.Entity.Character:GetAttribute('LastDamageTakenTime')
    end,
    Threat = function(a, b)
        return getStrength(a.Entity) > getStrength(b.Entity)
    end,
    Kit = function(a, b)
        return (a.Entity.Player and kitorder[a.Entity.Player:GetAttribute('PlayingAsKit')] or 0) > (b.Entity.Player and kitorder[b.Entity.Player:GetAttribute('PlayingAsKit')] or 0)
    end,
    Health = function(a, b)
        return a.Entity.Health < b.Entity.Health
    end,
    Angle = function(a, b)
        local selfrootpos = entitylib.character.RootPart.Position
        local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
        local angle = math.acos(localfacing:Dot(((a.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
        local angle2 = math.acos(localfacing:Dot(((b.Entity.RootPart.Position - selfrootpos) * Vector3.new(1, 0, 1)).Unit))
        return angle < angle2
    end
}

-- extend entitylib lifecycle
run(function()
    if not entitylib then return end
    local oldstart = entitylib.start

    local function customEntity(ent)
        if ent:HasTag('inventory-entity') and not ent:HasTag('Monster') then return end
        entitylib.addEntity(ent, nil,
            ent:HasTag('Drone') and function(self)
                local droneplr = playersService:GetPlayerByUserId(self.Character:GetAttribute('PlayerUserId'))
                return not droneplr or lplr:GetAttribute('Team') ~= droneplr:GetAttribute('Team')
            end or function(self)
                return lplr:GetAttribute('Team') ~= self.Character:GetAttribute('Team')
            end
        )
    end

    entitylib.start = function()
        oldstart()
        if entitylib.Running then
            for _, ent in collectionService:GetTagged('entity') do customEntity(ent) end
            table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('entity'):Connect(customEntity))
            table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('entity'):Connect(function(ent)
                entitylib.removeEntity(ent)
            end))
        end
    end

    entitylib.addPlayer = function(plr)
        if plr.Character then entitylib.refreshEntity(plr.Character, plr) end
        entitylib.PlayerConnections[plr] = {
            plr.CharacterAdded:Connect(function(char) entitylib.refreshEntity(char, plr) end),
            plr.CharacterRemoving:Connect(function(char) entitylib.removeEntity(char, plr == lplr) end),
            plr:GetAttributeChangedSignal('Team'):Connect(function()
                for _, v in entitylib.List do
                    if v.Targetable ~= entitylib.targetCheck(v) then
                        entitylib.refreshEntity(v.Character, v.Player)
                    end
                end
                if plr == lplr then
                    entitylib.start()
                else
                    entitylib.refreshEntity(plr.Character, plr)
                end
            end)
        }
    end

    entitylib.addEntity = function(char, plr, teamfunc)
        if not char then return end
        entitylib.EntityThreads[char] = task.spawn(function()
            local hum, humrootpart, head
            if plr then
                hum = waitForChildOfType(char, 'Humanoid', 10)
                humrootpart = hum and waitForChildOfType(hum, 'RootPart', workspace.StreamingEnabled and 9e9 or 10, true)
                head = char:WaitForChild('Head', 10) or humrootpart
            else
                hum = {HipHeight = 0.5}
                humrootpart = waitForChildOfType(char, 'PrimaryPart', 10, true)
                head = humrootpart
            end
            local updateobjects = plr and plr ~= lplr and {
                char:WaitForChild('ArmorInvItem_0', 5),
                char:WaitForChild('ArmorInvItem_1', 5),
                char:WaitForChild('ArmorInvItem_2', 5),
                char:WaitForChild('HandInvItem', 5)
            } or {}

            if hum and humrootpart then
                local entity = {
                    Connections = {},
                    Character = char,
                    Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char),
                    Head = head,
                    Humanoid = hum,
                    HumanoidRootPart = humrootpart,
                    HipHeight = hum.HipHeight + (humrootpart.Size.Y / 2) + (hum.RigType == Enum.HumanoidRigType.R6 and 2 or 0),
                    Jumps = 0,
                    JumpTick = tick(),
                    Jumping = false,
                    LandTick = tick(),
                    MaxHealth = char:GetAttribute('MaxHealth') or 100,
                    NPC = plr == nil,
                    Player = plr,
                    RootPart = humrootpart,
                    TeamCheck = teamfunc
                }

                if plr == lplr then
                    entity.AirTime = tick()
                    entitylib.character = entity
                    entitylib.isAlive = true
                    entitylib.Events.LocalAdded:Fire(entity)
                    table.insert(entitylib.Connections, char.AttributeChanged:Connect(function(attr)
                        ooferEvents.AttributeChanged:Fire(attr)
                    end))
                else
                    entity.Targetable = entitylib.targetCheck(entity)

                    for _, v in entitylib.getUpdateConnections(entity) do
                        table.insert(entity.Connections, v:Connect(function()
                            entity.Health = (char:GetAttribute('Health') or 100) + getShieldAttribute(char)
                            entity.MaxHealth = char:GetAttribute('MaxHealth') or 100
                            entitylib.Events.EntityUpdated:Fire(entity)
                        end))
                    end

                    for _, v in updateobjects do
                        table.insert(entity.Connections, v:GetPropertyChangedSignal('Value'):Connect(function()
                            task.delay(0.1, function()
                                if bedwars.getInventory then
                                    store.inventories[plr] = bedwars.getInventory(plr)
                                    entitylib.Events.EntityUpdated:Fire(entity)
                                end
                            end)
                        end))
                    end

                    if plr then
                        local anim = char:FindFirstChild('Animate')
                        if anim then
                            pcall(function()
                                anim = anim.jump:FindFirstChildWhichIsA('Animation').AnimationId
                                table.insert(entity.Connections, hum.Animator.AnimationPlayed:Connect(function(playedanim)
                                    if playedanim.Animation.AnimationId == anim then
                                        entity.JumpTick = tick()
                                        entity.Jumps += 1
                                        entity.LandTick = tick() + 1
                                        entity.Jumping = entity.Jumps > 1
                                    end
                                end))
                            end)
                        end

                        task.delay(0.1, function()
                            if bedwars.getInventory then
                                store.inventories[plr] = bedwars.getInventory(plr)
                            end
                        end)
                    end
                    table.insert(entitylib.List, entity)
                    entitylib.Events.EntityAdded:Fire(entity)
                end

                table.insert(entity.Connections, char.ChildRemoved:Connect(function(part)
                    if part == humrootpart or part == hum or part == head then
                        if part == humrootpart and hum.RootPart then
                            humrootpart = hum.RootPart
                            entity.RootPart = hum.RootPart
                            entity.HumanoidRootPart = hum.RootPart
                            return
                        end
                        entitylib.removeEntity(char, plr == lplr)
                    end
                end))
            end
            entitylib.EntityThreads[char] = nil
        end)
    end

    entitylib.getUpdateConnections = function(ent)
        local char = ent.Character
        local tab = {
            char:GetAttributeChangedSignal('Health'),
            char:GetAttributeChangedSignal('MaxHealth'),
            {
                Connect = function()
                    ent.Friend = ent.Player and isFriend(ent.Player) or nil
                    ent.Target = ent.Player and isTarget(ent.Player) or nil
                    return {Disconnect = function() end}
                end
            }
        }
        if ent.Player then
            table.insert(tab, ent.Player:GetAttributeChangedSignal('PlayingAsKit'))
        end
        for name, val in char:GetAttributes() do
            if name:find('Shield') and type(val) == 'number' then
                table.insert(tab, char:GetAttributeChangedSignal(name))
            end
        end
        return tab
    end

    entitylib.targetCheck = function(ent)
        if ent.TeamCheck then return ent:TeamCheck() end
        if ent.NPC then return true end
        if isFriend(ent.Player) then return false end
        if not (whitelist and whitelist.get) then return lplr:GetAttribute('Team') ~= ent.Player:GetAttribute('Team') end
        if not select(2, whitelist:get(ent.Player)) then return false end
        return lplr:GetAttribute('Team') ~= ent.Player:GetAttribute('Team')
    end

    entitylib.Events.LocalAdded:Connect(updateVelocity)
end)
if entitylib and entitylib.start then entitylib.start() end

-- Knit/Flamework resolve
run(function()
    local KnitInit, Knit
    repeat
        KnitInit, Knit = pcall(function()
            return debug.getupvalue(require(lplr.PlayerScripts.TS.knit).setup, 9)
        end)
        if KnitInit then break end
        task.wait()
    until KnitInit

    if not debug.getupvalue(Knit.Start, 1) then
        repeat task.wait() until debug.getupvalue(Knit.Start, 1)
    end

    local Flamework = require(replicatedStorage['rbxts_include']['node_modules']['@flamework'].core.out).Flamework
    local InventoryUtil = require(replicatedStorage.TS.inventory['inventory-util']).InventoryUtil
    local Client = require(replicatedStorage.TS.remotes).default.Client
    local OldGet, OldBreak = Client.Get

    bedwars = setmetatable({
        AbilityController = Flamework.resolveDependency('@easy-games/game-core:client/controllers/ability/ability-controller@AbilityController'),
        AnimationType = require(replicatedStorage.TS.animation['animation-type']).AnimationType,
        AnimationUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out['shared'].util['animation-util']).AnimationUtil,
        AppController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.controllers['app-controller']).AppController,
        BedBreakEffectMeta = require(replicatedStorage.TS.locker['break-bed-effect']['break-bed-effect-meta']).BreakBedEffectMeta,
        BedwarsKitMeta = require(replicatedStorage.TS.games.bedwars.kit['bedwars-kit-meta']).BedwarsKitMeta,
        BlockBreaker = Knit.Controllers.BlockBreakController.blockBreaker,
        BlockController = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out).BlockEngine,
        BlockEngine = require(lplr.PlayerScripts.TS.lib['block-engine']['client-block-engine']).ClientBlockEngine,
        BlockPlacer = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.client.placement['block-placer']).BlockPlacer,
        BowConstantsTable = debug.getupvalue(Knit.Controllers.ProjectileController.enableBeam, 8),
        ClickHold = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out.client.ui.lib.util['click-hold']).ClickHold,
        Client = Client,
        ClientConstructor = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts'].net.out.client),
        ClientDamageBlock = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['block-engine'].out.shared.remotes).BlockEngineRemotes.Client,
        CombatConstant = require(replicatedStorage.TS.combat['combat-constant']).CombatConstant,
        DamageIndicator = Knit.Controllers.DamageIndicatorController.spawnDamageIndicator,
        DefaultKillEffect = require(lplr.PlayerScripts.TS.controllers.game.locker['kill-effect'].effects['default-kill-effect']),
        EmoteType = require(replicatedStorage.TS.locker.emote['emote-type']).EmoteType,
        GameAnimationUtil = require(replicatedStorage.TS.animation['animation-util']).GameAnimationUtil,
        getIcon = function(item, showinv)
            local itemmeta = bedwars.ItemMeta[item.itemType]
            return itemmeta and showinv and itemmeta.image or ''
        end,
        getInventory = function(plr)
            local suc, res = pcall(function() return InventoryUtil.getInventory(plr) end)
            return suc and res or { items = {}, armor = {} }
        end,
        HudAliveCount = require(lplr.PlayerScripts.TS.controllers.global['top-bar'].ui.game['hud-alive-player-counts']).HudAlivePlayerCounts,
        ItemMeta = debug.getupvalue(require(replicatedStorage.TS.item['item-meta']).getItemMeta, 1),
        KillEffectMeta = require(replicatedStorage.TS.locker['kill-effect']['kill-effect-meta']).KillEffectMeta,
        KillFeedController = Flamework.resolveDependency('client/controllers/game/kill-feed/kill-feed-controller@KillFeedController'),
        Knit = Knit,
        KnockbackUtil = require(replicatedStorage.TS.damage['knockback-util']).KnockbackUtil,
        MageKitUtil = require(replicatedStorage.TS.games.bedwars.kit.kits.mage['mage-kit-util']).MageKitUtil,
        NametagController = Knit.Controllers.NametagController,
        PartyController = Flamework.resolveDependency('@easy-games/lobby:client/controllers/party-controller@PartyController'),
        ProjectileMeta = require(replicatedStorage.TS.projectile['projectile-meta']).ProjectileMeta,
        QueryUtil = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).GameQueryUtil,
        QueueCard = require(lplr.PlayerScripts.TS         QueueCard = require(lplr.PlayerScripts.TS.controllers.global.queue.ui['queue-card']).QueueCard,
        QueueMeta = require(replicatedStorage.TS.game['queue-meta']).QueueMeta,
        Roact = require(replicatedStorage['rbxts_include']['node_modules']['@rbxts'].roact).default,
        RuntimeLib = require(replicatedStorage['rbxts_include']['RuntimeLib']),
        SoundList = require(replicatedStorage.TS.sound['game-sound']).GameSound,
        SoundManager = require(replicatedStorage['rbxts_include']['node_modules']['@easy-games']['game-core'].out).SoundManager,
        Store = require(lplr.PlayerScripts.TS.ui.store).ClientStore,
        TeamUpgradeMeta = require(replicatedStorage.TS.games.bedwars['team-upgrade']['team-upgrade-meta']).TeamUpgradeMeta,
        UILayers = require(lplr.PlayerScripts.TS.ui['ui-layers']).UILayers,
        VisualizerUtils = require(replicatedStorage.TS.lib.visualizer['visualizer-utils']).VisualizerUtils,
        ViewmodelController = Knit.Controllers.ViewmodelController,
        WeldTable = require(replicatedStorage.TS.util['weld-util']).WeldUtil,
        ZapNetworking = require(replicatedStorage.TS.lib.network['zap-networking']).ZapNetworking
    }, { __index = bedwars })
end)

-- === Store change hook ===
local function updateStore(new, old)
    if new.Bedwars ~= old.Bedwars then
        store.equippedKit = new.Bedwars.kit ~= 'none' and new.Bedwars.kit or ''
    end
    if new.Game ~= old.Game then
        store.matchState = new.Game.matchState
        store.queueType = new.Game.queueType or 'bedwars_test'
    end
    if new.Inventory ~= old.Inventory then
        local newinv = (new.Inventory and new.Inventory.observedInventory or {inventory = {}})
        local oldinv = (old.Inventory and old.Inventory.observedInventory or {inventory = {}})
        store.inventory = newinv
        if newinv ~= oldinv then
            ooferEvents.InventoryChanged:Fire()
        end
        if newinv.inventory.items ~= oldinv.inventory.items then
            ooferEvents.InventoryAmountChanged:Fire()
            store.tools.sword = getSword()
            for _, v in {'stone', 'wood', 'wool'} do
                store.tools[v] = getTool(v)
            end
        end
        if newinv.inventory.hand ~= oldinv.inventory.hand then
            local currentHand, toolType = new.Inventory.observedInventory.inventory.hand, ''
            if currentHand then
                local handData = bedwars.ItemMeta[currentHand.itemType]
                toolType = handData.sword and 'sword' or handData.block and 'block' or currentHand.itemType:find('bow') and 'bow'
            end
            store.hand = {
                tool = currentHand and currentHand.tool,
                amount = currentHand and currentHand.amount or 0,
                toolType = toolType
            }
        end
    end
end
local storeChanged = bedwars.Store.changed:connect(updateStore)
updateStore(bedwars.Store:getState(), {})

-- === Event wiring ===
for _, event in {'MatchEndEvent','EntityDeathEvent','BedwarsBedBreak','BalloonPopped','AngelProgress','GrapplingHookFunctions'} do
    bedwars.Client:WaitFor(event):andThen(function(connection)
        oofer:Clean(connection:Connect(function(...)
            ooferEvents[event]:Fire(...)
        end))
    end)
end

oofer:Clean(bedwars.ZapNetworking.EntityDamageEventZap.On(function(...)
    ooferEvents.EntityDamageEvent:Fire({
        entityInstance = ...,
        damage = select(2, ...),
        damageType = select(3, ...),
        fromPosition = select(4, ...),
        fromEntity = select(5, ...),
        knockbackMultiplier = select(6, ...),
        knockbackId = select(7, ...),
        disableDamageHighlight = select(13, ...)
    })
end))

for _, event in {'PlaceBlockEvent','BreakBlockEvent'} do
    oofer:Clean(bedwars.ZapNetworking[event..'Zap'].On(function(...)
        local data = {
            blockRef = { blockPosition = ... },
            player = select(5, ...)
        }
        ooferEvents[event]:Fire(data)
    end))
end

-- === Collections ===
store.blocks = collection('block', nil)
store.shop = collection({'BedwarsItemShop','TeamUpgradeShopkeeper'}, nil, function(tab, obj)
    table.insert(tab, {
        Id = obj.Name,
        RootPart = obj,
        Shop = obj:HasTag('BedwarsItemShop'),
        Upgrades = obj:HasTag('TeamUpgradeShopkeeper')
    })
end)
store.enchant = collection({'enchant-table','broken-enchant-table'}, nil, nil, function(tab, obj, tag)
    if obj:HasTag('enchant-table') and tag == 'broken-enchant-table' then return end
    obj = table.find(tab, obj)
    if obj then table.remove(tab, obj) end
end)

-- === Session stats ===
local kills = sessioninfo:AddItem('Kills')
local beds  = sessioninfo:AddItem('Beds')
local wins  = sessioninfo:AddItem('Wins')
local games = sessioninfo:AddItem('Games')
local mapname = 'Unknown'
sessioninfo:AddItem('Map', 0, function() return mapname end, false)

task.delay(1, function() games:Increment() end)

task.spawn(function()
    pcall(function()
        repeat task.wait() until store.matchState ~= 0 or oofer.Loaded == nil
        if oofer.Loaded == nil then return end
        mapname = workspace:WaitForChild('Map', 5):WaitForChild('Worlds', 5):GetChildren()[1].Name
        mapname = string.gsub(string.split(mapname, '_')[2] or mapname, '-', '') or 'Blank'
    end)
end)

oofer:Clean(ooferEvents.BedwarsBedBreak.Event:Connect(function(bedTable)
    if bedTable.player and bedTable.player.UserId == lplr.UserId then
        beds:Increment()
    end
end))

oofer:Clean(ooferEvents.MatchEndEvent.Event:Connect(function(winTable)
    if (bedwars.Store:getState().Game.myTeam or {}).id == winTable.winningTeamId or lplr.Neutral then
        wins:Increment()
    end
end))

oofer:Clean(ooferEvents.EntityDeathEvent.Event:Connect(function(deathTable)
    local killer = playersService:GetPlayerFromCharacter(deathTable.fromEntity)
    local killed = playersService:GetPlayerFromCharacter(deathTable.entityInstance)
    if not killed or not killer then return end
    if killed ~= lplr and killer == lplr then
        kills:Increment()
    end
end))

-- === Air/jump reset loop ===
task.spawn(function()
    repeat
        if entitylib.isAlive then
            entitylib.character.AirTime = entitylib.character.Humanoid.FloorMaterial ~= Enum.Material.Air and tick() or entitylib.character.AirTime
        end
        for _, v in entitylib.List do
            v.LandTick = math.abs(v.RootPart.Velocity.Y) < 0.1 and v.LandTick or tick()
            if (tick() - v.LandTick) > 0.2 and v.Jumps ~= 0 then
                v.Jumps = 0
                v.Jumping = false
            end
        end
        task.wait()
    until oofer.Loaded == nil
end)

-- === Shop preload ===
pcall(function()
    if getthreadidentity and setthreadidentity then
        local old = getthreadidentity()
        setthreadidentity(2)
        bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
        bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2)
        bedwars.Shop.getShopItem('iron_sword', lplr)
        setthreadidentity(old)
        store.shopLoaded = true
    else
        task.spawn(function()
            repeat task.wait(0.1) until oofer.Loaded == nil or bedwars.AppController:isAppOpen('BedwarsItemShopApp')
            bedwars.Shop = require(replicatedStorage.TS.games.bedwars.shop['bedwars-shop']).BedwarsShop
            bedwars.ShopItems = debug.getupvalue(debug.getupvalue(bedwars.Shop.getShopItem, 1), 2)
            store.shopLoaded = true
        end)
    end
end)

-- === Cleanup ===
oofer:Clean(function()
    Client.Get = OldGet
    bedwars.BlockController.isBlockBreakable = OldBreak
    if store.blockPlacer and store.blockPlacer.disable then
        store.blockPlacer:disable()
    end
    for _, v in ooferEvents do v:Destroy() end
    table.clear(store)
    table.clear(sides)
    table.clear(remotes)
    if storeChanged then storeChanged:disconnect() end
end)

-- Remove unwanted modules
for _, v in {'AntiRagdoll','TriggerBot','SilentAim','AutoRejoin','Re    'Rejoin','Disabler','Timer','ServerHop','MouseTP','MurderMystery'} do
    if oofer.Remove then
        oofer:Remove(v)
    end
end

-- Final export
return oofer.Modules
