return {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_TEXT,
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_UNLOCKTECH,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_UNLOCKTECHTIP,
            fn = function()
                GetPlayer().components.builder:UnlockRecipesForTech({SCIENCE = 10, MAGIC = 10, ANCIENT = 10, SHADOW = 10, CARTOGRAPHY = 10})
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_UNLOCK_ALL_CHARACTERS,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_UNLOCK_ALL_CHARACTERSTIP,
            fn = function()
                GetPlayer().profile:UnlockEverything()
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_CHANGE_CHARACTER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_CHANGE_CHARACTERTIP,
            fn = function()
                GetPlayer().HUD.controls.TMI:ShowCharacterMenu()
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_CLEARMORGUE,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_CHARACTER_CLEARMORGUETIP,
            fn = function()
                ErasePersistentString("morgue")
            end,
        },
    },
}