local function get(http,cache)
    local s,result = pcall(function() return loadstring(game:HttpGet(http, (cache or true)))() end)
    return (s and result) or not s
end

local Aimbot = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/aimbot.lua')
local ESP = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/esp.lua')
local UI = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/solaris.lua')
repeat task.wait() until Aimbot and ESP and UI

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = UI:New({
    Name = 'KRNL32',
    FolderToSave = 'KRNL32stuff'
})

local t1 = Windows:Tab('Home')
local s1 = t1:Section('Home')

s1:Label('Welcome, ' .. Client.Name)
local timmy = s1:Label('Current Time')
local timmy2 = s1:Label('Playing Time')
local timmy3 = s1:Label('Server Time')
local timmy4 = s1:Label('FPS')
game:GetService('RunService').RenderStepped:Connect(function()
    do
        local date = os.date("*t")
        local hour = (date.hour) % 24
        local ampm = hour < 12 and "AM" or "PM"
        local ts = string.format("Current Time: %02i:%02i %s", ((hour - 1) % 12) + 1, date.min, ampm)
        if timmy then
            timmy:Set(ts)
        end
    end

    do
        local t = workspace.DistributedGameTime or time()
        local seconds = math.floor(t) % 60
        local mins = math.floor(t/60)
        local hours = math.floor(mins/60)
        local ts = ('Playing Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy2 then
            timmy2:Set(ts)
        end
    end

    do
        local t = workspace:GetServerTimeNow()
        local seconds = math.floor(t) % 60
        local mins = (math.floor(t) % 3600) / 60
        local hours = (math.floor(t) % 86400) / 3600
        local ts = ('Server Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy3 then
            timmy3:Set(ts)
        end
    end

    do
        local fps = workspace:GetRealPhysicsFPS()
        local ts = ('FPS: %02i'):format(fps)
        if timmy4 then
            timmy4:Set(ts)
        end
    end
    game:GetService('RunService').RenderStepped:Wait()
end)