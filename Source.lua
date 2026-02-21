-- =============================================
-- LuminaUI - Biblioteca Completa de UI Roblox (Luau)
-- Baseado no seu GUI azul lindo (mobile + PC friendly)
-- Tema escuro azul profissional com animações suaves
-- Suporte total a IDs para controle externo (Set/Get/Remove)
-- Loadstring ready • Fácil de atualizar templates
-- Elementos: Toggle, Button, Textbox, Codebox, Slider, Dropdown (multi + players), ColorPicker (círculo cromático)
-- Notificação system bonito
-- =============================================

local LuminaUI = {}
LuminaUI.__index = LuminaUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Assets (você pode trocar por IDs próprios)
local COLOR_WHEEL_ID = "rbxassetid://3570695787"  -- Círculo cromático clássico (troque se quiser outro)
local NOTIF_SOUND = "rbxassetid://131057809"      -- Som suave de notificação

-- =============================================
-- Criação da janela principal (seu design lindo mantido)
-- =============================================
function LuminaUI:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, LuminaUI)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "LuminaUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = playerGui
    
    -- Main Frame (seu código original aprimorado)
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 250, 0, 180)
    self.MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui
    
    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", self.MainFrame)
    stroke.Color = Color3.fromRGB(50, 80, 150)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    self.UIScale = Instance.new("UIScale", self.MainFrame)
    self.UIScale.Scale = 1
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 50, 100)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    
    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Size = UDim2.new(0, 16, 0, 16)
    titleIcon.Position = UDim2.new(0, 6, 0.5, -8)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Image = "rbxassetid://114403076249281"
    titleIcon.Parent = titleBar
    
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 26, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = config.Title or "www.name.rbx"
    self.TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.Gotham
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = titleBar
    
    -- Botões de controle
    self.MinBtn = self:CreateControlButton(titleBar, UDim2.new(1, -60, 0.5, -12), "-", Color3.fromRGB(40, 60, 120))
    self.CloseBtn = self:CreateControlButton(titleBar, UDim2.new(1, -30, 0.5, -12), "X", Color3.fromRGB(200, 50, 50))
    
    self.CloseBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(self.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tween:Play()
        tween.Completed:Connect(function() self.ScreenGui:Destroy() end)
    end)
    
    -- Divider + Sidebar
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(0, 1, 1, -30)
    divider.Position = UDim2.new(1, -70, 0, 30)
    divider.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    divider.Parent = self.MainFrame
    
    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Size = UDim2.new(0, 68, 1, -30)
    self.Sidebar.Position = UDim2.new(1, -68, 0, 30)
    self.Sidebar.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    self.Sidebar.ScrollBarThickness = 4
    self.Sidebar.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 220)
    self.Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    self.Sidebar.Active = true
    self.Sidebar.Parent = self.MainFrame
    
    local sideList = Instance.new("UIListLayout", self.Sidebar)
    sideList.Padding = UDim.new(0, 4)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, sideList.AbsoluteContentSize.Y + 8)
    end)
    
    -- Template de conteúdo (clonado por tab)
    self.ContentTemplate = Instance.new("ScrollingFrame")
    self.ContentTemplate.Name = "ContentTemplate"
    self.ContentTemplate.Size = UDim2.new(1, -78, 1, -34)
    self.ContentTemplate.Position = UDim2.new(0, 6, 0, 32)
    self.ContentTemplate.BackgroundTransparency = 1
    self.ContentTemplate.ScrollBarThickness = 4
    self.ContentTemplate.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 220)
    self.ContentTemplate.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.ContentTemplate.Active = true
    self.ContentTemplate.Visible = false
    self.ContentTemplate.Parent = self.MainFrame
    
    local listLayout = Instance.new("UIListLayout", self.ContentTemplate)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ContentTemplate.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
    end)
    
    Instance.new("Frame", self.ContentTemplate).Size = UDim2.new(1, 0, 0, 40) -- spacer
    
    -- Estado interno
    self.Tabs = {}
    self.Elements = {}      -- ID → elemento (para Set/Get)
    self.IdCounter = 0
    self.CurrentTab = nil
    self.Notifications = {}
    
    -- Drag
    self:EnableDragging(titleBar)
    
    -- Minimizar
    self.IsMinimized = false
    self.MinBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
    
    return self
end

function LuminaUI:CreateControlButton(parent, pos, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 24, 0, 24)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    return btn
end

function LuminaUI:EnableDragging(titleBar)
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function LuminaUI:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    local targetSize = self.IsMinimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 180)
    local tween = TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
    tween:Play()
    
    if not self.IsMinimized then
        for _, tab in pairs(self.Tabs) do tab.Content.Visible = (tab == self.CurrentTab) end
    else
        tween.Completed:Connect(function()
            if self.IsMinimized then
                for _, tab in pairs(self.Tabs) do tab.Content.Visible = false end
            end
        end)
    end
