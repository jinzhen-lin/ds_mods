local Image = require "widgets/image"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"

local TMI_menubar = require "widgets/TMI_menubar"

local function SendCommand(fnstr)
    ExecuteConsoleCommand(fnstr)
end


local TooManyItems = Class(Widget, function(self)
    Widget._ctor(self, "TooManyItems")

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetPosition(0, 0, 0)

    self.shieldpos_x = -250
    self.shieldsize_x = 350
    self.shieldsize_y = 480
    self.shield = self.root:AddChild( Image("images/ui.xml", "black.tex") )
    self.shield:SetScale(1, 1, 1)
    self.shield:SetPosition(self.shieldpos_x, 0, 0)
    self.shield:SetSize(self.shieldsize_x, self.shieldsize_y)
    self.shield:SetTint(1, 1, 1, 0.6)

    local savepath = TOOMANYITEMS.GetTeleportSavePath()

    if TOOMANYITEMS.DATA_SAVE == 1 then
        if TOOMANYITEMS.LoadData(savepath) then
            TOOMANYITEMS.TELEPORT_DATA = TOOMANYITEMS.LoadData(savepath)
        end
    elseif TOOMANYITEMS.DATA_SAVE == -1 then
        _G.TheSim:GetPersistentString(savepath, function(load_success, str) if load_success then _G.ErasePersistentString(savepath, nil) end end)
    end

    self:DebugMenu()

    if TOOMANYITEMS.DATA.IsDebugMenuShow then
        self.debugshield:Show()
    else
        self.debugshield:Hide()
    end

    self.menu = self.shield:AddChild(TMI_menubar(self))

end)

function TooManyItems:Close()
    self:Hide()
    self.IsTooManyItemsMenuShow = false
end

function TooManyItems:ShowDebugMenu()
    if TOOMANYITEMS.DATA.IsDebugMenuShow then
        self.debugshield:Hide()
        TOOMANYITEMS.DATA.IsDebugMenuShow = false
    else
        self.debugshield:Show()
        TOOMANYITEMS.DATA.IsDebugMenuShow = true
    end
    if TOOMANYITEMS.DATA_SAVE == 1 then
        TOOMANYITEMS.SaveNormalData()
    end
end


function TooManyItems:SetPointer()
    local mainstr = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_POINTER
    local prefix = ""
    prefix = STRINGS.TOO_MANY_ITEMS_UI.BUTTON_POINTER_SELF
    self.pointer:SetText("")
    self.pointersizex, self.pointersizey = self.pointer.text:GetRegionSize()
    self.pointer.image:SetSize(self.pointersizex * .85, self.pointersizey)
    self.pointer:SetPosition(self.left + self.pointersizex * .5, self.shieldsize_y * .5 - self.pointersizey * .5, 0)
end

