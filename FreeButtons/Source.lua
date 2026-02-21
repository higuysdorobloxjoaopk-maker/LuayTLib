-- by grok ia
-- vibe code
local ADDONVip = {}
ADDONVip.__index = ADDONVip

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local buttons = {}

local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			local conn; conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function createParticles(button, particleColor, particleType)
	local centerX = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
	local centerY = button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
	local screenGui = button.Parent

	local particleCount = 0
	local maxParticles = 25

	if particleType == "explosion" then
		particleCount = 20
		for i = 1, particleCount do
			local angle = math.rad(i * (360 / particleCount) + math.random(-15, 15))
			local line = Instance.new("Frame")
			line.Size = UDim2.new(0, math.random(20, 40), 0, 3)
			line.Position = UDim2.fromOffset(centerX, centerY)
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Rotation = math.deg(angle)
			line.BackgroundColor3 = particleColor
			line.BackgroundTransparency = 0
			line.BorderSizePixel = 0
			line.ZIndex = 30
			line.Parent = screenGui

			local dist = math.random(70, 140)
			local tx = centerX + math.cos(angle) * dist
			local ty = centerY + math.sin(angle) * dist

			TweenService:Create(line, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(tx, ty),
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(line, 0.9)
		end

	elseif particleType == "volcano" then
		particleCount = 18
		for i = 1, particleCount do
			local angle = math.rad(math.random(-60, 60))
			local part = Instance.new("Frame")
			part.Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
			part.Position = UDim2.fromOffset(centerX, centerY)
			part.BackgroundColor3 = particleColor
			part.BackgroundTransparency = 0.2
			part.BorderSizePixel = 0
			part.ZIndex = 30
			part.Parent = screenGui

			local corner = Instance.new("UICorner", part)
			corner.CornerRadius = UDim.new(1, 0)

			local vy = math.random(-180, -100)
			local vx = math.random(-60, 60)

			TweenService:Create(part, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(centerX + vx, centerY + vy),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 4, 0, 4)
			}):Play()

			Debris:AddItem(part, 1.1)
		end

	elseif particleType == "confetti" then
		particleCount = 30
		for i = 1, particleCount do
			local conf = Instance.new("Frame")
			conf.Size = UDim2.new(0, math.random(6, 12), 0, math.random(10, 18))
			conf.Position = UDim2.fromOffset(centerX, centerY)
			conf.BackgroundColor3 = particleColor
			conf.BackgroundTransparency = 0
			conf.BorderSizePixel = 0
			conf.Rotation = math.random(0, 360)
			conf.ZIndex = 30
			conf.Parent = screenGui

			local vx = math.random(-120, 120)
			local vy = math.random(-140, -40)

			TweenService:Create(conf, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(centerX + vx, centerY + vy + 80),  -- cai um pouco
				Rotation = conf.Rotation + math.random(-360, 360),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(conf, 1.5)
		end

	elseif particleType == "expanding_circles" or particleType == "expanding circles" then
		particleCount = 12
		for i = 1, particleCount do
			local circle = Instance.new("Frame")
			circle.Size = UDim2.new(0, 10, 0, 10)
			circle.Position = UDim2.fromOffset(centerX, centerY)
			circle.AnchorPoint = Vector2.new(0.5, 0.5)
			circle.BackgroundColor3 = particleColor
			circle.BackgroundTransparency = 0.3
			circle.BorderSizePixel = 0
			circle.ZIndex = 30
			circle.Parent = screenGui

			local corner = Instance.new("UICorner", circle)
			corner.CornerRadius = UDim.new(1, 0)

			TweenService:Create(circle, TweenInfo.new(0.9, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 120, 0, 120),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(circle, 1.2)
		end
	end
end

function ADDONVip:FREEButtonCreate(config)

	local id = config.id or "default_button"
	local imageId = config.image or 114403076249281
	local buttonSize = config.size or 37
	local color = config.colorparticle or {255, 255, 255}
	local particleType = (config.typeparticle or "explosion"):lower()

	local particleColor = Color3.fromRGB(color[1], color[2], color[3])

	local screenGuiName = "AddonVipGui"
	local screenGui = playerGui:FindFirstChild(screenGuiName)
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = screenGuiName
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
	end

	local button = Instance.new("ImageButton")
	button.Name = "VipButton_" .. id
	button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	button.Position = UDim2.new(0.5, -buttonSize/2, 0.5, -buttonSize/2)
	button.BackgroundTransparency = 1
	button.Image = "rbxassetid://" .. tostring(imageId)
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, math.floor(buttonSize / 4))
	corner.Parent = button

	button.MouseButton1Click:Connect(function()

		local origSize = button.Size
		TweenService:Create(button, TweenInfo.new(0.08), {Size = UDim2.new(0, buttonSize*0.82, 0, buttonSize*0.82)}):Play()
		task.wait(0.09)
		TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Size = origSize}):Play()

		createParticles(button, particleColor, particleType)
	end)

	makeDraggable(button)

	buttons[id] = button

	print("[ADDONVip] Botão criado: " .. id .. " | Tipo: " .. particleType)
	return button
end

function ADDONVip:FREEButtonDelete(id)
	local btn = buttons[id]
	if btn then
		btn:Destroy()
		buttons[id] = nil
		print("[ADDONVip] Botão deletado: " .. id)
	else
		warn("[ADDONVip] Botão não encontrado: " .. tostring(id))
	end
end

return ADDONVip
