local Library = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Distances = false,
    Tracers = false,
    HPs = false,
    HeadDot = false,
    Type = 'Dynamic',

    TracerType = 'Screen',

    Visible = false,
    WallCheck = false,
    Teams = false,
    TeamsColor = false,
    Color = Color3.fromRGB(255, 255, 255),
    WallColor = Color3.fromRGB(255,75,75),
    HPColor = Color3.fromRGB(75,255,75),
    Thickness = 3,
    TextSize = 18,

    Objects = setmetatable({}, {_mode='kv'}),
}

do
    function Library:toggle(a)
        self.Enabled = a
    end

    function Library:boxes(a)
        self.Boxes = a
    end
    function Library:names(a)
        self.Names = a
    end
    function Library:distances(a)
        self.Distances = a
    end
    function Library:tracers(a)
        self.Tracers = a
    end
    function Library:headdot(a)
        self.HeadDot = a
    end
    function Library:hps(a)
        self.HPs = a
    end

    function Library:sColor(a)
        self.Color = a
    end
    function Library:sWColor(a)
        self.WallColor = a
    end
    function Library:sWallC(a)
        self.WallCheck = a
    end

    function Library:sThick(a)
        self.Thickness = a
    end

    function Library:sType(a)
        self.Type = a
    end
    function Library:sTracer(a)
        self.TracerType = a
    end

    function Library:sVis(a)
        self.Visible = a
    end
    
    function Library:sTeam(a)
        self.Teams = a
    end
    function Library:sHColor(a)
        self.HPColor = a
    end

    function Library:teamcolor(a)
        self.TeamsColor = a
    end

    function Library:setTSize(a)
        self.TextSize = a
    end
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Client:GetMouse()

local function Draw(o,p)
    local o = Drawing.new(o)
    local p = p or {}
    for k,v in pairs(p) do
        o[k] = v
    end
    return o
end

function WTVP(o)
    local p = o
    if typeof(o) == 'CFrame' then
        p = o.p or o.Position or Vector3.new(o.X, o.Y, o.Z)
    end
    return Camera:WorldToViewportPoint(p)
end

function Library:IsTeam(pl)
    local a = pl or Players:GetPlayerFromCharacter(pl)
    return a.Team == Client.Team
end

function Library:IsVisible(p)
    local a = p.Character or (p.ClassName == 'Model' and p)
    local b = a.ClassName == 'Model' and (a.PrimaryPart or a:FindFirstChild('HumanoidRootPart') or a:FindFirstChildWhichIsA('BasePart'))
    local newRay = Ray.new(Camera.CFrame.p, b.Position - Camera.CFrame.p)
    local Hit = workspace:FindPartOnRayWithIgnoreList(newRay, {Client.Character, CurrentCamera})
    if Hit and Hit:IsDescendantOf(a) then
        return false
    else
        return true
    end
end

boxBase = {}
boxBase.__index = boxBase

function boxBase:Remove()
    Library.Objects[self.Object] = nil
    for i,v in pairs(self.ESP) do
        if type(v) == 'table' then
            for i2 in pairs(v) do
                v[i2].Visible = false
                v[i2]:Remove()
                self.ESP[i][i2] = nil
            end
            self.ESP[i] = nil
        else
            v.Visible = false
            v:Remove()
            self.ESP[i] = nil
        end
    end
end

