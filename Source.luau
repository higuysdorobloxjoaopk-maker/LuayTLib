--[[ 
    luayTLib - UI Library (Mobile Optimized)
    Design: Identidade visual 1:1 com a referência.
    Funcionalidades: Barra lateral de minimização, Arrastável, Dropdowns, Toggles.
]]

local luayTLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Cores da Imagem
local COLORS = {
    Background = Color3.fromRGB(80, 80, 80),
    Sidebar = Color3.fromRGB(65, 65, 65),
    AccentPurple = Color3.fromRGB(108, 44, 245),
    AccentGreen = Color3.fromRGB(0, 200, 83),
    ItemBg = Color3.fromRGB(120, 120, 120),
    SearchBg = Color3.fromRGB(55, 55, 55),
    TextGray = Color3.fromRGB(176, 176, 176)
}

function luayTLib:CreateWindow()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayTLib"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Barra de Minimização Lateral
    local MinimizeHandle = Instance.new("TextButton")
    MinimizeHandle.Name = "MinimizeHandle"
    MinimizeHandle.Size = UDim2.new(0, 6, 0, 60)
    MinimizeHandle.Position = UDim2.new(0, 0, 0.5, -30)
    MinimizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeHandle.BackgroundTransparency = 0.4
    MinimizeHandle.Text = ""
    MinimizeHandle.Parent = ScreenGui
    Instance.new("UICorner", MinimizeHandle).CornerRadius = UDim.new(0, 4)

    -- Container Principal (Janela Pequena Mobile)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 520, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 15)
    MainCorner.Parent = MainFrame

    -- Sidebar (Esquerda)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Size = UDim2.new(1, -20, 0, 25)
    TabTitle.Position = UDim2.new(0, 10, 0, 10)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = "Tabs"
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Font = Enum.Font.SourceSansBold
    TabTitle.TextSize = 18
    TabTitle.Parent = Sidebar

    -- Search Bar
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Size = UDim2.new(1, -20, 0, 22)
    SearchFrame.Position = UDim2.new(0, 10, 0, 35)
    SearchFrame.BackgroundColor3 = COLORS.SearchBg
    SearchFrame.Parent = Sidebar
    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 10)

    local SearchLabel = Instance.new("TextLabel")
    SearchLabel.Size = UDim2.new(1, -10, 1, 0)
    SearchLabel.Position = UDim2.new(0, 8, 0, 0)
    SearchLabel.BackgroundTransparency = 1
    SearchLabel.Text = "🔍 Search..."
    SearchLabel.TextColor3 = COLORS.TextGray
    SearchLabel.TextSize = 12
    SearchLabel.TextXAlignment = Enum.TextXAlignment.Left
    SearchLabel.Parent = SearchFrame

    -- Tab Items (Exemplo)
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 1, -70)
    TabContainer.Position = UDim2.new(0, 0, 0, 65)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar

    local function CreateTab(name, active)
        local Tab = Instance.new("Frame")
        Tab.Size = UDim2.new(1, -10, 0, 30)
        Tab.Position = UDim2.new(0, 5, 0, active and 0 or 35)
        Tab.BackgroundColor3 = active and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(100, 100, 100)
        Tab.BackgroundTransparency = active and 0.2 or 0.8
        Tab.Parent = TabContainer
        Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 6)

        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(1, -15, 1, 0)
        L.Position = UDim2.new(0, 8, 0, 0)
        L.BackgroundTransparency = 1
        L.Text = name
        L.TextColor3 = Color3.fromRGB(255, 255, 255)
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.Font = Enum.Font.SourceSansBold
        L.TextSize = 16
        L.Parent = Tab

        if active then
            local Ind = Instance.new("Frame")
            Ind.Size = UDim2.new(0, 4, 0, 18)
            Ind.Position = UDim2.new(1, 2, 0.5, -9)
            Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Ind.Parent = Tab
            Instance.new("UICorner", Ind)
        end
    end
    CreateTab("Main", true)
    CreateTab("Main", false)

    -- Área de Conteúdo Central
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -150, 1, -20)
    Content.Position = UDim2.new(0, 140, 0, 10)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 5
    Content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    Content.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Content

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundTransparency = 1
    Header.Text = "Exemple <font size='14' color='#b0b0b0'>Main</font>"
    Header.RichText = true
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 32
    Header.Font = Enum.Font.SourceSansBold
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Content

    -- Elementos Genéricos (Click, Toggle, Dropdown)
    local function AddElement(name, type, options)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0.95, 0, 0, 40)
        Frame.BackgroundColor3 = COLORS.ItemBg
        Frame.Parent = Content
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local L = Instance.new("TextLabel")
        L.Size = UDim2.new(0.6, 0, 1, 0)
        L.Position = UDim2.new(0, 12, 0, 0)
        L.BackgroundTransparency = 1
        L.Text = name
        L.TextColor3 = Color3.fromRGB(255, 255, 255)
        L.TextSize = 22
        L.Font = Enum.Font.SourceSansBold
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.Parent = Frame

        if type == "Click" then
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 24, 0, 24)
            Icon.Position = UDim2.new(1, -35, 0.5, -12)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://6034503241" -- Cursor/Send icon
            Icon.Parent = Frame
        elseif type == "Toggle" then
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 42, 0, 20)
            Switch.Position = UDim2.new(1, -55, 0.5, -10)
            Switch.BackgroundColor3 = options.color or COLORS.AccentPurple
            Switch.Parent = Frame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 10)
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = UDim2.new(1, -18, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            Circle.Parent = Switch
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
        elseif type == "Dropdown" then
            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 24, 0, 24)
            Arrow.Position = UDim2.new(1, -35, 0.5, -12)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://6034818372" -- Arrow right
            Arrow.Parent = Frame
        end
    end

    AddElement("Click", "Click")
    AddElement("Toggle", "Toggle", {color = COLORS.AccentPurple})
    AddElement("Toggle", "Toggle", {color = COLORS.AccentGreen})
    AddElement("DropDown", "Dropdown")

    -- Lógica de Arrastar (Mobile & PC)
    local dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragStart then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Lógica de Minimização
    local isVisible = true
    MinimizeHandle.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        local target = isVisible and UDim2.new(0.5, -260, 0.5, -160) or UDim2.new(-1, 0, 0.5, -160)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
    end)

    return luayTLib
end

-- Exemplo de uso:
-- luayTLib:CreateWindow()

return luayTLib
