
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
    if not GROUND.OCEAN_SHALLOW then
        return
    end
    local boating = inst.components.driver and inst.components.driver:GetIsDriving()
    local onwater = GetWorld().Map:GetTileAtPoint(x, y, z) >= GROUND.OCEAN_SHALLOW
    if boating and onwater == false then
        -- 在船上但目标在地面，则将船停在原处
        inst.components.driver:OnDismount()
    elseif not boating and onwater == true then
        -- 不在船上但目标在水上，则生成一艘木筏并乘上船
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
        if interiorspawner then
            local current_interior = interiorspawner.current_interior and interiorspawner.current_interior.unique_name or nil
            local door
            for _, v in ipairs(interiorspawner:GetInteriorDoors(interior)) do
                door = v
                break
            end
            if current_interior ~= interior and door then
                goto_interior(interior, door.inst)
            end
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

local function Teleport(slot_num)
    return function()
        if TheInput:IsKeyDown(KEY_CTRL) then
            SaveTeleportData(slot_num)
        else
            LoadTeleportData(slot_num)
        end
    end
end

local function GetTeleportList()
    local telelist = {}
    for i = 1, 7 do
        telelist[i] = {
            beta = false,
            pos = "all",
            name = '[ '..i..' ]',
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TELEPORT_TIP,
            fn = Teleport(i),
        }
    end
    return telelist
end


local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TELEPORT,
    tag = "teleport_load",
    list = GetTeleportList()
}

return _TMI.ModifyDebuglist(res, "teleport", _TMI.locals())