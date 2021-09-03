ESP = {
    Enabled = false,

    Box = false,
    Name = false,
    Distance = false,
    Tracers = false,
    HealthBar = false,
    Bone = false,
  
    Teamate = false,
    WallCheck = false,
    TeamColor = false,

    Render = 1000,
    Radius = 6,
    Size = CFrame.new(4,4,0),
    Thickness = 2,
    TextSize = 16,
    WallColor = Color3.fromRGB(0, 255, 0),
    Color = Color3.fromRGB(255, 255, 255),

    Objects = {}
}

local Players,Client,Camera,Limbs,OldColor,IsLoaded,w do
    Players = game:GetService('Players')
    Client = Players.LocalPlayer
    Camera = workspace.CurrentCamera
    Limbs = {'LeftFoot','LeftHand','LeftLowerArm','LeftLowerLeg','LeftUpperArm','LeftUpperLeg','LowerTorso','RightFoot','RighthHand','RightLowerArm','RightUpperLeg','UpperTorso','Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'}
    OldColor = ESP.Color
    IsLoaded = game:IsLoaded()
    w = loadstring(game:HttpGet('https://raw.githubusercontent.com/PysephRBX/RBXWait/master/Source.lua'))()
end
repeat w() until IsLoaded and w;

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

function ESP:OnRender(p)
    local a = p or Players:GetPlayerFromCharacter(p)
    local a2 = a.Character and (a.Character.PrimaryPart or a.Character:FindFirstChild('HumanoidRootPart') or a.Character:FindFirstChildWhichIsA('BasePart'))
    return Client:DistanceFromCharacter(a2.Position) <= self.Render
end

