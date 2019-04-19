local function ModifySpeedMultiplier(speedmult_extra)
    if not speedmult_extra then
        speedmult_extra = 1
    end
    local locomotor_ = GetPlayer().components.locomotor or nil
    local player = GetPlayer()
    if player and locomotor_ and locomotor_.GetSpeedMultiplier then 
        if locomotor_._tmi_speedmult_extra == nil then
            locomotor_._tmi_speedmult_extra = 1
            local _oldGetSpeedMultiplier = locomotor_.GetSpeedMultiplier
            locomotor_.GetSpeedMultiplier = function(self)
                return _oldGetSpeedMultiplier(self) * self._tmi_speedmult_extra
            end
        end
    end
    return function()
        if player and locomotor_ then
            locomotor_._tmi_speedmult_extra = speedmult_extra
        end
    end
end

local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_TEXT,
    tag = "speed",
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_SLOW,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_SLOWTIP,
            fn = ModifySpeedMultiplier(0.6),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_NORMAL,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_NORMALTIP,
            fn = ModifySpeedMultiplier(1),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_FAST,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_FASTTIP,
            fn = ModifySpeedMultiplier(2),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_SFAST,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_SFASTTIP,
            fn = ModifySpeedMultiplier(3),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_FLY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SPEED_FLYTIP,
            fn = ModifySpeedMultiplier(4),
        },
    },
}

return _TMI.ModifyDebuglist(res, "speed", _TMI.locals())