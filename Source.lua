--// meu projeto 🫠

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local Library = {
    Elements = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(20, 35, 70),
        TopBar = Color3.fromRGB(30, 50, 100),
        ElementBg = Color3.fromRGB(25, 40, 85),
        Accent = Color3.fromRGB(60, 80, 140),
        AccentActive = Color3.fromRGB(60, 200, 100),
        Text = Color3.fromRGB(200, 220, 255),
        Divider = Color3.fromRGB(15, 25, 50)
    }
}

--// Helper para criar Instâncias rapidamente
local function create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do
        inst[k] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

--// Sistema de Notificação
local notifGui = create("ScreenGui", {Name = "BlueNotifGui", ResetOnSpawn = false})
if RunService:IsStudio() then notifGui.Parent = player:WaitForChild("PlayerGui") else notifGui.Parent = CoreGui end

local notifLayout = create("Frame", {
    Size = UDim2.new(0, 250, 1, -40),
    Position = UDim2.new(1, -270, 0, 20),
    BackgroundTransparency = 1,
    Parent = notifGui
})
local nList = create("UIListLayout", {Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = notifLayout})

function Library:Notify(title, text, duration)
    duration = duration or 3
    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Library.Theme.TopBar,
        BackgroundTransparency = 1,
        ClipsDescendants = true
    }, {
        create("UICorner", {CornerRadius = UDim.new(0, 6)}),
        create("UIStroke", {Color = Library.Theme.Accent, Thickness = 1, Transparency = 1}),
        create("TextLabel", {
            Text = title, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Library.Theme.Text,
            Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        }),
        create("TextLabel", {
            Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Library.Theme.Text,
            Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 25),
            BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1
        })
    })
    notif.Parent = notifLayout
    
    -- Animação de entrada
    TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    for _, child in pairs(notif:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 0, Transparency = 0}):Play()
        end
    end
    
    task.delay(duration, function()
        local tw = TweenService:Create(notif, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 60), BackgroundTransparency = 1})
        for _, child in pairs(notif:GetChildren()) do
            if child:IsA("TextLabel") or child:IsA("UIStroke") then TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1, Transparency = 1}):Play() end
        end
        tw:Play()
        tw.Completed:Wait()
        notif:Destroy()
    end)
end

