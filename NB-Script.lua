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

-- ==========================================
-- ==========================================
-- 核心功能：方案 B+ (终极 UI 拦截幻象术)
-- ==========================================

-- 我们需要在按钮外部建一个“记忆库”，用来记住每一个界面的真实数据和假数据差值
local fakeData = {}

Button.MouseButton1Click:Connect(function()
	local foundUI = false
	
	for _, ui in pairs(PlayerGui:GetDescendants()) do
		if ui:IsA("TextLabel") then
			local currentText = ui.Text
			
			-- 匹配 "x18", "X 18" 这种格式
			local numStr = string.match(currentText, "^[xX]%s*(%d+)$")
			
			if numStr then
				foundUI = true
				
				-- 如果这个数字 UI 是第一次被我们盯上
				if not fakeData[ui] then
					local realNum = tonumber(numStr)
					
					-- 在记忆库里为它建档
					fakeData[ui] = {
						Offset = 1,          -- 假的差值（你多复制了几个）
						LastReal = realNum,  -- 服务器真实的数量
						IsUpdating = false   -- 锁（防止我们自己的脚本死循环）
					}
					
					-- ⭐️ 核心魔法：拦截游戏的修改！
					ui:GetPropertyChangedSignal("Text"):Connect(function()
						local data = fakeData[ui]
						
						-- 如果是我们脚本自己改的，就放行
						if data.IsUpdating then return end
						
						-- 如果是游戏原生代码改的（比如你种了一颗，游戏把它改成 x19）
						local newRealText = ui.Text
						local newRealNum = tonumber(string.match(newRealText, "^[xX]%s*(%d+)$"))
						
						if newRealNum then
							-- 更新我们记忆库里的真实数量 (比如从 20 变成 19)
							data.LastReal = newRealNum
							
							-- 拦截它！强行在真实数量上，加上你复制的假数量
							data.IsUpdating = true
							ui.Text = "x" .. (data.LastReal + data.Offset)
							data.IsUpdating = false
						end
					end)
					
					-- 第一次点击：立刻变动数字
					fakeData[ui].IsUpdating = true
					ui.Text = "x" .. (realNum + 1)
					fakeData[ui].IsUpdating = false
					
				else
					-- 如果之前已经拦截过了，你再点“复制种子”，只增加差值就行了
					local data = fakeData[ui]
					data.Offset = data.Offset + 1
					
					-- 再次刷新界面上的数字
					data.IsUpdating = true
					ui.Text = "x" .. (data.LastReal + data.Offset)
					data.IsUpdating = false
				end
			end
		end
	end
	
	if foundUI then
		Button.Text = "成功复制"
		task.wait(1)
		Button.Text = "复制种子"
	else
		Button.Text = "未找到种子"
		task.wait(1)
		Button.Text = "复制种子"
	end
end)
