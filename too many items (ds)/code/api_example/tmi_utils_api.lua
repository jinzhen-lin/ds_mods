

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

local _G = GLOBAL
local exists_TMI = false
for k, v in pairs(_G) do
    if k == "_TMI" then
        exists_TMI = true
    end
end

if not exists_TMI then
    _G._TMI = {}
end

for _, v in pairs(postinit_list) do
    if _G._TMI[v] == nil then
        _G._TMI[v] = {}
    end
end


_G._TMI.AddItemlistPostInit = function(listname, fn)
    if _G._TMI.ItemlistPostInit[listname] == nil then
        _G._TMI.ItemlistPostInit[listname] = {}
    end
    table.insert(_G._TMI.ItemlistPostInit[listname], fn)
end

_G._TMI.AddAllItemlistPostInit = function(fn)
    table.insert(_G._TMI.AllItemlistPostInit, fn)
end


_G._TMI.AddSpecialSpawn = function(item, fn)
    _G._TMI.SpecialSpawn[item] = fn
end

_G._TMI.AddDebuglistPostInit = function(listname, fn)
    if _G._TMI.DebuglistPostInit[listname] == nil then
        _G._TMI.DebuglistPostInit[listname] = {}
    end
    table.insert(_G._TMI.DebuglistPostInit[listname], fn)
end

_G._TMI.AddAllDebuglistPostInit = function(fn)
    table.insert(_G._TMI.AllDebuglistPostInit, fn)
end

_G._TMI.AddIconbuttonlistPostInit = function(fn)
    table.insert(_G._TMI.IconbuttonlistPostInit, fn)
end

_G._TMI.AddItemAssetlistPostInit = function(fn)
    table.insert(_G._TMI.ItemAssetlistPostInit, fn)
end

_G._TMI.AddTranslation = function(string_table, fn)
    table.insert(_G._TMI.Translation, {string_table, fn})
end
