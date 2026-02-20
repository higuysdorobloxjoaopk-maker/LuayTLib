--[[ 
    made by gemini pro🫠
    luayTLib - UI Library
    Inspirada no design da imagem fornecida.
    Funcionalidades: Minimização lateral, Arrastável, Responsivo.
]]

local luayTLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

function luayTLib:CreateWindow(titleText)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayTLib"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Barra de Minimização (Estilo Game Turbo)
    local MinimizeHandle = Instance.new("TextButton")
    MinimizeHandle.Name = "MinimizeHandle"
    MinimizeHandle.Size = UDim2.new(0, 6, 0, 60)
    MinimizeHandle.Position = UDim2.new(0, 0, 0.5, -30)
    MinimizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeHandle.BackgroundTransparency = 0.5
    MinimizeHandle.Text = ""
    MinimizeHandle.Parent = ScreenGui
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, 4)
    HandleCorner.Parent = MinimizeHandle

    -- Container Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 650, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(58, 58, 58)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    -- Sidebar (Esquerda)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(68, 68, 68)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Size = UDim2.new(1, -20, 0, 30)
    TabTitle.Position = UDim2.new(0, 10, 0, 10)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = "Tabs"
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Font = Enum.Font.SourceSansBold
    TabTitle.TextSize = 16
    TabTitle.Parent = Sidebar

    -- Área de Conteúdo (Meio)
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Position = UDim2.new(0, 170, 0, 15)
    ContentArea.Size = UDim2.new(0, 270, 1, -30)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ScrollBarThickness = 4
    ContentArea.CanvasSize = UDim2.new(0, 0, 2, 0) -- Ajustável
    ContentArea.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ContentArea

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    Header.Text = "Exemple <font size='14' color='#b0b0b0'>Main</font>"
    Header.RichText = true
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 28
    Header.Font = Enum.Font.SourceSansBold
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = ContentArea

    -- Painel de Perfil (Direita)
    local InfoPanel = Instance.new("Frame")
    InfoPanel.Name = "InfoPanel"
    InfoPanel.Size = UDim2.new(0, 180, 1, -30)
    InfoPanel.Position = UDim2.new(1, -195, 0, 15)
    InfoPanel.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
    InfoPanel.BorderSizePixel = 0
    InfoPanel.Parent = MainFrame

    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 8)
    InfoCorner.Parent = InfoPanel

    local ProfileImg = Instance.new("ImageLabel")
    ProfileImg.Size = UDim2.new(0, 80, 0, 80)
    ProfileImg.Position = UDim2.new(0, 10, 0, 10)
    ProfileImg.BackgroundColor3 = Color3.fromRGB(51, 51, 51)
    ProfileImg.Image = "rbxassetid://6031225818" -- Placeholder icon
    ProfileImg.Parent = InfoPanel

    local GuiName = Instance.new("TextLabel")
    GuiName.Size = UDim2.new(1, -20, 0, 30)
    GuiName.Position = UDim2.new(0, 10, 0, 100)
    GuiName.BackgroundTransparency = 1
    GuiName.Text = "Name gui"
    GuiName.TextColor3 = Color3.fromRGB(255, 255, 255)
    GuiName.TextSize = 24
    GuiName.Font = Enum.Font.SourceSansBold
    GuiName.TextXAlignment = Enum.TextXAlignment.Left
    GuiName.Parent = InfoPanel

    -- Lógica de Arrastar
    local dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then isDragging = false end
            end)
        end
    end)

    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then update(input) end
    end)

    -- Lógica de Minimização
    local isVisible = true
    MinimizeHandle.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        local targetPos = isVisible and UDim2.new(0.5, -325, 0.5, -190) or UDim2.new(-1, 0, 0.5, -190)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = targetPos}):Play()
    end)

    -- Funções para adicionar elementos
    function luayTLib:CreateToggle(name, default, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
        ToggleFrame.Parent = ContentArea
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = ToggleFrame

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -70, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 18
        Label.Font = Enum.Font.SourceSans
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleFrame

        local Switch = Instance.new("TextButton")
        Switch.Size = UDim2.new(0, 45, 0, 22)
        Switch.Position = UDim2.new(1, -55, 0.5, -11)
        Switch.BackgroundColor3 = default and Color3.fromRGB(108, 44, 245) or Color3.fromRGB(51, 51, 51)
        Switch.Text = ""
        Switch.Parent = ToggleFrame

        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(1, 0)
        SCorner.Parent = Switch

        local Circle = Instance.new("Frame")
        Circle.Size = UDim2.new(0, 18, 0, 18)
        Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Parent = Switch
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local toggled = default
        Switch.MouseButton1Click:Connect(function()
            toggled = not toggled
            local targetX = toggled and 1 or 0
            local targetOff = toggled and -20 or 2
            local targetCol = toggled and Color3.fromRGB(108, 44, 245) or Color3.fromRGB(51, 51, 51)
            
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(targetX, targetOff, 0.5, -9)}):Play()
            TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
            callback(toggled)
        end)
    end

    return luayTLib
end

return luayTLib
