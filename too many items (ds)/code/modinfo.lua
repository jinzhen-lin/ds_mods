name = "[DST->DS]Too Many Items"
forumthread = ""
version = "1.6.0"
description = "Too Many Items Version:"..version.."\n\nAllows you to spawn any item you want and more powerful features.\nYou must be a Admin to use this.\nPress (T) to open spawn menu.\nLeft Click to spawn 1 item.\nRight Click to spawn 10 items.\n\nToggle Button and spawn num are Configurable\nYou can customize a special item list.(Add or Delete a item by hold down the ctrl key and click.)\n\nCodes by C.J.B. | Items and bug fix by GaRAnTuLA. | DST version by Skull."
author = "CJB & GaRAnTuLA & Skull & linjinzhen"
api_version = 6
priority = -10000
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true


icon_atlas = "TooManyItems.xml"
icon = "TooManyItems.tex"

local alpha = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local KEY_A = 97
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
    {
        name = "TMI_TOGGLE_KEY",
        label = "Toggle Button",
        hover = "The key you need to show the TooManyItems screen.",
        options = keyslist,
        default = 116, --T
    },
    {
        name = "TMI_L_CLICK_NUM",
        label = "Click",
        hover = "The num of item you get from TooManyItems.",
        options =
        {
            {description = "1", data = 1},
            {description = "2", data = 2},
            {description = "3", data = 3},
            {description = "4", data = 4},
            {description = "5", data = 5},
        },
        default = 1,
    },
    {
        name = "TMI_R_CLICK_NUM",
        label = "Right-click",
        hover = "The num of item you get from TooManyItems.",
        options =
        {
            {description = "10", data = 10},
            {description = "15", data = 15},
            {description = "20", data = 20},
            {description = "25", data = 25},
            {description = "30", data = 30},
        },
        default = 10,
    },
    {
        name = "TMI_DATA_SAVE",
        label = "Save data?",
        hover = "Do you want to Save TMI's Data?",
        options =
        {
            {description = "Yes", data = 1},
            {description = "No", data = 0},
            {description = "Delete", data = -1},
        },
        default = 1,
    },
    {
        name = "TMI_SEARCH_HISTORY_NUM",
        label = "Search history max num",
        hover = "Only save these Search history.",
        options =
        {
            {description = "5", data = 5},
            {description = "10", data = 10},
            {description = "20", data = 20},
            {description = "30", data = 30},
            {description = "40", data = 40},
            {description = "50", data = 50},
        },
        default = 10,
    },
    {
        name = "LANG",
        label = "Display Language",
        hover = "Display Language",
        options =
        {
            {description = "English", data = "en"},
            {description = "Simplified Chinese", data = "chs"},
            {description = "Traditional Chinese", data = "cht"},
            {description = "Follow Mods", data = "mod"}
        },
        default = "mod",
    },
    {
        name = "OTHER_MODS",
        label = "Tweak by Other Mods",
        hover = "Tweak by Other Mods",
        options =
        {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
    },
}
