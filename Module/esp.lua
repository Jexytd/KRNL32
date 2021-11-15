Library = {
    Enabled = false,
    Boxes = false,
    HP = false,
    Username = false,
    Distance = false,
    Tracer = false,
    ESPType = 'Dynamic',

    BoxType = 'Default',
    HPType = 'Bar',
    TracerType = 'FromCharacter',
    UsernamePos = 'Top',
    DistancePos = 'Bottom',
    HPPos = 'Top',

    Thickness = 2,
    TextSize = 16,
    Color = Color3.fromRGB(255,255,255),
    Objects = {}
}
Library.__index = Library

do
    function Library:toggle(t)
        self.Enabled = t
    end
    function Library:showBox(t)
        self.Boxes = t
    end
    function Library:showHP(t)
        self.HP = t
    end
    function Library:showUsername(t)
        self.Username = t
    end
    function Library:showDistance(t)
        self.Distance = t
    end
    function Library:showTracer(t)
        self.Tracer = t
    end

    function Library:setESPType(t)
        self.ESPType = t
    end
    function Library:setBoxType(t)
        self.BoxType = t
    end
    function Library:setHPType(t)
        self.HPType = t
    end
    function Library:setTracerType(t)
        self.TracerType = t
    end

    function Library:setUsernamePos(t)
        self.UsernamePos = t
    end
    function Library:setDistancePos(t)
        self.DistancePos = t
    end
    function Library:setHPPos(t)
        self.HPPos = t
    end

    function Library:setTextSize(n)
        self.TextSize = n
    end
    function Library:setThickness(n)
        self.Thickness = n
    end
    function Library:setColor(c)
        self.Color = c
    end
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local CurrentCamera = workspace.CurrentCamera

local function draw(userdata, properties)
    local object = Drawing.new(userdata)
    local properties = properties or {}
    for k,v in pairs(properties) do
        object[k] = v
    end
    return object
end

Base = {}
Base.__index = Base

function Base:Remove()
    Library.Objects[self.Object] = nil
    for i in pairs(self.Data) do
        if type(v) == 'table' then
            for k,v2 in pairs(v) do
                v[k].Visible = false
                v[k]:Remove()
                self.Data[i] = nil
            end
        else
            self.Data[i].Visible = false
            self.Data[i]:Remove()
            self.Data[i] = nil
        end
    end
end

