local container_map = {}
container_map.treasurechest = "TREASURECHEST"
container_map.chester = "CHESTER"
container_map.shadowchester = "CHESTER"
container_map.hutch = "CHESTER"
container_map.icebox = "ICEBOX"
container_map.chest = "OTHER_CHEST"
container_map.cookpot = "COOKPOT"
container_map.cooker = "OTHER_COOKER"

local function ModifyContainerRange(self)
    function self:OnUpdate(dt)
        local container_config_name = container_map[self.inst.prefab]
        if container_config_name == nil then
          container_config_name = container_map[self["type"]]
        end
        local d = GetModConfigData(container_config_name) or 3
        if self.opener == nil then
            self.inst:StopUpdatingComponent(self)
        elseif not (self.inst.components.inventoryitem ~= nil and
                    self.inst.components.inventoryitem:IsHeldBy(self.opener))
            and ((self.opener.components.rider ~= nil and self.opener.components.rider:IsRiding())
                or not (self.opener:IsNear(self.inst, d) and
                        GLOBAL.CanEntitySeeTarget(self.opener, self.inst))) then
            self:Close()
        end
    end
end

AddComponentPostInit("container", ModifyContainerRange)
