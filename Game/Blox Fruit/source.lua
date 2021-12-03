assert(sendErr, 'Failed to load features!')
if type(ENGINE_l) ~= 'table' then
    return sendErr('Library', ENGINE_l)
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = ENGINE_l

-- Unminified code here https://github.com/Jexytd/KRNL32/blob/master/Module/tp.lua
do
    function sumsof(a,b)if type(a)~='number'then return end;if type(b)~='number'then return end;local c={}if a<0 and b<0 then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and 0<=b then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end end;if a<0 and 0<=b then local d=a<b and'add'or a==b and'equal'table.insert(c,d)if d=='add'then local e=-a*2;local g=e;local f=a+e;local h=b-f;g=g+h;local i=a+g or f+h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and b<0 then local d=b<a and'sub'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a*2;local g=e;local f=a-e;local h=f-b;g=g+h;local i=a-g or f-h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end end;return c end
    function tp(a)local b=game:GetService('Players').LocalPlayer;local c=b.Character;local d=c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')or c:FindFirstChildWhichIsA('BasePart')local e=math.huge;local f=CFrame.new(math.floor(a.X)+1,a.Y,math.floor(a.Z)+1)local g=false;repeat d=c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')or c:FindFirstChildWhichIsA('BasePart')local h=d.Position;local i,j=unpack(sumsof(h.X,f.X))local k,l=unpack(sumsof(h.Z,f.Z))local m=math.clamp(j,-200,200)local n=math.clamp(l,-200,200)local o=Vector3.new(math.floor(h.X)+1,f.Y,math.floor(h.Z)+1)if i=='sub'then o=o-Vector3.new(m,0,0)elseif i=='add'then o=o+Vector3.new(m,0,0)end;if k=='sub'then o=o-Vector3.new(0,0,n)elseif k=='add'then o=o+Vector3.new(0,0,n)end;if i=='equal'and k=='equal'then g=true end;if not g then pcall(function()d.CFrame=CFrame.new(o.X,o.Y,o.Z)+Vector3.new(0,100,0)end)end;wait(0.5)until b:DistanceFromCharacter(Vector3.new(a.X,0,a.Z))<=500 or not d or g;local p=CFrame.new(a.p.X or a.X,a.p.Y or a.Y,a.p.Z or a.Z)d.CFrame=p*CFrame.new(0,30,0)end
end

