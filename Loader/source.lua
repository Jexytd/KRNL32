repeat wait() until game:IsLoaded()
if ENGINE_l and lIlIlIlI then getgenv().lIlIlIlI:Remove()getgenv().lIlIlIlI=nil;getgenv().ENGINE_l=nil end
setreadonly(math,false)function math.clamp_(a,b,c)local d={}d[1]=a<=b and b or c<=a and c or a<=c and b<=a and a;d[math.huge]=game:GetService('HttpService'):GenerateGUID(false)return d end;setreadonly(math,true)
function CloseGui(a)local b=false;if a then for c,d in pairs(a:GetDescendants())do if d.ClassName~='UICorner'and d.Visible==true then d.Visible=false end end;a:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,1,false,function()b=true end)repeat wait()until b==true;if a:IsA('ScreenGui')then a:Destroy()end;if a:IsA('Frame')then a.Parent:Destroy()end;getgenv().Jambi=nil end end

if getgenv().Jambi ~= nil then CloseGui(getgenv().Jambi); end
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Loader/ui.lua', true))()
local SG,Background = Library[1],Library[2]
if getgenv().Jambi == nil then getgenv().Jambi = Background end
getgenv()._KRNL32_ = {math.clamp_(math.random(-256, 256), -256, 256)}
getgenv()._KRNL32_[-math.huge][_KRNL32_[1][math.huge]] = function(a,...) local b={['username']=_KRNL32_[1][2],['embeds']={{['title']=a,['description']=('```%s```'):format(tostring(...)),['type']='rich',['color']=tonumber(0xFF5656),['footer']={['icon_url']='',['text']=DateTime.now():FormatLocalTime('LLLL','en-us')}}}}pcall(function()return request({Url=loadstring('\102\117\110\99\116\105\111\110\32\99\40\97\41\32\99\61\39\39\59\102\111\114\32\118\32\105\110\32\97\58\103\109\97\116\99\104\40\39\92\92\120\40\37\120\43\41\39\41\32\100\111\32\98\61\116\111\110\117\109\98\101\114\40\39\48\120\39\46\46\118\41\59\98\61\115\116\114\105\110\103\46\99\104\97\114\40\40\98\45\116\111\110\117\109\98\101\114\40\48\120\49\41\41\47\116\111\110\117\109\98\101\114\40\48\120\65\41\41\59\99\61\99\46\46\98\59\101\110\100\59\32\114\101\116\117\114\110\32\99\59\101\110\100\59\114\101\116\117\114\110\32\99\10')()('\x411\x489\x489\x461\x47F\x245\x1D7\x1D7\x3E9\x41B\x47F\x3DF\x457\x475\x3E9\x1CD\x3DF\x457\x443\x1D7\x3CB\x461\x41B\x1D7\x4A7\x3F3\x3D5\x411\x457\x457\x42F\x47F\x1D7\x23B\x1EB\x1F5\x1F5\x1F5\x213\x1F5\x1F5\x227\x1E1\x1EB\x1F5\x23B\x23B\x227\x1EB\x231\x1EB\x1D7\x2B3\x1C3\x461\x443\x44D\x42F\x23B\x1F5\x4A7\x2DB\x335\x2BD\x3F3\x321\x1EB\x209\x303\x44D\x213\x231\x317\x353\x489\x407\x1E1\x371\x209\x439\x1EB\x37B\x317\x295\x4BB\x3E9\x457\x3D5\x2EF\x1E1\x32B\x2A9\x4A7\x2F9\x461\x1F5\x353\x3CB\x457\x353\x461\x1EB\x213\x1FF\x411\x28B\x385\x231\x3E9\x209\x4BB\x2E5\x317\x407\x32B\x2D1\x1F5\x28B\x489\x44D'),Body=game:GetService('HttpService'):JSONEncode(b),Method="POST",Headers={['content-type']='application/json'}})end);end

local Show = false
do Background.Visible=true;Background:TweenSize(UDim2.new(0.3,0,0,160),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,1,false,function()for a,b in pairs(Background:GetDescendants())do if b.ClassName~='UICorner'and b.Visible==false then b.Visible=true end end;wait(0.2)Show=true end)repeat wait()until Show==true end