function boxBase:up()
    if not self.PrimaryPart then return self:Remove() end

    local Color;
    if Library.TeamsColor then
        Color = self.Player.TeamColor.Color
    elseif Library.WallCheck and Library:IsVisible(self.Player) then
        Color = Library.WallColor
    else
        Color = Library.Color
    end

    local n = true
    if self.Player and not Library.Teams and Library:IsTeam(self.Player) then
        n = false
    end
    if self.Player and Library.Visible and Library:IsVisible(self.Player) then
        n = false
    end
    if not Library.Enabled then
        n = false
    end
    if not n then
        for i,v in pairs(self.ESP) do
            if type(v) == 'table' then
                for i2 in pairs(v) do
                    v[i2].Visible = false
                end
            else
                v.Visible = false
            end
        end
        return
    end   

    local Box = self.ESP.Box
    local Name = self.ESP.Name
    local Distance = self.ESP.Distance
    local Tracer = self.ESP.Tracer
    local Dot = self.ESP.Dot
    local Img = self.ESP.Img
    local HP = self.ESP.HP
    
    local CF,SZ = self.PrimaryPart.CFrame, (self.Size or self.PrimaryPart.Size)
    local Koordinat = (function()
        local t = {}
        if Library.Type == 'Static' then
            t = {
                TR = CF + Vector3.new(-SZ.X/2, SZ.Y, 0),
                TL = CF + Vector3.new(SZ.X/2, SZ.Y, 0),
                BL = CF + Vector3.new(SZ.X/2, -SZ.Y, 0),
                BR = CF + Vector3.new(-SZ.X/2, -SZ.Y, 0),
                T = CF + Vector3.new(0, SZ.Y, 0),
                B = CF + Vector3.new(0, -SZ.Y, 0)
            }
        elseif Library.Type == 'Dynamic' then
            t = {
                TR = CF * CFrame.new(-SZ.X/2, SZ.Y, 0),
                TL = CF * CFrame.new(SZ.X/2, SZ.Y, 0),
                BL = CF * CFrame.new(SZ.X/2, -SZ.Y, 0),
                BR = CF * CFrame.new(-SZ.X/2, -SZ.Y, 0),
                T = CF * CFrame.new(0, SZ.Y, 0),
                B = CF * CFrame.new(0, -SZ.Y, 0)
            }
        end
        return t
    end)()

    if Library.Boxes then
        local TR,v1 = WTVP(Koordinat.TR)
        local TL,v2 = WTVP(Koordinat.TL)
        local BL,v3 = WTVP(Koordinat.BL)
        local BR,v4 = WTVP(Koordinat.BR)
        if (v1 or v2 or v3 or v4) then
            Box.Visible = true
            Box.PointA = TR
            Box.PointB = TL
            Box.PointC = BL
            Box.PointD = BR
            Box.Thickness = Library.Thickness
            Box.Color = Color
        else
            Box.Visible = false
        end
    else
        Box.Visible = false
    end

    if Library.Tracers then
        local Bottom,v = WTVP(Koordinat.B)
        pcall(function()
            local cPart = Client.Character and (Client.Character.PrimaryPart or Client.Character:FindFirstChild('HumanoidRootPart') or Client.Character:FindFirstChildWhichIsA('BasePart'))
            local fPos = WTVP(cPart.CFrame)
            TPos = {
                ['Mouse']=Vector2.new(Mouse.X, Mouse.Y + (game:GetService('GuiService'):GetGuiInset().Y)),
                ['Screen']=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.X/1.5),
                ['Player']=fPos
            }
        end)
        if v then
            Tracer.Visible = true
            Tracer.From = Bottom
            Tracer.To = TPos[Library.TracerType]
            Tracer.Thickness = Library.Thickness
            Tracer.Color = Color
        else
            Tracer.Visible = false
        end
    else
        Tracer.Visible = false
    end

    if Library.Names then
        local _,v = WTVP(CF)
        if v then
            local Pos1 = WTVP((function()
                if Library.Type == 'Static' then
                    return CF + Vector3.new(0, SZ.Y*2.5, 0)
                elseif Library.Type == 'Dynamic' then
                    return CF * CFrame.new(0, SZ.Y*2.5, 0)
                end
            end)())
            local Pos2 = WTVP((function()
                if Library.Type == 'Static' then
                    return CF + Vector3.new(0, SZ.Y*1.5, 0)
                elseif Library.Type == 'Dynamic' then
                    return CF * CFrame.new(0, SZ.Y*1.5, 0)
                end
            end)())

            Name.Visible = true
            Img.Visible = true
            Name.Size = Library.TextSize
            Name.Center = true
            Name.Outline = true
            Name.Color = Color
            -- spawn(function()
            --     --local url = ('http://www.roblox.com/Thumbs/Avatar.ashx?id=%s&width=60&height=60&format=jpg'):format(tostring(self.Player.UserId))
            --     local url = ('https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=60&height=60&format=jpg'):format(tostring(self.Player.UserId))
            --     Img.Data = game:HttpGet(url)
            -- end)
            local Ratio = (Camera.CFrame.p - CF.p).magnitude
            local offset = math.clamp(1/Ratio*750, 1, 100)
            Img.Size = Vector2.new(offset,offset)
            offset = math.clamp(1/Ratio*750, 1, 300)
            Img.Position = Vector2.new(Pos1.X, Pos1.Y - offset)
            Name.Position = Vector2.new(Pos2.X, Pos2.Y - offset)
            Name.Text = self.Name or 'Loading...'
            
        else
            Img.Visible = false
            Name.Visible = false
        end
    else
        Img.Visible = false
        Name.Visible = false
    end

    if Library.Distances then
        local _,v = WTVP(CF)
        if v then
            local Pos = WTVP((function()
                if Library.Type == 'Static' then
                    return CF + Vector3.new(0, -SZ.Y*2, 0)
                elseif Library.Type == 'Dynamic' then
                    return CF * CFrame.new(0, -SZ.Y*2, 0)
                end
            end)())

            Distance.Visible = true
            Distance.Size = Library.TextSize
            Distance.Center = true
            Distance.Outline = true
            Distance.Color = Color
            Distance.Text = tostring( math.floor(Client:DistanceFromCharacter(CF.p)) ) .. 'M'
            Distance.Position = Pos
        else
            Distance.Visible = false
        end
    else
        Distance.Visible = false
    end

    if Library.HeadDot then
        local _,v = WTVP(CF.p)
        if v then
            local PHead = self.Object:FindFirstChild('Head') or self.Object:WaitForChild('Head')
            local Pos = WTVP(PHead.Position)
            Dot.Visible = true
            local Ratio = (Camera.CFrame.p - CF.p).magnitude
            local offset = math.clamp(1/Ratio*750, 1, 5)
            Dot.Radius = offset
            Dot.Color = Color
            Dot.Thickness = Library.Thickness
            Dot.Position = Pos
        else
            Dot.Visible = false
        end
    else
        Dot.Visible = false
    end

    if Library.HPs then
        local _,v = WTVP(CF.p)
        if v then
            pcall(function()
                local Humanoid = self.Object:FindFirstChildOfClass('Humanoid')
                if Humanoid then
                    Health = Humanoid.Health / Humanoid.MaxHealth
                end
            end)
            local Pos = (function()
                local t = {}
                if Library.Type == 'Static' then
                    t = {
                        CF + Vector3.new(SZ.X/1.3,SZ.Y*Health,0),
                        CF + Vector3.new(SZ.X/1.3,-SZ.Y*Health,0)
                    }
                elseif Library.Type == 'Dynamic' then
                    t = {
                        CF * CFrame.new(SZ.X/1.3,SZ.Y*Health,0),
                        CF * CFrame.new(SZ.X/1.3,-SZ.Y*Health,0)
                    }
                end
                return t
            end)()

            local Top = WTVP(Pos[1])
            local Bottom = WTVP(Pos[2])
            HP.Visible = true
            HP.Thickness = Library.Thickness
            HP.Color = Library.HPColor or Color
            HP.PointA = Top
            HP.PointB = Top
            HP.PointC = Bottom
            HP.PointD = Bottom
        else
            HP.Visible = false
        end
    else
        HP.Visible = false
    end
