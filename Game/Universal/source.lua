assert(sendErr, 'Failed to load features!')
local function get(http,cache)
    local s,result = pcall(function() return loadstring(game:HttpGet(http, (cache or true)))() end)
    return (s and result) or not s
end

local Aimbot,I_ = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/aimbot.lua')
local ESP,_l = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/esp.lua')
local ENGINE_l, l_ = get('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/kavo.lua')
if not Aimbot or not ESP or not ENGINE_l then 
    ENGINE_l:Notification('Oops something went wrong!', 'Script failed to continue! theres a problem on main function, dm KERNEL32#7398')
    return sendErr((not Aimbot and 'Universal Aimbot') or (not ESP and 'Universal ESP') or (not ENGINE_l and 'Universal Library'), tostring((I_ or _l or l_))) 
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local theme = 'DarkTheme'
local Windows = ENGINE_l:CreateLib('KRNL32', theme)

local t1 = Windows:NewTab('Home')
local s1 = t1:NewSection('Home')

s1:NewLabel('Welcome, ' .. Client.Name)
local timmy = s1:NewLabel('Current Time')
local timmy2 = s1:NewLabel('Playing Time')
local timmy3 = s1:NewLabel('Server Time')
local timmy4 = s1:NewLabel('FPS')
game:GetService('RunService').RenderStepped:Connect(function()
    do
        local date = os.date("*t")
        local hour = (date.hour) % 24
        local ampm = hour < 12 and "AM" or "PM"
        local ts = string.format("Current Time: %02i:%02i %s", ((hour - 1) % 12) + 1, date.min, ampm)
        if timmy then
            timmy:UpdateLabel(ts)
        end
    end

    do
        local t = workspace.DistributedGameTime or time()
        local seconds = math.floor(t) % 60
        local mins = math.floor(t/60)
        local hours = math.floor(mins/60)
        local ts = ('Playing Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy2 then
            timmy2:UpdateLabel(ts)
        end
    end

    do
        local t = workspace:GetServerTimeNow()
        local seconds = math.floor(t) % 60
        local mins = (math.floor(t) % 3600) / 60
        local hours = (math.floor(t) % 86400) / 3600
        local ts = ('Server Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy3 then
            timmy3:UpdateLabel(ts)
        end
    end

    do
        local fps = workspace:GetRealPhysicsFPS()
        local ts = ('FPS: %02i'):format(fps)
        if timmy4 then
            timmy4:UpdateLabel(ts)
        end
    end
    game:GetService('RunService').RenderStepped:Wait()
end)

local t2 = Windows:NewTab('Aimbot')
local s2 = t2:NewSection('Aimbot')
local s2s = t2:NewSection('Settings')

s2:NewToggle("Enabled", "Enable aimbot", function(t)
    Aimbot:toggle(t)
end)
 
s2:NewToggle("FOV","Show fov", function(t)
    Aimbot:showFov(t)
end)

s2:NewToggle("FromMouse","Set fov position to mouse position", function(t)
    Aimbot:fromMouse(t)
end)

s2:NewToggle("Ignore Wall","When target not visible/on wall, will ignored", function(t)
    Aimbot:wallCheck(t)
end)

s2:NewToggle("Team Check","allow aimbot to target teammate", function(t)
    Aimbot:teamCheck(t)
end)

s2s:NewSlider("Aim FOV", "Set aimbot fov", Aimbot.FOV*2,1, function(t)
    Aimbot:setFov(t)
end)

s2s:NewSlider("Aim Smooth", "Set aimbot smooth", Aimbot.Smooth*2,1, function(t)
    Aimbot:setSmooth(t)
end)

s2s:NewColorPicker("FOV Color", "Set fov color",Aimbot.FOVColor, function(t)
    Aimbot:setFovColor(t)
end)

local t3 = Windows:NewTab('ESP')
local s3 = t3:NewSection('ESP')
local s3o = t3:NewSection('Options')
local s3s = t3:NewSection('Settings')
local old_c = ESP.Color

s3:NewToggle('Enabled', 'Enable esp', function(t)
    ESP:toggle(t)
end)
s3:NewToggle('Box', 'Show box', function(t)
    ESP:boxes(t)
end)
s3:NewToggle('Name', 'Show name', function(t)
    ESP:names(t)
end)
s3:NewToggle('Tracer', 'Show tracer', function(t)
    ESP:tracers(t)
end)
s3:NewToggle('Distance', 'Show distance', function(t)
    ESP:distances(t)
end)
s3:NewToggle('Healthbar', 'Show healthbar', function(t)
    ESP:hps(t)
end)
s3:NewToggle('Head Dot', 'Show headdot', function(t)
    ESP:headdot(t)
end)

s3o:NewDropdown('ESP Type', 'Set esp type', {'Static', 'Dynamic'}, function(t)
    ESP:sType(t)
end)
s3o:NewDropdown('Tracer From', 'Set tracer from', {'Screen', 'Mouse', 'Player'}, function(t)
    ESP:sTracer(t)
end)
s3o:NewToggle('Visible Only', 'When target not visible/on wall, will not visible', function(t)
    ESP:sVis(t)
end)
s3o:NewToggle('Wall Check', 'When target not visible/on wall, esp will change color', function(t)
    ESP:sWallC(t)
end)
s3o:NewToggle('Teammate', 'Show esp for teammate', function(t)
    ESP:sTeam(t)
end)
s3o:NewToggle('Team Color', 'Set color to teams color', function(t)
    ESP:teamcolor(t)
end)

s3s:NewSlider("Thickness", 'Set thickness of esp line', ESP.Thickness*2,1, function(t)
    ESP:sThick(t)
end)
s3o:NewColorPicker("Wall Color",'Set wall color', Color3.fromRGB(255,255,255), function(t)
    ESP:sWColor(t)
end)
s3o:NewColorPicker("HP Color",'Set healthbar color', Color3.fromRGB(255,255,255),"EHPColor", function(t)
    ESP:sHColor(t)
end)

rbw = {false,1}
s3s:NewToggle('Rainbow Color', 'Set esp color to rainbow', function(t)
    rbw[1] = t
    while rbw[1] do
        local time = tostring(rbw[2]) .. '0'
        time = tonumber(time)
        for _=0,1,0.01 do 
            if not rbw[1] then break end
            ESP:sColor(Color3.fromHSV(_,1,1)) 
            wait(0.01 * time)
        end
        wait(0.01 * time)
    end
    ESP:sColor(old_c)
end)
s3s:NewSlider("Rainbow Time", "Slower color rainbow", function(t)
    rbw[2] = t
end)
s3s:NewColorPicker("ESP Color", 'Set esp color',Color3.fromRGB(255,255,255), function(t)
    ESP:sColor(t)
    old_c = t
end)

local tinf = Windows:NewTab('Aimbot')
local so = tinf:NewSection('Aimbot')

so:NewDropdown("UI Themes", "Set ui themes", {'DarkTheme','LightTheme','BloodTheme','GrapeTheme','Ocean','Midnight','Sentinel','Synapse','Serpent'}, function(currentOption)
    ENGINE_l:ChangeTheme(currentOption)
end)

local themes = {
    SchemeColor = Color3.fromRGB(64, 64, 64),
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}
for theme, color in pairs(themes) do
    so:NewColorPicker(theme, "Change your "..theme, color, function(color3)
        ENGINE_l:ChangeColor(theme, color3)
    end)
end