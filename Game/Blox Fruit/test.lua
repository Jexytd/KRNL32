local lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard', true))()
local window = lib:NewWindow('test')
local section1 = window:NewSection('Main')

FARMING = false
FBOSS = false
BOSS_DEBOUNCE = false
CQUEST = ''
C2 = ''
local checkBoss;

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

function farm()
    local level = Client:FindFirstChild('Data') and Client.Data:FindFirstChild('Level').Value
    local module = require(game:GetService('ReplicatedStorage'):FindFirstChild('Quests'))
    local qtdata = {}

    for quest,tbl in pairs(module) do
        local i = 1
        for _,data in pairs(tbl) do
            local req = data['LevelReq']
            local task = data['Task']
            if req <= level then
                local temp = {}
                temp[1] = req;
                temp[2] = quest;
                temp[3] = i;
                temp[4] = {}
                for k,v in pairs(task) do
                    temp[4][1] = k;
                    temp[4][2] = v;
                    if v == 1 then
                        temp[4][3] = true
                    else
                        temp[4][3] = false
                    end
                end
                table.insert(qtdata, temp)
            end
            i = i + 1
        end
    end
    table.sort(qtdata, function(a,b) return a[1] < b[1] end)

    local target = {}
    local iter = 0
    for i=#qtdata,1,-1 do
        iter = i
        if FBOSS and not BOSS_DEBOUNCE and (workspace.Enemies:FindFirstChild(qtdata[i][4][1]) or game:GetService('ReplicatedStorage'):FindFirstChild(qtdata[i][4][1])) and qtdata[i][4][2] == 1 then
            if CQUEST ~= qtdata[i][4][1] then CQUEST = qtdata[i][4][1] end
            target[1] = qtdata[i][4][1]
            target[2] = qtdata[i][1]
            BOSS_DEBOUNCE = true
            break
        end
        if FBOSS and not BOSS_DEBOUNCE and qtdata[i][4][2] ~= 1 then
            if CQUEST ~= qtdata[i][4][1] then CQUEST = qtdata[i][4][1] end
            target[1] = qtdata[i][4][1]
            target[2] = qtdata[i][1]
            break
        end
        if not FBOSS and qtdata[i][4][2] ~= 1 then
            if CQUEST ~= qtdata[i][4][1] then CQUEST = qtdata[i][4][1] end
            target[1] = qtdata[i][4][1]
            target[2] = qtdata[i][1]
            break
        end
    end
    
    spawn(function()
        if FBOSS and not checkBoss then
            checkBoss = game:GetService('RunService').RenderStepped:Connect(function()
                if BOSS_DEBOUNCE then
                    if not workspace.Enemies:FindFirstChild(target[1]) or not game:GetService('ReplicatedStorage'):FindFirstChild(target) then
                        BOSS_DEBOUNCE = false
                        print('Boss in his rest right now! can\'t find it', DateTime.now():FormatLocalTime('LLLL','en-us'))
                    end
                end

                if not BOSS_DEBOUNCE or not LFARM or not FBOSS then
                    checkBoss:Disconnect()
                end
            end)
        end
    end)

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
        if CQUEST and C2 == '' then
            C2 = CQUEST
            game:GetService('ReplicatedStorage').Remotes.CommF_:InvokeServer('StartQuest', qtdata[iter][2], qtdata[iter][3])
        end
    end)

    local target = get(target[1])
    local tp = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/tp.lua', true))()
    if target then
        repeat
            local primary = target:FindFirstChild('HumanoidRootPart')
            local height = 30
            local ratio = Client:DistanceFromCharacter(primary.Position)
            if ratio > 250 then tp(primary.CFrame, 100, height, 0.7) end
            if ratio <= 250 then
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
        until not FARMING or not target or not target.Parent or target:FindFirstChildOfClass('Humanoid').Health <= 0
        pcall(function()
            if not Client.PlayerGui.Main.Quest.Visible then
                C2 = ''
            end
        end)
    end
end

section1:CreateToggle('farm', function(t)
    FARMING = t
    local sv;
    sv = game:GetService('RunService').RenderStepped:Connect(function()
        if FARMING == true then
            pcall(function()
                Client.Character.Humanoid:ChangeState(10)
                Client.Character.HumanoidRootPart.Velocity = Vector3.new()
            end)
        end
        if FARMING == false then
            sv:Disconnect()
        end
    end)
    while FARMING do
        local s,m = pcall(farm)
        if not s then return warn(m) end
        game:GetService('RunService').RenderStepped:wait()
    end
end)

section1:CreateToggle('bosses', function(t)
    FBOSS = t
end)