ESP = {
    Enabled = true,

    Box = true,
    Healthbar = true,

    TypeBox = '3D',
    Thickness = 2,
    Color = Color3.fromRGB(255, 255, 255),
    Objects = {}
}

local Players,Client,Camera,IsLoaded,w do
    Players = game:GetService('Players')
    Client = Players.LocalPlayer
    Camera = workspace.CurrentCamera
    IsLoaded = game:IsLoaded()
end
repeat task.wait() until IsLoaded;

function Draw(a, b)
    local c = Drawing.new(a)
    local c2 = b or {}
    for k,v in ipairs(c2) do
        c[k] = v;
    end
    return c
end

function ESP:Toggle(bool)
    self.Enabled = bool
    if not bool then
        for i,v in pairs(self.Objects) do
            if v.Type == "Box" then --fov circle etc
                for i,v in pairs(v.Drawed) do
                    v.Visible = false
                end
            end
        end
    end
end

base = {}
base.__index = base

function base:Remove()
    ESP.Objects[self.Object] = nil
    for i,v in pairs(self.Drawed) do
        if type(v) == 'table' then
            for k,v2 in pairs(v) do
                v[k].Visible = false
                v[k]:Remove()
                self.Drawed[i] = nil
            end
        else
            self.Drawed[i].Visible = false
            self.Drawed[i]:Remove()
            self.Drawed[i] = nil
        end
    end
end

function base:Update()
    if not self.PrimaryPart then
        return self:Remove()
    end

    if ESP.TypeBox == 'Corners' and type(self.Drawed.Box) ~= 'table' then
        self.Drawed.Box = {}
        for i=1,8 do
            table.insert(self.Drawed.Box, Draw('Line', {
                Color = self.Color,
                Thickness = ESP.Thickness,
                Visible = ESP.Enabled and ESP.Box
            }))
        end
        return
    elseif ESP.TypeBox == 'Classic' and type(self.Drawed.Box) ~= 'userdata' then
        self.Drawed.Box = Draw('Quad', {
            Thickness = self.Thickness,
            Color = ESP.Color,
            Visible = ESP.Enabled and ESP.Box
        })
        return
    elseif ESP.TypeBox == '3D' and type(self.Drawed.Box) ~= 'userdata' then
        self.Drawed.Box = Draw('Quad', {
            Thickness = self.Thickness,
            Color = ESP.Color,
            Visible = ESP.Enabled and ESP.Box
        })
        return
    end
    
    local a,b = self.Drawed.Box, self.Drawed.Healthbar
    local wtvp = function(x)
        return Camera:WorldToViewportPoint(x)
    end
    if ESP.Enabled then
        local CF,Size = self.PrimaryPart.CFrame, self.PrimaryPart.Size
        if ESP.Box and ESP.TypeBox == 'Corners' then
            --// 8 Line = 1 CORNER = 2 LINE
            local p,v = wtvp(CF.p)
            if v then
                local locs = {
                    TR = CF + Vector3.new(-Size.X/2, Size.Y, 0),
                    TL = CF + Vector3.new(Size.X/2, Size.Y, 0),
                    BL = CF + Vector3.new(Size.X/2, -Size.Y, 0),
                    BR = CF + Vector3.new(-Size.X/2, -Size.Y, 0),
                }
                local t = {false, false}
                local i = 1
                local is1 = false
                local is2 = false
                local isMinus = false
                local c = coroutine.create(function()
                  for x=1,4 do
                    if not is1 and t[i] == false then
                      t[i] = true
                      is1 = true
                    end
                    coroutine.yield()
                    if is1 and t[i] == true then
                      t[i] = false
                    end
                    coroutine.yield()
                    if is1 then is1 = false end
                  end
                end)

                local c2 = coroutine.create(function()
                  for x=1,4 do
                    if not is2 and t[i] == false then
                      is2 = true
                    end
                    coroutine.yield()
                    if is2 and t[i] == false then
                      t[i] = true
                      is2 = false
                    end
                    coroutine.yield()
                    if not is2 and t[i] == true then
                      t[i] = false
                    end
                  end
                end)

                local vector;
                for j=1, 8 do
                  local getLocs = (function()
                    if j == 1 or j == 2 then
                        return locs.TR.p
                    elseif j == 3 or j == 4 then
                        return locs.TL.p
                    elseif j == 5 or j == 6 then
                        return locs.BL.p
                    elseif j == 7 or j == 8 then
                        return locs.BR.p
                    end
                  end)()
                  local Pos = wtvp(getLocs)
                  local Ratio = (Camera.CFrame.p - self.PrimaryPart.Position).magnitude
                  local Offset = math.clamp(1/Ratio*375, 2, 300)
                  if i == 1 then
                    coroutine.resume(c)
                  elseif i == 2 then
                    coroutine.resume(c2)
                  end
                  if a[1] == a[i] then
                    if j == 1 or j == 2 then
                        vector2 = Vector2.new(Pos.X + Offset, Pos.Y)
                    end
                    if j == 3 or j == 4 then
                        vector2 = Vector2.new(Pos.X - Offset, Pos.Y)
                    end
                    if j == 5 or j == 6 then
                        vector2 = Vector2.new(Pos.X - Offset, Pos.Y)
                    end
                    if j == 7 or j == 8 then
                        vector2 = Vector2.new(Pos.X + Offset, Pos.Y) 
                    end
                  elseif a[2] == a[i] then
                    if j == 1 or j == 2 then
                        vector2 = Vector2.new(Pos.X, Pos.Y + Offset)
                    end
                    if j == 3 or j == 4 then
                        vector2 = Vector2.new(Pos.X, Pos.Y + Offset)
                    end
                    if j == 5 or j == 6 then
                        vector2 = Vector2.new(Pos.X, Pos.Y - Offset)
                    end
                    if j == 7 or j == 8 then
                        
                        vector2 = Vector2.new(Pos.X, Pos.Y - Offset)
                    end
                  end
                  a[j].Visible = true
                  a[j].Color = ESP.Color
                  a[j].From = Vector2.new(Pos.X, Pos.Y)
                  a[j].To = vector2
                  i = i+1
                  if i > 2 then i = 1 end
                end
            else
                for I in pairs(a) do
                    a[I].Visible = false
                end
            end
        elseif ESP.Box and ESP.TypeBox == 'Classic' then
            local locs = {
                TR = CF + Vector3.new(-Size.X/2, Size.Y, 0),
                TL = CF + Vector3.new(Size.X/2, Size.Y, 0),
                BL = CF + Vector3.new(Size.X/2, -Size.Y, 0),
                BR = CF + Vector3.new(-Size.X/2, -Size.Y, 0),
            }
            local p1,v1 = wtvp(locs.TR.p)
            local p2,v2 = wtvp(locs.TL.p)
            local p3,v3 = wtvp(locs.BL.p)
            local p4,v4 = wtvp(locs.BR.p)
            if (v1 or v2 or v3 or v4) then
                a.Visible = true
                a.PointA = p1
                a.PointB = p2
                a.PointC = p3
                a.PointD = p4
                a.Color = ESP.Color
                a.Thickness = ESP.Thickness
            else
                a.Visible = false
            end
        elseif ESP.Box and ESP.TypeBox == '3D' then
            --: NEED 4 QUAD
            local locs = {
                TR = CF + Vector3.new(-Size.X/2, Size.Y, Size.Z/2), --/ z Size.Z/2 just give little back axis
                TL = CF + Vector3.new(Size.X/2, Size.Y, -Size.Z/2),
                BL = CF + Vector3.new(Size.X/2, -Size.Y, -Size.Z/2),
                BR = CF + Vector3.new(-Size.X/2, -Size.Y, Size.Z/2),
            }
            local p1,v1 = wtvp(locs.TR.p)
            local p2,v2 = wtvp(locs.TL.p)
            local p3,v3 = wtvp(locs.BL.p)
            local p4,v4 = wtvp(locs.BR.p)
            if (v1 or v2 or v3 or v4) then
                a.Visible = true
                a.PointA = p1
                a.PointB = p2
                a.PointC = p3
                a.PointD = p4
                a.Color = ESP.Color
                a.Thickness = ESP.Thickness
            else
                a.Visible = false
            end
        end

        if ESP.Healthbar then
            local Humanoid = self.Object:FindFirstChildOfClass('Humanoid')
            local Health
            if Humanoid then
                Health = Humanoid.Health / Humanoid.MaxHealth
            end
            local locs = {
                Top = CF + Vector3.new(-Size.X/1.5, Size.Y*Health, 0), 
                Bottom = CF + Vector3.new(-Size.X/1.5, -Size.Y*Health, 0)
            }
            local p1,v1 = wtvp(locs.Top.p)
            local p2,v2 = wtvp(locs.Bottom.p)
            if (v1 or v2) then
                b.Visible = true
                b.PointA = p1
                b.PointB = p1
                b.PointC = p2
                b.PointD = p2
                --local Color = game:GetService("CoreGui").ThemeProvider.TopBarFrame.RightFrame.HealthBar.HealthBar.Fill.ImageColor3
                b.Color = ESP.Color
                b.Thickness = ESP.Thickness
            else
                b.Visible = false
            end
        end
    else
        a.Visible = false
        b.Visible = false
    end
