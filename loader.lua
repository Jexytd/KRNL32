repeat wait() until game:IsLoaded()

-- Loader Gui
function Loader()
    local SG = Instance.new('ScreenGui')
    local Holder = Instance.new('Frame')
    local Title = Instance.new('TextLabel')
    local Logo = Instance.new('ImageLabel')
    local SContainer = Instance.new('Frame')
    local Round = Instance.new('Frame')
    local Step = Instance.new('TextLabel')
    local Text = Instance.new('TextLabel')
    local Logger = Instance.new('TextLabel')
    local Corner1 = Instance.new('UICorner')
    local Corner2 = Instance.new('UICorner')

    local function Gen() return game:GetService('HttpService'):GenerateGUID(false) end

    SG.Name = Gen()
    SG.Parent = game:GetService('CoreGui')
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Global

    Corner1.Parent = Holder
    Holder.Name = Gen()
    Holder.Parent = SG
    Holder.AnchorPoint = Vector2.new(0.5,0.5)
    Holder.Position = UDim2.new(0.5,0,0.5,0)
    Holder.Size = UDim2.new(0,0,0,0)
    Holder.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Holder.BorderSizePixel = 0
    Holder.ZIndex = 9999999
    Holder.Visible = false

    Title.Parent = Holder
    Title.Name = Gen()
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Position = UDim2.new(0.02,0,0.02,0)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(170, 85, 255)
    Title.TextWrapped = true
    Title.TextSize = 12
    Title.Text = '[LOADER]'
    Title.ZIndex = 9999999
    Title.Visible = false

    Logo.Parent = Title
    Logo.Name = Gen()
    Logo.BackgroundTransparency = 1
    Logo.Size = UDim2.new(0,25,0,25)
    Logo.Position = UDim2.new(0,0,0,0)
    Logo.Image = 'rbxassetid://7929559435'
    Logo.ZIndex = 9999999
    Logo.Visible = false

    SContainer.Parent = Holder
    SContainer.Name = Gen()
    SContainer.Position = UDim2.new(0.03,0,0.25,0)
    SContainer.Size = UDim2.new(0.94,0,0,100)
    SContainer.BackgroundColor3 = Color3.fromRGB(255,255,255)
    SContainer.BackgroundTransparency = 1
    SContainer.BorderSizePixel = 0
    SContainer.ZIndex = 9999999
    SContainer.Visible = false

    Corner2.Parent = Round
    Corner2.CornerRadius = UDim.new(1,1)
    Round.Parent = SContainer
    Round.Name = Gen()
    Round.AnchorPoint = Vector2.new(0.5,0.5)
    Round.Position = UDim2.new(0.2,0,0.4,0)
    Round.Size = UDim2.new(0,60,0,60)
    Round.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Round.BorderSizePixel = 0
    Round.ZIndex = 9999999
    Round.Visible = false

    Step.Parent = Round
    Step.Name = Gen()
    Step.Size = UDim2.new(1,0,1,0)
    Step.BackgroundTransparency = 1
    Step.Font = Enum.Font.GothamBold
    Step.TextSize = 16
    Step.TextColor3 = Color3.fromRGB(255,255,255)
    Step.Text = '0'
    Step.TextXAlignment = Enum.TextXAlignment.Center
    Step.TextYAlignment = Enum.TextYAlignment.Center
    Step.ZIndex = 9999999
    Step.Visible = false

    Text.Parent = SContainer
    Text.Name = Gen()
    Text.AnchorPoint = Vector2.new(0.5,0.5)
    Text.Size = UDim2.new(0,100,0,20)
    Text.Position = Round.Position + UDim2.new(0.24,0,0,0)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 13
    Text.BackgroundTransparency = 1
    Text.TextColor3 = Color3.fromRGB(170,85,255)
    Text.Text = 'Loading...'
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.ZIndex = 9999999
    Text.Visible = false

    Logger.Parent = Holder
    Logger.Name = Gen()
    Logger.Size = UDim2.new(0.945,0,0,40)
    Logger.Position = SContainer.Position + UDim2.new(0,0,0.5,0)
    Logger.BackgroundTransparency = 1
    Logger.Font = Enum.Font.GothamBold
    Logger.TextSize = 13
    Logger.TextColor3 = Color3.fromRGB(170,85,255)
    Logger.Text = 'Please be a patient, this may take a while to load!'
    Logger.TextXAlignment = Enum.TextXAlignment.Center
    Logger.TextYAlignment = Enum.TextYAlignment.Center
    Logger.TextWrapped = true
    Logger.ZIndex = 9999999
    Logger.Visible = false

    local Library = {SG,Holder,{nil,false}}
    Library.__index = Library

    local fadeDebounce = Library[3]

    function textTransparency(o)
        if not o then return false end
        local TweenS = game:GetService('TweenService')
        local function TInfo(speed, style, direction)
            local speed = speed or 0.6
            local style = style or Enum.EasingStyle.Linear
            local direct = direction or Enum.EasingDirection.InOut
            return TweenInfo.new(speed, style, direct)
        end
        if not fadeDebounce[2] and (fadeDebounce[1] == o or fadeDebounce == nil) then
            local b = TInfo()
            local a = TweenS:Create(o, b, {TextTransparency=0})
            a.Completed:Connect(function()
                fadeDebounce = {o,true}
            end)
            a:Play()
            repeat wait() until fadeDebounce[2] == true and fadeDebounce[1] == o
        elseif fadeDebounce[2] and fadeDebounce[1] == o then
            local b = TInfo()
            local a = TweenS:Create(fadeDebounce[1], b, {TextTransparency=1})
            a.Completed:Connect(function()
                fadeDebounce = {nil,false}
            end)
            a:Play()
            repeat wait() until fadeDebounce[2] == false and not fadeDebounce[1]
        end
    end

    function Library:setTitle(s)
        textTransparency(Title)
        Title.Text = ('[%s]'):format(s)
        textTransparency(Title)
    end

    function Library:setLog(...)
        textTransparency(Logger)
        Logger.Text = ...
        textTransparency(Logger)
    end

    function Library:setStep(i,v)
        textTransparency(Step)
        Step.Text = i
        textTransparency(Step)
        textTransparency(Text)
        Text.Text = v
        textTransparency(Text)
    end

    function Library:setColor(bool)
        if type(bool) ~= 'boolean' then return end
        local TweenS = game:GetService('TweenService')
        local function TInfo(speed, style, direction)
            local speed = speed or 0.6
            local style = style or Enum.EasingStyle.Linear
            local direct = direction or Enum.EasingDirection.InOut
            return TweenInfo.new(speed, style, direct)
        end

        local pass = Round.BackgroundColor3 == Color3.fromRGB(69, 69, 230)

        if bool and Round.BackgroundColor3 == Color3.fromRGB(69, 69, 230) then
            local a = TweenS:Create(Round, TInfo(), {BackgroundColor3=Color3.fromRGB(69, 230, 69)})
            local b = false
            a.Completed:Connect(function()
                b = true
            end)
            a:Play()
            repeat wait() until b
        end

        if bool and not pass then
            local a = TweenS:Create(Round, TInfo(), {BackgroundColor3=Color3.fromRGB(69, 69, 230)})
            local b = false
            a.Completed:Connect(function()
                b = true
            end)
            a:Play()
            repeat wait() until b
        end

        if not bool then
            local a = TweenS:Create(Round, TInfo(), {BackgroundColor3=Color3.fromRGB(230, 69, 69)})
            local b = false
            a.Completed:Connect(function()
                b = true
            end)
            a:Play()
            repeat wait() until b
        end
    end

    return Library