end

-- =============================================
-- Tabs
-- =============================================
function LuminaUI:AddTab(name)
    self.IdCounter += 1
    local tabId = "tab_" .. self.IdCounter
    
    -- Botão na sidebar
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = #self.Tabs == 0 and Color3.fromRGB(40,60,120) or Color3.fromRGB(25,35,60)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180,200,240)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    tabBtn.Parent = self.Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
    
    -- Conteúdo (clone do template)
    local content = self.ContentTemplate:Clone()
    content.Name = name .. "Content"
    content.Visible = #self.Tabs == 0
    content.Parent = self.MainFrame
    
    local tabData = {
        Name = name,
        Button = tabBtn,
        Content = content,
        Elements = {}
    }
    
    tabBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(tabData)
    end)
    
    table.insert(self.Tabs, tabData)
    if #self.Tabs == 1 then self:SwitchTab(tabData) end
    
    return tabData  -- retorna para AddToggle, AddButton etc.
end

function LuminaUI:SwitchTab(tabData)
    self.CurrentTab = tabData
    self.TitleLabel.Text = (self.ScreenGui.Parent and self.ScreenGui.Parent.Name or "Lumina") .. " /" .. tabData.Name:lower()
    
    for _, t in ipairs(self.Tabs) do
        t.Content.Visible = (t == tabData)
        t.Button.BackgroundColor3 = (t == tabData) and Color3.fromRGB(40,60,120) or Color3.fromRGB(25,35,60)
    end
end

-- =============================================
-- Elementos (todos com ID obrigatório ou auto)
-- =============================================
local function AssignID(self, elementType, config)
    if not config.ID then
        self.IdCounter += 1
        config.ID = elementType .. "_" .. self.IdCounter
    end
    return config.ID
end

