local container_map = {}
container_map.treasurechest = "TREASURECHEST"
container_map.chester = "CHESTER"
container_map.shadowchester = "CHESTER"
container_map.hutch = "CHESTER"
container_map.icebox = "ICEBOX"
container_map.chest = "OTHER_CHEST"
container_map.cookpot = "COOKPOT"
container_map.cooker = "OTHER_COOKER"
container_map.boat = "BOAT"

local function ModifyContainerRange(self)
    function self:OnUpdate(dt)
        local container_config_name = container_map[self.container.prefab]
        if container_config_name == nil then
            container_config_name = container_map[self.container.components.container.type]
        end
        local d = GetModConfigData(container_config_name) or GetModConfigData("OTHER") or 3
        if self.isopen and self.owner and self.container then
    		if not (self.container.components.inventoryitem and self.container.components.inventoryitem:IsHeldBy(self.owner)) then
    			local distsq = self.owner:GetDistanceSqToInst(self.container)
    			if distsq > d*d then
    				self:Close()
    			end
    		end
    	end
    end
end

AddClassPostConstruct("widgets/containerwidget", ModifyContainerRange)


AddPrefabPostInit("cookpot", function(self)
    self.components.playerprox.far = GetModConfigData(container_map.cookpot)
end)
