
local savepath = TOOMANYITEMS.GetTeleportSavePath()
local interiorspawner = GetWorld().components.interiorspawner

local function goto_interior(to_interior, to_target)
    if to_target == nil then
        to_target = GetPlayer()
    end
    local is_invincible = GetPlayer().components.health:IsInvincible()
    GetPlayer().components.health:SetInvincible(true)
    GetWorld().doorfreeze = true
    interiorspawner.to_target = to_target
    interiorspawner.to_interior = to_interior
    interiorspawner:FadeOutFinished()
    GetPlayer().components.health:SetInvincible(is_invincible)
end

local function water_teleport_handle(inst, x, y, z)
    local allow_water = true
    local boating = inst.components.driver and inst.components.driver:GetIsDriving()
    local onwater
    if GROUND.OCEAN_SHALLOW then
        onwater = GetWorld().Map:GetTileAtPoint(x, 0, z) >= GROUND.OCEAN_SHALLOW
    else
        allow_water = false
    end
    
    if boating and onwater == false then
        -- 在船上但目标在地面，则将船停在原处
        if not allow_water then
            return
        end
        inst.components.driver:OnDismount()
    elseif not boating and onwater == true then
        -- 不在船上但目标在水上，则生成一艘木筏并乘上船
        if not allow_water then
            return
        end
        local boat = SpawnPrefab("lograft")
        if boat then
            inst.components.driver:OnMount(boat)
            boat.components.drivable:OnMounted(inst)
        end
    end
end

local function LoadTeleportData(slot_num)
    if slot_num and type(slot_num) == "number" then
        slot_num = "slot"..slot_num
        local interior = TOOMANYITEMS.TELEPORT_DATA[slot_num] and TOOMANYITEMS.TELEPORT_DATA[slot_num]["interior"]
        local current_interior = interiorspawner.current_interior and interiorspawner.current_interior.unique_name or nil
        local door
        for _, v in ipairs(interiorspawner:GetInteriorDoors(interior)) do
            door = v
        end
        if interiorspawner and current_interior ~= interior and door then
            goto_interior(interior, door.inst)
        end

        local x = TOOMANYITEMS.TELEPORT_DATA[slot_num] and TOOMANYITEMS.TELEPORT_DATA[slot_num]["x"]
        local z = TOOMANYITEMS.TELEPORT_DATA[slot_num] and TOOMANYITEMS.TELEPORT_DATA[slot_num]["z"]

        if x and z and type(x) == "number" and type(z) == "number" then
            local player = GetPlayer()
            if player ~= nil then
                water_teleport_handle(player, x, 0, z)
                if player.Physics ~= nil then
                    player.Physics:Teleport(x, 0, z)
                else
                    player.Transform:SetPosition(x, 0, z)
                end
            end
        end
    end
end

local function SaveTeleportData(slot_num)
    local x, _, z = GetPlayer().Transform:GetWorldPosition()
    if x and z and slot_num and type(x) == "number" and type(z) == "number" and type(slot_num) == "number" then
        slot_num = "slot"..slot_num
        TOOMANYITEMS.TELEPORT_DATA[slot_num] = {}
        TOOMANYITEMS.TELEPORT_DATA[slot_num]["x"] = x
        TOOMANYITEMS.TELEPORT_DATA[slot_num]["z"] = z
        if interiorspawner and interiorspawner.current_interior then
            TOOMANYITEMS.TELEPORT_DATA[slot_num]["interior"] = interiorspawner.current_interior.unique_name
        end

        if TOOMANYITEMS.DATA_SAVE == 1 then
            TOOMANYITEMS.SaveData(savepath, TOOMANYITEMS.TELEPORT_DATA)
        end
    end
end

local function GetTeleportList(Teleportfn)
    local telelist = {}
    for i = 1, 7 do
        telelist[i] = {
            beta = false,
            pos = "all",
            name = '[ '..i..' ]',
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TELEPORT_SLOT.." "..i,
            fn = {
                TeleportNum = i,
                TeleportFn = Teleportfn,
            },
        }
    end
    return telelist
end

return {
    {
        tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TELEPORT_SAVE_TEXT,
        list = GetTeleportList(SaveTeleportData)
    },
    {
        tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TELEPORT_LOAD_TEXT,
        list = GetTeleportList(LoadTeleportData)
    }
}