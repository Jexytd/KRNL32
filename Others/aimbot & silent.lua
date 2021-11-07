local client = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = client:GetMouse()
local UIS = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local function myCharacter()
    for i, v in ipairs(workspace.Characters:GetChildren()) do
        if (v.Body.Head.Position - camera.CFrame.p).magnitude < 1 then return v end 
    end
end

local function onTeam(x)
    for i, v in ipairs(client.PlayerGui:GetChildren()) do 
        if v.Name == "NameGui" then 
            if v.Adornee:IsDescendantOf(x) then return true end    
        end
    end
end

--Aimbot
local function closestPlayer(fov)
    local closest = fov
    local target = nil
    for i, v in ipairs(workspace.Characters:GetChildren()) do 
        if v ~= myCharacter() and myCharacter() and not onTeam(v) then
            local _, onscreen = camera:WorldToScreenPoint(v.Body.Head.Position)
            if onscreen then
                local targetPos = camera:WorldToViewportPoint(v.Body.Head.Position)
                local mousePos = camera:WorldToViewportPoint(mouse.Hit.p)
                local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(targetPos.X, targetPos.Y)).magnitude
                if dist < closest then 
                    closest = dist 
                    target = v 
                end
            end
        end
    end
    return target
end
local function aimAt(pos,smooth)
    local targetPos = camera:WorldToScreenPoint(pos)
    local mousePos = camera:WorldToScreenPoint(mouse.Hit.p)
    mousemoverel((targetPos.X-mousePos.X)/smooth,(targetPos.Y-mousePos.Y)/smooth)
end
local isAiming = false 
mouse.Button2Down:connect(function() isAiming=true end)
mouse.Button2Up:connect(function() isAiming=false end)
--Silent Aim 
local silentFovObject = Drawing.new("Circle")
silentFovObject.Radius = 300 
silentFovObject.Filled = true 
silentFovObject.Transparency = 0.4 
silentFovObject.Position = Vector2.new(0,0)
silentFovObject.Visible = true
silentFovObject.Color = _G.BBconfig.fovColor
local silentHead = Drawing.new("Circle")
silentHead.Radius = 10
silentHead.Filled = true 
silentHead.Transparency = 0.4 
silentHead.Position = Vector2.new(0,0)
silentHead.Visible = false
silentHead.Color = Color3.fromRGB(255,0,0)
local isShooting = false 

