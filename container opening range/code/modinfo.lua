name = "Container Opening Range 容器开启范围"
description = "Modify container opening range 修改容器开启范围"
author = "linjinzhen"
version = "1.0.5"

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

client_only_mod = false
all_clients_require_mod = false
server_only_mod = true


local num_options = {}
for i = 1, 12 do num_options[i] = {description = ""..i.."", data = i} end

configuration_options = 
{
  {
    name = "TREASURECHEST",
    label = "Treasure Chest",
    hover = "Treasure Chest 宝箱",
    options = num_options,
    default = 3,
  },
  {
    name = "CHESTER",
    label = "Chester And Hutch",
    hover = "Chester And Hutch 切斯特和哈奇",
    options = num_options,
    default = 3,
  },
  {
    name = "ICEBOX",
    label = "Icebox",
    hover = "Icebox 冰箱",
    options = num_options,
    default = 5,
  },
  {
    name = "OTHER_CHEST",
    label = "Other Chest-like Container",
    hover = "Other Chest-like Container 其他像箱子的容器",
    options = num_options,
    default = 3,
  },
  {
    name = "COOKPOT",
    label = "Cookpot",
    hover = "Cookpot 烹煮锅",
    options = num_options,
    default = 3,
  },
  {
    name = "OTHER_COOKER",
    label = "Other Cooker-like Container",
    hover = "Other Cooker-like Container 其他像锅的容器",
    options = num_options,
    default = 3,
  }
}

