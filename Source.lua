--[[ 
    luayTLib - UI Library (Mobile Optimized)
    Modos: "Normal" e "Transparente"
    Design: 1:1 com a imagem, funcional e compacto.
]]

local luayTLib = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local THEME = {
    MainBg = Color3.fromRGB(45, 45, 45),
    SidebarBg = Color3.fromRGB(35, 35, 35),
    ElementBg = Color3.fromRGB(60, 60, 60),
    AccentPurple = Color3.fromRGB(108, 44, 245),
    AccentGreen = Color3.fromRGB(0, 200, 83),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 180),
}

function luayTLib:CreateWindow(hubName, mode)
    hubName = hubName or "Exemple"
    mode = mode or "Normal" -- "Normal" ou "Transparente"
    
    local transparencyValue = (mode == "Transparente") and 0.25 or 0
    local bgTransparency = (mode == "Transparente") and 0.25 or 0

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayTLib_Final"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- [MINIMIZE HANDLE]
    local MinimizeHandle = Instance.new("TextButton")
    MinimizeHandle.Name = "MinimizeHandle"
    MinimizeHandle.Size = UDim2.new(0, 6, 0, 50)
    MinimizeHandle.Position = UDim2.new(0, 0, 0.5, -25)
    MinimizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeHandle.BackgroundTransparency = 0.4
    MinimizeHandle.Text = ""
    MinimizeHandle.Parent = ScreenGui
    Instance.new("UICorner", MinimizeHandle).CornerRadius = UDim.new(0, 4)

    -- [MAIN FRAME] - Reduzido para Mobile
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 480, 0, 280)
    Main.Position = UDim2.new(0.5, -240, 0.5, -140)
    Main.BackgroundColor3 = THEME.MainBg
    Main.BackgroundTransparency = bgTransparency
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

    -- [SIDEBAR]
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = THEME.SidebarBg
    Sidebar.BackgroundTransparency = bgTransparency
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local TabTitle = Instance.new("TextLabel")
    TabTitle.Size = UDim2.new(1, -20, 0, 25)
    TabTitle.Position = UDim2.new(0, 10, 0, 8)
    TabTitle.BackgroundTransparency = 1
    TabTitle.Text = "Tabs"
    TabTitle.TextColor3 = THEME.TextMain
    TabTitle.Font = Enum.Font.GothamBold
    TabTitle.TextSize = 14
    TabTitle.TextXAlignment = Enum.TextXAlignment.Left
    TabTitle.Parent = Sidebar

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -16, 0, 22)
    SearchBox.Position = UDim2.new(0, 8, 0, 35)
    SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SearchBox.BackgroundTransparency = bgTransparency
    SearchBox.PlaceholderText = "🔍 Search..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = THEME.TextMain
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 11
    SearchBox.Parent = Sidebar
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, 0, 1, -70)
    TabScroll.Position = UDim2.new(0, 0, 0, 65)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 0
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Parent = TabScroll
    TabList.Padding = UDim.new(0, 4)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- [CONTENT AREA]
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -130, 1, 0)
    Container.Position = UDim2.new(0, 130, 0, 0)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, -20, 0, 40)
    Header.Position = UDim2.new(0, 12, 0, 5)
    Header.BackgroundTransparency = 1
    Header.Text = hubName .. " <font color='#b0b0b0'>Main</font>"
    Header.RichText = true
    Header.TextColor3 = THEME.TextMain
    Header.TextSize = 22
    Header.Font = Enum.Font.GothamBold
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Container

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, -50)
    PageContainer.Position = UDim2.new(0, 0, 0, 45)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = Container

    local currentTab = nil

    function luayTLib:AddTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.9, 0, 0, 32)
        TabBtn.BackgroundColor3 = THEME.ElementBg
        TabBtn.BackgroundTransparency = 0.6
        TabBtn.Text = name
        TabBtn.TextColor3 = THEME.TextDark
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 13
        TabBtn.Parent = TabScroll
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 18)
        Indicator.Position = UDim2.new(1, -2, 0.5, -9)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Visible = false
        Indicator.Parent = TabBtn
        Instance.new("UICorner", Indicator)

        -- Scroll da Página
        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1, -10, 1, -5)
        PageScroll.Position = UDim2.new(0, 10, 0, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.ScrollBarThickness = 3
        PageScroll.Visible = false
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.Parent = PageContainer

        local PageList = Instance.new("UIListLayout")
        PageList.Parent = PageScroll
        PageList.Padding = UDim.new(0, 6)
        
        PageList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageList.AbsoluteContentSize.Y + 10)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Btn.BackgroundTransparency = 0.6
                currentTab.Btn.TextColor3 = THEME.TextDark
                currentTab.Btn.Indicator.Visible = false
                currentTab.Page.Visible = false
            end
            TabBtn.BackgroundTransparency = 0.2
            TabBtn.TextColor3 = THEME.TextMain
            Indicator.Visible = true
            PageScroll.Visible = true
            currentTab = {Btn = TabBtn, Page = PageScroll, Indicator = Indicator}
        end)

        -- Elementos da Aba
        local Elements = {}

        function Elements:AddButton(text, callback)
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(0.96, 0, 0, 38)
            B.BackgroundColor3 = THEME.ElementBg
            B.BackgroundTransparency = bgTransparency
            B.Text = "  " .. text
            B.TextColor3 = THEME.TextMain
            B.Font = Enum.Font.GothamSemibold
            B.TextSize = 14
            B.TextXAlignment = Enum.TextXAlignment.Left
            B.Parent = PageScroll
            Instance.new("UICorner", B).CornerRadius = UDim.new(0, 8)

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Position = UDim2.new(1, -28, 0.5, -9)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://6034503241"
            Icon.Parent = B

            B.MouseButton1Click:Connect(callback)
        end

        function Elements:AddToggle(text, default, callback)
            local T = Instance.new("Frame")
            T.Size = UDim2.new(0.96, 0, 0, 42)
            T.BackgroundColor3 = THEME.ElementBg
            T.BackgroundTransparency = bgTransparency
            T.Parent = PageScroll
            Instance.new("UICorner", T).CornerRadius = UDim.new(0, 8)

            local L = Instance.new("TextLabel")
            L.Size = UDim2.new(1, -60, 1, 0)
            L.Position = UDim2.new(0, 12, 0, 0)
            L.BackgroundTransparency = 1
            L.Text = text
            L.TextColor3 = THEME.TextMain
            L.Font = Enum.Font.GothamSemibold
            L.TextSize = 14
            L.TextXAlignment = Enum.TextXAlignment.Left
            L.Parent = T

            local Switch = Instance.new("TextButton")
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Position = UDim2.new(1, -50, 0.5, -10)
            Switch.BackgroundColor3 = default and THEME.AccentPurple or Color3.fromRGB(35, 35, 35)
            Switch.Text = ""
            Switch.Parent = T
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Switch
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local state = default
            Switch.MouseButton1Click:Connect(function()
                state = not state
                local targetX = state and 1 or 0
                local targetOff = state and -18 or 2
                local targetCol = state and THEME.AccentPurple or Color3.fromRGB(35, 35, 35)
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(targetX, targetOff, 0.5, -8)}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
                callback(state)
            end)
        end

        -- Ativa primeira aba se houver
        if not currentTab then
            TabBtn.BackgroundTransparency = 0.2
            TabBtn.TextColor3 = THEME.TextMain
            Indicator.Visible = true
            PageScroll.Visible = true
            currentTab = {Btn = TabBtn, Page = PageScroll, Indicator = Indicator}
        end

        return Elements
    end

    -- [DRAG & MINIMIZE]
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = true dragStart = i.Position startPos = Main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local open = true
    MinimizeHandle.MouseButton1Click:Connect(function()
        open = not open
        local target = open and UDim2.new(0.5, -240, 0.5, -140) or UDim2.new(-1, 0, 0.5, -140)
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = target}):Play()
    end)

    return luayTLib
end

return luayTLib
