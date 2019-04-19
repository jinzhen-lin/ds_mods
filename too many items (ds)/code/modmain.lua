_G = GLOBAL

Assets =
{
    Asset("IMAGE", "images/tmi/healthmeter.tex"),
    Asset("ATLAS", "images/tmi/healthmeter.xml"),
    Asset("IMAGE", "images/tmi/sanity.tex"),
    Asset("ATLAS", "images/tmi/sanity.xml"),
    Asset("IMAGE", "images/tmi/hunger.tex"),
    Asset("ATLAS", "images/tmi/hunger.xml"),
    Asset("IMAGE", "images/tmi/logmeter.tex"),
    Asset("ATLAS", "images/tmi/logmeter.xml"),
    Asset("IMAGE", "images/tmi/wetness_meter.tex"),
    Asset("ATLAS", "images/tmi/wetness_meter.xml"),
    Asset("IMAGE", "images/tmi/thermal_measurer_build.tex"),
    Asset("ATLAS", "images/tmi/thermal_measurer_build.xml"),
    Asset("ATLAS", "images/tmi/close.xml"),
    Asset("IMAGE", "images/tmi/close.tex"),
    Asset("ATLAS", "images/tmi/creativemode.xml"),
    Asset("IMAGE", "images/tmi/creativemode.tex"),
    Asset("ATLAS", "images/tmi/godmode.xml"),
    Asset("IMAGE", "images/tmi/godmode.tex"),
    Asset("ATLAS", "images/tmi/debug.xml"),
    Asset("IMAGE", "images/tmi/debug.tex"),
    Asset("ATLAS", "images/tmi/delete.xml"),
    Asset("IMAGE", "images/tmi/delete.tex"),
    Asset("ATLAS", "images/tmi/living.xml"),
    Asset("IMAGE", "images/tmi/living.tex"),
    Asset("ATLAS", "images/tmi/building.xml"),
    Asset("IMAGE", "images/tmi/building.tex"),
    Asset("ATLAS", "images/tmi/pause.xml"),
    Asset("IMAGE", "images/tmi/pause.tex"),
    Asset("ATLAS", "images/tmi/poison.xml"),
    Asset("IMAGE", "images/tmi/poison.tex"),
}

_G.AllRecipes = _G.GetAllRecipes()
_G.TOOMANYITEMS = {
    DATA_FILE = "mod_config_data/toomanyitems_data_save",
    TELEPORT_DATA_FILE = "mod_config_data/",
    DATA = {},
    TELEPORT_DATA = {},
    LIST = {},

    TMI_TOGGLE_KEY = GetModConfigData("TMI_TOGGLE_KEY"),
    L_CLICK_NUM = GetModConfigData("TMI_L_CLICK_NUM"),
    R_CLICK_NUM = GetModConfigData("TMI_R_CLICK_NUM"),
    DATA_SAVE = GetModConfigData("TMI_DATA_SAVE"),
    SEARCH_HISTORY_NUM = GetModConfigData("TMI_SEARCH_HISTORY_NUM"),
    OTHER_MODS = GetModConfigData("OTHER_MODS"),
}

modimport("tmi_utils_main.lua")

_G.TOOMANYITEMS.GetListFromFile = function(filename)
    if not filename then
        return
    end
    local list = {}
    for line in _G.io.lines(filename) do 
        local prefab = line:gsub("%s", "")
        table.insert(list, prefab)
    end
    return list
end

_G.TOOMANYITEMS.GetTeleportSavePath = function()
    local current_slot = _G.SaveGameIndex:GetCurrentSaveSlot()
    local current_mode = _G.SaveGameIndex:GetCurrentMode()
    local world_id = "world"
    local function OnGetSaveData(savedata)
        if type(savedata) == "table" and type(savedata) == "table" then
            -- 使用地图生成的种子（其实就是时间戳）作为该世界的唯一标识
            world_id = savedata.meta.seed or world_id
        end
    end
    _G.SaveGameIndex:GetSaveData(current_slot, current_mode, OnGetSaveData)
    local savepath = _G.TOOMANYITEMS.TELEPORT_DATA_FILE .. "toomanyitems_teleport_save_"..tostring(world_id)
    return savepath
end

if _G.TOOMANYITEMS.DATA_SAVE == -1 then
    local filepath = _G.TOOMANYITEMS.DATA_FILE
    _G.TheSim:GetPersistentString(filepath, function(load_success, str) if load_success then _G.ErasePersistentString(filepath, nil) end end)
elseif _G.TOOMANYITEMS.DATA_SAVE == 1 then
    _G.TOOMANYITEMS.LoadData = function(filepath)
        local data = nil
        _G.TheSim:GetPersistentString(filepath,
            function(load_success, str)
                if load_success == true then
                    local success, savedata = _G.RunInSandbox(str)
                    if success and string.len(str) > 0 then
                        data = savedata
                    else
                        print ("[TooManyItems] Could not load "..filepath)
                    end
                else
                    print ("[TooManyItems] Can not find "..filepath)
                end
            end
        )
        return data
    end

    _G.TOOMANYITEMS.SaveData = function(filepath, data)
        if data and type(data) == "table" and filepath and type(filepath) == "string" then
            _G.SavePersistentString(filepath, _G.DataDumper(data, nil, true), false, nil)
        end
    end

    _G.TOOMANYITEMS.SaveNormalData = function()
        _G.TOOMANYITEMS.SaveData(_G.TOOMANYITEMS.DATA_FILE, _G.TOOMANYITEMS.DATA)
    end
end

STRINGS = _G.STRINGS
STRINGS.TOO_MANY_ITEMS_UI = {}


