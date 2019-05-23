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
        local d = GetModConfigData(container_config_name) or GetModConfigData("OTHER") or 3
        if (self.opener == nil and self.opencount == nil) or self.opencount == 0 then
            self.inst:StopUpdatingComponent(self)
        else
            local openlist = self.openlist or {self.opener = ""}
            for doer, _ in pairs(openlist) do
                if doer ~= nil
                    and not (self.inst.components.inventoryitem ~= nil 
                    and self.inst.components.inventoryitem:IsHeldBy(doer))
                    and ((doer.components.rider ~= nil 
                    and doer.components.rider:IsRiding())
                    or not (doer:IsNear(self.inst, d) 
                    and GLOBAL.CanEntitySeeTarget(doer, self.inst))) then
                self:Close(doer)
            end
        end
    end
end

AddComponentPostInit("container", ModifyContainerRange)
