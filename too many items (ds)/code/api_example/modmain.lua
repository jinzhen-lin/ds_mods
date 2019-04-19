local _G = GLOBAL

modimport("tmi_utils_api.lua")

-- Example for "AddItemlistPostInit"
-- add "log" to "gift" itemlist
-- 往“礼物”物品列表中添加木头
_G._TMI.AddItemlistPostInit("gift", function(list)
    table.insert(list, "log")
    return list
end)

-- Example for "AddAllItemlistPostInit"
-- modify the itemlist, set "others" itemlist to be the same with "all" itemlist
-- 修改物品列表，将“其他”物品列表中的物品设为与“所有”列表中的一样
_G._TMI.AddAllItemlistPostInit(function(list)
    list["others"] = list["all"]
    return list
end)

-- Example for "AddDebuglistPostInit"
-- add a function to the "player" debuglist
-- 往”角色”调试功能列表中添加一个功能
_G._TMI.AddDebuglistPostInit("player", function(list, envs)
    local say_something = {
        beta = false,
        pos = "all",
        name = "Say",
        tip = "Say",
        fn = function() _G.GetPlayer().components.talker:Say("This is a test")  end,
    }
    table.insert(list["list"], say_something)
    return list
end)

-- Example for "AddDebuglistPostInit"
-- add a teleport destation to the "map" debuglist
-- 往”地图”当中添加一个传送地点
_G._TMI.AddDebuglistPostInit("map", function(list, envs)
    local goto_grass = {
        beta = false,
        pos = {"shipwrecked", "forest", "porkland"},
        name = "Grass",
        tip = _G.STRINGS.TOO_MANY_ITEMS_UI.DEBUG_MAP_TELEPORTTIP.."Grass",
        fn = envs.gotoswitch({"grass", "grass_tall"})
    }
    table.insert(list["list"], goto_grass)
    return list
end)

-- Example for "AddAllDebuglistPostInit"
-- delete all debuglists except "player", "map", and "game"
-- 删除除了“玩家”、“地图”、“游戏”三个列表之外其他所有的调试功能列表
_G._TMI.AddAllDebuglistPostInit(function(list)
    local new_list = {}
    for _, v in pairs(list) do
        if table.contains({"player", "map", "game"}, v.tag) then
            table.insert(new_list, v)
        end
    end
    return new_list
end)


-- Example for "AddSpecialSpawn"
-- Put eyebone, a grass and a log in the generated chester
-- 在生成的切斯特当中放入对应的眼骨以及一个草和一个木头
_G._TMI.AddSpecialSpawn("chester+witheyebone", function(inst)
    local leader = _G.SpawnPrefab("chester_eyebone")
    inst.components.follower.leader = leader
    inst.components.container:GiveItem(leader)
    local grass = _G.SpawnPrefab("cutgrass")
    inst.components.container:GiveItem(grass)
    local log = _G.SpawnPrefab("log")
    inst.components.container:GiveItem(log)
end)


-- Example for "AddIconbuttonlistPostInit"
-- Exchange the position of health button and sanity button
-- 交换健康按钮与精神按钮的位置
_G._TMI.AddIconbuttonlistPostInit(function(list, envs)
    local pos_tmp = list["health"]["pos"]
    list["health"]["pos"] = list["sanity"]["pos"]
    list["sanity"]["pos"] = pos_tmp
    return list
end)


-- Example for "AddItemAssetlistPostInit"
-- Set the log icon to the log icon of Hamlet, set the butterfly icon to the butterfly icon of shipwrecked
-- 使得木头显示为哈姆雷特中木头的图标，蝴蝶显示为船难中蝴蝶的图标
_G._TMI.AddItemAssetlistPostInit(function(item, itematlas_list, itemimage_list)
    if item == "log" then
        itemimage_list = {"log_rainforest.tex"}
    elseif item == "butterfly" then
        itemimage_list = {"butterfly_tropical.tex"}
    end
    return itematlas_list, itemimage_list
end)


-- Example for "AddTranslation"
-- Modify the text for "BUTTON_HEALTH" and "BUTTON_SANITY"
-- 修改健康按钮和精神按钮的提示文字
_G._TMI.AddTranslation({
    ["BUTTON_HEALTH"] = "BUTTON_HEALTH",
    ["BUTTON_SANITY"] = "BUTTON_SANITY",
}, true)