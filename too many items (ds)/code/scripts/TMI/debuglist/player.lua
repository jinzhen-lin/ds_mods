local res = {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_TEXT,
    tag = "player",
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_UNLOCKTECH,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_UNLOCKTECHTIP,
            fn = function()
                GetPlayer().components.builder:UnlockRecipesForTech({SCIENCE = 10, MAGIC = 10, ANCIENT = 10, SHADOW = 10, CARTOGRAPHY = 10})
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_UNLOCK_ALL_CHARACTERS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_UNLOCK_ALL_CHARACTERSTIP,
            fn = function()
                GetPlayer().profile:UnlockEverything()
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_CHANGE_CHARACTER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_CHANGE_CHARACTERTIP,
            fn = function()
                GetPlayer().HUD.controls.TMI:ShowCharacterMenu()
            end,
        },
    },
}

return _TMI.ModifyDebuglist(res, "player", _TMI.locals())