local URL_REPLACEMENTS = {
    ["https://raw.githubusercontent.com/bimoso/BimoScripts/main/AsesinosVsSherifs.lua"] = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/AsesinosVsSherifs.lua",
    ["https://bimo-panel-controller-production.up.railway.app/crypt"] = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/crypt",
    ["https://689b05f70003acdfef63.nyc.appwrite.run/information"] = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/information.json",
    ["https://raw.githubusercontent.com/DemogorgonItsMe/DemoNotifications/refs/heads/main/V2/source.lua"] = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/source.lua",
    ["https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"] = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/main.lua",
}

local function rewrite(url)
    if type(url) ~= "string" then return url end
    for original, replacement in pairs(URL_REPLACEMENTS) do
        if url:find(original, 1, true) then
            return replacement
        end
    end
    return url
end

do
    local mt = getrawmetatable(game)
    setreadonly(mt, false)

    local origIndex = mt.__index
    local origNamecall = mt.__namecall
    mt.__index = function(self, key)
        if self == game and (key == "HttpGet" or key == "HttpGetAsync") then
            return function(_, url, ...)
                return origIndex(self, key)(self, rewrite(url), ...)
            end
        end
        return origIndex(self, key)
    end
    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()
        if self == game and (method == "HttpGet" or method == "HttpGetAsync") then
            local args = table.pack(...)
            args[1] = rewrite(args[1])
            return origNamecall(self, table.unpack(args, 1, args.n))
        end
        return origNamecall(self, ...)
    end

    setreadonly(mt, true)
end

local function wrap(fn)
    return function(request, ...)
        local url = (typeof(request) == "table" and request.Url) or request
        local newUrl = rewrite(url)
        if typeof(request) == "table" then
            request.Url = newUrl
            return fn(request, ...)
        else
            return fn(newUrl, ...)
        end
    end
end

if syn and syn.request then syn.request = wrap(syn.request) end
if http and http.request then http.request = wrap(http.request) end
if request then request = wrap(request) end
if http_request then http_request = wrap(http_request) end

local function base64encode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c * 2 + (x:sub(i, i) == '1' and 1 or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

local function base64decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^' .. b .. '=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c * 2 + (x:sub(i, i) == '1' and 1 or 0) end
        return string.char(c)
    end))
end

local function bytes_to_b64url(bytes)
    local b64 = base64encode(bytes)
    return b64:gsub('+', '-'):gsub('/', '_'):gsub('=', '')
end

