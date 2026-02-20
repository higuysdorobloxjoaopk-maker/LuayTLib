--[[ 
    luayTLib - UI Library (Pro Mobile Edition)
    Fidelidade 1:1 - Funcional e Estável
]]

local luayTLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Configurações de Design (Paleta Extraída da Imagem)
local THEME = {
    MainBg = Color3.fromRGB(45, 45, 45),
    SidebarBg = Color3.fromRGB(35, 35, 35),
    ElementBg = Color3.fromRGB(60, 60, 60),
    AccentPurple = Color3.fromRGB(108, 44, 245),
    AccentGreen = Color3.fromRGB(0, 200, 83),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(70, 70, 70)
}

function luayTLib:CreateWindow(hubName)
    hubName = hubName or "Exemple"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayTLib_Premium"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- [MINIMIZE HANDLE] - Estilo Xiaomi
    local MinimizeHandle = Instance.new("TextButton")
    MinimizeHandle.Name = "MinimizeHandle"
    MinimizeHandle.Size = UDim2.new(0, 6, 0, 70)
    MinimizeHandle.Position = UDim2.new(0, 0, 0.5, -35)
    MinimizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeHandle.BackgroundTransparency = 0.3
    MinimizeHandle.Text = ""
    MinimizeHandle.AutoButtonColor = false
    MinimizeHandle.Parent = ScreenGui
    
    Instance.new("UICorner", MinimizeHandle).CornerRadius = UDim.new(0, 4)

    -- [MAIN FRAME]
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 330)
    Main.Position = UDim2.new(0.5, -275, 0.5, -165)
    Main.BackgroundColor3 = THEME.MainBg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    -- [SIDEBAR]
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = THEME.SidebarBg
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Size = UDim2.new(1, -20, 0, 30)
    TabTitle.Position = UDim2.new(0, 12, 0, 10)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = "Tabs"
    TabTitle.TextColor3 = THEME.TextMain
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.TextSize = 16
    TabTitle.Parent = Sidebar

    -- [SEARCH BAR]
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 24)
    SearchBox.Position = UDim2.new(0, 10, 0, 38)
    SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "🔍 Search..."
    SearchBox.PlaceholderColor3 = THEME.TextDark
    SearchBox.TextColor3 = THEME.TextMain
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = Sidebar
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 12)

    -- [TABS CONTAINER]
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -80)
    TabScroll.Position = UDim2.new(0, 0, 0, 75)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabScroll
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- [CONTENT AREA]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -150, 1, 0)
    Container.Position = UDim2.new(0, 150, 0, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, -30, 0, 50)
    Header.Position = UDim2.new(0, 15, 0, 5)
    Header.BackgroundTransparency = 1
    Header.Text = hubName .. " <font color='#b0b0b0'>Main</font>"
    Header.RichText = true
    Header.TextColor3 = THEME.TextMain
    Header.TextSize = 26
    Header.Font = Enum.Font.GothamBold
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Container

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, -60)
    PageContainer.Position = UDim2.new(0, 0, 0, 55)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Container

    -- [SCROLLING LOGIC]
    local function CreatePage()
        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, -15, 1, -10)
        Scroll.Position = UDim2.new(0, 15, 0, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.ScrollBarThickness = 4
        Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll.Visible = false
        Scroll.Parent = PageContainer

        local List = Instance.new("UIListLayout")
        List.Parent = Scroll
        List.Padding = UDim.new(0, 8)
        
        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 10)
        end)

        return Scroll
    end

    local currentTab = nil
    
    function luayTLib:AddTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
        TabBtn.BackgroundColor3 = THEME.ElementBg
        TabBtn.BackgroundTransparency = 0.5
        TabBtn.Text = name
        TabBtn.TextColor3 = THEME.TextDark
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 14
        TabBtn.Parent = TabScroll
        
        local Corner = Instance.new("UICorner", TabBtn)
        Corner.CornerRadius = UDim.new(0, 8)
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 4, 0, 20)
        Indicator.Position = UDim2.new(1, -2, 0.5, -10)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Visible = false
        Indicator.Parent = TabBtn
        Instance.new("UICorner", Indicator)

        local Page = CreatePage()

        TabBtn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Btn.BackgroundTransparency = 0.5
                currentTab.Btn.TextColor3 = THEME.TextDark
                currentTab.Btn.Indicator.Visible = false
                currentTab.Page.Visible = false
            end
            TabBtn.BackgroundTransparency = 0.1
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Visible = true
            Page.Visible = true
            currentTab = {Btn = TabBtn, Page = Page, Indicator = Indicator}
        end)

        -- Elementos da Página
        local Elements = {}

        function Elements:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.95, 0, 0, 40)
            Btn.BackgroundColor3 = THEME.ElementBg
            Btn.Text = text
            Btn.TextColor3 = THEME.TextMain
            Btn.Font = Enum.Font.GothamSemibold
            Btn.TextSize = 16
            Btn.AutoButtonColor = true
            Btn.Parent = Page
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(1, -30, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://6034503241"
            Icon.Parent = Btn

            Btn.MouseButton1Click:Connect(callback)
        end

        function Elements:AddToggle(text, default, callback)
            local TglFrame = Instance.new("Frame")
            TglFrame.Size = UDim2.new(0.95, 0, 0, 45)
            TglFrame.BackgroundColor3 = THEME.ElementBg
            TglFrame.Parent = Page
            Instance.new("UICorner", TglFrame).CornerRadius = UDim.new(0, 8)

            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, -60, 1, 0)
            L.Position = UDim2.new(0, 15, 0, 0)
            L.BackgroundTransparency = 1
            L.Text = text
            L.TextColor3 = THEME.TextMain
            L.Font = Enum.Font.GothamSemibold
            L.TextSize = 16
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Parent = TglFrame

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 44, 0, 22)
            Switch.Position = UDim2.new(1, -54, 0.5, -11)
            Switch.BackgroundColor3 = default and THEME.AccentPurple or Color3.fromRGB(40, 40, 40)
            Switch.Text = ""
            Switch.Parent = TglFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 18, 0, 18)
            Circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Switch
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local state = default
            Switch.MouseButton1Click:Connect(function()
                state = not state
                local targetX = state and 1 or 0
                local targetOff = state and -20 or 2
                local targetColor = state and THEME.AccentPurple or Color3.fromRGB(40, 40, 40)
                
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(targetX, targetOff, 0.5, -9)}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                callback(state)
            end)
        end

        function Elements:AddDropdown(text, list, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(0.95, 0, 0, 40)
            DropFrame.BackgroundColor3 = THEME.ElementBg
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = Page
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 40)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = "  " .. text
            DropBtn.TextColor3 = THEME.TextMain
            DropBtn.Font = Enum.Font.GothamSemibold
            DropBtn.TextSize = 16
            DropBtn.TextXAlignment = Enum.TextXAlignment.Left
            DropBtn.Parent = DropFrame

            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Position = UDim2.new(1, -30, 0, 10)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = "rbxassetid://6034818372"
            Arrow.Parent = DropFrame

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -20, 0, 0)
            ItemHolder.Position = UDim2.new(0, 10, 0, 40)
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = DropFrame

            local UIList = Instance.new("UIListLayout")
            UIList.Parent = ItemHolder
            UIList.Padding = UDim.new(0, 5)

            local open = false
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                local targetSize = open and (45 + UIList.AbsoluteContentSize.Y) or 40
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, targetSize)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = open and 90 or 0}):Play()
            end)

            for _, item in ipairs(list) do
                local Itm = Instance.new("TextButton")
                Itm.Size = UDim2.new(1, 0, 0, 30)
                Itm.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Itm.Text = item
                Itm.TextColor3 = THEME.TextDark
                Itm.Font = Enum.Font.Gotham
                Itm.TextSize = 14
                Itm.Parent = ItemHolder
                Instance.new("UICorner", Itm).CornerRadius = UDim.new(0, 6)
                
                Itm.MouseButton1Click:Connect(function()
                    callback(item)
                    DropBtn.Text = "  " .. text .. ": " .. item
                end)
            end
        end

        -- Ativa a primeira aba automaticamente
        if not currentTab then
            TabBtn.BackgroundTransparency = 0.1
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Visible = true
            Page.Visible = true
            currentTab = {Btn = TabBtn, Page = Page, Indicator = Indicator}
        end

        return Elements
    end

    -- [DRAG LOGIC]
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- [MINIMIZE LOGIC]
    local shown = true
    MinimizeHandle.MouseButton1Click:Connect(function()
        shown = not shown
        local target = shown and UDim2.new(0.5, -275, 0.5, -165) or UDim2.new(-1, 0, 0.5, -165)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
    end)

    return luayTLib
end

return luayTLib
