local SetDurabilityScreen = require "screens/TMI_setdurability"

local function DeleteEntity()
    local player = GetPlayer()
    local function InInv(b)
        local inv = b.components.inventoryitem
        return inv and inv.owner and true or false
    end
    local function CanDelete(inst)
        if inst and inst ~= GetWorld() and not InInv(inst) and inst.Transform then
            local x, y, z = inst:GetPosition():Get()
            if x == 0 and y == 0 and z == 0 then
                return false
            elseif inst:HasTag("player") then
                if inst ~= player then
                    return true
                end
            else
                if inst.prefab:sub(-3) == "_fx" then
                    return false
                end
                if Prefabs[inst.prefab] and Prefabs[inst.prefab].path then
                    local prefabpath = Prefabs[inst.prefab].path
                    if prefabpath:sub(1, 10) == "common/fx/" then
                        return false
                    end
                    if prefabpath:sub(1, 3) == "fx/" then
                        return false
                    end
                    return true
                end
            end
        end
        return false
    end
    if player and player.Transform then
        if player.components.burnable then
            player.components.burnable:Extinguish(true)
        end
        local x, y, z = player.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 5)
        for _, obj in pairs(ents) do
            if CanDelete(obj) then
                if obj.components then
                    if obj.components.burnable then
                        obj.components.burnable:Extinguish(true)
                    end
                    if obj.components.firefx then
                        if obj.components.firefx.extinguishsoundtest then
                            obj.components.firefx.extinguishsoundtest = function()
                                return true
                            end
                        end
                        obj.components.firefx:Extinguish()
                    end
                end
                print(obj.prefab)
                obj:Remove()
            end
        end
    end
end


local function FertilizePlant()
    local player = GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30)
    local poop = nil
    for k, obj in pairs(ents) do
        if not obj:HasTag('player') and obj ~= GetWorld() and obj.AnimState and obj.Transform then
            if not (poop and poop.components and poop.components.fertilizer) then
                poop = c_spawn('poop')
            end
            if obj and obj.components.crop and not obj.components.crop:IsReadyForHarvest() and not obj:HasTag('withered') then
                obj.components.crop:Fertilize(poop)
            elseif obj.components.grower and obj.components.grower:IsEmpty() then
                obj.components.grower:Fertilize(poop)
            elseif obj.components.pickable and obj.components.pickable:CanBeFertilized() then
                obj.components.pickable:Fertilize(poop)
            elseif obj.components.hackable and obj.components.hackable:CanBeFertilized() then
                obj.components.hackable:Fertilize(poop)
            end
        end
    end
    if poop ~= nil then
        poop:Remove()
    end
end

local function PlantGrowth()
    local player = GetPlayer()
    local function trygrowth(inst)
        if inst:IsInLimbo() or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then
            return
        end
        if inst.components.hackable ~= nil then
            if inst.components.hackable.canbehacked then
                return
            end
            inst.components.hackable:Regen()
        end
        if inst:HasTag("stump") then
            return
        end
        if inst.components.pickable ~= nil then
            if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
                return
            end
            inst.components.pickable:FinishGrowing()
        end
        if inst.components.crop ~= nil then
            inst.components.crop:DoGrow(TUNING.TOTAL_DAY_TIME * 3, true)
        end
        if inst.components.growable ~= nil and inst:HasTag("tree") and not inst:HasTag("stump") then
            inst.components.growable:DoGrowth()
        end
        if inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and inst:HasTag("mushroom_farm") then
            inst.components.harvestable:Grow()
        end
    end
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, nil, {"pickable", "withered", "INLIMBO" })
    if #ents > 0 then
        trygrowth(table.remove(ents, math.random(#ents)))
        if #ents > 0 then
            local timevar = 1 - 1 / (#ents + 1)
            for i, v in ipairs(ents) do
                v:DoTaskInTime(timevar * math.random(), trygrowth)
            end
        end
    end
end

local function HarvestPlant()
    local player = GetPlayer()
    if not player or player:HasTag("playerghost") then
        return
    end
    local function tryharvest(inst)
        local objc = inst.components
        if objc.crop ~= nil then
            objc.crop:Harvest(player)
        elseif objc.harvestable ~= nil then
            objc.harvestable:Harvest(player)
        elseif objc.stewer ~= nil then
            objc.stewer:Harvest(player)
        elseif objc.dryer ~= nil then
            objc.dryer:Harvest(player)
        elseif objc.occupiable ~= nil and objc.occupiable:IsOccupied() then
            local item = objc.occupiable:Harvest(player)
            if item ~= nil then
                player.components.inventory:GiveItem(item)
            end
        elseif objc.pickable ~= nil and objc.pickable:CanBePicked() then
            objc.pickable:Pick(player)
        end
    end
    local function harvesting()
        local x, y, z = player.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 30)
        for k, obj in pairs(ents) do
            if not obj:HasTag("player") and
            not obj:HasTag("flower") and
            not obj:HasTag("trap") and
            not obj:HasTag("mine") and
            not obj:HasTag("cage") and
            obj ~= GetWorld() and
            obj.AnimState and
            obj.components and
            obj.prefab and
            obj.prefab ~= "birdcage" and
            not string.find(obj.prefab, "mandrake") then
                tryharvest(obj)
            end
        end
    end
    harvesting()
end

local function PickEntity()
    local player = GetPlayer()
    if not player or player:HasTag("playerghost") then
        return
    end
    local inv = player.components.inventory
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, nil, { "INLIMBO", "NOCLICK", "catchable", "fire" })
    local baits = {
        ["powcake"] = true,
        ["pigskin"] = true,
        ["winter_food4"] = true,
    }
    local function Wall(item)
        local xx, yy, zz = item.Transform:GetWorldPosition()
        local nents = TheSim:FindEntities(xx, yy, zz, 3)
        local targets = 0
        for _, vv in ipairs(nents) do
            if vv:HasTag("wall") and vv.components.health then
                targets = targets + 1
            end
        end
        return targets
    end
    for _, v in ipairs(ents) do
        local c = v.components
        if c.inventoryitem ~= nil and
        c.inventoryitem.canbepickedup and
        c.inventoryitem.cangoincontainer and
        not c.inventoryitem:IsHeld() and
        not v:HasTag("flower") and
        not v:HasTag("trap") and
        not v:HasTag("mine") and
        not v:HasTag("cage") and
        not v:HasTag("bookshelfed") and
        inv then
            if c.trap ~= nil and c.trap:IsSprung() then
                c.trap:Harvest(player)
            else
                if baits[v.prefab] then
                    if Wall(v) < 7 then
                        inv:GiveItem(v)
                    end
                else
                    if c.bait then
                        if not c.bait.trap then
                            inv:GiveItem(v)
                        end
                    else
                        inv:GiveItem(v)
                    end
                end
            end
        end
    end
end


local function FrozenEntity()
    local player = GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15)
    for k, obj in pairs(ents) do
        if not obj:HasTag('player') and
        obj ~= GetWorld() and
        obj.AnimState and
        obj.Transform and
        obj.components and
        obj.components.freezable ~= nil then
            obj.components.freezable:AddColdness(1, 60)
            obj.components.freezable:SpawnShatterFX()
        end
    end
end


local function ExtinguishEntity()
    local player = GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15)
    for k, obj in pairs(ents) do
        if obj ~= GetWorld() and
        obj.AnimState and
        obj.Transform and
        obj.components and
        obj.components.burnable and
        obj.components.burnable:IsBurning() then
            obj.components.burnable:Extinguish()
        end
    end
