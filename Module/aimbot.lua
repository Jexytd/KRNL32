--[[
    KESALAHAN - LIBRARY satu saja jadi settings no need
]]
getgenv().ManusiaIkan = {}
local Library = {
    Enabled = false,
    ShowFov = false,
    TeamCheck = false,
    WallCheck = false,
    FromMouse = false,
    FOV = 20,
    FOVColor = Color3.fromRGB(69,69,230),
    Smooth = 2,
    Target = 'Head',
    Object = {}
}
Library.__index = Library

do
    function Library:toggle(bool)
        self.Enabled = bool
    end

    function Library:setFov(n)
        self.FOV = n
    end

    function Library:showFov(bool)
        self.ShowFov = bool
    end

    function Library:setFovColor(c)
        self.FOVColor = c
    end

    function Library:setSmooth(n)
        self.Smooth = n
    end

    function Library:fromMouse(bool)
        self.FromMouse = bool
    end

    function Library:teamCheck(bool)
        self.TeamCheck = bool
    end

    function Library:wallCheck(bool)
        self.WallCheck = bool
    end

    function Library:setTarget(s)
        self.Target = s
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

if #ManusiaIkan > 0 then
    for _,v in pairs(ManusiaIkan) do
        if typeof(v) == 'userdata' then
            v:Remove()
        end
    end
end
Library.Object['Circle'] = Drawing.new('Circle')
table.insert(ManusiaIkan, Library.Object['Circle'])

function up(show)
    local MousePos = Vector2.new(Mouse.X, Mouse.Y + (game:GetService('GuiService'):GetGuiInset().Y))
    if Library.Object['Circle'] then
        Library.Object['Circle'].Transparency = 1
        Library.Object['Circle'].Color = Library.FOVColor
        Library.Object['Circle'].Visible = (Library.Enabled and show) or false
        Library.Object['Circle'].Thickness = 2
        Library.Object['Circle'].NumSides = 60
        Library.Object['Circle'].Radius = (Library.FOV*6)/2
        Library.Object['Circle'].Filled = false
        Library.Object['Circle'].Position = (not Library.FromMouse and CenterScreen) or MousePos
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
    local targetPart = targetPart or Library.Target -- MUST BE STRING
    local fov = fov or (Library.FOV*6)/2
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
                local targetpart = (targetPart == 'MultiHitbox' and v:FindFirstChildWhichIsA('BasePart')) or v:FindFirstChild(targetPart)
                if Library.TeamCheck and getTeams[v.Name] ~= true then
                    local _, OnScreen = worldToView(targetpart)
                    if OnScreen then
                        local targetPos = worldToView(targetpart)
                        local fovPos = (Library.FromMouse and worldToView(Mouse.Hit.p)) or Library.Object['Circle'].Position
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
                        local fovPos = (Library.FromMouse and worldToView(Mouse.Hit.p)) or Library.Object['Circle'].Position
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
                    if Library.Smooth ~= 0 then
                        mousemoverel((targetPos.X - mousePos.X)/Library.Smooth, (targetPos.Y - mousePos.Y)/Library.Smooth - 2)
                    else
                        mousemoverel((targetPos.X - mousePos.X), (targetPos.Y - mousePos.Y))
                    end
                end
            else
                if Library.Smooth ~= 0 then
                    mousemoverel((targetPos.X - mousePos.X)/Library.Smooth, (targetPos.Y - mousePos.Y)/Library.Smooth - 2)
                else
                    mousemoverel((targetPos.X - mousePos.X), (targetPos.Y - mousePos.Y))
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(v)
    if onteams[v.Name] then
        onteams[v.Name] = nil
    end
end)

game:GetService('RunService').Heartbeat:Connect(function()
    up(Library.ShowFov)
    if Library.Enabled then
        if getClosestFOV() then
            aimAt(getClosestFOV()[Library.Target], Library.WallCheck)
        end
    end
    game:GetService('RunService').RenderStepped:Wait()
end)

return Library