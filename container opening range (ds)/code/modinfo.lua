name = "Container Opening Range 容器开启范围"
description = "Modify container opening range 修改容器开启范围"
author = "linjinzhen"
version = "1.1.0"
forumthread = ""

api_version = 6

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = false

local num_options = {}
for i = 1, 12 do num_options[i] = {description = ""..i.."", data = i} end

configuration_options = 
{
    {
        name = "TREASURECHEST",
        label = "Treasure Chest",
        options = num_options,
        default = 3,
    },
    {
        name = "CHESTER",
        label = "Chester",
        options = num_options,
        default = 3,
    },
    {
        name = "ICEBOX",
        label = "Icebox",
        options = num_options,
        default = 5,
    },
    {
        name = "OTHER_CHEST",
        label = "Other Chest-like Container",
        options = num_options,
        default = 3,
    },
    {
        name = "COOKPOT",
        label = "Cookpot",
        options = num_options,
        default = 3,
    },
    {
        name = "OTHER_COOKER",
        label = "Other Cooker-like Container",
        options = num_options,
        default = 3,
    },
    {
        name = "BOAT",
        label = "Boat",
        options = num_options,
        default = 3,
    },
    {
        name = "OTHER",
        label = "Other Container",
        hover = "Other Container 其他容器",
        options = num_options,
        default = 3,
    }
}

