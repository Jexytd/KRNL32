if type(setreadonly) == 'function' then
    setreadonly(table, false)
else
    warn('[#]: Please set setreadonly(<table> t, <bool> val) function!')
end
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
if type(setreadonly) == 'function' then
    setreadonly(table, false)
end
if not table.find(math, 'clamp') then function math.clamp(value,min,max) return (max <= value and max) or (value <= min and min) or (min <= value and value <= max and value); end; end

function sumsof(v,v2)
    if type(v) ~= 'number' then return end
    if type(v2) ~= 'number' then return end
    local r = {}
    if v < 0 and v2 < 0 then
        local a = (v2 < v and 'sub') or (v < v2 and 'add') or (v == v2 and 'equal')
        table.insert(r, a)
        if a == 'sub' then
            local b = (v-v2)
            local c = v-b
            table.insert(r, b)
        elseif a == 'add' then
            local b = (v2-v)
            local c = v+b
            table.insert(r, b)
        elseif a == 'equal' then
            table.insert(r, 0)
        end
    elseif 0 <= v and 0 <= v2 then
        local a = (v2 < v and 'sub') or (v < v2 and 'add') or (v == v2 and 'equal')
        table.insert(r, a)
        if a == 'sub' then
            local b = (v-v2)
            local c = v-b
            table.insert(r, b)
        elseif a == 'add' then
            local b = (v2-v)
            local c = v+b
            table.insert(r, b)
        elseif a == 'equal' then
            table.insert(r, 0)
        end
    end
    if v < 0 and 0 <= v2 then
        local a = (v < v2 and 'add') or (v == v2 and 'equal')
        table.insert(r, a)
        if a == 'add' then
            local b = -v*2
            local sum1 = b
            local c = v+b
            local d = (v2-c)
            sum1 = sum1 + d
            local e = v + sum1 or c + d
            table.insert(r, sum1)
        elseif a == 'equal' then
            table.insert(r, 0)
        end
    elseif 0 <= v and v2 < 0 then
        local a = (v2 < v and 'sub') or (v == v2 and 'equal')
        table.insert(r, a)
        if a == 'sub' then
            local b = v*2
            local sum1 = b
            local c = v-b
            local d = (c-v2)
            sum1 = sum1 + d
            local e = v - sum1 or c - d
            table.insert(r, sum1)
        elseif a == 'equal' then
            table.insert(r, 0)
        end
    end
    return r
end

function tp(cf, startheight,endheight, time)
    local Client = game:GetService('Players').LocalPlayer
    local Character = Client.Character

    local RootPart = Character.PrimaryPart or Character:FindFirstChild('HumanoidRootPart') or Character:FindFirstChildWhichIsA('BasePart')
    local Ratio = math.huge
    local TVector = CFrame.new((math.floor(cf.X) + 1), cf.Y, (math.floor(cf.Z) + 1))

    local startheight = startheight or 100
    local endheight = endheight or 30
    local time = time or 0.5

    local isequal = false
    repeat
        RootPart = Character.PrimaryPart or Character:FindFirstChild('HumanoidRootPart') or Character:FindFirstChildWhichIsA('BasePart')
        local CVector = RootPart.Position
        local methodX, sumX = unpack(sumsof(CVector.X,TVector.X))
        local methodZ, sumZ = unpack(sumsof(CVector.Z,TVector.Z))

        local minmax1 = math.clamp(sumX, -200, 200)
        local minmax2 = math.clamp(sumZ, -200, 200)
        local NVector = Vector3.new((math.floor(CVector.X) + 1), TVector.Y, (math.floor(CVector.Z) + 1))
        if methodX == 'sub' then
            NVector = NVector - Vector3.new(minmax1,0,0)
        elseif methodX == 'add' then
            NVector = NVector + Vector3.new(minmax1,0,0)
        end
        if methodZ == 'sub' then
            NVector = NVector - Vector3.new(0,0,minmax2)
        elseif methodZ == 'add' then
            NVector = NVector + Vector3.new(0,0,minmax2)
        end

        if methodX == 'equal' and methodZ == 'equal' then
            isequal = true
        end

        if not isequal then
            pcall(function()
                RootPart.CFrame = CFrame.new(NVector.X, NVector.Y, NVector.Z) + Vector3.new(0, startheight, 0)
            end)
        end

        wait(time)
    until Client:DistanceFromCharacter(Vector3.new(cf.X,RootPart.Position.Y,cf.Z)) <= 250 or not RootPart or isequal

    local cf2 = CFrame.new((cf.p.X or cf.X), (cf.p.Y or cf.Y), (cf.p.Z or cf.Z))
    RootPart.CFrame = cf2 * CFrame.new(0, endheight, 0)
end

return tp