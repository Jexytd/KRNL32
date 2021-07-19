local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jexytd/KRNL32/master/ui.lua", true))();
local window = library:NewWindow("kyeXL", "v4.6");

--// Section
local s_1 = window:NewSection("AutoFarm");

--// works
do
    local sv = {};
    setmetatable(sv, {__index = function(_,x) return game:GetService(x); end})

    --// outter variable
    local client = sv.Players.LocalPlayer;
    local combat = sv.ReplicatedStorage.RemoteEvents.BladeCombatRemote;
    selectednpc = 'Kaji';
    farming = false;
    qt_dat = {
        ["Kaji"] = "Defeat 10 Bandits",
        ["Laji"] = "Defeat 9 of Agni's Minions",
        ["flamingo kaji"] = "Defeat 8 of Lars' Minions",
        ["MlgSteakStyle"] = "Defeat 7 of Rahgan's Minions",
        ["pilgrism"] = "Defeat 6 of Agni's Overseers",
        ["Aito"] = "Defeat 5 of Lars' Overseers",
        ["KINGKONGKINGGKONGGG"] = "Defeat 4 of Rahgan's Overseers",
    };

    local drop_dat = {};
    for i in pairs(qt_dat) do table.insert(drop_dat, i); end;
    s_1:Drop("NPC Quest", drop_dat, function(x)
        selectednpc = x;
    end);

    function start()
        if client.Character then
            local currentqt = client["PlayerValues"]["CurrentQuest"].Value --// string
            local oldDialog = client["PlayerValues"]["DialogNpc"].Value --// string
            local pgui = client:FindFirstChild("PlayerGui");
            local qtframe = pgui:FindFirstChild("Menu"):FindFirstChild("QuestFrame");
            local qtinfo = qtframe:FindFirstChild("QuestName").Text;
            local qtprogress = qtframe:FindFirstChild("Amount").Text;

            function getQuest(x)
                if qt_dat[x] and typeof(qt_dat[x]) == "string" then
                    sv.ReplicatedStorage.RemoteEvents.ChangeNpcValueRemote:FireServer(oldDialog, npc);
                    sv.ReplicatedStorage.RemoteEvents.ChangeQuestRemote:FireServer(sv.ReplicatedStorage.Quests:FindFirstChild(qt_dat[x]));
                end;
            end;

            function getQTProgress()
                local qt_dat = false;
                pcall(function()
                    local progress = qtprogress:split(' / ');
                    local Req, Max = tonumber(progress[1]), tonumber(progress[2]);
                    if Req == Max then 
                        qt_dat = false; 
                    else 
                        qt_dat = true; 
                    end;
                end);

                return qt_dat;
            end;
            
            --// get patched on v4.6
            function getQTTarget()
                local target_dat = nil;
                pcall(function()
                    for _,v in pairs(workspace.Live:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 and qtinfo:sub(1, -2):match(v.Name) then
                            target_dat = v;
                        end;
                    end;
                end);
                return target_dat;
            end;

            function equipTool()
                for _,v in pairs(client.Backpack:GetChildren()) do
                    if v.ClassName == "Tool" and v:FindFirstChild("Combat Script") then 
                        v.Parent = client.Character;
                    end;
                end;
            end;

            if currentqt ~= '' then
                if qtframe.Visible ~= false then
                    local Progress = getQTProgress();
                    if Progress then
                        local Target = getQTTarget();
                        local health;
                        if Target then
                            health = Target.Humanoid.Health
                            equipTool();
                            repeat
                                pcall(function()
                                    local rootpart = client.Character.HumanoidRootPart;
                                    rootpart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(90), 0, 0) + Vector3.new(0, -9, 0)
                                end);
                                wait();
                                pcall(function()
                                    combat:FireServer(true, nil, nil);

                                    if Target.Humanoid.Health < health then Target.Humanoid.Health = 0 end
                                end);
                            until not Target or Target.Humanoid.Health <= 0 or not farming;
                        end
                    end
                end
            else
                getQuest(selectednpc)
            end
        end;
    end;

    s_1:Toggle("Auto Farm", function(x)
        farming = x
        while farming do
            local state,errormsg = pcall(start);
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);
end;