end

function ESP:Add(object, options)
    if not object.Parent then return warn(object, ' has no parent') end

    local Box = setmetatable({
        Name = options.Name or object.Name,
        Type = 'Box',
        Color = self.Color or options.Color,
        Size = options.Size or self.Size,
        Object = object,
        IsTeam = options.IsTeam,
        Player = options.Player or Players:GetPlayerFromCharacter(object),
        PrimaryPart = options.PrimaryPart or object.ClassName == 'Model' and (object.PrimaryPart or object:FindFirstChild('HumanoidRootPart') or object:FindFirstChildWhichIsA('BasePart')) or object:IsA('BasePart') and object,
        Drawed = {}
    }, base)

    if self.Objects[object] then
        self.Objects[object]:Remove()
    end

    --[[
    Box.Drawed['Box'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Box
    })
    ]]--
    Box.Drawed['Healthbar'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = Box.Color,
        Visible = self.Enabled and self.Healthbar
    })
    self.Objects[object] = Box

    object.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            Box:Remove()
        end
    end)
    object:GetPropertyChangedSignal("Parent"):Connect(function()
        if object.Parent == nil then
            Box:Remove()
        end
    end)

    local hum = object:FindFirstChildOfClass("Humanoid")
	if hum then
        hum.Died:Connect(function()
            Box:Remove()
		end)
    end

    return Box
end

local function CharAdded(char)
    local p = Players:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                ESP:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c,
                })
            end
        end)
    else
        ESP:Add(char, {
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
    for i,v in (ESP.Enabled and pairs or ipairs)(ESP.Objects) do
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn("[EU]", e, v.Object:GetFullName()) end
        end
    end
end)