--// Janela Principal
function Library:CreateWindow(config)
    local winName = config.Name or "www.name.rbx"
    
    local screenGui = create("ScreenGui", {Name = "CustomBlueLibrary", ResetOnSpawn = false})
    if RunService:IsStudio() then screenGui.Parent = player:WaitForChild("PlayerGui") else screenGui.Parent = CoreGui end
    
    local mainFrame = create("Frame", {
        Size = UDim2.new(0, 450, 0, 300), -- Um pouco maior para caber mais coisas
        Position = UDim2.new(0.5, -225, 0.5, -150),
        BackgroundColor3 = Library.Theme.Background,
        ClipsDescendants = true, Parent = screenGui, Active = true
    }, {
        create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        create("UIStroke", {Color = Library.Theme.Accent, Thickness = 1, Transparency = 0.5}),
        create("UIScale", {Name = "Scale", Scale = 0}) -- Começa em 0 para animar
    })
    
    TweenService:Create(mainFrame:FindFirstChild("Scale"), TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()

    local titleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Library.Theme.TopBar, Parent = mainFrame
    }, { create("UICorner", {CornerRadius = UDim.new(0, 8)}) })
    
    create("Frame", {Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Library.Theme.TopBar, BorderSizePixel = 0, Parent = titleBar}) -- Fix corner
    
    local titleLabel = create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1,
        Text = winName .. " /", TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar
    })

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local closeBtn = create("TextButton", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -30, 0.5, -12), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "X", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar}, {create("UICorner", {CornerRadius = UDim.new(0,4)})})
    closeBtn.MouseButton1Click:Connect(function()
        local tw = TweenService:Create(mainFrame:FindFirstChild("Scale"), TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
        tw:Play() tw.Completed:Wait() screenGui:Destroy()
    end)

    local isMinimized = false
    local minBtn = create("TextButton", { Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundColor3 = Library.Theme.Accent, Text = "-", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar}, {create("UICorner", {CornerRadius = UDim.new(0,4)})})
    
    local contentContainer = create("Frame", { Size = UDim2.new(1, 0, 1, -30), Position = UDim2.new(0, 0, 0, 30), BackgroundTransparency = 1, Parent = mainFrame })
    create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -100, 0, 0), BackgroundColor3 = Library.Theme.Divider, BorderSizePixel = 0, Parent = contentContainer })
    
    local sideBar = create("ScrollingFrame", { Size = UDim2.new(0, 98, 1, 0), Position = UDim2.new(1, -98, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, Active = true, ScrollingDirection = Enum.ScrollingDirection.Y, Parent = contentContainer })
    local sideList = create("UIListLayout", {Padding = UDim.new(0, 4), Parent = sideBar})
    sideList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sideBar.CanvasSize = UDim2.new(0, 0, 0, sideList.AbsoluteContentSize.Y + 8) end)

    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        contentContainer.Visible = not isMinimized
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = isMinimized and UDim2.new(0, 450, 0, 30) or UDim2.new(0, 450, 0, 300)}):Play()
    end)

    local Window = { Tabs = {}, CurrentTab = nil }

    function Window:CreateTab(tabName)
        local tabBtn = create("TextButton", { Size = UDim2.new(1, -4, 0, 30), BackgroundColor3 = Library.Theme.ElementBg, Text = tabName, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, Parent = sideBar}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
        
        local tabContent = create("ScrollingFrame", { Size = UDim2.new(1, -110, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, Active = true, ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = contentContainer })
        local tabList = create("UIListLayout", {Padding = UDim.new(0, 6), Parent = tabContent})
        tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabContent.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 15) end)
        create("Frame", {Size = UDim2.new(1, 0, 0, 15), BackgroundTransparency = 1, LayoutOrder = 999, Parent = tabContent}) -- Spacer

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do t.Content.Visible = false t.Btn.BackgroundColor3 = Library.Theme.ElementBg end
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = Library.Theme.Accent
            titleLabel.Text = winName .. " / " .. tabName:lower()
            Window.CurrentTab = tabName
        end)

        if not Window.CurrentTab then
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = Library.Theme.Accent
            titleLabel.Text = winName .. " / " .. tabName:lower()
            Window.CurrentTab = tabName
        end

        local Tab = { Content = tabContent, Btn = tabBtn }
        Window.Tabs[tabName] = Tab

        --// MÉTODOS DOS ELEMENTOS DA ABA
        function Tab:CreateToggle(id, name, default, callback)
            Library.Flags[id] = default
            local tFrame = create("Frame", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Library.Theme.ElementBg, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            create("TextLabel", {Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = tFrame})
            
            local switchBg = create("TextButton", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -48, 0.5, -10), BackgroundColor3 = default and Library.Theme.AccentActive or Library.Theme.Accent, Text = "", AutoButtonColor = false, Parent = tFrame}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})
            local circle = create("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = default and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1), Parent = switchBg}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})

            local function SetState(state)
                Library.Flags[id] = state
                TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Theme.AccentActive or Library.Theme.Accent}):Play()
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                pcall(callback, state)
            end

            switchBg.MouseButton1Click:Connect(function() SetState(not Library.Flags[id]) end)
            
            Library.Elements[id] = { Set = SetState, Get = function() return Library.Flags[id] end }
        end

        function Tab:CreateButton(id, name, callback)
            local btn = create("TextButton", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Library.Theme.ElementBg, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            btn.MouseButton1Click:Connect(function() 
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.ElementBg}):Play()
                pcall(callback) 
            end)
            Library.Elements[id] = { Fire = function() pcall(callback) end }
        end

        function Tab:CreateSlider(id, name, min, max, default, callback)
            Library.Flags[id] = default
            local sFrame = create("Frame", {Size = UDim2.new(1, -6, 0, 45), BackgroundColor3 = Library.Theme.ElementBg, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            create("TextLabel", {Size = UDim2.new(0.7, 0, 0, 20), Position = UDim2.new(0, 8, 0, 2), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = sFrame})
            local valLabel = create("TextLabel", {Size = UDim2.new(0.3, 0, 0, 20), Position = UDim2.new(0.7, -8, 0, 2), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Parent = sFrame})
            
            local slideBg = create("Frame", {Size = UDim2.new(1, -16, 0, 6), Position = UDim2.new(0, 8, 0, 28), BackgroundColor3 = Library.Theme.Background, Parent = sFrame}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})
            local fill = create("Frame", {Size = UDim2.new((default - min)/(max - min), 0, 1, 0), BackgroundColor3 = Library.Theme.AccentActive, Parent = slideBg}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})
            local btn = create("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = slideBg})

            local function SetValue(val)
                val = math.clamp(math.floor(val), min, max)
                Library.Flags[id] = val
                valLabel.Text = tostring(val)
                TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new((val - min)/(max - min), 0, 1, 0)}):Play()
                pcall(callback, val)
            end

            local sliding = false
            btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pct = math.clamp((input.Position.X - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
                    SetValue(min + ((max - min) * pct))
                end
            end)

            Library.Elements[id] = { Set = SetValue, Get = function() return Library.Flags[id] end }
        end

        function Tab:CreateDropdown(id, name, options, multi, callback)
            Library.Flags[id] = multi and {} or ""
            local isOpen = false
            local dFrame = create("Frame", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Library.Theme.ElementBg, ClipsDescendants = true, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            local topBtn = create("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", Parent = dFrame})
            create("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBtn})
            local icon = create("TextLabel", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -25, 0, 0), BackgroundTransparency = 1, Text = "+", TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, Parent = topBtn})
            
            local dropContainer = create("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1, Parent = dFrame})
            local dropList = create("UIListLayout", {Padding = UDim.new(0, 2), Parent = dropContainer})

            local function buildOptions(opts)
                for _, child in pairs(dropContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                local sizeY = 34
                for _, opt in ipairs(opts) do
                    sizeY = sizeY + 26
                    local optBtn = create("TextButton", {Size = UDim2.new(1, -16, 0, 24), Position = UDim2.new(0, 8, 0, 0), BackgroundColor3 = Library.Theme.Background, Text = opt, TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, Parent = dropContainer}, {create("UICorner", {CornerRadius = UDim.new(0,4)})})
                    
                    local function updateVisuals()
                        if multi then
                            optBtn.BackgroundColor3 = table.find(Library.Flags[id], opt) and Library.Theme.AccentActive or Library.Theme.Background
                        else
                            optBtn.BackgroundColor3 = (Library.Flags[id] == opt) and Library.Theme.AccentActive or Library.Theme.Background
                        end
                    end
                    updateVisuals()

                    optBtn.MouseButton1Click:Connect(function()
                        if multi then
                            local idx = table.find(Library.Flags[id], opt)
                            if idx then table.remove(Library.Flags[id], idx) else table.insert(Library.Flags[id], opt) end
                        else
                            Library.Flags[id] = opt
                            isOpen = false
                            TweenService:Create(dFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -6, 0, 34)}):Play()
                            icon.Text = "+"
                        end
                        for _, c in pairs(dropContainer:GetChildren()) do if c:IsA("TextButton") then 
                            c.BackgroundColor3 = Library.Theme.Background
                            if multi and table.find(Library.Flags[id], c.Text) then c.BackgroundColor3 = Library.Theme.AccentActive
                            elseif not multi and Library.Flags[id] == c.Text then c.BackgroundColor3 = Library.Theme.AccentActive end
                        end end
                        pcall(callback, Library.Flags[id])
                    end)
                end
                if isOpen then dFrame.Size = UDim2.new(1, -6, 0, sizeY) end
                return sizeY
            end

            local maxH = buildOptions(options)

            topBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                icon.Text = isOpen and "-" or "+"
                TweenService:Create(dFrame, TweenInfo.new(0.2), {Size = isOpen and UDim2.new(1, -6, 0, maxH) or UDim2.new(1, -6, 0, 34)}):Play()
            end)

            Library.Elements[id] = {
                Refresh = function(newOpts) maxH = buildOptions(newOpts) end,
                Get = function() return Library.Flags[id] end
            }
        end

        function Tab:CreateInput(id, name, placeholder, isCodeBox, callback)
            local height = isCodeBox and 100 or 40
            local iFrame = create("Frame", {Size = UDim2.new(1, -6, 0, height), BackgroundColor3 = Library.Theme.ElementBg, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            if not isCodeBox then create("TextLabel", {Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = iFrame}) end
            
            local box = create("TextBox", {
                Size = isCodeBox and UDim2.new(1, -16, 1, -16) or UDim2.new(0.55, -8, 0, 26),
                Position = isCodeBox and UDim2.new(0, 8, 0, 8) or UDim2.new(0.45, 0, 0.5, -13),
                BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Text, PlaceholderText = placeholder,
                Font = isCodeBox and Enum.Font.Code or Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
                TextXAlignment = isCodeBox and Enum.TextXAlignment.Left or Enum.TextXAlignment.Center,
                TextYAlignment = isCodeBox and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                MultiLine = isCodeBox, Parent = iFrame
            }, {create("UICorner", {CornerRadius = UDim.new(0,4)})})

            box.FocusLost:Connect(function()
                Library.Flags[id] = box.Text
                pcall(callback, box.Text)
            end)

            Library.Elements[id] = { Set = function(txt) box.Text = txt; Library.Flags[id] = txt end, Get = function() return box.Text end }
        end

        function Tab:CreateColorPicker(id, name, defaultColor, callback)
            Library.Flags[id] = defaultColor
            local isOpen = false
            local cpFrame = create("Frame", {Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Library.Theme.ElementBg, ClipsDescendants = true, Parent = tabContent}, {create("UICorner", {CornerRadius = UDim.new(0,6)})})
            local topBtn = create("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, Text = "", Parent = cpFrame})
            create("TextLabel", {Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBtn})
            
            local colorPreview = create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -30, 0.5, -10), BackgroundColor3 = defaultColor, Parent = topBtn}, {create("UICorner", {CornerRadius = UDim.new(0,4)})})
            local rgbLabel = create("TextLabel", {Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(1, -115, 0, 0), BackgroundTransparency = 1, Text = math.floor(defaultColor.R*255)..", "..math.floor(defaultColor.G*255)..", "..math.floor(defaultColor.B*255), TextColor3 = Library.Theme.Text, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right, Parent = topBtn})

            -- Hue Wheel & Darkness Slider
            local cpContainer = create("Frame", {Size = UDim2.new(1, 0, 0, 130), Position = UDim2.new(0, 0, 0, 34), BackgroundTransparency = 1, Parent = cpFrame})
            local wheel = create("ImageButton", {Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0, 15, 0, 10), Image = "rbxassetid://283725628", BackgroundTransparency = 1, Parent = cpContainer})
            local cursor = create("Frame", {Size = UDim2.new(0, 4, 0, 4), BackgroundColor3 = Color3.new(0,0,0), Position = UDim2.new(0.5, -2, 0.5, -2), Parent = wheel}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})
            
            local valSliderBg = create("Frame", {Size = UDim2.new(0, 20, 0, 100), Position = UDim2.new(0, 135, 0, 10), BackgroundColor3 = Color3.new(1,1,1), Parent = cpContainer}, {create("UICorner", {CornerRadius = UDim.new(0,4)}), create("UIGradient", {Rotation = 90, Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0))})})
            local valBtn = create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = valSliderBg})
            local valCursor = create("Frame", {Size = UDim2.new(1, 2, 0, 4), Position = UDim2.new(0, -1, 0, -2), BackgroundColor3 = Color3.new(0,0,0), Parent = valSliderBg}, {create("UICorner", {CornerRadius = UDim.new(1,0)})})

            local h, s, v = defaultColor:ToHSV()

            local function UpdateColor()
                local finalColor = Color3.fromHSV(h, s, v)
                Library.Flags[id] = finalColor
                colorPreview.BackgroundColor3 = finalColor
                rgbLabel.Text = math.floor(finalColor.R*255)..", "..math.floor(finalColor.G*255)..", "..math.floor(finalColor.B*255)
                valSliderBg.UIGradient.Color = ColorSequence.new(Color3.fromHSV(h, s, 1), Color3.new(0,0,0))
                pcall(callback, finalColor)
            end

            local function UpdateWheel(input)
                local r = wheel.AbsoluteSize.X / 2
                local cx, cy = wheel.AbsolutePosition.X + r, wheel.AbsolutePosition.Y + r
                local x, y = input.Position.X - cx, input.Position.Y - cy
                local dist = math.clamp(math.sqrt(x^2 + y^2), 0, r)
                local phi = math.atan2(y, x)
                cursor.Position = UDim2.new(0.5, x/r * (dist) - 2, 0.5, y/r * (dist) - 2)
                h = (math.pi + phi) / (2 * math.pi)
                s = dist / r
                UpdateColor()
            end

            local wSliding, vSliding = false, false
            wheel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then wSliding = true; UpdateWheel(input) end end)
            valBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then vSliding = true end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then wSliding = false; vSliding = false end end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if wSliding then UpdateWheel(input) end
                    if vSliding then
                        local pct = math.clamp((input.Position.Y - valSliderBg.AbsolutePosition.Y) / valSliderBg.AbsoluteSize.Y, 0, 1)
                        valCursor.Position = UDim2.new(0, -1, pct, -2)
                        v = 1 - pct
                        UpdateColor()
                    end
                end
            end)

            topBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                TweenService:Create(cpFrame, TweenInfo.new(0.2), {Size = isOpen and UDim2.new(1, -6, 0, 164) or UDim2.new(1, -6, 0, 34)}):Play()
            end)

            Library.Elements[id] = { 
                Set = function(col) h,s,v = col:ToHSV(); UpdateColor() end, 
                Get = function() return Library.Flags[id] end 
            }
        end

        return Tab
    end

    return Window
end

return Library
