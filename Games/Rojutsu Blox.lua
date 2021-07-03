--[[
        QUEST/MOB

- Training Dummy [1+]
- Metal Training Dummy [15+]
- Grade 1 Curse [30+]
- Grade 2 Curse [75+]
- Unique Grade [150+]

]]

getgenv().AutoFarm = true;
getgenv().Quest = 'Grade 2 Curse';

local sv = {};
setmetatable(sv, {__index = function(_,x) return game:GetService(x) end})

do
    local client = sv.Players.LocalPlayer;
    local combat = workspace.EventHolder['Combat_Damage'].Reactor; --// Remote Event

    function start()
        if client.Character then
            local qtGui = client:FindFirstChild("PlayerGui"):FindFirstChild("Quest")
            function getTargetQT()
                local target_dat = nil;
                
                pcall(function()
                    local frame = qtGui:FindFirstChild("MainFrame");
                    local info = frame['QuestInfo'];
                    local text = info.Text:split("Defeat ")[2]
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v.Name == text:sub(1, -2) then
                            target_dat = v;
                        end;
                    end;
                end);
                return target_dat;
            end;

            function getQTProgress()
                local qt_dat = false;
                pcall(function()
                    local frame = qtGui:FindFirstChild("MainFrame")
                    local pg = frame:FindFirstChild("QuestProgress")
                    local progress = pg.Text:split(' / ');
                    local Req, Max = tonumber(progress[1]), tonumber(progress[2]);
                    if Req == Max then 
                        qt_dat = false; 
                    else 
                        qt_dat = true; 
                    end;
                end)

                return qt_dat;
            end;

            function getNPCQuest(qtMob)
                local npc_dat = nil;
                local proximity_dat = nil;
                pcall(function()
                    for _,v in pairs(workspace:GetChildren()) do
                        if v:IsA("Model") and v.Name == "QuestGiver" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Interact") and v.Interact:FindFirstChild("ProximityPrompt") then
                            local Enemy = v.Interact.ProximityPrompt.Quest_Settings.Enemy.Value;
                            if Enemy == qtMob or Enemy:match(qtMob) then
                                npc_dat = v;
                                proximity_dat = v.Interact:FindFirstChild("ProximityPrompt");
                            end;
                        end;
                    end;
                end);
                return npc_dat, proximity_dat;
            end;

            --// works

            if qtGui.Enabled then
                local qtFrame = qtGui:FindFirstChildOfClass("Frame")
                local Progress = getQTProgress();
                if Progress then
                    local Target = getTargetQT();
                    if Target then
                        repeat
                            pcall(function()
                                local rootpart = client.Character.HumanoidRootPart;
                                rootpart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4.3);
                            end);
                            wait(.2);
                            pcall(function()
                                for i = 1, 3 do
                                    combat:FireServer('No', i);
                                end;
                            end);
                        until not Target or Target.Humanoid.Health <= 0 or not getgenv().AutoFarm;
                    end;
                end;
            else
                local target, proximity = getNPCQuest(getgenv().Quest);
                if target then
                    local rootpart = client.Character.HumanoidRootPart
                    rootpart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3);
                    wait(.3);
                    fireproximityprompt(proximity);
                end;
            end;
        end;
    end;
    
    while getgenv().AutoFarm do
        if client.Character then
            if client.Character.Head:FindFirstChildOfClass("BillboardGui") then client.Character.Head:FindFirstChildOfClass("BillboardGui"):remove(); end;
            local state,errormsg = pcall(start);
            if not state then
                print(errormsg)
            end;
        end;
        wait();
    end;
end;