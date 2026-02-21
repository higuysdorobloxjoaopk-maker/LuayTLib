-- =====================================================
-- Tlib v1.0 - Biblioteca UI Completa (Mobile + PC Friendly)
-- Nome: Tlib
-- Visual 100% idêntico ao seu GUI original (cores, tamanhos, fontes, cantos, scroll, drag, minimize, fechar com scale)
-- Todos os elementos têm ID obrigatório para controle posterior
-- Funções de controle: SetToggle(id, bool), SetSlider(id, value), etc.
-- Fácil de atualizar modelos internos (tudo modularizado)
-- Pode ser usado com loadstring(game:HttpGet("suaurl"))
-- =====================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Tlib = {}
Tlib.__index = Tlib
Tlib.Elements = {}      -- id → {Type, Data}
Tlib.TabContents = {}   -- "TabName" → ScrollingFrame
Tlib.CurrentTab = "Main"
Tlib.NextID = 1
Tlib.Windows = {}       -- suporta múltiplas janelas (mas exemplo usa 1)

local function GenerateID()
    local id = "tlib_" .. Tlib.NextID
    Tlib.NextID += 1
    return id
end

--// ==================== CRIAÇÃO DA JANELA (visual EXATO) ====================
function Tlib:Create(config)
    config = config or {}
    local self = setmetatable({}, Tlib)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "TlibGui"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = playerGui

    -- Main Frame
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 250, 0, 180)
    self.MainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
    self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    Instance.new("UICorner", self.MainFrame).CornerRadius = UDim.new(0, 8)

    local mainStroke = Instance.new("UIStroke", self.MainFrame)
    mainStroke.Color = Color3.fromRGB(50, 80, 150)
    mainStroke.Thickness = 1
    mainStroke.Transparency = 0.5

    self.UIScale = Instance.new("UIScale", self.MainFrame)

    -- Title Bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = Color3.fromRGB(30, 50, 100)
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.MainFrame

    Instance.new("UICorner", self.TitleBar).CornerRadius = UDim.new(0, 8)

    local titleIcon = Instance.new("ImageLabel")
    titleIcon.Size = UDim2.new(0, 16, 0, 16)
    titleIcon.Position = UDim2.new(0, 6, 0.5, -8)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Image = "rbxassetid://114403076249281"
    titleIcon.Parent = self.TitleBar

    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 26, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = "www.name.rbx /main"
    self.TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    self.TitleLabel.TextSize = 13
    self.TitleLabel.Font = Enum.Font.Gotham
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar

    -- Min / Close
    self.MinBtn = Instance.new("TextButton")
    self.MinBtn.Size = UDim2.new(0, 24, 0, 24)
    self.MinBtn.Position = UDim2.new(1, -60, 0.5, -12)
    self.MinBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    self.MinBtn.Text = "-"
    self.MinBtn.TextColor3 = Color3.new(1,1,1)
    self.MinBtn.Font = Enum.Font.GothamBold
    self.MinBtn.TextSize = 14
    self.MinBtn.Parent = self.TitleBar
    Instance.new("UICorner", self.MinBtn).CornerRadius = UDim.new(0,4)

    self.CloseBtn = Instance.new("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    self.CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
    self.CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    self.CloseBtn.Text = "X"
    self.CloseBtn.TextColor3 = Color3.new(1,1,1)
    self.CloseBtn.Font = Enum.Font.GothamBold
    self.CloseBtn.TextSize = 14
    self.CloseBtn.Parent = self.TitleBar
    Instance.new("UICorner", self.CloseBtn).CornerRadius = UDim.new(0,4)

    self.CloseBtn.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(self.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tween:Play()
        tween.Completed:Wait()
        self.ScreenGui:Destroy()
    end)

    -- Divider
    self.Divider = Instance.new("Frame")
    self.Divider.Size = UDim2.new(0, 1, 1, -30)
    self.Divider.Position = UDim2.new(1, -70, 0, 30)
    self.Divider.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    self.Divider.Parent = self.MainFrame

    -- Sidebar
    self.SideBar = Instance.new("ScrollingFrame")
    self.SideBar.Size = UDim2.new(0, 68, 1, -30)
    self.SideBar.Position = UDim2.new(1, -68, 0, 30)
    self.SideBar.BackgroundColor3 = Color3.fromRGB(20, 35, 70)
    self.SideBar.BorderSizePixel = 0
    self.SideBar.ScrollBarThickness = 5
    self.SideBar.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 220)
    self.SideBar.ScrollBarImageTransparency = 0.4
    self.SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.SideBar.Active = true
    self.SideBar.Parent = self.MainFrame

    local sideList = Instance.new("UIListLayout", self.SideBar)
    sideList.Padding = UDim.new(0, 4)
    sideList.SortOrder = Enum.SortOrder.LayoutOrder
    sideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.SideBar.CanvasSize = UDim2.new(0, 0, 0, sideList.AbsoluteContentSize.Y + 8)
    end)

    -- Main Content (default)
    self.MainContent = Instance.new("ScrollingFrame")
    self.MainContent.Name = "MainContent"
    self.MainContent.Size = UDim2.new(1, -78, 1, -34)
    self.MainContent.Position = UDim2.new(0, 6, 0, 32)
    self.MainContent.BackgroundTransparency = 1
    self.MainContent.BorderSizePixel = 0
    self.MainContent.ScrollBarThickness = 5
    self.MainContent.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 220)
    self.MainContent.ScrollBarImageTransparency = 0.4
    self.MainContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.MainContent.Active = true
    self.MainContent.Parent = self.MainFrame

    local listLayout = Instance.new("UIListLayout", self.MainContent)
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.MainContent.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end)

    self.TabContents["Main"] = self.MainContent

    -- Spacer
    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, 40)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 999
    spacer.Parent = self.MainContent

    -- Drag
    local dragging = false
    local dragStart, startPos
    self.TitleBar.InputBegan:Connect(function(input)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- Minimize (exato)
    local isMinimized = false
    self.MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if not isMinimized then
            self.Divider.Visible = true
            self.SideBar.Visible = true
            for _, c in pairs(self.TabContents) do c.Visible = (self.CurrentTab == c.Name) end
        end
        local targetSize = isMinimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 180)
        local tween = TweenService:Create(self.MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
        tween:Play()
        if isMinimized then
            tween.Completed:Connect(function()
                if isMinimized then
                    self.Divider.Visible = false
                    self.SideBar.Visible = false
                    for _, c in pairs(self.TabContents) do c.Visible = false end
                end
            end)
        end
    end)

    Tlib.Windows["default"] = self
    self:UpdateTitle()
    return self
