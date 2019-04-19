local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_TEXT,
    tag = "time",
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_NEXT,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_NEXTTIP,
            fn = 'GetClock():NextPhase()',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_ODAY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_ODAYTIP,
            fn = 'LongUpdate(TUNING.TOTAL_DAY_TIME, true)',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_FDAYS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_FDAYSTIP,
            fn = 'LongUpdate(TUNING.TOTAL_DAY_TIME * 5, true)',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_TDAYS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_TDAYSTIP,
            fn = 'LongUpdate(TUNING.TOTAL_DAY_TIME * 10, true)',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_20DAYS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_TIME_20DAYSTIP,
            fn = 'LongUpdate(TUNING.TOTAL_DAY_TIME * 20, true)',
        },
    },
}

return _TMI.ModifyDebuglist(res, "time", _TMI.locals())