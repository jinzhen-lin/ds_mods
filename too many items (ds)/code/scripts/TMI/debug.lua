
local res = {
    require "TMI/debuglist/season",
    require "TMI/debuglist/time",
    require "TMI/debuglist/speed",
    require "TMI/debuglist/weather",
    require "TMI/debuglist/player",
    require "TMI/debuglist/entity",
    require "TMI/debuglist/beefalo",
    require "TMI/debuglist/follower",
    require "TMI/debuglist/game",
    require "TMI/debuglist/teleport",
    require "TMI/debuglist/map",
}

for _, fn in pairs(_TMI.AllDebuglistPostInit) do
    res = fn(res)
end

return res
