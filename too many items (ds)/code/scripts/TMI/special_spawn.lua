local special_spawn = {}

-- 激活远古机器人的身躯、腿、手掌、头
special_spawn["ancient_robot_ribs"] = {
    activate = function(inst)
        inst:DoTaskInTime(5 * FRAMES, function()
            inst.lifetime = 90
            if inst:HasTag("dormant") then
                inst.wantstodeactivate = nil
                inst:RemoveTag("dormant")
                inst:PushEvent("shock")
                if not inst.updatetask then
                    inst.updatetask = inst:DoPeriodicTask(5, inst.periodicupdate)
                end
            end
        end)
    end
}
special_spawn["ancient_robot_leg"] = special_spawn["ancient_robot_ribs"]
special_spawn["ancient_robot_claw"] = special_spawn["ancient_robot_ribs"]
special_spawn["ancient_robot_head"] = special_spawn["ancient_robot_ribs"]

-- 让普通猪人变为猪人
special_spawn["pigman"] = {
    moon = function(inst)
        inst.components.werebeast:SetWere()
    end
}

-- 让普通桦树变化为桦树精
special_spawn["deciduoustree"] = {
    treeguard = function(inst)
        inst:DoTaskInTime(3 * FRAMES, function()
            inst.components.growable:SetStage(2)
            inst.leaf_state = "normal"
            inst:StartMonster()
        end)
    end
}

-- 让渡渡鸟宝宝长大为青年渡渡鸟
special_spawn["doydoybaby"] = {
    teen = function(inst)
        inst.components.growable:SetStage(2)
    end
}

-- 给伏特羊充能
special_spawn["lightninggoat"] = {
    charged = function(inst)
        inst:setcharged()
    end
}

-- 让猪强盗的宝藏显示出来
special_spawn["bandittreasure"] = {
    reveal = function(inst)
        if inst.Reveal then
            inst:Reveal()
        else
            inst:Remove()
        end
    end
}

-- 让宝藏（船难中那种）显示出来
special_spawn["buriedtreasure"] = special_spawn["bandittreasure"]

local function SetPigHouseColor(color)
    local house_builds = {
       pink = "pig_townhouse1_pink_build",
       green = "pig_townhouse1_green_build",
       white = "pig_townhouse1_white_build",
       brown = "pig_townhouse1_brown_build",
       beige = "pig_townhouse5_beige_build",
       red = "pig_townhouse6_red_build",   
    }
    local scalenum_list = {
        pink = 0.75,
        green = 0.75,
        brown = 0.75,
        white = 0.75,
        beige = 1,
        red = 1,
    }
    local build = house_builds[color]
    local scalenum = scalenum_list[color]
    return function(inst)
        local anim = inst.AnimState
        inst.build = build
        anim:SetBuild(build)
        anim:SetBank("pig_shop")
        inst.animset = "pig_shop"
        anim:SetScale(scalenum, scalenum, scalenum)

        anim:PlayAnimation("idle", true)
        local rnd1 = math.random()
        local color1 = rnd1 * 0.5 + 0.5
        anim:SetMultColour(color1, color1, color1, 1)
        inst.colornum = rnd1

        anim:Hide("YOTP")

        inst:PushEvent("onbuilt")
    end
end

-- 修改猪镇中普通猪房的颜色与样式
special_spawn["pighouse_city"] = {}
for _, color in pairs({"red", "brown", "white", "green", "beige", "white"}) do
    special_spawn["pighouse_city"][color] = SetPigHouseColor(color)
end

-- 直接代码生成的守卫塔不会加上旗子以及产生守卫
special_spawn["pig_guard_tower"] = {
    built = function(inst) inst:PushEvent("onbuilt") end
}

special_spawn["pig_guard_tower_palace"] = special_spawn["pig_guard_tower"]

-- 让块茎树开花
special_spawn["tubertree_tall"] = {
    blooming = function(inst) inst.components.bloomable:StartBloom() end
}

-- 让雨林树开花
special_spawn["rainforesttree_tall"] = {
    blooming = function(inst) inst.components.bloomable:StartBloom() end
}

local function SpawnLeader(inst, leader_name)
    local leader = SpawnPrefab(leader_name)
    inst.components.follower.leader = leader
    inst.components.container:GiveItem(leader)
    return leader
end

-- 产生普通切斯特、影切、冰切，并同时生成其对应的眼骨放入其中（防止其被删除）
special_spawn["chester"] = {
    witheyebone = function(inst)
        SpawnLeader(inst, "chester_eyebone")
    end,
    shadow_witheyebone = function(inst)
        SpawnLeader(inst, "chester_eyebone")
        inst:OnPreLoad({ChesterState = "SHADOW"})
    end,
    snow_witheyebone = function(inst)
        SpawnLeader(inst, "chester_eyebone")
        inst:OnPreLoad({ChesterState = "SNOW"})
    end
}

