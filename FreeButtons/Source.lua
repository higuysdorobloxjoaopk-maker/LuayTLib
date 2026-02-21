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
	local dragging = false
	local dragInput, dragStart, startPos

	local function clampToScreen(pos)
		local camera = workspace.CurrentCamera
		if not camera then return pos end

		local screenSize = camera.ViewportSize
		local absSize = guiObject.AbsoluteSize

		local minX = 0
		local minY = 0
		local maxX = screenSize.X - absSize.X
		local maxY = screenSize.Y - absSize.Y

		local clampedX = math.clamp(pos.X.Offset, minX, maxX)
		local clampedY = math.clamp(pos.Y.Offset, minY, maxY)

		return UDim2.new(0, clampedX, 0, clampedY)
	end

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart

			local newPos = UDim2.new(
				0,
				startPos.X.Offset + delta.X,
				0,
				startPos.Y.Offset + delta.Y
			)

			guiObject.Position = clampToScreen(newPos)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local function createParticles(button, particleColor, particleType)
	local centerX = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
	local centerY = button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
	local screenGui = button.Parent

	if particleType == "explosion" then
		local count = 20
		for i = 1, count do
			local angle = math.rad(i * (360 / count) + math.random(-15, 15))
			local line = Instance.new("Frame")
			line.Size = UDim2.new(0, math.random(20, 40), 0, 3)
			line.Position = UDim2.fromOffset(centerX, centerY)
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Rotation = math.deg(angle)
			line.BackgroundColor3 = particleColor
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
		for i = 1, 18 do
			local part = Instance.new("Frame")
			part.Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
			part.Position = UDim2.fromOffset(centerX, centerY)
			part.BackgroundColor3 = particleColor
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
		for i = 1, 30 do
			local conf = Instance.new("Frame")
			conf.Size = UDim2.new(0, math.random(6, 12), 0, math.random(10, 18))
			conf.Position = UDim2.fromOffset(centerX, centerY)
			conf.BackgroundColor3 = particleColor
			conf.BorderSizePixel = 0
			conf.Rotation = math.random(0, 360)
			conf.ZIndex = 30
			conf.Parent = screenGui

			local vx = math.random(-120, 120)
			local vy = math.random(-140, -40)

			TweenService:Create(conf, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(centerX + vx, centerY + vy + 80),
				Rotation = conf.Rotation + math.random(-360, 360),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(conf, 1.5)
		end

	elseif particleType == "expanding_circles" then
		for i = 1, 12 do
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

	if buttons[id] then
		buttons[id]:Destroy()
		buttons[id] = nil
	end

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
	button.Position = UDim2.new(0, 100, 0, 100)
	button.BackgroundTransparency = 1
	button.Image = "rbxassetid://" .. tostring(imageId)
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, math.floor(buttonSize / 4))
	corner.Parent = button

	local isAnimating = false

	button.MouseButton1Click:Connect(function()
		if isAnimating then return end
		isAnimating = true

		button:TweenSize(
			UDim2.new(0, buttonSize*0.85, 0, buttonSize*0.85),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.08,
			true
		)

		task.wait(0.09)

		button:TweenSize(
			UDim2.new(0, buttonSize, 0, buttonSize),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Back,
			0.18,
			true
		)

		createParticles(button, particleColor, particleType)

		task.wait(0.2)
		isAnimating = false
	end)

	makeDraggable(button)

	buttons[id] = button
	return button
end

function ADDONVip:FREEButtonDelete(id)
	local btn = buttons[id]
	if btn then
		btn:Destroy()
		buttons[id] = nil
	end
end

return ADDONVip