function ESP:IsTeam(p)
    return (p and p.Team) == (Client and Client.Team)
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

    local nexts = true
    if self.Player and not ESP.Teamate and self.IsTeam then
        nexts = false
    end

    if not nexts then
        for i,v in pairs(self.Drawed) do
            if type(v) == 'table' then
                for k in pairs(v) do
                    v[k].Visible = false
                end
            else
                v.Visible = false
            end
        end
        return
    end

    local B,N,T,D,H,BN = self.Drawed.Box, self.Drawed.Name, self.Drawed.Tracer, self.Drawed.Distance, self.Drawed.HealthBar, self.Drawed.Bone
    if ESP:OnRender(self.Player) then
        local wtvp = function(x)
            return Camera:WorldToViewportPoint(x)
        end
        local cframe,size = self.PrimaryPart.CFrame,(self.Size or self.PrimaryPart.Size)
        local box_pos = {
            ['TopLeft'] = cframe * CFrame.new(size.X/2, size.Y, 0),
            ['TopRight'] = cframe * CFrame.new(-size.X/2, size.Y, 0),
            ['BottomLeft'] = cframe * CFrame.new(size.X/2, -size.Y, 0),
            ['BottomRight'] = cframe * CFrame.new(-size.X/2, -size.Y, 0)
        }

        local name_pos = cframe.p + Vector3.new(0, size.Y*1.5, 0)
        local tracer_pos = cframe * CFrame.new(0, -size.Y/3, 0)
        local distance_pos = cframe.p + Vector3.new(0, -size.Y*1.5, 0)

        if ESP.TeamColor then
            ESP.Color = self.Player.Team.TeamColor.Color
        end

        if ESP.WallCheck then
            local ray = Ray.new(Camera.CFrame.p, (self.PrimaryPart.Position - Camera.CFrame.p).unit * (ESP.Render * 2))
            local hit,pos = workspace:FindPartOnRayWithIgnoreList(ray, {Client.Character})
            if hit and hit:IsDescendantOf(self.Player.Character) then
                ESP.Color = ESP.WallColor
            else
                ESP.Color = ESP.Color
            end
        end

        if ESP.Box then
            local TR,v2 = wtvp(box_pos['TopRight'].p)
            local TL,v1 = wtvp(box_pos['TopLeft'].p)
            local BL,v3 = wtvp(box_pos['BottomLeft'].p)
            local BR,v4 = wtvp(box_pos['BottomRight'].p)
            if B then
                if (v1 or v2 or v3 or v4) then
                    B.Visible = true
                    B.PointA = TR
                    B.PointB = TL
                    B.PointC = BL
                    B.PointD = BR

                    B.Color = ESP.Color
                    B.Thickness = ESP.Thickness
                else
                    B.Visible = false
                end
            end
        else
            B.Visible = false
        end

        if ESP.Name then
            local p,v1 = wtvp(name_pos)
            if N then
                if v1 then
                    N.Visible = true
                    N.Center = true
                    N.Text = self.Player.Name
                    N.Position = p
                    N.Color = ESP.Color
                    N.Size = ESP.TextSize
                else
                    N.Visible = false
                end
            end
        else
            N.Visible = false
        end

        if ESP.Distance then
            local p,v1 = wtvp(distance_pos)
            if D then
                if v1 then
                    D.Visible = true
                    D.Center = true
                    D.Position = p
                    D.Text = math.floor((Camera.CFrame.p - cframe.p).magnitude) .."m away"
                    D.Color = ESP.Color
                    D.Size = ESP.TextSize
                else
                    D.Visible = false
                end
            end
        else
            D.Visible = false
        end

        if ESP.Tracers then
            local p,v1 = wtvp(tracer_pos.p)
            if T then
                if v1 then
                    T.Visible = true
                    T.To = p
                    T.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    T.Color = ESP.Color
                    T.Thickness = ESP.Thickness
                else
                    T.Visible = false
                end
            end
        else
            T.Visible = false
        end

        if ESP.HealthBar then
            local hum = self.Player.Character:FindFirstChildOfClass('Humanoid')
            local gp = function(a,b)
                return ((a/b)*100)
            end
            local health_pos = {
                ['A'] = box_pos['TopLeft'] * CFrame.new(hum.Health/1000, size.Y*1.5/2, 0),
                ['B'] = box_pos['TopRight'] * CFrame.new(-hum.Health/1000, size.Y*1.5/2, 0),
                ['C'] = box_pos['TopLeft'] * CFrame.new(hum.Health/1000, size.Y/1.5, 0),
                ['D'] = box_pos['TopRight'] * CFrame.new(-hum.Health/1000, size.Y/1.5, 0)
            }
            local A,v1 = wtvp(health_pos['A'].p)
            local B,v2 = wtvp(health_pos['B'].p)
            local C,v3 = wtvp(health_pos['C'].p)
            local D,v4 = wtvp(health_pos['D'].p)
            if H then
                if (v1 or v2 or v3 or v4) then
                    H.Visible = true
                    H.PointA = A - Vector3.new(hum.Health/100, 0, 0)  -- TOP RIGHT
                    H.PointB = B -- TOP LEFT
                    H.PointC = D -- BOTTOM LEFT
                    H.PointD = C - Vector3.new(hum.Health/100, 0, 0) -- BOTTOM RIGHT
                    H.Filled = true
                    H.Color = Color3.fromRGB(0,255,0)
                else
                    H.Visible = false
                end
            end
        else
            H.Visible = false
        end

        if ESP.Bone then
            function compare(a,b,c) -- param: 1. Torso 2. UpperTorso, which return upper torso if HAVE else return torso
                return b:match(a) and (c:FindFirstChild(b) or c:FindFirstChild(a))
            end
            for k in pairs(BN) do
                if k == 'Head' then
                    local p = self.Player.Character:FindFirstChild(k)
                    if p then
                        local pipes = BN[k..'_pipe']
                        local base_pipes = BN['Torso'] or BN['LowerTorso'] or BN['UpperTorso']
                        local pX, mX, pY, mY;
                        if base_pipes then
                            pX, mX = (base_pipes.From and typeof(base_pipes.From) == 'Vector2' and base_pipes.From.X), (base_pipes.To and typeof(base_pipes.To) == 'Vector2' and base_pipes.To.X)
                            pY, mY = (base_pipes.From and typeof(base_pipes.From) == 'Vector2' and base_pipes.From.Y), (base_pipes.To and typeof(base_pipes.To) == 'Vector2' and base_pipes.To.Y)
                        end

                        local locs = p.CFrame
                        local pos,v1 = wtvp(locs.p)
                        if v1 then
                            BN[k].Visible = true

                            BN[k].Position = pos
                            BN[k].Radius = ESP.Radius
                            BN[k].NumSides = 12
                            if base_pipes then
                                pipes.Visible = true
                                pipes.From = Vector2.new(pX,mY)
                                pipes.To = pos
                                pipes.Color = ESP.Color
                                pipes.Thickness = ESP.Thickness
                            end

                            BN[k].Thickness = self.Thickness
                            BN[k].Color = ESP.Color
                        else
                            BN[k].Visible = false 
                            pipes.Visible = false
                        end
                    end
                elseif k ~= 'Head' then
                    local p = self.Player.Character:FindFirstChild(k)
                    if p then
                        local pipes = BN[k..'_pipe']
                        local base_pipes = BN['Torso'] or BN['LowerTorso'] or BN['UpperTorso']
                        local pX, mX, pY, mY;
                        if base_pipes then
                            pX, mX = (base_pipes.From and typeof(base_pipes.From) == 'Vector2' and base_pipes.From.X), (base_pipes.To and typeof(base_pipes.To) == 'Vector2' and base_pipes.To.X)
                            pY, mY = (base_pipes.From and typeof(base_pipes.From) == 'Vector2' and base_pipes.From.Y), (base_pipes.To and typeof(base_pipes.To) == 'Vector2' and base_pipes.To.Y)
                        end

                        local front,back = p.CFrame.UpVector, -p.CFrame.UpVector
                        local locs1,locs2 = p.CFrame * front, p.CFrame * back
                        local pos,v1 = wtvp(locs1) -- front
                        local pos2,v2 = wtvp(locs2) -- below
                        if (v1 or v2) then
                            BN[k].Visible = true
                            BN[k].From = pos2
                            BN[k].To = pos

                            if base_pipes then
                                pipes.Visible = true
                                if k:match('Leg') then
                                    pipes.From = Vector2.new(pos.X, pos.Y)
                                    pipes.To = Vector2.new(pX,pY)
                                elseif k:match('Arm') then
                                    pipes.From = Vector2.new(pos.X, pos.Y)
                                    pipes.To = Vector2.new(pX,mY)
                                end
                                pipes.Color = ESP.Color
                                pipes.Thickness = ESP.Thickness
                            end

                            
                            BN[k].Color = ESP.Color
                            BN[k].Thickness = ESP.Thickness
                        else 
                            BN[k].Visible = false
                            pipes.Visible = false
                        end
                    end
                end
            end
        else
            for k,v in pairs(BN) do
                v.Visible = false
            end
        end
    else
        for k,v in pairs(BN) do
            v.Visible = false
        end
        B.Visible = false
        N.Visible = false
        T.Visible = false
        D.Visible = false
        H.Visible = false
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

    Box.Drawed['Box'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Box
    })
    Box.Drawed['Name'] = Draw('Text', {
        Color = Box.Color,
        Center = true,
        Outline = true,
        Size = ESP.TextSize,
        Visible = self.Enabled and self.Name
    })
    Box.Drawed['Distance'] = Draw('Text', {
        Color = Box.Color,
        Center = true,
        Outline = true,
        Size = ESP.TextSize,
        Visible = self.Enabled and self.Distance
    })
    Box.Drawed['Tracer'] = Draw('Line', {
        Thickness = self.Thickness,
        Color = self.Color,
        Visible = self.Enabled and self.Tracers
    })
    Box.Drawed['HealthBar'] = Draw('Quad', {
        Thickness = self.Thickness,
        Color = Color3.new(0, 255, 0),
        Filled = true,
        Visible = self.Enabled and self.HealthBar
    })
    Box.Drawed['Bone'] = {}
    for _,Limb in pairs(Limbs) do
        local c = (Box.Player and Box.Player.Character)
        local p = c:FindFirstChild(Limb)
        if p then
            if Limb == 'Head' then
                Box.Drawed['Bone'][Limb] = Draw('Circle', {
                    Thickness = self.Thickness,
                    Color = self.Color,
                    NumSides = 12,
                    Radius = 5,
                    Visible = self.Enabled and self.Bone
                })
                Box.Drawed['Bone'][Limb..'_pipe'] = Draw('Line', {
                    Thickness = self.Thickness,
                    Color = self.Color,
                    Visible = self.Enabled and self.Bone
                })
            else
                Box.Drawed['Bone'][Limb] = Draw('Line', {
                    Thickness = self.Thickness,
                    Color = self.Color,
                    Visible = self.Enabled and self.Bone
                })
                Box.Drawed['Bone'][Limb..'_pipe'] = Draw('Line', {
                    Thickness = self.Thickness,
                    Color = self.Color,
                    Visible = self.Enabled and self.Bone
                })
            end
        end
    end
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
                    IsTeam = ESP:IsTeam(p)
                })
            end
        end)
    else
        ESP:Add(char, {
            Name = p.Name,
            Player = p,
            PrimaryPart = char.HumanoidRootPart,
            IsTeam = ESP:IsTeam(p)
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

return ESP