local function GotoMode(targetmode)
    if not IsDLCEnabled(PORKLAND_DLC) and not IsDLCEnabled(CAPY_DLC) then
        return
    end
    local _oldTravelBetweenWorlds = TravelBetweenWorlds
    local function cancel()
        TravelBetweenWorlds = _oldTravelBetweenWorlds
        SetPause(false, "console")
    end
    return function()
        SetPause(true, "console")
        local portal_event = ""
        local SaveIntegrationScreen = require "screens/saveintegrationscreen"
        if not SaveGameIndex:OwnsMode(targetmode) then
            local savescreen
            if IsDLCEnabled(PORKLAND_DLC) then
                savescreen = SaveIntegrationScreen(targetmode, portal_event, cancel)
                TravelBetweenWorlds = function(targetmode, playerevent, waittime, dropitems, customoptions, mergefromslot)
                    _oldTravelBetweenWorlds(targetmode, "", 0, dropitems, customoptions, mergefromslot)
                end
            else
                savescreen = SaveIntegrationScreen(targetmode, cancel)
                TravelBetweenWorlds = function(playerevent, waittime, dropitems, customoptions, mergefromslot)
                    _oldTravelBetweenWorlds("", 0, dropitems, customoptions, mergefromslot)
                end
            end
            TheFrontEnd:PushScreen(savescreen)
        else
            if IsDLCEnabled(PORKLAND_DLC) then
                TravelBetweenWorlds(targetmode, portal_event, 0, {"chester_eyebone", "packim_fishbone"})
            else
                TravelBetweenWorlds(portal_event, 0, {"chester_eyebone", "packim_fishbone"})
            end
        end
    end
end


return {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TEXT,
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_ROLLBACK,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_ROLLBACKTIP,
            fn = 'StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_SAVE,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_SAVETIP,
            fn = 'GetPlayer().components.autosaver:DoSave()',
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_NEXTWORLD,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_NEXTWORLDTIP,
            fn = function()
                local DeathScreen = require "screens/deathscreen"
                local days_survived, start_xp, reward_xp, new_xp, capped = CalculatePlayerRewards(GetPlayer())
                SaveGameIndex:CompleteLevel(function() TheFrontEnd:PushScreen(DeathScreen(days_survived, start_xp, true, capped)) end )
            end,
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_RESET_WORLDID,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_RESET_WORLDIDTIP,
            fn = function()
                local current_mode = SaveGameIndex.data.slots[SaveGameIndex.current_slot].current_mode
                local data = SaveGameIndex:GetModeData(SaveGameIndex.current_slot, current_mode)
                data.world = 1
                GetPlayer().components.autosaver:DoSave()
            end,
        },
        {
            beta = false,
            pos = function()
                local can_goto_porkland = IsDLCEnabled(PORKLAND_DLC)
                return not SaveGameIndex:IsModePorkland() and can_goto_porkland
            end,
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLD_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.PORKLAND),
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLDTIP_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.PORKLAND),
            fn = GotoMode("porkland"),
        },
        {
            beta = false,
            pos = function()
                local can_goto_porkland = IsDLCEnabled(PORKLAND_DLC) or IsDLCEnabled(CAPY_DLC)
                return not SaveGameIndex:IsModeShipwrecked() and can_goto_porkland
            end,
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLD_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.SHIPWRECKED),
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLDTIP_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.SHIPWRECKED),
            fn = GotoMode("shipwrecked"),
        },
        {
            beta = false,
            pos = function()
                return not SaveGameIndex:IsModeSurvival()
            end,
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLD_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.SURVIVAL),
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_GAME_TRAWELWORLDTIP_FORMAT:format(STRINGS.UI.SAVEINTEGRATION.SURVIVAL),
            fn = GotoMode("survival"),
        },
    }
}