return {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_TEXT,
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.NAMES.LIGHTNING,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_LIGHTNINGTIP,
            fn = 'GetSeasonManager():DoLightningStrike(Vector3(GetPlayer().Transform:GetWorldPosition()))',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_WATER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_WATERTIP,
            fn = function()
                if not GetSeasonManager().precip then 
                    GetSeasonManager():StartPrecip() 
                else 
                    GetSeasonManager():StopPrecip() 
                end
            end,
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_VOLCANOERUPTION,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_VOLCANOERUPTIONTIP,
            fn = function()
                if not GetVolcanoManager():IsErupting() then 
                    GetVolcanoManager():StartEruption(60, 60, 60, 1 / 2)
                else 
                    GetVolcanoManager():Stop()
                    GetVolcanoManager():StopSmoke()
                end
            end,
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_STORM,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_STORMTIP,
            fn = function()
                if not GetSeasonManager().hurricane then 
                    GetSeasonManager():StartHurricaneStorm()
                else 
                    GetSeasonManager():StopHurricaneStorm()
                end
            end,
        },
        {
            beta = false,
            pos = {"porkland"},
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_FOG,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_WEATHER_FOGTIP,
            fn = function()
                if GetSeasonManager().fog_state ~= FOG_STATE.FOGGY then
                    GetSeasonManager().atmo_moisture = 3000
                    GetSeasonManager().fog_state = FOG_STATE.FOGGY
                else
                    GetSeasonManager().atmo_moisture = 0
                end
            end,
        },
    },
}