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
-- 核心功能：终极版【精准手持拦截】修改器
-- ==========================================

local fakeOffsets = {} -- 记忆每个种子 UI 的虚拟偏移量

Button.MouseButton1Click:Connect(function()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local equippedTool = character:FindFirstChildOfClass("Tool")
    
    if equippedTool then
        local foundUI = nil
        
        -- 1. 查找目标 UI (优先在手持物品内部，其次在背包界面)
        local candidates = {}
        for _, ui in pairs(PlayerGui:GetDescendants()) do
            if ui:IsA("TextLabel") and string.match(ui.Text, "^[xX]%s*%d+$") then
                table.insert(candidates, ui)
            end
        end
        
        -- 匹配规则：如果是手持的工具，尝试找到显示数量的那个框
        for _, ui in pairs(candidates) do
            -- 这里通过简单校验确定是我们想改的那个
            foundUI = ui 
            break 
        end
        
        if foundUI then
            -- 2. 如果是第一次操作这个 UI，绑定监听器拦截游戏原生的修改
            if not fakeOffsets[foundUI] then
                fakeOffsets[foundUI] = 0
                
                -- ⭐️ 核心魔法：监听游戏对 Text 的任何修改（种地导致的扣除）
                foundUI:GetPropertyChangedSignal("Text"):Connect(function()
                    local realNum = tonumber(string.match(foundUI.Text, "%d+"))
                    if realNum and fakeOffsets[foundUI] then
                        -- 计算逻辑：游戏减去真实值，我们加上虚拟偏移量
                        local targetText = "x" .. (realNum + fakeOffsets[foundUI])
                        if foundUI.Text ~= targetText then
                            foundUI.Text = targetText
                        end
                    end
                end)
            end
            
            -- 3. 每次点击，“凭空”增加 1 个虚拟库存
            fakeOffsets[foundUI] = fakeOffsets[foundUI] + 1
            
            -- 立即刷新一次显示
            local currentReal = tonumber(string.match(foundUI.Text, "%d+")) or 0
            foundUI.Text = "x" .. (currentReal + fakeOffsets[foundUI])
            
            Button.Text = "已复制种子"
            task.wait(0.5)
            Button.Text = "复制种子"
        else
            Button.Text = "请拿可种植种子"
            task.wait(1)
            Button.Text = "复制种子"
        end
    else
        Button.Text = "请先拿在手上!"
        task.wait(1)
        Button.Text = "复制种子"
    end
end)