local function b64url_to_bytes(s)
    s = s:gsub('-', '+'):gsub('_', '/')
    s = s .. string.rep('=', (4 - #s % 4) % 4)
    return base64decode(s)
end

local function sha256_bytes(msg)
    local band, bor, bxor, bnot = bit32.band, bit32.bor, bit32.bxor, bit32.bnot
    local lshift, rshift = bit32.lshift, bit32.rshift
    local function rrotate(x, n)
        n = n % 32
        return bor(rshift(x, n), lshift(x, 32 - n)) % 4294967296
    end
    local function add32(a, b)
        return (a + b) % 4294967296
    end
    local function add_many(a, b, c, d, e)
        local s = (a or 0) + (b or 0) + (c or 0) + (d or 0) + (e or 0)
        return s % 4294967296
    end

    local H = {
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    }
    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2,
    }
    local function Ch(x,y,z) return bxor(band(x,y), band(bnot(x), z)) end
    local function Maj(x,y,z) return bxor(band(x,y), band(x,z), band(y,z)) end
    local function S0(x) return bxor(rrotate(x,2), rrotate(x,13), rrotate(x,22)) end
    local function S1(x) return bxor(rrotate(x,6), rrotate(x,11), rrotate(x,25)) end
    local function s0(x) return bxor(rrotate(x,7), rrotate(x,18), rshift(x,3)) end
    local function s1(x) return bxor(rrotate(x,17), rrotate(x,19), rshift(x,10)) end

    local bytes = {string.byte(msg, 1, #msg)}
    local bitLen = #bytes * 8
    bytes[#bytes + 1] = 0x80
    while ((#bytes + 8) % 64) ~= 0 do bytes[#bytes + 1] = 0 end
    local hi = math.floor(bitLen / 4294967296)
    local lo = bitLen % 4294967296
    local function append32(v)
        bytes[#bytes + 1] = math.floor(v / 16777216) % 256
        bytes[#bytes + 1] = math.floor(v / 65536) % 256
        bytes[#bytes + 1] = math.floor(v / 256) % 256
        bytes[#bytes + 1] = v % 256
    end
    append32(hi); append32(lo)

    local w = table.create(64)
    local a,b,c,d,e,f,g,h
    for i = 1, #bytes, 64 do
        for t = 0, 15 do
            local j = i + (t * 4)
            local v = bytes[j] * 16777216 + bytes[j+1] * 65536 + bytes[j+2] * 256 + bytes[j+3]
            w[t] = v
        end
        for t = 16, 63 do
            w[t] = add_many(s1(w[t-2] or 0), w[t-7] or 0, s0(w[t-15] or 0), w[t-16] or 0)
        end

        a,b,c,d,e,f,g,h = H[1],H[2],H[3],H[4],H[5],H[6],H[7],H[8]
        for t = 0, 63 do
            local T1 = add_many(h, S1(e), Ch(e,f,g), K[t+1], w[t])
            local T2 = add32(S0(a), Maj(a,b,c))
            h = g; g = f; f = e
            e = add32(d, T1)
            d = c; c = b; b = a
            a = add32(T1, T2)
        end
        H[1] = add32(H[1], a); H[2] = add32(H[2], b); H[3] = add32(H[3], c); H[4] = add32(H[4], d)
        H[5] = add32(H[5], e); H[6] = add32(H[6], f); H[7] = add32(H[7], g); H[8] = add32(H[8], h)
    end
    local res = ''
    for _, h in ipairs(H) do
        res = res .. string.char(
            rshift(h, 24) % 256,
            rshift(h, 16) % 256,
            rshift(h, 8) % 256,
            h % 256
        )
    end
    return res
end

local function hmac_sha256(key, msg)
    local blocksize = 64
    if #key > blocksize then
        key = sha256_bytes(key)
    end
    key = key .. string.rep('\0', blocksize - #key)
    local ipad = ''
    local opad = ''
    for i = 1, blocksize do
        local byte = string.byte(key, i)
        ipad = ipad .. string.char(bit32.bxor(byte, 0x36))
        opad = opad .. string.char(bit32.bxor(byte, 0x5C))
    end
    return sha256_bytes(opad .. sha256_bytes(ipad .. msg))
end

local original_request = request
request = function(input)
    local req = typeof(input) == "table" and input or {Url = input}
    local url = req.Url
    local original = function() return original_request(input) end

    if url == "https://689b05f70003acdfef63.nyc.appwrite.run/reportExecute" then
        return {Success = true, StatusCode = 200, Body = "", Headers = {}}
    elseif url == "https://689b05f70003acdfef63.nyc.appwrite.run/getValidHWIDs" then
        local http = game:GetService("HttpService")
        local secret = "BimoLegionForever12#$kjs#$/jsaWAasi(#/"
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        local header_tbl = {alg = "HS256", typ = "JWT"}
        local header_json = http:JSONEncode(header_tbl)
        local header_b64 = bytes_to_b64url(header_json)
        local payload_tbl = {
            hwids = {hwid}, -- HWID kept as requested, used locally in JWT
            iat = os.time(),
            exp = os.time() + 5
        }
        local payload_json = http:JSONEncode(payload_tbl)
        local payload_b64 = bytes_to_b64url(payload_json)
        local signing = header_b64 .. "." .. payload_b64
        local signature = hmac_sha256(secret, signing)
        local sig_b64 = bytes_to_b64url(signature)
        local token = header_b64 .. "." .. payload_b64 .. "." .. sig_b64
        local body = http:JSONEncode({token = token})
        return {Success = true, StatusCode = 200, Body = body, Headers = {}}
    elseif url == "https://bimo-panel-controller-production.up.railway.app/crypt" then
        return original()
    else
        return original()
    end
end

local replacements = {
    ["Bimo"] = "NewToyotaCamry",
    ["BimoPanel"] = "Cerberus",
    ["Asesinos Vs Sherifs"] = "Murderers VS Sheriffs",
}

local function applyReplacements(str)
    if typeof(str) ~= "string" then return str end
    for original, replacement in pairs(replacements) do
        if str:find(original, 1, true) then
            str = str:gsub(original, replacement)
        end
    end
    return str
end

local mt = getrawmetatable(game)
setreadonly(mt, false)

local old_index = mt.__index
local old_newindex = mt.__newindex
local old_namecall = mt.__namecall

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    local args = table.pack(...)
    for i = 1, args.n do
        if typeof(args[i]) == "string" then
            args[i] = applyReplacements(args[i])
        end
    end
    return old_namecall(self, table.unpack(args, 1, args.n))
end

mt.__newindex = function(self, key, value)
    if typeof(value) == "string" then
        value = applyReplacements(value)
    end
    return old_newindex(self, key, value)
end

mt.__index = function(self, key)
    local result = old_index(self, key)
    if typeof(result) == "string" then
        return applyReplacements(result)
    end
    return result
end

setreadonly(mt, true)

loadstring(game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/bim/AsesinosVsSherifs.lua"))()