-- Toggle (seu original aprimorado)
function LuminaUI:AddToggle(tab, config)
    config = config or {}
    local id = AssignID(self, "toggle", config)
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 34)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    toggleFrame.Parent = tab.Content
    Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextSize = 15
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -54, 0.5, -11)
    switchBg.BackgroundColor3 = config.Default and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(60, 80, 140)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = toggleFrame
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = config.Default and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 255)
    circle.Parent = switchBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local value = config.Default or false
    local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local function updateVisual()
        TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = value and Color3.fromRGB(60,200,100) or Color3.fromRGB(60,80,140)}):Play()
        TweenService:Create(circle, tweenInfo, {Position = value and UDim2.new(0,24,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
    end
    updateVisual()
    
    switchBg.MouseButton1Click:Connect(function()
        value = not value
        updateVisual()
        if config.Callback then config.Callback(value) end
        self.Elements[id] = {Type = "toggle", Value = value, Callback = config.Callback, Frame = toggleFrame}
    end)
    
    self.Elements[id] = {Type = "toggle", Value = value, Callback = config.Callback, Frame = toggleFrame}
    return id
end

-- Button
function LuminaUI:AddButton(tab, config)
    config = config or {}
    local id = AssignID(self, "button", config)
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    btn.Text = config.Name or "Button"
    btn.TextColor3 = Color3.fromRGB(220, 240, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = tab.Content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)
    
    self.Elements[id] = {Type = "button", Callback = config.Callback, Frame = btn}
    return id
end

-- Textbox (Input)
function LuminaUI:AddTextbox(tab, config)
    config = config or {}
    local id = AssignID(self, "textbox", config)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    frame.Parent = tab.Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 1, -8)
    box.Position = UDim2.new(0, 8, 0, 4)
    box.BackgroundTransparency = 1
    box.PlaceholderText = config.Placeholder or "Digite aqui..."
    box.Text = config.Default or ""
    box.TextColor3 = Color3.fromRGB(200,220,255)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.Parent = frame
    
    box.FocusLost:Connect(function(enterPressed)
        if enterPressed and config.Callback then config.Callback(box.Text) end
    end)
    
    self.Elements[id] = {Type = "textbox", Value = box.Text, Callback = config.Callback, Box = box}
    return id
end

-- Codebox (monospace)
function LuminaUI:AddCodebox(tab, config)
    config = config or {}
    local id = AssignID(self, "codebox", config)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    frame.Parent = tab.Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 1, -12)
    box.Position = UDim2.new(0, 6, 0, 6)
    box.BackgroundTransparency = 1
    box.Text = config.Default or "-- código aqui"
    box.TextColor3 = Color3.fromRGB(180, 255, 200)
    box.TextSize = 13
    box.Font = Enum.Font.Code
    box.MultiLine = true
    box.ClearTextOnFocus = false
    box.TextWrapped = true
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.Parent = frame
    
    self.Elements[id] = {Type = "codebox", Value = box.Text, Box = box}
    return id
end

-- Slider
function LuminaUI:AddSlider(tab, config)
    config = config or {}
    local id = AssignID(self, "slider", config)
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = math.clamp(config.Default or config.Min, config.Min, config.Max)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Content
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = (config.Name or "Slider") .. ": " .. config.Default
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(40,60,120)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(220,220,255)
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    
    local value = config.Default
    local dragging = false
    
    local function update(pos)
        local percent = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.round(config.Min + percent * (config.Max - config.Min))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        label.Text = (config.Name or "Slider") .. ": " .. value
        if config.Callback then config.Callback(value) end
    end
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    self.Elements[id] = {Type = "slider", Value = value, Callback = config.Callback, Min = config.Min, Max = config.Max}
    return id
end

-- ColorPicker (círculo cromático + preview)
function LuminaUI:AddColorPicker(tab, config)
    config = config or {}
    local id = AssignID(self, "colorpicker", config)
    local currentColor = config.Default or Color3.fromRGB(255, 100, 100)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    frame.Parent = tab.Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 24, 0, 24)
    preview.Position = UDim2.new(0, 8, 0.5, -12)
    preview.BackgroundColor3 = currentColor
    preview.Parent = frame
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 1, 0)
    label.Position = UDim2.new(0, 40, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Color"
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextSize = 15
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(0, 60, 1, 0)
    rgbLabel.Position = UDim2.new(1, -68, 0, 0)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.Text = string.format("RGB: %d,%d,%d", currentColor.R*255, currentColor.G*255, currentColor.B*255)
    rgbLabel.TextColor3 = Color3.fromRGB(160,180,220)
    rgbLabel.TextSize = 12
    rgbLabel.Font = Enum.Font.Gotham
    rgbLabel.Parent = frame
    
    -- Picker Dropdown
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 200, 0, 200)
    pickerFrame.Position = UDim2.new(1, 10, 0, 0)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 10
    pickerFrame.Parent = self.MainFrame
    Instance.new("UICorner", pickerFrame).CornerRadius = UDim.new(0, 8)
    
    local wheel = Instance.new("ImageLabel")
    wheel.Size = UDim2.new(0, 160, 0, 160)
    wheel.Position = UDim2.new(0.5, -80, 0, 20)
    wheel.Image = COLOR_WHEEL_ID
    wheel.BackgroundTransparency = 1
    wheel.Parent = pickerFrame
    
    local pickerDot = Instance.new("Frame")
    pickerDot.Size = UDim2.new(0, 12, 0, 12)
    pickerDot.BackgroundColor3 = Color3.new(1,1,1)
    pickerDot.BorderSizePixel = 2
    pickerDot.BorderColor3 = Color3.new(0,0,0)
    pickerDot.Parent = wheel
    Instance.new("UICorner", pickerDot).CornerRadius = UDim.new(1,0)
    
    local function updatePicker(pos)
        local center = wheel.AbsolutePosition + wheel.AbsoluteSize/2
        local dir = (pos - center)
        local dist = math.min(dir.Magnitude, wheel.AbsoluteSize.X/2)
        local angle = math.atan2(dir.Y, dir.X)
        local hue = (angle + math.pi) / (2 * math.pi)
        local sat = dist / (wheel.AbsoluteSize.X/2)
        currentColor = Color3.fromHSV(hue, sat, 1)
        
        preview.BackgroundColor3 = currentColor
        rgbLabel.Text = string.format("RGB: %d,%d,%d", currentColor.R*255, currentColor.G*255, currentColor.B*255)
        
        pickerDot.Position = UDim2.new(0.5, dir.X * (dist / dir.Magnitude) * 0.5, 0.5, dir.Y * (dist / dir.Magnitude) * 0.5) -- approx
        if config.Callback then config.Callback(currentColor) end
    end
    
    wheel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            updatePicker(input.Position)
        end
    end)
    wheel.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            updatePicker(input.Position)
        end
    end)
    
    preview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerFrame.Visible = not pickerFrame.Visible
        end
    end)
    
    self.Elements[id] = {Type = "colorpicker", Value = currentColor, Callback = config.Callback, Frame = frame, PickerFrame = pickerFrame}
    return id
end

