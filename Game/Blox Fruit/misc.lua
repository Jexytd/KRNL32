function CollectData()
    getgenv().Gamefunctions = {}
    for _,v in pairs(getgc()) do
        if type(v) == 'function' and getfenv(v).script.Parent == game:GetService('Players').LocalPlayer.Character then
            local c = getconstants(v)
            if table.find(c, '_G') and #c > 0 then
                table.insert(Gamefunctions, v)
            end
        end
    end
    print('[!]: All misc game function has been collected!')
end

if not getgenv().Gamefunctions or #getgenv().Gamefunctions <= 0 then
    CollectData()
end

local Humanoid = game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid') or game:GetService('Players').LocalPlayer.Character:WaitForChild('Humanoid')\
Humanoid.Died:Connect(function()
    CollectData()
end)

local Config = {
    [1] = {
        ['LengthData'] = 104,
        [1] = {83,20}
    },
    [2] = {
        ['LengthData'] = 73,
        [1] = {31,-1},
        [2] = {49,-1}
    },
}

for _,Data in pairs(Config) do
    for _,v in pairs(Gamefunctions) do
        local c = getconstants(v)
        if #c == Data['LengthData'] then
            for i=1,#Data do
                setconstant(v, Data[i][1], Data[i][2])
            end
            break
        end
    end
end