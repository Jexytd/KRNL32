--// https://www.roblox.com/games/6938803436

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jexytd/KRNL32/master/ui.lua", true))();
local window = library:NewWindow("Kye", "HUB");

--// global variable
AF = false;

--// works
do

    local sv = {};
    setmetatable(sv, {__index = function(_,x) return game:GetService(x); end})

    --// outter variable
    local client = sv.Players.LocalPlayer;
    local y = 9.2;

    function Tween(Object, Speed)
        if client.Character then
            if typeof(Object) == "CFrame" then IsCFrame = true end
            local Distance = {0, y, 0}
            if IsCFrame then
                pcall(function()
                    local TWInfo = TweenInfo.new(client:DistanceFromCharacter(Object.p + Vector3.new(unpack(Distance))) / Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
                    local TWService = sv.TweenService:Create(client.Character.HumanoidRootPart, TWInfo, {CFrame = Object + Vector3.new(unpack(Distance))}):Play();
                    wait(client:DistanceFromCharacter(Object.p + Vector3.new(unpack(Distance))) / Speed);
                end);
            else
                pcall(function()
                    local TWInfo = TweenInfo.new(client:DistanceFromCharacter(Object.Position + Vector3.new(unpack(Distance))) / Speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out);
                    local TWService = sv.TweenService:Create(client.Character.HumanoidRootPart, TWInfo, {CFrame = Object.CFrame * CFrame.Angles(math.rad(-90), 0, 0) + Vector3.new(unpack(Distance))}):Play();
                    wait(client:DistanceFromCharacter(Object.Position + Vector3.new(unpack(Distance))) / Speed);
                end);
            end;
        end;
    end;

    function getTarget()
        local target;
        pcall(function()
            for _,v in pairs(workspace.Folders.Monsters:GetChildren()) do
                if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChildOfClass("Humanoid").Health > 0 then
                    target = v;
                end
            end
        end)
        return target;
    end;

    function run()
        if client.Character then
            local rootpart = client.Character.HumanoidRootPart;
            local combat = sv.ReplicatedStorage.RemoteEvents.MainRemoteEvent;
            local Target = getTarget();
            if Target then
                Tween(Target.HumanoidRootPart, 200)
                if client:DistanceFromCharacter(Target.HumanoidRootPart.Position + Vector3.new(0, y, 0)) <= 2 then
                    repeat
                        pcall(function()
                            for i = 1, 4 do
                                combat:FireServer("UseSkill", { ["hrpCFrame"] = rootpart.CFrame }, i)
                                wait();
                            end
                        end)
                        wait(.1)
                        pcall(function()
                            for i = 1, 4 do
                                combat:FireServer("UseSkill", { ["hrpCFrame"]= Target.HumanoidRootPart.CFrame, ["attackNumber"] = i }, "BasicAttack")
                                wait();
                            end
                        end);
                    until not Target or not (client:DistanceFromCharacter(Target.HumanoidRootPart.Position) <= 4) or not AF
                end;
            end;
        end;
    end;

end;

--// gui
local s_1 = window:NewSection("Main") do
    s_1:Toggle("Auto Farm", function(x)
        AF = x
        local Stepped;
        Stepped = game:service'RunService'.RenderStepped:connect(function()
            if AF == true then pcall(function() game:service'Players'.LocalPlayer.Character.Humanoid:ChangeState(11) end) end
            if AF == false then Stepped:Disconnect(); end
        end)
        while AF do
            local state,errormsg = pcall(run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end)
end;