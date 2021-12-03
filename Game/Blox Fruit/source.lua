assert(sendErr, 'Failed to load features!')
if type(ENGINE_l) ~= 'table' then
    return sendErr('Library', ENGINE_l)
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = ENGINE_l

do
    function sumsof(a,b)if type(a)~='number'then return end;if type(b)~='number'then return end;local c={}if a<0 and b<0 then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and 0<=b then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end end;if a<0 and 0<=b then local d=a<b and'add'or a==b and'equal'table.insert(c,d)if d=='add'then local e=-a*2;local g=e;local f=a+e;local h=b-f;g=g+h;local i=a+g or f+h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and b<0 then local d=b<a and'sub'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a*2;local g=e;local f=a-e;local h=f-b;g=g+h;local i=a-g or f-h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end end;return c end
    
    function tp(cf)
        local Character = Client.Character
        local TVector = cf.p or cf
        local Ratio = Client:DistanceFromCharacter(TVector)
    
        local RootPart = Character.PrimaryPart or Character:FindFirstChild('HumanoidRootPart') or Character:FindFirstChildWhichIsA('BasePart')
        local CVector = RootPart.Position
    
        local CX,CZ = CVector.X, CVector.Z
        local X,Y,Z = TVector.X, TVector.Y, TVector.Z
        local methodX, sumX = unpack(sumsof(CX,X))
        local methodZ, sumZ = unpack(sumsof(CZ,Z))
    
        -- local Base = Instance.new('Part')
        -- Base.Parent = workspace
        -- Base.Size = Vector3.new(10, 1, 10)
        -- Base.CFrame = RootPart.CFrame
        -- Base.Anchored = true
    
        local Index = 0
        repeat
            local minmax1 = math.clamp(sumX, -200, 200)
            local minmax2 = math.clamp(sumZ, -200, 200)
            local NVector = Vector3.new(minmax1, Y/4, minmax2)
    
            if methodX == 'sub' then
                NVector = NVector - Vector3.new(minmax1,0,0)
            end
            if methodZ == 'sub' then
                NVector = NVector - Vector3.new(0,0,minmax2*1.7)
            end
    
            pcall(function()
                if RootPart.Position.Y <= 999 then
                    RootPart.CFrame = RootPart.CFrame + Vector3.new(0, 1000, 0)
                end
                RootPart.CFrame = RootPart.CFrame + NVector
                -- Base.CFrame = RootPart.CFrame - Vector3.new(0, 5, 0)
            end)
    
            wait(0.5)
            if Index == 1 then
                sumX = sumX - minmax1
                sumZ = sumZ - minmax2
                Index = 0
            end
            Index = Index + 1
            local XL,ZL = (cf.p.X or cf.X), (cf.p.Z or cf.Z)
            local Ratvector = Vector3.new(XL,0,ZL)
            Ratio = Client:DistanceFromCharacter(Ratvector)
        until Ratio <= 500 or not RootPart or (sumX == 0 and sumZ == 0)
        -- Base:Destroy()
        local cf2 = CFrame.new((cf.p.X or cf.X), (cf.p.Y or cf.Y), (cf.p.Z or cf.Z))
        RootPart.CFrame = cf2
    end
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
                        table.insert(tbl, {rawget(t2, 'Name'), quest, quest_index})
                    end
                    if not Level then
                        table.insert(tbl, {rawget(t2, 'Name'), quest, quest_index})
                    end
                    quest_index = quest_index + 1
                end
            end
            if Level then
                table.sort(tbl, function(a,b) return a[1] < b[1] end)
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
                return Get[1]
            end
        end
        function LevelFarm()
            local _,Quest = pcall(function() return Client.PlayerGui.Main:FindFirstChild('Quest') end)
            local x
            if Quest.Visible ~= true then
                x = grabQuest()
            end

            if Quest.Visible and x then
                local Text = Quest.Container.QuestTitle.Title.Text:lower():gsub('defeat %d+', ''):gsub('^%s+', ''):gsub('%s+$', ''):split(' ')
                local Enemies = Text[1]
                local Stats = Text[2]:sub(2, #Text[2]-1):split('/')
                --/ Theres a better way to check enemies, like 
                if Enemies:match(x) then
                    local Current,Max = tonumber(Stats[1]), tonumber(Stats[2])
                    local Target = (function()
                        local pass = true
                        local distance = math.huge
                        local o = nil
                        for _,v in pairs(workspace.Enemies:GetChildren()) do
                            if v:IsA('Model') and v.Name:lower():match(x) and (v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')) and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                                local Part = v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')
                                local isPrim = (v.PrimaryPart and true) or false
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
                                if v:IsA('Model') and v.Name:lower():match(x) and (v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')) and v:FindFirstChild('Humanoid') and v.Humanoid.Health > 0 then
                                    local Part = v.PrimaryPart or v:FindFirstChild('HumanoidRootPart')
                                    local isPrim = (v.PrimaryPart and true) or false
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
                        local Ratio = Client:DistanceFromCharacter(first.Position)
                        if Ratio > 500 then tp(Target:FindFirstChild('HumanoidRootPart').CFrame) end
                        Ratio = Client:DistanceFromCharacter(first.Position) -- update the ratio
                        if Ratio <= 500 then
                            Target:FindFirstChild('HumanoidRootPart').Size = Vector3.new(30,30,30)
                            repeat
                                pcall(function()
                                    Client.Character.HumanoidRootPart.CFrame = Target:FindFirstChild('HumanoidRootPart').CFrame * CFrame.new(0, 10, 0)
                                end)
                                wait(os.clock()/os.time())
                                pcall(function()
                                    print('click')
                                end)
                            until Current == Max or not LFarm or not Quest.Visible or not Target
                        else
                            tp(first.CFrame)
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
                        Client.Character:FindFirstChildOfClass('Humanoid'):ChangeState(11)
                        Client.Character.PrimaryPart.Velocity = Vector3.new()
                    end)
                end
                if LFarm == false then
                    s:Disconnect()
                end
            end)
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