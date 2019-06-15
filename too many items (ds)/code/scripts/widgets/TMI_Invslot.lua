local ItemSlot = require "widgets/itemslot"
local TMI_SPECIAL_SPAWN = require "TMI/special_spawn"

local InvSlot = Class(ItemSlot, function(self, owner, atlas, bgim, item)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.item = item
end)

function InvSlot:OnControl(control, down)
    if InvSlot._base.OnControl(self, control, down) then return true end

    if down then
        if control == CONTROL_ACCEPT then
            self:Click(false)
        elseif control == CONTROL_SECONDARY then
            self:Click(true)
        end
        return true
    end

end

function InvSlot:SetSpecialItem()
    local specialitems = {}
    if table.contains(TOOMANYITEMS.DATA.specialitems, self.item) then
        for i = 1, #TOOMANYITEMS.DATA.specialitems do
            if TOOMANYITEMS.DATA.specialitems[i] ~= self.item then
                table.insert(specialitems, TOOMANYITEMS.DATA.specialitems[i])
            end
        end
        GetPlayer().SoundEmitter:PlaySound("dontstarve/HUD/research_unlock")
    else
        table.insert(specialitems, self.item)
        for i = 1, #TOOMANYITEMS.DATA.specialitems do
            table.insert(specialitems, TOOMANYITEMS.DATA.specialitems[i])
        end
        GetPlayer().SoundEmitter:PlaySound("dontstarve/HUD/research_available")
    end
    TOOMANYITEMS.DATA.specialitems = specialitems
    if TOOMANYITEMS.DATA.listinuse == "special" then
        if TOOMANYITEMS.DATA.issearch then
            self.owner:Search()
        else
            self.owner:TryBuild()
        end
    end
    if TOOMANYITEMS.DATA_SAVE == 1 then
        TOOMANYITEMS.SaveNormalData()
    end
end

function InvSlot:GiveRecipeItem(stack_mod)
    local player = GetPlayer()
    local function tmi_give(item)
        if player ~= nil and player.Transform then
            local x, y, z = player.Transform:GetWorldPosition()
            if item ~= nil and item.components then
                if item.components.inventoryitem and player.components and player.components.inventory then
                    player.components.inventory:GiveItem(item)
                else
                    item.Transform:SetPosition(x, y, z)
                end
            end
        end
    end
    local function tmi_mat(name)
        local recipe = AllRecipes[name]
        if recipe then
            for _, iv in pairs(recipe.ingredients) do
                for i = 1, iv.amount do
                    local item = SpawnPrefab(iv.type)
                    tmi_give(item)
                end
            end
        end
    end
    local num = stack_mod and TOOMANYITEMS.R_CLICK_NUM or TOOMANYITEMS.L_CLICK_NUM
    for i = 1, num or 1 do
        tmi_mat(self.item)
    end
    player.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
end

function InvSlot:GiveItem(stack_mod)
    local player = GetPlayer()
    if player ~= nil and player.Transform then
        local x, y, z = player.Transform:GetWorldPosition()
        local num = stack_mod and TOOMANYITEMS.R_CLICK_NUM or TOOMANYITEMS.L_CLICK_NUM
        local item = self.item:gsub("-[^+]*", "")
        if TOOMANYITEMS.LIST.deleteitem_list_config[item] then
            return
        end
        for i = 1, num or 1 do
            local _, _, prefabname, condition = item:find("(.*)+(.*)")
            item = prefabname or item
            local inst = SpawnPrefab(item)
            if inst and inst.components then
                if inst.components.inventoryitem
                and player.components
                and player.components.inventory
                and not table.contains({"living", "building"}, TOOMANYITEMS.DATA.listinuse) then
                    player.components.inventory:GiveItem(inst)
                else
                    local x, y, z = player.Transform:GetWorldPosition()
                    inst.Transform:SetPosition(x, y, z)
                end
                local fn = TMI_SPECIAL_SPAWN[prefabname] and TMI_SPECIAL_SPAWN[prefabname][condition]
                if fn then
                    fn(inst)
                end
            end
        end
    end
    player.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
end

function InvSlot:Click(stack_mod)
    if self.item then
        print ("[TooManyItems] SpawnPrefab: "..self.item)
        if TheInput:IsKeyDown(KEY_CTRL) then
            self:SetSpecialItem()
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            self:GiveRecipeItem(stack_mod)
        else
            self:GiveItem(stack_mod)
        end
    end
end

return InvSlot
