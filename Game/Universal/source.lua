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

local t2 = Windows:Tab('Aimbot')
local s2 = t2:Section('Aimbot')
local s2s = t2:Section('Settings')

s2:Toggle("Enabled", false,"AEnabled", function(t)
    Aimbot:toggle(t)
end)
 
s2:Toggle("Show FOV", false,"AFov", function(t)
    Aimbot:showFov(t)
end)

s2:Toggle("FromMouse", false,"AFrommouse", function(t)
    Aimbot:fromMouse(t)
end)

s2:Toggle("Wall Check", false,"AWallcheck", function(t)
    Aimbot:wallCheck(t)
end)

s2:Toggle("Team Check", false,"AFromATeamcheckmouse", function(t)
    Aimbot:teamCheck(t)
end)
s2s:Slider("Aim FOV", 0,300,Aimbot.FOV,1,"ASFov", function(t)
    Aimbot:setFov(t)
end)

s2s:Slider("Aim Smooth", 0,5,Aimbot.Smooth,1,"ASSmooth", function(t)
    Aimbot:setSmooth(t)
end)

s2s:Colorpicker("FOV Color", Aimbot.FOVColor,"FOVPicker", function(t)
    Aimbot:setFovColor(t)
end)