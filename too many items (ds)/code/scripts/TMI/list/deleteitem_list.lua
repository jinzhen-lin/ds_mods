local IS_SURVIVAL = SaveGameIndex:IsModeSurvival()
local IS_FOREST = SaveGameIndex:GetCurrentMode() == "survival"
local IS_CAVE = SaveGameIndex:GetCurrentMode() == "cave"
local IS_SW = SaveGameIndex:IsModeShipwrecked()
local IS_SW_BASE = SaveGameIndex:GetCurrentMode() == "shipwrecked"
local IS_VOLCANO = SaveGameIndex:GetCurrentMode() == "volcano"
local IS_HAMLET = SaveGameIndex:IsModePorkland()

local deleteitem_list = TOOMANYITEMS.GetListFromFile(softresolvefilepath("scripts/TMI/list/deleteitem_list.txt"))
local deleteitem_list_config = {
    bandittreasure = not IS_HAMLET,
    pigbandit = not IS_HAMLET,
    roc = not IS_HAMLET,
    antqueen = not IS_HAMLET,
    sharkittenspawner = not IS_SW_BASE,
    volcano = not IS_SW,
    volcano_altar = not IS_SW_BASE,
    kraken = not IS_SW_BASE,
    shipwrecked_exit = not IS_SW_BASE,
    shipwrecked_entrance = not IS_FOREST,
    cave_entrance = not IS_FOREST,
    buzzard = not IS_FOREST,
}

return {
    deleteitem_list = deleteitem_list,
    deleteitem_list_config = deleteitem_list_config,
}