function TooManyItems:DebugMenu()
    self.debugwidth = 500
    self.font = BODYTEXTFONT
    self.fontsize = 26
    self.minwidth = 36
    self.nextline = 24
    self.spacing = 10

    self.left = -self.debugwidth * 0.5
    self.limit = -self.left
    self.debugshield = self.root:AddChild( Image("images/ui.xml", "black.tex") )
    self.debugshield:SetScale(1, 1, 1)
    self.debugshield:SetPosition(self.shieldpos_x + self.shieldsize_x * 0.5 + self.limit, 0, 0)
    self.debugshield:SetSize(self.limit * 2, self.shieldsize_y)
    self.debugshield:SetTint(1, 1, 1, 0.6)
    self.debugshield:Hide()

    self.pointer = self.debugshield:AddChild(TextButton())
    self.pointer:SetFont(self.font)
    self.pointer:SetTooltip(STRINGS.TOO_MANY_ITEMS_UI.BUTTON_POINTERTIP)
    self.pointer:SetTextSize(self.fontsize)
    self.pointer:SetColour(0, 1, 1, 1)
    self.pointer:SetOverColour(0.4, 1, 1, 1)

    self:SetPointer()

    self.debugbuttonlist = require "TMI/debug"
    self.top = self.shieldsize_y * .5 - self.pointersizey - self.spacing

    local function IsShowBeta(beta)
        if beta and BRANCH == "release" then
            return false
        end
        return true
    end

    local function IsShowPos(pos)
        if type(pos) == "string" then
            if pos == "all" then
                return true
            else
                pos = {pos}
            end
        elseif type(pos) == "function" then    
            return pos()
        elseif type(pos) ~= "table" then
            return false
        end

        local current_pos = GetWorld().prefab
        if current_pos == "cave" then
            current_pos = "cave"..tostring(SaveGameIndex:GetCurrentCaveLevel())
        end
        if table.contains(pos, current_pos) then
            return true
        end
        local pos_pre = GetSeasonManager().StartAutumn and "rog_" or "ds_"
        if table.contains(pos, pos_pre..current_pos) then
            return true
        end
        return false
    end

    local function IsShowButton(beta, pos)
        if IsShowBeta(beta) and IsShowPos(pos) then
            return true
        end
        return false
    end

    local function MakeDebugButtons(buttonlist, left)
        local lleft = left
        for i = 1, #buttonlist do
            if IsShowButton(buttonlist[i].beta, buttonlist[i].pos) then
                local button = self.debugshield:AddChild(TextButton())
                button:SetFont(self.font)
                button.text:SetHorizontalSqueeze(.9)
                button:SetText(buttonlist[i].name)
                local buttontip = buttonlist[i].tip
                if type(buttontip) == "function" then
                    buttontip = buttontip(buttonlist[i])
                end
                button:SetTooltip(buttontip)
                button:SetTextSize(self.fontsize)
                button:SetColour(0.9, 0.8, 0.6, 1)

                local fn = buttonlist[i].fn
                if type(fn) == "table" then
                    button:SetOnClick(function() fn.TeleportFn(fn.TeleportNum) end)
                elseif type(fn) == "string" then
                    button:SetOnClick(function() SendCommand(string.format(fn, GetPlayer())) end)
                elseif type(fn) == "function" then
                    button:SetOnClick(fn)
                end

                local width, height = button.text:GetRegionSize()
                if width < self.minwidth then
                    width = self.minwidth
                    button.text:SetRegionSize(width, height)
                end
                button.image:SetSize(width * 0.8, height)

                if lleft + width > self.limit then
                    self.top = self.top - self.nextline
                    button:SetPosition(self.left + width * .5, self.top, 0)
                    lleft = self.left + width + self.spacing
                else
                    button:SetPosition(lleft + width * .5, self.top, 0)
                    lleft = lleft + width + self.spacing
                end

            end
        end

    end

    local function MakeDebugButtonList(buttonlist)
        for i = 1, #buttonlist do
            local tittle = self.debugshield:AddChild(Text(self.font, self.fontsize, buttonlist[i].tittle))
            tittle:SetHorizontalSqueeze(.85)
            local width = tittle:GetRegionSize()
            tittle:SetPosition(self.left + width * .5, self.top, 0)
            MakeDebugButtons(buttonlist[i].list, self.left + width + self.spacing)
            self.top = self.top - self.nextline
        end
    end

    MakeDebugButtonList(self.debugbuttonlist)
end

function TooManyItems:OnControl(control, down)
    if TooManyItems._base.OnControl(self, control, down) then
        return true
    end

    if not down then
        if control == CONTROL_PAUSE or control == CONTROL_CANCEL then
            self:Close()
        end
    end

    return true
end

function TooManyItems:OnRawKey(key, down)
    if TooManyItems._base.OnRawKey(self, key, down) then
        return true
    end
end