local support_languages = {
    chs = "chs",
    cn = "chs",
    zh_CN = "chs",
    lmu = "chs",
    TW = "cht",
    cht = "cht",
}

local function LoadTranslation()
    modimport("Stringslocalization.lua")
    local configlang = GetModConfigData("LANG")
    if configlang and table.contains({"en", "cht", "chs"}, configlang) then
        if configlang ~= "en" then
            modimport("Stringslocalization_"..configlang..".lua")
        end
    else
        local lang = _G.LanguageTranslator.defaultlang or nil
        if lang ~= nil and support_languages[lang] ~= nil then
            lang = support_languages[lang]
            print("[TooManyItems] Get your language from language mod!")
            modimport("Stringslocalization_"..lang..".lua")
        else
            local enabledmods = _G.ModManager:GetEnabledModNames()
            for _, mod in pairs(enabledmods) do
                local modinfo = _G.KnownModIndex:GetModInfo(mod)
                if modinfo.name:find("中文") or modinfo.name:find("汉化") then
                    modimport("Stringslocalization_chs.lua")
                    break
                end
            end
        end
    end
    
    for _, v in pairs(_G._TMI.Translation) do
        local string_table = v[1]
        local fn = v[2]
        if (type(fn) == "boolean" and fn) or (type(fn) == "function" and fn()) then
            for k0, v0 in pairs(string_table) do
                STRINGS.TOO_MANY_ITEMS_UI[k0] = v0
            end
        end
    end
end

local function DataInit()
    if _G.TOOMANYITEMS.DATA_SAVE == 1 then
        _G.TOOMANYITEMS.DATA = _G.TOOMANYITEMS.LoadData(_G.TOOMANYITEMS.DATA_FILE)
    end
    if _G.TOOMANYITEMS.DATA == nil then
        _G.TOOMANYITEMS.DATA = {}
    end
    if _G.TOOMANYITEMS.DATA.IsDebugMenuShow == nil then
        _G.TOOMANYITEMS.DATA.IsDebugMenuShow = false
    end
    if _G.TOOMANYITEMS.DATA.listinuse == nil then
        _G.TOOMANYITEMS.DATA.listinuse = "all"
    end
    if _G.TOOMANYITEMS.DATA.search == nil then
        _G.TOOMANYITEMS.DATA.search = ""
    end
    if _G.TOOMANYITEMS.DATA.issearch == nil then
        _G.TOOMANYITEMS.DATA.issearch = false
    end
    if _G.TOOMANYITEMS.DATA.searchhistory == nil then
        _G.TOOMANYITEMS.DATA.searchhistory = {}
    else
        local history_num = #_G.TOOMANYITEMS.DATA.searchhistory
        local beyond = history_num - _G.TOOMANYITEMS.SEARCH_HISTORY_NUM
        if beyond > 0 then
            local history = {}
            for i = beyond + 1, history_num do
                table.insert(history, _G.TOOMANYITEMS.DATA.searchhistory[i])
            end
            _G.TOOMANYITEMS.DATA.searchhistory = history
        end
    end
    if _G.TOOMANYITEMS.DATA.specialitems == nil then
        _G.TOOMANYITEMS.DATA.specialitems = {}
    end
    if _G.TOOMANYITEMS.DATA.currentpage == nil then
        _G.TOOMANYITEMS.DATA.currentpage = {}
    end

    _G.TOOMANYITEMS.LIST = _G.require "TMI/prefabinfolist"
    local delete_list = _G.require "TMI/list/deleteitem_list"
    _G.TOOMANYITEMS.LIST.deleteitem_list = delete_list.deleteitem_list
    --local crash_item_mod = GetModConfigData("CRASH_ITEM")
    local crash_item_mod = "Delete"
    if crash_item_mod == "Cannot Spawn" then
        _G.TOOMANYITEMS.LIST.deleteitem_list_config = delete_list.deleteitem_list_config
    else
        _G.TOOMANYITEMS.LIST.deleteitem_list_config = {}
        for k, v in pairs(delete_list.deleteitem_list_config) do
            if v then
                table.insert(_G.TOOMANYITEMS.LIST.deleteitem_list, k)
            end
        end
    end
end

local function IsHUDScreen()
    local defaultscreen = false
    if _G.TheFrontEnd:GetActiveScreen() and _G.TheFrontEnd:GetActiveScreen().name and type(_G.TheFrontEnd:GetActiveScreen().name) == "string" and _G.TheFrontEnd:GetActiveScreen().name == "HUD" then
        defaultscreen = true
    end
    return defaultscreen
end

local function AddTMIMenu(self)
    controls = self
    DataInit()
    LoadTranslation()
    local TMI = _G.require "widgets/TooManyItems"
    if controls and controls.containerroot then
        controls.TMI = controls.containerroot:AddChild(TMI())
    else
        print("[TooManyItems] AddClassPostConstruct errors!")
        return
    end
    controls.TMI.IsTooManyItemsMenuShow = false
    controls.TMI:Hide()
end

AddClassPostConstruct( "widgets/controls", AddTMIMenu )

local function ShowTMIMenu()
    if IsHUDScreen() then
        if controls and controls.TMI then
            if controls.TMI.IsTooManyItemsMenuShow then
                controls.TMI:Hide()
                controls.TMI.IsTooManyItemsMenuShow = false
            else
                controls.TMI:Show()
                controls.TMI.IsTooManyItemsMenuShow = true
            end
        else
            print("[TooManyItems] Menu can not show!")
            return
        end
    end
end

_G.TheInput:AddKeyUpHandler(_G.TOOMANYITEMS.TMI_TOGGLE_KEY, ShowTMIMenu)
