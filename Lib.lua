--[[
    Biblioteca Baseada na Imagem "www.name.rbx"
    Recursos:
    - IDs Únicos para cada item.
    - Função SetItem para modificar itens via script.
    - Animação complexa e anti-spam no Toggle (efeito de esticar/encolher).
    - Função para minimizar/abrir com animação suave.
    - Sistema de Abas (Tabs) e Áreas.
]]

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Fallback caso não seja executado via exploit (para testar no Studio)
local targetGui = pcall(function() return CoreGui.RobloxGui end) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")

local Library = {
    Elements = {}, -- Armazena todos os elementos criados pelo seu ID
    Windows = {},
    Minimilized = false
}

-- Cores baseadas na imagem
local Colors = {
    MainBG = Color3.fromRGB(225, 225, 225),
    StrokeBG = Color3.fromRGB(180, 180, 180),
    DarkBG = Color3.fromRGB(170, 170, 170),
    White = Color3.fromRGB(255, 255, 255),
    TextLight = Color3.fromRGB(160, 160, 160),
    ToggleOn = Color3.fromRGB(160, 200, 160),
    ToggleOff = Color3.fromRGB(180, 180, 180)
}

-- Função utilitária para criar instâncias
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

-- Função utilitária para animações
local function Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

-----------------------------------------
-- FUNÇÕES GLOBAIS DA BIBLIOTECA
-----------------------------------------

-- Função para alterar um item existente pelo ID
function Library:SetItem(id, newValue)
    local element = self.Elements[id]
    if not element then return warn("Item com ID '" .. tostring(id) .. "' não encontrado!") end

    if element.Type == "Toggle" then
        element:Set(newValue)
    elseif element.Type == "Input" then
        element.Instance.Text = tostring(newValue)
    elseif element.Type == "Dropdown" then
        -- Lógica para setar dropdown pode ser adicionada aqui
    end
end

-- Função para minimizar/abrir a UI
function Library:Tlib(minimilize)
    if self.Minimilized == minimilize then return end
    self.Minimilized = minimilize

    for _, window in pairs(self.Windows) do
        if minimilize then
            -- Esconde as abas e o conteúdo, diminui o tamanho
            Tween(window.MainFrame, {Size = UDim2.new(0, 500, 0, 35)}, 0.4, Enum.EasingStyle.Quint)
            Tween(window.ContentContainer, {BackgroundTransparency = 1}, 0.2)
            Tween(window.TabContainer, {BackgroundTransparency = 1}, 0.2)
            window.ContentContainer.Visible = false
            window.TabContainer.Visible = false
        else
            -- Volta ao normal
            window.ContentContainer.Visible = true
            window.TabContainer.Visible = true
            Tween(window.MainFrame, {Size = UDim2.new(0, 500, 0, 300)}, 0.4, Enum.EasingStyle.Quint)
            Tween(window.ContentContainer, {BackgroundTransparency = 0}, 0.4)
            Tween(window.TabContainer, {BackgroundTransparency = 0}, 0.4)
        end
    end
end

-----------------------------------------
-- CRIAÇÃO DA JANELA PRINCIPAL
-----------------------------------------