end

function Tlib:UpdateTitle()
    self.TitleLabel.Text = "www.name.rbx /" .. self.CurrentTab:lower()
end

--// ==================== TABS ====================
function Tlib:CreateTab(name)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = (name == self.CurrentTab) and Color3.fromRGB(40,60,120) or Color3.fromRGB(25,35,60)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.fromRGB(180,200,240)
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.TextSize = 13
    tabBtn.Parent = self.SideBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local content = self.MainContent:Clone()
    content.Name = name .. "Content"
    content.Visible = (name == self.CurrentTab)
    content.Parent = self.MainFrame
    self.TabContents[name] = content

    local list = content:FindFirstChildOfClass("UIListLayout")
    if list then
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 8)
        end)
    end

    local spacer = Instance.new("Frame")
    spacer.Size = UDim2.new(1, 0, 0, 40)
    spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = 999
    spacer.Parent = content

    tabBtn.MouseButton1Click:Connect(function()
        self.CurrentTab = name
        self:UpdateTitle()
        for tabName, frame in pairs(self.TabContents) do
            frame.Visible = (tabName == name)
        end
        for _, btn in ipairs(self.SideBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn.Text == name) and Color3.fromRGB(40,60,120) or Color3.fromRGB(25,35,60)
            end
        end
    end)

    return name
end

--// ==================== ELEMENTOS (todos com ID) ====================

local function UpdateCanvas(parent)
    local list = parent:FindFirstChildOfClass("UIListLayout")
    if list then parent.CanvasSize = UDim2.new(0,0,0, list.AbsoluteContentSize.Y + 8) end
end

