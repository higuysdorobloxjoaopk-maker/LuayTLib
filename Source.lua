-- =============================================
-- ggPro Library v1.0 
-- =============================================

local ggPro = {}
ggPro.__index = ggPro

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Temas (Light = sua imagem, Dark = modo escuro)
local Themes = {
	Light = {
		MainBg = Color3.fromRGB(245, 245, 250),
		Header = Color3.fromRGB(225, 225, 235),
		Sidebar = Color3.fromRGB(255, 255, 255),
		Text = Color3.fromRGB(30, 30, 40),
		TabBg = Color3.fromRGB(255, 255, 255),
		TabText = Color3.fromRGB(40, 40, 50),
		ToggleOff = Color3.fromRGB(189, 189, 199),
		ToggleOn = Color3.fromRGB(65, 195, 125),
		InputBg = Color3.fromRGB(235, 235, 240),
		ItemBg = Color3.fromRGB(255, 255, 255),
		Border = Color3.fromRGB(210, 210, 220)
	},
	Dark = {
		MainBg = Color3.fromRGB(26, 26, 31),
		Header = Color3.fromRGB(32, 32, 40),
		Sidebar = Color3.fromRGB(35, 35, 45),
		Text = Color3.fromRGB(225, 225, 240),
		TabBg = Color3.fromRGB(45, 45, 55),
		TabText = Color3.fromRGB(220, 220, 235),
		ToggleOff = Color3.fromRGB(72, 72, 82),
		ToggleOn = Color3.fromRGB(0, 170, 100),
		InputBg = Color3.fromRGB(55, 55, 65),
		ItemBg = Color3.fromRGB(50, 50, 60),
		Border = Color3.fromRGB(55, 55, 65)
	}
}

-- ==================== MÓDULOS VIA LOADSTRING (como você pediu) ====================
local function loadComponent(code)
	return loadstring(code)()
end

local ToggleModule = loadComponent([[
	return {
		Create = function(theme, id, text, defaultState, callback, scrollFrame)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, -16, 0, 52)
			frame.BackgroundTransparency = 1
			frame.Parent = scrollFrame
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.62, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = text or "Toggle"
			label.TextColor3 = theme.Text
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextSize = 16
			label.Font = Enum.Font.Gotham
			label.Parent = frame
			
			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(0, 54, 0, 30)
			bg.Position = UDim2.new(1, -70, 0.5, -15)
			bg.BackgroundColor3 = theme.ToggleOff
			bg.Parent = frame
			Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
			
			local knob = Instance.new("Frame")
			knob.Size = UDim2.new(0, 26, 0, 26)
			knob.Position = UDim2.new(0, 2, 0.5, -13)
			knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
			knob.Parent = bg
			Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
			
			local state = defaultState or false
			local function updateVisual()
				if state then
					TweenService:Create(bg, TweenInfo.new(0.25), {BackgroundColor3 = theme.ToggleOn}):Play()
					TweenService:Create(knob, TweenInfo.new(0.25), {Position = UDim2.new(1, -28, 0.5, -13)}):Play()
				else
					TweenService:Create(bg, TweenInfo.new(0.25), {BackgroundColor3 = theme.ToggleOff}):Play()
					TweenService:Create(knob, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0.5, -13)}):Play()
				end
			end
			updateVisual()
			
			bg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					state = not state
					updateVisual()
					if callback then callback(state) end
				end
			end)
			
			return {id = id, frame = frame, state = state, bg = bg, knob = knob, callback = callback, updateVisual = updateVisual}
		end
	}
]])

local InputModule = loadComponent([[
	return {
		Create = function(theme, id, text, placeholder, scrollFrame)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, -16, 0, 52)
			frame.BackgroundTransparency = 1
			frame.Parent = scrollFrame
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.4, 0, 1, 0)
			label.Text = text or "Input"
			label.BackgroundTransparency = 1
			label.TextColor3 = theme.Text
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextSize = 16
			label.Font = Enum.Font.Gotham
			label.Parent = frame
			
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.55, 0, 0, 38)
			box.Position = UDim2.new(0.42, 0, 0.5, -19)
			box.BackgroundColor3 = theme.InputBg
			box.PlaceholderText = placeholder or "..."
			box.Text = ""
			box.ClearTextOnFocus = false
			box.TextColor3 = theme.Text
			box.TextSize = 15
			box.Font = Enum.Font.Gotham
			box.Parent = frame
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)
			
			return {id = id, frame = frame, box = box}
		end
	}
]])

local DropdownModule = loadComponent([[
	return {
		Create = function(theme, id, text, items, openByDefault, scrollFrame)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, -16, 0, 52)
			container.BackgroundTransparency = 1
			container.Parent = scrollFrame
			
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 52)
			btn.BackgroundColor3 = theme.ItemBg
			btn.Text = text or "Dropdown"
			btn.TextColor3 = theme.Text
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.TextSize = 16
			btn.Font = Enum.Font.Gotham
			btn.Parent = container
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
			
			local arrow = Instance.new("TextLabel")
			arrow.Size = UDim2.new(0, 30, 1, 0)
			arrow.Position = UDim2.new(1, -35, 0, 0)
			arrow.BackgroundTransparency = 1
			arrow.Text = openByDefault and "▼" or "▶"
			arrow.TextColor3 = theme.Text
			arrow.TextSize = 18
			arrow.Parent = btn
			
			local list = Instance.new("Frame")
			list.Size = UDim2.new(1, 0, 0, 0)
			list.Position = UDim2.new(0, 0, 1, 4)
			list.BackgroundColor3 = theme.ItemBg
			list.Visible = openByDefault
			list.Parent = container
			Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
			
			local listLayout = Instance.new("UIListLayout", list)
			listLayout.Padding = UDim.new(0, 4)
			
			for _, itemText in ipairs(items or {"Item", "Item", "Item"}) do
				local itemBtn = Instance.new("TextButton")
				itemBtn.Size = UDim2.new(1, -12, 0, 38)
				itemBtn.Position = UDim2.new(0, 6, 0, 0)
				itemBtn.BackgroundTransparency = 1
				itemBtn.Text = itemText
				itemBtn.TextColor3 = theme.Text
				itemBtn.TextSize = 15
				itemBtn.Font = Enum.Font.Gotham
				itemBtn.Parent = list
			end
			
			btn.MouseButton1Click:Connect(function()
				list.Visible = not list.Visible
				arrow.Text = list.Visible and "▼" or "▶"
				container.Size = list.Visible and UDim2.new(1, -16, 0, 52 + #items * 42) or UDim2.new(1, -16, 0, 52)
			end)
			
			return {id = id, frame = container, list = list, arrow = arrow}
		end
	}
]]

