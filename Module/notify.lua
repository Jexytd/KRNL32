--# this soon will be reworking (dont know what time)
return (function(properties)
    if type(properties) ~= 'table' then return print('Argument [1] is table expected!, got ' .. type(properties)) end

    local Notifier = Instance.new('ScreenGui')
    local Background = Instance.new('Frame')
    local TitleNotifier = Instance.new('TextLabel')
    local TextNotifier = Instance.new('TextLabel')
    local UICorner = Instance.new("UICorner")

    local title,teks = properties['title'],properties['text']
    local t = properties['time']

    local function Gen()
        return game:GetService('HttpService'):GenerateGUID(false)
    end

    Notifier.Name = Gen()
    Notifier.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    Notifier.ZIndexBehavior = Enum.ZIndexBehavior.Global

    UICorner.Parent = Background
    Background.Parent = Notifier
    Background.Name = Gen()
    Background.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Background.BorderSizePixel = 0
    Background.AnchorPoint = Vector2.new(0.5, 0.5)
    Background.Position = UDim2.new(0.5,0, -1,0)
    Background.Size = UDim2.new(0, 304,0, 62)
    Background.ZIndex = 9999999

    TitleNotifier.Parent = Background
    TitleNotifier.Name = Gen()
    TitleNotifier.BackgroundTransparency = 1
    TitleNotifier.Size = UDim2.new(1,0, 0, 25)
    TitleNotifier.Position = UDim2.new(0,0,0.03,0)
    TitleNotifier.Font = Enum.Font.GothamBold
    TitleNotifier.TextColor3 = Color3.fromRGB(170, 85, 255)
    TitleNotifier.TextWrapped = true
    TitleNotifier.TextSize = 12
    TitleNotifier.Text = '[' .. (title or Gen()) .. ']'
    TitleNotifier.ZIndex = 9999999

    TextNotifier.Parent = Background
    TextNotifier.Name = Gen()
    TextNotifier.BackgroundTransparency = 1
    TextNotifier.Size = UDim2.new(0.9, 0, 0,31)
    TextNotifier.Position = TitleNotifier.Position + UDim2.new(0.05,0,0.42,0)
    TextNotifier.Font = Enum.Font.Gotham
    TextNotifier.TextColor3 = Color3.fromRGB(170, 85, 255)
    TextNotifier.TextWrapped = true
    TextNotifier.TextSize = 12
    TextNotifier.Text = (teks or 'Made in KRNL')
    TextNotifier.ZIndex = 9999999
    Background:TweenPosition(
    	UDim2.new(0.5, 0, 0, 0),           
    	Enum.EasingDirection.In, 
    	Enum.EasingStyle.Sine,   
    	1                       
    )
    wait(t or 2)
    Background:TweenPosition(
    	UDim2.new(0.5, 0, -1, 0),           
    	Enum.EasingDirection.In, 
    	Enum.EasingStyle.Sine,   
    	1                       
    )
    wait(2)
    Notifier:Destroy()
end)