-- Toggle
function Tlib:CreateToggle(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 34)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
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
    switchBg.BackgroundColor3 = (config.Default == true) and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(60, 80, 140)
    switchBg.Text = ""
    switchBg.AutoButtonColor = false
    switchBg.Parent = toggleFrame
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = (config.Default == true) and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(220, 220, 255)
    circle.Parent = switchBg
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local isOn = config.Default == true
    local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    switchBg.MouseButton1Click:Connect(function()
        isOn = not isOn
        TweenService:Create(switchBg, tweenInfo, {BackgroundColor3 = isOn and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(60, 80, 140)}):Play()
        TweenService:Create(circle, tweenInfo, {Position = isOn and UDim2.new(0, 24, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        if config.Callback then config.Callback(isOn) end
    end)

    Tlib.Elements[id] = {Type = "Toggle", Frame = toggleFrame, Value = isOn, Callback = config.Callback, SwitchBg = switchBg, Circle = circle}
    UpdateCanvas(parent)
    return id
end

function Tlib:SetToggle(id, value)
    local el = Tlib.Elements[id]
    if el and el.Type == "Toggle" then
        el.Value = value
        local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad)
        TweenService:Create(el.SwitchBg, tweenInfo, {BackgroundColor3 = value and Color3.fromRGB(60,200,100) or Color3.fromRGB(60,80,140)}):Play()
        TweenService:Create(el.Circle, tweenInfo, {Position = value and UDim2.new(0,24,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
        if el.Callback then el.Callback(value) end
    end
end

-- Button
function Tlib:CreateButton(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    btn.Text = config.Name or "Button"
    btn.TextColor3 = Color3.fromRGB(220, 230, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    Tlib.Elements[id] = {Type = "Button", Button = btn}
    UpdateCanvas(parent)
    return id
end

-- Input
function Tlib:CreateInput(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    frame.Parent = parent
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
        if config.Callback then config.Callback(box.Text) end
    end)

    Tlib.Elements[id] = {Type = "Input", TextBox = box}
    UpdateCanvas(parent)
    return id
end

function Tlib:SetInput(id, text)
    local el = Tlib.Elements[id]
    if el and el.Type == "Input" then el.TextBox.Text = text end
end

-- Slider
function Tlib:CreateSlider(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent
    local min = config.Min or 0
    local max = config.Max or 100
    local default = math.clamp(config.Default or 50, min, max)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(25, 40, 85)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = Color3.fromRGB(200,220,255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 60, 0, 20)
    valLabel.Position = UDim2.new(1, -68, 0, 4)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.fromRGB(180,200,255)
    valLabel.TextSize = 14
    valLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 6)
    bar.Position = UDim2.new(0, 8, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(220,220,255)
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local dragging = false
    knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + rel * (max - min))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(val)
            if config.Callback then config.Callback(val) end
        end
    end)

    Tlib.Elements[id] = {Type = "Slider", Fill = fill, Knob = knob, ValueLabel = valLabel, Min = min, Max = max, Callback = config.Callback}
    UpdateCanvas(parent)
    return id
end

function Tlib:SetSlider(id, value)
    local el = Tlib.Elements[id]
    if el and el.Type == "Slider" then
        local rel = math.clamp((value - el.Min) / (el.Max - el.Min), 0, 1)
        el.Fill.Size = UDim2.new(rel, 0, 1, 0)
        el.Knob.Position = UDim2.new(rel, -7, 0.5, -7)
        el.ValueLabel.Text = tostring(math.floor(value))
        if el.Callback then el.Callback(value) end
    end
end

-- Dropdown (single + multi + players)
function Tlib:CreateDropdown(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent
    local isMulti = config.Multi or false
    local isPlayerList = config.PlayerList or false

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    btn.Text = config.Name or "Dropdown"
    btn.TextColor3 = Color3.fromRGB(220,230,255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 0)
    dropFrame.Position = UDim2.new(0, 0, 1, 4)
    dropFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    dropFrame.ClipsDescendants = true
    dropFrame.Visible = false
    dropFrame.Parent = btn

    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 6)

    local list = Instance.new("UIListLayout", dropFrame)
    list.Padding = UDim.new(0, 2)

    local selected = config.Default or (isMulti and {} or nil)
    local items = {}

    local function refreshText()
        if isMulti then
            btn.Text = config.Name .. " (" .. #selected .. ")"
        elseif isPlayerList then
            btn.Text = config.Name .. " (" .. (selected and selected.Name or "Nenhum") .. ")"
        else
            btn.Text = config.Name .. ": " .. (selected or "Nenhum")
        end
    end
    refreshText()

    local function createItem(text, value)
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, 0, 0, 28)
        itemBtn.BackgroundColor3 = Color3.fromRGB(30, 45, 80)
        itemBtn.Text = text
        itemBtn.TextColor3 = Color3.fromRGB(200,220,255)
        itemBtn.Font = Enum.Font.Gotham
        itemBtn.TextSize = 13
        itemBtn.Parent = dropFrame
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

        itemBtn.MouseButton1Click:Connect(function()
            if isMulti then
                if table.find(selected, value) then
                    table.remove(selected, table.find(selected, value))
                else
                    table.insert(selected, value)
                end
                itemBtn.BackgroundColor3 = table.find(selected, value) and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(30, 45, 80)
            else
                selected = value
                dropFrame.Visible = false
            end
            refreshText()
            if config.Callback then config.Callback(isMulti and selected or value) end
        end)
        return itemBtn
    end

    if isPlayerList then
        for _, p in ipairs(Players:GetPlayers()) do
            if p \~= player then createItem(p.Name, p) end
        end
        Players.PlayerAdded:Connect(function(p) createItem(p.Name, p) end)
        Players.PlayerRemoving:Connect(function(p)
            for _, c in ipairs(dropFrame:GetChildren()) do
                if c:IsA("TextButton") and c.Text == p.Name then c:Destroy() end
            end
        end)
    else
        for _, v in ipairs(config.Options or {}) do
            local item = createItem(v, v)
            table.insert(items, item)
        end
    end

    btn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        dropFrame.Size = UDim2.new(1, 0, 0, math.min(#dropFrame:GetChildren() * 30, 180))
    end)

    Tlib.Elements[id] = {Type = "Dropdown", Button = btn, DropFrame = dropFrame, Selected = selected, IsMulti = isMulti, Callback = config.Callback, Items = items}
    UpdateCanvas(parent)
    return id
end

function Tlib:AddDropdownItem(id, text, value)
    local el = Tlib.Elements[id]
    if el and el.Type == "Dropdown" then
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, 0, 0, 28)
        itemBtn.BackgroundColor3 = Color3.fromRGB(30, 45, 80)
        itemBtn.Text = text
        itemBtn.TextColor3 = Color3.fromRGB(200,220,255)
        itemBtn.Font = Enum.Font.Gotham
        itemBtn.TextSize = 13
        itemBtn.Parent = el.DropFrame
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)

        itemBtn.MouseButton1Click:Connect(function()
            if el.IsMulti then
                if not table.find(el.Selected, value) then table.insert(el.Selected, value) end
            else
                el.Selected = value
                el.DropFrame.Visible = false
            end
            if el.Callback then el.Callback(el.IsMulti and el.Selected or value) end
        end)
        table.insert(el.Items, itemBtn)
    end
end

function Tlib:RemoveDropdownItem(id, text)
    local el = Tlib.Elements[id]
    if el and el.Type == "Dropdown" then
        for _, item in ipairs(el.Items) do
            if item.Text == text then item:Destroy() end
        end
    end
end

-- Color Picker (círculo cromático + dropdown + quando fechado mostra quadrado + RGB)
function Tlib:CreateColorPicker(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent
    local currentColor = config.Default or Color3.fromRGB(255, 100, 100)

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = UDim2.new(1, 0, 0, 36)
    mainBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 120)
    mainBtn.Text = config.Name or "Color"
    mainBtn.TextColor3 = Color3.fromRGB(220,230,255)
    mainBtn.Font = Enum.Font.GothamSemibold
    mainBtn.TextSize = 14
    mainBtn.Parent = parent
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0, 6)

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, 24, 0, 24)
    preview.Position = UDim2.new(1, -32, 0.5, -12)
    preview.BackgroundColor3 = currentColor
    preview.Parent = mainBtn
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 0)
    dropFrame.Position = UDim2.new(0, 0, 1, 4)
    dropFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
    dropFrame.ClipsDescendants = true
    dropFrame.Visible = false
    dropFrame.Parent = mainBtn
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 6)

    -- Color Wheel (usando asset público comum)
    local wheel = Instance.new("ImageLabel")
    wheel.Size = UDim2.new(0, 140, 0, 140)
    wheel.Position = UDim2.new(0.5, -70, 0, 10)
    wheel.BackgroundTransparency = 1
    wheel.Image = "rbxassetid://415580125"  -- círculo cromático público
    wheel.Parent = dropFrame

    local pickerDot = Instance.new("Frame")
    pickerDot.Size = UDim2.new(0, 12, 0, 12)
    pickerDot.BackgroundColor3 = Color3.new(1,1,1)
    pickerDot.BorderSizePixel = 2
    pickerDot.BorderColor3 = Color3.new(0,0,0)
    pickerDot.Parent = wheel
    Instance.new("UICorner", pickerDot).CornerRadius = UDim.new(1,0)

    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(1, 0, 0, 20)
    rgbLabel.Position = UDim2.new(0, 0, 1, -28)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.Text = string.format("RGB: %d, %d, %d", currentColor.R*255, currentColor.G*255, currentColor.B*255)
    rgbLabel.TextColor3 = Color3.fromRGB(200,220,255)
    rgbLabel.TextSize = 12
    rgbLabel.Font = Enum.Font.Gotham
    rgbLabel.Parent = dropFrame

    mainBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        dropFrame.Size = UDim2.new(1, 0, 0, 190)
        preview.BackgroundColor3 = currentColor
    end)

    -- Lógica simples de wheel (HSV)
    local function updateFromWheel()
        -- Implementação básica (pode ser expandida com InputBegan no wheel)
        local h, s, v = currentColor:ToHSV()
        pickerDot.Position = UDim2.new(s, -6, 1-v, -6)
        rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
        if config.Callback then config.Callback(currentColor) end
    end

    -- Clique no wheel (simplificado)
    wheel.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            -- Aqui você pode adicionar lógica completa de arrastar no wheel se quiser
            -- Por hora só atualiza preview
            updateFromWheel()
        end
    end)

    Tlib.Elements[id] = {Type = "ColorPicker", MainBtn = mainBtn, Preview = preview, DropFrame = dropFrame, Color = currentColor, Callback = config.Callback}
    UpdateCanvas(parent)
    return id
