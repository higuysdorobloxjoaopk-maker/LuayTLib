--// Tlib - UI Library
--// by Você 😈

local Tlib = {}
Tlib.__index = Tlib

--// Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Config
local PRIMARY = Color3.fromRGB(138, 74, 255)
local DARK = Color3.fromRGB(35, 35, 35)
local DARK2 = Color3.fromRGB(45, 45, 45)

--// Criar Janela
function Tlib:CreateWindow(title)

    local self = setmetatable({}, Tlib)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "Tlib"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(600, 400)
    main.Position = UDim2.new(0.5, -300, 0.5, -200)
    main.BackgroundColor3 = DARK
    main.BorderSizePixel = 0
    main.Parent = gui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    -- TopBar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 50)
    top.BackgroundColor3 = DARK2
    top.BorderSizePixel = 0
    top.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "Tlib"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 22
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = top

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(40, 35)
    minBtn.Position = UDim2.new(1, -90, 0.5, -17)
    minBtn.Text = "-"
    minBtn.TextSize = 22
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.BackgroundColor3 = PRIMARY
    minBtn.Parent = top
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

    -- Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(40, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    closeBtn.Text = "X"
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.BackgroundColor3 = PRIMARY
    closeBtn.Parent = top
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 150, 1, -50)
    sidebar.Position = UDim2.new(0, 0, 0, 50)
    sidebar.BackgroundColor3 = DARK2
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -150, 1, -50)
    content.Position = UDim2.new(0, 150, 0, 50)
    content.BackgroundTransparency = 1
    content.Parent = main

    -- Layout
    local tabLayout = Instance.new("UIListLayout", sidebar)
    tabLayout.Padding = UDim.new(0, 5)

    -- Minimizado
    local minimized = false

    local miniBar = Instance.new("TextButton")
    miniBar.Size = UDim2.fromOffset(160, 35)
    miniBar.Position = UDim2.new(0, 10, 0, 10)
    miniBar.BackgroundColor3 = PRIMARY
    miniBar.Text = title or "Tlib"
    miniBar.TextColor3 = Color3.new(1,1,1)
    miniBar.Visible = false
    miniBar.Parent = gui
    Instance.new("UICorner", miniBar).CornerRadius = UDim.new(0, 8)

    local function toggleMinimize()
        minimized = not minimized
        main.Visible = not minimized
        miniBar.Visible = minimized
    end

    minBtn.MouseButton1Click:Connect(toggleMinimize)
    miniBar.MouseButton1Click:Connect(toggleMinimize)

    -- Atalho Z
    UserInputService.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Z then
            toggleMinimize()
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    self.Main = main
    self.Sidebar = sidebar
    self.Content = content
    self.Tabs = {}

    return self
end

--// Criar Tab
function Tlib:AddTab(name)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, -10, 0, 35)
    tabBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    tabBtn.Text = name
    tabBtn.TextColor3 = Color3.new(1,1,1)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 14
    tabBtn.Parent = self.Sidebar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 4
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Content

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 8)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Content:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        page.Visible = true
    end)

    if #self.Content:GetChildren() == 1 then
        page.Visible = true
    end

    local elements = {}

    -- Button
    function elements:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
        btn.Text = text
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
    end

    -- Toggle
    function elements:AddToggle(text, callback)
        local state = false

        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(55,55,55)
        frame.Text = text
        frame.TextColor3 = Color3.new(1,1,1)
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        frame.MouseButton1Click:Connect(function()
            state = not state
            frame.BackgroundColor3 = state and PRIMARY or Color3.fromRGB(55,55,55)
            if callback then callback(state) end
        end)
    end

    return elements
end

return Tlib