-- Dropdown (single + multi + player list)
function LuminaUI:AddDropdown(tab, config)
    config = config or {}
    local id = AssignID(self, "dropdown", config)
    local multi = config.Multi or false
    local isPlayerList = config.PlayerList or false
    local selected = config.Default or (multi and {} or nil)
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    frame.Parent = tab.Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Dropdown"
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextSize = 15
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -28, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(180,200,240)
    arrow.TextSize = 18
    arrow.Parent = frame
    
    local dropFrame = Instance.new("ScrollingFrame")
    dropFrame.Size = UDim2.new(1, 0, 0, 0)
    dropFrame.Position = UDim2.new(0, 0, 1, 4)
    dropFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    dropFrame.BorderSizePixel = 0
    dropFrame.ScrollBarThickness = 4
    dropFrame.Visible = false
    dropFrame.Parent = frame
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 6)
    
    local list = Instance.new("UIListLayout", dropFrame)
    list.Padding = UDim.new(0, 2)
    
    local items = isPlayerList and {} or (config.Items or {})
    if isPlayerList then
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(items, plr.Name)
        end
        Players.PlayerAdded:Connect(function(plr)
            table.insert(items, plr.Name)
            -- rebuild if open...
        end)
    end
    
    local function refreshDropdown()
        for _, child in ipairs(dropFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, item in ipairs(items) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(30, 45, 90)
            btn.Text = item
            btn.TextColor3 = Color3.fromRGB(200,220,255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = dropFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                if multi then
                    if table.find(selected, item) then
                        table.remove(selected, table.find(selected, item))
                    else
                        table.insert(selected, item)
                    end
                else
                    selected = item
                    dropFrame.Visible = false
                end
                label.Text = config.Name .. ": " .. (multi and table.concat(selected, ", ") or selected)
                if config.Callback then config.Callback(multi and selected or selected) end
            end)
        end
        dropFrame.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y)
    end
    refreshDropdown()
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dropFrame.Visible = not dropFrame.Visible
            if dropFrame.Visible then dropFrame.Size = UDim2.new(1,0,0, math.min(#items * 26, 150)) end
        end
    end)
    
    self.Elements[id] = {Type = "dropdown", Value = selected, Items = items, Callback = config.Callback, Multi = multi}
    return id
end

-- Notification System
function LuminaUI:Notify(title, text, duration)
    duration = duration or 4
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 220, 0, 70)
    notif.Position = UDim2.new(1, -240, 1, -90 - #self.Notifications * 80)
    notif.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    notif.Parent = self.ScreenGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    
    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -16, 0, 24)
    tLabel.Position = UDim2.new(0, 8, 0, 8)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(255, 240, 200)
    tLabel.TextSize = 14
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = notif
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -16, 0, 34)
    desc.Position = UDim2.new(0, 8, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Text = text
    desc.TextColor3 = Color3.fromRGB(200,220,255)
    desc.TextSize = 13
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextWrapped = true
    desc.Parent = notif
    
    -- Som
    local sound = Instance.new("Sound")
    sound.SoundId = NOTIF_SOUND
    sound.Volume = 0.6
    sound.Parent = notif
    sound:Play()
    
    table.insert(self.Notifications, notif)
    
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -240, 1, -90 - (#self.Notifications-1) * 80)}):Play()
    
    task.delay(duration, function()
        if notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 20, notif.Position.Y.Scale, notif.Position.Y.Offset)}):Play()
            task.wait(0.4)
            notif:Destroy()
            table.remove(self.Notifications, table.find(self.Notifications, notif))
        end
    end)
end

-- =============================================
-- Funções de controle por ID (o que você pediu)
-- =============================================
function LuminaUI:Set(id, value)
    local elem = self.Elements[id]
    if not elem then return warn("LuminaUI: ID não encontrado -> " .. id) end
    
    if elem.Type == "toggle" then
        elem.Value = value
        -- atualiza visual (simplesmente clica no switch internamente)
        elem.Frame:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Fire() -- trigger
        if elem.Callback then elem.Callback(value) end
    elseif elem.Type == "slider" then
        elem.Value = math.clamp(value, elem.Min, elem.Max)
        -- (você pode expandir a atualização do knob aqui se quiser)
        if elem.Callback then elem.Callback(elem.Value) end
    elseif elem.Type == "colorpicker" then
        elem.Value = value
        elem.Frame:FindFirstChildWhichIsA("Frame").BackgroundColor3 = value -- preview
        if elem.Callback then elem.Callback(value) end
    elseif elem.Type == "textbox" or elem.Type == "codebox" then
        elem.Box.Text = value
        elem.Value = value
    elseif elem.Type == "dropdown" then
        elem.Value = value
        -- refresh label etc.
    end
end

function LuminaUI:Get(id)
    local elem = self.Elements[id]
    return elem and elem.Value
end

function LuminaUI:RemoveElement(id)
    local elem = self.Elements[id]
    if elem and elem.Frame then elem.Frame:Destroy() end
    self.Elements[id] = nil
end

function LuminaUI:AddToDropdown(id, newItem)
    local elem = self.Elements[id]
    if elem and elem.Type == "dropdown" then
        table.insert(elem.Items, newItem)
        -- rebuild dropdown se aberto...
    end
end
return LuminaUI
