name = "coffee and nettle for everyone 所有人都能吃咖啡和荨麻"
author = "linjinzhen"
version = "1.1.0"
description = "coffee and nettle for everyone 所有人都能吃咖啡和荨麻 Version:"..version
forumthread = ""

api_version = 6

icon_atlas = "coffee_nettle.xml"
icon = "coffee_nettle.tex"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = false

configuration_options = 
{
    {
        name = "COFFEE",
        label = "Coffee",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
    },
    {
        name = "NETTLE",
        label = "Nettle",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
    },
    {
        name = "SEEDPOD",
        label = "Seed Pod",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
    },
    {
        name = "TEA",
        label = "Tea",
        options = {
            {description = "Yes", data = true},
            {description = "No", data = false}
        },
        default = true,
    }
}

