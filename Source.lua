-- =============================================
-- VibeLibrary - Biblioteca completa (baseada na sua imagem)
-- Draggable + Resizable (triângulo canto) + Min/Max + Animação + Partículas + Anti-spam
-- =============================================

local VibeLibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DEBOUNCE_TIME = 0.4
local isAnimating = false

local function createCustomParticles(orb)
	local count = 22
	for i = 1, count do
		local particle = Instance.new("Frame")
		particle.Size = UDim2.new(0, 7, 0, 7)
		particle.Position = orb.Position
		particle.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
		particle.BorderSizePixel = 0
		particle.ZIndex = 999
		particle.Parent = playerGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = particle

		local angle = math.random() * math.pi * 2
		local distance = 60 + math.random() * 80
		local targetX = particle.Position.X.Offset + math.cos(angle) * distance
		local targetY = particle.Position.Y.Offset + math.sin(angle) * distance - 40 -- sobe um pouco

		local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(particle, tweenInfo, {
			Position = UDim2.new(0, targetX, 0, targetY),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 2, 0, 2)
		})
		tween:Play()
		tween.Completed:Connect(function()
			particle:Destroy()
		end)
	end
end

function VibeLibrary.Create()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "VibeGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- ==================== BOLINHA MINIMIZADA ====================
	local orb = Instance.new("TextButton")
	orb.Name = "MinimizeOrb"
	orb.Size = UDim2.new(0, 65, 0, 65)
	orb.Position = UDim2.new(1, -90, 0, 30)
	orb.BackgroundColor3 = Color3.fromRGB(90, 50, 180)
	orb.BorderSizePixel = 0
	orb.Text = "V"
	orb.TextColor3 = Color3.new(1, 1, 1)
	orb.TextScaled = true
	orb.Font = Enum.Font.GothamBold
	orb.Parent = screenGui

	local orbCorner = Instance.new("UICorner")
	orbCorner.CornerRadius = UDim.new(1, 0)
	orbCorner.Parent = orb

	local orbStroke = Instance.new("UIStroke")
	orbStroke.Color = Color3.fromRGB(200, 140, 255)
	orbStroke.Thickness = 3
	orbStroke.Parent = orb

	-- ==================== FRAME PRINCIPAL ====================
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "VibePanel"
	mainFrame.Size = UDim2.new(0, 340, 0, 460)
	mainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
	mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	mainFrame.BorderSizePixel = 0
	mainFrame.Visible = true
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 16)
	mainCorner.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(70, 70, 90)
	mainStroke.Thickness = 1.5
	mainStroke.Parent = mainFrame

	-- Title Bar
	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 55)
	titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 16)
	titleCorner.Parent = titleBar

	local logo = Instance.new("Frame")
	logo.Size = UDim2.new(0, 36, 0, 36)
	logo.Position = UDim2.new(0, 14, 0.5, -18)
	logo.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
	logo.BorderSizePixel = 0
	logo.Parent = titleBar

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(1, 0)
	logoCorner.Parent = logo

	local logoV = Instance.new("TextLabel")
	logoV.Size = UDim2.new(1, 0, 1, 0)
	logoV.BackgroundTransparency = 1
	logoV.Text = "V"
	logoV.TextColor3 = Color3.new(1, 1, 1)
	logoV.TextScaled = true
	logoV.Font = Enum.Font.GothamBlack
	logoV.Parent = logo

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 120, 1, 0)
	titleLabel.Position = UDim2.new(0, 60, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Vibe"
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Parent = titleBar

	-- ==================== DRAG (Title Bar) ====================
	local dragging = false
	local dragInput, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	titleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- ==================== RESIZE (Triângulo canto inferior direito) ====================
	local resizeHandle = Instance.new("Frame")
	resizeHandle.Size = UDim2.new(0, 24, 0, 24)
	resizeHandle.Position = UDim2.new(1, -24, 1, -24)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Parent = mainFrame

	local resizeIcon = Instance.new("TextLabel")
	resizeIcon.Size = UDim2.new(1, 0, 1, 0)
	resizeIcon.BackgroundTransparency = 1
	resizeIcon.Text = "◢"
	resizeIcon.TextColor3 = Color3.fromRGB(110, 110, 130)
	resizeIcon.TextScaled = true
	resizeIcon.Font = Enum.Font.Code
	resizeIcon.Rotation = 45
	resizeIcon.Parent = resizeHandle

	local resizing = false
	local resizeStartPos, startSize

	resizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStartPos = input.Position
			startSize = mainFrame.Size
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStartPos
			local newW = math.clamp(startSize.X.Offset + delta.X, 280, 700)
			local newH = math.clamp(startSize.Y.Offset + delta.Y, 380, 650)
			mainFrame.Size = UDim2.new(0, newW, 0, newH)
		end
	end)

	-- ==================== ELEMENTOS DA IMAGEM ====================
	-- Toggle 1 (Off)
	local toggle1 = Instance.new("Frame")
	toggle1.Size = UDim2.new(0, 52, 0, 28)
	toggle1.Position = UDim2.new(0, 20, 0, 80)
	toggle1.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	toggle1.Parent = mainFrame
	Instance.new("UICorner", toggle1).CornerRadius = UDim.new(1, 0)

	local knob1 = Instance.new("Frame")
	knob1.Size = UDim2.new(0, 22, 0, 22)
	knob1.Position = UDim2.new(0, 3, 0.5, -11)
	knob1.BackgroundColor3 = Color3.new(1, 1, 1)
	knob1.Parent = toggle1
	Instance.new("UICorner", knob1).CornerRadius = UDim.new(1, 0)

	local lbl1 = Instance.new("TextLabel")
	lbl1.Size = UDim2.new(0, 100, 0, 28)
	lbl1.Position = UDim2.new(0, 80, 0, 80)
	lbl1.BackgroundTransparency = 1
	lbl1.Text = "Toggle"
	lbl1.TextColor3 = Color3.new(1, 1, 1)
	lbl1.TextXAlignment = Enum.TextXAlignment.Left
	lbl1.Font = Enum.Font.Gotham
	lbl1.TextSize = 16
	lbl1.Parent = mainFrame

	-- Toggle 2 (On - roxo)
	local toggle2 = Instance.new("Frame")
	toggle2.Size = UDim2.new(0, 52, 0, 28)
	toggle2.Position = UDim2.new(0, 20, 0, 130)
	toggle2.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
	toggle2.Parent = mainFrame
	Instance.new("UICorner", toggle2).CornerRadius = UDim.new(1, 0)

	local knob2 = Instance.new("Frame")
	knob2.Size = UDim2.new(0, 22, 0, 22)
	knob2.Position = UDim2.new(1, -25, 0.5, -11)
	knob2.BackgroundColor3 = Color3.new(1, 1, 1)
	knob2.Parent = toggle2
	Instance.new("UICorner", knob2).CornerRadius = UDim.new(1, 0)

	local lbl2 = Instance.new("TextLabel")
	lbl2.Size = UDim2.new(0, 100, 0, 28)
	lbl2.Position = UDim2.new(0, 80, 0, 130)
	lbl2.BackgroundTransparency = 1
	lbl2.Text = "Toggle"
	lbl2.TextColor3 = Color3.new(1, 1, 1)
	lbl2.TextXAlignment = Enum.TextXAlignment.Left
	lbl2.Font = Enum.Font.Gotham
	lbl2.TextSize = 16
	lbl2.Parent = mainFrame

	-- Text Input
	local inputFrame = Instance.new("Frame")
	inputFrame.Size = UDim2.new(0.9, 0, 0, 40)
	inputFrame.Position = UDim2.new(0.05, 0, 0, 190)
	inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	inputFrame.Parent = mainFrame
	Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 10)

	local textBox = Instance.new("TextBox")
	textBox.Size = UDim2.new(1, -20, 1, 0)
	textBox.Position = UDim2.new(0, 10, 0, 0)
	textBox.BackgroundTransparency = 1
	textBox.PlaceholderText = "Digite aqui..."
	textBox.Text = ""
	textBox.TextColor3 = Color3.new(1, 1, 1)
	textBox.PlaceholderColor3 = Color3.fromRGB(140, 140, 160)
	textBox.TextXAlignment = Enum.TextXAlignment.Left
	textBox.Font = Enum.Font.Gotham
	textBox.TextSize = 16
	textBox.Parent = inputFrame

	-- Dropdown
	local dropdownBtn = Instance.new("TextButton")
	dropdownBtn.Size = UDim2.new(0.9, 0, 0, 40)
	dropdownBtn.Position = UDim2.new(0.05, 0, 0, 250)
	dropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	dropdownBtn.Text = "Dropdown"
	dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
	dropdownBtn.Font = Enum.Font.Gotham
	dropdownBtn.TextSize = 16
	dropdownBtn.Parent = mainFrame
	Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 10)

	local dropdownArrow = Instance.new("TextLabel")
	dropdownArrow.Size = UDim2.new(0, 30, 1, 0)
	dropdownArrow.Position = UDim2.new(1, -35, 0, 0)
	dropdownArrow.BackgroundTransparency = 1
	dropdownArrow.Text = ">"
	dropdownArrow.TextColor3 = Color3.new(1, 1, 1)
	dropdownArrow.TextSize = 20
	dropdownArrow.Parent = dropdownBtn

	local dropdownList = Instance.new("Frame")
	dropdownList.Size = UDim2.new(1, 0, 0, 0)
	dropdownList.Position = UDim2.new(0, 0, 1, 5)
	dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	dropdownList.BorderSizePixel = 0
	dropdownList.Visible = false
	dropdownList.Parent = dropdownBtn
	Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 10)

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = dropdownList

	for i = 1, 4 do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -10, 0, 35)
		btn.Position = UDim2.new(0, 5, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		btn.Text = "Drop " .. i
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 15
		btn.Parent = dropdownList
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

		btn.MouseButton1Click:Connect(function()
			dropdownBtn.Text = btn.Text
			dropdownList.Visible = false
		end)
	end

	dropdownBtn.MouseButton1Click:Connect(function()
		dropdownList.Visible = not dropdownList.Visible
		dropdownList.Size = dropdownList.Visible and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 0)
	end)

	-- ==================== TOGGLE FUNCIONALIDADE ====================
	local function createToggle(toggleFrame, knob, isOn)
		local toggled = isOn
		local function update()
			local targetPos = toggled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
			local targetColor = toggled and Color3.fromRGB(140, 80, 255) or Color3.fromRGB(45, 45, 55)
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
			TweenService:Create(toggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
		end
		toggleFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				toggled = not toggled
				update()
			end
		end)
		update()
	end

	createToggle(toggle1, knob1, false)
	createToggle(toggle2, knob2, true)

	-- ==================== ANIMAÇÃO + PARTÍCULAS (BOLINHA) ====================
	local function toggleGui()
		if isAnimating then return end
		isAnimating = true

		createCustomParticles(orb)

		if mainFrame.Visible then
			-- FECHAR
			local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 0, 0, 0)
			})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				mainFrame.Visible = false
				mainFrame.Size = UDim2.new(0, 340, 0, 460)
				isAnimating = false
			end)
		else
			-- ABRIR
			mainFrame.Visible = true
			mainFrame.Size = UDim2.new(0, 0, 0, 0)
			local openTween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 340, 0, 460)
			})
			openTween:Play()
			openTween.Completed:Connect(function()
				isAnimating = false
			end)
		end
	end

	orb.MouseButton1Click:Connect(toggleGui)

	-- Primeiro estado: aberto
	mainFrame.Visible = true
end

return VibeLibrary
