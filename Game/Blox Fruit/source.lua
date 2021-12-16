assert(_KRNL32_, 'Failed to load features!')
if type(ENGINE_l) ~= 'table' then
    return _KRNL32_[-math.huge][_KRNL32_[1][2]]('Library', ENGINE_l)
end

local Players = game:GetService('Players')
local Client = Players.LocalPlayer

local Windows = ENGINE_l

-- Unminified code here https://github.com/Jexytd/KRNL32/blob/master/Module/tp.lua
-- Old version code: https://pastebin.com/raw/i9FKyjvf (Before changing)
do
    setreadonly(table, false)
    --/ Change table.find '==' to string.match()
    function table.find(t, val, startindex)
        local startindex = startindex or 0
        local key = nil
        for i,v in pairs(t) do
            if (type(i) == 'number' and startindex <= i) and (v:match(val) or v == val) then
                key = i
                break
            elseif (type(i) == 'string' and i:match(val)) then
                key = i
                break
            end
        end
        return key
    end
    setreadonly(table, true)
    if not table.find(math, 'clamp') then function math.clamp(value,min,max) return (max <= value and max) or (value <= min and min) or (min <= value and value <= max and value); end; end
    function sumsof(a,b)if type(a)~='number'then return end;if type(b)~='number'then return end;local c={}if a<0 and b<0 then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and 0<=b then local d=b<a and'sub'or a<b and'add'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a-b;local f=a-e;table.insert(c,e)elseif d=='add'then local e=b-a;local f=a+e;table.insert(c,e)elseif d=='equal'then table.insert(c,0)end end;if a<0 and 0<=b then local d=a<b and'add'or a==b and'equal'table.insert(c,d)if d=='add'then local e=-a*2;local g=e;local f=a+e;local h=b-f;g=g+h;local i=a+g or f+h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end elseif 0<=a and b<0 then local d=b<a and'sub'or a==b and'equal'table.insert(c,d)if d=='sub'then local e=a*2;local g=e;local f=a-e;local h=f-b;g=g+h;local i=a-g or f-h;table.insert(c,g)elseif d=='equal'then table.insert(c,0)end end;return c end
    function tp(a)local b=game:GetService('Players').LocalPlayer;local c=b.Character;local d=c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')or c:FindFirstChildWhichIsA('BasePart')local e=math.huge;local f=CFrame.new(math.floor(a.X)+1,a.Y,math.floor(a.Z)+1)local g=false;repeat d=c.PrimaryPart or c:FindFirstChild('HumanoidRootPart')or c:FindFirstChildWhichIsA('BasePart')local h=d.Position;local i,j=unpack(sumsof(h.X,f.X))local k,l=unpack(sumsof(h.Z,f.Z))local m=math.clamp(j,-200,200)local n=math.clamp(l,-200,200)local o=Vector3.new(math.floor(h.X)+1,f.Y,math.floor(h.Z)+1)if i=='sub'then o=o-Vector3.new(m,0,0)elseif i=='add'then o=o+Vector3.new(m,0,0)end;if k=='sub'then o=o-Vector3.new(0,0,n)elseif k=='add'then o=o+Vector3.new(0,0,n)end;if i=='equal'and k=='equal'then g=true end;if not g then pcall(function()d.CFrame=CFrame.new(o.X,o.Y,o.Z)+Vector3.new(0,100,0)end)end;wait(0.5)until b:DistanceFromCharacter(Vector3.new(a.X,0,a.Z))<=500 or not d or g;local p=CFrame.new(a.p.X or a.X,a.p.Y or a.Y,a.p.Z or a.Z)d.CFrame=p*CFrame.new(0,30,0)end
end

xpcall(function()
    LFarm = false
    LFarm_Boss = false
    LBoss_Debounce = false

    local t2 = Windows:NewTab('Main')
    do
        local s1 = t2:NewSection('Farms')
        function LevelFarm()
            if not LBoss_Debounce then
               
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
            LFarm_table[2] = LFarm_Boss
        end)
    end
end, function(e)
    _KRNL32_[-math.huge][_KRNL32_[1][math.huge]]('Blox Fruit', e)
    lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)