function TooManyItems:ShowCharacterMenu()
    local function TMIGetActiveCharacterList() 
        local list = MAIN_CHARACTERLIST

        if IsDLCEnabled(REIGN_OF_GIANTS) then
            list = JoinArrays(list, ROG_CHARACTERLIST)
            if IsDLCEnabledAndInstalled(CAPY_DLC) then
                list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
            end
            if IsDLCEnabledAndInstalled(PORKLAND_DLC) then
                list = JoinArrays(list, PORKLAND_CHARACTERLIST)
            end         
        end
        if IsDLCEnabled(CAPY_DLC) then
            if IsDLCInstalled(REIGN_OF_GIANTS) then
                list = JoinArrays(list, ROG_CHARACTERLIST)
            end
            if IsDLCEnabledAndInstalled(PORKLAND_DLC) then
                list = JoinArrays(list, PORKLAND_CHARACTERLIST)
            end        
            list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
        end

        if IsDLCEnabled(PORKLAND_DLC) then
            if IsDLCInstalled(REIGN_OF_GIANTS) then
                list = JoinArrays(list, ROG_CHARACTERLIST)
            end
            if IsDLCInstalled(CAPY_DLC) then
                list = JoinArrays(list, SHIPWRECKED_CHARACTERLIST)
            end
            
            list = JoinArrays(list, PORKLAND_CHARACTERLIST)
        end

        for i=#list,1,-1 do
            if "wilson" == list[i] then
                table.remove(list,i)
            else
                for t, rchar in ipairs(RETIRED_CHARACTERLIST) do
                    if rchar == list[i] then
                        table.remove(list,i)
                    end
                end
            end
        end
        return list
    end
    
    
    self.totalwidth = self.shieldsize_x + self.debugwidth
    self.charactershield = self.root:AddChild( Image("images/ui.xml", "black.tex") )
    self.charactershield:SetScale(1, 1, 1)
    self.charactershield:SetPosition(0, 0, 0)
    self.charactershield:SetSize(self.shieldsize_x + self.debugwidth, self.shieldsize_y)
    self.charactershield:SetTint(1, 1, 1, 0.8)

    local back_button = self.charactershield:AddChild(TextButton())
    back_button:SetFont(self.font)
    back_button.text:SetHorizontalSqueeze(.9)
    back_button:SetText("Back")
    back_button:SetTooltip("Back to Debug Menu")
    back_button:SetTextSize(self.fontsize * 2)
    back_button:SetColour(0.9, 0.8, 0.6, 1)
    back_button:SetPosition(0, -200)
    back_button:SetOnClick(function()
        self.charactershield:Hide()
    end)

    local character_tiptext = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_UNLOCK_ALL_CHARACTERS_UITIP
    self.tiptext = self.charactershield:AddChild(Text(BODYTEXTFONT, 30, character_tiptext))
    self.tiptext:SetPosition(0, self.shieldsize_y / 2 - 35, 0)
    self.tiptext:SetColour(0.9, 0.8, 0.6, 1)

    local character_each_line = 8
    local character_start_x = -self.totalwidth / 2 + 80
    local character_start_y = self.shieldsize_y / 2 - 100
    local character_end_x = self.totalwidth / 2 - 80
    local character_end_y = -self.shieldsize_y / 2 + 80
    local character_space = (character_end_x - character_start_x) / (character_each_line - 1)
    local character_icon_width = character_space * 1.1
    
    local player_profile = GetPlayer().profile
    local unlocked_characters = player_profile.persistdata.unlocked_characters
    local characterlist = TMIGetActiveCharacterList()
    for k, v in ipairs(characterlist) do
        local _x = math.fmod(k - 1, character_each_line)
        local _y = math.modf((k - 1) / character_each_line)
        local x = character_start_x + character_space * _x
        local y = character_start_y - character_space * _y
        local character_atlas = (table.contains(MODCHARACTERLIST, v) and "images/saveslot_portraits/"..v..".xml") or "images/saveslot_portraits.xml"
        local character_icon = self.charactershield:AddChild(
            ImageButton(character_atlas, v .. ".tex", v .. ".tex", v .. ".tex")
        )
        local tint = unlocked_characters[v] and 1 or 0.3
        character_icon.image:SetTint(tint, tint, tint, 1)

        character_icon:SetPosition(x, y, 0)
        character_icon:SetTooltip(STRINGS.NAMES[v:upper()] or v)
        local character_icon_scale = character_icon_width / character_icon:GetSize()
        character_icon:SetScale(character_icon_scale, character_icon_scale)
        character_icon:SetOnClick(function()
            unlocked_characters[v] = not unlocked_characters[v]
            local tint = unlocked_characters[v] and 1 or 0.3
            character_icon.image:SetTint(tint, tint, tint, 1)
            player_profile:Save()
        end)
    end
end



return TooManyItems
