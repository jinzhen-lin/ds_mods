local ImageButton = require "widgets/imagebutton"

local function SendCommand(fnstr)
    ExecuteConsoleCommand(fnstr)
end

local function HealthSet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('c_sethealth(0.1)')
    else
        SendCommand('c_sethealth(1)')
    end
end

local function SanitySet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('c_setsanity(0)')
    else
        SendCommand('c_setsanity(1)')
    end
end

local function HungerSet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('c_sethunger(0)')
    else
        SendCommand('c_sethunger(1)')
    end
end

local function MoistureSet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('GetPlayer().components.moisture:SetMoistureLevel(100)')
    else
        SendCommand('GetPlayer().components.moisture:SetMoistureLevel(0)')
    end
end

local function TemperatureSet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('GetPlayer().components.temperature:SetTemp(GetSeasonManager():GetCurrentTemperature())')
    else
        SendCommand('GetPlayer().components.temperature:SetTemp(25)')
    end
end

local function BeavernessSet()
    if TheInput:IsKeyDown(KEY_CTRL) then
        SendCommand('GetPlayer().components.beaverness:SetPercent(0)')
    else
        SendCommand('GetPlayer().components.beaverness:SetPercent(1)')
    end
end

local function SayString(enable, mode_str)
    local s = enable and STRINGS.TOO_MANY_ITEMS_UI.ENABLE_FORMAT or STRINGS.TOO_MANY_ITEMS_UI.DISABLE_FORMAT
    GetPlayer().components.talker:Say(s:format(mode_str)) 
end

local godmode_enabled = false
local function GodMode()
    if GetPlayer() then
        godmode_enabled = not godmode_enabled
        GetPlayer().components.health:SetInvincible(godmode_enabled)
        SayString(godmode_enabled, STRINGS.TOO_MANY_ITEMS_UI.GODMODE)
    end
end

local function CreativeMode()
    GetPlayer().components.builder:GiveAllRecipes()
    SayString(GetPlayer().components.builder.freebuildmode, STRINGS.TOO_MANY_ITEMS_UI.CREATIVEMODE)
end

local function OneHitKillMode()
    local combat_ = GetPlayer().components.combat or nil 
    local player = GetPlayer()
    if player and player.components.talker and combat_ and combat_.CalcDamage then 
        if combat_.OldCalcDamage then     
            SayString(false, STRINGS.TOO_MANY_ITEMS_UI.ONEHITKILLMODE)
            combat_.CalcDamage = combat_.OldCalcDamage 
            combat_.OldCalcDamage = nil 
        else     
            SayString(true, STRINGS.TOO_MANY_ITEMS_UI.ONEHITKILLMODE)
            combat_.OldCalcDamage = combat_.CalcDamage combat_.CalcDamage = function(...) 
                return 99999999999
            end 
        end 
    end
end

local function RemoveBackpack()
    local player = GetPlayer()
    local inventory = player and player.components.inventory or nil 
    local backpack = inventory and inventory.overflow and inventory.overflow.components.container or nil 
    local backpackSlotCount = backpack and backpack:GetNumSlots() or 0 
    for i = 1, backpackSlotCount do 
        local item = backpack:GetItemInSlot(i) or nil 
        if item ~= nil then 
            inventory:RemoveItem(item, true) 
            item:Remove() 
        end 
    end
    if TheInput:IsKeyDown(KEY_CTRL) then
        for i = 1, inventory.maxslots do 
            local item = inventory.itemslots[i] or nil 
            if item ~= nil then 
                inventory:RemoveItem(item, true) 
                item:Remove() 
            end 
        end
    end
end

local paused = false
local function TogglePause()
    paused = not paused
    SetPause(paused, "console")
end


local function PoisonSet()
    local player = GetPlayer()
    if player.components and player.components.poisonable then
        if TheInput:IsKeyDown(KEY_CTRL) then
            local gas = player.components.poisonable:CanBePoisoned(true)
            player.components.poisonable:Poison(gas)
        else
            player.components.poisonable:DonePoisoning()
        end
    end
end

