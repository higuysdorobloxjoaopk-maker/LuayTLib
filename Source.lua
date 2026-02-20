--[[
    luayTLib - UI LIBRARY
    Estilo Xiaomi Game Turbo para Roblox Mobile
    Focado em: Delta, Fluxus e outros executores.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local luayTLib = {}

-- Função interna para tornar elementos arrastáveis (Otimizada para Mobile)
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

    -- GATILHO ESTILO XIAOMI (A barrinha branca no canto superior esquerdo)
    local Trigger = Instance.new("Frame")
    Trigger.Name = "TurboTrigger"
    Trigger.Parent = ScreenGui
    Trigger.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Trigger.BackgroundTransparency = 0.4
    Trigger.BorderSizePixel = 0
    Trigger.Position = UDim2.new(0, 0, 0.35, 0)
    Trigger.Size = UDim2.new(0, 5, 0, 85) 
    
    local TriggerCorner = Instance.new("UICorner")
    TriggerCorner.CornerRadius = UDim.new(0, 6)
    TriggerCorner.Parent = Trigger

    -- Container Principal (Janela)
    local Main = Instance.new("Frame")
    Main.Name = "MainFrame"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    Main.Position = UDim2.new(0.5, -300, 0.5, -175)
    Main.Size = UDim2.new(0, 600, 0, 360)
    Main.Visible = false
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 20)
    MainCorner.Parent = Main

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.88
    Stroke.Thickness = 1.2
    Stroke.Parent = Main

    MakeDraggable(Main)

    -- Sistema de Auto-Redimensionamento (Mobile Friendly)
    local function AutoScale()
        local viewport = workspace.CurrentCamera.ViewportSize
        if viewport.X < 800 then -- Se for telemóvel
            Main.Size = UDim2.new(0, viewport.X * 0.92, 0, viewport.Y * 0.75)
            Main.Position = UDim2.new(0.04, 0, 0.12, 0)
        else
            Main.Size = UDim2.new(0, 620, 0, 380)
        end
    end
    AutoScale()
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(AutoScale)

    -- Sidebar de Tabs
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Sidebar.Size = UDim2.new(0, 170, 1, 0)
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Parent = Sidebar
    TabContainer.Size = UDim2.new(1, -20, 1, -40)
    TabContainer.Position = UDim2.new(0, 10, 0, 20)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabContainer
    TabList.Padding = UDim.new(0, 12)

    -- Área de Conteúdo Central
    local Content = Instance.new("Frame")
    Content.Name = "ContentArea"
    Content.Parent = Main
    Content.Position = UDim2.new(0, 185, 0, 20)
    Content.Size = UDim2.new(1, -205, 1, -40)
    Content.BackgroundTransparency = 1

    local Header = Instance.new("TextLabel")
    Header.Parent = Content
    Header.Text = title .. " <font color='#999'>" .. subtitle .. "</font>"
    Header.RichText = true
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 28
    Header.TextColor3 = Color3.fromRGB(255, 255, 255)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1

    -- Lógica de Gatilho (Xiaomi Style)
    local isVisible = false
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isVisible = not isVisible
            Main.Visible = isVisible
            if isVisible then
                TweenService:Create(Trigger, TweenInfo.new(0.3), {Size = UDim2.new(0, 14, 0, 95), BackgroundTransparency = 0.2}):Play()
            else
                TweenService:Create(Trigger, TweenInfo.new(0.3), {Size = UDim2.new(0, 5, 0, 85), BackgroundTransparency = 0.4}):Play()
            end
        end
    end)

    local TabLogic = {}

    function TabLogic:CreateTab(name, desc)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "_Tab"
        TabBtn.Parent = TabContainer
        TabBtn.Size = UDim2.new(1, 0, 0, 55)
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 12)
        Corner.Parent = TabBtn
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Parent = TabBtn
        TabTitle.Text = name
        TabTitle.Font = Enum.Font.GothamBold
        TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabTitle.TextSize = 15
        TabTitle.Position = UDim2.new(0, 12, 0, 10)
        TabTitle.BackgroundTransparency = 1
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left

        local TabDesc = Instance.new("TextLabel")
        TabDesc.Parent = TabBtn
        TabDesc.Text = desc or "Funcionalidades..."
        TabDesc.Font = Enum.Font.Gotham
        TabDesc.TextColor3 = Color3.fromRGB(160, 160, 160)
        TabDesc.TextSize = 11
        TabDesc.Position = UDim2.new(0, 12, 0, 28)
        TabDesc.BackgroundTransparency = 1
        TabDesc.TextXAlignment = Enum.TextXAlignment.Left

        local Page = Instance.new("ScrollingFrame")
        Page.Parent = Content
        Page.Size = UDim2.new(1, 0, 1, -60)
        Page.Position = UDim2.new(0, 0, 0, 60)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
        
        local PageList = Instance.new("UIListLayout")
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 10)
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Content:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in pairs(TabContainer:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
            end
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(85, 45, 200) -- Roxo Xiaomi
        end)

        local Elements = {}

        -- Toggle Widget
        function Elements:CreateToggle(text, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 55)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(62, 62, 62)
            ToggleFrame.Parent = Page
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 14)
            TCorner.Parent = ToggleFrame
            
            local TTitle = Instance.new("TextLabel")
            TTitle.Parent = ToggleFrame
            TTitle.Text = text
            TTitle.Font = Enum.Font.GothamSemibold
            TTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TTitle.TextSize = 17
            TTitle.Position = UDim2.new(0, 20, 0, 0)
            TTitle.Size = UDim2.new(0.6, 0, 1, 0)
            TTitle.BackgroundTransparency = 1
            TTitle.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame")
            Switch.Parent = ToggleFrame
            Switch.Position = UDim2.new(1, -75, 0.5, -14)
            Switch.Size = UDim2.new(0, 55, 0, 28)
            Switch.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Knob = Instance.new("Frame")
            Knob.Parent = Switch
            Knob.Size = UDim2.new(0, 22, 0, 22)
            Knob.Position = UDim2.new(0, 3, 0.5, -11)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            
            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(1, 0)
            KCorner.Parent = Knob

            local toggled = false
            ToggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    toggled = not toggled
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Color3.fromRGB(108, 44, 245) or Color3.fromRGB(90, 90, 90)}):Play()
                    TweenService:Create(Knob, TweenInfo.new(0.2), {Position = toggled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)}):Play()
                    callback(toggled)
                end
            end)
        end

        -- Button Widget
        function Elements:CreateButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 55)
            Btn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
            Btn.Text = text
            Btn.Font = Enum.Font.GothamBold
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 17
            Btn.Parent = Page
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 14)
            BCorner.Parent = Btn
            
            Btn.MouseButton1Click:Connect(callback)
        end

        return Elements
    end

    return TabLogic
end

-- Exemplo de Inicialização com o novo nome
local UI = luayTLib:CreateWindow("Exemple", "Main")
local Principal = UI:CreateTab("Main", "Configurações")

Principal:CreateToggle("Auto-Farm", function(v)
    print("Auto Farm está:", v)
end)

Principal:CreateButton("Teleport Lobby", function()
    print("Teleportando...")
end)

return luayTLib
