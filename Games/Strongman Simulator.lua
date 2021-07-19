local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Jexytd/KRNL32/master/ui.lua", true))();
local window = library:NewWindow("Kye", "HUB");

--// Section
local s_1 = window:NewSection("AutoFarm");

--// global variable
farming = false;
strength = false;

--// works
do
    local sv = {};
    setmetatable(sv, {__index = function(_,x) return game:GetService(x); end})

    --// outter variable
    local client = sv.Players.LocalPlayer;

    pcall(function()
        repeat wait() until client
        for i,v in pairs(getconnections(client.Idled)) do
            v:Disable()
        end
    end)

    function farming_run()
        if client.Character then
            --// inner variable
            local rootpart = client.Character.HumanoidRootPart;
            local loader = workspace.BadgeColliders.FarmBadge;
            local item = workspace.Areas["Area7_Steampunk"].DraggableItems:FindFirstChildOfClass("MeshPart")

            if not item then 
                rootpart.CFrame = loader.CFrame; 
                return true; 
            end;

            local interact = item:WaitForChild("InteractionPoint");
            local proximity = interact:FindFirstChild("ProximityPrompt");
            local dragitems = workspace.PlayerDraggables[client.UserId]

            rootpart.CFrame = item.CFrame + Vector3.new(0, 0, item.Position.Z * 2 / 34);
            wait(.1);
            if #dragitems:GetChildren() <= 3 then
                fireproximityprompt(proximity);
            end ;

            for _,v in pairs(dragitems:GetChildren()) do
                for i = 1, 2 do
                    v.CFrame = workspace.Areas["Area7_Steampunk"].Goal.CFrame;
                    wait();
                end;
            end;

            return true;
        end;
    end;

    function strength_run()
        if client.Character then
            --// inner variable
            local rootpart = client.Character.HumanoidRootPart;
            local gym = workspace.Areas.Area1.Gym.TrainingEquipment.WorkoutStation.Collider;
            local proximity = gym.ProximityPrompt;

            rootpart.CFrame = gym.CFrame;
            wait(.1);

            fireproximityprompt(proximity);

            spawn(function()
                while strength do
                    sv.ReplicatedStorage["StrongMan_UpgradeStrength"]:InvokeServer()
                    wait(.1);

                    if not strength then client.Character.Humanoid.Jump = true; end;
                end
            end)
        end;
    end;
end;

do
    s_1:Toggle("Auto Farm", function(x)
        farming = x;
        while farming do
            local state,errormsg = pcall(function() repeat wait() until farming_run() == true end)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);

    s_1:Toggle("Auto Strength", function(x)
        strength = x;
        while strength do
            local state,errormsg = pcall(strength_run)
            if not state then
                print(errormsg)
            end;
            wait();
        end;
    end);
end;