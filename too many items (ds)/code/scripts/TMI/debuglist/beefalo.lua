local function GetDomesticateStr(tendencytype, saddle)
    return function ()
    	local player = GetPlayer() 
        local x,y,z = player.Transform:GetWorldPosition() 
        local beef = c_spawn('beefalo') 
        beef.components.domesticatable:DeltaDomestication(1) 
        beef.components.domesticatable:DeltaObedience(1) 
        beef.components.domesticatable:DeltaTendency(tendencytype, 1) 
        beef:SetTendency() 
        beef.components.domesticatable:BecomeDomesticated() 
        beef.components.hunger:SetPercent(0.5) 
        beef.components.rideable:SetSaddle(nil, SpawnPrefab(saddle)) 
        beef.Transform:SetPosition(x,y,z)
    end
end


return {
    tittle = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_TEXT,
    list = {
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_ORNERY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_ORNERYTIP,
            fn = GetDomesticateStr("ORNERY", "saddle_war"),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_RIDER,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_RIDERTIP,
            fn = GetDomesticateStr("RIDER", "saddle_race"),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_PUDGY,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_PUDGYTIP,
            fn = GetDomesticateStr("PUDGY", "saddle_race"),
        },
        {
            beta = false,
            pos = "all",
            name = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_DEFAULT,
            tip = STRINGS.TOO_MANY_ITEMS_UI.DEBUG_BEEFALO_DEFAULTTIP,
            fn = GetDomesticateStr("DEFAULT", "saddle_war"),
        },
    },
}