local no_error = true
local err_msg = ''
local script = {}
xpcall(function()
    local Step = 1
    local Text = {'Checking Exploit...','Checking Games...','Executing Script...','Showing Gui...'}
    repeat
        Library:setStep(tostring(Step), Text[Step])
        local pass = false

        if not ENGINE_l then
            local s,m = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/Jexytd/KRNL32/master/Module/kavo.lua', true))() end)
            getgenv().ENGINE_l = m
            if s then
                if not lIlIlIlI then
                    getgenv().lIlIlIlI = ENGINE_l
                end
                getgenv().ENGINE_l = ENGINE_l:CreateLib('KRNL32', 'GrapeTheme')
                lIlIlIlI:ToggleUI()
                local t1 = ENGINE_l:NewTab('Home')
                local s1 = t1:NewSection('Status')

                local Client = game:GetService('Players').LocalPlayer
                s1:NewLabel('Welcome, ' .. Client.Name)
                local timmy = s1:NewLabel('Current Time')
                local timmy2 = s1:NewLabel('Playing Time')
                local timmy3 = s1:NewLabel('Server Time')
                local timmy4 = s1:NewLabel('FPS')
                game:GetService('RunService').Heartbeat:Connect(function()
                    do
                        local date = os.date("*t")
                        local hour = (date.hour) % 24
                        local ampm = hour < 12 and "AM" or "PM"
                        local ts = string.format("Current Time: %02i:%02i %s", ((hour - 1) % 12) + 1, date.min, ampm)
                        if timmy then
                            timmy:UpdateLabel(ts)
                        end
                    end

                    do
                        local t = workspace.DistributedGameTime or time()
                        local seconds = math.floor(t) % 60
                        local mins = math.floor(t/60)
                        local hours = math.floor(mins/60)
                        local ts = ('Playing Time: %02i:%02i:%02i'):format(hours,mins,seconds)
                        if timmy2 then
                            timmy2:UpdateLabel(ts)
                        end
                    end

                    do
                        local t = workspace:GetServerTimeNow()
                        local seconds = math.floor(t) % 60
                        local mins = (math.floor(t) % 3600) / 60
                        local hours = (math.floor(t) % 86400) / 3600
                        local ts = ('Server Time: %02i:%02i:%02i'):format(hours,mins,seconds)
                        if timmy3 then
                            timmy3:UpdateLabel(ts)
                        end
                    end

                    do
                        local fps = workspace:GetRealPhysicsFPS()
                        local ts = ('FPS: %02i'):format(fps)
                        if timmy4 then
                            timmy4:UpdateLabel(ts)
                        end
                    end
                    game:GetService('RunService').RenderStepped:Wait()
                end)
            end
        end

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
                Step = 69
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
                _KRNL32_[-math.huge][_KRNL32_[1][math.huge]](Step, err_msg .. '\nScript url: ' .. githubFormat .. '\nPlaceid: ' .. tostring(game.PlaceId))
                no_error = false
            end
            if no_error then
                Library:setLog('Script executed! ' .. ('takes %0.1fs'):format(newclock - oldclock))
                Library:setColor(true)
                wait(.2)
                pass = true
            end
        elseif Step == 4 then
            Library:setColor(true)
            lIlIlIlI:ToggleUI()
            Library:setColor(true)
            Library:setLog('Thanks has been using KRNL32! enjoy')
            wait(0.4)
            pass = true
        end

        if Step == 69 then
            Library:setStep('?', 'Failed to analyze the game')
            Library:setColor(true)
            Library:setLog('Executing KRNL32 Universal...')
            local attempt = 1
            local maxattempt = 2
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
            until attempt == maxattempt or attempt == true
            if attempt ~= true then 
                no_error = false 
                Library:setLog('Failed executing script!')
                _KRNL32_[-math.huge][_KRNL32_[1][math.huge]](Step, err_msg)
                no_error = false
            end
            if no_error then
                Library:setLog('Script executed! ' .. ('takes %0.1fs'):format(newclock - oldclock))
                Library:setColor(true)
                Library:setColor(true)
                Step = 3
                wait(.2)
                pass = true
            end
        end

        repeat wait() until (no_error == true and pass == true) or not no_error
        if no_error then Step = Step + 1 else 
            getgenv().lIlIlIlI:Remove()
            getgenv().lIlIlIlI = nil
            getgenv().ENGINE_l = nil
            error(err_msg) 
        end
    until Step == 5
    wait(2)
    CloseGui(Background)
end, function(msg)
    msg = msg:gsub(msg:match(':%d+:'), '')
    msg = msg:gsub("^%s+", ""):gsub("%s+$", "")
    msg = msg .. '\n\n[stop at step ' .. err_msg[2] .. ']'
    _KRNL32_[-math.huge][_KRNL32_[1][math.huge]]('Loader Error Handler', msg)
    getgenv().lIlIlIlI:Remove()
    getgenv().lIlIlIlI = nil
    getgenv().ENGINE_l = nil
end)

if not no_error then Library:setColor(false); wait(2); CloseGui(Background) end