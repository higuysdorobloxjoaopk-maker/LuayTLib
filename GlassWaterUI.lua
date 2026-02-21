--!strict
-- CustomUI Library (estilo floating window www.name.rbx)
-- Feito para parecer com a print que você mandou

local CustomUI = {}
CustomUI.__index = CustomUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local GLOBAL_ID = 0
local function generateId()
    GLOBAL_ID += 1
    return "item_" .. GLOBAL_ID .. "_" .. math.random(10000,99999)
end

local function createTween(obj, props, time, easing)
    time = time or 0.3
    easing = easing or Enum.EasingStyle.Sine
    local tweenInfo = TweenInfo.new(time, easing, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Cria a janela principal
function CustomUI.new(titleName: string, parent: GuiObject?)
    local self = setmetatable({}, CustomUI)
    
    self.Items = {}             -- [id] = {type, frame, data...}
    self.Tabs = {}              -- lista de frames de abas
    self.CurrentTab = nil
    self.Minimized = false
    self.Debounce = {}          -- anti-spam por elemento
    
    local screenGui = parent or Instance.new("ScreenGui")
    screenGui.Name = "CustomUI_" .. titleName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Janela principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 380, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = screenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20,20,20))
    }
    UIGradient.Rotation = 90
    UIGradient.Parent = MainFrame
    
    -- Barra de título
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,38)
    TitleBar.BackgroundColor3 = Color3.fromRGB(22,22,22)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0,12)
    TitleCorner.Parent = TitleBar
    
    -- Globo (ícone)
    local Globe = Instance.new("ImageLabel")
    Globe.Size = UDim2.new(0,24,0,24)
    Globe.Position = UDim2.new(0,12,0.5,-12)
    Globe.BackgroundTransparency = 1
    Globe.Image = "rbxassetid://6031280882"  -- ícone de globo (mude se quiser outro)
    Globe.ImageColor3 = Color3.fromRGB(120,180,255)
    Globe.Parent = TitleBar
    
    -- Texto do título
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-60,1,0)
    TitleLabel.Position = UDim2.new(0,50,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "www." .. titleName .. ".rbx"
    TitleLabel.TextColor3 = Color3.fromRGB(200,200,200)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamSemibold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Botão Minimize (podemos usar texto "-" por simplicidade)
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0,34,0,26)
    MinimizeBtn.Position = UDim2.new(1,-42,0.5,-13)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    MinimizeBtn.Text = "−"
    MinimizeBtn.TextColor3 = Color3.new(1,1,1)
    MinimizeBtn.TextSize = 18
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0,6)
    MinCorner.Parent = MinimizeBtn
    
    -- Tabs (Main Main Main...)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1,0,0,36)
    TabContainer.Position = UDim2.new(0,0,0,38)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0,8)
    TabLayout.Parent = TabContainer
    
    -- Área de conteúdo
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Size = UDim2.new(1,-16,1,-90)
    ContentArea.Position = UDim2.new(0,8,0,80)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame
    
    -- Draggable
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Minimize logic
    function self:minimize(state: boolean)
        if state == self.Minimized then return end
        self.Minimized = state
        
        if state then
            -- encolhe
            createTween(MainFrame, {
                Size = UDim2.new(0, 180, 0, 38),
                Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + 140)
            }, 0.4, Enum.EasingStyle.Back)
            
            ContentArea.Visible = false
            TabContainer.Visible = false
            MinimizeBtn.Text = "+"
        else
            -- expande
            createTween(MainFrame, {
                Size = UDim2.new(0, 380, 0, 320),
                Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 140)
            }, 0.4, Enum.EasingStyle.Back)
            
            task.delay(0.25, function()
                ContentArea.Visible = true
                TabContainer.Visible = true
            end)
            MinimizeBtn.Text = "−"
        end
    end
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        self:minimize(not self.Minimized)
    end)
    
    -- Cria tab (Main)
    function self:CreateTab(name: string?)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0,80,0,28)
        tabButton.BackgroundColor3 = Color3.fromRGB(35,35,35)
        tabButton.Text = name or "Main"
        tabButton.TextColor3 = Color3.fromRGB(180,180,180)
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.TextSize = 14
        tabButton.AutoButtonColor = false
        tabButton.Parent = TabContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = tabButton
        
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1,0,1,0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Visible = false
        contentFrame.Parent = ContentArea
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0,10)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = contentFrame
        
        table.insert(self.Tabs, {button = tabButton, frame = contentFrame})
        
        if #self.Tabs == 1 then
            contentFrame.Visible = true
            self.CurrentTab = contentFrame
            createTween(tabButton, {BackgroundColor3 = Color3.fromRGB(60,60,60), TextColor3 = Color3.new(1,1,1)}, 0.2)
        end
        
        tabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab == contentFrame then return end
            if self.CurrentTab then
                self.CurrentTab.Visible = false
                createTween(self.Tabs[#self.Tabs].button, {BackgroundColor3 = Color3.fromRGB(35,35,35), TextColor3 = Color3.fromRGB(180,180,180)}, 0.15)
            end
            contentFrame.Visible = true
            self.CurrentTab = contentFrame
            createTween(tabButton, {BackgroundColor3 = Color3.fromRGB(60,60,60), TextColor3 = Color3.new(1,1,1)}, 0.2)
        end)
        
        return contentFrame
    end
    
    -- Toggle
    function self:CreateToggle(parent: GuiObject, text: string, default: boolean?, callback: (boolean)->()?)
        local id = generateId()
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,0,34)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 15
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0,54,0,26)
        toggleBg.Position = UDim2.new(1,-60,0.5,-13)
        toggleBg.BackgroundColor3 = default and Color3.fromRGB(60,180,100) or Color3.fromRGB(70,70,70)
        toggleBg.Parent = frame
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1,0)
        toggleCorner.Parent = toggleBg
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0,22,0,22)
        circle.Position = default and UDim2.new(0,28,0.5,-11) or UDim2.new(0,4,0.5,-11)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.Parent = toggleBg
        
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1,0)
        circleCorner.Parent = circle
        
        local shadow = Instance.new("UIStroke")
        shadow.Transparency = 0.6
        shadow.Color = Color3.new(0,0,0)
        shadow.Parent = circle
        
        local function update(state)
            createTween(toggleBg, {
                BackgroundColor3 = state and Color3.fromRGB(60,180,100) or Color3.fromRGB(70,70,70)
            }, 0.25)
            
            createTween(circle, {
                Size = UDim2.new(0,26,0,26),
                Position = state and UDim2.new(0,26,0.5,-13) or UDim2.new(0,4,0.5,-13)
            }, 0.32, Enum.EasingStyle.Quint)
            
            task.delay(0.16, function()
                createTween(circle, {Size = UDim2.new(0,22,0,22)}, 0.2)
            end)
        end
        
        toggleBg.InputBegan:Connect(function(input)
            if input.UserInputType \~= Enum.UserInputType.MouseButton1 then return end
            if self.Debounce[id] then return end
            self.Debounce[id] = true
            
            local newState = not (circle.Position.X.Offset > 15)
            update(newState)
            
            if callback then
                task.spawn(callback, newState)
            end
            
            task.delay(0.4, function() self.Debounce[id] = nil end)
        end)
        
        if default then update(true) end
        
        self.Items[id] = {type = "Toggle", frame = frame, value = default or false, update = update}
        return id
    end
    
    -- Input (simples por enquanto)
    function self:CreateInput(parent: GuiObject, placeholder: string, callback: (string)->()?)
        local id = generateId()
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1,0,0,36)
        frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1,-16,1,-8)
        input.Position = UDim2.new(0,8,0,4)
        input.BackgroundTransparency = 1
        input.Text = ""
        input.PlaceholderText = placeholder
        input.PlaceholderColor3 = Color3.fromRGB(140,140,140)
        input.TextColor3 = Color3.new(1,1,1)
        input.TextSize = 15
        input.ClearTextOnFocus = false
        input.Parent = frame
        
        if callback then
            input.FocusLost:Connect(function(enter)
                if enter then
                    callback(input.Text)
                end
            end)
        end
        
        self.Items[id] = {type = "Input", frame = frame, textbox = input}
        return id
    end
    
    -- Dropdown (simples - clica para abrir lista)
    function self:CreateDropdown(parent: GuiObject, defaultText: string, options: {string}, callback: (string)->()?)
        local id = generateId()
        
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1,0,0,38)
        frame.BackgroundColor3 = Color3.fromRGB(45,45,45)
        frame.Text = defaultText
        frame.TextColor3 = Color3.new(1,1,1)
        frame.TextSize = 15
        frame.Font = Enum.Font.Gotham
        frame.AutoButtonColor = false
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,8)
        corner.Parent = frame
        
        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0,30,1,0)
        arrow.Position = UDim2.new(1,-34,0,0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(160,160,160)
        arrow.TextSize = 16
        arrow.Parent = frame
        
        local listFrame = Instance.new("ScrollingFrame")
        listFrame.Size = UDim2.new(1,0,0,0)
        listFrame.Position = UDim2.new(0,0,1,6)
        listFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
        listFrame.BorderSizePixel = 0
        listFrame.ScrollBarThickness = 4
        listFrame.Visible = false
        listFrame.CanvasSize = UDim2.new(0,0,0,0)
        listFrame.ClipsDescendants = true
        listFrame.Parent = frame
        
        local listCorner = Instance.new("UICorner")
        listCorner.CornerRadius = UDim.new(0,8)
        listCorner.Parent = listFrame
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0,4)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Parent = listFrame
        
        local open = false
        
        local function toggleDropdown()
            open = not open
            if open then
                listFrame.Visible = true
                local height = #options * 38 + (#options-1)*4 + 8
                createTween(listFrame, {Size = UDim2.new(1,0,0,height)}, 0.3, Enum.EasingStyle.Back)
                createTween(arrow, {Rotation = 180}, 0.3)
            else
                createTween(listFrame, {Size = UDim2.new(1,0,0,0)}, 0.25)
                task.delay(0.25, function() listFrame.Visible = false end)
                createTween(arrow, {Rotation = 0}, 0.3)
            end
        end
        
        frame.MouseButton1Click:Connect(toggleDropdown)
        
        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-8,0,34)
            btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
            btn.Text = opt
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.Parent = listFrame
            
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0,6)
            c.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                frame.Text = opt
                toggleDropdown()
                if callback then callback(opt) end
            end)
        end
        
        listFrame.CanvasSize = UDim2.new(0,0,0, #options*42)
        
        self.Items[id] = {type = "Dropdown", frame = frame, list = listFrame}
        return id
    end
    
    -- Para modificar depois (exemplo básico)
    function self:setItem(id: string, newValue: any)
        local item = self.Items[id]
        if not item then return end
        
        if item.type == "Toggle" and typeof(newValue) == "boolean" then
            item.update(newValue)
            item.value = newValue
        elseif item.type == "Input" and typeof(newValue) == "string" then
            item.textbox.Text = newValue
        elseif item.type == "Dropdown" and typeof(newValue) == "string" then
            item.frame.Text = newValue
        end
    end
    
    -- Cria tab padrão se não tiver
    self:CreateTab()
    
    return self
end

return CustomUI
