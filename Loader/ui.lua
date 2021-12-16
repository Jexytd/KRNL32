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

function textTransparency(a)if not a then return false end;local b=game:GetService('TweenService')local function c(d,e,f)local d=d or 0.6;local e=e or Enum.EasingStyle.Linear;local g=f or Enum.EasingDirection.InOut;return TweenInfo.new(d,e,g)end;if not fadeDebounce[2]and(fadeDebounce[1]==a or fadeDebounce==nil)then local h=c()local i=b:Create(a,h,{TextTransparency=0})i.Completed:Connect(function()fadeDebounce={a,true}end)i:Play()repeat wait()until fadeDebounce[2]==true and fadeDebounce[1]==a elseif fadeDebounce[2]and fadeDebounce[1]==a then local h=c()local i=b:Create(fadeDebounce[1],h,{TextTransparency=1})i.Completed:Connect(function()fadeDebounce={nil,false}end)i:Play()repeat wait()until fadeDebounce[2]==false and not fadeDebounce[1]end end
function Library:setColor(a)if type(a)~='boolean'then return end;local b=game:GetService('TweenService')local function c(d,e,f)local d=d or 0.6;local e=e or Enum.EasingStyle.Linear;local g=f or Enum.EasingDirection.InOut;return TweenInfo.new(d,e,g)end;local h=Round.BackgroundColor3==Color3.fromRGB(69,69,230)if a and Round.BackgroundColor3==Color3.fromRGB(69,69,230)then local i=b:Create(Round,c(),{BackgroundColor3=Color3.fromRGB(69,230,69)})local j=false;i.Completed:Connect(function()j=true end)i:Play()repeat wait()until j end;if a and not h then local i=b:Create(Round,c(),{BackgroundColor3=Color3.fromRGB(69,69,230)})local j=false;i.Completed:Connect(function()j=true end)i:Play()repeat wait()until j end;if not a then local i=b:Create(Round,c(),{BackgroundColor3=Color3.fromRGB(230,69,69)})local j=false;i.Completed:Connect(function()j=true end)i:Play()repeat wait()until j end end

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

return Library