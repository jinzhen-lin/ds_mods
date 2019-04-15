local lastfound = -1
local interiorspawner = GetWorld().components.interiorspawner
local function findnext_entity(prefablist, musttags, canttags, mustoneoftags)
    local player = GetPlayer()
    local radius = 10000

    local trans = player.Transform
    local found = nil
    local foundlowestid = nil
    local reallowest = nil
    local reallowestid = nil

    local x, y, z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags)
    for k, v in pairs(ents) do
        if v ~= player and table.contains(prefablist, v.prefab) then
            if v.GUID > lastfound and (foundlowestid == nil or v.GUID < foundlowestid) then
                found = v
                foundlowestid = v.GUID
            end
            if not reallowestid or v.GUID < reallowestid then
                reallowest = v
                reallowestid = v.GUID
            end
        end
    end
    if not found then
        found = reallowest
    end
    if found then
        lastfound = found.GUID
    end
    return found
end

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

local function InitAllInteriors()
    -- 显示遗迹内的全部房间
    local intervel_time = FRAMES * 3
    local current_interior = interiorspawner.current_interior    
    if current_interior then
        local interiors = interiorspawner:GetInteriorsByDungeonName(current_interior.dungeon_name)
        local i = 0
        for _, v in pairs(interiors) do
            -- 给每个房间足够的时间初始化
            -- 某些房间里的物品需要一定时间才能完成初始化，如果未完成就的话会导致崩溃
            -- 比如末日时钟
            GetWorld():DoTaskInTime(intervel_time * i, function()
                interiorspawner:UnloadInterior()
                interiorspawner:LoadInterior(v)
            end)
            i = i + 1
        end
        GetWorld():DoTaskInTime(intervel_time * i, function()
            interiorspawner:UnloadInterior()
            interiorspawner:LoadInterior(current_interior)
        end)
    end
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

local function gotoswitch(prefablist, musttags, canttags, mustoneoftags)
    return function()
        local found = findnext_entity(prefablist, musttags, canttags, mustoneoftags)
        local player = GetPlayer()
        if not found or not player then
            return 
        end

        local x, y, z = found:GetPosition():Get()
        water_teleport_handle(player, x, y, z)

        if interiorspawner then
            if not interiorspawner.current_interior and found.ininterior then
                -- 目标在室内但玩家不在室内
                goto_interior(found.interior, found)
            elseif interiorspawner.current_interior and not found.ininterior then
                -- 目标不在室内但玩家在室内
                goto_interior(nil, found)
            elseif interiorspawner.current_interior and found.interior then
                -- 玩家和目标不在同一个室内
                goto_interior(found.interior, found)
            end
        end
        c_goto(found)
    end
end

local function ShowMap()
    -- 密集网格取点，显示每个点周围的地图
    local w, h = GetWorld().Map:GetSize()
    for x = -w * 2, w * 2, 15 do
        for z = -h * 2, h * 2, 15 do
            local cx, cy, cz = GetWorld().Map:GetTileCenterPoint(x, 0, z)
            if cx and cy and cz then
                GetWorld().minimap.MiniMap:ShowArea(cx, cy, cz, 30)
                GetWorld().Map:VisitTile(GetWorld().Map:GetTileCoordsAtPoint(cx, cy, cz))
            end
        end
    end
end


local MAP_LIST = {
    forest = {
        {{"cave_entrance_open", "cave_entrance"}},
        {{"pigking"}},
        {{"walrus_camp"}},
        {{"wormhole", "wormhole_limited_1"}},
        {{"adventure_portal"}},
        {{"teleportato_base", "teleportato_checkmate"}},
        {{"sunken_boat"}},
        {{"chester_eyebone"}},
        {{"dirtpile"}},
    },

    rog_forest = {
        {{"statueglommer"}},
    },

    cave1 = {
        {{"cave_exit"}, name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_CAVE_EXIT},
        {{"cave_entrance_open", "cave_entrance"}},
        {{"tentacle_pillar", "tentacle_garden"}},
        {{"slurtlehole"}},
        {{"chester_eyebone"}},
    },

    cave2 = {
        {{"cave_exit"}, name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_CAVE_EXIT},
        {{"pond_cave"}},
        {{"ancient_altar", "ancient_altar_broken"}},
        {{"minotaur"}},
        {{"chester_eyebone"}},
    },

    shipwrecked = {
        {{"volcano"}},
        {{"octopusking"}},
        {{"coral_brain_rock"}},
        {{"swordfish"}},
        {{"wreck"}},
        {
            {"sharkittenspawner"},
            name = STRINGS.NAMES.SHARKITTENSPAWNER_ACTIVE,
        },
        {{"teleportato_sw_base", "teleportato_sw_checkmate"}},
        {{"slotmachine"}},
        {{"shipwrecked_exit"}},
        {{"mermhouse_fisher"}},
        {{"doydoy"}},
        {{"packim_fishbone"}},
        {{"whale_bubbles"}},
    },

    volcanolevel = {
        {{"volcano_altar"}},
        {{"obsidian_workbench"}},
        {{"volcano_exit"}, name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_VOLCANO_EXIT},
        {{"packim_fishbone"}},
    },

    porkland = {
        {
            beta = false,
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOW_ALL_ROOMS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOW_ALL_ROOMSTIP,
            fn = InitAllInteriors,
        },
        {{"pig_palace"}},
        {{"playerhouse_city"}},
        {{"pugalisk_fountain"}},
        {{"anthill"}},
        {{"vampirebatcave"}},
        {{"mandrakehouse"}},
        {
            {"roc_nest"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_ROC_NEST
        },
        {
            {"pig_ruins_entrance_small"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_PIGRUINS_COMMON_FORMAT:format(STRINGS.NAMES.PIG_RUINS_ENTRANCE),
        },
        {
            {"pig_ruins_entrance", "pig_ruins_entrance2", "pig_ruins_entrance3", "pig_ruins_entrance4", "pig_ruins_entrance5"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_PIGRUINS_SPECIAL_FORMAT:format(STRINGS.NAMES.PIG_RUINS_ENTRANCE),
        },
        {{"deco_ruins_fountain"}},
        {{"ancient_robot_ribs", "ancient_robot_claw", "ancient_robot_leg", "ancient_robot_head"}},
        {{"ro_bin_gizzard_stone"}},
    }
}

local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_TEXT,
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOW.."1",
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOWTIP1,
            fn = 'GetWorld().minimap.MiniMap:ShowArea(0, 0, 0, 10000)'
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOW.."2",
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_SHOWTIP2,
            fn = ShowMap,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_HIDE,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_HIDETIP,
            fn = 'GetWorld().minimap.MiniMap:ClearRevealedAreas(true)',
        }
    }
}

for k1, v1 in pairs(MAP_LIST) do
    for k2, v2 in pairs(v1) do
        local map_item = {
            beta = false,
            pos = k1,
            name = v2["name"] or STRINGS.NAMES[v2[1][1]:upper()] or v2[1][1]:upper(),
            tip = v2["tip"],
            fn = v2["fn"] or gotoswitch(v2[1], v2["musttags"], v2["canttags"], v2["mustoneoftags"])
        }
        if map_item["tip"] == nil then
            map_item["tip"] = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_TELEPORTTIP..map_item["name"]
        end
        table.insert(res["list"], map_item)
    end
end

return res