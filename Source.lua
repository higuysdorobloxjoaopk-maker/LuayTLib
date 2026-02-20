--[[
    Tlib UI Library
    Inspirado no design enviado.
    Atalhos: "Z" para minimizar/maximizar.
]]

local Tlib = {}
Tlib.__index = Tlib

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Cores baseadas na imagem
local Colors = {
    MainBG = Color3.fromRGB(65, 65, 65),
    HeaderBG = Color3.fromRGB(85, 85, 85),
    Accent = Color3.fromRGB(138, 85, 255),
    SideBar = Color3.fromRGB(75, 75, 75),
    Text = Color3.fromRGB(255, 255, 255),
    ElementBG = Color3.fromRGB(90, 90, 90)
}

function Tlib.new(title)
    local self = setmetatable({}, Tlib)
    
    -- Instância Principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "Tlib_UI"
    self.ScreenGui.Parent = (runService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
    self.ScreenGui.ResetOnSpawn = false

    -- Container Principal
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, 450, 0, 350)
    self.MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    self.MainFrame.BackgroundColor3 = Colors.MainBG
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.ClipsDescendants = true
    self.MainFrame.Parent = self.ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = self.MainFrame

    -- Header (Título e Botões)
    self.Header = Instance.new("Frame")
    self.Header.Size = UDim2.new(1, 0, 0, 50)
    self.Header.BackgroundColor3 = Colors.HeaderBG
    self.Header.BorderSizePixel = 0
    self.Header.Parent = self.MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = title or "Exempleui"
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 28
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = self.Header

    -- Barra de Minimizar (Estilo Xiaomi/Poco)
    self.MiniBar = Instance.new("TextButton")
    self.MiniBar.Name = "MiniBar"
    self.MiniBar.Size = UDim2.new(0, 100, 0, 5)
    self.MiniBar.Position = UDim2.new(0.5, -50, 0, 5)
    self.MiniBar.BackgroundColor3 = Colors.Accent
    self.MiniBar.Text = ""
    self.MiniBar.Visible = false
    self.MiniBar.Parent = self.ScreenGui

    local MiniCorner = Instance.new("UICorner")
    MiniCorner.CornerRadius = UDim.new(1, 0)
    MiniCorner.Parent = self.MiniBar

    -- Sidebar (Menu de Abas)
    self.Sidebar = Instance.new("ScrollingFrame")
    self.Sidebar.Size = UDim2.new(0, 120, 1, -60)
    self.Sidebar.Position = UDim2.new(0, 0, 0, 60)
    self.Sidebar.BackgroundColor3 = Colors.SideBar
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.BorderSizePixel = 0
    self.Sidebar.ScrollBarThickness = 2
    self.Sidebar.Parent = self.MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SideLayout.Parent = self.Sidebar

    -- Separador Roxo Lateral (Vertical)
    local Separator = Instance.new("Frame")
    Separator.Size = UDim2.new(0, 4, 1, -50)
    Separator.Position = UDim2.new(0, 125, 0, 50)
    Separator.BackgroundColor3 = Colors.Accent
    Separator.BorderSizePixel = 0
    Separator.Parent = self.MainFrame

    -- Container de Conteúdo
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, -140, 1, -60)
    self.Container.Position = UDim2.new(0, 135, 0, 60)
    self.Container.BackgroundTransparency = 1
    self.Container.Parent = self.MainFrame

    self.Tabs = {}
    self.ActiveTab = nil

    -- Lógica de Minimizar (Z ou Botão X)
    local isMinimized = false
    
    local function toggleUI()
        isMinimized = not isMinimized
        if isMinimized then
            self.MainFrame.Visible = false
            self.MiniBar.Visible = true
        else
            self.MainFrame.Visible = true
            self.MiniBar.Visible = false
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Z then
            toggleUI()
        end
    end)

    self.MiniBar.MouseButton1Click:Connect(toggleUI)

    return self
end

function Tlib:CreateTab(name)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0.9, 0, 0, 35)
    TabButton.BackgroundColor3 = Colors.ElementBG
    TabButton.Text = name
    TabButton.TextColor3 = Colors.Text
    TabButton.Font = Enum.Font.SourceSans
    TabButton.TextSize = 18
    TabButton.Parent = self.Sidebar

    local TabIndicator = Instance.new("Frame")
    TabIndicator.Size = UDim2.new(0, 5, 1, 0)
    TabIndicator.BackgroundColor3 = Colors.Accent
    TabIndicator.BorderSizePixel = 0
    TabIndicator.Visible = false
    TabIndicator.Parent = TabButton

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 4)
    TabCorner.Parent = TabButton

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 0
    Page.Parent = self.Container

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 10)
    PageLayout.Parent = Page

    TabButton.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do
            t.Page.Visible = false
            t.Indicator.Visible = false
        end
        Page.Visible = true
        TabIndicator.Visible = true
    end)

    table.insert(self.Tabs, {Page = Page, Indicator = TabIndicator})
    
    -- Ativar primeira aba por padrão
    if #self.Tabs == 1 then
        Page.Visible = true
        TabIndicator.Visible = true
    end

    local TabMethods = {}

    function TabMethods:AddToggle(text, callback)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
        ToggleFrame.BackgroundColor3 = Colors.ElementBG
        ToggleFrame.Parent = Page

        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Text = text
        ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.TextColor3 = Colors.Text
        ToggleLabel.TextSize = 22
        ToggleLabel.Font = Enum.Font.SourceSans
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame

        local SwitchBG = Instance.new("TextButton")
        SwitchBG.Size = UDim2.new(0, 50, 0, 25)
        SwitchBG.Position = UDim2.new(1, -60, 0.5, -12)
        SwitchBG.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        SwitchBG.Text = ""
        SwitchBG.Parent = ToggleFrame

        local SwitchCorner = Instance.new("UICorner")
        SwitchCorner.CornerRadius = UDim.new(1, 0)
        SwitchCorner.Parent = SwitchBG

        local Slider = Instance.new("Frame")
        Slider.Size = UDim2.new(0, 21, 0, 21)
        Slider.Position = UDim2.new(0, 2, 0.5, -10)
        Slider.BackgroundColor3 = Colors.Accent
        Slider.Parent = SwitchBG

        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(1, 0)
        SliderCorner.Parent = Slider

        local enabled = false
        SwitchBG.MouseButton1Click:Connect(function()
            enabled = not enabled
            local targetPos = enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            TweenService:Create(Slider, TweenInfo.new(0.2), {Position = targetPos}):Play()
            callback(enabled)
        end)
    end

    return TabMethods
end

return Tlib
