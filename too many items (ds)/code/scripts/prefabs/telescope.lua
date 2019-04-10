local assets=
{
	Asset("ANIM", "anim/telescope.zip"),
	Asset("ANIM", "anim/telescope_long.zip"),
	Asset("ANIM", "anim/swap_telescope.zip"),
	Asset("ANIM", "anim/swap_telescope_long.zip"),
	Asset("INV_IMAGE", "supertelescope"),
	--Asset("INV_IMAGE", "telescope_long"),
}

local prefabs =
{
}

local function Look(inst, range, x, y, z, angle, arc)
	print(string.format("Telescope (%4.2f, %4.2f, %4.2f), range=%4.2f, angle=%4.2f\n", x, y, z, range, angle))
	
	GetPlayer().HUD.controls:ToggleMap()

	local minimap = GetWorld().minimap.MiniMap
	local map = GetWorld().Map
	local arclength = 0.5 * range * arc * DEGREES

	if not GetClock():IsDay() then
		range = range / 2
	end

	--print("arclength" .. arclength)
	
	local i = 1

	local looking = function(inst)

		for d = 1, 2 do -- need this to speed it up
			if i < range then
				for j = 0, arclength, 4 do
					local a = angle + (j / (0.5 * range * DEGREES))
					print(string.format("%4.2f = (%4.2f / %4.2f)\n", a, j, arclength))
					local c = math.cos(a * DEGREES)
					local s = math.sin(a * DEGREES)
					local x0, z0 = x + i * c, z + i * s
					local cx, cy, cz = map:GetTileCenterPoint(x0, 0, z0)
					if cx and cy and cz then
						minimap:ShowArea(cx, cy, cz, 30)
						--map:VisitTile(map:GetTileCoordsAtPoint(cx, cy, cz))
					end
				end
			end
			i = i + 8
		end
	end
	local MapScreen = require "screens/mapscreen"
	MapScreen:SetOnUpdateFn(looking)
	MapScreen:SetOnBecomeInactiveFn(nil)
end

local function onfinished(inst)
	local user = inst.components.inventoryitem:GetGrandOwner()
	if not user then
		inst:Remove()
	else
		user:ListenForEvent("animover", function() 
			inst:Remove()
		end)
	end
end

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_telescope", "swap_object")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onsuperequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_telescope_long", "swap_object")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner)
	-- print("telescope onunequip")
	-- --print(debug.traceback())
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function oncast(inst, target, pos)
        print("========================")
	-- You can find this line in SGWilson and SGWilsonboating in the peertelescope state
	-- Because the telescope needs to exist after casting the last spell so the putaway animation can play.
	inst.components.finiteuses:Use()
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/use_spyglass_reveal")

	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local angle = -GetPlayer():GetAngleToPoint(pos.x, pos.y, pos.z) - ((TUNING.TELESCOPE_ARC/2))
	Look(inst, TUNING.TELESCOPE_RANGE, x, y, z, angle, TUNING.TELESCOPE_ARC)
end

local function onsupercast(inst, target, pos)
	inst.components.finiteuses:Use()
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/supertelescope")

	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local angle = -GetPlayer():GetAngleToPoint(pos.x, pos.y, pos.z) - ((TUNING.TELESCOPE_ARC/2))
	Look(inst, TUNING.SUPERTELESCOPE_RANGE, x, y, z, angle, TUNING.TELESCOPE_ARC)
end

local function peertest(inst, doer, target, pos)
	-- if doer and pos then
	-- 	doer:ForceFacePoint(pos.x, pos.y, pos.z)
	-- end
	return true
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst:AddTag("nopunch")

	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TELESCOPE_USES)
	inst.components.finiteuses:SetUses(TUNING.TELESCOPE_USES)
	inst.components.finiteuses:SetOnFinished(onfinished)
	-------
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("reticule")
	inst.components.reticule.targetfn = function() 
        return Vector3(GetPlayer().entity:LocalToWorldSpace(5,0,0))
    end
	inst.components.reticule.ease = true

	inst:AddComponent("spellcaster")
	inst.components.spellcaster:SetAction(ACTIONS.PEER)
    inst.components.spellcaster:SetSpellFn(oncast)
    inst.components.spellcaster:SetSpellTestFn(peertest)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false
	
	return inst
end

local function normalfn(Sim)
	local inst = fn(Sim)

	inst.AnimState:SetBank("telescope")
	inst.AnimState:SetBuild("telescope")
	inst.AnimState:PlayAnimation("idle")

	inst.components.inventoryitem.imagename = "telescope"

	inst.components.equippable:SetOnEquip(onequip)
	
	inst.components.spellcaster:SetSpellFn(oncast)


	return inst
end

local function superfn(Sim)
	local inst = fn(Sim)

	inst.AnimState:SetBank("telescope_long")
	inst.AnimState:SetBuild("telescope_long")
	inst.AnimState:PlayAnimation("idle")

	--inst.components.inventoryitem.imagename = "telescope_long"
	--inst.components.inventoryitem:ChangeImageName("telescope_long")
	
	inst.components.equippable:SetOnEquip(onsuperequip)

	inst.components.spellcaster:SetSpellFn(onsupercast)


	return inst
end

return Prefab( "common/inventory/telescope", normalfn, assets, prefabs),
	   Prefab( "common/inventory/supertelescope", superfn, assets, prefabs)