function Library:CreateWindow(config)
    local name = config.Name or "name"
    local fullName = "www." .. name .. ".rbx"

    local ScreenGui = Create("ScreenGui", {
        Name = "RbxLibraryGui",
        Parent = targetGui,
        ResetOnSpawn = false
    })

    -- Frame Principal
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.StrokeBG,
        Position = UDim2.new(0.5, -250, 0.5, -150),
        Size = UDim2.new(0, 500, 0, 300),
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})
    
    -- Barra de Título (Header)
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Colors.StrokeBG,
        Size = UDim2.new(1, 0, 0, 35),
        BorderSizePixel = 0
    })

    -- Ícone do Globo
    Create("ImageLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://6031280882", -- Ícone de globo da internet
        ImageColor3 = Colors.White
    })

    -- Texto do Título
    Create("TextLabel", {
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = fullName,
        TextColor3 = Colors.White,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Container das Abas (Topo)
    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Colors.StrokeBG,
        Position = UDim2.new(0, 0, 0, 35),
        Size = UDim2.new(1, 0, 0, 35),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.X
    })
    Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})

    -- Fundo do Conteúdo Principal (Abaixo das abas)
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Colors.MainBG,
        Position = UDim2.new(0, 5, 0, 75),
        Size = UDim2.new(1, -10, 1, -80)
    })
    Create("UICorner", {Parent = ContentContainer, CornerRadius = UDim.new(0, 8)})

    -- Suporte para arrastar a UI
    local dragging, dragInput, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {
        MainFrame = MainFrame,
        ContentContainer = ContentContainer,
        TabContainer = TabContainer,
        Tabs = {},
        CurrentTab = nil
    }
    table.insert(Library.Windows, Window)

    -----------------------------------------
    -- SISTEMA DE ABAS (TABS)
    -----------------------------------------
    function Window:CreateTab(tabName)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Colors.MainBG,
            Size = UDim2.new(0, 100, 0, 25),
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = Colors.TextLight,
            TextSize = 14,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 12)})

        local TabPage = Create("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 0,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Create("UIPadding", {Parent = TabPage, PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 10)})

        -- Lógica de troca de aba
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Btn, {TextColor3 = Colors.TextLight}, 0.2)
            end
            TabPage.Visible = true
            Tween(TabBtn, {TextColor3 = Colors.StrokeBG}, 0.2)
        end)

        if not Window.CurrentTab then
            TabPage.Visible = true
            TabBtn.TextColor3 = Colors.StrokeBG
            Window.CurrentTab = TabPage
        end

        local TabElements = {Page = TabPage, Btn = TabBtn}
        table.insert(Window.Tabs, TabElements)

        -----------------------------------------
        -- CRIAÇÃO DE ELEMENTOS DENTRO DA ABA
        -----------------------------------------

        function TabElements:CreateToggle(tConfig)
            local id = tConfig.ID
            local text = tConfig.Name or "Toggle"
            local callback = tConfig.Callback or function() end
            local default = tConfig.Default or false

            local ToggleFrame = Create("TextButton", {
                Parent = TabPage,
                BackgroundColor3 = Colors.White,
                Size = UDim2.new(0, 200, 0, 30),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 8)})

            Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Colors.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBG = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = default and Colors.ToggleOn or Colors.ToggleOff,
                Position = UDim2.new(1, -45, 0.5, -10),
                Size = UDim2.new(0, 35, 0, 20)
            })
            Create("UICorner", {Parent = SwitchBG, CornerRadius = UDim.new(1, 0)})

            local Thumb = Create("Frame", {
                Parent = SwitchBG,
                BackgroundColor3 = Colors.White,
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Thumb, CornerRadius = UDim.new(1, 0)})

            local state = default
            local isAnimating = false -- Sistema Anti-Spam

            local function SetState(newState)
                if isAnimating then return end
                isAnimating = true
                state = newState

                -- Animação Complexa do Toggle (Estica, move, encolhe)
                local goalColor = state and Colors.ToggleOn or Colors.ToggleOff
                local goalPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

                Tween(SwitchBG, {BackgroundColor3 = goalColor}, 0.3)
                
                -- Efeito de esticar a bolinha
                Tween(Thumb, {Size = UDim2.new(0, 22, 0, 16)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out).Completed:Connect(function()
                    local moveTween = Tween(Thumb, {Position = goalPos}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    Tween(Thumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    
                    moveTween.Completed:Connect(function()
                        isAnimating = false
                        callback(state)
                    end)
                end)
            end

            ToggleFrame.MouseButton1Click:Connect(function() SetState(not state) end)

            -- Registra o elemento pelo ID
            if id then
                Library.Elements[id] = {Type = "Toggle", Instance = ToggleFrame, Set = SetState, State = function() return state end}
            end
        end

        function TabElements:CreateInput(iConfig)
            local id = iConfig.ID
            local text = iConfig.Name or "Input"
            local callback = iConfig.Callback or function() end

            local InputFrame = Create("Frame", {
                Parent = TabPage,
                BackgroundColor3 = Colors.White,
                Size = UDim2.new(0, 200, 0, 30)
            })
            Create("UICorner", {Parent = InputFrame, CornerRadius = UDim.new(0, 8)})

            Create("TextLabel", {
                Parent = InputFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.4, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Colors.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local TextBoxBG = Create("Frame", {
                Parent = InputFrame,
                BackgroundColor3 = Colors.StrokeBG,
                Position = UDim2.new(1, -60, 0.5, -10),
                Size = UDim2.new(0, 50, 0, 20)
            })
            Create("UICorner", {Parent = TextBoxBG, CornerRadius = UDim.new(0, 6)})

            local TextBox = Create("TextBox", {
                Parent = TextBoxBG,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "...",
                TextColor3 = Colors.White,
                TextSize = 12,
                ClearTextOnFocus = true
            })

            TextBox.FocusLost:Connect(function(enterPressed)
                callback(TextBox.Text)
            end)

            if id then
                Library.Elements[id] = {Type = "Input", Instance = TextBox}
            end
        end

        function TabElements:CreateDropdown(dConfig)
            local id = dConfig.ID
            local text = dConfig.Name or "Dropdown"
            local options = dConfig.Options or {}
            local callback = dConfig.Callback or function() end

            local dropOpen = false

            local DropFrame = Create("Frame", {
                Parent = TabPage,
                BackgroundColor3 = Colors.White,
                Size = UDim2.new(0, 200, 0, 30),
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 8)})

            local DropBtn = Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Text = ""
            })

            Create("TextLabel", {
                Parent = DropBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.8, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Colors.TextLight,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Create("TextLabel", {
                Parent = DropBtn,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -25, 0, 0),
                Size = UDim2.new(0, 20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = ">",
                TextColor3 = Colors.StrokeBG,
                TextSize = 18
            })

            local ItemContainer = Create("ScrollingFrame", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 30),
                Size = UDim2.new(1, 0, 1, -30),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Colors.StrokeBG,
                AutomaticCanvasSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", {
                Parent = ItemContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            Create("UIPadding", {Parent = ItemContainer, PaddingLeft = UDim.new(0, 5), PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)})

            local function CalculateSize()
                local count = #options
                if count > 3 then count = 3.5 end -- Mostra máx 3.5 itens antes de scrollar
                return 30 + (count * 25) + (count * 5)
            end

            DropBtn.MouseButton1Click:Connect(function()
                dropOpen = not dropOpen
                Tween(Arrow, {Rotation = dropOpen and 90 or 0}, 0.2)
                Tween(DropFrame, {Size = UDim2.new(0, 200, 0, dropOpen and CalculateSize() or 30)}, 0.3, Enum.EasingStyle.Quint)
            end)

            for _, opt in pairs(options) do
                local ItemBtn = Create("TextButton", {
                    Parent = ItemContainer,
                    BackgroundColor3 = Colors.MainBG,
                    Size = UDim2.new(1, -10, 0, 25),
                    Font = Enum.Font.GothamBold,
                    Text = "  " .. opt,
                    TextColor3 = Colors.TextLight,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                Create("UICorner", {Parent = ItemBtn, CornerRadius = UDim.new(0, 6)})

                ItemBtn.MouseButton1Click:Connect(function()
                    callback(opt)
                    dropOpen = false
                    Tween(Arrow, {Rotation = 0}, 0.2)
                    Tween(DropFrame, {Size = UDim2.new(0, 200, 0, 30)}, 0.3, Enum.EasingStyle.Quint)
                end)
            end

            if id then
                Library.Elements[id] = {Type = "Dropdown", Instance = DropFrame}
            end
        end

        return TabElements
    end

    return Window
end

return Library
