assert(_KRNL32_, 'Failed to load features!')
if type(ENGINE_l) ~= 'table' then
    return _KRNL32_[_KRNL32_[1][2]]('Library', ENGINE_l)
end

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Client = Players.LocalPlayer

local Windows = ENGINE_l

xpcall(function()
    LFarm = false
    LFarm_Boss = false
    LBoss_Debounce = false
    CQuest = ''
    CQ2 = ''
    TPAddition = 200
    TPDebounce = 0.6
    TPHeight = 100

    local Lcheck;

    local t2 = Windows:NewTab('Main')
    do
        local s1 = t2:NewSection('Farms')
        function LevelFarm()
            
            local Level = Client:FindFirstChild('Data') and Client.Data:FindFirstChild('Level').Value
            local Module = require(ReplicatedStorage:FindFirstChild('Quests'))
            local QTdata = {}

            for quest,tbl in pairs(Module) do
                local i = 1
                for _,data in pairs(tbl) do
                    local reqlvl = data['LevelReq']
                    local task = data['Task']
                    if reqlvl <= Level then
                        local tempData = {}
                        tempData[1] = reqlvl;
                        tempData[2] = quest;
                        tempData[3] = i; 
                        tempData[4] = {}
                        for k,v in pairs(task) do
                            tempData[4][1] = k;
                            tempData[4][2] = v;
                        end
                        table.insert(QTdata, tempData)
                    end
                    i = i + 1
                end
            end

            table.sort(QTdata, function(t1,t2) return t1[1] < t2[1] end)

            local Target = {}
            local Iteration = 0
            for i = #QTdata,1,-1 do
                Iteration = i;
                if LFarm_Boss and not LBoss_Debounce and (workspace.Enemies:FindFirstChild(QTdata[i][4][1]) or ReplicatedStorage:FindFirstChild(QTdata[i][4][1])) and QTdata[i][4][2] == 1 then
                    if CQuest ~= QTdata[i][4][1] then CQuest = QTdata[i][4][1] end
                    Target[1] = QTdata[i][4][1]
                    LBoss_Debounce = true
                    break
                end
                if LFarm_Boss and not LBoss_Debounce and QTdata[i][4][2] ~= 1 then
                    if CQuest ~= QTdata[i][4][1] then CQuest = QTdata[i][4][1] end
                    Target[1] = QTdata[i][4][1]
                    break
                end
                if not LFarm_Boss and QTdata[i][4][2] ~= 1 then
                    if CQuest ~= QTdata[i][4][1] then CQuest = QTdata[i][4][1] end
                    Target[1] = QTdata[i][4][1]
                    break
                end
            end

            if LFarm_Boss and not Lcheck then
                Lcheck = game:GetService('RunService').RenderStepped:Connect(function()
                    if LBoss_Debounce then
                        if not workspace.Enemies:FindFirstChild(Target[1]) or not ReplicatedStorage:FindFirstChild(Target[1]) then
                            LBoss_Debounce = false
                        end
                    end
                    if not LBoss_Debounce or not LFarm or not LFarm_Boss then
                        Lcheck:Disconnect()
                    end
                end)
            end

            local function get(name)
                local found = false
                local odist = math.huge
                local instance
        
                for _,mob in pairs(workspace.Enemies:GetChildren()) do
                    local newname = mob.Name:gsub('[Lv. %d+]', ''):gsub('[[]]', '')
                    if mob:IsA('Model') and newname == name and mob:FindFirstChild('HumanoidRootPart') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                        local ndist = Client:DistanceFromCharacter(mob.HumanoidRootPart.Position)
                        if ndist < odist then
                            found = true
                            instance = mob
                            odist = ndist
                            break
                        end
                    end
                end
        
                if not found then
                    for _,mob in pairs(game:GetService('ReplicatedStorage'):GetChildren()) do
                        local newname = mob.Name:gsub('[Lv. %d+]', ''):gsub('[[]]', '')
                        if mob:IsA('Model') and newname == name and mob:FindFirstChild('HumanoidRootPart') and mob:FindFirstChild('Humanoid') and mob.Humanoid.Health > 0 then
                            local ndist = Client:DistanceFromCharacter(mob.HumanoidRootPart.Position)
                            if ndist < odist then
                                found = true
                                instance = mob
                                odist = ndist
                                break
                            end
                        end
                    end
                end
        
                return instance
            end

            pcall(function()
                if CQuest and CQ2 == '' then
                    CQ2 = CQuest
                    ReplicatedStorage.Remotes.CommF_:InvokeServer('StartQuest', QTdata[Iteration][2], QTdata[Iteration][3])
                end
            end)

            local Target = get(Target[1])
            local TP = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/tp.lua', true))()
            if Target then
                repeat
                    local primary = Target:FindFirstChild('HumanoidRootPart')
                    local height = 30
                    local ratio = Client:DistanceFromCharacter(primary.Position)
                    if ratio > 500 then tp(primary.CFrame, TPAddition, LFarm, TPHeight, height, TPDebounce) end
                    if ratio <= 500 then
                        primary.Size = Vector3.new(50,60,50)
                        pcall(function() 
                            Client.Character.HumanoidRootPart.CFrame = primary.CFrame * CFrame.new(0,height,0)
                        end)
                        wait(os.clock()/os.time())
                        pcall(function()
                            if Client.Character:FindFirstChildOfClass('Tool') then
                                local vu = game:GetService('VirtualUser')
                                vu:Button1Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                                vu:Button1Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                            end
                        end)
                    end
                until not LFarm or not Target or not Target.Parent or Target:FindFirstChildOfClass('Humanoid').Health <= 0
                pcall(function()
                    if not Client.PlayerGui.Main.Quest.Visible then
                        CQ2 = ''
                    end
                end)
            end
        end

        s1:NewToggle('Auto Level Farm', 'Automatic farming mob with possible quest level', function(t)
            LFarm = t
            local s
            s = game:GetService('RunService').RenderStepped:Connect(function() if LFarm == true then pcall(function() Client.Character:FindFirstChildOfClass('Humanoid'):ChangeState(10); Client.Character.PrimaryPart.Velocity=Vector3.new(); end) end; if LFarm == false then s:Disconnect() end; end)
            while LFarm do
                local s,m = pcall(LevelFarm)
                if not s then return error(m); end
                game:GetService('RunService').RenderStepped:wait()
            end
        end)

        s1:NewToggle('Include Boss', 'When boss quest available', function(t)
            LFarm_Boss = t
        end)
        s1:NewLabel('When tp addition get high increase, please increase the debounce too or you will get tp\'ed back')
        s1:NewSlider("TP Addition", "Teleport (num) away from current distance per debounce", 900, 1, function(s)
            TPAddition = s
        end)
        s1:NewSlider("TP Debounce", "Increasing this will slowing the tp", 2, 0.1, function(s)
            TPDebounce = s
        end)
        s1:NewSlider('TP Height', 'Set height of tp when in progress/working', 1000, -200, function(s)
            TPHeight = s
        end)
    end
end, function(e)
    _KRNL32_[_KRNL32_[1][math.huge]]('Blox Fruit', e)
    lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)