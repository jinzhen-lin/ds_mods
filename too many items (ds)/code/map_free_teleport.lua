
local function water_teleport_handle(inst, x, y, z)
    if not _G.GROUND.OCEAN_SHALLOW then
        return
    end
    local boating = inst.components.driver and inst.components.driver:GetIsDriving()
    local onwater = _G.GetWorld().Map:GetTileAtPoint(x, y, z) >= _G.GROUND.OCEAN_SHALLOW
    if boating and onwater == false then
        -- 在船上但目标在地面，则将船停在原处
        inst.components.driver:OnDismount()
    elseif not boating and onwater == true then
        -- 不在船上但目标在水上，则生成一艘木筏并乘上船
        local boat = _G.SpawnPrefab("lograft")
        if boat then
            inst.components.driver:OnMount(boat)
            boat.components.drivable:OnMounted(inst)
        end
    end
end

local function GetTargetDoor()
    local interiorspawner = _G.GetWorld().components.interiorspawner
    if not interiorspawner or not interiorspawner:IsInInterior() then
        return
    end
    local object_list = interiorspawner:GetCurrentInteriorEntities()
    for _, object in pairs(object_list) do
        local door = object.components.door
        if door and not door.target_interior then
            if interiorspawner.doors[door.target_door_id] then
                return interiorspawner.doors[door.target_door_id].inst
            end
        end
    end
end