local Menu = Class(function(self, owner, pos)
    self.owner = owner
    self.shield = self.owner.owner.shield
        local pos_y1 = -178
        local pos_y2 = -213

    local function Close()
      self.owner.owner:Close()
    end
    local function ShowDebugMenu()
        self.owner.owner:ShowDebugMenu()
    end
    self.menu = {
        ["health"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_HEALTH,
            fn = HealthSet,
            atlas = "images/tmi/healthmeter.xml",
            image = "healthmeter.tex",
            pos = {pos[1], pos_y1},
        },
        ["sanity"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_SANITY,
            fn = SanitySet,
            atlas = "images/tmi/sanity.xml",
            image = "sanity.tex",
            pos = {pos[2], pos_y1},
        },
        ["hunger"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_HUNGER,
            fn = HungerSet,
            atlas = "images/tmi/hunger.xml",
            image = "hunger.tex",
            pos = {pos[3], pos_y1},
        },
        ["godmode"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_GODMODE,
            fn = GodMode,
            atlas = "images/tmi/godmode.xml",
            image = "godmode.tex",
            pos = {pos[4], pos_y1},
        },
        ["pause"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_PAUSE,
            fn = TogglePause,
            atlas = "images/tmi/pause.xml",
            image = "pause.tex",
            pos = {pos[5], pos_y1},
        },
        ["onehitkillmode"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_ONEHITKILLMODE,
            fn = OneHitKillMode,
            atlas = "images/hud.xml",
            image = "tab_fight.tex",
            pos = {pos[6], pos_y1},
        },
        ["remove"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_EMPTYBACKPACK,
            fn = RemoveBackpack,
            atlas = "images/tmi/delete.xml",
            image = "delete.tex",
            pos = {pos[7], pos_y1},
        },
        ["moisture"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_WET,
            fn = MoistureSet,
            atlas = "images/tmi/wetness_meter.xml",
            image = "wetness_meter.tex",
            pos = {pos[1], pos_y2},
        },
        ["temperature"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_TEMPERATURE,
            fn = TemperatureSet,
            atlas = "images/tmi/thermal_measurer_build.xml",
            image = "thermal_measurer_build.tex",
            pos = {pos[2], pos_y2},
        },
        ["beaverness"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_LOGMETER,
            fn = BeavernessSet,
            atlas = "images/tmi/logmeter.xml",
            image = "logmeter.tex",
            pos = {pos[3], pos_y2},
        },
        ["poison"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_POISON,
            fn = PoisonSet,
            atlas = "images/tmi/poison.xml",
            image = "poison.tex",
            pos = {pos[4], pos_y2},
        },
        ["debug"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_DEBUGMENU,
            fn = ShowDebugMenu,
            atlas = "images/tmi/debug.xml",
            image = "debug.tex",
            pos = {pos[5], pos_y2},
        },
        ["creativemode"] = {
            tip = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_CREATIVEMODE,
            fn = CreativeMode,
            atlas = "images/tmi/creativemode.xml",
            image = "creativemode.tex",
            pos = {pos[6], pos_y2},
        },
        ["cancel"] = {
            tip = STRINGS.UI.OPTIONS.CLOSE,
            fn = Close,
            atlas = "images/tmi/close.xml",
            image = "close.tex",
            pos = {pos[7], pos_y2},
        },
        ["prevbutton"] = {
            tip = STRINGS.UI.HELP.PREVPAGE,
            fn = function() self.owner.inventory:Scroll(-1) end,
            atlas = "images/ui.xml",
            image = "arrow_left.tex",
            pos = {pos[8], pos_y2},
        },
        ["nextbutton"] = {
            tip = STRINGS.UI.HELP.NEXTPAGE,
            fn = function() self.owner.inventory:Scroll(1) end,
            atlas = "images/ui.xml",
            image = "arrow_right.tex",
            pos = {pos[9], pos_y2},
        },
    }

    self:MainButton()
end)

function Menu:MainButton()
    self.mainbuttons = {}
    local function MakeMainButtonList(buttonlist)
        local function MakeMainButton(name, tip, fn, atlas, image, pos)
            if type(image) == "string" then
                self.mainbuttons[name] = self.shield:AddChild(ImageButton(atlas, image, image, image))
            elseif type(image) == "table" then
                self.mainbuttons[name] = self.shield:AddChild(ImageButton(atlas, image[1], image[2], image[3]))
            else
                return
            end
            self.mainbuttons[name]:SetTooltip(tip)
            self.mainbuttons[name]:SetOnClick(fn)
            self.mainbuttons[name]:SetPosition(pos[1], pos[2], 0)
            local w, h = self.mainbuttons[name].image:GetSize()
            local scale = math.min(30 / w, 30 / h)
            self.mainbuttons[name]:SetScale(scale, scale, scale)
        end
        for k,v in pairs(buttonlist) do
            MakeMainButton(k, v.tip, v.fn, v.atlas, v.image, v.pos)
        end
    end

    if self.menu then
        MakeMainButtonList(self.menu)
    end
end

return Menu
