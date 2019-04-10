

local IS_SURVIVAL = SaveGameIndex:IsModeSurvival()
local IS_SW = SaveGameIndex:IsModeShipwrecked()
local IS_HAMLET = SaveGameIndex:IsModePorkland()


local inventory_imgname = {
    ["seagull_water"] = "seagull",
    ["cutlichen"] = "algae",
    ["deadlyfeast"] = "bonestew",
    ["heatrock"] = "heat_rock3",
    ["maxwellkey"] = "purplegem",
    ["mosquito_poison"] = "mosquito_yellow",
    ["banditmap"] = "stash_map",
    ["corkboat_item"] = "corkboat",
    ["boat_lantern"] = "boat_lantern_off",
    ["boat_torch"] = "boat_torch_off",
    ["clippings"] = "cut_hedge",
    ["doydoybaby"] = "doydoy_baby",
    ["doydoyegg_cracked"] = "doydoyegg",
    ["player_house_cottage_craft"] = "player_house_cottage",
    ["player_house_villa_craft"] = "player_house_villa",
    ["player_house_manor_craft"] = "player_house_manor",
    ["player_house_tudor_craft"] = "player_house_tudor",
    ["player_house_gothic_craft"] = "player_house_gothic",
    ["player_house_brick_craft"] = "player_house_brick",
    ["player_house_turret_craft"] = "player_house_turret",
    ["fish_med"] = "fish_dogfish",
    ["fish_raw_small_cooked"] = "fishtropical_cooked",
    ["glowfly"] = "lantern_fly",
    ["ro_bin_gizzard_stone"] = "ro_bin_gem",
    ["roc_robin_egg"] = "roc_egg",
    ["tunacan"] = "tuna",
    ["webberskull"] = "skull_webber",
    ["butterfly"] = IS_SW and "butterfly_tropical" or "butterfly",
    ["butterflywings"] = IS_SW and "butterflywings_tropical" or "butterflywings",
    ["log"] = IS_HAMLET and "log_rainforest" or "log",
}


local noninventory_imgname = {
    ["butterfly"] = IS_SW and "butterfly|sw" or "butterfly",
    ["mermhouse"] = IS_SW and "mermhouse|sw" or "mermhouse",
    ["krampus"] = IS_SW and "krampus|sw" or "krampus",
    ["spider_warrior"] = IS_SW and "spider_warrior|sw" or "spider_warrior",
}

local function GetDesc(name, subname)
    if type(name) ~= "string" then
        return ""
    end
    local desc = STRINGS.NAMES[name:upper()]
    if desc == nil then
        desc = STRINGS.UI.CUSTOMIZATIONSCREEN.NAMES[name:upper()]
    end
    if type(desc) == "table" and type(subname) == "string" then
        name = name[subname:upper()]
    end
    if type(desc) == "string" then
        return desc
    end
    return ""
end

local descname = {
    ["cave_entrance"] = GetDesc("CAVE_ENTRANCE_OPEN"),
    ["fissure_lower"] = "",
    ["hedge_cone"] = GetDesc("HEDGE"),
    ["hedge_block"] = GetDesc("HEDGE"),
    ["hedge_layered"] = GetDesc("HEDGE"),
    ["lawnornament_1"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_2"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_3"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_4"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_5"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_6"] = GetDesc("LAWNORNAMENT"),
    ["lawnornament_7"] = GetDesc("LAWNORNAMENT"),
    ["maxwelllight_area"] = GetDesc("MAXWELLLIGHT"),
    ["mermhouse"] = GetDesc("MERMHOUSE", IS_SW and "SW" or "BASE"),
    ["pig_ruins_ant"] = GetDesc("PIG_RUINS_HEAD"),
    ["pig_ruins_artichoke"] = GetDesc("ROCK_FLINTLESS"),
    ["pig_ruins_truffle"] = GetDesc("PIG_RUINS_MUSHROOM"),
    ["pig_ruins_dart_statue"] = GetDesc("PIG_RUINS_DART_TRAP"),
    ["ruins_chair"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_table"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_chipbowl"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_bowl"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_vase"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_plate"] = GetDesc("RUINS_RUBBLE"),
    ["ruins_statue_head"] = GetDesc("ANCIENT_STATUE"),
    ["ruins_statue_mage"] = GetDesc("ANCIENT_STATUE"),
    ["ruins_statue_head_nogem"] = GetDesc("ANCIENT_STATUE"),
    ["ruins_statue_mage_nogem"] = GetDesc("ANCIENT_STATUE"),
    ["sharkittenspawner+active"] = GetDesc("SHARKITTENSPAWNER_ACTIVE"),
    ["sharkittenspawner+inactive"] = GetDesc("SHARKITTENSPAWNER_INACTIVE"),
    ["spiderden_2"] = GetDesc("SPIDERDEN"),
    ["spiderden_3"] = GetDesc("SPIDERDEN"),
    ["stalagmite_full"] = GetDesc("STALAGMITE"),
    ["stalagmite_tall_full"] = GetDesc("STALAGMITE"),
    ["topiary_1"] = GetDesc("TOPIARY"),
    ["topiary_2"] = GetDesc("TOPIARY"),
    ["topiary_3"] = GetDesc("TOPIARY"),
    ["topiary_4"] = GetDesc("TOPIARY"),
    ["clawpalmtree_tall"] = GetDesc("CLAWPALMTREE"),
    ["moose"] = GetDesc("MOOSE2"),
    ["parrot_pirate"] = GetDesc("PARROT"),
    ["rainforesttree_tall"] = GetDesc("RAINFORESTTREE"),
    ["rainforesttree_rot_tall"] = GetDesc("RAINFORESTTREE"),
    ["rainforesttree_tall+blooming"] = GetDesc("RAINFORESTTREE"),
    ["tubertree_tall"] = GetDesc("TUBERTREE"),
    ["tubertree_tall+blooming"] = GetDesc("TUBERTREE"),
    ["teatree_tall"] = GetDesc("TEATREE"),
    ["spider_monkey_tree_tall"] = GetDesc("SPIDER_MONKEY_TREE"),
    ["doydoybaby+teen"] = GetDesc("DOYDOYTEEN"),
}


return {
    inventory_imgname = inventory_imgname,
    noninventory_imgname = noninventory_imgname,
    descname = descname,
}