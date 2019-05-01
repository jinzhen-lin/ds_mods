local Screen = require "widgets/screen"
local Image = require "widgets/image"
local Text = require "widgets/text"
local Menu = require "widgets/menu"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local VALID_CHARS = "1234567890."
local screen_title = STRINGS.TOO_MANY_ITEMS_UI.DUABILITY_SCREEN_TITTLE
local screen_tip = STRINGS.TOO_MANY_ITEMS_UI.DUABILITY_SCREEN_TIP
local screen_errmsg = STRINGS.TOO_MANY_ITEMS_UI.DUABILITY_SCREEN_ERRMSG


local SetDurabilityScreen = Class(Screen, function(self)
	Screen._ctor(self, "SetDurabilityScreen")
	self:DoInit()
end)


function SetDurabilityScreen:DoInit()
	local label_width = 200
	local label_height = 50
	local label_offset = 450

	local space_between = 30
	local height_offset = -270

	local fontsize = 30
	
	local edit_width = 320
	local edit_bg_padding = 35
	
	self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root = self.root:AddChild(Widget(""))
	self.root:SetPosition(0, 0, 0)

    self.bg = self.root:AddChild(Image("images/globalpanels.xml", "panel.tex"))
    self.bg:SetPosition(0, 0, 0)
    self.bg:SetScale(0.9, 0.62, 0.7)

    self.edit_bg = self.root:AddChild(Image())
	self.edit_bg:SetTexture("images/ui.xml", "textbox_long.tex")
	self.edit_bg:SetPosition(0, -13, 0)
	self.edit_bg:ScaleToSize(edit_width + edit_bg_padding, label_height)

	self.durability_edit = self.root:AddChild(TextEdit(DEFAULTFONT, fontsize, ""))
    self.durability_edit:SetFocusedImage(self.edit_bg, "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex")
	self.durability_edit:SetPosition(0, -13, 0)
	self.durability_edit:SetRegionSize(edit_width, label_height)
	self.durability_edit:SetHAlign(ANCHOR_LEFT)
	self.durability_edit:SetCharacterFilter(VALID_CHARS)
    if type(TOOMANYITEMS.DATA.DURABILITY) == "number" then
        self.durability_edit:SetString(tostring(TOOMANYITEMS.DATA.DURABILITY))
    else
        self.durability_edit:SetString("")
    end
	self.durability_edit:SetAllowClipboardPaste(true)
    local _oldOnGainFocus = self.durability_edit.OnGainFocus
    self.durability_edit.OnGainFocus = function(self)
        self:SetEditing(true)
        _oldOnGainFocus(self)
    end
    self.durability_edit.OnTextEntered = function() self:OnConfirm() end

    self.titletext = self.root:AddChild(Text(BODYTEXTFONT, 45, screen_title))
    self.titletext:SetPosition(0, 80, 0)
    self.titletext:SetColour(0.9, 0.8, 0.6, 1)

    self.tiptext = self.root:AddChild(Text(BODYTEXTFONT, 20, screen_tip))
    self.tiptext:SetPosition(0, 37, 0)
    self.tiptext:SetColour(0.9, 0.8, 0.6, 1)
    
    self.menu = self.root:AddChild(Menu(nil, 200, true))
    self.menu:SetScale(0.6)
    self.menu:SetPosition(0, -80, 0)

    self.confirmbutton = self.menu:AddItem(STRINGS.UI.MAINSCREEN.OK, function() self:OnConfirm() end, nil, nil, 1.15)
    self.emptybutton = self.menu:AddItem(STRINGS.TOO_MANY_ITEMS_UI.DUABILITY_SCREEN_EMPTY, function() self:OnEmpty() end, nil, nil, 1.15)
    self.cancelbutton = self.menu:AddItem(STRINGS.UI.MAINSCREEN.CANCEL, function() self:OnCancel() end, nil, nil, 1.15)

    self.menu:SetHRegPoint(ANCHOR_MIDDLE)

    self.confirmbutton:SetFocusChangeDir(MOVE_UP, self.durability_edit)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.durability_edit)
    self.default_focus = self.durability_edit
end

function SetDurabilityScreen:OnConfirm()
    local durability = tonumber(self.durability_edit:GetString())
    if durability == nil or durability > 1 or durability < 0 then
        self.tiptext:SetString(screen_errmsg.."\n"..screen_tip)
    else
        TOOMANYITEMS.DATA.DURABILITY = durability
        if TOOMANYITEMS.DATA_SAVE == 1 then
            TOOMANYITEMS.SaveNormalData()
        end
        self:OnCancel()
    end
end

function SetDurabilityScreen:OnEmpty()
    self.durability_edit:SetString("")
end

function SetDurabilityScreen:OnCancel()
	TheFrontEnd:PopScreen(self)
end

function SetDurabilityScreen:OnBecomeActive()
    SetPause(true, "console")
    self.durability_edit:SetFocus()
    self.durability_edit:SetEditing(true)
    SetDurabilityScreen._base.OnBecomeActive(self)
end

function SetDurabilityScreen:OnBecomeInactive()
    SetPause(false, "console")
    SetDurabilityScreen._base.OnBecomeInactive(self)
end

return SetDurabilityScreen