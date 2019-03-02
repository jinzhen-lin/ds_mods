local _G = GLOBAL
local isdst = _G.TheSim:GetGameID() == "DST"
local key_map = {
    ctrl = _G.CONTROL_FORCE_STACK,
    shift = _G.CONTROL_FORCE_TRADE,
    alt = _G.CONTROL_FORCE_INSPECT
}


-- 直接根据mod的id判断mod是否启动
local function IsModEnabled(modid)
    print("8329483920859028590")
    return _G.KnownModIndex:IsModEnabled("workshop-"..tostring(modid))
end


-- 判断动作执行者是否按了某个控制按键
local function IsPressed(doer, key)
    if isdst then
        return doer.components.playercontroller:IsControlPressed(key_map[key])
    else
        return _G.TheInput:IsControlPressed(key_map[key])
    end
end

-- 判断table中是否包含某个值
local function IsIncluded(value, tbl)
    for k, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- 将table的key和value互换
local function RevTable(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[v] = k
    end
    return res
end


-- 重新打包包裹
local function ReBundling(doer, item, item_list)
    local bundler = doer.components.bundler
    if item ~= nil and
        item.components.bundlemaker ~= nil and
        item.components.bundlemaker.bundlingprefab ~= nil and
        item.components.bundlemaker.bundledprefab ~= nil then
        bundler:StopBundling()
        bundler.bundlinginst = _G.SpawnPrefab(item.components.bundlemaker.bundlingprefab)
        if bundler.bundlinginst ~= nil then
            if bundler.bundlinginst.components.container ~= nil then
                bundler.bundlinginst.components.container:Open(bundler.inst)
                if bundler.bundlinginst.components.container:IsOpenedBy(bundler.inst) then
                    bundler.bundlinginst.entity:SetParent(bundler.inst.entity)
                    bundler.bundlinginst.persists = false
                    bundler.itemprefab = item.prefab
                    bundler.wrappedprefab = item.components.bundlemaker.bundledprefab
                    item.components.bundlemaker:OnStartBundling(bundler.inst)
                    bundler.inst.sg.statemem.bundling = true
                    bundler.inst.sg:GoToState("bundling")
                end
                for k, v in pairs(item_list) do
                    bundler.bundlinginst.components.container:GiveItem(v)
                end
            end
        end
    end
end

-- 展示打开包裹时的动画
local function ShowAnim(inst, doer, pos)
    local name = inst.prefab
    if isdst then
        _G.SpawnPrefab(name.."_unwrap").Transform:SetPosition(pos:Get())
    end
    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
    end
end

-- 获取打开包裹时的掉落物表格（除了包裹里本身包含的东西）
local function GetLootItemTable(inst, loottable)
    if loottable == nil then
        return {}
    end
    local lootitemtable = {}
    local moisture, iswet
    if isdst then
        moisture = inst.components.inventoryitem:GetMoisture()
        iswet = inst.components.inventoryitem:IsWet()
    end
    for i, v in ipairs(loottable) do
        local item = _G.SpawnPrefab(v)
        if item ~= nil then
            if item.components.inventoryitem ~= nil then
                if isdst then
                    item.components.inventoryitem:InheritMoisture(moisture, iswet)
                end
                table.insert(lootitemtable, item)
            end
        end
    end
    return lootitemtable
end

-- 获取包裹内包含的物品
local function GetBundleItemTable(self)
    if self.itemdata ~= nil then
        local creator = self.origin ~= nil and _G.TheWorld.meta.session_identifier ~= self.origin and { sessionid = self.origin } or nil
        local itemtable = {}
        for i, v in ipairs(self.itemdata) do
            local bundle_item = _G.SpawnPrefab(v.prefab, v.skinname, v.skin_id, creator)
            if bundle_item ~= nil and bundle_item:IsValid() then
                bundle_item:SetPersistData(v.data)
                table.insert(itemtable, bundle_item)
            end
        end
        return itemtable
    else
        return {}
    end
end

-- 获取包裹内包含的物品名称
local function GetBundleItemPrefabTable(self)
    if self.itemdata ~= nil then
        local itemprefabtable = {}
        for i, v in ipairs(self.itemdata) do
            table.insert(itemprefabtable, v.prefab)
        end
        return true, itemprefabtable
    else
        return true, {}
    end
end

-- 处理物品，让物品掉落或者交给动作执行者
local function HandleItem(doer, item, drop, pos)
    if drop then
        if pos == nil then
            pos = GetPos(item, doer)
        end
        if item ~= nil and item:IsValid() then
            if item.Physics ~= nil then
                item.Physics:Teleport(pos:Get())
            else
                item.Transform:SetPosition(pos:Get())
            end
            if item.components.inventoryitem ~= nil then
                item.components.inventoryitem:OnDropped(true)
            end
        end
    else
        doer.components.inventory:GiveItem(item)
    end
end

-- 获取特效显示以及物品掉落的位置
local function GetPos(inst, doer) 
    local function NoHoles(pt)
        return not _G.TheWorld.Map:IsPointNearHole(pt)
    end
    local pos = inst:GetPosition()
    if doer ~= nil and
        inst.components.inventoryitem ~= nil and
        inst.components.inventoryitem:GetGrandOwner() == doer then
        local doerpos = doer:GetPosition()
        local offset = _G.FindWalkableOffset(doerpos, doer.Transform:GetRotation() * _G.DEGREES, 1, 8, false, true, NoHoles)
        if offset ~= nil then
            pos.x = doerpos.x + offset.x
            pos.z = doerpos.z + offset.z
        else
            pos.x, pos.z = doerpos.x, doerpos.z
        end
    end
    return pos
end

-- 根据物品列表以及一些参数，决定最终是否把物品交给用户，还是重新打包，还是掉到地上
local function OnUnwrap(inst, doer, loottable, itemtable, wrap_item, rewrap, drop)
    local lootitemtable = GetLootItemTable(inst, loottable)
    local pos = GetPos(inst, doer)
    ShowAnim(inst, doer, pos)
    for k, v in pairs(lootitemtable) do
        HandleItem(doer, v, drop, pos)
    end
    if rewrap then
        if wrap_item ~= nil then
            ReBundling(doer, wrap_item, itemtable)
        else
            for k, v in pairs(itemtable) do
                HandleItem(doer, v, drop, pos)
            end
        end
    else
        if wrap_item ~= nil then
            HandleItem(doer, wrap_item, drop, pos)
        end
        for k, v in pairs(itemtable) do
            HandleItem(doer, v, drop, pos)
        end
    end
    inst:Remove()
end


-- 获取USEITEM类型的动作时的wrap_item和loottable
local function GetUseitemRepackRes(inst, know_bundlewrap, wrap_material, rewrap)
    local wrap_item, loottable
    if inst.prefab == "bundle" then
        if wrap_material.prefab == "rope" then
            if know_bundlewrap then
                wrap_item = _G.SpawnPrefab("bundlewrap")
                wrap_material.components.inventoryitem:RemoveFromOwner(false)
                loottable = {}
            else
                return false
            end
        elseif rewrap and wrap_material.prefab == "bundlewrap" then
            wrap_item = _G.SpawnPrefab("bundlewrap")
            local moisture, iswet
            if isdst then
                moisture = wrap_material.components.inventoryitem:GetMoisture()
                iswet = wrap_material.components.inventoryitem:IsWet()
                wrap_item.components.inventoryitem:InheritMoisture(moisture, iswet)
            end
            wrap_material.components.inventoryitem:RemoveFromOwner(false)
            loottable = {"waxpaper"}
        else
            return false
        end
    elseif inst.prefab == "gift" then
        if wrap_material.prefab == "giftwrap" and rewrap then
            wrap_item = _G.SpawnPrefab("giftwrap")
            if isdst then
                local moisture = wrap_material.components.inventoryitem:GetMoisture()
                local iswet = wrap_material.components.inventoryitem:IsWet()
                wrap_item.components.inventoryitem:InheritMoisture(moisture, iswet)
            end
            wrap_material.components.inventoryitem:RemoveFromOwner(false)
            loottable = {}
        else
            return false
        end
    end
    return true, wrap_item, loottable
end




-- 获取INVENTORY和SCENE类型的动作时的wrap_item和loottable
local function GetItemRepackRes(inst, know_bundlewrap, itemtable, rewrap)
    local material_map = {
        gift = {rewrap and "giftwrap" or nil},
        bundle = {rewrap and "bundlewrap" or nil, know_bundlewrap and "rope" or nil}
    }
    local material_table = material_map[inst.prefab]
    local material_revtable = RevTable(material_table)
    local i, t
    for k, v in pairs(itemtable) do
        i = material_revtable[v.prefab]
        t = i ~= nil and (t == nil or t >= i) and i or t
    end

    local itemtable_tmp = {}
    local use_material = false
    for k, v in pairs(itemtable) do
        i = material_revtable[v.prefab]
        if not use_material and t ~= nil and i == t then
            use_material = true
            material_num = v.components.stackable.stacksize
            if material_num > 1 then
                v.components.stackable.stacksize = material_num - 1
                table.insert(itemtable_tmp, v)
            else
                v:Remove()
            end
        else
            table.insert(itemtable_tmp, v)
        end
    end
    itemtable = itemtable_tmp

    local material_type = material_table[t]
    local wrap_item, loottable
    if material_type == "rope" and inst.prefab == "bundle" then
        wrap_item = _G.SpawnPrefab("bundlewrap")
        loottable = {}
    elseif material_type == "bundlewrap" and inst.prefab == "bundle" then
        wrap_item = _G.SpawnPrefab("bundlewrap")
        loottable = {"waxpaper"}
    elseif material_type == "giftwrap" and inst.prefab == "gift" then
        wrap_item = _G.SpawnPrefab("giftwrap")
        loottable = {}
    else
        return false
    end
    return true, wrap_item, loottable, itemtable
end


local function UnwrapAction(act, rewrap, drop, normal)
    local doer = act.doer
    local know_bundlewrap = doer.components.builder:KnowsRecipe("bundlewrap")
    local self, wrap_material
    if act.target ~= nil then
        self = act.target.components.unwrappable
        wrap_material = act.invobject
    else
        self = act.invobject.components.unwrappable
        wrap_material = nil
    end
    
    local inst = self.inst
    local itemtable = GetBundleItemTable(self)
    local success, wrap_item, loottable
    if normal then
        success = true
        wrap_item = nil
        if inst.prefab == "bundle" then
            loottable = {"waxpaper"}
        elseif inst.prefab == "gift" then
            loottable = {}
        else
            return false
        end
    elseif wrap_material ~= nil then
        success, wrap_item, loottable = GetUseitemRepackRes(inst, know_bundlewrap, wrap_material, rewrap)
    elseif IsIncluded(inst.prefab, {"bundle", "gift"}) then
        success, wrap_item, loottable, itemtable = GetItemRepackRes(inst, know_bundlewrap, itemtable, rewrap)
    else
        return false
    end
    if not success then return false end
    OnUnwrap(inst, doer, loottable, itemtable, wrap_item, rewrap, drop)
    return true
end


-- 动作显示的文字
_G.STRINGS.ACTIONS.REWRAP = {
    REWRAP = "Rewrap"
}
-- 如果启用了中文语言包mod
if _G.KnownModIndex:IsModEnabled("workshop-367546858") or
    _G.KnownModIndex:IsModEnabled("workshop-1418746242") then
    _G.STRINGS.ACTIONS.REWRAP.REWRAP = "重新打包"
end


-- 单机版和联机版定义Action的方式有差异
local DSTAction = function(data)
    action = isdst and _G.Action(data) or _G.Action(
        {data.mount_enabled}, data.priority, data.instant, data.rmb
    )
    return action
end

-- 新的拆开包裹动作：打开包裹，并重新制作包装纸（物品掉落）
local UNWRAP_NEW = DSTAction({priority = 500, instant = false, rmb = true})
UNWRAP_NEW.id = "UNWRAP_NEW"
UNWRAP_NEW.str = _G.STRINGS.ACTIONS.UNWRAP
UNWRAP_NEW.strfn  = _G.STRINGS.ACTIONS.UNWRAP.strfn
UNWRAP_NEW.fn = function(act)
    return UnwrapAction(act, false, true, false)
end
AddAction(UNWRAP_NEW)
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.UNWRAP_NEW, "dolongaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.UNWRAP_NEW, "dolongaction"))


-- 新的拆开包裹动作：打开包裹，并重新制作包装纸（物品不掉落）
local UNWRAP_NEW_NODROP = DSTAction({priority = 500, instant = false, rmb = true})
UNWRAP_NEW_NODROP.id = "UNWRAP_NEW_NODROP"
UNWRAP_NEW_NODROP.str = _G.STRINGS.ACTIONS.UNWRAP
UNWRAP_NEW_NODROP.strfn  = _G.STRINGS.ACTIONS.UNWRAP.strfn
UNWRAP_NEW_NODROP.fn = function(act)
    return UnwrapAction(act, false, false, false)
end
AddAction(UNWRAP_NEW_NODROP)
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.UNWRAP_NEW_NODROP, "dolongaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.UNWRAP_NEW_NODROP, "dolongaction"))


-- 新的拆开包裹动作：打开包裹，并重新制作包装纸（物品不掉落）
local UNWRAP_NODROP = DSTAction({priority = 500, instant = false, rmb = true})
UNWRAP_NODROP.id = "UNWRAP_NODROP"
UNWRAP_NODROP.str = _G.STRINGS.ACTIONS.UNWRAP
UNWRAP_NODROP.strfn  = _G.STRINGS.ACTIONS.UNWRAP.strfn
UNWRAP_NODROP.fn = function(act)
    return UnwrapAction(act, false, false, true)
end
AddAction(UNWRAP_NODROP)
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.UNWRAP_NODROP, "dolongaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.UNWRAP_NODROP, "dolongaction"))


-- 重新打包的动作：打开包裹后重新进入打包模式
local REWRAP = DSTAction({priority = 500, instant = false, rmb = true})
REWRAP.id = "REWRAP"
REWRAP.str = _G.STRINGS.ACTIONS.REWRAP
REWRAP.strfn  = function(act)
    return "REWRAP"
end
REWRAP.fn = function(act)
    return UnwrapAction(act, true, true, false)
end
AddAction(REWRAP)
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.REWRAP, "dolongaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.REWRAP, "dolongaction"))


-- 重新打包的动作：打开包裹后重新进入打包模式
local REWRAP_NODROP = DSTAction({priority = 500, instant = false, rmb = true})
REWRAP_NODROP.id = "REWRAP_NODROP"
REWRAP_NODROP.str = _G.STRINGS.ACTIONS.REWRAP
REWRAP_NODROP.strfn  = function(act)
    return "REWRAP"
end
REWRAP_NODROP.fn = function(act)
    return UnwrapAction(act, true, false, false)
end
AddAction(REWRAP_NODROP)
AddStategraphActionHandler("wilson", _G.ActionHandler(_G.ACTIONS.REWRAP_NODROP, "dolongaction"))
AddStategraphActionHandler("wilson_client", _G.ActionHandler(_G.ACTIONS.REWRAP_NODROP, "dolongaction"))


local AllModActions = {"REWRAP", "REWRAP_NODROP", "UNWRAP_NEW", "UNWRAP_NEW_NODROP", "UNWRAP", "UNWRAP_NODROP"}

-- 对Unwrappable类型的物品的动作绑定
local function UnwrappableActionBind(inst, doer, actions, right, scene)
    if (right or not scene) and doer and doer.components.playercontroller then
        if IsIncluded(inst.prefab, {"bundle", "gift"}) then
            local unwrap_act, rewrap_act, action
            normal_unwrap_act = IsPressed(doer, "ctrl") and _G.ACTIONS.UNWRAP or _G.ACTIONS.UNWRAP_NODROP
            unwrap_act = IsPressed(doer, "ctrl") and _G.ACTIONS.UNWRAP_NEW or _G.ACTIONS.UNWRAP_NEW_NODROP
            rewrap_act = IsPressed(doer, "ctrl") and _G.ACTIONS.REWRAP or _G.ACTIONS.REWRAP_NODROP
            action = IsPressed(doer, "shift") and inst.prefab == "bundle" and unwrap_act or nil
            action = action or IsPressed(doer, "alt") and rewrap_act or nil
            action = action or normal_unwrap_act or nil
            table.insert(actions, action)
        end
    end
end

-- 对WrapMaterial类型的物品的动作绑定
local function WrapMaterialActionBind(inst, doer, target, actions, right)
    if right and doer and doer.components.playercontroller then
        local unwrap_act, rewrap_act, action
        unwrap_act = IsPressed(doer, "ctrl") and _G.ACTIONS.UNWRAP_NEW or _G.ACTIONS.UNWRAP_NEW_NODROP
        rewrap_act = IsPressed(doer, "ctrl") and _G.ACTIONS.REWRAP or _G.ACTIONS.REWRAP_NODROP
        action = IsPressed(doer, "alt") and rewrap_act or unwrap_act
        if target.prefab == "bundle" then
            if inst.prefab == "rope" or inst.prefab == "bundlewrap" and IsPressed(doer, "alt") then
                table.insert(actions, action)
            end
        elseif target.prefab == "gift" and inst.prefab == "giftwrap" and IsPressed(doer, "alt") then
            table.insert(actions, action)
        end
	end
end

AddPrefabPostInitAny(function(inst)
    local wrap_material_tbl = {"bundlewrap", "rope", "giftwrap"}
	if inst and IsIncluded(inst.prefab, wrap_material_tbl) then
		inst:AddComponent("wrap_material")
	end
end)

if isdst then
    AddComponentAction("INVENTORY", "unwrappable", function(inst, doer, actions, right)
        return UnwrappableActionBind(inst, doer, actions, right, false)
    end)
    AddComponentAction("SCENE", "unwrappable", function(inst, doer, actions, right)
        return UnwrappableActionBind(inst, doer, actions, right, true)
    end)
    AddComponentAction("USEITEM", "wrap_material", WrapMaterialActionBind)
else
    AddComponentPostInit("unwrappable", function(self)
        function self:CollectSceneActions(doer, actions, right)
            return UnwrappableActionBind(self.inst, doer, actions, right, true)
        end
        function self:CollectInventoryActions(doer, actions, right)
            return UnwrappableActionBind(self.inst, doer, actions, right, false)
        end
    end)

    AddComponentPostInit("wrap_material", function(self) 
        function self:CollectUseActions(doer, target, actions, right)
            return WrapMaterialActionBind(self.inst, doer, target, actions, right)
        end
    end)
end

if isdst and IsModEnabled(1608191708) then
    -- 对于ActionQueue Reborn这个mod，允许本mod中定义的几个Action加入行为队列
    -- For "ActionQueue Reborn", allow several actions defined in this mod to join the action queue
    AddComponentPostInit("actionqueuer", function(self)
        local _oldGetAction = self.GetAction
        function self:GetAction(target, rightclick, pos)
            local pos = pos or target:GetPosition()
            local picker = self.inst.components.playeractionpicker
            local rightclick_actions = rightclick and picker:GetRightClickActions(pos, target) or {}
            for _, act in ipairs(rightclick_actions) do
                if IsIncluded(act.action.id, AllModActions) then
                    return act, true
                end
            end
            return _oldGetAction(self, target, rightclick, pos)
        end
    end)
end


if false and (IsModEnabled(873350047) or IsModEnabled(928939144)) then
    -- 如果物品是包裹，则覆盖“快捷丢弃-客户端版本”的行为
    -- If the item is a bundle, override the "Quick Drop - Client Version" behavior
    -- 是否有必要更改？以下代码已经可以实现需求，但暂时不启用了
    -- Is it necessary to change it? The following code can already meet the requirements, but is not enabled for the time being
    AddComponentPostInit("playeractionpicker", function(self)
        local _oldGetInventoryActions = self.GetInventoryActions
        function self:GetInventoryActions(useitem, right)
            local sorted_acts = _oldGetInventoryActions(self, useitem, right)
            local unwrap_act = IsPressed(self.inst, "ctrl") and _G.ACTIONS.UNWRAP_NEW or _G.ACTIONS.UNWRAP_NEW_NODROP
            if useitem.prefab == "bundle" and IsPressed(self.inst, "shift") and not IsPressed(self.inst, "alt") then
                sorted_acts = self:SortActionList({ unwrap_act }, _G.Vector3(_G.GetPlayer().Transform:GetWorldPosition()), useitem)
            end
            return sorted_acts
        end
    end)

    local self = _G.require "widgets/invslot"
    local _oldOnControl = self.OnControl
    function self:OnControl(control, down, ...)
        if down and control == _G.CONTROL_SECONDARY and IsPressed(self.owner, "shift") and self.tile and self.tile.item.prefab == "bundle" then
            if isdst then
                self:UseItem()
            else
                _G.GetPlayer().components.inventory:UseItemFromInvTile(self.tile.item)
            end
        else
            return _oldOnControl(self, control, down, ...)
        end
    end
end