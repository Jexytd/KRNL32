local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jexytd/KRNL32/master/ui.lua", true))()
local window = library:NewWindow("Kye", "HUB")

--[[
    Auto fuse / feed:

    _G.Pet = 'King'
    loadstring(game:HttpGet('https://pastebin.com/raw/M9VY4Bip'))()
]]

local Sections do
    Sections = {}
    Sections[1] = window:NewSection("Main")
    Sections[2] = window:NewSection("Egg/Pets")
end

local Client,Character,reWrite do
    Client = game:service'Players'.LocalPlayer
    Character = Client.Character or Client:WaitForChild('Character')
    reWrite = function(t)
        local a,b = {}, {}
        for _,v in ipairs(t) do
            if not b[v] then
                b[v] = true
                table.insert(a, v)
            end
        end
        return a
    end
end

-- Sections[1]
do
    local AutoFarm,AutoCoins,FarmTarget;

    function Farming()
        local Debounce = false;

        local Target = (function() 
            local t;
            for _,v in pairs(workspace.Worlds[Client:FindFirstChild("World").Value]:GetChildren()) do
                if v:IsA("Folder") and v.Name == 'Enemies' then
                    for _,target in pairs(v:GetChildren()) do
                        if target:IsA("Model") and target.DisplayName.value == FarmTarget and target.Health.value > 0 then
                            t = target;
                        end
                    end
                end
            end
            return t;
        end)()
        repeat wait() until Target

        local p = Target.PrimaryPart or Target:FindFirstChild("HumanoidRootPart")
        Character.HumanoidRootPart.CFrame = p.CFrame

        --[[
            Note: using sendpet event are not working, trying find it.

            RBXScriptSignal? because when mouse hover target it show billboardgui, and when click will fire event sendpet
        ]]

        repeat until not Target or not AutoFarm

        Debounce = true;

        return Debounce;
    end

    function GrabCoins()
        local Debounce = false;

        for _,v in pairs(workspace.Effects:GetChildren()) do
            if v:IsA("Model") and v.Name == 'Yen' and v:FindFirstChild("Base") then
                v.Base.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        wait(.2)
        Debounce = true;

        return Debounce;
    end

    local _,Enemies = pcall(function()
        local t = {}
        for _,v in pairs(workspace.Worlds[Client:FindFirstChild("World").Value]:GetChildren()) do
            if v:IsA("Folder") and v.Name == 'Enemies' then
                for _,target in pairs(v:GetChildren()) do
                    table.insert(t, target.DisplayName.value)
                end
            end
        end
        return reWrite(t);
    end)
    local Pucing = Sections[1]:Drop('Enemies/World', Enemies, function(x) FarmTarget = x; end)
    Pucing:on(Enemies)
    Sections[1]:Toggle('Auto Farm', function(x) AutoFarm = x; local f = Farming; while AutoFarm do repeat wait() until f() == true wait() end; end)
    Sections[1]:Toggle('Collect Coins', function(x) AutoCoins = x; local f = GrabCoins; while AutoCoins do repeat wait() until f() == true wait() end; end)
end

-- Sections[2]
do
    local AutoOpen,AutoFuse,Egg,Pet;

    function EggOpener()
        local Debounce = false;
        for _,sub in pairs(workspace.Worlds:GetChildren()) do 
            for _,v in pairs(sub:GetChildren()) do 
                if v.name == Egg and v:FindFirstChildOfClass("MeshPart") then
                    local p = v:FindFirstChildOfClass("MeshPart")
                    local Event = game:GetService('ReplicatedStorage').Remote.OpenEgg
                    if Client:DistanceFromCharacter(p.Position) >= 10 then
                        Character.HumanoidRootPart.CFrame = p.CFrame + Vector3.new(2, 0, 2)
                    end
                    Event:InvokeServer(v, 1)
                    wait(.65)
                    Debounce = true;
                    break
                end
            end
        end
        return Debounce
    end

    function EggFuse()
        local Debounce = false;

        if Client:FindFirstChild("PlayerGui").MainGui.Pets.Visible == false then firesignal(Client:FindFirstChild("PlayerGui").MainGui.Menu.Tabs.Pets.Activated) end

        local Container = Client:FindFirstChild("PlayerGui").MainGui.Pets.Main.Scroll
        local Selected = (function()
            for _,v in pairs(Container:GetChildren()) do
                if v.ClassName == 'ImageButton' and v.Name == 'PetBox' and v.PetName.text == Pet then
                    return v;
                end
            end
        end)()
        repeat wait() until Selected

        Debounce = true;

        local Unequipped = (function() 
            local t = {}
            for _,v in pairs(Container:GetChildren()) do
                if v.ClassName == 'ImageButton' and v.Name == 'PetBox' and v.Equipped.Visible ~= true then
                    table.insert(t, v.UID.value)
                end
            end
            return t
        end)()
        local UID,PetName = Selected.UID.value, Selected.PetName.text

        if #Unequipped >= 1 then
            local Event = game:GetService("ReplicatedStorage").Remote.FeedPets
            print('[' .. table.concat(Unequipped, ',') .. ']', 'pets available for feed, feeding to', PetName .. ' [' .. UID .. ']')
            Event:FireServer(Unequipped, UID)
        end

        return Debounce;
    end

    Sections[2]:Drop('Egg', (function() local t = {}; for _,sub in pairs(workspace.Worlds:GetChildren()) do for _,v in pairs(sub:GetChildren()) do if v.name:lower():match('egg') then table.insert(t, v.name) end; end; end; return t; end)() ,function(x) Egg = x; end)
    Sections[2]:Toggle('Auto Open', function(x) AutoOpen = x; local f = EggOpener while AutoOpen do pcall(function() repeat wait() until f() == true end) wait(); end; end)

    local Pets = (function() if Client:FindFirstChild("PlayerGui").MainGui.Pets.Visible == false then firesignal(Client:FindFirstChild("PlayerGui").MainGui.Menu.Tabs.Pets.Activated); end; local t = {}; for _,v in pairs(Client:FindFirstChild("PlayerGui").MainGui.Pets.Main.Scroll:GetChildren()) do if v.ClassName == 'ImageButton' and v.Name == 'PetBox' and v.Equipped.Visible == true then table.insert(t, v.PetName.text); end; end; return t; end)()
    local Pucing = Sections[2]:Drop('Equipped Pets', Pets, function(x) Pet = x; end)
    Pucing:on(Pets)
    Sections[2]:Toggle('Auto Fuse', function(x) AutoFuse = x; local f = EggFuse while AutoFuse do pcall(function() repeat wait() until f() == true end) wait(); end; end)
end