assert(sendErr, 'Failed to load features!')
if type(ENGINE_l) ~= 'table' then
    return sendErr('Library', ENGINE_l)
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = ENGINE_l
local t1 = Windows:NewTab('Home')
local s1 = t1:NewSection('Status')

s1:NewLabel('Welcome, ' .. Client.Name)
local timmy = s1:NewLabel('Current Time')
local timmy2 = s1:NewLabel('Playing Time')
local timmy3 = s1:NewLabel('Server Time')
local timmy4 = s1:NewLabel('FPS')
game:GetService('RunService').Heartbeat:Connect(function()
    do
        local date = os.date("*t")
        local hour = (date.hour) % 24
        local ampm = hour < 12 and "AM" or "PM"
        local ts = string.format("Current Time: %02i:%02i %s", ((hour - 1) % 12) + 1, date.min, ampm)
        if timmy then
            timmy:UpdateLabel(ts)
        end
    end

    do
        local t = workspace.DistributedGameTime or time()
        local seconds = math.floor(t) % 60
        local mins = math.floor(t/60)
        local hours = math.floor(mins/60)
        local ts = ('Playing Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy2 then
            timmy2:UpdateLabel(ts)
        end
    end

    do
        local t = workspace:GetServerTimeNow()
        local seconds = math.floor(t) % 60
        local mins = (math.floor(t) % 3600) / 60
        local hours = (math.floor(t) % 86400) / 3600
        local ts = ('Server Time: %02i:%02i:%02i'):format(hours,mins,seconds)
        if timmy3 then
            timmy3:UpdateLabel(ts)
        end
    end

    do
        local fps = workspace:GetRealPhysicsFPS()
        local ts = ('FPS: %02i'):format(fps)
        if timmy4 then
            timmy4:UpdateLabel(ts)
        end
    end
    game:GetService('RunService').RenderStepped:Wait()
end)

xpcall(function()
    local t2 = Windows:NewTab('Farms')
    --/ Items Sections /--
    do
        local s1 = t2:NewSection('Items') 
        local function GetObj(folder)
            local o
            local d = math.huge
            for _,part in pairs(folder:GetChildren()) do
                if part:IsA('Part') and part.Name == 'SpawnLocation' then
                    for _,object in pairs(part:GetChildren()) do
                        local object = (object:IsA('Model') and (object.PrimaryPart or object:FindFirstChildWhichIsA('BasePart'))) or object
                        local nd = Client:DistanceFromCharacter(object.Position)
                        if nd < d then
                            nd = d
                            o = object
                        end
                    end
                end
            end
            return o
        end

        local toggle1 = false
        s1:NewToggle('Auto Collect All Items', 'Automaticly collect items on map', function(t)
            toggle1 = t 
            local NoClip;
            NoClip = game:GetService('RunService').RenderStepped:Connect(function()
                if toggle1 == true then
                    pcall(function() Client.Character:FindFirstChildOfClass('Humanoid'):ChangeState(11) end)
                end
                if toggle1 == false then
                    NoClip:Disconnect()
                end
            end)
            while toggle1 do
                local target = (function()
                    local ancestor = workspace:FindFirstChild("ItemSpawns")
                    for _,folder in pairs(ancestor:GetChildren()) do
                        return GetObj(folder)
                    end
                    return false
                end)()
                if target then
                    repeat
                        pcall(function()
                            Client.Character.PrimaryPart.CFrame = target.CFrame + Vector3.new(0, 0, -6)
                        end)
                        wait(os.clock()/os.time())
                        pcall(function()
                            local proximity = (function()
                                for _,v in pairs(target:GetChildren()) do
                                    if v:IsA('ProximityPrompt') or v.ClassName == 'ProximityPrompt' then
                                        return v
                                    end
                                end
                                return false
                            end)()
                            if proximity then
                                fireproximityprompt(proximity, 0, true)
                            end
                        end)
                    until not target or not target.Parent or not toggle1
                end
                game:GetService('RunService').RenderStepped:Wait()
            end
        end)
    end
end, function(e)
    sendErr('A Universal Time', e)
    lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)