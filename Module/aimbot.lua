getgenv().AimbotSettings = getgenv().AimbotSettings or {
    Enabled = false,
    ShowFov = false,
    FOV = 60,
    FOVColor = Color3.fromRGB(69,69,230),
    Smooth = 0,
    Target = 'Head',
    TeamCheck = false,
    WallCheck = false,
    FromMouse = false,
}
local Library = {}
Library.__index = Library

do
    function Library:Toggle(bool)
        AimbotSettings.Enabled = bool
    end

    function Library:SetFov(n)
        AimbotSettings.FOV = n
    end

    function Library:ShowFov(bool)
        AimbotSettings.ShowFov = bool
    end

    function Library:setFovColor(c)
        AimbotSettings.FOVColor = c
    end

    function Library:setSmooth(n)
        AimbotSettings.Smooth = n
    end

    function Library:fromMouse(bool)
        AimbotSettings.FromMouse = bool
    end

    function Library:teamCheck(bool)
        AimbotSettings.TeamCheck = bool
    end

    function Library:wallCheck(bool)
        AimbotSettings.WallCheck = bool
    end

    function Library:setTarget(str)
        AimbotSettings.Target = str
    end
end

local Service = setmetatable({}, {
    __index = function(t,k)
        return game:GetService(k)
    end,
    __newindex = function(t,k,v)
        t[k] = v
    end
})

local Players = Service.Players
local Client = Players.LocalPlayer
local Mouse = Client:GetMouse()
local CurrentCamera = workspace.CurrentCamera

local CenterScreen = (CurrentCamera.ViewportSize)/2
FieldView = Drawing.new('Circle')
function up()
    local MousePos = Vector2.new(Mouse.X, Mouse.Y + (game:GetService('GuiService'):GetGuiInset().Y))
    if FieldView then
        FieldView.Transparency = 1
        FieldView.Visible = ShowFov or false
        FieldView.Color = Color3.fromRGB(69,69,230)
        FieldView.Thickness = 2
        FieldView.NumSides = 13
        FieldView.Radius = (AimbotSettings.FOV*6)/2
        FieldView.Filled = false
        FieldView.Position = (not AimbotSettings.FromMouse and CenterScreen) or MousePos
    end
end

local function worldToView(o)
    local o = o
    if typeof(o) == 'CFrame' then
        o = o.p
    elseif typeof(o) == 'Instance' then
        o = o.Position
    end
    return CurrentCamera:WorldToViewportPoint(o)
end

onteams = {}
function getClosestFOV(char_folder, targetPart, fov)
    local char_folder = char_folder
    local targetPart = targetPart or AimbotSettings.Target -- MUST BE STRING
    local fov = fov or (AimbotSettings.FOV*6)/2
    local getTeams = (function()
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= Client then
                if v.Team == Client.Team then
                    onteams[v.Name] = true
                else
                    onteams[v.Name] = false
                end
            end
        end
        return onteams
    end)()
    local s,children = pcall(function()
        if char_folder and char_folder:IsDescendantOf(workspace) then
            return char_folder:GetChildren()
        end
        if Client.Character then
            return Client.Character.Parent:GetChildren()
        end
    end)
    if s and children and type(children) == 'table' then
        local closestDist = fov 
        local target = nil
        for _,v in pairs(children) do
            if v:IsA('Model') and Players:GetPlayerFromCharacter(v) and v ~= Client.Character and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                local targetpart = v:FindFirstChild(targetPart) or v.PrimaryPart
                if AimbotSettings.TeamCheck and getTeams[v.Name] ~= true then
                    local _, OnScreen = worldToView(targetpart)
                    if OnScreen then
                        local targetPos = worldToView(targetpart)
                        local fovPos = (AimbotSettings.FromMouse and worldToView(Mouse.Hit.p)) or FieldView.Position
                        local dist = (Vector2.new(fovPos.X, fovPos.Y) - Vector2.new(targetPos.X, targetPos.Y)).magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = v
                        end
                    end
                else
                    local _, OnScreen = worldToView(targetpart)
                    if OnScreen then
                        local targetPos = worldToView(targetpart)
                        local fovPos = (AimbotSettings.FromMouse and worldToView(Mouse.Hit.p)) or FieldView.Position
                        local dist = (Vector2.new(fovPos.X, fovPos.Y) - Vector2.new(targetPos.X, targetPos.Y)).magnitude
                        if dist < closestDist then
                            closestDist = dist
                            target = v
                        end
                    end
                end
            end
        end
        return target
    end
end

function aimAt(o,wallcheck)
    if not Players:GetPlayerFromCharacter(o.Parent) then return print(o, 'are not Player Character!') end
    if not o.Parent or not o then return print(o, 'is not found! maybe health <= 0?') end
    if o then
        local wallcheck = wallcheck or false
        local _, OnScreen = worldToView(o)
        if OnScreen then
            local mousePos = worldToView(Mouse.Hit.p)
            local targetPos = worldToView(o)
            if wallcheck then
                local origin = CurrentCamera.CFrame.p
                local newRay = Ray.new(origin,  o.Position - origin)
                local ignore = {Client.Character, CurrentCamera, o, o.Parent}
                for _,v in pairs(o.Parent:GetChildren()) do
                    if v:IsA('Accessory') or v:IsA('Accoutrement') then
                        if not table.find(ignore, v) then
                            table.insert(ignore, v)
                        end
                    end 
                end
                local Hit,_ = workspace:FindPartOnRayWithIgnoreList(newRay, ignore)
                if not Hit then
                    mousemoverel((targetPos.X - mousePos.X)/AimbotSettings.Smooth, (targetPos.Y - mousePos.Y)/AimbotSettings.Smooth - 2)
                end
            else
                mousemoverel((targetPos.X - mousePos.X)/AimbotSettings.Smooth, (targetPos.Y - mousePos.Y)/AimbotSettings.Smooth - 2)
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(v)
    if onteams[v.Name] then
        onteams[v.Name] = nil
    end
end)

game:GetService('RunService').RenderStepped:Connect(function()
    up()

    if Enabled and getClosestFOV() then
        aimAt(getClosestFOV()[AimbotSettings.Target], AimbotSettings.WallCheck)
    end
    game:GetService('RunService').RenderStepped:Wait()
end)

return Library