xpcall(function()
    LFarm = false

    local t2 = Windows:NewTab('Main')
    do
        local s1 = t2:NewSection('Farms')

        local function quests(Level)
            local module = require(game:GetService('ReplicatedStorage'):FindFirstChild('Quests'))
            local tbl = {}
            for quest,t in next, module do
                local quest_index = 1
                for _,t2 in next, t do
                    if Level and rawget(t2, 'LevelReq') <= Level then
                        table.insert(tbl, {rawget(t2, 'Name'), quest, quest_index, rawget(t2, 'LevelReq')})
                    end
                    if not Level then
                        table.insert(tbl, {rawget(t2, 'Name'), quest, quest_index, rawget(t2, 'LevelReq')})
                    end
                    quest_index = quest_index + 1
                end
            end
            if Level then
                table.sort(tbl, function(a,b) return a[4] < b[4] end)
            end
            return tbl[#tbl]
        end

        local function grabQuest()
            local Data = Client:FindFirstChild('Data') or Client:WaitForChild('Data')
            local Level = Data.Level.Value

            local Remote = game:GetService('ReplicatedStorage').Remotes.CommF_
            local _,Quest = pcall(function() return Client.PlayerGui.Main:FindFirstChild('Quest') end)
            if not _ then return end
            if Quest.Visible == true then Remote:InvokeServer('AbandonQuest') end
            local Args = {'StartQuest', '', 1}
            local Get = quests(Level)
            if Get then
                Args[2] = Get[2]
                Args[3] = Get[3]
                pcall(function() Remote:InvokeServer(unpack(Args)) end)
            end
            return Get[1]
        end
        function LevelFarm()
            if not getgenv().x then 
                getgenv().x = grabQuest()
                if not getgenv().x2 then
                    getgenv().x2 = getgenv().x[2]
                end
            end
            if getgenv().x[2] ~= getgenv().x2 then
                getgenv().x = nil
                getgenv().x2 = nil
                return
            end

            local _,Quest = pcall(function() return Client.PlayerGui.Main:FindFirstChild('Quest') end)
            if Quest.Visible then
                local Text = Quest.Container.QuestTitle.Title.Text:lower():gsub('defeat %d+', ''):gsub('^%s+', ''):gsub('%s+$', ''):split(' ')
                local Enemies = Text[1]
                -- local Stats = Text[2]:sub(2, #Text[2]-1):split('/')
                if getgenv().x:lower() ~= Enemies then 
                    getgenv().x = nil
                    game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('AbandonQuest')
                    return
                end
                --/ Theres a better way to check enemies 
                if Enemies:match(x:lower()) then
                    local Target = (function()
                        local pass = true
                        local distance = math.huge
                        local o = nil
                        for _,v in pairs(workspace.Enemies:GetChildren()) do
                            local c = v.Name:gsub('[Lv. %d+]', ''):gsub('[[]]', ''):lower()
                            if v:IsA('Model') and x:lower():match(c) and v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                                local Part = v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')
                                local newdist = Client:DistanceFromCharacter(Part.Position)
                                if newdist < distance then
                                    pass = false
                                    distance = newdist
                                    o = v
                                    break
                                end
                            end
                        end
                        if pass then
                            for _,v in pairs(game:GetService('ReplicatedStorage'):GetChildren()) do
                                local c = v.Name:gsub('[Lv. %d+]', ''):gsub('[[]]', ''):lower()
                                if v:IsA('Model') and x:lower():match(c) and v:FindFirstChild('HumanoidRootPart') and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                                    local Part = v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')
                                    local newdist = Client:DistanceFromCharacter(Part.Position)
                                    if newdist < distance then
                                        pass = false
                                        distance = newdist
                                        o = v
                                        break
                                    end
                                end
                            end
                        end
                        return o
                    end)()
                    if Target then
                        repeat
                            local Part = Target:FindFirstChild('HumanoidRootPart')
                            local Ratio = Client:DistanceFromCharacter(Part.Position)
                            if Ratio > 500 then tp(Part.CFrame) end
                            if Ratio <= 500 then
                                Part.Size = Vector3.new(50,60,50)
                                Part.Transparency = 0.8
                                pcall(function()
                                    Client.Character.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 30, 0)
                                end)
                                wait(os.clock()/os.time())
                                pcall(function()
                                    local vu = game:GetService('VirtualUser')
                                    vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                                    wait((os.clock()/os.time())/60)
                                    vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                                end)
                            else
                                tp(Part.CFrame)
                            end
                            wait(os.clock()/os.time())
                        until not Target or not LFarm or Target:FindFirstChildOfClass('Humanoid').Health <= 0
                        if not Quest.Visible then
                            getgenv().x = nil
                        end
                    end
                end
            end
        end

        s1:NewToggle('Auto Level Farm', 'Automatic farming mob with possible quest level', function(t)
            LFarm = t
            local s
            s = game:GetService('RunService').RenderStepped:Connect(function()
                if LFarm == true then
                    pcall(function()
                        Client.Character:FindFirstChildOfClass('Humanoid'):ChangeState(10)
                        Client.Character.PrimaryPart.Velocity = Vector3.new()
                    end)
                end
                if LFarm == false then
                    s:Disconnect()
                end
            end)
            if getgenv().x and getgenv().x[2] ~= getgenv().x2 then getgenv().x = nil; getgenv().x2 = nil; end
            while LFarm do
                local s,m = pcall(LevelFarm)
                if not s then
                    print('[#]:',m)
                end
                game:GetService('RunService').RenderStepped:wait()
            end
        end)
    end
end, function(e)
    sendErr('Blox Fruit', e)
    lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)