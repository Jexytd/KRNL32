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

        local function grabQuest()
            local Data = Client:FindFirstChild('Data') or Client:WaitForChild('Data')
            local Level = Data.Level.Value

            local Remote = game:GetService('ReplicatedStorage').Remotes.CommF_
            local _,Quest = pcall(function() return Client.PlayerGui.Main:FindFirstChild('Quest') end)
            if not _ then return end
            if Quest.Visible == true then Remote:InvokeServer('AbandonQuest') end
            local Args = {'StartQuest', '', 1}
            local Get = (function()
                local module = require(game:GetService('ReplicatedStorage'):FindFirstChild('Quests'))
                local tbl = {}
                for quest,t in next, module do
                    local quest_index = 1
                    for _,t2 in next, t do
                        if rawget(t2, 'LevelReq') <= lvl then
                            table.insert(tbl, {rawget(t2, 'LevelReq'), quest, quest_index})
                        end
                        quest_index = quest_index + 1
                    end
                end
                table.sort(tbl, function(a,b) return a[1] < b[1] end)
                return tbl[#tbl]
            end)()
            if Get then
                Args[2] = Get[2]
                Args[3] = Get[3]
                pcall(function() Remote:InvokeServer(unpack(Args)) end)
            end
        end
        function LevelFarm()
            local _,Quest = pcall(function() return Client.PlayerGui.Main:FindFirstChild('Quest') end)
            if Quest.Visible ~= true then
                grabQuest()
            end

            print'attack'
        end

        s1:NewToggle('Auto Level Farm', 'Automatic farming mob with possible quest level', function(t)
            LFarm = t
            local s
            s = game:GetService('RunService').RenderStepped:Connect(function()
                if LFarm == true then
                    pcall(function()
                        local char = Client.Character
                        local part = char.PrimaryPart or char:FindFirstChild('HumanoidRootPart')
                        for _,v in pairs(char:GetDescendants()) do
                            if v:IsA('BasePart') and v.CanCollide == true then
                                v.CanCollide = false
                            end
                        end
                        char:FindFirstChildOfClass('Humanoid'):ChangeState(10)
                        part.Velocity = Vector3.new()
                    end)
                end
                if LFarm == false then
                    s:Disconnect()
                end
            end)
        end)
        while LFarm do
            local s,m = pcall(LevelFarm)
            if not s then
                print('[#]:',m)
            end
            game:GetService('RunService').RenderStepped:wait()
        end
    end
end, function(e)
    sendErr('Blox Fruit', e)
    lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)