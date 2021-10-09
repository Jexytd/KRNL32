--[[
░██████╗██████╗░███████╗░█████╗░████████╗███████╗██████╗░
██╔════╝██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
╚█████╗░██████╔╝█████╗░░██║░░╚═╝░░░██║░░░█████╗░░██████╔╝
░╚═══██╗██╔═══╝░██╔══╝░░██║░░██╗░░░██║░░░██╔══╝░░██╔══██╗
██████╔╝██║░░░░░███████╗╚█████╔╝░░░██║░░░███████╗██║░░██║
╚═════╝░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
]]

--< GUI Settings >--
local setting = {
    theme = {
        images = {
            open_ui_icon = "rbxassetid://4521836217",
            close_ui_icon = "rbxassetid://4510354080",
        };
        
        colors = {
            ["primary color"] = Color3.fromRGB(192, 57, 43),
            ["secondary color"] = Color3.fromRGB(37, 41, 43),
            ["drag click"] = Color3.fromRGB(106, 30, 23),
            ["on color"] = Color3.fromRGB(48, 255, 162),
            ["exit click"] = Color3.fromRGB(255, 50, 50),
            ["text color"] = Color3.fromRGB(255, 255, 255)
        },
        
        font = "SourceSans",
        hotkey = Enum.KeyCode.Insert
    };
}

--< Library >--
local engine = loadstring(game:HttpGet("https://navicat.glitch.me/ui3.lua"))() --// Original https://pastebin.com/raw/y0iyJTiN

--< Initialized UI >--
local engine = engine(setting)
local Library = engine:init()
-- Documentation: https://pastebin.com/raw/H3ARQ6ZE

--< Window >--
local Windows = {'Main', 'Client', 'ESP', 'Credits', 'Information', 'Teleports'}
local TempWindows = {}
local XPosition,YPosition = 0
local XSize,YSize = 200, 150
for Index,Value in pairs(Windows) do
    if type(Value) ~= 'string' then Value = tostring(Value) end
    if XPosition >= 800 then
        XPosition = 0
        YPosition = YSize + 24
    end
    TempWindows[Value] = Library:create('window', '<semibold>' .. Value, {
        resizeable = false,
        default_position = UDim2.new(0, XPosition, 0, YPosition),
        default_size = UDim2.new(0, XSize, 0, YSize)
    })
    Windows[Index] = nil
    XPosition = XPosition + (XSize + 4)
end
Windows = TempWindows

function Windows:addColumn(window, size)
    size = size or 140
    return self[window]:create('column', size)
end

--< Column >--
local Columns = {}
for Index,Value in pairs(Windows) do
    Columns[Index] = {}
end
table.insert(Columns['Main'], Windows:addColumn('Main', 170))
table.insert(Columns['Client'], Windows:addColumn('Client'))
table.insert(Columns['ESP'], Windows:addColumn('ESP'))
table.insert(Columns['Credits'], Windows:addColumn('Credits'))
table.insert(Columns['Information'], Windows:addColumn('Information', 180))
table.insert(Columns['Teleports'], Windows:addColumn('Teleports'))

--< Global Variable >--
Players = game:GetService('Players')
client = Players.LocalPlayer
Camera = workspace.CurrentCamera

Items = workspace:FindFirstChild('Items')
GhostName = workspace:FindFirstChild('Van').Objectives.SurfaceGui.Frame.Objectives.GhostInfo.Text:split('is ')[2]:match('>(.+)<')
Rooms = workspace:FindFirstChild('House') and workspace.House:FindFirstChild('Rooms')

Main = {    
    FindEvidence = false,
    AutoEvidence = false,
    AutoAggro = false,
}
Client = {
    Noclip = false,
    Speedhack = false,
    Nofog = false,
    Fullbright = false
}
ESP = {
    Enabled = false,
    Ghost = false,
    Player = false,
    Items = false,
    
    Color = Color3.fromRGB(192, 57, 43),
    Type = '1',
    Objects = {}   
}

Evidence = {}
GhostRoom = {}
IsReady = false
Step = '0'

function log(...) return print('[WRAPPER]:', ...) end
local Init = loadstring(game:HttpGet('https://navicat.glitch.me/Specter/Init.lua'))()
coroutine.wrap(Init)()