BoxType = {
    ['Default']= draw('Quad', {
        Thickness=Library.Thickness,
        Color=Library.Color,
        Visible=Library.Enabled and Library.Boxes
    }), 
    ['Corner']= {
        ['TR1'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['TR2'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['TL1'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['TL2'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['BL1'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['BL2'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['BR1'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
        ['BR2'] = draw('Line', {
            Thickness=Library.Thickness,
            Color=Library.Color,
            Visible=Library.Enabled and Library.Boxes
        }),
    }
}
HPType = {
    ['Default']= draw('Text', {
        Color=Library.Color,
        Visible=Library.Enabled and Library.HP
    }), 
    ['Bar']= draw('Quad', {
        Thickness=Library.Thickness,
        Color=Library.Color,
        Visible=Library.Enabled and Library.HP
    })
}

function Base:Update()
    if (not self.PrimaryPart) then return warn(self.Name .. ' not have PrimaryPart') end

    local cf = self.PrimaryPart.CFrame
    local size = self.Size or self.PrimaryPart.Size
    local CenterScreen = (CurrentCamera.ViewportSize)/2
    
    if self.Data['HP'] ~= HPType[Library.HPType] then
        self.Data['HP'] = HPType[Library.HPType]
    end
    if self.Data['Box'] ~= BoxType[Library.BoxType] then
        self.Data['Box'] = BoxType[Library.BoxType]
    end

    local Box,HP,Username,Distance,Tracer do
        Box = self.Data['Box']
        HP = self.Data['HP']
        Username = self.Data['Username']
        Distance = self.Data['Distance']
        Tracer = self.Data['Tracer']
    end
    local worldToView = function(o)
        local o = o
        if typeof(o) == 'CFrame' then
            o = o.p
        elseif typeof(o) == 'Instance' then
            o = o.Position
        end
        if typeof(o) ~= 'Vector3' then return warn('Something went wrong when converting') end
        return CurrentCamera:WorldToViewportPoint(o)
    end

    local locs
    if Library.ESPType == 'Static' then
        locs = {
            ['Top'] = cf + Vector3.new(0, size.Y, 0),
            ['Bottom'] = cf + Vector3.new(0, -size.Y, 0),
            ['Left'] = cf + Vector3.new(size.X/2, 0, 0),
            ['Right'] = cf + Vector3.new(-size.X/2, 0, 0),
            ['TopLeft'] = cf + Vector3.new(size.X/2,size.Y, 0),
            ['TopRight'] = cf + Vector3.new(-size.X/2,size.Y, 0),
            ['BottomLeft'] = cf + Vector3.new(size.X/2,-size.Y, 0),
            ['BottomRight'] = cf + Vector3.new(-size.X/2,-size.Y, 0),
        }
    elseif Library.ESPType == 'Dynamic' then
        locs = {
            ['Top'] = cf * CFrame.new(0, size.Y, 0),
            ['Bottom'] = cf * CFrame.new(0, -size.Y, 0),
            ['Left'] = cf * CFrame.new(size.X/2, 0, 0),
            ['Right'] = cf * CFrame.new(-size.X/2, 0, 0),
            ['TopLeft'] = cf * CFrame.new(size.X/2,size.Y, 0),
            ['TopRight'] = cf * CFrame.new(-size.X/2,size.Y, 0),
            ['BottomLeft'] = cf * CFrame.new(size.X/2,-size.Y, 0),
            ['BottomRight'] = cf * CFrame.new(-size.X/2,-size.Y, 0),
        }
    end

    if (Box and HP and Username and Distance and Tracer) then
        if Library.Username then
            local p,v = worldToView(locs[Library.UsernamePos])
            if v then
                Username.Visible = true
                Username.Color = Library.Color
                Username.Size = Library.TextSize
                Username.Position = p 
                Username.Center = true
                Username.Outline = true
                Username.Text = self.Name or 'Loading...'
            else
                Username.Visible = false
            end
        else
            Username.Visible = false
        end

        if Library.Distance then
            local client_part = Client.Character and (Client.Character.PrimaryPart or Client.Character:FindFirstChild('HumanoidRootPart') or Client.Character:FindFirstChildWhichIsA('BasePart'))
            local p,v = worldToView(locs[Library.DistancePos])
            if v then
                Distance.Visible = true
                Distance.Color = Library.Color
                Distance.Size = Library.TextSize
                Distance.Position = p 
                Distance.Center = true
                Distance.Outline = true
                Distance.Text = tostring(math.floor((client_part.CFrame.p - cf.p).magnitude)) .. 'm away' or 'Loading...'
            else
                Distance.Visible = false
            end
        else
            Distance.Visible = false
        end

        if Library.Tracer then
            local client_part = Client.Character and (Client.Character.PrimaryPart or Client.Character:FindFirstChild('HumanoidRootPart') or Client.Character:FindFirstChildWhichIsA('BasePart'))
            local tracer_locs = {
                ['FromScreen'] = Vector2.new(CurrentCamera.ViewportSize.X/2,CurrentCamera.ViewportSize.X/1.5),
                ['FromMouse'] = Vector2.new(Mouse.X, Mouse.Y + (game:GetService('GuiService'):GetGuiInset().Y)),
                ['FromCharacter'] = client_part.CFrame
            }
            local p,v = worldToView(cf)
            local p2
            if Library.TracerType == 'FromCharacter' then
                p2 = worldToView(tracer_locs[Library.TracerType])
            end
            if v then
                Tracer.Visible = true
                Tracer.Thickness = Library.Thickness
                Tracer.Color = Library.Color
                Tracer.From = Vector2.new(p.X, p.Y)
                Tracer.To = p2 or tracer_locs[Library.TracerType]
            else
                Tracer.Visible = false
            end
        else
            Tracer.Visible = false
        end

        if Library.Boxes then
            local _,onScreen = worldToView(cf)
            if onScreen then   
                if Library.BoxType == 'Corner' then
                    print('Work in Progress')
                elseif Library.BoxType == 'Default' then
                    local p,v = worldToView(locs['TopRight'])
                    local p2,v2 = worldToView(locs['TopLeft'])
                    local p3,v3 = worldToView(locs['BottomLeft'])
                    local p4,v4 = worldToView(locs['BottomRight'])
                    if (v or v2 or v3 or v4) then
                        Box.Visible = true
                        Box.Thickness = Library.Thickness
                        Box.Color = Library.Color
                        Box.PointA = p
                        Box.PointB = p2
                        Box.PointC = p3
                        Box.PointD = p4
                    end
                end
            else
                if type(Box) == 'table' then
                    for i in pairs(Box) do
                        if type(Box[i]) == 'userdata' then
                            Box[i].Visible = false
                        end
                    end
                else
                    Box.Visible = false
                end
            end
        else
            if type(Box) == 'table' then
                for i in pairs(Box) do
                    if type(Box[i]) == 'userdata' then
                        Box[i].Visible = false
                    end
                end
            else
                Box.Visible = false
            end
        end

        if Library.HP then
            local _,onScreen = worldToView(cf)
            if onScreen then
                if Library.HPType == 'Bar' then
                    local Humanoid = self.Object:FindFirstChildOfClass('Humanoid')
                    local Health
                    if Humanoid then
                        Health = Humanoid.Health / Humanoid.MaxHealth
                    end
                    local locs2
                    if Library.HPPos == 'Top' or Library.HPPos == 'Bottom' then
                        if Library.ESPType == 'Static' then
                            locs2 = {
                                locs[Library.HPPos] + Vector3.new(size.X*Health, (Library.HPPos == 'Top' and (size.Y/4) or Library.HPPos == 'Bottom' and (-size.Y/4)),0),
                                locs[Library.HPPos] + Vector3.new(-size.X*Health, (Library.HPPos == 'Top' and (size.Y/4) or Library.HPPos == 'Bottom' and (-size.Y/4)),0)
                            }
                        elseif Library.ESPType == 'Dynamic' then
                            locs2 = {
                                locs[Library.HPPos] * CFrame.new(size.X*Health, (Library.HPPos == 'Top' and (size.Y/4) or Library.HPPos == 'Bottom' and (-size.Y/4)),0),
                                locs[Library.HPPos] * CFrame.new(-size.X*Health, (Library.HPPos == 'Top' and (size.Y/4) or Library.HPPos == 'Bottom' and (-size.Y/4)),0)
                            }
                        end
                    else
                        if Library.ESPType == 'Static' then
                            locs2 = {
                                cf + Vector3.new((Library.HPPos == 'Left' and (size.X/1.5) or Library.HPPos == 'Right' and (-size.X/1.5)), size.Y*Health, 0),
                                cf + Vector3.new((Library.HPPos == 'Left' and (size.X/1.5) or Library.HPPos == 'Right' and (-size.X/1.5)), -size.Y*Health, 0)
                            }
                        elseif Library.ESPType == 'Dynamic' then
                            locs2 = {
                                cf * CFrame.new((Library.HPPos == 'Left' and (size.X/1.5) or Library.HPPos == 'Right' and (-size.X/1.5)), size.Y*Health, 0),
                                cf * CFrame.new((Library.HPPos == 'Left' and (size.X/1.5) or Library.HPPos == 'Right' and (-size.X/1.5)), -size.Y*Health, 0)
                            }
                        end
                        
                    end
                    local p,v = worldToView(locs2[1])
                    local p2,v2 = worldToView(locs2[2])
                    if (v or v2) then
                        HP.Visible = true
                        HP.Color = Library.Color
                        HP.PointA = p
                        HP.PointB = p
                        HP.PointC = p2
                        HP.PointD = p2
                    else
                        HP.Visible = false
                    end
                elseif Library.HPType == 'Default' then
                    local Humanoid = self.Object:FindFirstChildOfClass('Humanoid')
                    local Health,MaxHealth
                    if Humanoid then
                        Health = Humanoid.Health
                        MaxHealth = Humanoid.MaxHealth
                    end
                    local p,v = worldToView(locs[Library.HPPos])
                    if v then
                        HP.Visible = true
                        HP.Color = Library.Color
                        HP.Center = true
                        HP.Outline = true
                        HP.Position = p
                        HP.Text = tostring(Health) .. '//' .. tostring(MaxHealth) or '???/???'
                    else
                        HP.Visible = false
                    end
                end
            else
                HP.Visible = false
            end
        else
            HP.Visible = false
        end
    end
end

function Library:Add(o,options)
    if not o.Parent then return warn(o,'has no parent') end
    
    local data = setmetatable({
        Name = options.Name or o.Name,
        Type = 'Classic',
        Color = options.Color or self.Color,
        Size = options.Size,
        Object = o,
        IsTeam = options.IsTeam,
        Player = options.Player or Players:GetPlayerFromCharacter(o),
        PrimaryPart = options.PrimaryPart or (o:IsA('Model') and ( o.PrimaryPart or o:FindFirstChild('HumanoidRootPart') or o:FindFirstChildWhichIsA('BasePart') )) or (o:IsA('BasePart') and o),
        Data = {}
    },Base)
    if self.Objects[o] then self.Objects[o]:Remove() end
    data['Data']['Username'] = draw('Text', {
        Color = data.Color or self.Color,
        Visible = self.Enabled and self.Username
    })
    data['Data']['Distance'] = draw('Text', {
        Color = data.Color or self.Color,
        Visible = self.Enabled and self.Distance
    })
    data['Data']['Tracer'] = draw('Line', {
        Thickness = self.Thickness,
        Color = data.Color or self.Color,
        Visible = self.Enabled and self.Tracer
    })
    self.Objects[o] = data

    o.AncestryChanged:Connect(function(_,parent)
        if not parent then data:Remove() end
    end)
    o:GetPropertyChangedSignal('Parent'):Connect(function()
        if not o.Parent then data:Remove() end
    end)
    local hum = o:FindFirstChildOfClass('Humanoid')
    if hum then
        hum.Died:Connect(function()
            data:Remove()
        end)
    end
    local plr = Players:GetPlayerFromCharacter(o)
    if plr then
        Players.PlayerRemoving:Connect(function(v)
            if v == plr then
                data:Remove()
                if self.Objects[o] then self.Objects[o]:Remove() end
            end
        end)
    end
    return data
end

local function CharAdded(char)
    local p = Players:GetPlayerFromCharacter(char)
    if not char:FindFirstChild("HumanoidRootPart") then
        local ev
        ev = char.ChildAdded:Connect(function(c)
            if c.Name == "HumanoidRootPart" then
                ev:Disconnect()
                Library:Add(char, {
                    Name = p.Name,
                    Player = p,
                    PrimaryPart = c,
                })
            end
        end)
    else
        Library:Add(char, {
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
        if v.Update then
            local s,e = pcall(v.Update, v)
            if not s then warn('[]:',e,v.Object:GetFullName()) end
        end
    end
end)

return Library