-- ======================= CORE =======================
function ggPro.new(title)
	local self = setmetatable({}, ggPro)
	self.ThemeName = "Light"
	self.Theme = Themes.Light
	self.Elements = {} -- id → dados do elemento
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "ggProUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.Parent = playerGui
	
	self:BuildWindow(title or "www.name.rbx")
	self:CreateDemoUI() -- cria exatamente igual à imagem
	return self
end

function ggPro:BuildWindow(title)
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 720, 0, 520)
	main.Position = UDim2.new(0.5, -360, 0.5, -260)
	main.BackgroundColor3 = self.Theme.MainBg
	main.BorderSizePixel = 0
	main.Parent = self.ScreenGui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
	self.MainFrame = main
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 56)
	header.BackgroundColor3 = self.Theme.Header
	header.Parent = main
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
	
	local globe = Instance.new("TextLabel")
	globe.Size = UDim2.new(0, 34, 1, 0)
	globe.Position = UDim2.new(0, 20, 0, 0)
	globe.BackgroundTransparency = 1
	globe.Text = "🌐"
	globe.TextSize = 28
	globe.TextColor3 = self.Theme.Text
	globe.Parent = header
	
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
	titleLbl.Position = UDim2.new(0, 70, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = self.Theme.Text
	titleLbl.TextSize = 19
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = header
	
	-- Tabs (5x "Main")
	local tabFrame = Instance.new("Frame")
	tabFrame.Size = UDim2.new(1, -40, 0, 44)
	tabFrame.Position = UDim2.new(0, 20, 0, 66)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Parent = main
	
	local listLayout = Instance.new("UIListLayout", tabFrame)
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.Padding = UDim.new(0, 8)
	
	for i = 1, 5 do
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 118, 1, 0)
		tab.BackgroundColor3 = self.Theme.TabBg
		tab.Text = "Main"
		tab.TextColor3 = self.Theme.TabText
		tab.TextSize = 15
		tab.Font = Enum.Font.Gotham
		tab.Parent = tabFrame
		Instance.new("UICorner", tab).CornerRadius = UDim.new(1, 0)
	end
	
	-- Sidebar (conteúdo da imagem)
	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Size = UDim2.new(0, 280, 1, -130)
	sidebar.Position = UDim2.new(0, 20, 0, 120)
	sidebar.BackgroundColor3 = self.Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.ScrollBarThickness = 6
	sidebar.Parent = main
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 14)
	
	local innerList = Instance.new("UIListLayout", sidebar)
	innerList.Padding = UDim.new(0, 12)
	innerList.SortOrder = Enum.SortOrder.LayoutOrder
	sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.Sidebar = sidebar
	
	self:MakeDraggable(header)
end

function ggPro:CreateDemoUI()
	-- Toggle off (igual imagem)
	local togOff = ToggleModule.Create(self.Theme, "tog_off", "Toggle", false, nil, self.Sidebar)
	self.Elements["tog_off"] = togOff
	
	-- Toggle on (verde)
	local togOn = ToggleModule.Create(self.Theme, "tog_on", "Toggle", true, nil, self.Sidebar)
	self.Elements["tog_on"] = togOn
	
	-- Input
	local inp = InputModule.Create(self.Theme, "input1", "Input", "...", self.Sidebar)
	self.Elements["input1"] = inp
	
	-- Dropdown fechado
	local ddClosed = DropdownModule.Create(self.Theme, "dd_closed", "Dropdown", {}, false, self.Sidebar)
	self.Elements["dd_closed"] = ddClosed
	
	-- Dropdown aberto com 3 itens
	local ddOpen = DropdownModule.Create(self.Theme, "dd_open", "Dropdown", {"Item", "Item", "Item"}, true, self.Sidebar)
	self.Elements["dd_open"] = ddOpen
end

-- Update / Delete / Minimize
function ggPro:Update(id, actions)
	local el = self.Elements[id]
	if not el then return end
	
	if actions.delete then
		el.frame:Destroy()
		self.Elements[id] = nil
		return
	end
	
	if el.state \~= nil and actions.state \~= nil then -- Toggle
		el.state = actions.state
		el.updateVisual()
		if el.callback then el.callback(el.state) end
	end
	
	-- mais tipos podem ser adicionados aqui
end

function ggPro:Delete(id)
	self:Update(id, {delete = true})
end

function ggPro:Minimize(minimize)
	self.Minimized = minimize
	if minimize then
		TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 720, 0, 62)}):Play()
	else
		TweenService:Create(self.MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 720, 0, 520)}):Play()
	end
end

function ggPro:SetTheme(themeName)
	self.ThemeName = themeName
	self.Theme = Themes[themeName]
	-- Atualiza cores (pode expandir para todos elementos se quiser)
	print("ggPro → Tema alterado para " .. themeName)
end

function ggPro:MakeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

return ggPro
