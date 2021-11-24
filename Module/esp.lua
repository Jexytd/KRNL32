local Library = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Distances = false,
    Tracers = false,
    HeadDot = false,
    Type = 'Dynamic',

    Visible = false,
    Teams = false,
    TeamsColor = false,
    Color = Color3.fromRGB(255, 255, 255),
    Thickness = 2,

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

    function Library:sColor(a)
        self.Color = a
    end

    function Library:sThick(a)
        self.Thickness = a
    end

    function Library:sType(a)
        self.Type = a
    end

    function Library:sVis(a)
        self.Visible = a
    end
    
    function Library:sTeam(a)
        self.Teams = a
    end

    function Library:teamcolor(a)
        self.TeamsColor = a
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
    if typeof(o) == 'Instance' then
        p = o.Position
    elseif typeof(o) == 'CFrame' then
        p = o.p or o.Position or Vector3.new(o.X, o.Y, o.Z)
    elseif o:IsA('Model') then
        p = (o.PrimaryPart and o.PrimaryPart.Position) or (o:FindFirstChild('HumanoidRootPart') and o.HumanoidRootPart.Position) or (o:FindFirstChildWhichIsA('BasePart') and o:FindFirstChildWhichIsA('BasePart').Position)
    end
    return Camera:WorldToViewportPoint(p)
end

function Library:IsTeam(pl)
    local a = pl or Players:GetPlayerFromCharacter(pl)
    return a.Team == Client.Team
end

function Library:IsVisible(p)
    local s = false
    local a = p.Character or (p.ClassName == 'Model' and p)
    local b = a.PrimaryPart or a:FindFirstChild('HumanoidRootPart') or a:FindFirstChildWhichIsA('BasePart')
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

    local n = true
    if self.Player and not Library.Teams and Library:IsTeam(self.Player) then
        n = false
    end
    if self.Player and Library.Visible and Library:IsVisible(self.Player) then
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

    local Color;
    if self.Player and Library.TeamsColor then
        Color = self.Player.TeamColor.Color
    else
        Color = Library.Color
    end

    local Box = self.ESP.Box
    local Name = self.ESP.Name
    local Distance = self.ESP.Distance
    local Tracer = self.ESP.Tracer
    local Dot = self.ESP.Dot
    local Img = self.ESP.Img
    if Library.Enabled then
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
            if v then
                Tracer.Visible = true
                Tracer.Position = Bottom
                Tracer.Thickness = Library.Thickness
                Tracer.Color = Color
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end

        if Library.Names then
            local _,v = WTVP(CF.p)
            if v then
                local Top = WTVP(Koordinat.T)
                Top = Top + Vector3.new(0, SZ.Y/2, 0)
                local Left = Top + Vector3.new(SZ.X/2, 0, 0)
                Left = WTVP(Left)

                Name.Visible = true
                Img.Visible = true
                Name.Size = (self.Thickness*6)
                Name.Center = true
                Name.Outline = true
                Name.Color = Color
                Img.Position = Right
                Name.Position = Top
                
            else
                Img.Visible = false
                Name.Visible = false
            end
        else
            Img.Visible = false
            Name.Visible = false
        end

        if Library.Distances then
            local _,v = WTVP(CF.p)
            if v then
                local Top = WTVP(Koordinat.T)
                Top = Top + Vector3.new(0, SZ.Y/2, 0)
                local Right = Top + Vector3.new(-SZ.X/2, 0, 0)
                Right = WTVP(Right)

                Distance.Visible = true
                Distance.Size = (self.Thickness*6)
                Distance.Center = true
                Distance.Outline = true
                Distance.Color = Color
                Distance.Position = Right
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
                Dot.Color = Color
                Dot.Thickness = self.Thickness
                Dot.Position = Pos
            else
                Dot.Visible = false
            end
        else
            Dot.Visible = false
        end
    else
        for i,v in pairs(self.ESP) do
            if type(v) == 'userdata' then
                v.Visible = false
            elseif type(v) == 'table' then
                for i2,v2 in pairs(v) do
                    v2.Visible = false
                end
            else
                print(i,v)
            end
        end
    end
end

function Library:add(o,p)
    if not o.Parent then return warn(o, 'no parent') end

    local a = setmetatable({
        Name = p.Name or o.Name or tostring(o),
        Color = p.Color or self.Color,
        Size = p.Size or self.Size,
        Object = o,
        Player = p.Player or Players:GetPlayerFromCharacter(o),
        PrimaryPart = p.PrimaryPart or o.ClassName == 'Model' and (o.PrimaryPart or o:FindFirstChild('HumanoidRootPart') or o:FindFirstChildWhichIsA('BasePart')) or o:IsA('BasePart') and o,
        ESP = {}
    }, boxBase)

    a.ESP['Box'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Boxes
    })
    a.ESP['Name'] = Draw('Text', {
        Size = (self.Thickness*6),
        Center = true,
        Outline = true,
        Color = self.Color,
        Visible = self.Enabled and self.Names
    })
    local tType,tSize = Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48
    local headShot = Players:GetUserThumbnailAsync(a.Player.UserId, tType, tSize)
    a.ESP['Img'] = Draw('Image', {
        Data = game:HttpGet(headShot),
        Rounding = 60,
        Size = 48,
        Visible = self.Enabled and self.Names
    })
    a.ESP['Distance'] = Draw('Text', {
        Size = (self.Thickness*6),
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
    for i,v in (Library.Enabled and pairs or ipairs)(Library.Objects) do
        if v.up then
            local s,e = pcall(v.up, v)
            if not s then print(e) end
        end
    end
end)
return Library