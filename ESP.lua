local ESP = {
    Enabled = false,
    Boxes = false,

    Color = Color3.fromRGB(255,255,255)
    Thickness = 2,
    BoxSize = Vector3.new(4, 6, 0)
}

local cam = workspace.CurrentCamera
local plrs = game:GetService("Players")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()

local V3new = Vector3.new
local WorldToViewportPoint = cam.WorldToViewportPoint

do
    function Drawing(object, properties)
        local new = Drawing.new(object);

        for i,v in pairs(properties or {}) do
            properties[i] = ;
        end
        return new
    end
end

local BoxBase = {}
BoxBase.__index = BoxBase

do
    function BoxBase:Remove()
        self.Object = nil
        for i,v in pairs(self.Components) do
            v.Visible = false
            v:Remove()
            self.Components[i] = nil
        end
    end

    function BoxBase:Update()
        if not BoxBase.Object then
            return self:Remove()
        end

        local color;

        if ESP.Highlighted == self.Object then
            color = ESP.HighlightColor
        else
            color = self.Color or ESP.Color
        end

        if ESP.Highlighted == self.Object then
            color = ESP.HighlightColor
        end

        local cf = self.PrimaryPart.CFrame
        local size = self.Size
        local locs = {
            TopLeft = cf * CFrame.new(size.X/2,size.Y/2,0),
            TopRight = cf * CFrame.new(-size.X/2,size.Y/2,0),
            BottomLeft = cf * CFrame.new(size.X/2,-size.Y/2,0),
            BottomRight = cf * CFrame.new(-size.X/2,-size.Y/2,0),
        }

        if ESP.Boxes then
            local TopLeft, Vis1 = WorldToViewportPoint(cam, locs.TopLeft.p)
            local TopRight, Vis2 = WorldToViewportPoint(cam, locs.TopRight.p)
            local BottomLeft, Vis3 = WorldToViewportPoint(cam, locs.BottomLeft.p)
            local BottomRight, Vis4 = WorldToViewportPoint(cam, locs.BottomRight.p)
    
            if self.Components.Quad then
                if Vis1 or Vis2 or Vis3 or Vis4 then
                    self.Components.Quad.Visible = true
                    self.Components.Quad.PointA = Vector2.new(TopRight.X, TopRight.Y)
                    self.Components.Quad.PointB = Vector2.new(TopLeft.X, TopLeft.Y)
                    self.Components.Quad.PointC = Vector2.new(BottomLeft.X, BottomLeft.Y)
                    self.Components.Quad.PointD = Vector2.new(BottomRight.X, BottomRight.Y)
                    self.Components.Quad.Color = color
                else
                    self.Components.Quad.Visible = false
                end
            end
        else
            self.Components.Quad.Visible = false
        end
    end
end

do
    function ESP:Add(object, options)
        if not workspace:IsAncestorOf(object) then
            return warn('Object parent aren\'t on workspace. Failed to add esp on', object)
        end

        local Box = setmetatable({
            Name = options.Name or object.Name,
            Color = options.Color,
            Size = options.Size or self.BoxSize,
            Objects = object,
            Components = {},
            PrimaryPart = options.PrimaryPart or object.ClassName == "Model" and (object.PrimaryPart or object:FindFirstChild("HumanoidRootPart") or object:FindFirstChildWhichIsA("BasePart")) or object:IsA("BasePart") and object,
        }, BoxBase)

        Box.Components["Quad"] = Drawing("Quad", {
            Thickness = self.Thickness,
            Color = color,
            Transparency = 1,
            Filled = false,
            Visible = self.Enabled and self.Boxes
        })

        object.AncestryChanged:Connect(function(_, parent)
            if parent == nil and ESP.AutoRemove ~= false then
                Box:Remove()
            end
        end)
        object:GetPropertyChangedSignal("Parent"):Connect(function()
            if object.Parent == nil and ESP.AutoRemove ~= false then
                Box:Remove()
            end
        end)

        local hum = object:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Died:Connect(function()
                if ESP.AutoRemove ~= false then
                    Box:Remove()
                end
            end)
        end

        return Box
    end
end

do
    local function CharAdded(char)
        local p = plrs:GetPlayerFromCharacter(char)
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
                PrimaryPart = char.HumanoidRootPart
            })
        end
    end
    local function PlayerAdded(p)
        p.CharacterAdded:Connect(CharAdded)
        if p.Character then
            coroutine.wrap(CharAdded)(p.Character)
        end
    end
    plrs.PlayerAdded:Connect(PlayerAdded)
    for i,v in pairs(plrs:GetPlayers()) do
        if v ~= plr then
            PlayerAdded(v)
        end
    end
    
    game:GetService("RunService").RenderStepped:Connect(function()
        cam = workspace.CurrentCamera
        for i,v in (ESP.Enabled and pairs or ipairs)(BoxBase.Objects) do
            if v.Update then
                local s,e = pcall(v.Update, v)
                if not s then warn("[EU]", e, v.Object:GetFullName()) end
            end
        end
    end)
end

return ESP;