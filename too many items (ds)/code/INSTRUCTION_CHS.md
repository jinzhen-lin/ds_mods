# 基本说明

按 T 键显示UI界面，按下UI界面下方的星星图标可以打开调试面板。关于主面板以及调试面板的使用细节可以查看下一节。



本MOD提供了接口来允许其他MOD对物品列表和指令列表等进行调整。接口文档暂时没时间写，有兴趣的可以参考下本MOD目录下的 "api_example" 文件夹。



配置选项：

- Toggle Button: 用于打开/关闭UI界面的按钮，默认是T键，一般不进行更改（除非冲突）
- Click: 左键点击物品时生成的物品数量，默认为1
- Right Click: 右键点击物品时生成的物品数量，默认为10
- Save Data?: 是否保存和读取本MOD的缓存数据，比如物品列表的页码、传送点数据等等。默认为"Yes" （保存以及读取）。其他可选选项为"No" （不保存也不读取）、"Delete"（删除缓存数据，一般如果由缓存数据导致游戏崩溃可以选择该项，不过一般不会）
- Search History Max Number?: 保存的搜索记录的数量上限，默认为10
- Display Language: 显示的语言。默认为"Follow Mods"，也就是去检测是否有汉化MOD开启，如果开启了汉化MOD则界面使用简体中文，否则用英文。也可以选择强制使用英文/简体中文/繁体中文。
- Tweak by Other Mods: 是否允许其他MOD对本MOD进行调整。默认情况下，本MOD提供了接口来允许其他MOD对本MOD中的物品列表、指令列表等进行修改。可以使用这个选项来禁止修改。



注意：

- 本MOD主要用处是供测试与演示使用，强烈不建议在正式游玩中使用该MOD，会极大降低游戏乐趣
- 有些物品可能会导致崩溃，尤其是当游戏版本不是[最新的哈姆雷特测试版](<https://steamcommunity.com/games/219740/announcements/detail/1727601346322579127>)时（该版本允许在哈姆雷特之外建造城镇猪房）。
- 物品列表中，物品显示的名称下方是物品的代码，如果代码中有加号("+")，表示本MOD对其进行一定的特殊处理
- 不得不说单机版的中文支持相比于联机版真的差，这个MOD如果调为中文的话UI界面会挺混乱的，无力解决，建议英文版（我是指如果你习惯的话，最好整个游戏都不开中文MOD）。



# 主面板

生成物品的功能方面，包含了多个物品类别：

- 特殊（收藏）：收藏的物品
- 全部：包含了资源、武器、工具、衣物、礼物中的物品
- 食物、资源、武器、工具、衣物、礼物：生成后进入物品栏
- 生物、建筑：生成后出现在玩家附近
- 其他：以上类别没出现的物品（比如之后版本新加的）以及MOD物品会出现在这里，但包含了很多乱七八糟的物品，很容易崩溃

生成物品的方式：

- 单击生成 1 个物品。（可以在选项中更改）
- 右击生成 10 个物品。（可以在选项中更改）
- SHIFT + 单击或右击得到和物品生成数量份数的制作材料。
- CTRL + 点击加入或移除自定义物品列表（收藏）。

搜索时：

- Enter 键或点击任意位置：搜索输入的内容。
- UP 键：上个输入内容。
- DOWN 键：下个输入内容或清空输入的内容。
- ESC 键：退出输入。



此外还可以还有一些小功能，具体如下（括号中为相同按钮按住CTRL再点击的效果）：设置生命为满（为10%）、设置精神为满（为0）、设置饥饿为满（为0）、设置温度为25度（为环境温度）、设置湿度为0（为100）、设置伍迪的木头值为满（为0）、清空背包（清空背包+物品栏）、解毒（中毒）、游戏暂停/继续、上帝模式、创造模式、一击必杀模式



# 调试面板

- 季节：
  - 原版：夏季、冬季
  - 巨人国：春季、夏季、秋季、冬季
  - 船难：温季、风季、雨季、旱季
  - 哈姆雷特：温和季、湿润季、繁茂季、毁灭季
- 时间：下一段、1天后、5天后、10天后、20天后
- 速度：0.6倍速、正常速度、2倍速、3倍速
- 天气：闪电、开始/停止雨雪、开始/停止火山爆发（船难）、开始/停止飓风（船难）、开始/停止雾（哈姆雷特、湿润季）
- 玩家：解锁全部科技（不是创造模式）、解锁全部人物、更换角色并继续游戏
- 实体：（范围内）删除、施肥、催熟、收获、拾取、冻结、灭火、清理积水（船难）、清理积雪（原版+巨人国）、设置物品耐久度（详见最后的介绍）
- 驯化牛：战斗牛、骑行牛、宠物牛、普通牛
- 随从：添加、驱逐、健康、饥饿度、忠诚度
- 游戏：回档、存档、进入下一个世界、重置世界ID为1（正常来说进入下一个世界后ID会加1）、清空停尸房、前往生存模式世界、前往船难世界、前往哈姆雷特世界
- 传送：记录当前所处位置、传送到已记录的位置
- 地图：全图（暂时，重新加载游戏后丢失）、全图（永久）、清空地图、在地图上显示当前遗迹内全部房间（HAMLET）、传送到某些指定地点（不同世界内列表不同）。传送到指定地点这一项专门针对做了一些优化：
  - 如果玩家在陆地上但目标在水面上，则会生成木筏并乘坐上再传送（不然直接淹死了）
  - 如果玩家在水面上但目标在陆地上，则会把船停在原地再传送（不然船会直接毁坏）
  - 在哈姆雷特中，避免了直接跨房间传送时会被卡主的问题
  
  
关于“设置物品耐久度”功能，其作用是将食物等的新鲜度或者工具/武器/衣物/护甲等的耐久度设定到一个预设值。
如果你鼠标拿起一个物品去点击这个按钮，则只设置物品的耐久度；如果在鼠标是空着的状态去点击这个按钮，则会将装备栏里（手里、身上、头上）的物品的耐久设为该预设值（如果该物品允许设置的话）。
默认情况下，会将耐久度设为满，但提供了命令来设置该预设值，具体来说是打开控制台，输入命令 "tmi_nj(xxx)" 或者 "tmi_durability(xxx)" ，其中xxx为目标耐久值（0到1之间的数值，1表示满耐久）。该耐久值会随本mod的缓存数据一起缓存。