end

function Tlib:SetColor(id, color)
    local el = Tlib.Elements[id]
    if el and el.Type == "ColorPicker" then
        el.Color = color
        el.Preview.BackgroundColor3 = color
        if el.Callback then el.Callback(color) end
    end
end

-- Code Box
function Tlib:CreateCodeBox(tabName, config)
    config = config or {}
    local id = config.ID or GenerateID()
    local parent = self.TabContents[tabName] or self.MainContent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(15, 25, 45)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -12, 1, -12)
    box.Position = UDim2.new(0, 6, 0, 6)
    box.BackgroundTransparency = 1
    box.Text = config.Default or "-- Código aqui"
    box.TextColor3 = Color3.fromRGB(180, 255, 180)
    box.TextSize = 13
    box.Font = Enum.Font.Code
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.MultiLine = true
    box.ClearTextOnFocus = false
    box.Parent = frame

    if config.Callback then
        box.FocusLost:Connect(function() config.Callback(box.Text) end)
    end

    Tlib.Elements[id] = {Type = "CodeBox", TextBox = box}
    UpdateCanvas(parent)
    return id
end

-- Notification System
function Tlib:Notify(config)
    config = config or {}
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 260, 0, 70)
    notifFrame.Position = UDim2.new(1, -280, 1, -90 - (#Tlib.Notifications * 80))
    notifFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 65)
    notifFrame.Parent = self.ScreenGui
    Instance.new("UICorner", notifFrame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0, 10, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notificação"
    title.TextColor3 = Color3.fromRGB(200, 220, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notifFrame

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -45)
    text.Position = UDim2.new(0, 10, 0, 32)
    text.BackgroundTransparency = 1
    text.Text = config.Text or ""
    text.TextColor3 = Color3.fromRGB(180, 200, 240)
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.TextWrapped = true
    text.Parent = notifFrame

    table.insert(Tlib.Notifications, notifFrame)

    task.delay(config.Duration or 5, function()
        if notifFrame.Parent then
            TweenService:Create(notifFrame, TweenInfo.new(0.4), {Position = notifFrame.Position + UDim2.new(0, 300, 0, 0)}):Play()
            task.wait(0.4)
            notifFrame:Destroy()
            table.remove(Tlib.Notifications, table.find(Tlib.Notifications, notifFrame))
        end
    end)
end

-- Exemplo de uso (remova após testar)
local window = Tlib:Create()

window:CreateTab("Main")
window:CreateTab("Config")
window:CreateTab("Extras")

local tog1 = window:CreateToggle("Main", {Name = "Auto Click", Default = true, Callback = print, ID = "toggle1"})
local btn1 = window:CreateButton("Main", {Name = "Explodir Tudo", Callback = function() print("BOOM") end, ID = "btn1"})
local slid1 = window:CreateSlider("Main", {Name = "Velocidade", Min = 0, Max = 200, Default = 80, Callback = print, ID = "slide1"})
local drop1 = window:CreateDropdown("Config", {Name = "Modo", Options = {"Easy", "Hard", "Insane"}, Callback = print, ID = "drop1"})
local col1 = window:CreateColorPicker("Config", {Name = "Cor do Personagem", Default = Color3.fromRGB(255,0,100), Callback = print, ID = "color1"})
local inp1 = window:CreateInput("Extras", {Name = "Texto", Placeholder = "Escreva algo", Callback = print, ID = "inp1"})
local code1 = window:CreateCodeBox("Extras", {Default = "-- Coloque seu código aqui", ID = "code1"})

-- Teste de controle após criação
task.wait(2)
Tlib:SetToggle("toggle1", false)
Tlib:SetSlider("slide1", 150)
Tlib:Notify({Title = "Tlib Carregada", Text = "Biblioteca pronta! Use os IDs para editar depois."})

return Tlib
