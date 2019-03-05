local _G = GLOBAL

if GetModConfigData("COFFEE") then
    -- 改变咖啡的食物分类
    local function AlterCoffee(inst)
        inst.components.edible.foodtype = "COFFEE"
    end
    AddPrefabPostInit("coffee", AlterCoffee)
end


if GetModConfigData("NETTLE") then
    -- 改变荨麻和荨麻卷的食物分类
    local function AlterNettle(inst)
        inst.components.edible.foodtype = "NETTLE"
    end
    AddPrefabPostInit("cutnettle", AlterNettle)
    AddPrefabPostInit("nettlelosange", AlterNettle)
end


-- 为食物类别表格添加咖啡和荨麻这两种食物类别
local function ModifyFoodTable(foodtable, carnivore)
    if type(foodtable) == "table" and (carnivore or table.contains(foodtable, "VEGGIE")) then
        if GetModConfigData("COFFEE") and not table.contains(foodtable, "COFFEE") then
            table.insert(foodtable, "COFFEE")
        end
        if GetModConfigData("NETTLE") and not table.contains(foodtable, "NETTLE") then
            table.insert(foodtable, "NETTLE")
        end
    end
end


-- 修改人物/生物可以吃的食物类别，为原来就可以吃蔬菜的人添加可以吃咖啡和荨麻这两种食物类别
-- 同时为肉食者添加可以吃咖啡和荨麻这两种食物类别
AddComponentPostInit("eater", function(self)
    local _oldSetCarnivore = self.SetCarnivore
    function self:SetCarnivore(human)
        _oldSetCarnivore(self, human)
        ModifyFoodTable(self.foodprefs, true)    
        if human then
            ModifyFoodTable(self.ablefoods, true)
        end
    end

    ModifyFoodTable(self.foodprefs)
    ModifyFoodTable(self.ablefoods)

    for k, v in pairs(_G.getmetatable(self)) do
        if type(v) == "function" and k ~= "SetCarnivore" and string.sub(k, 1, 3) == "Set" then
            _oldSetFunc = v
            self[k] = function(self, ...)
                _oldSetFunc(self, ...)
                ModifyFoodTable(self.foodprefs)
                ModifyFoodTable(self.ablefoods)
            end
        end
    end
end)