local silentAimEnabled = true
local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall
gmt.__namecall = newcclosure(function(self, ...)
    local Args = {...}
    local method = getnamecallmethod()
    if tostring(self) == "Projectiles" and tostring(method) == "FireServer" and closestPlayer(_G.BBconfig.fovAmount) and silentAimEnabled then
        Args[3] = closestPlayer(_G.BBconfig.fovAmount).Hitbox.Head
        Args[4] = closestPlayer(_G.BBconfig.fovAmount).Hitbox.Head.Position
        return self.FireServer(self, unpack(Args))
    end
    return oldNamecall(self, ...)
end)
--Fly
local velPart = Instance.new("BodyVelocity") 
local flySettings = {
    speed = _G.BBconfig.flySpeed,
    enabled = false,
    ["mf"] = {[true] = Vector3.new(math.huge,math.huge,math.huge), [false] = Vector3.new()},
    multCF = CFrame.new(0,0,0)
}
UIS.InputBegan:Connect(function(input)
    local newCF = flySettings.multCF
    if input.KeyCode == Enum.KeyCode.F then 
        flySettings.enabled = not flySettings.enabled
        velPart.MaxForce = flySettings["mf"][flySettings.enabled]
    elseif input.KeyCode == Enum.KeyCode.W then
        newCF = CFrame.new(newCF.X, newCF.Y, -5)
    elseif input.KeyCode == Enum.KeyCode.S then
        newCF = CFrame.new(newCF.X, newCF.Y, 5)
    elseif input.KeyCode == Enum.KeyCode.A then
        newCF = CFrame.new(-5, newCF.Y, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.D then
        newCF = CFrame.new(5, newCF.Y, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.Space then
        newCF = CFrame.new(newCF.X, 5, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.LeftShift then
        newCF = CFrame.new(newCF.X, -5, newCF.Z)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = true 
    end
    flySettings.multCF = newCF
end)
UIS.InputEnded:Connect(function(input)
    local newCF = flySettings.multCF
    if input.KeyCode == Enum.KeyCode.W and newCF.Z == -5 then
        newCF = CFrame.new(newCF.X, newCF.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.S and newCF.Z == 5 then
        newCF = CFrame.new(newCF.X, newCF.Y, 0)
    elseif input.KeyCode == Enum.KeyCode.A and newCF.X == -5 then
        newCF = CFrame.new(0, newCF.Y, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.D and newCF.X == 5 then
        newCF = CFrame.new(0, newCF.Y, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.Space and newCF.Y == 5 then
        newCF = CFrame.new(newCF.X, 0, newCF.Z)
    elseif input.KeyCode == Enum.KeyCode.LeftShift and newCF.Y == -5 then
        newCF = CFrame.new(newCF.X, 0, newCF.Z)
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = false 
    end
    flySettings.multCF = newCF
end)
velPart.MaxForce = Vector3.new(0,0,0)

--ESP
local boxes = {}
local function newLine()
    local x = Drawing.new("Line")
    x.To = Vector2.new(2,2)
    x.From = Vector2.new(0,0)
    x.Visible = false 
    x.Thickness = 2 
    x.Color = _G.BBconfig.espColor
    return x
end

local function newBox(x)
    local box = {["Character"] = x, newLine(), newLine(), newLine(), newLine()}
    table.insert(boxes,box)
end

workspace.Characters.ChildAdded:connect(function(x)
    if not onTeam(x) and x ~= myCharacter() then
        newBox(x)
    end
end)
for i, x in ipairs(workspace.Characters:GetChildren()) do 
    if not onTeam(x) and x ~= myCharacter() then
        newBox(x)
    end    
end
local function updateEsp()
    for i, v in ipairs(boxes) do 
        if not v["Character"]:IsDescendantOf(workspace) then 
            for i, x in ipairs(v) do x.Remove() end
            table.remove(boxes, i)    
        else 
            local character = v["Character"]
            local TL = camera:WorldToViewportPoint((character.Root.CFrame * CFrame.new(-2,3,0)).p)
            local TR = camera:WorldToViewportPoint((character.Root.CFrame * CFrame.new(2,3,0)).p)
            local BL = camera:WorldToViewportPoint((character.Root.CFrame * CFrame.new(-2,-5,0)).p)
            local BR = camera:WorldToViewportPoint((character.Root.CFrame * CFrame.new(2,-5,0)).p)
            v[1].From = Vector2.new(TL.X, TL.Y)
            v[1].To = Vector2.new(TR.X, TR.Y)
            v[2].From = Vector2.new(TR.X, TR.Y)
            v[2].To = Vector2.new(BR.X, BR.Y)
            v[3].From = Vector2.new(BR.X, BR.Y)
            v[3].To = Vector2.new(BL.X, BL.Y)
            v[4].From = Vector2.new(BL.X, BL.Y)
            v[4].To = Vector2.new(TL.X, TL.Y)
            local _, onscreen = camera:WorldToScreenPoint(character.Root.Position)
            if onTeam(v["Character"]) then onscreen = false end
            for i, x in ipairs(v) do x.Visible = onscreen end
        end
    end
end

--Main Loop
rs.RenderStepped:connect(function()
    --ESP 
    updateEsp()
    --Fly
    if myCharacter() then
        local character = myCharacter()
        if not velPart:IsDescendantOf(character) then velPart.Parent = character.Root end
        local old = flySettings.multCF 
        local newCF = character.Root.CFrame * CFrame.new(old.X,old.Y,old.Z)
        local newPos = newCF.p
        if newPos ~= character.Root.Position and newPos then 
            character.Root.Anchored = false
            velPart.Velocity = CFrame.new(character.Root.Position,newPos).LookVector * flySettings.speed
        elseif flySettings.enabled then
            character.Root.Anchored = true
        else 
            character.Root.Anchored = false
        end
    end
    --Aimbot
    local mousePos = camera:WorldToViewportPoint(mouse.Hit.p)
    silentFovObject.Position = Vector2.new(mousePos.X, mousePos.Y)
    if isAiming and closestPlayer(_G.BBconfig.fovAmount) then 
        aimAt(closestPlayer(_G.BBconfig.fovAmount).Hitbox.Head.Position, _G.BBconfig.aimbotSmoothness)
    end
    --Silent Aim 
    if isShooting and closestPlayer(_G.BBconfig.fovAmount) then 
        local pos = camera:WorldToViewportPoint(closestPlayer(_G.BBconfig.fovAmount).Hitbox.Head.Position)
        silentHead.Position = Vector2.new(pos.X, pos.Y)
        silentHead.Visible = true 
    else 
        silentHead.Visible = false
    end
end)
