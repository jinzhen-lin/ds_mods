local _G = GLOBAL

modimport("tmi_utils_api.lua")


local postinit_list = {
    "ItemlistPostInit",
    "AllItemlistPostInit",
    "SpecialSpawn",
    "DebuglistPostInit",
    "AllDebuglistPostInit",
    "IconbuttonlistPostInit",
    "ItemAssetlistPostInit",
    "Translation"
}

if not _G.TOOMANYITEMS.OTHER_MODS then 
    for _, v in pairs(postinit_list) do
        _G._TMI[v] = {}
    end
end

_G._TMI.locals = function()
    local variables = {}
    local idx = 1
    while true do
      local ln, lv = _G.debug.getlocal(2, idx)
      if ln ~= nil then
        variables[ln] = lv
      else
        break
      end
      idx = 1 + idx
    end
    return variables
end

_G._TMI.ModifyItemlist = function(list, listname)
    if _G._TMI.ItemlistPostInit[listname] == nil then
        return list
    end
    for _, fn in pairs(_G._TMI.ItemlistPostInit[listname]) do
        list = fn(list)
    end
    return list
end

_G._TMI.ModifyDebuglist = function(list, listname, envs)
    if _G._TMI.DebuglistPostInit[listname] == nil then
        return list
    end
    for _, fn in pairs(_G._TMI.DebuglistPostInit[listname]) do
        list = fn(list, envs)
    end
    return list
end