-- 产生普通鸟切、胖鸟切、火鸟切，并同时生成其对应的鱼骨放入其中（防止其被删除）
special_spawn["packim"] = {
    withfishbone = function(inst)
        SpawnLeader(inst, "packim_fishbone")
    end,
    fire_withfishbone = function(inst)
        SpawnLeader(inst, "packim_fishbone")
        inst:OnPreLoad({PackimState = "FIRE"})
    end,
    fat_withfishbone = function(inst)
        SpawnLeader(inst, "packim_fishbone")
        inst:OnPreLoad({PackimState = "FAT"})
    end
}

-- 生成robin对应的石头，防止其消失
-- 但生成石头会直接再生成一只robin，所以干脆直接把原来的删除
special_spawn["ro_bin"] = {
    withstone = function(inst)
        inst:Remove()
        local stone = SpawnPrefab("ro_bin_gizzard_stone")
        local x, y, z = GetPlayer().Transform:GetWorldPosition()
        stone.Transform:SetPosition(x, y, z)
    end
}

-- 让生成的虎鲨巢进入激活/未激活状态
special_spawn["sharkittenspawner"] = {
    active = function(inst)
        local function ReturnChildren(inst)
            for k, child in pairs(inst.components.childspawner.childrenoutside) do
                if child.components.homeseeker then
                    child.components.homeseeker:GoHome()
                end
                child:PushEvent("gohome")
            end
        end
        if not inst.spawneractive then
            inst.spawneractive = true

            inst.dusktime_fn = function()
                inst.components.childspawner:StopSpawning()
                ReturnChildren(inst)
            end

            inst.daytime_fn = function()
                inst.components.childspawner:StartSpawning()
            end

            inst.activatefn = function()
                inst.components.named:SetName(STRINGS.NAMES["SHARKITTENSPAWNER_ACTIVE"])
                inst.AnimState:PlayAnimation("idle_active")
                inst.blink_task = inst:DoPeriodicTask(math.random() * 10 + 10, function()
                    if inst.components.childspawner and inst.components.childspawner.childreninside > 0 then
                        inst.AnimState:PlayAnimation("blink")
                        inst.AnimState:PushAnimation("idle_active")
                    end
                end)
        
                inst:ListenForEvent("dusktime", inst.dusktime_fn, GetWorld())
                inst:ListenForEvent("daytime", inst.daytime_fn, GetWorld())
        
                if GetClock():IsDay() then
                    inst.daytime_fn()
                end

                inst:RemoveEventCallback("entitywake", inst.activatefn)
                inst.activatefn = nil
            end

            inst:ListenForEvent("entitywake", inst.activatefn)
            inst.activatefn()
        end
    end,
    inactive = function(inst)
        if inst.spawneractive then
            inst.spawneractive = false

            inst.deactivatefn = function()
                inst.components.named:SetName(STRINGS.NAMES["SHARKITTENSPAWNER_INACTIVE"])
                inst.AnimState:PlayAnimation("idle_inactive")
                if inst.blink_task then
                    inst.blink_task:Cancel()
                    inst.blink_task = nil
                end

                if inst.dusktime_fn and inst.daytime_fn then
                    inst:RemoveEventCallback("dusktime", inst.dusktime_fn, GetWorld())
                    inst:RemoveEventCallback("daytime", inst.daytime_fn, GetWorld())
                    inst.dusktime_fn = nil
                    inst.daytime_fn = nil
                end

                inst:RemoveEventCallback("entitywake", inst.deactivatefn)
                inst.deactivatefn = nil
            end

            inst:ListenForEvent("entitywake", inst.deactivatefn)
            inst.deactivatefn()
        end
    end,
}

-- 直接代码生成的秃鹫没有homeseeker这个组件，会出错
-- 这里添加下组件，如果没法找不到home的话，就删除秃鹫
special_spawn["buzzard"] = {
    home = function(inst)
        local buzzardspawner = TheSim:FindFirstEntityWithTag("buzzardspawner")
        if buzzardspawner then
            inst:AddComponent("homeseeker")
            inst.components.homeseeker:SetHome(buzzardspawner)
        else
            inst:Remove()
        end
    end
}

-- 直接代码生成的传送底座没有三个宝石位
special_spawn["telebase"] = {
    gemsocket = function(inst) inst:PushEvent("onbuilt") end
}


return special_spawn