end

local function BlockFlooding()
    local player = GetPlayer()
    local x, y, z = player.Transform:GetWorldPosition()
    local r = 12
    for cx = -r, r, 1 do
        for cz = -r, r, 1 do
            if (cx ^ 2 + cz ^ 2) <= r ^ 2 then
                GetWorld().Flooding:SetIsPositionBlocked(x + cx, 0, z + cz, true, true)
                GetWorld().Flooding:SetIsPositionBlocked(x + cx, 0, z + cz, false, false)
            end
        end
    end
end

local function ClearSnow()
    GetSeasonManager().ground_snow_level = 0
end

local function SetDurability()
    if TheInput:IsKeyDown(KEY_CTRL) then
        TheFrontEnd:PushScreen(SetDurabilityScreen())
        return
    end
    
    local player = GetPlayer()
    if not player or not player.components.inventory then
        return
    end
    local inventory = player.components.inventory
    local items
    local active_item = inventory:GetActiveItem()
    if active_item ~= nil then
        items = {active_item}
    else
        items = inventory.equipslots
    end

    local durability
    if type(TOOMANYITEMS.DATA.DURABILITY) == "number" then
        durability = TOOMANYITEMS.DATA.DURABILITY
    else
        durability = 1
    end

    durability = math.max(0, math.min(1, durability))
    for k, v in pairs(items) do
        if v.components.perishable then
            v.components.perishable:SetPercent(durability)
        end

        if v.components.finiteuses then
            v.components.finiteuses:SetPercent(durability)
        end

        if v.components.fueled then
            v.components.fueled:SetPercent(durability)
        end

        if v.components.armor then
            v.components.armor:SetPercent(durability)
        end
    end
end

local function CopyEntity()
    local player = GetPlayer()
    if not player or not player.components.inventory then
        return
    end
    local inventory = player.components.inventory
    local active_item = inventory:GetActiveItem()
    local data = active_item:GetSaveRecord()
    local new_item = SpawnSaveRecord(data)
    player.components.inventory:GiveItem(new_item)
end

local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_TEXT,
    tag = "entity",
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_DELETE,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_DELETETIP,
            fn = DeleteEntity,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_FERTILIZER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_FERTILIZERTIP,
            fn = FertilizePlant,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_GROWTH,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_GROWTHTIP,
            fn = PlantGrowth,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_HARVEST,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_HARVESTTIP,
            fn = HarvestPlant,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_PICK,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_PICKTIP,
            fn = PickEntity,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_FROZEN,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_FROZENTIP,
            fn = FrozenEntity,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_EXTINGUISH,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_EXTINGUISHTIP,
            fn = ExtinguishEntity,
        },
        {
            beta = false,
            pos = "shipwrecked",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_BLOCKFLOODING,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_BLOCKFLOODINGTIP,
            fn = BlockFlooding,
        },
        {
            beta = false,
            pos = "forest",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_CLEARSNOW,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_CLEARSNOWTIP,
            fn = ClearSnow,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_SETDURABILITY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_SETDURABILITYTIP,
            fn = SetDurability,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_COPY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_ENTITY_COPY,
            fn = CopyEntity,
        }
    },
}

return _TMI.ModifyDebuglist(res, "entity", _TMI.locals())