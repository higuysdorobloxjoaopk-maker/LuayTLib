--[[
    luayTLib - UI LIBRARY
    Fiel à imagem de referência (Xiaomi Game Turbo Style)
    Desenvolvido para Mobile (Delta, Fluxus, etc.)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local luayTLib = {}

-- Utilitário para Arrastar (Mobile & Desktop)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function luayTLib:CreateWindow(title, subtitle)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayTLib_GUI"
    ScreenGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- GATILHO XIAOMI (Barrinha branca no canto esquerdo)
    local Trigger = Instance.new("Frame")
    Trigger.Name = "Trigger"
    Trigger.Parent = ScreenGui
    Trigger.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Trigger.BackgroundTransparency = 0.4
    Trigger.BorderSizePixel = 0
    Trigger.Position = UDim2.new(0, 0, 0.4, 0)
    Trigger.Size = UDim2.new(0, 4, 0, 60)
    
    local TriggerCorner = Instance.new("UICorner")
    TriggerCorner.CornerRadius = UDim.new(0, 4)
    TriggerCorner.Parent = Trigger

    -- CONTAINER PRINCIPAL (Baseado na imagem - Cinza Escuro)
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Cor cinza da imagem
    Main.Position = UDim2.new(0.5, -250, 0.5, -140)
    Main.Size = UDim2.new(0, 500, 0, 280) -- Tamanho compacto solicitado
    Main.Visible = false
    Main.ClipsDescendants = false -- Permitir abas saltadas
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    MakeDraggable(Main)

    -- Sombra Lateral das Tabs (Aba saliente à esquerda)
    local TabSidebar = Instance.new("Frame")
    TabSidebar.Name = "TabSidebar"
    TabSidebar.Parent = Main
    TabSidebar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabSidebar.Position = UDim2.new(0, -100, 0, 20)
    TabSidebar.Size = UDim2.new(0, 100, 0, 140)
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabSidebar

    local TabLabel = Instance.new("TextLabel")
    TabLabel.Parent = TabSidebar
    TabLabel.Text = "Tabs"
    TabLabel.Font = Enum.Font.GothamBold
    TabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabLabel.TextSize = 12
    TabLabel.Position = UDim2.new(0, 10, 0, 5)
    TabLabel.Size = UDim2.new(0, 50, 0, 20)
    TabLabel.BackgroundTransparency = 1
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = TabSidebar
    TabContainer.Position = UDim2.new(0, 5, 0, 25)
    TabContainer.Size = UDim2.new(1, -10, 1, -30)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 5)

    -- HEADER DA JANELA (Título e Cursor na imagem)
    local Header = Instance.new("TextLabel")
    Header.Parent = Main
    Header.Text = " " .. title .. " <font color='#BBB'>" .. subtitle .. "</font>"
    Header.RichText = true
    Header.Font = Enum.Font.GothamBold
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextSize = 32
    Header.Position = UDim2.new(0, 10, 0, 0)
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.TextXAlignment = Enum.TextXAlignment.Left

    -- ÁREAS DE CONTEÚDO (Dividido em colunas conforme a imagem)
    local LeftContent = Instance.new("Frame")
    LeftContent.Name = "LeftContent"
    LeftContent.Parent = Main
    LeftContent.Position = UDim2.new(0, 15, 0, 55)
    LeftContent.Size = UDim2.new(0.45, 0, 1, -70)
    LeftContent.BackgroundTransparency = 1

    local LeftList = Instance.new("UIListLayout")
    LeftList.Parent = LeftContent
    LeftList.Padding = UDim.new(0, 8)

    local RightContent = Instance.new("Frame")
    RightContent.Name = "RightContent"
    RightContent.Parent = Main
    RightContent.Position = UDim2.new(0.52, 0, 0, 55)
    RightContent.Size = UDim2.new(0.45, 0, 1, -70)
    RightContent.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
    
    local RightCorner = Instance.new("UICorner")
    RightCorner.CornerRadius = UDim.new(0, 10)
    RightCorner.Parent = RightContent

    -- Abrir/Fechar
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Main.Visible = not Main.Visible
            Trigger.BackgroundTransparency = Main.Visible and 0.1 or 0.4
        end
    end)

    local Tabs = {}

    function Tabs:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(1, 0, 0, 45)
        TabBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        TabBtn.Text = ""
        
        local TBCorner = Instance.new("UICorner")
        TBCorner.CornerRadius = UDim.new(0, 8)
        TBCorner.Parent = TabBtn
        
        local Icon = Instance.new("ImageLabel")
        Icon.Parent = TabBtn
        Icon.Size = UDim2.new(0, 30, 0, 30)
        Icon.Position = UDim2.new(0, 5, 0.5, -15)
        Icon.Image = "rbxassetid://10734895619" -- Placeholder de imagem
        Icon.BackgroundTransparency = 1

        local Txt = Instance.new("TextLabel")
        Txt.Parent = TabBtn
        Txt.Text = name
        Txt.Font = Enum.Font.GothamBold
        Txt.TextSize = 10
        Txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        Txt.Position = UDim2.new(0, 40, 0, 5)
        Txt.Size = UDim2.new(1, -45, 0, 15)
        Txt.BackgroundTransparency = 1
        Txt.TextXAlignment = Enum.TextXAlignment.Left

        local Elements = {}

        -- Botão Estilo "Click" com Ícone de Avião
        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Parent = LeftContent
            Btn.Size = UDim2.new(1, 0, 0, 45)
            Btn.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
            Btn.Text = text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 24
            Btn.TextXAlignment = Enum.TextXAlignment.Left
            
            local Padding = Instance.new("UIPadding")
            Padding.PaddingLeft = UDim.new(0, 15)
            Padding.Parent = Btn

            local Icon = Instance.new("ImageLabel")
            Icon.Parent = Btn
            Icon.Image = "rbxassetid://6034287518" -- Ícone similar ao da imagem
            Icon.Size = UDim2.new(0, 25, 0, 25)
            Icon.Position = UDim2.new(1, -35, 0.5, -12)
            Icon.BackgroundTransparency = 1

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Btn

            Btn.MouseButton1Click:Connect(callback)
        end

        -- Toggle com cores da imagem (Roxo/Verde)
        function Elements:CreateToggle(text, callback)
            local Frame = Instance.new("Frame")
            Frame.Parent = LeftContent
            Frame.Size = UDim2.new(1, 0, 0, 45)
            Frame.BackgroundColor3 = Color3.fromRGB(110, 110, 110)
            
            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Frame
            
            local Label = Instance.new("TextLabel")
            Label.Parent = Frame
            Label.Text = text
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 24
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame")
            Switch.Parent = Frame
            Switch.Position = UDim2.new(1, -70, 0.5, -12)
            Switch.Size = UDim2.new(0, 60, 0, 24)
            Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = Switch
            
            local Indicator = Instance.new("Frame")
            Indicator.Parent = Switch
            Indicator.Size = UDim2.new(0.5, -4, 1, -4)
            Indicator.Position = UDim2.new(0, 2, 0, 2)
            Indicator.BackgroundColor3 = Color3.fromRGB(108, 44, 245) -- Roxo da imagem
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(0, 4)
            ICorner.Parent = Indicator

            local active = false
            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    active = not active
                    Indicator.BackgroundColor3 = active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(108, 44, 245)
                    TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = active and UDim2.new(0.5, 2, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
                    callback(active)
                end
            end)
        end

        return Elements
    end

    -- Adicionar Card de Perfil na direita (como na imagem)
    local ProfileCard = Instance.new("Frame")
    ProfileCard.Parent = RightContent
    ProfileCard.Size = UDim2.new(1, -20, 0, 120)
    ProfileCard.Position = UDim2.new(0, 10, 0, 10)
    ProfileCard.BackgroundColor3 = Color3.fromRGB(130, 130, 130)
    
    local PCorner = Instance.new("UICorner")
    PCorner.CornerRadius = UDim.new(0, 8)
    PCorner.Parent = ProfileCard

    local Img = Instance.new("ImageLabel")
    Img.Parent = ProfileCard
    Img.Size = UDim2.new(0, 60, 0, 60)
    Img.Position = UDim2.new(0, 10, 0, 10)
    Img.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Parent = ProfileCard
    NameLabel.Text = "Name gui"
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 22
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Position = UDim2.new(0, 80, 0, 10)
    NameLabel.Size = UDim2.new(0, 100, 0, 25)
    NameLabel.BackgroundTransparency = 1
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local DiscordBtn = Instance.new("TextButton")
    DiscordBtn.Parent = ProfileCard
    DiscordBtn.Size = UDim2.new(0, 60, 0, 18)
    DiscordBtn.Position = UDim2.new(0, 10, 0, 75)
    DiscordBtn.BackgroundColor3 = Color3.fromRGB(108, 44, 245)
    DiscordBtn.Text = "Discord"
    DiscordBtn.TextSize = 10
    DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", DiscordBtn).CornerRadius = UDim.new(0, 4)

    return Tabs
end

-- Exemplo de uso idêntico ao layout da imagem:
local Window = luayTLib:CreateWindow("Exemple", "Main")
local MainTab = Window:CreateTab("Main")

MainTab:CreateButton("Click", function() print("Clicado!") end)
MainTab:CreateToggle("Toggle", function(state) print("Toggle 1:", state) end)
MainTab:CreateToggle("Toggle", function(state) print("Toggle 2:", state) end)

return luayTLib
