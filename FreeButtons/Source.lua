-- ADDONVip Library (versão corrigida: sem crescimento infinito, posição reset ao recriar, arrastar dentro da tela)

local ADDONVip = {}
ADDONVip.__index = ADDONVip

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local buttons = {}          -- armazena botões por ID
local lastClickTime = {}    -- debounce por botão

-- Função auxiliar: limita posição para não sair da tela
local function clampToScreen(guiObject)
	local absSize = guiObject.AbsoluteSize
	local screenSize = workspace.CurrentCamera.ViewportSize

	local function onRender()
		local pos = guiObject.Position
		local offsetX = pos.X.Offset
		local offsetY = pos.Y.Offset

		local clampedX = math.clamp(offsetX, 0, screenSize.X - absSize.X)
		local clampedY = math.clamp(offsetY, 0, screenSize.Y - absSize.Y)

		if clampedX \~= offsetX or clampedY \~= offsetY then
			guiObject.Position = UDim2.new(0, clampedX, 0, clampedY)
		end
	end

	-- Conecta só uma vez por objeto
	if not guiObject:GetAttribute("Clamped") then
		guiObject:SetAttribute("Clamped", true)
		RunService.RenderStepped:Connect(onRender)
	end
end

-- Torna arrastável + clamp na tela (mobile + PC)
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
			-- clamp imediato durante drag
			clampToScreen(guiObject)
		end
	end)

	-- Garante clamp final após soltar
	guiObject.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			clampToScreen(guiObject)
		end
	end)

	clampToScreen(guiObject) -- clamp inicial
end

-- Cria partículas (igual antes, mas com cor como Color3)
local function createParticles(button, particleColor, particleType)
	local centerX = button.AbsolutePosition.X + button.AbsoluteSize.X / 2
	local centerY = button.AbsolutePosition.Y + button.AbsoluteSize.Y / 2
	local screenGui = button.Parent

	local particleCount = 0

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

			TweenService:Create(line, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
				Position = UDim2.fromOffset(tx, ty),
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(line, 0.9)
		end

	elseif particleType == "volcano" then
		-- (mantido igual, adicionei só pra completar)
		particleCount = 18
		for i = 1, particleCount do
			local angle = math.rad(math.random(-60, 60))
			local part = Instance.new("Frame")
			part.Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
			part.Position = UDim2.fromOffset(centerX, centerY)
			part.BackgroundColor3 = particleColor
			part.BackgroundTransparency = 0.2
			part.ZIndex = 30
			part.Parent = screenGui

			Instance.new("UICorner", part).CornerRadius = UDim.new(1, 0)

			local vy = math.random(-180, -100)
			local vx = math.random(-60, 60)

			TweenService:Create(part, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
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
			conf.Rotation = math.random(0, 360)
			conf.ZIndex = 30
			conf.Parent = screenGui

			local vx = math.random(-120, 120)
			local vy = math.random(-140, -40)

			TweenService:Create(conf, TweenInfo.new(1.2, Enum.EasingStyle.Sine), {
				Position = UDim2.fromOffset(centerX + vx, centerY + vy + 80),
				Rotation = conf.Rotation + math.random(-720, 720),
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
			circle.ZIndex = 30
			circle.Parent = screenGui

			Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

			TweenService:Create(circle, TweenInfo.new(0.9, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0, 120, 0, 120),
				BackgroundTransparency = 1
			}):Play()

			Debris:AddItem(circle, 1.2)
		end
	end
end

-- Cria ou recria botão
function ADDONVip:FREEButtonCreate(config)
	local id = config.id or "default_" .. math.random(1000,9999)
	local imageId = config.image or 114403076249281
	local buttonSize = config.size or 37
	local colorTbl = config.colorparticle or {255, 255, 255}
	local particleType = (config.typeparticle or "explosion"):lower()

	local particleColor = Color3.fromRGB(colorTbl[1], colorTbl[2], colorTbl[3])

	-- Deleta botão antigo com mesmo ID (evita posição antiga)
	if buttons[id] then
		self:FREEButtonDelete(id)
	end

	-- ScreenGui
	local screenGuiName = "AddonVipGui"
	local screenGui = playerGui:FindFirstChild(screenGuiName) or Instance.new("ScreenGui")
	screenGui.Name = screenGuiName
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Cria botão novo (sempre centralizado)
	local button = Instance.new("ImageButton")
	button.Name = "VipButton_" .. id
	button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
	button.Position = UDim2.new(0.5, -buttonSize/2, 0.5, -buttonSize/2)  -- sempre centro ao criar
	button.BackgroundTransparency = 1
	button.Image = "rbxassetid://" .. tostring(imageId)
	button.Parent = screenGui

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, math.floor(buttonSize / 4))

	-- Debounce clique (evita spam e crescimento infinito)
	button.MouseButton1Click:Connect(function()
		local now = tick()
		if lastClickTime[id] and now - lastClickTime[id] < 0.3 then
			return  -- ignora cliques muito rápidos
		end
		lastClickTime[id] = now

		-- Animação de clique (sem acumular)
		local origSize = button.Size
		local tweenDown = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, buttonSize * 0.82, 0, buttonSize * 0.82)
		})
		tweenDown:Play()
		tweenDown.Completed:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = origSize
			}):Play()
		end)

		-- Partículas
		createParticles(button, particleColor, particleType)
	end)

	-- Arrastar + clamp na tela
	makeDraggable(button)

	buttons[id] = button

	print("[ADDONVip] Botão criado/recarregado: " .. id .. " | Tipo: " .. particleType)
	return button
end

-- Deleta botão
function ADDONVip:FREEButtonDelete(id)
	local btn = buttons[id]
	if btn then
		btn:Destroy()
		buttons[id] = nil
		lastClickTime[id] = nil
		print("[ADDONVip] Botão deletado: " .. id)
	else
		warn("[ADDONVip] Botão não encontrado: " .. tostring(id))
	end
end

return ADDONVip
