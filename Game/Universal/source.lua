local function get(http,cache)
    return loadstring(game:HttpGetAsync(http, (cache or true)))()
end

local Aimbot = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/aimbot.lua')
