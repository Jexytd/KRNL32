local UI = loadstring(game:HttpGet('https://navicat.glitch.me/ui2.lua'))()
local ESP = loadstring(game:HttpGet('https://navicat.glitch.me/ESPLib.lua'))()
--// HEADERS //--
local Window, Main = UI:CreateWindow('Universal')
local Tab1,Tab2 = Window:CreateTab('ESP'), Window:CreateTab('Aimbot')
local Group1,Group2,Group3 = Tab1:CreateGroupbox('Toggle'), Tab1:CreateGroupbox('Settings'), Tab1:CreateGroupbox('Options')
--// BODY //--
WHAT,OldColor = false, ESP.Color;

local Teamate = Group3:CreateToggle('Teamate', function(x)
    ESP.Teamate = x
end)
local TeamColor = Group3:CreateToggle('Teamate Color', function(x)
    ESP.TeamColor = x
end)
local WallCheck = Group3:CreateToggle('Wall Check', function(x)
    ESP.WallCheck = x
end)

local Rainbow = Group2:CreateToggle('Rainbow', function(x)
    WHAT = x
    while WHAT do
        local rainbow = Color3.fromHSV(tick() * 24 % 255 / 255,1,1)
        ESP.Color = rainbow
        ESP.WallColor = rainbow
        wait()
        if not WHAT then ESP.Color = OldColor end
    end
end)
local Render = Group2:CreateSlider('Render ESP', 0, 5000, ESP.Render, function(x)
    ESP.Render = x
end)
local TextSize = Group2:CreateSlider('Text Size', 0, 21, ESP.TextSize, function(x)
    ESP.TextSize = x
end)
local TextSize = Group2:CreateSlider('Thickness', 0, 5, ESP.Thickness, function(x)
    ESP.Thickness = x
end)
local Radius = Group2:CreateSlider('Radius', 0, 20, ESP.Radius, function(x)
    ESP.Radius = x
end)

--[[
    TOGGLE THINGS
]]

local Enabled = Group1:CreateToggle('Enabled', function(x)
    ESP:Toggle(x)
end)

local Box = Group1:CreateToggle('Box', function(x)
    ESP.Box = x
end)

local Name = Group1:CreateToggle('Name', function(x)
    ESP.Name = x
end)

local Distance = Group1:CreateToggle('Distance', function(x)
    ESP.Distance = x
end)

local Tracers = Group1:CreateToggle('Tracers', function(x)
    ESP.Tracers = x
end)

local Healthbar = Group1:CreateToggle('Health Bar', function(x)
    ESP.HealthBar = x
end)

local Bone = Group1:CreateToggle('Bone', function(x)
    ESP.Bone = x
end)