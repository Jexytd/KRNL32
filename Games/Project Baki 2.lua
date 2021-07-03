local library = loadstring(game:HttpGet("https://naviproject.glitch.me/ui.lua", true))();
local window = library:NewWindow("Kye", "HUB");

--// global variable
local CombatTime = 0.1
local Target, Quest, ShadowLevel, Stats, Items = '', '', '', ''; --// strings
local AF,AQF,ASF,AS,ASA = false, false, false, false, false; --// boolean

--// works
do

    local sv = {};
    setmetatable(sv, {__index = function(_,x) return game:GetService(x); end})

    --// outter variable
    local client = sv.Players.LocalPlayer;

    spawn(function()
        while true do
            if sv.Lighting.ColorCorrection.Enabled then sv.Lighting.ColorCorrection.Enabled = false; end
            sv.Lighting.FogEnd = 1000000;
            if game:GetService("Workspace").Game:FindFirstChild(client.Name .. "Arena") then
                game:GetService("Workspace").Game:FindFirstChild(client.Name .. "Arena"):remove()
            end
            wait();
        end;
    end);

    function reWrite(t)
        local a,b = {}, {};
        for _,v in ipairs(t) do
            if not b[v] then
                b[v] = true;
                table.insert(a, v);
            end;
        end;
        return a;
    end;   

    function getDataTarget()
        local dat = {};
        for _,v in pairs(workspace.Game.Players:GetChildren()) do
            if v:IsA("Model") and not v:FindFirstChild("Core") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                if v.Name:match(client.Name) then
                    table.insert(dat, v.Name)
                end
                for _,v2 in pairs(v:GetChildren()) do
                    if v2:IsA("Script") and v2.Name:match("Soul") then
                        table.insert(dat, v.Name)
                    end;
                end;
            end;
        end;
        return reWrite(dat);
    end;

    function getTarget()
        local target;
        pcall(function()
            for _,v in pairs(workspace.Game.Players:GetChildren()) do
                if v.Name == Target and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                    target = v;
                end;
            end;
        end);
        return target;
    end;

    function getDataQuest()
        local dat = {};
        pcall(function()
            for _,v in pairs(workspace.Game.Quests:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChild("Quest") then
                    table.insert(dat, v:FindFirstChild("Quest"):FindFirstChild("Name").Value);
                end;
            end;
        end);
        return dat;
    end;

    function getTargetQT(qtGui)
        local target;
        pcall(function()
            local qt = qtGui.QuestList:WaitForChild("Quest");
            if qt then
                if qt.Info.Text:lower():match("defeat") then
                    local qtInfo = qt.Info.Text:split("Defeat ")
                    local qtTarget = qtInfo[2]:sub(1, -2)
                    for _,v in pairs(workspace.Game.Players:GetChildren()) do
                        if v.Name == qtTarget and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                            target = v;
                        end;
                    end;
                elseif qt.Info.Text:lower():match("find") then
                    target = {Ball = workspace.Game.Quests.questball, ClickDetector = workspace.Game.Quests.questball.ClickDetector}
                end
            end
        end)
        return target;
    end;

    function getStatusQT(qtGui)
        local status = false;
        local qt = qtGui.QuestList:WaitForChild("Quest");
        if qt then
            local qtInfo = qt.Info.Text:split("Defeat ")
            local qtPorgress = qtInfo[1]:split("/")
            local Req,Max = qtPorgress[1], qtPorgress[2]

            if Req == Max then
                status = false;
            else
                status = true;
            end

        end
        return status;
    end

    function getDataItems()
        local dat = {};
        local obj = {};
        pcall(function()
            for _,v in pairs(workspace.Game.Shop:GetChildren()) do
                for _,v2 in pairs(v:GetChildren()) do
                    if v2:IsA("Part") then
                        table.insert(dat, v2.Name);
                        table.insert(obj, v2)
                    end
                end
            end
        end)
        return reWrite(dat), obj;
    end;   

    function AF_run()
        if client.Character then
            local rootpart = client.Character.HumanoidRootPart;
            local Target = getTarget();
            if Target then
                repeat
                    pcall(function()
                        rootpart.CFrame = Target.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                    end)
                    wait();
                    pcall(function()
                        local combat = sv.ReplicatedStorage.Remotes.ClientToServer.BasicCombat;
                        for i = 1, 5 do
                            combat:FireServer("LightPunch", i, Target.Humanoid);
                            wait(CombatTime)
                        end;
                        if Target:FindFirstChild("Ragdolled") and Target.Humanoid.Health <= 0 then
                            Target:remove()
                        end
                    end)
                until not Target or Target.Humanoid.Health <= 0 or not AF;
            else
                rootpart.CFrame = CFrame.new(0, 10000, 0)
            end
        end;
    end;

    function AQF_run()
        if client.Character then
            local qtGui = client.PlayerGui.QuestGUI --// enabled > true == working enabled > false get quest
            local rootpart = client.Character.HumanoidRootPart;
            if qtGui.Enabled then
                local status = getStatusQT(qtGui);
                if status then
                    local Target = getTargetQT(qtGui);
                    if Target then
                        if type(Target) ~= "table" then
                            repeat
                                pcall(function()
                                    rootpart.CFrame = Target.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                                end)
                                wait();
                                pcall(function()
                                    local combat = sv.ReplicatedStorage.Remotes.ClientToServer.BasicCombat;
                                    for i = 1, 5 do
                                        combat:FireServer("LightPunch", i, Target.Humanoid);
                                        wait(CombatTime)
                                    end;
                                    if Target:FindFirstChild("Ragdolled") then
                                        Target.Ragdolled:remove()
                                    end
                                end)
                            until not Target or Target.Humanoid.Health <= 0 or not AQF;
                            if Target.Humanoid.Health == 0 then Target:remove() end
                        else
                            local Ball,ClickDetector = Target["Ball"], Target["ClickDetector"];
                            if client:DistanceFromCharacter(Ball.Position) > 2 then
                                rootpart.CFrame = Ball.CFrame
                            else
                                fireclickdetector(ClickDetector, 0)
                            end
                        end
                    end
                end
            else
                rootpart.CFrame = CFrame.new(0, 10000, 0)
                sv.ReplicatedStorage.Remotes.ClientToServer.QuestRemote:FireServer(Quest, "Request")
                wait(.5)
            end
        end;
    end;

    function ASF_run()
        if client.Character then
            local Level = ShadowLevel;
            local rootpart = client.Character.HumanoidRootPart;
            local Target = function()
                local shadow;
                pcall(function()
                    for _,v in pairs(workspace.Game.Players:GetChildren()) do
                        if v:IsA("Model") and not v:FindFirstChild("Core") and v.Name:match(client.Name) and v.Humanoid.Health > 0 then
                            if Level == "Yujiro" and v.Name:match(Level) then
                                shadow = v;
                            else
                                shadow = v;
                            end
                        end
                    end
                end)
                return shadow;
            end;
            if Target() then
                local Target = Target();
                repeat
                    pcall(function()
                        rootpart.CFrame = Target.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                    end)
                    wait();
                    pcall(function()
                        local combat = sv.ReplicatedStorage.Remotes.ClientToServer.BasicCombat;
                        for i = 1, 5 do
                            combat:FireServer("LightPunch", i, Target.Humanoid);
                            wait(CombatTime)
                        end;
                        if Target:FindFirstChild("Ragdolled") then
                            Target.Ragdolled:remove()
                        end
                    end)
                until not Target or Target.Humanoid.Health <= 0 or not ASF;
                if Target.Humanoid.Health == 0 then Target:remove() end
            else
                rootpart.CFrame = CFrame.new(0, 10000, 0)
                local Anim = client.Character.Humanoid:LoadAnimation(client.PlayerGui.Dialogue.Dialogue.Meditate);
                wait(Anim.Length * 1.5);
                sv.ReplicatedStorage.Remotes.ClientToServer.ShadowBoxing:InvokeServer(Level);
            end;
        end;
    end;

    function AS_run()
        if client.Character then
            if client.Data.SkillPoints.Value > 0 then
                sv.ReplicatedStorage.Remotes.ClientToServer.SkillPoint:FireServer(Stats)
            end
        end;
    end;

    function ASA_run()
        if client.Character then
            if client.Data.SkillPoints.Value > 0 then
                local Stats_dat = {"Strength", "Durability", "Agility", "Intellect"};
                sv.ReplicatedStorage.Remotes.ClientToServer.SkillPoint:FireServer(Stats_dat[math.random(1, #Stats_dat)]);
            end
        end;
    end;
end;

--// gui
local s_1 = window:NewSection("Main") do
    Target = getDataTarget()[1];
    local TargetDropdown = s_1:Drop("Target", getDataTarget(), function(x)
        Target = x;
    end)
    TargetDropdown:on(getDataTarget())

    s_1:Toggle("Auto Farm", function(x)
        AF = x;
        local Stepped;
        Stepped = game:service'RunService'.RenderStepped:connect(function()
            if AF == true then pcall(function() game:service'Players'.LocalPlayer.Character.Humanoid:ChangeState(11) end) end
            if AF == false then Stepped:Disconnect(); end
        end)
        while AF do
            local state,errormsg = pcall(AF_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);
    
    Quest = getDataQuest()[1];
    s_1:Drop("Quest", getDataQuest(), function(x)
        Quest = x;
    end)

    s_1:Toggle("Auto Quest Farm", function(x)
        AQF = x;
        local Stepped;
        Stepped = game:service'RunService'.RenderStepped:connect(function()
            if AQF == true then pcall(function() game:service'Players'.LocalPlayer.Character.Humanoid:ChangeState(11) end) end
            if AQF == false then Stepped:Disconnect(); end
        end)
        while AQF do
            local state,errormsg = pcall(AQF_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);

    local SLevel = {"Level 1", "Level 1 HARD", "Level 2", "Level 2 HARD", "Yujiro"};
    ShadowLevel = SLevel[1]
    s_1:Drop("Shadow Level", SLevel, function(x)
        ShadowLevel = x;
    end)

    s_1:Toggle("Auto Shadows Farm", function(x)
        ASF = x;
        local Stepped;
        Stepped = game:service'RunService'.RenderStepped:connect(function()
            if ASF == true then pcall(function() game:service'Players'.LocalPlayer.Character.Humanoid:ChangeState(11) end) end
            if ASF == false then Stepped:Disconnect(); end
        end)
        while ASF do
            local state,errormsg = pcall(ASF_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);
end;

local s_2 = window:NewSection("Misc") do
    local Stats_dat = {"Strength", "Durability", "Agility", "Intellect"};
    Stats = Stats_dat[1];
    s_2:Drop("Stats", Stats_dat, function(x)
        Stats = x;
    end)

    s_2:Toggle("Auto Stats", function(x)
        AS = x;
        while AS do
            local state,errormsg = pcall(AS_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);

    s_2:Toggle("Auto Stats All", function(x)
        ASA = x;
        while ASA do
            local state,errormsg = pcall(ASA_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);

    s_2:Drop("Items", getDataItems(), function(x)
        Items = x;
    end)

    s_2:Button("Buy Item", function()
        local _,Obj = getDataItems()
        for _,v in pairs(Obj) do
            if v.Name == Items then
                game:service'ReplicatedStorage'.Remotes.ClientToServer.Shop:InvokeServer(v)
            end
        end;
    end);
end;