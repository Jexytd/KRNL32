assert(_KRNL32_, 'Failed to load features!')
local Aimbot,I_ = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/aimbot.lua', true))() end)
local ESP,_l = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/esp.lua', true))() end)
if not Aimbot or not ESP or type(ENGINE_l) ~= 'table' then 
    return _KRNL32_[_KRNL32_[1][2]]((not Aimbot and 'Aimbot') or (not ESP and 'ESP') or (type(ENGINE_l) ~= 'table' and 'Library'), tostring((I_ or _l or ENGINE_l))) 
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = ENGINE_l
local t2 = Windows:NewTab('Aimbot')
local s2 = t2:NewSection('Aimbot')
local s2s = t2:NewSection('Settings')

s2:NewToggle("Enabled", "Enable aimbot", function(t)
    I_:toggle(t)
end)
 
s2:NewToggle("FOV","Show fov", function(t)
    I_:showFov(t)
end)

s2:NewToggle("FromMouse","Set fov position to mouse position", function(t)
    I_:fromMouse(t)
end)

s2:NewToggle("Ignore Wall","When target not visible/on wall, will ignored", function(t)
    I_:wallCheck(t)
end)

s2:NewToggle("Team Check","allow aimbot to target teammate", function(t)
    I_:teamCheck(t)
end)

s2s:NewDropdown('Aim Target', 'Set esp type', {'Head', 'HumanoidRootPart', 'MultiHitbox'}, function(t)
    _l:sType(t)
end)

s2s:NewSlider("Aim FOV", "Set aimbot fov", I_.FOV*2,0, function(t)
    I_:setFov(t)
end)

s2s:NewSlider("Aim Smooth", "Set aimbot smooth", I_.Smooth*2,0, function(t)
    I_:setSmooth(t)
end)

s2s:NewColorPicker("FOV Color", "Set fov color",I_.FOVColor, function(t)
    I_:setFovColor(t)
end)

local t3 = Windows:NewTab('ESP')
local s3 = t3:NewSection('ESP')
local s3o = t3:NewSection('Options')
local s3s = t3:NewSection('Settings')
local old_c = ESP.Color

s3:NewToggle('Enabled', 'Enable esp', function(t)
    _l:toggle(t)
end)
s3:NewToggle('Box', 'Show box', function(t)
    _l:boxes(t)
end)
s3:NewToggle('Name', 'Show name', function(t)
    _l:names(t)
end)
s3:NewToggle('Tracer', 'Show tracer', function(t)
    _l:tracers(t)
end)
s3:NewToggle('Distance', 'Show distance', function(t)
    _l:distances(t)
end)
s3:NewToggle('Healthbar', 'Show healthbar', function(t)
    _l:hps(t)
end)
s3:NewToggle('Head Dot', 'Show headdot', function(t)
    _l:headdot(t)
end)

s3o:NewDropdown('ESP Type', 'Set esp type', {'Static', 'Dynamic'}, function(t)
    _l:sType(t)
end)
s3o:NewDropdown('Tracer From', 'Set tracer from', {'Screen', 'Mouse', 'Player'}, function(t)
    _l:sTracer(t)
end)
s3o:NewToggle('Visible Only', 'When target not visible/on wall, will not visible', function(t)
    _l:sVis(t)
end)
s3o:NewToggle('Wall Check', 'When target not visible/on wall, esp will change color', function(t)
    _l:sWallC(t)
end)
s3o:NewToggle('Teammate', 'Show esp for teammate', function(t)
    _l:sTeam(t)
end)
s3o:NewToggle('Team Color', 'Set color to teams color', function(t)
    _l:teamcolor(t)
end)

s3s:NewSlider("Thickness", 'Set thickness of esp line', ESP.Thickness*2,1, function(t)
    _l:sThick(t)
end)

-- rbw = {false,1}
-- s3s:NewToggle('Rainbow Color', 'Set esp color to rainbow', function(t)
--     rbw[1] = t
--     while rbw[1] do
--         local time = tostring(rbw[2]) .. '0'
--         time = tonumber(time)
--         for _=0,1,0.01 do 
--             if not rbw[1] then break end
--             ESP:sColor(Color3.fromHSV(_,1,1)) 
--             wait(0.01 * time)
--         end
--         wait(0.01 * time)
--     end
--     ESP:sColor(old_c)
-- end)
-- s3s:NewSlider("Rainbow Time", "Slower color rainbow", 10,1, function(t)
--     rbw[2] = t
-- end)
s3s:NewColorPicker("Wall Color",'Set wall color', Color3.fromRGB(255,255,255), function(t)
    _l:sWColor(t)
end)
s3s:NewColorPicker("HP Color",'Set healthbar color', Color3.fromRGB(255,255,255),"EHPColor", function(t)
    _l:sHColor(t)
end)
s3s:NewColorPicker("ESP Color", 'Set esp color',Color3.fromRGB(255,255,255), function(t)
    _l:sColor(t)
    old_c = t
end)

local tinf = Windows:NewTab('Settings')
local sk = tinf:NewSection('Main')
local so = tinf:NewSection('Themes')

sk:NewKeybind("Open/Close", "Keybind to open/close gui", Enum.KeyCode.RightShift, function()
	lIlIlIlI:ToggleUI()
end)

so:NewDropdown("UI Themes", "Set ui themes", {'DarkTheme','LightTheme','BloodTheme','GrapeTheme','Ocean','Midnight','Sentinel','Synapse','Serpent'}, function(currentOption)
    lIlIlIlI:ChangeTheme(currentOption)
end)

local themes = lIlIlIlI:GetThemes()[2]
for theme, color in pairs(themes) do
    so:NewColorPicker(theme, "Change your "..theme, color, function(color3)
        lIlIlIlI:ChangeColor(theme, color3)
    end)
end