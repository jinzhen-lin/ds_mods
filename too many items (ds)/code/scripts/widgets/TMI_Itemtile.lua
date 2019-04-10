local Image = require "widgets/image"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local ItemTile = Class(Widget, function(self, invitem)
    Widget._ctor(self, "ItemTile")
    self.item = invitem
    self.desc = self:DescriptionInit()

    self:SetImage()
end)

function ItemTile:SetText()
    self.image = self:AddChild( Image("images/global.xml", "square.tex") )
    self.image:SetTint(0, 0, 0, .8)

    self.text = self.image:AddChild(Text(BODYTEXTFONT, 36, ""))
    self.text:SetHorizontalSqueeze(.85)
    self.text:SetString("????")
end

function ItemTile:SetImage()
    local atlas_list, image_list = self:GetAsset()
    local final_atlas
    local final_image
    for _, image in pairs(image_list) do
        for _, atlas in pairs(atlas_list) do
            local atlas_path = softresolvefilepath(atlas)
            if atlas_path and TheSim:AtlasContains(atlas_path, image) then
                final_atlas = atlas
                final_image = image
                break
            end
        end
        if final_atlas and final_image then
            break
        end
    end
    if final_atlas and final_image then
        local img = Image(final_atlas, final_image)
        img:SetSize(60, 60)
        self.image = self:AddChild(img)
    else
        self:SetText()
    end
end

function ItemTile:GetAsset(find)
    local itematlas_list = {}
    local itemimage_list = {}
    local listinuse = TOOMANYITEMS.DATA.listinuse
    if table.contains({"living", "building"}, listinuse) then
        if TOOMANYITEMS.LIST.noninventory_imgname[self.item] then
            table.insert(itemimage_list, TOOMANYITEMS.LIST.noninventory_imgname[self.item]..".tex")
        end
        if listinuse == "living" then
            table.insert(itematlas_list, "images/tmi/living.xml")
        elseif listinuse == "building" then
            table.insert(itematlas_list, "images/tmi/building.xml")
        end      
    elseif TOOMANYITEMS.LIST.inventory_imgname[self.item] then
        table.insert(itemimage_list, TOOMANYITEMS.LIST.inventory_imgname[self.item]..".tex")
    elseif AllRecipes[self.item] and AllRecipes[self.item].atlas and AllRecipes[self.item].image then
        table.insert(itematlas_list, AllRecipes[self.item].atlas)
        table.insert(itemimage_list, AllRecipes[self.item].image)
    end

    table.insert(itematlas_list, "images/inventoryimages.xml")
    table.insert(itematlas_list, "images/inventoryimages_2.xml")
    if not table.contains(itemimage_list, self.item..".tex") and type(self.item) == "string" then
        table.insert(itemimage_list, self.item..".tex")
        local item_base = self.item:gsub("|.*", ""):gsub("+.*", "")
        if self.item ~= item_base then
            table.insert(itemimage_list, item_base..".tex")
        end
    end

    return itematlas_list, itemimage_list
end

function ItemTile:OnControl(control, down)
    self:UpdateTooltip()
    return false
end

function ItemTile:UpdateTooltip()
    self:SetTooltip(self:GetDescriptionString())
end

function ItemTile:GetDescriptionString()
    return self.desc
end

function ItemTile:DescriptionInit()
    local item
    local item_plus
    local str = ""
    if type(self.item) == "string" then
        item = self.item:gsub("|.*", ""):gsub("+.*", "")
        item_plus = self.item:gsub("|[^+]*", "")
    end

    if item ~= nil and item ~= "" then
        local itemtip = string.upper(item)
        if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
            if type(STRINGS.NAMES[itemtip]) == "string" then
                str = STRINGS.NAMES[itemtip]
            end
        end
        if TOOMANYITEMS.LIST.descname[item_plus] then
            str = TOOMANYITEMS.LIST.descname[item_plus]
        end
    end

    if type(str) == "string" and type(self.item) == "string" then
        str = str.."\n"..self.item
    end
    return str
end

function ItemTile:OnGainFocus()
    self:UpdateTooltip()
end

return ItemTile
