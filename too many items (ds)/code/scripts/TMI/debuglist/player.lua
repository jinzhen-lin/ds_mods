local CharacterSelectScreen = require "screens/characterselectscreen"

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
                if TheInput:IsKeyDown(KEY_CTRL) then
                    local player_profile = GetPlayer().profile
                    local current_xp = player_profile:GetXP()
                    player_profile:UnlockEverything()
                    player_profile:SetXP(current_xp)
                    player_profile:Save()
                    return
                end
                GetPlayer().HUD.controls.TMI:ShowCharacterMenu()
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_CHANGE_CHARACTER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_PLAYER_CHANGE_CHARACTERTIP,
            fn = function()
                local player_profile = GetPlayer().profile
                local onSet = function(character, random)
                    TheFrontEnd:PopScreen()
                    if character ~= nil then
                        GetPlayer().components.autosaver:DoSave()
                        GetPlayer():DoTaskInTime(3, function()
                            SaveGameIndex:SetSlotCharacter(SaveGameIndex:GetCurrentSaveSlot(), character, function()
                                StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
                            end)
                        end)
                    end
                end
                local slot_character = SaveGameIndex:GetSlotCharacter(SaveGameIndex:GetCurrentSaveSlot())
                local character_select_screen = CharacterSelectScreen(player_profile, onSet, false, slot_character)
                TheFrontEnd:PushScreen(character_select_screen)
            end,
        },
    },
}

return _TMI.ModifyDebuglist(res, "player", _TMI.locals())