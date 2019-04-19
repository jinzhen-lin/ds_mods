require "util"
local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"
local SearchScreen = Class(Screen, function(self, config)
    Screen._ctor(self, "SearchScreen")
    self.config = config

    self:DoInit()
end)

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]

function SearchScreen:OnBecomeActive()
    SetPause(true, "console")
    SearchScreen._base.OnBecomeActive(self)
    if self.config.activefn ~= nil then
        self.config.activefn()
    end
    self.edit_text:SetFocus()
    TheFrontEnd:LockFocus(true)
end

function SearchScreen:OnBecomeInactive()
    SetPause(false, "console")
    SearchScreen._base.OnBecomeInactive(self)
end

function SearchScreen:OnControl(control, down)
    if SearchScreen._base.OnControl(self, control, down) then
        if not down and (control == CONTROL_CANCEL ) then
            self:Close()
            return true
        end
        return true
    end

    --jcheng: don't allow debug menu stuff going on right now
    if control == CONTROL_OPEN_DEBUG_CONSOLE then
        return true
    end

    if not down and (control == CONTROL_CANCEL ) then
        self:Close()
        return true
    end
end

function SearchScreen:OnRawKey(key, down)
    if SearchScreen._base.OnRawKey(self, key, down) then return true end

    if down then return end

    if self.config.rawkeyfn ~= nil then
        self.config.rawkeyfn(key, self)
    end

    return true
end

function SearchScreen:Run()
    if self.config.acceptfn ~= nil then
        self.config.acceptfn(self:GetText())
    end
end

function SearchScreen:Close()
    GetPlayer().components.playercontroller:Enable(true)
    if self.config.closefn ~= nil then
        self.config.closefn()
    end
    TheInput:EnableDebugToggle(true)
    TheFrontEnd:PopScreen(self)
end

function SearchScreen:OnTextEntered()
    TheInputProxy:FlushInput()
    self:Run()
    self:Close()
end

function SearchScreen:DoInit()
    TheInput:EnableDebugToggle(false)

    self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root = self.root:AddChild(Widget(""))
    self.root:SetPosition(0, 0, 0)

    self.edit_text = self.root:AddChild( TextEdit( DEFAULTFONT, self.config.fontsize, "" ) )
    self.edit_text:SetPosition(self.config.pos)
    self.edit_text:SetRegionSize( self.config.size[1], self.config.size[2] )
    self.edit_text:SetCharacterFilter( VALID_CHARS )
    self.edit_text.OnTextEntered = function() self:OnTextEntered() end
    self.edit_text.OnRawKey = function(self, key, down)
        if TextEdit._base.OnRawKey(self, key, down) then return true end
        if self.editing then
            if down then
                self.inst.TextEditWidget:OnKeyDown(key)
            else
                if key == KEY_ENTER then
                    self:OnProcess()
                    return true
                else
                    self.inst.TextEditWidget:OnKeyUp(key)
                end
            end
        end
        if self.validrawkeys[key] then return false end
        return true
    end
    self.edit_text.OnControl = function(self, control, down)
        if TextEdit._base.OnControl(self, control, down) then return true end

        if self.editing and (control ~= CONTROL_CANCEL and control ~= CONTROL_OPEN_DEBUG_CONSOLE and control ~= CONTROL_ACCEPT) then
            return true
        end

        if self.editing and not down and control == CONTROL_CANCEL then
            self:SetEditing(false)
            return true
        end

        if not down and control == CONTROL_ACCEPT then
            if not self.editing then
                self:SetEditing(true)
            else
                self:OnProcess()
            end
            return true
        end
    end
    self.edit_text:SetEditing(self.config.isediting)
    TheInput:EnableDebugToggle(false)
    GetPlayer().components.playercontroller:Enable(false)
end

function SearchScreen:OverrideText(text)
    self.edit_text:SetString(text)
    self.edit_text:SetFocus()
end

function SearchScreen:GetText()
    return self.edit_text:GetString()
end

return SearchScreen
