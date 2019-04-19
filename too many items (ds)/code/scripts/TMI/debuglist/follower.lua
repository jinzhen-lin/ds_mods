local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_TEXT,
    tag = "follower",
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_ADD,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_ADDTIP,
            fn = function()
                local player = GetPlayer()
                local x, y, z = player.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 5)
                for k, obj in pairs(ents) do
                    if not obj:HasTag("player") and
                    obj ~= GetWorld() and
                    obj.AnimState and
                    obj.Transform and
                    obj.components and
                    obj.components.follower ~= nil then
                        if obj.components.combat and obj.components.combat.target == player then
                            obj.components.combat:SetTarget(nil)
                        end
                        if player.components.leader ~= nil then
                            player:PushEvent("makefriend")
                            player.components.leader:AddFollower(obj)
                            obj.components.follower:AddLoyaltyTime(6000)
                            obj.components.follower.maxfollowtime = 6000
                        end
                    end
                end
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_EXPEL,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_EXPELTIP,
            fn = function()
                local player = GetPlayer()
                local x, y, z = player.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 8)
                for k, obj in pairs(ents) do
                    if obj.components and
                    obj.components.follower ~= nil and
                    player.components.leader ~= nil and
                    player.components.leader:IsFollower(obj) then
                        player.components.leader:RemoveFollower(obj)
                        obj.components.follower.targettime = 0
                    end
                end
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_HEALTH,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_HEALTHTIP,
            fn = function()
                local player = GetPlayer()
                local x, y, z = player.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 30)
                for k, obj in pairs(ents) do
                    if obj.components and
                    obj.components.follower ~= nil and
                    player.components.leader ~= nil and
                    player.components.leader:IsFollower(obj) and
                    obj.components.health then
                        obj.components.health:SetPercent(1)
                    end
                end
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_HUNGER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_HUNGERTIP,
            fn = function()
                local player = GetPlayer()
                local x, y, z = player.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 30)
                for k, obj in pairs(ents) do
                    if obj.components and
                    obj.components.follower ~= nil and
                    player.components.leader ~= nil and
                    player.components.leader:IsFollower(obj) and
                    obj.components.hunger then
                        obj.components.hunger:SetPercent(1)
                    end
                end
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_LOYAL,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_FOLLOWER_LOYALTIP,
            fn = function()
                local player = GetPlayer()
                local x, y, z = player.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 30)
                for k, obj in pairs(ents) do
                    if obj.components and
                    obj.components.follower ~= nil and
                    player.components.leader ~= nil and
                    player.components.leader:IsFollower(obj) and
                    obj.components.follower.maxfollowtime then
                        obj.components.follower.targettime = obj.components.follower.maxfollowtime + GetTime()
                        if obj.components.domesticatable then
                            obj.components.domesticatable:DeltaObedience(1)
                        end
                    end
                end
            end,
        },
    },
}

return _TMI.ModifyDebuglist(res, "follower", _TMI.locals())