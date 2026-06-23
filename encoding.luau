getgenv().webEnc = getgenv().webEnc or {}
local m = getgenv().webEnc
local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function m.enc(str, k)
    local s = math.random(1, 25)
    local r = string.char(s + 64)
    local t = (str:gsub('.', function(x)
        local a, by = '', x:byte()
        for i = 8, 1, -1 do a = a .. (by % 2 ^ i - by % 2 ^ (i - 1) > 0 and '1' or '0') end
        return a
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return b:sub(math.floor(c / 64) + 1, math.floor(c / 64) + 1) .. b:sub((c % 64) + 1, (c % 64) + 1)
    end):gsub('=+$', '')
    for i = 1, #t do
        local c = t:byte(i)
        if c >= 65 and c <= 90 then r = r .. string.char((c - 65 + s) % 26 + 65)
        elseif c >= 97 and c <= 122 then r = r .. string.char((c - 97 + s) % 26 + 97)
        else r = r .. string.char(c) end
    end
    local v = ""
    local ki = 1
    for i = 1, #r do
        local c = r:byte(i)
        if c >= 65 and c <= 90 then
            local sh = k:byte(ki % #k + 1) - 64
            v = v .. string.char((c - 65 + sh) % 26 + 65)
            ki = ki + 1
        elseif c >= 97 and c <= 122 then
            local sh = k:byte(ki % #k + 1) - 64
            v = v .. string.char((c - 97 + sh) % 26 + 97)
            ki = ki + 1
        else
            v = v .. string.char(c)
        end
    end
    return v
end
function m.dec(str, k)
    local r = ""
    local ki = 1
    for i = 1, #str do
        local c = str:byte(i)
        if c >= 65 and c <= 90 then
            local sh = k:byte(ki % #k + 1) - 64
            r = r .. string.char((c - 65 - sh) % 26 + 65)
            ki = ki + 1
        elseif c >= 97 and c <= 122 then
            local sh = k:byte(ki % #k + 1) - 64
            r = r .. string.char((c - 97 - sh) % 26 + 97)
            ki = ki + 1
        else
            r = r .. string.char(c)
        end
    end
    local s = r:byte(1) - 64
    local t = r:sub(2)
    local cae = ""
    for i = 1, #t do
        local c = t:byte(i)
        if c >= 65 and c <= 90 then cae = cae .. string.char((c - 65 - s) % 26 + 65)
        elseif c >= 97 and c <= 122 then cae = cae .. string.char((c - 97 - s) % 26 + 97)
        else cae = cae .. string.char(c) end
    end
    return (cae:gsub('.', function(x)
        if x == '=' then return '' end
        local f = (b:find(x) - 1)
        local ro = ''
        for i = 6, 1, -1 do ro = ro .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return ro
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end
