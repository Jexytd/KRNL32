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

function tp(cf)
    local Client = game:GetService('Players').LocalPlayer
    local Character = Client.Character
    local TVector = cf.p or cf
    local Ratio = Client:DistanceFromCharacter(TVector)

    local RootPart = Character.PrimaryPart or Character:FindFirstChild('HumanoidRootPart') or Character:FindFirstChildWhichIsA('BasePart')
    local CVector = RootPart.Position

    local CX,CZ = CVector.X, CVector.Z
    local X,Y,Z = TVector.X, TVector.Y, TVector.Z
    local methodX, sumX = unpack(sumsof(CX,X))
    local methodZ, sumZ = unpack(sumsof(CZ,Z))

    local Base = Instance.new('Part')
    Base.Parent = workspace
    Base.Size = Vector3.new(10, 1, 10)
    Base.CFrame = RootPart.CFrame
    Base.Anchored = true

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
            RootPart.CFrame = RootPart.CFrame + NVector
            Base.CFrame = RootPart.CFrame - Vector3.new(0, 5, 0)
        end)

        wait(0.5)
        if Index == 1 then
            sumX = sumX - minmax1
            sumZ = sumZ - minmax2
            Index = 0
        end
        Index = Index + 1
        Ratio = Client:DistanceFromCharacter((cf.p or cf))
    until Ratio <= 500 or not RootPart or (sumX == 0 and sumZ == 0)
    Base:Destroy()
    RootPart.CFrame = cf
  
    print'Done'
end

print(tp)
tp(CFrame.new(1027, 19, 1367))