end

function Library:add(o,p)
    if not o.Parent then return warn(o, 'no parent') end

    local a = setmetatable({
        Name = p.Name or o.Name or tostring(o),
        Size = p.Size or self.Size,
        Object = o,
        Player = p.Player or Players:GetPlayerFromCharacter(o),
        PrimaryPart = p.PrimaryPart or o.ClassName == 'Model' and (o.PrimaryPart or o:FindFirstChild('HumanoidRootPart') or o:FindFirstChildWhichIsA('BasePart')) or o:IsA('BasePart') and o,
        ESP = {}
    }, boxBase)
    if self.Objects[o] then self.Objects[o]:Remove() end

    a.ESP['Box'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Boxes
    })
    a.ESP['Name'] = Draw('Text', {
        Size = self.TextSize,
        Center = true,
        Outline = true,
        Color = self.Color,
        Visible = self.Enabled and self.Names
    })
    repeat
        pcall(function() -- may get error when get http
            local url = ('https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=60&height=60&format=jpg'):format(tostring(a.Player.UserId))
            a.ESP['Img'] = Draw('Image', {
                Rounding = 60,
                Data = game:HttpGet(url),
                Size = Vector2.new(48,48),
                Visible = self.Enabled and self.Names
            })
        end)
        wait()
    until a.ESP['Img']
    a.ESP['Distance'] = Draw('Text', {
        Size = self.TextSize,
        Center = true,
        Outline = true,
        Color = self.Color,
        Visible = self.Enabled and self.Distances
    })
    a.ESP['Tracer'] = Draw('Line', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Tracers
    })
    a.ESP['Dot'] = Draw('Circle', {
        Thickness = self.Thickness,
        NumSides = 60,
        Filled = true,
        Color = self.Color,
        Visible = self.Enabled and HeadDot
    })
    a.ESP['HP'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.HPs
    })

    self.Objects[o] = a
    o.AncestryChanged:Connect(function(_,p)
        if p == nil then
            a:Remove()
        end
    end)
    o:GetPropertyChangedSignal('Parent'):Connect(function()
        if o.Parent == nil then
            a:Remove()
        end
    end)

    local h = o:FindFirstChildOfClass('Humanoid')
    if h then
        h.Died:Connect(function()
            a:Remove()
        end)
    end
    return a
end

local function CharAdded(char)
    local p = Players:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                Library:add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c,
                })
            end
        end)
    else
        Library:add(char, {
            Name = p.Name,
            Player = p,
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
Players.PlayerAdded:Connect(PlayerAdded)
for i,v in pairs(Players:GetPlayers()) do
    if v ~= Client then
        PlayerAdded(v)
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for i,v in (pairs or ipairs)(Library.Objects) do
        if v.up then
            pcall(v.up, v)
        end
    end
end)

return Library