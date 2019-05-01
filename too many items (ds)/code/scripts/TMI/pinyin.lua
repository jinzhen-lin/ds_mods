
local json = require "json"
local pinyin_data = io.open(softresolvefilepath("scripts/TMI/pinyin_data.json")):read()
pinyin_data = json.decode(pinyin_data)


function GetChineseStringPinyin(str)
    if str == nil or str == "" then
        return {""}
    end
    local char_table = {}
    local i = 1
    while true do
        local c = str:sub(i, i)
        local b = c:byte()
        if b < 128 then
            table.insert(char_table, c)
            i = i + 1
        else
            table.insert(char_table, str:sub(i, i + 2))
            i = i + 3
        end
        if i > #str then
            break
        end
    end
    local res = {""}
    for _, c in pairs(char_table) do
        local tmp = {}
        for _, r in pairs(res) do
            local c_pinyin_table = pinyin_data[c]
            if c_pinyin_table == nil then
                table.insert(tmp, r..c)
            else 
                for _, c_pinyin in pairs(c_pinyin_table) do
                    table.insert(tmp, r..c_pinyin)
                end
            end
        end
        res = tmp
    end
    return res
end




return {
    GetChineseStringPinyin = GetChineseStringPinyin,
    pinyin_data = pinyin_data
}