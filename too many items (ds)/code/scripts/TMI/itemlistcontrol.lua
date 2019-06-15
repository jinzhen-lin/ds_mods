local pinyin = require "TMI/pinyin"
local Prefabname_list = {}
for _, v in pairs(Prefabs) do
    table.insert(Prefabname_list, v.name)
end

local Listload = {
    ["food"] = true,
    ["resource"] = true,
    ["weapon"] = true,
    ["tool"] = true,
    ["clothe"] = true,
    ["gift"] = true,
    ["living"] = false,
    ["building"] = false,
}

local function comp(a, b)
    return a < b
end

local function MergeItemList(...)
    local ret = {}
    for _, map in ipairs({...}) do
        for i = 1, #map do
            if not table.contains(dont_add_item, map[i]) then
                table.insert(ret, map[i])
            end
        end
    end
    return ret
end

local function GetItemDesc(item)
    if type(item) ~= "string" then
        return ""
    end
    local item_plus = ""
    local str = ""
    item = item:gsub("-.*", ""):gsub("+.*", "")
    item_plus = item:gsub("-[^+]*", "")

    if item ~= nil and item ~= "" then
        local itemtip = item:upper()
        if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
            if type(STRINGS.NAMES[itemtip]) == "string" then
                str = STRINGS.NAMES[itemtip]
            end
        end
        if TOOMANYITEMS.LIST.descname[item_plus] then
            str = TOOMANYITEMS.LIST.descname[item_plus]
        end
    end

    return str
end

local ItemListControl = Class(function(self)
    self.beta = BRANCH ~= "release" and true or false
    self.list = {}
    self.desclist = {}
    self.special_spawn_prefab_list = {}
    self:Init()
end)

function ItemListControl:Init()
    if self.beta then
        self.betalistpatch = require "TMI/list/itemlist_beta"
    end

    local n = 1
    local dont_add_item = TOOMANYITEMS.LIST.deleteitem_list
    self.list["all"] = {}
    self.desclist["all"] = {}
    for k, v in pairs(Listload) do
        local path = "TMI/list/itemlist_"..k
        local item_list = _TMI.ModifyItemlist(require(path), k)
        self.list[k] = {}
        self.desclist[k] = {}
        for i, item in pairs(item_list) do
            local item_base = item:gsub("+[^-]*", "")
            local can_add = not table.contains(dont_add_item, item_base) and not table.contains(dont_add_item, item)
            if can_add and table.contains(Prefabname_list, item_base) then
                table.insert(self.list[k], item)
                self.desclist[k][item] = GetItemDesc(item)
                if item ~= item_base then
                    table.insert(self.special_spawn_prefab_list, item_base)
                end
            end
        end
        self:SortList(self.list[k])
        if self.betalistpatch and self.betalistpatch[k] and #self.betalistpatch[k] > 0 then
            self.list[k] = MergeItemList(self.list[k], self.betalistpatch[k])
            self:SortList(self.list[k])
        end
        if v then
            for i = 1, #self.list[k] do
                if not table.contains(self.list["all"], self.list[k][i]) then
                    self.list["all"][n] = self.list[k][i]
                    n = n + 1
                end
            end
        end
    end
    self.list["all"] = _TMI.ModifyItemlist(self.list["all"], "all")
    for _, item in pairs(self.list["all"]) do
        self.desclist["all"][item] = GetItemDesc(item)
    end

    self:SortList(self.list["all"])

    self.list["others"] = {}
    self.desclist["others"] = {}

    for _, v in pairs(Prefabs) do
        if v.assets and self:CanAddOthers(v.name) then
            table.insert(self.list["others"], v.name)
        end
    end
    self.list["others"] = _TMI.ModifyItemlist(self.list["others"], "others")
    self:SortList(self.list["others"])
    for _, fn in pairs(_TMI.AllItemlistPostInit) do
        self.list = fn(self.list)
    end
    for _, item in pairs(self.list["others"]) do
        self.desclist["others"][item] = GetItemDesc(item)
    end
end

function ItemListControl:GetList()
    return self:GetListbyName(TOOMANYITEMS.DATA.listinuse)
end

function ItemListControl:GetListbyName(name)
    if name and type(name) == "string" then
        if name == "special" then
            return TOOMANYITEMS.DATA.specialitems
        else
            return self.list[name]
        end
    else
        TOOMANYITEMS.DATA.listinuse = "all"
    end
    return self.list["all"]
end

function ItemListControl:Search()
    local searchlist = {}
    local list = self:GetList()
    local current_desclist = self.desclist[TOOMANYITEMS.DATA.listinuse]
    local item = TOOMANYITEMS.DATA.search

    for _, v in ipairs(list) do
        if v:find(item) then
            table.insert(searchlist, v)
        end
    end

    for k, v in pairs(current_desclist) do
        local all_descs = pinyin.GetChineseStringPinyin(v)
        if all_descs[1] ~= v then
            table.insert(all_descs, v)
        end
        for _, desc in pairs(all_descs) do
            if table.contains(list, k) and desc:lower():find(item:lower()) and not table.contains(searchlist, k) then
                table.insert(searchlist, k)
            end
        end
    end

    self:SortList(searchlist)
    return searchlist
end

function ItemListControl:SortList(list)
    table.sort(list, comp)
end

function ItemListControl:CanAddOthers(item)
    local can_add = not table.contains(self.special_spawn_prefab_list, item)
    and not table.contains(TOOMANYITEMS.LIST.deleteitem_list, item)
    and not table.contains(self.list["others"], item)
    and not table.contains(self.list["all"], item)
    and not table.contains(self.list["living"], item)
    and not table.contains(self.list["building"], item)
    and not string.find(item, "MOD_")
    and not string.find(item, "_placer")
    and not string.find(item, "_builder")
    and not string.find(item, "_classified")
    and not string.find(item, "_network")
    and not string.find(item, "_lvl")
    and not string.find(item, "_fx")
    and not string.find(item, "blueprint")
    and not string.find(item, "buff")
    and not string.find(item, "map")
    and not string.find(item, "workshop")

    return can_add
end

return ItemListControl
