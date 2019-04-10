
local savepath = TOOMANYITEMS.GetTeleportSavePath()

local function LoadTeleportData(slot_num)
    if slot_num and type(slot_num) == "number" then
        slot_num = "slot"..slot_num
        local x = TOOMANYITEMS.TELEPORT_DATA[slot_num] and TOOMANYITEMS.TELEPORT_DATA[slot_num]["x"]
        local z = TOOMANYITEMS.TELEPORT_DATA[slot_num] and TOOMANYITEMS.TELEPORT_DATA[slot_num]["z"]
        if x and z and type(x) == "number" and type(z) == "number" then
            local player = GetPlayer()
            if player ~= nil then
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