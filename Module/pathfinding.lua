function CreateGrid(PosGrid,Parent)
    local Base = Instance.new('Part')
    Base.Parent = Parent
    Base.Anchored = true
    Base.CanCollide = false
    Base.Position = PosGrid
    Base.Size = Vector3.new(7, 1, 7)
    Base.Transparency = 1

    local Size = Base.Size
    local CrossPos = {
        [1] = Base.Position + Vector3.new(-Size.X/2, 0, -Size.Z/2),
        [2] = Base.Position + Vector3.new(Size.X/2, 0, -Size.Z/2),
        [3] = Base.Position + Vector3.new(Size.X/2, 0, Size.Z/2),
        [4] = Base.Position + Vector3.new(-Size.X/2, 0, Size.Z/2),
        [5] = Base.Position + Vector3.new(0, 0, -Size.Z/2),
        [6] = Base.Position + Vector3.new(Size.X/2, 0, 0),
        [7] = Base.Position + Vector3.new(0, 0, Size.Z/2),
        [8] = Base.Position + Vector3.new(-Size.X/2, 0, 0),
    }

    local PreviousPart = {}
    local PhaseOne = false
    local LineIndex = 1
    local Names = {
        [1] = 'TL',
        [2] = 'TR',
        [3] = 'BR',
        [4] = 'BL',
        [5] = 'Top',
        [6] = 'Right',
        [7] = 'Bottom',
        [8] = 'Left'
    }

    for i=1,#CrossPos+1 do
        if i <= #CrossPos then
            CrossPart = Instance.new('Part')
            CrossPart.Parent = Base
            CrossPart.Name = Names[i]
            CrossPart.Material = 'Basalt'
            CrossPart.Anchored = true
            CrossPart.CanCollide = false
            CrossPart.Size = Vector3.new(0.8, 0.8, 0.8)
            CrossPart.Position = CrossPos[i]
        end

        if #PreviousPart > 0 and LineIndex <= 4 then
            local ConnectLine = Instance.new('Part')
            ConnectLine.Parent = Base
            ConnectLine.Name = 'Line_' .. PreviousPart[LineIndex].Name .. '_' .. tostring(LineIndex)
            ConnectLine.Material = 'Basalt'
            ConnectLine.Anchored = true
            ConnectLine.CanCollide = false
            ConnectLine.Size = Vector3.new(0.8, 0.6, 0.8)
            ConnectLine.Transparency = 0.1

            if LineIndex == 4 then
                local CenterPos = PreviousPart[LineIndex].Position - PreviousPart[1].Position
                ConnectLine.Position = Base.Position + Vector3.new(CenterPos.X/2, 0, CenterPos.Z/2)
                ConnectLine.Size = ConnectLine.Size + Vector3.new(5.2, 0, 0)
                PhaseOne = true
            else
                local CenterPos = PreviousPart[LineIndex].Position - CrossPart.Position
                ConnectLine.Position = Base.Position + Vector3.new(CenterPos.X/2, 0, CenterPos.Z/2)
            end
            if LineIndex == 1 then
                ConnectLine.Size = ConnectLine.Size + Vector3.new(0, 0, 6.2)
            end
            if LineIndex == 2 then
                ConnectLine.Size = ConnectLine.Size + Vector3.new(6.2, 0, 0)
            end
            if LineIndex == 3 then
                ConnectLine.Size = ConnectLine.Size + Vector3.new(0, 0, 6.2)
            end

            ConnectLine.Size = Vector3.new(ConnectLine.Size.X/2, ConnectLine.Size.Y, ConnectLine.Size.Z/2)
            LineIndex += 1
        end

        if PhaseOne and #PreviousPart > 4 and 4 < LineIndex then
            local ConnectLine = Instance.new('Part')
            ConnectLine.Parent = Base
            ConnectLine.Name = 'Line_' .. PreviousPart[LineIndex].Name .. '_' .. tostring(LineIndex)
            ConnectLine.Material = 'Basalt'
            ConnectLine.Anchored = true
            ConnectLine.CanCollide = false
            ConnectLine.Size = Vector3.new(0.8, 0.6, 0.8)
            ConnectLine.Transparency = 0.1

            if LineIndex == 8 then
                local CenterPos = PreviousPart[LineIndex].Position - PreviousPart[5].Position
                ConnectLine.Position = Base.Position + Vector3.new(CenterPos.X/2, 0, CenterPos.Z/2)
                ConnectLine.Rotation = Vector3.new(0, -40, 0)
                ConnectLine.Size = ConnectLine.Size + Vector3.new(5.2, 0, 0)
            else
                local CenterPos = PreviousPart[LineIndex].Position - CrossPart.Position
                ConnectLine.Position = Base.Position + Vector3.new(CenterPos.X/2, 0, CenterPos.Z/2)
            end
            if LineIndex == 5 then
                ConnectLine.Rotation = Vector3.new(0, -40, 0)
                ConnectLine.Size = ConnectLine.Size + Vector3.new(0, 0, 6.2)
            end
            if LineIndex == 6 then
                ConnectLine.Rotation = Vector3.new(0, -40, 0)
                ConnectLine.Size = ConnectLine.Size + Vector3.new(6.2, 0, 0)
            end
            if LineIndex == 7 then
                ConnectLine.Rotation = Vector3.new(0, -40, 0)
                ConnectLine.Size = ConnectLine.Size + Vector3.new(0, 0, 6.2)
            end

            ConnectLine.Size = Vector3.new(ConnectLine.Size.X/2, ConnectLine.Size.Y, ConnectLine.Size.Z/2)
            LineIndex += 1
        end

        table.insert(PreviousPart, CrossPart)
    end

    return Base
