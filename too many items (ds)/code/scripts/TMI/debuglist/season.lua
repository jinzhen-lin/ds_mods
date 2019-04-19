local function SeasonButtonTip(self)
    return STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SEASON_TIP:format(self.name)
end

local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SEASON,
    tag = "season",
    list = {
        {
            beta = false,
            pos = {"rog_forest", "rog_cave1", "rog_cave2"},
            name = STRINGS.UI.SANDBOXMENU.SPRING,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartSpring()​',
        },
        {
            beta = false,
            pos = {"forest", "cave1", "cave2"},
            name = STRINGS.UI.SANDBOXMENU.SUMMER,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartSummer()',
        },
        {
            beta = false,
            pos = {"rog_forest", "rog_cave1", "rog_cave2"},
            name = STRINGS.UI.SANDBOXMENU.AUTUMN,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartAutumn()',
        },
        {
            beta = false,
            pos = {"forest", "cave1", "cave2"},
            name = STRINGS.UI.SANDBOXMENU.WINTER,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartWinter()',
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.UI.SANDBOXMENU.MILD,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartMild()',
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.UI.SANDBOXMENU.WET,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartWet()',
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.UI.SANDBOXMENU.GREEN,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartGreen()',
        },
        {
            beta = false,
            pos = {"shipwrecked", "volcanolevel"},
            name = STRINGS.UI.SANDBOXMENU.DRY,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartDry()',
        },
        {
            beta = false,
            pos = "porkland",
            name = STRINGS.UI.SANDBOXMENU.TEMPERATE,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartTemperate()',
        },
        {
            beta = false,
            pos = "porkland",
            name = STRINGS.UI.SANDBOXMENU.HUMID,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartHumid()',
        },
        {
            beta = false,
            pos = "porkland",
            name = STRINGS.UI.SANDBOXMENU.LUSH,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartLush()',
        },
        {
            beta = false,
            pos = "porkland",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_SEASON_APORKALYPSE,
            tip = SeasonButtonTip,
            fn = 'GetSeasonManager():StartAporkalypse()',
        },
    },
}

return _TMI.ModifyDebuglist(res, "season", _TMI.locals())