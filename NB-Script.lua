local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Gui = Instance.new("ScreenGui")
Gui.Name = "NBGUI"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Parent = Gui
Frame.Size = UDim2.new(0,220,0,80)
Frame.Position = UDim2.new(0.5,-110,0.5,-40)
Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true

Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1,0,0,25)
Title.BackgroundTransparency = 1
Title.Text = "NB-Script"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextColor3 = Color3.new(1,1,1)

local Button = Instance.new("TextButton")
Button.Parent = Frame
Button.Position = UDim2.new(0,10,0,35)
Button.Size = UDim2.new(1,-20,0,35)
Button.Text = "复制种子"
Button.Font = Enum.Font.GothamBold
Button.TextScaled = true
Button.TextColor3 = Color3.new(1,1,1)
Button.BackgroundColor3 = Color3.fromRGB(55,55,55)
Button.BorderSizePixel = 0

Instance.new("UICorner",Button).CornerRadius = UDim.new(0,8)

-- 拖动逻辑
local dragging = false
local dragStart
local startPos

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

----------------------------------------------------
-- 🛠️ 下面是为你添加的【五颜六色霓虹变色】核心代码
----------------------------------------------------
task.spawn(function()
	local hue = 0
	while true do
		-- hue 从 0 到 1 循环，代表彩虹的所有颜色
		hue = hue + 0.01
		if hue > 1 then
			hue = 0
		end
		
		-- 参数解释: fromHSV(色相, 饱和度, 亮度)
		Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
		
		-- 变色速度控制：数字越小变色越快
		task.wait(0.02) 
	end
end)

-- 复制种子的点击事件（在这里写上你原本的功能逻辑就行）
Button.MouseButton1Click:Connect(function()
	print("复制种子按钮被点击了！")
end)