end

function CloseGui(Holder)
    local done = false
    if Holder then
        for _,v in pairs(Holder:GetDescendants()) do
            if v.ClassName ~= 'UICorner' and v.Visible == true then
                v.Visible = false
            end
        end
        Holder:TweenSize(
            UDim2.new(0,0,0,0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quad,
            1,
            false,
            function()
                done = true
            end
        )
        repeat wait() until done == true
        if Holder:IsA('ScreenGui') then Holder:Destroy() end
        if Holder:IsA('Frame') then Holder.Parent:Destroy() end
        getgenv().Jambi = nil
    end
end
if getgenv().Jambi ~= nil then 
    CloseGui(getgenv().Jambi); 
end

local Library = Loader()
local SG,Background = Library[1],Library[2]

if getgenv().Jambi == nil then
    getgenv().Jambi = Background
end

local Show = false

getgenv().sendErr = function(title,...)
    local dt = DateTime.now():FormatLocalTime('LLLL', 'en-us')
    local hs = game:GetService('HttpService')
    local embed = {
        ['embeds'] = {{
            ['title'] = title,
            ['description'] = ('```%s```'):format(tostring(...)),
            ['type'] = 'rich',
            ['color'] = tonumber(0xFF5656),
            ['footer'] = {
                ['icon_url'] = '',
                ['text'] = dt
            }
        }}
    }; 
    local s,m = pcall(function() 
        --# below url are really discord webhook, do not touch or ill come to your house
        local webhook = loadstring("function c(a) c='';for v in a:gmatch('\\x(%x+)') do b=tonumber('0x'..v);b=string.char((b-tonumber(0x1))/tonumber(0xA));c=c..b;end; return c;end;return c")()('\x411\x489\x489\x461\x47F\x245\x1D7\x1D7\x3E9\x41B\x47F\x3DF\x457\x475\x3E9\x1CD\x3DF\x457\x443\x1D7\x3CB\x461\x41B\x1D7\x4A7\x3F3\x3D5\x411\x457\x457\x42F\x47F\x1D7\x23B\x1EB\x1F5\x1F5\x1F5\x213\x1F5\x1F5\x227\x1E1\x1EB\x1F5\x23B\x23B\x227\x1EB\x231\x1EB\x1D7\x2B3\x1C3\x461\x443\x44D\x42F\x23B\x1F5\x4A7\x2DB\x335\x2BD\x3F3\x321\x1EB\x209\x303\x44D\x213\x231\x317\x353\x489\x407\x1E1\x371\x209\x439\x1EB\x37B\x317\x295\x4BB\x3E9\x457\x3D5\x2EF\x1E1\x32B\x2A9\x4A7\x2F9\x461\x1F5\x353\x3CB\x457\x353\x461\x1EB\x213\x1FF\x411\x28B\x385\x231\x3E9\x209\x4BB\x2E5\x317\x407\x32B\x2D1\x1F5\x28B\x489\x44D')
        return request({Url = webhook, Body = hs:JSONEncode(embed), Method = "POST", Headers = { ['content-type']='application/json' } })
    end)
end

-- Open Gui
do
    Background.Visible = true
    Background:TweenSize(
        UDim2.new(0.3,0,0,160),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Sine,
        1,
        false,
        function() 
            for _,v in pairs(Background:GetDescendants()) do
                if v.ClassName ~= 'UICorner' and v.Visible == false then
                    v.Visible = true
                end
            end
            wait(0.2)
            Show = true
        end
    )
    repeat wait() until Show == true
end

local no_error = true
local err_msg = ''
local script = {}
xpcall(function()
    local Step = 1
    local Text = {
        'Checking Exploit...',
        'Checking Games...',
        'Executing Script...'
    }
    repeat
        Library:setStep(tostring(Step), Text[Step])
        local pass = false

        if Step == 1 then
            Library:setColor(true)
            local getExploit = (function()
                for i in pairs(getgenv()) do
                    if i == "syn_getinstances" then
                        return {"Synapse X",true}
                    elseif i == "Krnl" then
                        return {"Krnl",true}
                    end
                end
                return {'未知',false}
            end)()
            local s,b = unpack(getExploit)
            Library:setLog(s)
            Library:setColor(true)
            pass = true
        elseif Step == 2 then
            Library:setColor(true)
            local s,msg = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/games.json',true) end) -- JSON
            if not s then Library:setLog(msg); no_error = false; err_msg={msg,step}; end
            local JSON = game:GetService('HttpService'):JSONDecode(msg)
            local found = false
            for _,t in pairs(JSON) do
                for _,id in pairs(t[1]) do
                    if game.PlaceId == id then
                        script[1] = t[3]
                        found = true
                        break
                    end
                end
                if not found and t[2] == game.CreatorId and game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name:lower():match(t[3]:lower()) then
                    script[1] = t[3]
                    found = true
                    break
                end
            end
            if not found then
                Library:setLog('Game not supported!')
                Library:setColor(false)
                err_msg = 'Game not supported'
                sendErr(Step, err_msg .. '\nPlaceId: ' .. (tostring(game.PlaceId) or 'Unable to get placeid') .. '\nPlace Name: ' .. (game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name or 'Unable to get placename'))
                Step = 4
            end
            if no_error and found then
                local PlaceName = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
                Library:setLog('Game Found! ' .. PlaceName .. (' [%s]'):format(game.CreatorId))
                Library:setColor(true)
                Library:setColor(true)
                pass = true
            end
        elseif Step == 3 then
            Library:setColor(true)
            
            local user = 'Jexytd'
            local repo = 'KRNL32'
            local path = 'Game/' .. script[1]
            local githubFormat = ('https://raw.githubusercontent.com/%s/%s/master/%s/source.lua'):format(user,repo,path)

            local attempt = 1
            local maxattempt = 2
            local oldclock = os.clock()
            local newclock
            repeat wait()
                Library:setLog('Executing script in attempt ' .. tostring(attempt))
                local s,msg = pcall(function() return loadstring(game:HttpGet(githubFormat, true))() end)
                if not s then
                    attempt = attempt + 1
                    err_msg = msg
                else
                    attempt = true
                    newclock = os.clock()
                    break
                end
                
            until (attempt == true) or (attempt == maxattempt)
            if attempt ~= true then
                Library:setLog('Failed to executing script!')
                sendErr(Step, err_msg .. '\nScript url: ' .. githubFormat .. '\nPlaceid: ' .. tostring(game.PlaceId))
                no_error = false
            end
            if no_error then
                Library:setLog('Script executed! ' .. ('takes %0.1fs'):format(newclock - oldclock))
                Library:setColor(true)
                wait(.4)
                pass = true
            end
        end

        if Step == 4 then
            Library:setStep(tostring(Step), 'Failed to analyze the game')
            Library:setColor(true)
            Library:setLog('Executing KRNL32 Universal...')
            local attempt = 1
            local maxattempt = 5
            local oldclock = os.clock()
            local newclock
            repeat wait()
                Library:setLog('Executing script in attempt ' .. tostring(attempt))
                local s,msg = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Game/Universal/source.lua', true))() end)
                if not s then
                    attempt = attempt + 1
                    err_msg = msg
                else
                    attempt = true
                    newclock = os.clock()
                    break
                end
                
            until attempt == maxattempt
            if attempt ~= true then 
                no_error = false 
                Library:setLog('Failed executing script!')
                sendErr(Step, err_msg)
            end
            if no_error then
                Library:setLog('Script executed! ' .. ('takes %0.1fs'):format(newclock - oldclock))
                Library:setColor(true)
                wait(.4)
                pass = true
            end
        end

        repeat wait() until (no_error == true and pass == true) or not no_error
        if no_error then Step = Step + 1 else error(err_msg) end
    until Step == 4 or Step == 5
    wait(2)
    CloseGui(Background)
end, function(msg)
    msg = msg:gsub(msg:match(':%d+:'), '')
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    msg = msg .. ' [stop at step ' .. err_msg[2] .. ']'
    sendErr('Oh no!', msg)
end)

if not no_error then Library:setColor(false); wait(2); CloseGui(Background) end