spawn(function()
    while IsReady == 'Fail' do wait()
        Columns['Main'][1]:create('button', 'Init Ghost Room', function()
            Step = '1'
            coroutine.wrap(Init)()
        end)
        return
    end
end)

--< Component Gui >--

Columns['Credits'][1]:create('label', {Text = 'UI:\n<bold><cyan>Frostys Library\r', FontSize = 16, Font = 'Arial', Color3.fromRGB(255, 255, 255)})
Columns['Credits'][1]:create('label', {Text = 'ESP:\n<bold><cyan>Kiriot22\r', FontSize = 16, Font = 'Arial', Color3.fromRGB(255, 255, 255)})
Columns['Credits'][1]:create('label', {Text = 'Scripting:\n<bold><cyan>kyeaintdead\r', FontSize = 16, Font = 'Arial', Color3.fromRGB(255, 255, 255)})

-- Main
Columns['Main'][1]:create('toggle', 'Find Evidence', Main.FindEvidence, function(bool)
    Main.FindEvidence = bool
    while (Main.FindEvidence) do

        local EMF,Book,SB,TM do
            EMF = (function()
                local Folder = Items or (function()
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA('Model') and Players:GetPlayerFromCharacter(v) and v:FindFirstChild('EMF Reader') then
                            return v
                        end
                    end
                end)()

                return Folder:FindFirstChild('EMF Reader') or (Folder:FindFirstChildOfClass('Model') and Folder:FindFirstChildOfClass('Model').Name == 'EMF Reader' and Folder:FindFirstChildOfClass('Model'))
            end)()

            Book = (function()
                local Folder = Items or (function()
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA('Model') and Players:GetPlayerFromCharacter(v) and v:FindFirstChild('Book') then
                            return v
                        end
                    end
                end)()

                return Folder:FindFirstChild('Book') or (Folder:FindFirstChildOfClass('Model') and Folder:FindFirstChildOfClass('Model').Name == 'Book' and Folder:FindFirstChildOfClass('Model'))
            end)()

            SB = (function()
                local Folder = Items or (function()
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA('Model') and Players:GetPlayerFromCharacter(v) and v:FindFirstChild('Spirit Box') then
                            return v
                        end
                    end
                end)()

                return Folder:FindFirstChild('Spirit Box') or (Folder:FindFirstChildOfClass('Model') and Folder:FindFirstChildOfClass('Model').Name == 'Spirit Box' and Folder:FindFirstChildOfClass('Model'))
            end)()

            TM = (function()
                local Folder = Items or (function()
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA('Model') and Players:GetPlayerFromCharacter(v) and v:FindFirstChild('Thermometer') then
                            return v
                        end
                    end
                end)()

                return Folder:FindFirstChild('Thermometer') or (Folder:FindFirstChildOfClass('Model') and Folder:FindFirstChildOfClass('Model').Name == 'Thermometer' and Folder:FindFirstChildOfClass('Model'))
            end)()
        end

        if (EMF or Book or SB or TM) then
            do
                function a(EMF)
                    local s = false
                    if EMF and s == false then 
                        local L = {}
                        for I = 1, 5 do table.insert(L, 'L' .. tostring(I)) end
                        local t_s = {}
                        for I,V in pairs(L) do
                            L[I] = EMF:FindFirstChild(V)
                            if typeof(L[I]) == 'Instance' then
                                local c = L[I].BrickColor ~= BrickColor.new('Smoky grey')
                                if c and I == 5 then
                                    s = true
                                    break
                                end
            
                                if not c then 
                                    table.insert(t_s, L[I].BrickColor)
                                end
                            end
                        end
                        s = (s == true) or (#t_s <= 5 and t_s)
                    elseif not EMF and s == false then
                        local a = workspace:FindFirstChild('emfpart5') or workspace:WaitForChild('emfpart5')
                        if a then
                            s = true
                        end
                    end
            
                    Evidence['EMF'] = s
                    return s
                end
                function b(SB)
                    local s = false
                    if SB and s == false then
                        local child = SB:FindFirstChild('Hand') and SB.Hand:GetChildren()
                        for _,V in pairs(child) do
                            if V.ClassName == 'Sound' and V.Playing == true then
                                s = true
                                break
                            end
                        end
                    end
                    Evidence['SpiritBox'] = s
                    return s
                end
                function c(Book)
                    local s = false
                    if Book and s == false then
                        local t = {}
                        for I = 1, 2 do table.insert(t, 'Page' .. tostring(I)) end
                        for I,V in pairs(t) do
                            t[I] = Book:FindFirstChild(V)
                            if typeof(t[I]) == 'Instance' then
                                local b = t[I]:FindFirstChildOfClass('Decal')
                                local c = b.Transparency == 0
                                if c then
                                    s = true
                                    break
                                end
                            end
                        end
                    end
                    Evidence['Writing'] = s
                    return s
                end
                function d()
                    local s = false
                    if #GhostRoom > 0 and s == false then
                        local a = GhostRoom[1].Parent
                        if a:IsA('Folder') then
                            local b = a:FindFirstChild('PrintPart') and a.PrintPart:FindFirstChild('SurfaceGui') and (a.PrintPart.SurfaceGui.Enabled == true)
                            if b then
                                s = true
                            else
                                for _,V in pairs(a:FindFirstChild('Windows'):GetChildren()) do
                                    if V:IsA('Part') and V:FindFirstChild('PrintPart') then
                                        local c = a.PrintPart:FindFirstChild('SurfaceGui') and (a.PrintPart.SurfaceGui.Enabled == true)
                                        if c then
                                            s = true
                                            break
                                        end
                                    end
                                end
                            end
            
                        end
                    end
                    Evidence['Fingerprints'] = s
                    return s
                end
                function e()
                    local s = false
                    if s == false then
                        local a = workspace:FindFirstChild('Orb') or workspace:WaitForChild('Orb')
                        if a then
                            s = true
                        end
                        wait(.5)
                    end
                    Evidence['Orbs'] = s
                    return s
                end
                function f(TM)
                    local s = false
                    if TM and s == false then
                        local a = TM:FindFirstChild('Temp') and (TM.Temp:FindFirstChild('SurfaceGui') and TM.Temp.SurfaceGui.Frame.TextLabel.Text)
                        local b = tonumber(a:match('%d+'))
                        local c = (b <= 0)
                        if c then
                            s = true
                        end
                    elseif not TM and s == false then
                        --// cold breath
                    end
                    Evidence['Freezing'] = s
                    return s
                end
            end

            if #Evidence <= 3 then
                if not Evidence['EMF'] then
                    coroutine.wrap(a)(EMF)
                else
                    print('EMF 5', true)
                end
                if not Evidence['SpiritBox'] then
                    coroutine.wrap(b)(SB)
                end
                if not Evidence['Writing'] then
                    coroutine.wrap(c)(Book)
                else
                    print('Writing', true)
                end
                if not Evidence['Fingerprints'] then
                    coroutine.wrap(d)()
                    print('Fingerprints', true)
                end
                if not Evidence['Orbs'] then
                    coroutine.wrap(e)()
                else
                    print('Orb', true)
                end
                if not Evidence['Freezing'] then
                    coroutine.wrap(f)(TM)
                else
                    print('Freezing Temp', true)
                end
            else
                print('Step [3] are false, go on Step [4]')
                local INDEX = 1
                for K,V in pairs(Evidence) do 
                    if INDEX > 3 then 
                        getgenv().Evidence[INDEX] = nil 
                    end 
                    INDEX = INDEX + 1
                end
            end
        end
        wait(.2)
    end
end)
Columns['Main'][1]:create('toggle', 'Aggro Ghost Hunting', Main.AutoAggro, function(bool)
    Main.AutoAggro = bool
    local sv
    while Main.AutoAggro do
        local GhostModel = workspace:FindFirstChild('GhostModel')
        local Base = GhostModel:FindFirstChild('Base')
        local BasePart = GhostModel.PrimaryPart or GhostModel:FindFirstChild('HumanoidRootPart') or GhostModel:FindFirstChildWhichIsA('BasePart')
        local HRoot = client.Character and (client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart') or client.Character:FindFirstChildWhichIsA('BasePart'))
        if Base and Base.Transparency == 0 then
            if not Client.Noclip then
                sv = game:service'RunService'.RenderStepped:connect(function()
                    if Main.AutoAggro == true then pcall(function() client.Character.Humanoid:ChangeState(11) end) end
                    if Main.AutoAggro and Base.Transparency == 1 and not IsHunting  then sv:Disconnect() end
                    if Main.AutoAggro == false then sv:Disconnect() end
                end)
            end
            HRoot.CFrame = BasePart.CFrame * CFrame.new(0, 7, 0)
        end
    end
end)
Columns['Main'][1]:create('button', 'Collect Extra Evidence', function()
    local House = workspace:FindFirstChild('House')
    local HRoot = game.Players.LocalPlayer.Character.PrimaryPart
    local OldPos = HRoot.CFrame
    for i = 1, 2 do
        local fire = fireproximityprompt or game:GetService("ReplicatedStorage").ReportEvidence
        local e = House:FindFirstChild('Bone') or (function()
            local Waters = House:FindFirstChild('Waters')
            for i,v in pairs(Waters:GetChildren()) do
                if v:IsA('Part') and v.Transparency < 1 then
                    return v
                end
            end
        end)()
        if e then
            repeat
                pcall(function()
                    HRoot.CFrame = e.CFrame
                end)
                wait(.2)
                pcall(function()
                    if type(fire) == 'function' then
                        local proximity = e:FindFirstChildOfClass('ProximityPrompt') or e:FindFirstChild('ProximityPrompt')
                        fire(proximity)
                    else
                        fire:FireServer(e)
                    end
                end)
            until not e.Parent or not e or e.Transparency == 1
        end
    end

    HRoot.CFrame = OldPos
end)
-- Client
Columns['Client'][1]:create('toggle', 'No Clip', Client.Noclip, function(bool)
    Client.Noclip = bool
    local sv
    sv = game:service'RunService'.RenderStepped:connect(function()
        if Client.Noclip == true then pcall(function() client.Character.Humanoid:ChangeState(11) end) end
        if Client.Noclip == false then sv:Disconnect() end
    end)
end)
Columns['Client'][1]:create('toggle', 'Speedhack', Client.Speedhack, function(bool)
    local Old = client.Character and client.Character:FindFirstChildOfClass('Humanoid') and client.Character.Humanoid.WalkSpeed
    Client.Speedhack = bool
    if Client.Speedhack then
        client.Character.Humanoid.WalkSpeed = 60
    else
        client.Character.Humanoid.WalkSpeed = Old
    end
end)

local Old = {game.Lighting.Brightness, game.Lighting.ClockTime, game.Lighting.GlobalShadows}
Columns['Client'][1]:create('toggle', 'Fullbright', Client.Fullbright, function(bool)
    Client.Fullbright = bool
    if Client.Fullbright then
        game.Lighting.Brightness = 5
        game.Lighting.ClockTime = 9
        game.Lighting.GlobalShadows = false
    else
        game.Lighting.Brightness = Old[1]
        game.Lighting.ClockTime = Old[2]
        game.Lighting.GlobalShadows = Old[3]
    end
end)
-- ESP
local WTF = {}
for I = 1, 8 do table.insert(WTF, tostring(I)) end
Columns['ESP'][1]:create('dropdown', 'ESP Type', WTF, 1, function(x)
    ESP.Type = WTF[x]
end)
Columns['ESP'][1]:create('toggle', 'Enabled', ESP.Ghost, function(bool)
    ESP.Enabled = bool
end)
Columns['ESP'][1]:create('toggle', 'Ghost', ESP.Ghost, function(bool)
    ESP.Ghost = bool
end)
Columns['ESP'][1]:create('toggle', 'Player', ESP.Player, function(bool)
    ESP.Player = bool
end)
Columns['ESP'][1]:create('toggle', 'Items', ESP.Items, function(bool)
    ESP.Items = bool
end)
Columns['ESP'][1]:create("color_picker", "Color ESP", Color3.fromRGB(255,0,0), function(color)
    ESP.Color = Color3.fromRGB(color.R*255, color.G*255, color.B*255)
end);
-- Information
local FSize = 12
do
    Columns['Information'][1]:create('label', {Text = ('Name: %s'):format(client.Name), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    ISanity = Columns['Information'][1]:create('label', {Text = 'Sanity: %s%', FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    ICRoom = Columns['Information'][1]:create('label', {Text = 'Room: %s', FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    IPeace = Columns['Information'][1]:create('label', {Text = ('Peace: %s'), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    Columns['Information'][1]:create('label', {Text = ('\nName: %s'):format(GhostName), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    IGHunting = Columns['Information'][1]:create('label', {Text = ('Hunting: %s'), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    IGRoom = Columns['Information'][1]:create('label', {Text = ('Room: %s'), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
    IGFRoom = Columns['Information'][1]:create('label', {Text = ('Favorite Room: %s'), FontSize = FSize, Font = 'Arial', Color3.fromRGB(255,255,255)})
end

-- Teleports
Columns['Teleports'][1]:create('button', 'Ghost Room', function()
    local Hitbox = (IsReady and #GhostRoom ~= 0) and GhostRoom[1]
    local Humanoid,HRoot = (client.Character and client.Character:FindFirstChildOfClass('Humanoid')), (client.Character and (client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart')))
    if not Client.Noclip then Humanoid.Sit = true end
    if Hitbox then
        HRoot.CFrame = Hitbox.CFrame
    end
end)
Columns['Teleports'][1]:create('button', 'Van', function()
    local VanSpawn = workspace:FindFirstChild('House') and workspace.House:FindFirstChild('VanSpawn')
    local Humanoid,HRoot = (client.Character and client.Character:FindFirstChildOfClass('Humanoid')), (client.Character and (client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart')))
    if not Client.Noclip then Humanoid.Sit = true end
    HRoot.CFrame = VanSpawn.CFrame - Vector3.new(0, 4, 0)
end)
function initTeleport()
    local indeks = 1
    for _,v in pairs(Rooms:GetChildren()) do
        local RoomName = v:IsA('Folder') and v:FindFirstChild('RoomName') and v.RoomName.Value
        -- local Column = (indeks < 6 and ) or (indeks >= 6 and Columns['Teleports'][2])
        Columns['Teleports'][1]:create('button', RoomName, function()
            local Humanoid,HRoot = (client.Character and client.Character:FindFirstChildOfClass('Humanoid')), (client.Character and (client.Character.PrimaryPart or client.Character:FindFirstChild('HumanoidRootPart')))
            if not Client.Noclip then 
                Humanoid.Sit = true
            end

            local Hitbox = v:IsA('Folder') and v:FindFirstChild('Hitbox')
            if Hitbox then
                HRoot.CFrame = Hitbox.CFrame
            end
        end)
        indeks = indeks + 1
    end
end

function updateInfo()
    local Data = client:FindFirstChild('Data') or client:WaitForChild('Data')
    local OldGCRoom
    game:GetService("RunService").Heartbeat:connect(function()
        local Sanity = math.floor(Data.Sanity.Value)
        local Outside = Data.Outside.Value == true
        local CRoom = (Data.Room.Value and Data.Room.Value:FindFirstChild('RoomName') and Data.Room.Value.RoomName.Value) or (Outside and 'Outside') or 'Unknown'
        local f = function(x)
            local Minute = 60
            return (x >= Minute*5 and tostring(5) .. 'm') or (x >= Minute*4 and tostring(4) .. 'm') or (x >= Minute*3 and tostring(3) .. 'm') or (x >= Minute*2 and tostring(2) .. 'm') or (x >= Minute and tostring(1) .. 'm') or (x <= Minute and tostring(x) .. 's')
        end
        local Peace = f(game:GetService('ReplicatedStorage').Peace.Value)
        local GCRoom = (function()
            local GhostModel = workspace:FindFirstChild('GhostModel') or workspace:WaitForChild('GhostModel')
            local PrimaryPart = GhostModel.PrimaryPart or GhostModel:FindFirstChild('HumanoidRootPart') or GhostModel:FindFirstChildWhichIsA('BasePart')
            local onRoom = ''
            for _,v in pairs(Rooms:GetChildren()) do
                if v:IsA('Folder') and v:FindFirstChild('Hitbox') then
                    v.Hitbox.Size = (v.Hitbox.Size + Vector3.new(0, 20, 0))
                    if (PrimaryPart.Position - v.Hitbox.Position).magnitude <= 5 then
                        onRoom = v.RoomName.Value
                        OldGCRoom = onRoom
                        break
                    end
                end
            end
            return (onRoom ~= '' and onRoom) or OldGCRoom or 'Unknown'
        end)()
        local IsHunting = (function()
            local on = false
            local GhostModel = workspace:FindFirstChild('GhostModel')
            local Base = GhostModel:FindFirstChild('Base')
            wait(.3)
            if Base.Transparency == 0then
                on = true
            end
            return on
        end)()
        local GFRoom = (IsReady and #GhostRoom ~= 0 and GhostRoom[2]) or (not IsReady and #GhostRoom == 0 and 'Initializing') or (IsReady == 'Fail' and #GhostRoom == 0 and 'Failed Initializing')
        pcall(ISanity.ChangeText, 'Sanity: '.. tostring(Sanity) .. '%')
        pcall(ICRoom.ChangeText, 'Room: ' .. tostring(CRoom))
        pcall(IPeace.ChangeText, 'Peace: ' .. Peace)
        pcall(IGRoom.ChangeText, 'Room: ' .. GCRoom)
        pcall(IGHunting.ChangeText, 'Hunting: ' .. tostring(IsHunting))
        pcall(IGFRoom.ChangeText, 'Favorite Room: ' .. tostring(GFRoom))
    end)
end

coroutine.wrap(initTeleport)()
coroutine.wrap(updateInfo)()

--< ESP >--
--// Original ESP from Kiriot22 ESP, i just add bit script in base:update()
pcall(function()
    function Draw(a, b)
        local c = Drawing.new(a)
        local c2 = b or {}
        for k,v in (pairs or ipairs)(c2) do
            c[k] = v;
        end
        return c
    end
    
    Base = {}
    Base.__index = Base
    
    function Base:Remove()
        ESP.Objects[self.Object] = nil
        for i,v in pairs(self.Draw) do
            if type(v) == 'table' then --// i use this for esp bone
                for k,v2 in pairs(v) do
                    v[k].Visible = false
                    v[k]:Remove()
                    self.Draw[i] = nil
                end
            else
                self.Draw[i].Visible = false
                self.Draw[i]:Remove()
                self.Draw[i] = nil
            end
        end
    end
    
    function Base:Update()
        if not self.PrimaryPart then return self:Remove() end
    
        local Box,Line,Name,Sanity = self.Draw.Box, self.Draw.Line, self.Draw.Name, self.Draw.Sanity
        if ESP.Enabled then
            local WTVP = function(x) return Camera:WorldToViewportPoint(x) end
    
            local TY_1 = (ESP.Type == '1') -- ALL
            local TY_2 = (ESP.Type == '2') -- Box & Name & Sanity
            local TY_3 = (ESP.Type == '3') -- Name & Sanity & Line
            local TY_4 = (ESP.Type == '4') -- Box & Line
            local TY_5 = (ESP.Type == '5') -- Line & Name & Sanity
            local TY_6 = (ESP.Type == '6') -- Box
            local TY_7 = (ESP.Type == '7') -- Name & Sanity
            local TY_8 = (ESP.Type == '8') -- Line
    
            --// BOXES \\--
            if (TY_1 or TY_2 or TY_4 or TY_5) and ESP.Ghost or ESP.Player or ESP.Items then
                local CF,Size;
                if ESP.Ghost and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and self.Object:FindFirstChild('Ghost') then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
                if ESP.Player and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and Players:GetPlayerFromCharacter(self.Object) then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
                if ESP.Items and CF == nil and Size == nil and Items:IsAncestorOf(self.Object) then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
    
                local Offset = {
                    ['TopLeft'] = CF * CFrame.new(Size.X/2, Size.Y, 0),
                    ['TopRight'] = CF * CFrame.new(-Size.X/2, Size.Y, 0),
                    ['BottomLeft'] = CF * CFrame.new(Size.X/2, -Size.Y, 0),
                    ['BottomRight'] = CF * CFrame.new(-Size.X/2, -Size.Y, 0)
                }
                local TR,v1 = WTVP(Offset.TopRight.p)
                local TL,v2 = WTVP(Offset.TopLeft.p)
                local BR,v3 = WTVP(Offset.BottomRight.p)
                local BL,v4 = WTVP(Offset.BottomLeft.p)
                if Box then
                    if (v1 or v2 or v3 or v4) then
                        Box.Visible = true
                        Box.PointA = TR
                        Box.PointB = TL
                        Box.PointC = BL
                        Box.PointD = BR
    
                        Box.Color = self.Color or ESP.Color
                    else
                        Box.Visible = false
                    end
                end
            else
                Box.Visible = false
            end
    
            --// NAME \\--
            if (TY_1 or TY_2 or TY_3 or TY_5 or TY_7) and ESP.Ghost or ESP.Player or ESP.Items then
                local CF,Size;
                if ESP.Ghost and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and self.Object:FindFirstChild('Ghost') then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
                if ESP.Player and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and Players:GetPlayerFromCharacter(self.Object) then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
                if ESP.Items and CF == nil and Size == nil and Items:IsAncestorOf(self.Object) then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                end
    
                local NameOffset = CF * CFrame.new(0,Size.Y*2,0)
                local Position,v1 = WTVP(NameOffset.p)
                if Name then
                    if v1 then
                        Name.Visible = true
                        Name.Center = true
                        Name.Position = Position
                        Name.Text = self.Name
    
                        Name.Color = self.Color or ESP.Color
                    else
                        Name.Visible = false
                    end
                end
            else
                Name.Visible = false
            end
    
            --// SANITY \\--
            if (TY_1 or TY_2 or TY_3 or TY_5 or TY_7) and ESP.Player then
                local CF,Size,OBject
                if ESP.Player and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and Players:GetPlayerFromCharacter(self.Object) then
                    CF = self.PrimaryPart.CFrame
                    Size = self.PrimaryPart.Size
                    Object = self.Object
                end
    
                local SanityOffset = CF * CFrame.new(0,Size.Y*1.5,0)
                local Position,v1 = WTVP(SanityOffset.p)
                if Sanity then
                    if v1 then
                        Sanity.Visible = true
                        Sanity.Center = true
                        Sanity.Position = Position
    
                        local p = Players:GetPlayerFromCharacter(self.Object)
                        local data = p:FindFirstChild('Data')
                        local sanity = data:FindFirstChild('Sanity') and math.floor(data.Sanity.Value)
                        Sanity.Text = tostring(sanity) .. '%'
    
                        Sanity.Color = self.Color or ESP.Color
                    else
                        Sanity.Visible = false
                    end
                end
            else
                Sanity.Visible = false
            end
    
            --// LINE \\--
            if (TY_1 or TY_3 or TY_4 or TY_8) and ESP.Ghost or ESP.Player or ESP.Items then
                local CF,Size;
                if ESP.Ghost and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and self.Object:FindFirstChild('Ghost') then
                    CF,Size = self.PrimaryPart.CFrame, self.PrimaryPart.Size
                end
                if ESP.Player and CF == nil and Size == nil and workspace:IsAncestorOf(self.Object) and Players:GetPlayerFromCharacter(self.Object) then
                    CF,Size = self.PrimaryPart.CFrame, self.PrimaryPart.Size
                end
                if ESP.Items and CF == nil and Size == nil and Items:IsAncestorOf(self.Object) then
                    CF,Size = self.PrimaryPart.CFrame, self.PrimaryPart.Size
                end
    
                local LineOffset = CF * CFrame.new(0,-Size.Y/3, 0)
                local Position,v1 = WTVP(LineOffset.p)
                if Line then
                    if v1 then
                        Line.Visible = true
                        Line.To = Position
                        Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    
                        Line.Color = self.Color or ESP.Color
                    else
                        Line.Visible = false
                    end
                end
            else
                Line.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            Line.Visible = false
        end
    end
    
    function ESP:Add(Object,Options)
        if not Object.Parent then return log(object, 'doesnt have a parent!') end
        local Data = setmetatable({
            Name = Options.Name or Object.Name or tostring(Object),
            Color = self.Color or Color3.fromRGB(255, 255, 255),
            Object = Object,
            PrimaryPart = Options.PrimaryPart and (Options.PrimaryPart.ClassName == 'Model' and (Options.PrimaryPart.PrimaryPart or Options.PrimaryPart:FindFirstChild('HumanoidRootPart') or Options.PrimaryPart:FindFirstChildWhichIsA('BasePart')) or Options.PrimaryPart:IsA('BasePart') and Options.PrimaryPart) or Object.PrimaryPart or Object.ClassName == 'Model' and (Object.PrimaryPart or Object:FindFirstChild('HumanoidRootPart') or Object:FindFirstChildWhichIsA('BasePart')) or Object:IsA('BasePart') and Object,
            Draw = {}
        }, Base)
        if self.Objects[Object] then self.Objects[Object]:Remove() end
    
        Data.Draw['Box'] = Draw('Quad', {
            Thickness = 2,
            Color = self.Color,
            Visible = self.Enabled and (self.Type == '1' or self.Type == '2' or self.Type == '4' or self.Type == '6') and self.Ghost or self.Player or self.Items
        })
    
        Data.Draw['Line'] = Draw('Line', {
            Thickness = 2,
            Color = Data.Color,
            Visible = self.Enabled and (self.Type == '1' or self.Type == '3' or self.Type == '4' or self.Type == '5' or self.Type == '8') and self.Ghost or self.Player or self.Items
        })
    
        Data.Draw['Name'] = Draw('Text', {
            Color = Data.Color,
            Center = true,
            Outline = true,
            Size = ESP.TextSize,
            Visible = self.Enabled and (self.Type == '1' or self.Type == '2' or self.Type == '3' or self.Type == '5' or self.Type == '7') and self.Ghost or self.Player or self.Items
        })
        Data.Draw['Sanity'] = Draw('Text', {
            Color = Data.Color,
            Center = true,
            Outline = true,
            Size = ESP.TextSize,
            Visible = self.Enabled and (self.Type == '1' or self.Type == '2' or self.Type == '3' or self.Type == '5' or self.Type == '7') and self.Player
        })
        self.Objects[Object] = Data
    
        Object.AncestryChanged:connect(function(_, Parent)
            if Parent == nil then Data:Remove() end
        end)
    
        Object:GetPropertyChangedSignal('Parent'):connect(function()
            if Object.Parent == nil then Data:Remove() end
        end)
    
        local Humanoid = Object:FindFirstChildOfClass('Humanoid')
        if Humanoid then
            Humanoid.Died:connect(function()
                Data:Remove()
            end)
        end
    
        return Data
    end
    -- Add ESP to Player
    do
        local function CharAdded(char)
            local p = Players:GetPlayerFromCharacter(char)
            if not char:FindFirstChild("HumanoidRootPart") then
                local ev
                ev = char.ChildAdded:Connect(function(c)
                    if c.Name == "HumanoidRootPart" then
                        ev:Disconnect()
                        ESP:Add(char, {
                            Name = p.Name,
                            PrimaryPart = c
                        })
                    end
                end)
            else
                ESP:Add(char, {
                    Name = p.Name,
                    PrimaryPart = char.HumanoidRootPart,
                })
            end
        end
        local function PlayerAdded(p)
            p.CharacterAdded:Connect(CharAdded)
            if p.Character then
                coroutine.wrap(CharAdded)(p.Character)
            end
        end
        --// Adding esp
        Players.PlayerAdded:Connect(PlayerAdded) --// add esp when player join
        for i,v in pairs(Players:GetPlayers()) do
            if v ~= client then
                PlayerAdded(v) --// add esp to all player
            end
        end
    end

    -- Add esp to items
    do
        Items.ChildAdded:connect(function(c)
            if c.ClassName == 'Model' and (c.PrimaryPart or c:FindFirstChildWhichIsA('BasePart')) then
                ESP:Add(c, {
                    Name = c.Name,
                    PrimaryPart = c
                })
            end
        end)
        for i,v in pairs(Items:GetChildren()) do
            ESP:Add(v, {
                Name = v.Name,
                PrimaryPart = v
            })
        end
    end

    -- Add ESP to ghost
    do
        ESP:Add(workspace.GhostModel, {
            Name = GhostName,
            PrimaryPart = workspace.GhostModel
        })
    end

    game:GetService("RunService").RenderStepped:Connect(function()
        for i,v in (pairs or ipairs)(ESP.Objects) do
            if v.Update then
                pcall(v.Update, v)
            end
        end
    end)
end)