local function GetRoomMapLayout()
    local room_map_layout = {}
    local pos_map = {}
    local interiorspawner = _G.GetWorld().components.interiorspawner
    local function GetLayout(current_pos)
        local pos_x = pos_map[current_pos][1]
        local pos_y = pos_map[current_pos][2]
        local object_list
        if current_pos == "0_0" then
            object_list = interiorspawner:GetCurrentInteriorEntities()
        else
            object_list = room_map_layout[current_pos].object_list
        end
        for _, object in pairs(object_list) do
            local door = object.components.door
            if door and door.target_interior then
                local connected_interior = interiorspawner:GetInteriorByName(door.target_interior)
                local pos_x_new, pos_y_new, pos_str_new
                if object:HasTag("door_north") then
                    pos_x_new = pos_x
                    pos_y_new = pos_y + 1
                elseif object:HasTag("door_south") then
                    pos_x_new = pos_x
                    pos_y_new = pos_y - 1
                elseif object:HasTag("door_east") then
                    pos_x_new = pos_x + 1
                    pos_y_new = pos_y
                elseif object:HasTag("door_west") then
                    pos_x_new = pos_x - 1
                    pos_y_new = pos_y
                end
                pos_str_new = tostring(pos_x_new).."_"..tostring(pos_y_new)
                for k, v in pairs(pos_map) do
                    if k == pos_str_new then
                        pos_str_new = nil
                        break
                    end
                end
                if pos_str_new then
                    pos_map[pos_str_new] = {pos_x_new, pos_y_new}
                    room_map_layout[pos_str_new] = connected_interior
                    GetLayout(pos_str_new)
                end
            end
        end
        
        local prefab_list = room_map_layout[current_pos].prefabs
        prefab_list = prefab_list or {}
        
        for _, prefab in pairs(prefab_list) do
            if prefab.name == "prop_door" then
                local door_tag = prefab.addtags[2]
                local pos_x_new, pos_y_new, pos_str_new
                if door_tag == "door_north" then
                    pos_x_new = pos_x
                    pos_y_new = pos_y + 1
                elseif door_tag == "door_south" then
                    pos_x_new = pos_x
                    pos_y_new = pos_y - 1
                elseif door_tag == "door_east" then
                    pos_x_new = pos_x + 1
                    pos_y_new = pos_y
                elseif door_tag == "door_west" then
                    pos_x_new = pos_x - 1
                    pos_y_new = pos_y
                end
                pos_str_new = tostring(pos_x_new).."_"..tostring(pos_y_new)
                for k, v in pairs(pos_map) do
                    if k == pos_str_new then
                        pos_str_new = nil
                        break
                    end
                end
                if pos_str_new then
                    pos_map[pos_str_new] = {pos_x_new, pos_y_new}
                    room_map_layout[pos_str_new] = connected_interior
                    GetLayout(pos_str_new)
                end
            end
        end
    end

    if not interiorspawner then
        return
    elseif not interiorspawner:IsInInterior() then
        return
    else
        local related_interiors = interiorspawner:GetCurrentInteriors()
        room_map_layout["0_0"] = interiorspawner.current_interior
        pos_map["0_0"] = {0, 0}
        if (#related_interiors) > 1 then
            GetLayout("0_0")
        end
        return room_map_layout
    end
end

AddClassPostConstruct("screens/mapscreen", function(MapScreen)
    local _oldOnControl = MapScreen.OnControl
    function MapScreen:OnControl(control, down)
        if not down and control == _G.CONTROL_ACCEPT then
            if _G.TheInput:IsKeyDown(_G.KEY_CTRL) and _G.TheInput:IsKeyDown(_G.KEY_SHIFT) then
                local interiorspawner = _G.GetWorld().components.interiorspawner
                local isininterior = interiorspawner and interiorspawner:IsInInterior()
                local related_interiors = {}
                if interiorspawner and isininterior then
                    related_interiors = interiorspawner:GetCurrentInteriors()
                end

                if not isininterior or (#related_interiors <= 1) then
                    local x, y, z = self.minimap:GetWorldMousePosition():Get()
                    if isininterior then
                        local is_invincible = _G.GetPlayer().components.health:IsInvincible()
                        _G.GetPlayer().components.health:SetInvincible(true)
                        _G.GetWorld().doorfreeze = true
                        interiorspawner.to_target = GetTargetDoor()
                        interiorspawner.to_interior = nil
                        interiorspawner:FadeOutFinished()
                        _G.GetPlayer().components.health:SetInvincible(is_invincible)
                    end
                    water_teleport_handle(_G.GetPlayer(), x, y, z)
                    _G.GetPlayer().Physics:Teleport(x, y, z)
            		_G.TheFrontEnd:PopScreen()
                    return true
                else
                    local target_interior = self.minimap:GetMouseInterior()
                    if target_interior then
                        interiorspawner:UnloadInterior()
                        interiorspawner:LoadInterior(target_interior)
                        _G.TheFrontEnd:PopScreen()
                        return true
                    end
                end                
            end
    	end
        return _oldOnControl(self, control, down)
    end
end)

AddClassPostConstruct("widgets/mapwidget", function(MapWidget)
    local map_offset = _G.Vector3(0, 0, 0)

    local _oldOnUpdate = MapWidget.OnUpdate
	function MapWidget:OnUpdate(...)
    	if not self.shown then return end
    	
    	if _G.TheInput:IsControlPressed(_G.CONTROL_PRIMARY) then
            local pos = _G.TheInput:GetScreenPosition()
    		if self.lastpos then
    			local scale = 0.2
    			local dx = scale * ( pos.x - self.lastpos.x )
    			local dy = scale * ( pos.y - self.lastpos.y )
                self:Offset(dx, dy)
    		end
    		self.lastpos = pos
    	else
    		self.lastpos = nil
    	end
	end

    local _oldOffset = MapWidget.Offset
	function MapWidget:Offset(dx, dy, ...)
		map_offset.x = map_offset.x + dx
		map_offset.y = map_offset.y + dy
		_oldOffset(self, dx, dy, ...)
	end

	local _oldOnShow = MapWidget.OnShow
	function MapWidget:OnShow(...)
		map_offset.x = 0
		map_offset.y = 0
		_oldOnShow(self, ...)
	end

	local _oldOnZoomIn = MapWidget.OnZoomIn
	function MapWidget:OnZoomIn(...)
		local zoom1 = self.minimap:GetZoom()
		_oldOnZoomIn(self, ...)
		local zoom2 = self.minimap:GetZoom()
		if self.shown then
			map_offset = map_offset * zoom1 / zoom2
		end
	end

	local _oldOnZoomOut = MapWidget.OnZoomOut
	function MapWidget:OnZoomOut(...)
		local zoom1 = self.minimap:GetZoom()
		_oldOnZoomOut(self, ...)
		local zoom2 = self.minimap:GetZoom()
		if self.shown and zoom1 < 20 then
			map_offset = map_offset * zoom1 / zoom2
		end
	end
	
	function MapWidget:GetWorldMousePosition()
        local target_door = GetTargetDoor()
		local screenwidth, screenheight = _G.TheSim:GetScreenSize()
        
        -- 玩家图标在地图界面上的像素位置
		local cx = screenwidth * .5 + map_offset.x * 4.5
		local cy = screenheight * .5 + map_offset.y * 4.5
        
        -- 鼠标在地图界面上的像素位置
		local mx, my = _G.TheInput:GetScreenPosition():Get()
		if _G.TheInput:ControllerAttached() then
			mx, my = screenwidth * .5, screenheight * .5
		end

        -- 两个位置的偏移
		local ox = mx - cx
		local oy = my - cy
        
        
        -- 像素位置差转换为在实际地图上的坐标距离
        local angle
        if target_door then
		    angle = 0
        else
            angle = _G.TheCamera:GetHeadingTarget() * math.pi / 180
        end

		local wd = math.sqrt(ox * ox + oy * oy) * self.minimap:GetZoom() / 4.5
		local wa = math.atan2(ox, oy) - angle

        -- 鼠标位置对应的地图坐标
        local px, pz
        if target_door then
            px, _, pz = target_door:GetPosition():Get()
        else
            px, _, pz = _G.GetPlayer():GetPosition():Get()
        end
		local wx = px - wd * math.cos(wa)
		local wz = pz + wd * math.sin(wa)
		return _G.Vector3(wx, 0, wz)
	end
    
    
    function MapWidget:GetMouseInterior()
        local interiorspawner = _G.GetWorld().components.interiorspawner
        if interiorspawner and not interiorspawner:IsInInterior() then
            return
        end
        local related_interiors = interiorspawner:GetCurrentInteriors()
        if (#related_interiors) <= 1 then
            return
        end
        
		local screenwidth, screenheight = _G.TheSim:GetScreenSize()

        -- 玩家所在房间的中心在地图上的像素位置
		local cx = screenwidth * .5 + map_offset.x * 4.5
		local cy = screenheight * .5 + map_offset.y * 4.5
        
        -- 鼠标在地图界面上的像素位置
		local mx, my = _G.TheInput:GetScreenPosition():Get()
		if _G.TheInput:ControllerAttached() then
			mx, my = screenwidth*.5, screenheight*.5
		end
        
        -- 两个位置的偏移
		local ox = mx - cx
		local oy = my - cy
        
        -- 实际距离差距
        ox = ox * self.minimap:GetZoom()
        oy = oy * self.minimap:GetZoom()

        -- interior width 和 interior depth
        local iw = interiorspawner.current_interior.width
        local id = interiorspawner.current_interior.depth
        
        -- 当zoom为1时interior的长和宽的像素数
        local iw_pixel = iw * 2.5 * 4.5
        local id_pixel = id * 2.5 * 4.5
        
		local i, j
        if math.abs(ox) < iw_pixel / 2 then
            i = 0
        else
            local interior_num = (math.abs(ox) - iw_pixel / 2) / (iw_pixel + 80)
            local interior_num_int = math.ceil(interior_num)
            local interior_num_deci = interior_num - interior_num_int + 1
            if interior_num_deci < 80 / (iw_pixel + 80) then
                return
            end
            i = interior_num_int * ox / math.abs(ox)
        end
        
        if math.abs(oy) < id_pixel / 2 then
            j = 0
        else
            local interior_num = (math.abs(oy) - id_pixel / 2) / (id_pixel + 80)
            local interior_num_int = math.ceil(interior_num)
            local interior_num_deci = interior_num - interior_num_int + 1
            if interior_num_deci < 80 / (id_pixel + 80) then
                return
            end
            j = interior_num_int * oy / math.abs(oy)
        end
        local room_map_layout = GetRoomMapLayout()
        return room_map_layout[tostring(i).."_"..tostring(j)]
	end
end)