end

function Pathfind(TargetPos)
    --[[
        local OpenSet = {}
        local ClosedSet = {}
        local Neighbors = {}
        local Client = game:GetService('Players').LocalPlayer
        local Char = Client.Character

        local SizeLayer = 6

        local CharPos = Char.PrimaryPart.Position or Char:FindFirstChild('HumanoidRootPart').Position
        table.insert(OpenSet, Grid(CharPos, Folder))

        for _,v in pairs(OpenSet) do
            local Size = v.Size
            local Pos = {
                [1] = v.Position + Vector3.new(0, 0, -8),
                [2] = v.Position + Vector3.new(8, 0, 0),
                [3] = v.Position + Vector3.new(0, 0, 8),
                [4] = v.Position + Vector3.new(-8, 0, 0),
                [5] = v.TL.Position + Vector3.new(-Size.X/2, 0, -Size.Z/2),
                [6] = v.TR.Position + Vector3.new(Size.X/2, 0, -Size.Z/2),
                [7] = v.BR.Position + Vector3.new(Size.X/2, 0, Size.Z/2),
                [8] = v.BL.Position + Vector3.new(-Size.X/2, 0, Size.Z/2)
            }
            local HC = {}
            for i=1,#Pos do
                local grid = Grid(Pos[i], Folder)
                local DistanceFromStart = math.floor((OpenSet[1].Position - grid.Position).magnitude)
                
                local a = Vector3.new(math.floor(grid.Position.X), 0, math.floor(grid.Position.Z))
                local b = Vector3.new(math.floor(TargetPos.X), 0, math.floor(TargetPos.Z))
                local DistanceFromTarget = math.floor((a - b).magnitude)

                local GCost = Instance.new('IntValue')
                GCost.Parent = grid
                GCost.Name = 'Gcost'
                GCost.Value = DistanceFromStart

                local HCost = Instance.new('IntValue')
                HCost.Parent = grid
                HCost.Name = 'Hcost'
                HCost.Value = DistanceFromTarget

                local FCost = Instance.new('IntValue')
                FCost.Parent = grid
                FCost.Name = 'Fcost'
                FCost.Value = GCost.Value + HCost.Value

                table.insert(HC, {HCost.Value,grid})
                table.insert(Neighbors, grid)
            end
            table.sort(HC, function(a,b) return a[1] < b[1] end)
            for I=2,#HC do
                HC[I][2]:Destroy() --// doing this because doesn't implemented the obstacle checking
            end
            table.insert(OpenSet, HC[1][2])
            for _,v in pairs(HC[1][2]:GetChildren()) do
                if v:IsA('BasePart') then
                    v.Color = Color3.fromRGB(0, 255, 255)
                end
            end
            
            if HC[1][1] <= 5 then
                print('Reach the end!')
                break
            end
            task.wait()
        end

        -- for _,p in pairs(ClosedSet) do
        --     p:Destroy()
        -- end
    ]]

    local tampungan = Instance.new('Folder')
    tampungan.Parent = workspace
    tampungan.Name = 'XMIPA2'

    local Client = game:GetService('Players').LocalPlayer
    local Character = Client.Character or Client.CharacterAdded
    local MainPart = Character:FindFirstChild('HumanoidRootPart') or Character.PrimaryPart
    local OpenSet = {}

    function OpenSet:Add(object) --/ DFS ?
        local newnode = {}
        objPos = object.Position
        objSize = object.Size

        local gridPos = {
            objPos + Vector3.new(0, 0, -objSize.Z), --/ Top
            objPos + Vector3.new(0, 0, objSize.Z), --/ Bottom
            objPos + Vector3.new(objSize.X, 0, 0), --/ Right
            objPos + Vector3.new(-objSize.X, 0, 0), --/ Left
            objPos + Vector3.new(-objSize.X, 0, -objSize.Z), --/ Top Left
            objPos + Vector3.new(objSize.X, 0, -objSize.Z), --/ Top Right
            objPos + Vector3.new(objSize.X, 0, objSize.Z), --/ Bottom Right
            objPos + Vector3.new(-objSize.X, 0, objSize.Z), --/ Bottom Left
        }

        for _,pos in pairs(gridPos) do
            --/ Checking obstacle / the blocking part
            local IsHit = false
            local newRay = Ray.new(objPos, pos - objPos)
            local c = {}
            for _,v in pairs(tampungan:GetChildren()) do
                table.insert(c,v)
            end
            for _,plr in pairs(Client.Parent:GetChildren()) do
                if plr.Character then
                    for _,v in pairs(plr.Character:GetChildren()) do
                        if v:IsA('BasePart') or v:IsA('Part') or v:IsA('MeshPart') then
                            table.insert(c, v)
                        end
                    end
                end
            end
            local Hit = workspace:FindPartOnRayWithIgnoreList(newRay, c)
            if Hit and not Hit:IsDescendantOf(tampungan) or tampungan:IsAncestorOf(Hit) then
                IsHit = true

                local firstNode = table.remove(newnode, 1) or table.remove(OpenSet[#OpenSet].nodes, 1)
                objPos = firstNode.Position
                objSize = firstNode.Size
            end

            if not IsHit then
                local grid = CreateGrid(pos, tampungan)
                table.insert(newnode, grid)
            end
        end

        table.insert(OpenSet, {obj = object, nodes = newnode})
    end
    function OpenSet:Remove(object)
        for idx,node in pairs(this) do
            if table.find(node, object) then
                table.remove(this, idx)
                return print(('[OpenSet]: Successfully remove %s from OpenSet, removed index %s'):format(tostring(object), tostring(idx)))
            end
        end
        return print('[OpenSet]: Cannot find the object!')
    end

    local ClosedSet = {}
    --/ the long path will going to ClosedSet

    OpenSet:Add(MainPart)

    for _,v in pairs(OpenSet) do
        if type(v) == 'table' then
            GC = {}
            local object = v.obj
            local nodes = v.nodes

            local function DistToTarget(posA, posB)
                local f = math.floor --/ too lazy to use, so i made it to simple when coding :|

                posA = Vector3.new(f(posA.X), 0, f(posA.Z))
                posB = Vector3.new(f(posB.X), 0, f(posB.Z))

                return f((posA - posB).magnitude)
            end

            local function addIntVal(obj, val)
                local iv = Instance.new('IntValue')
                iv.Parent = obj
                iv.Value = val
                iv.Name = 'HCost'
            end

            local dist = DistToTarget(object.Position, TargetPos)
            addIntVal(object, dist)
            table.insert(GC, {dist, object})

            for _,node in pairs(nodes) do
                local dist = DistToTarget(node.Position, TargetPos)
                addIntVal(node, dist)
                table.insert(GC, {dist, node})
            end

            table.sort(GC, function(a,b) return a[1] < b[1] end)

            local sortestPath = GC[1][2]
            for _,v in pairs(sortestPath:GetChildren()) do
                if v:IsA('Part') then
                    v.Color = Color3.fromRGB(0, 255, 255)
                end
            end
            OpenSet:Add(sortestPath)

            if GC[1][1] <= 5 then warn('[Pathfind]: Path has reached the goal!'); break end
            task.wait()
        end -- end if
    end

    for _,v in pairs(OpenSet) do
        if type(v) == 'table' then
            local obj = v.obj
            local Character = Client.Character or Client.CharacterAdded
            local Humanoid = Character:WaitForChild('Humanoid') or Character:FindFirstChildOfClass('Humanoid')
            Humanoid:MoveTo(obj.Position)
            wait(.2)
        end
    end
end -- end function

Pathfind(Vector3.new(46,4,-99))

