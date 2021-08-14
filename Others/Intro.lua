local Client = game:GetService('Players').LocalPlayer
local GuiService = Client:FindFirstChild('PlayerGui') or game:GetService('CoreGui')
local HttpService,StarterGui,TweenService = game:GetService("HttpService"), game:GetService('StarterGui'), game:GetService('TweenService')
local Camera = workspace.CurrentCamera

local Name = 'NAVI HUB'
Done = false

a = {}
function a:new(name, properties, children)
	local obj = Instance.new(name)
	local prop, child = properties or {}, children or {}
	for key,val in pairs(prop) do
		obj[key] = val
	end
	for key,val in pairs(child) do
		val.Parent = obj
	end
	return obj
end

local Screen = a:new('ScreenGui', {
	Parent = GuiService,
	Name = HttpService:GenerateGUID(false)
}, {
	a:new('ImageLabel', {
		Name = 'Background',
		--Size = UDim2.new(0, 180, 0, 60),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		
		Image = 'rbxassetid://3570695787',
		ImageColor3 = Color3.fromRGB(50, 50, 50),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = 0.040
	}, {
		a:new('TextLabel', {
			Name = 'Name',
			Text = Name or 'Loaded',
			TextColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			TextTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Visible = false
		})
	})
})

repeat wait() until (Screen and game:IsLoaded())
wait(1)
local BackgroundSize = UDim2.new(0, 180, 0, 60)
local Tween = TweenService:Create(Screen.Background, TweenInfo.new(.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = BackgroundSize})
Tween:Play()
Tween.Completed:wait()

for idx,val in pairs(Screen.Background:GetChildren()) do
	val.Visible = true
	local Tween = TweenService:Create(val, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 0})
	Tween:Play()
	Tween.Completed:wait()
	
	spawn(function()
		while (Done == false) do
			val.TextColor3 = Color3.new(math.random(),math.random(),math.random())
			wait(.4)
			val.TextStrokeColor3 = Color3.new(math.random(),math.random(),math.random())
		end
	end)
	
	wait(2)
	Done = true
	
	local Tween = TweenService:Create(val, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1})
	Tween:Play()
	Tween.Completed:wait()
end

repeat wait() until Done == true

local Tween = TweenService:Create(Screen.Background, TweenInfo.new(.7, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0)})
Tween:Play()
Tween.Completed:wait()
Screen.Background.Visible = false

Screen:Destroy()

return Done;