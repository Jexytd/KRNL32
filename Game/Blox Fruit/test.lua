local lib = loadstring(game:HttpGet('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard', true))()
local window = lib:NewWindow('test')
local section1 = window:NewSection('Main')
local window2 = lib:NewWindow('misc')
local section2 = window2:NewSection('Main')

FARMING = false
FBOSS = false
BOSS_DEBOUNCE = false
CQUEST = ''
C2 = ''
local checkBoss;

MAUTO = false
GEPPO1 = false
GEPPO2 = false
DODGE1 = false
DODGE2 = false
Config = {
    [1] = {
        ['LengthData'] = 104,
        ['Name'] = 'Dodge',
        [1] = {83,20},
        [2] = {85,3},
        [3] = {84,30},
        [4] = {32,0.01}
    },
    [2] = {
        ['LengthData'] = 73,
        ['Name'] = 'Geppo',
        [1] = {31,0.001},
        [2] = {49,0.001}
    },
}
OldConstantValue = {}
OldFunctions = false

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

function CollectData(character)
    print('[!]: Starting collecting data...')
    getgenv().Gamefunctions = {}
    getgenv().Updatedfunctions = {}
    for _,v in pairs(getgc()) do
        if type(v) == 'function' and getfenv(v).script.Parent == character then
            local c = getconstants(v)
            if table.find(c, '_G') and #c > 0 then
                table.insert(Gamefunctions, v)
            end
        end
    end
    
    for _,Data in pairs(Config) do
        for _,func in pairs(Gamefunctions) do
            local constant = getconstants(func)
            if #constant == Data['LengthData'] then
                Updatedfunctions[Data['Name']] = func
                break
            end
        end
    end

    local function getLength(t)
        local i = 0
        for _,v in pairs(t) do
            i = i + 1
        end
        return i
    end
    print('[!]: Data collected!')
    print('[Gamefunctions]:',Gamefunctions,'\n|-| Length:',getLength(Gamefunctions))
    print('[Updatedfunctions]:',Updatedfunctions,'\n|-| Length:',getLength(Updatedfunctions))
end

CollectData(Client.Character)

local function getConstantValue()
    if not Gamefunctions or #Gamefunctions <= 0 then return warn('This should not be printed!') end
    for _,Data in pairs(Config) do
        for _,func in pairs(Gamefunctions) do
            local constant = getconstants(func)
            if #constant == Data['LengthData'] then
                OldConstantValue[Data['Name']] = {}
                for i,v in pairs(Data) do
                    if type(i) == 'number' then
                        local value = getconstant(func, v[1])
                        OldConstantValue[Data['Name']][i] = value
                    end
                end
                break
            end
        end
    end
end

coroutine.wrap(getConstantValue)()
Client.CharacterAdded:Connect(function()
    OldFunctions = true
end)
local Humanoid = Client.Character:FindFirstChildOfClass('Humanoid') or Client.Character:WaitForChild('Humanoid')
if Humanoid then
    Humanoid.Died:Connect(function()
        OldFunctions = true
    end)
end

function getData(t,key,key2)
    for k,v in pairs(t) do
        if k == key and type(v) == 'table' then
            for k2,v2 in pairs(v) do
                if k2 == key2 then
                    return v2
                end
            end
        end
    end
end

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

local ev;
section2:CreateToggle('Auto Update', function(t)
    MAUTO = t
    spawn(function()
        while MAUTO do
            if OldFunctions then
                repeat wait() until Client.CharacterAdded or Client.Character
                CollectData(Client.Character)
                OldFunctions = false
            end
            wait()
        end
    end)
    if MAUTO then
        local function CharAdded(char)
            repeat 
                wait(0.1)
            until Client.Character
            CollectData(Client.Character)
        end
        ev = Client.CharacterAdded:Connect(CharAdded)
    end
    if not MAUTO then
        ev:Disconnect()
    end
end)
section2:CreateToggle('Geppo No Cooldown', function(t)
    GEPPO1 = t
    local index = 1
    while GEPPO1 do
        local f = getgenv().Updatedfunctions['Geppo']
        local i,v = getData(Config,2,index)[1],getData(Config,2,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Geppo']
    local i,v = getData(Config,2,index)[1],getData(OldConstantValue,'Geppo',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateToggle('Inf Geppo Jump', function(t)
    GEPPO2 = t
    local index = 2
    while GEPPO2 do
        local f = getgenv().Updatedfunctions['Geppo']
        local i,v = getData(Config,2,index)[1],getData(Config,2,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Geppo']
    local i,v = getData(Config,2,index)[1],getData(OldConstantValue,'Geppo',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateToggle('Dodge Velocity', function(t)
    DODGE1 = t
    local index = 1
    while DODGE1 do
        local f = getgenv().Updatedfunctions['Dodge']
        local i,v = getData(Config,1,index)[1],getData(Config,1,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Dodge']
    local i,v = getData(Config,1,index)[1],getData(OldConstantValue,'Dodge',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateToggle('Dodge Speed', function(t)
    DODGE2 = t
    local index = 2
    while DODGE2 do
        local f = getgenv().Updatedfunctions['Dodge']
        local i,v = getData(Config,1,index)[1],getData(Config,1,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Dodge']
    local i,v = getData(Config,1,index)[1],getData(OldConstantValue,'Dodge',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateToggle('Dodge Instant', function(t)
    DODGE2 = t
    local index = 3
    while DODGE2 do
        local f = getgenv().Updatedfunctions['Dodge']
        local i,v = getData(Config,1,index)[1],getData(Config,1,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Dodge']
    local i,v = getData(Config,1,index)[1],getData(OldConstantValue,'Dodge',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateToggle('Dodge No Cooldown', function(t)
    DODGE2 = t
    local index = 4
    while DODGE2 do
        local f = getgenv().Updatedfunctions['Dodge']
        local i,v = getData(Config,1,index)[1],getData(Config,1,index)[2]
        local c = getconstant(f,i)
        if f and c ~= v then
            setconstant(f,i,v)
        end
        game:GetService('RunService').RenderStepped:wait()
    end
    local f = getgenv().Updatedfunctions['Dodge']
    local i,v = getData(Config,1,index)[1],getData(OldConstantValue,'Dodge',index)
    if f then
        setconstant(f,i,v)
    end
end)

section2:CreateSlider("Dodge Velocity", 1, 20, Config[1][1][2], false, function(v)
    Config[1][1][2] = v
end)
section2:CreateSlider("Dodge Speed", 0.01, 3, Config[1][2][2], true, function(v)
    Config[1][2][2] = v
end)
section2:CreateSlider("Dodge Instant", 1, 30, Config[1][3][2], false, function(v)
    Config[1][3][2] = v
end)