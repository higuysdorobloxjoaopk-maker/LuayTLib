--[[
    ╔═════════════════════════════════════════════════════════════╗
    ║         GLASSWATER UI - LUAU ROBLOX LIBRARY v2.0            ║
    ║    iOS Style UI with Smooth Animations & Glass Morphism    ║
    ║                  Mobile & PC Compatible                     ║
    ║           Complete with Hitbox & All Features              ║
    ╚═════════════════════════════════════════════════════════════╝
]]

local GlassWaterUI = {}
GlassWaterUI.__index = GlassWaterUI

-- ============================================================================
-- CONSTANTS & CONFIGURATION
-- ============================================================================

local ANIMATION_SPEED = 0.3
local TRANSITION_SPEED = 0.25
local GLASS_TRANSPARENCY = 0.15
local BLUR_SIZE = 15
local CORNER_RADIUS = 20
local PADDING = 15
local SPACING = 12

-- Color Palette
local COLORS = {
    -- Light Theme
    light = {
        background = Color3.fromRGB(245, 245, 247),
        surface = Color3.fromRGB(255, 255, 255),
        glass = Color3.fromRGB(255, 255, 255),
        text = Color3.fromRGB(0, 0, 0),
        textSecondary = Color3.fromRGB(100, 100, 102),
        accent = Color3.fromRGB(0, 122, 255),
        accentLight = Color3.fromRGB(100, 180, 255),
        shadow = Color3.fromRGB(0, 0, 0),
        border = Color3.fromRGB(200, 200, 205),
        success = Color3.fromRGB(52, 168, 83),
        error = Color3.fromRGB(255, 59, 48),
        warning = Color3.fromRGB(255, 159, 64),
    },
    -- Dark Theme
    dark = {
        background = Color3.fromRGB(0, 0, 0),
        surface = Color3.fromRGB(28, 28, 30),
        glass = Color3.fromRGB(45, 45, 50),
        text = Color3.fromRGB(245, 245, 247),
        textSecondary = Color3.fromRGB(155, 155, 157),
        accent = Color3.fromRGB(100, 180, 255),
        accentLight = Color3.fromRGB(150, 200, 255),
        shadow = Color3.fromRGB(0, 0, 0),
        border = Color3.fromRGB(70, 70, 75),
        success = Color3.fromRGB(52, 168, 83),
        error = Color3.fromRGB(255, 59, 48),
        warning = Color3.fromRGB(255, 159, 64),
    }
}

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

local function createTween(object, info, goal)
    local tweenService = game:GetService("TweenService")
    local tween = tweenService:Create(object, info, goal)
    return tween
end

local function clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function newCoroutine(func)
    return coroutine.create(func)
end

local function resumeCoroutine(coro, ...)
    return coroutine.resume(coro, ...)
end

local function ease(easing, value)
    -- Smooth easing functions
    if easing == "inOut" then
        if value < 0.5 then
            return 2 * value * value
        else
            return -1 + (4 - 2 * value) * value
        end
    elseif easing == "out" then
        return 1 - (1 - value) ^ 2
    elseif easing == "in" then
        return value ^ 2
    end
    return value
end

-- ============================================================================
-- CORE UI CLASS
-- ============================================================================

function GlassWaterUI.new(config)
    local self = setmetatable({}, GlassWaterUI)
    
    self.isDarkMode = config and config.darkMode or false
    self.theme = self.isDarkMode and COLORS.dark or COLORS.light
    self.parent = config and config.parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenSize = self.parent.AbsoluteSize
    self.isMobile = config and config.isMobile or (self:detectMobile())
    self.showDebug = config and config.showDebug or false
    
    self.containers = {}
    self.buttons = {}
    self.inputs = {}
    self.animations = {}
    self.hitboxes = {}
    
    self._maid = {}
    
    return self
end

function GlassWaterUI:detectMobile()
    local userInputService = game:GetService("UserInputService")
    return userInputService.TouchEnabled and not userInputService.MouseEnabled
end

function GlassWaterUI:setTheme(darkMode)
    self.isDarkMode = darkMode
    self.theme = darkMode and COLORS.dark or COLORS.light
    for _, container in ipairs(self.containers) do
        self:updateTheme(container)
    end
end

function GlassWaterUI:updateTheme(object)
    if object:IsA("Frame") or object:IsA("TextLabel") or object:IsA("TextButton") then
        if object:GetAttribute("isGlass") then
            object.BackgroundColor3 = self.theme.glass
        elseif object:GetAttribute("isSurface") then
            object.BackgroundColor3 = self.theme.surface
        elseif object:GetAttribute("isBackground") then
            object.BackgroundColor3 = self.theme.background
        end
        
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            object.TextColor3 = self.theme.text
        end
    end
    
    for _, child in ipairs(object:GetChildren()) do
        self:updateTheme(child)
    end
end

-- ============================================================================
-- CONTAINER / WINDOW CLASS
-- ============================================================================

function GlassWaterUI:createContainer(name, config)
    config = config or {}
    
    local container = Instance.new("ScreenGui")
    container.Name = name
    container.Parent = self.parent
    container.ResetOnSpawn = false
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainContainer"
    mainFrame.Parent = container
    mainFrame.BackgroundColor3 = self.theme.background
    mainFrame.BackgroundTransparency = 1
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame:SetAttribute("isBackground", true)
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
    corner.Parent = mainFrame
    
    local containerFrame = Instance.new("Frame")
    containerFrame.Name = "ContentContainer"
    containerFrame.Parent = mainFrame
    containerFrame.BackgroundColor3 = self.theme.surface
    containerFrame.BackgroundTransparency = GLASS_TRANSPARENCY
    
    -- Size
    local size = config.size or UDim2.new(0, 350, 0, 500)
    containerFrame.Size = size
    containerFrame:SetAttribute("isSurface", true)
    
    -- Position
    local position = config.position or UDim2.new(0.5, -175, 0.5, -250)
    containerFrame.Position = position
    
    -- Corner
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, CORNER_RADIUS)
    containerCorner.Parent = containerFrame
    
    -- Stroke / Border
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.border
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = containerFrame
    
    -- Blur effect (optional)
    if config.useBlur then
        local blur = Instance.new("BlurEffect")
        blur.Size = BLUR_SIZE
        blur.Parent = game.Lighting
        table.insert(self._maid, blur)
    end
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, PADDING)
    padding.PaddingBottom = UDim.new(0, PADDING)
    padding.PaddingLeft = UDim.new(0, PADDING)
    padding.PaddingRight = UDim.new(0, PADDING)
    padding.Parent = containerFrame
    
    -- List Layout
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, SPACING)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = containerFrame
    
    -- Make draggable
    self:makeDraggable(containerFrame, mainFrame)
    
    local containerObject = {
        screenGui = container,
        mainFrame = mainFrame,
        contentFrame = containerFrame,
        listLayout = listLayout,
        stroke = stroke,
        isVisible = true,
        children = {},
        config = config
    }
    
    table.insert(self.containers, containerObject)
    
    return containerObject
end

function GlassWaterUI:makeDraggable(frame, parentGui)
    local isDragging = false
    local dragStart = nil
    local startPosition = nil
    
    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end
    
    local function onInputChanged(input, gameProcessed)
        if not isDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = startPosition + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end
    
    local function onInputEnded(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end
    
    local userInputService = game:GetService("UserInputService")
    userInputService.InputBegan:Connect(onInputBegan)
    userInputService.InputChanged:Connect(onInputChanged)
    userInputService.InputEnded:Connect(onInputEnded)
end

-- ============================================================================
-- BUTTON COMPONENT
-- ============================================================================

function GlassWaterUI:createButton(parent, config)
    config = config or {}
    
    local button = Instance.new("TextButton")
    button.Name = config.name or "Button"
    button.Parent = parent.contentFrame
    button.BackgroundColor3 = config.color or self.theme.accent
    button.BackgroundTransparency = config.transparent and 0.3 or 0.1
    button.TextColor3 = self.theme.text
    button.TextSize = config.textSize or 16
    button.Font = Enum.Font.GothamBold
    button.Text = config.text or "Button"
    button.LayoutOrder = config.layoutOrder or 999
    
    button.Size = UDim2.new(1, -10, 0, config.height or 50)
    button:SetAttribute("isGlass", true)
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.border
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = button
    
    -- Hover effect
    local originalColor = button.BackgroundColor3
    local hoverColor = Color3.fromRGB(
        clamp(originalColor.R * 1.2, 0, 1),
        clamp(originalColor.G * 1.2, 0, 1),
        clamp(originalColor.B * 1.2, 0, 1)
    )
    
    local isHovering = false
    
    button.MouseEnter:Connect(function()
        isHovering = true
        local tweenInfo = TweenInfo.new(
            ANIMATION_SPEED,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(button, tweenInfo, {BackgroundColor3 = hoverColor})
        tween:Play()
        if config.onHover then config.onHover() end
    end)
    
    button.MouseLeave:Connect(function()
        isHovering = false
        local tweenInfo = TweenInfo.new(
            ANIMATION_SPEED,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(button, tweenInfo, {BackgroundColor3 = originalColor})
        tween:Play()
        if config.onLeave then config.onLeave() end
    end)
    
    -- Click animation
    button.MouseButton1Down:Connect(function()
        local tweenInfo = TweenInfo.new(
            0.1,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(button, tweenInfo, {Size = UDim2.new(1, -10, 0, config.height or 50) * 0.98})
        tween:Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local tweenInfo = TweenInfo.new(
            0.15,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(button, tweenInfo, {Size = UDim2.new(1, -10, 0, config.height or 50)})
        tween:Play()
        if config.callback then config.callback() end
    end)
    
    -- Hitbox
    local hitboxData = {
        object = button,
        type = "button",
        enabled = true,
        bounds = {
            x = button.AbsolutePosition.X,
            y = button.AbsolutePosition.Y,
            width = button.AbsoluteSize.X,
            height = button.AbsoluteSize.Y
        }
    }
    table.insert(self.hitboxes, hitboxData)
    table.insert(self.buttons, button)
    
    return button
end

-- ============================================================================
-- INPUT TEXT BOX COMPONENT
-- ============================================================================

function GlassWaterUI:createTextInput(parent, config)
    config = config or {}
    
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = config.name or "TextInput"
    inputContainer.Parent = parent.contentFrame
    inputContainer.BackgroundColor3 = self.theme.surface
    inputContainer.BackgroundTransparency = 1
    inputContainer.Size = UDim2.new(1, -10, 0, 50)
    inputContainer.LayoutOrder = config.layoutOrder or 999
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = inputContainer
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextColor3 = self.theme.textSecondary
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.Text = config.placeholder or "Input"
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.Parent = inputContainer
    inputBox.BackgroundColor3 = self.theme.glass
    inputBox.BackgroundTransparency = 0.2
    inputBox.TextColor3 = self.theme.text
    inputBox.PlaceholderColor3 = self.theme.textSecondary
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.Gotham
    inputBox.Size = UDim2.new(1, 0, 0, 30)
    inputBox.Position = UDim2.new(0, 0, 0, 20)
    inputBox.PlaceholderText = config.placeholder or ""
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.ClearTextOnFocus = false
    inputBox:SetAttribute("isGlass", true)
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = inputBox
    
    -- Padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = inputBox
    
    -- Border
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.border
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = inputBox
    
    -- Focus animation
    inputBox.Focused:Connect(function()
        local tweenInfo = TweenInfo.new(
            ANIMATION_SPEED,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(stroke, tweenInfo, {Color = self.theme.accent, Transparency = 0})
        tween:Play()
        local tween2 = createTween(inputBox, tweenInfo, {BackgroundTransparency = 0})
        tween2:Play()
    end)
    
    inputBox.FocusLost:Connect(function()
        local tweenInfo = TweenInfo.new(
            ANIMATION_SPEED,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )
        local tween = createTween(stroke, tweenInfo, {Color = self.theme.border, Transparency = 0.5})
        tween:Play()
        local tween2 = createTween(inputBox, tweenInfo, {BackgroundTransparency = 0.2})
        tween2:Play()
    end)
    
    -- Hitbox
    local hitboxData = {
        object = inputBox,
        type = "input",
        enabled = true,
        bounds = {
            x = inputBox.AbsolutePosition.X,
            y = inputBox.AbsolutePosition.Y,
            width = inputBox.AbsoluteSize.X,
            height = inputBox.AbsoluteSize.Y
        }
    }
    table.insert(self.hitboxes, hitboxData)
    table.insert(self.inputs, inputBox)
    
    return inputBox
end

-- ============================================================================
-- SLIDER / PROGRESS COMPONENT
-- ============================================================================

function GlassWaterUI:createSlider(parent, config)
    config = config or {}
    
    local sliderContainer = Instance.new("Frame")
    sliderContainer.Name = config.name or "Slider"
    sliderContainer.Parent = parent.contentFrame
    sliderContainer.BackgroundColor3 = self.theme.surface
    sliderContainer.BackgroundTransparency = 1
    sliderContainer.Size = UDim2.new(1, -10, 0, 80)
    sliderContainer.LayoutOrder = config.layoutOrder or 999
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = sliderContainer
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextColor3 = self.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = config.label or "Value"
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Parent = sliderContainer
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.TextColor3 = self.theme.accent
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(config.default or 50)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Background track
    local trackBg = Instance.new("Frame")
    trackBg.Name = "TrackBackground"
    trackBg.Parent = sliderContainer
    trackBg.BackgroundColor3 = self.theme.glass
    trackBg.BackgroundTransparency = 0.3
    trackBg.Size = UDim2.new(1, 0, 0, 4)
    trackBg.Position = UDim2.new(0, 0, 0, 40)
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = trackBg
    
    -- Progress fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = trackBg
    fill.BackgroundColor3 = self.theme.accent
    fill.BackgroundTransparency = 0
    fill.Size = UDim2.new((config.default or 50) / (config.max or 100), 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill
    
    -- Slider thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Parent = trackBg
    thumb.BackgroundColor3 = self.theme.accent
    thumb.BackgroundTransparency = 0
    thumb.Size = UDim2.new(0, 20, 0, 20)
    thumb.Position = UDim2.new((config.default or 50) / (config.max or 100), -10, 0.5, -10)
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 10)
    thumbCorner.Parent = thumb
    
    -- Thumb shadow
    local thumbShadow = Instance.new("UIStroke")
    thumbShadow.Color = self.theme.shadow
    thumbShadow.Thickness = 0
    thumbShadow.Parent = thumb
    
    local currentValue = config.default or 50
    local minValue = config.min or 0
    local maxValue = config.max or 100
    
    local function updateSlider(position)
        local relativePos = clamp(position - trackBg.AbsolutePosition.X, 0, trackBg.AbsoluteSize.X)
        local percentage = relativePos / trackBg.AbsoluteSize.X
        currentValue = minValue + (maxValue - minValue) * percentage
        
        local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween1 = createTween(fill, tweenInfo, {Size = UDim2.new(percentage, 0, 1, 0)})
        local tween2 = createTween(thumb, tweenInfo, {Position = UDim2.new(percentage, -10, 0.5, -10)})
        tween1:Play()
        tween2:Play()
        
        valueLabel.Text = tostring(math.floor(currentValue))
        if config.onChanged then config.onChanged(currentValue) end
    end
    
    -- Interaction
    local isDragging = false
    
    thumb.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    
    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position.X)
            isDragging = true
        end
    end)
    
    return {
        container = sliderContainer,
        getValue = function() return currentValue end,
        setValue = function(value)
            currentValue = clamp(value, minValue, maxValue)
            local percentage = (currentValue - minValue) / (maxValue - minValue)
            fill.Size = UDim2.new(percentage, 0, 1, 0)
            thumb.Position = UDim2.new(percentage, -10, 0.5, -10)
            valueLabel.Text = tostring(math.floor(currentValue))
        end
    }
end

-- ============================================================================
-- TOGGLE / SWITCH COMPONENT
-- ============================================================================

function GlassWaterUI:createToggle(parent, config)
    config = config or {}
    
    local toggleContainer = Instance.new("Frame")
    toggleContainer.Name = config.name or "Toggle"
    toggleContainer.Parent = parent.contentFrame
    toggleContainer.BackgroundColor3 = self.theme.surface
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Size = UDim2.new(1, -10, 0, 50)
    toggleContainer.LayoutOrder = config.layoutOrder or 999
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Parent = toggleContainer
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0, 200, 0, 50)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.TextColor3 = self.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.Text = config.label or "Toggle"
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBackground"
    switchBg.Parent = toggleContainer
    switchBg.BackgroundColor3 = config.enabled and self.theme.success or self.theme.glass
    switchBg.BackgroundTransparency = config.enabled and 0 or 0.4
    switchBg.Size = UDim2.new(0, 50, 0, 28)
    switchBg.Position = UDim2.new(1, -70, 0, 11)
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 14)
    switchCorner.Parent = switchBg
    
    -- Toggle thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.Parent = switchBg
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BackgroundTransparency = 0
    thumb.Size = UDim2.new(0, 24, 0, 24)
    thumb.Position = config.enabled and UDim2.new(0, 2, 0, 2) or UDim2.new(0, 24, 0, 2)
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 12)
    thumbCorner.Parent = thumb
    
    local isToggled = config.enabled or false
    
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isToggled = not isToggled
            local newColor = isToggled and self.theme.success or self.theme.glass
            local newTransparency = isToggled and 0 or 0.4
            local newPosition = isToggled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
            
            local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween1 = createTween(switchBg, tweenInfo, {BackgroundColor3 = newColor, BackgroundTransparency = newTransparency})
            local tween2 = createTween(thumb, tweenInfo, {Position = newPosition})
            tween1:Play()
            tween2:Play()
            
            if config.onToggle then config.onToggle(isToggled) end
        end
    end)
    
    return {
        container = toggleContainer,
        isToggled = function() return isToggled end,
        setToggled = function(value)
            isToggled = value
            local newColor = isToggled and self.theme.success or self.theme.glass
            local newTransparency = isToggled and 0 or 0.4
            local newPosition = isToggled and UDim2.new(0, 24, 0, 2) or UDim2.new(0, 2, 0, 2)
            switchBg.BackgroundColor3 = newColor
            switchBg.BackgroundTransparency = newTransparency
            thumb.Position = newPosition
        end
    }
end

-- ============================================================================
-- DROPDOWN COMPONENT
-- ============================================================================

function GlassWaterUI:createDropdown(parent, config)
    config = config or {}
    
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Name = config.name or "Dropdown"
    dropdownContainer.Parent = parent.contentFrame
    dropdownContainer.BackgroundColor3 = self.theme.surface
    dropdownContainer.BackgroundTransparency = 1
    dropdownContainer.Size = UDim2.new(1, -10, 0, 50)
    dropdownContainer.LayoutOrder = config.layoutOrder or 999
    
    -- Button
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = "DropdownButton"
    dropdownButton.Parent = dropdownContainer
    dropdownButton.BackgroundColor3 = self.theme.glass
    dropdownButton.BackgroundTransparency = 0.2
    dropdownButton.TextColor3 = self.theme.text
    dropdownButton.TextSize = 14
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.Size = UDim2.new(1, 0, 0, 50)
    dropdownButton.Position = UDim2.new(0, 0, 0, 0)
    dropdownButton.Text = config.options and config.options[1] or "Select Option"
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = dropdownButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = self.theme.border
    buttonStroke.Thickness = 1.5
    buttonStroke.Transparency = 0.5
    buttonStroke.Parent = dropdownButton
    
    -- Menu list
    local menuList = Instance.new("Frame")
    menuList.Name = "MenuList"
    menuList.Parent = dropdownContainer
    menuList.BackgroundColor3 = self.theme.surface
    menuList.BackgroundTransparency = GLASS_TRANSPARENCY
    menuList.Size = UDim2.new(1, 0, 0, 0)
    menuList.Position = UDim2.new(0, 0, 1, 5)
    menuList.ZIndex = 50
    menuList.Visible = false
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 10)
    menuCorner.Parent = menuList
    
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Color = self.theme.border
    menuStroke.Thickness = 1.5
    menuStroke.Transparency = 0.5
    menuStroke.Parent = menuList
    
    local menuPadding = Instance.new("UIPadding")
    menuPadding.PaddingTop = UDim.new(0, 5)
    menuPadding.PaddingBottom = UDim.new(0, 5)
    menuPadding.PaddingLeft = UDim.new(0, 5)
    menuPadding.PaddingRight = UDim.new(0, 5)
    menuPadding.Parent = menuList
    
    local menuLayout = Instance.new("UIListLayout")
    menuLayout.Padding = UDim.new(0, 3)
    menuLayout.FillDirection = Enum.FillDirection.Vertical
    menuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    menuLayout.Parent = menuList
    
    local isOpen = false
    
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            menuList.Visible = true
            local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local itemCount = #(config.options or {})
            local targetSize = UDim2.new(1, 0, 0, (itemCount * 35) + 10)
            local tween = createTween(menuList, tweenInfo, {Size = targetSize})
            tween:Play()
        else
            local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = createTween(menuList, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
            tween:Play()
            tween.Completed:Connect(function()
                menuList.Visible = false
            end)
        end
    end)
    
    -- Create menu items
    if config.options then
        for i, option in ipairs(config.options) do
            local menuItem = Instance.new("TextButton")
            menuItem.Name = "MenuItem_" .. i
            menuItem.Parent = menuList
            menuItem.BackgroundColor3 = self.theme.glass
            menuItem.BackgroundTransparency = 0.3
            menuItem.TextColor3 = self.theme.text
            menuItem.TextSize = 13
            menuItem.Font = Enum.Font.Gotham
            menuItem.Size = UDim2.new(1, 0, 0, 35)
            menuItem.Text = option
            
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 8)
            itemCorner.Parent = menuItem
            
            menuItem.MouseButton1Click:Connect(function()
                dropdownButton.Text = option
                isOpen = false
                menuList.Visible = false
                local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = createTween(menuList, tweenInfo, {Size = UDim2.new(1, 0, 0, 0)})
                tween:Play()
                if config.onSelected then config.onSelected(option) end
            end)
        end
    end
    
    return {
        container = dropdownContainer,
        getSelected = function() return dropdownButton.Text end,
        setSelected = function(value)
            dropdownButton.Text = value
        end
    }
end

-- ============================================================================
-- CARD COMPONENT
-- ============================================================================

function GlassWaterUI:createCard(parent, config)
    config = config or {}
    
    local card = Instance.new("Frame")
    card.Name = config.name or "Card"
    card.Parent = parent.contentFrame
    card.BackgroundColor3 = self.theme.glass
    card.BackgroundTransparency = GLASS_TRANSPARENCY
    card.Size = UDim2.new(1, -10, 0, config.height or 120)
    card.LayoutOrder = config.layoutOrder or 999
    card:SetAttribute("isGlass", true)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CORNER_RADIUS)
    corner.Parent = card
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.border
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = card
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = card
    
    -- Title
    if config.title then
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Parent = card
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, 0, 0, 25)
        title.TextColor3 = self.theme.text
        title.TextSize = 16
        title.Font = Enum.Font.GothamBold
        title.Text = config.title
        title.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Content
    if config.content then
        local content = Instance.new("TextLabel")
        content.Name = "Content"
        content.Parent = card
        content.BackgroundTransparency = 1
        content.Size = UDim2.new(1, 0, 1, -30)
        content.Position = UDim2.new(0, 0, 0, 25)
        content.TextColor3 = self.theme.textSecondary
        content.TextSize = 13
        content.Font = Enum.Font.Gotham
        content.Text = config.content
        content.TextWrapped = true
        content.TextXAlignment = Enum.TextXAlignment.Left
        content.TextYAlignment = Enum.TextYAlignment.Top
    end
    
    return card
end

-- ============================================================================
-- SCROLL VIEW COMPONENT
-- ============================================================================

function GlassWaterUI:createScrollView(parent, config)
    config = config or {}
    
    local scrollContainer = Instance.new("Frame")
    scrollContainer.Name = config.name or "ScrollView"
    scrollContainer.Parent = parent.contentFrame
    scrollContainer.BackgroundColor3 = self.theme.surface
    scrollContainer.BackgroundTransparency = 1
    scrollContainer.Size = UDim2.new(1, -10, 0, config.height or 200)
    scrollContainer.LayoutOrder = config.layoutOrder or 999
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.Parent = scrollContainer
    scrollingFrame.BackgroundColor3 = self.theme.glass
    scrollingFrame.BackgroundTransparency = 0.3
    scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollingFrame.CanvasSize = UDim2.new(1, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 4
    scrollingFrame.ScrollBarImageColor3 = self.theme.accent
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 10)
    scrollCorner.Parent = scrollingFrame
    
    local scrollPadding = Instance.new("UIPadding")
    scrollPadding.PaddingTop = UDim.new(0, 10)
    scrollPadding.PaddingBottom = UDim.new(0, 10)
    scrollPadding.PaddingLeft = UDim.new(0, 10)
    scrollPadding.PaddingRight = UDim.new(0, 10)
    scrollPadding.Parent = scrollingFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scrollingFrame
    
    listLayout.UIListSizeConstraint = Instance.new("UIListSizeConstraint")
    listLayout.UIListSizeConstraint.MaxSize = Vector2.new(math.huge, math.huge)
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    
    return {
        container = scrollContainer,
        scrollFrame = scrollingFrame,
        addItem = function(self, item)
            item.Parent = scrollingFrame
            return item
        end
    }
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================

function GlassWaterUI:createNotification(config)
    config = config or {}
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Notification"
    screenGui.Parent = self.parent
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local notification = Instance.new("Frame")
    notification.Name = "NotificationFrame"
    notification.Parent = screenGui
    notification.BackgroundColor3 = config.color or self.theme.accent
    notification.BackgroundTransparency = 0.1
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, 20, 1, -100)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = notification
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = config.color or self.theme.accent
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = notification
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.Parent = notification
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = notification
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 25)
    title.TextColor3 = self.theme.text
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Text = config.title or "Notification"
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Message
    local message = Instance.new("TextLabel")
    message.Name = "Message"
    message.Parent = notification
    message.BackgroundTransparency = 1
    message.Size = UDim2.new(1, 0, 0, 35)
    message.Position = UDim2.new(0, 0, 0, 25)
    message.TextColor3 = self.theme.textSecondary
    message.TextSize = 12
    message.Font = Enum.Font.Gotham
    message.Text = config.message or ""
    message.TextWrapped = true
    message.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Entrance animation
    local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = createTween(notification, tweenInfo, {Position = UDim2.new(1, -320, 1, -100)})
    tween:Play()
    
    -- Auto-dismiss
    local duration = config.duration or 3
    wait(duration)
    
    local exitTween = createTween(notification, tweenInfo, {Position = UDim2.new(1, 20, 1, -100)})
    exitTween:Play()
    exitTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

-- ============================================================================
-- TOOLTIP SYSTEM
-- ============================================================================

function GlassWaterUI:createTooltip(targetObject, config)
    config = config or {}
    
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Parent = self.parent
    tooltip.BackgroundColor3 = self.theme.glass
    tooltip.BackgroundTransparency = 0
    tooltip.TextColor3 = self.theme.text
    tooltip.TextSize = 11
    tooltip.Font = Enum.Font.Gotham
    tooltip.Text = config.text or "Tooltip"
    tooltip.TextWrapped = true
    tooltip.Visible = false
    tooltip.ZIndex = 100
    
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 8)
    tooltipCorner.Parent = tooltip
    
    local tooltipStroke = Instance.new("UIStroke")
    tooltipStroke.Color = self.theme.border
    tooltipStroke.Thickness = 1
    tooltipStroke.Parent = tooltip
    
    local tooltipPadding = Instance.new("UIPadding")
    tooltipPadding.PaddingTop = UDim.new(0, 8)
    tooltipPadding.PaddingBottom = UDim.new(0, 8)
    tooltipPadding.PaddingLeft = UDim.new(0, 10)
    tooltipPadding.PaddingRight = UDim.new(0, 10)
    tooltipPadding.Parent = tooltip
    
    targetObject.MouseEnter:Connect(function()
        tooltip.Visible = true
        tooltip.Size = UDim2.new(0, 150, 0, 50)
        tooltip.Position = UDim2.new(0, targetObject.AbsolutePosition.X, 0, targetObject.AbsolutePosition.Y - 60)
        
        local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = createTween(tooltip, tweenInfo, {TextTransparency = 0})
        tween:Play()
    end)
    
    targetObject.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = createTween(tooltip, tweenInfo, {TextTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            tooltip.Visible = false
        end)
    end)
    
    return tooltip
end

-- ============================================================================
-- HITBOX SYSTEM
-- ============================================================================

function GlassWaterUI:updateHitboxes()
    for _, hitbox in ipairs(self.hitboxes) do
        if hitbox.enabled and hitbox.object and hitbox.object.Parent then
            hitbox.bounds = {
                x = hitbox.object.AbsolutePosition.X,
                y = hitbox.object.AbsolutePosition.Y,
                width = hitbox.object.AbsoluteSize.X,
                height = hitbox.object.AbsoluteSize.Y
            }
        end
    end
end

function GlassWaterUI:checkHitbox(position)
    for _, hitbox in ipairs(self.hitboxes) do
        if hitbox.enabled then
            local isInside = (
                position.X >= hitbox.bounds.x and
                position.X <= hitbox.bounds.x + hitbox.bounds.width and
                position.Y >= hitbox.bounds.y and
                position.Y <= hitbox.bounds.y + hitbox.bounds.height
            )
            if isInside then
                return hitbox
            end
        end
    end
    return nil
end

-- ============================================================================
-- VISIBILITY & ANIMATION CONTROL
-- ============================================================================

function GlassWaterUI:showContainer(container, animated)
    animated = animated ~= false
    
    if animated then
        container.screenGui.ScreenInsets = UDim2.new(0, 0, 0, 0)
        local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = createTween(container.contentFrame, tweenInfo, {BackgroundTransparency = GLASS_TRANSPARENCY})
        tween:Play()
        container.isVisible = true
    else
        container.screenGui.Enabled = true
        container.isVisible = true
    end
end

function GlassWaterUI:hideContainer(container, animated)
    animated = animated ~= false
    
    if animated then
        local tweenInfo = TweenInfo.new(ANIMATION_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = createTween(container.contentFrame, tweenInfo, {BackgroundTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            container.screenGui.Enabled = false
            container.isVisible = false
        end)
    else
        container.screenGui.Enabled = false
        container.isVisible = false
    end
end

-- ============================================================================
-- UTILITY METHODS
-- ============================================================================

function GlassWaterUI:cleanup()
    for _, item in ipairs(self.containers) do
        if item.screenGui then
            item.screenGui:Destroy()
        end
    end
    
    for _, item in ipairs(self._maid) do
        if item and item.Parent then
            item:Destroy()
        end
    end
    
    self.containers = {}
    self.buttons = {}
    self.inputs = {}
    self.animations = {}
    self.hitboxes = {}
end

function GlassWaterUI:getTheme()
    return self.theme
end

function GlassWaterUI:setColorScheme(colorScheme)
    -- Allow custom color schemes
    for key, value in pairs(colorScheme) do
        self.theme[key] = value
    end
    for _, container in ipairs(self.containers) do
        self:updateTheme(container.contentFrame)
    end
end

-- ============================================================================
-- EXAMPLE USAGE
-- ============================================================================

--[[
    local Library = GlassWaterUI.new({
        darkMode = true,
        parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"),
        isMobile = false
    })
    
    local mainWindow = Library:createContainer("MainWindow", {
        size = UDim2.new(0, 400, 0, 600),
        position = UDim2.new(0.5, -200, 0.5, -300),
        useBlur = true
    })
    
    Library:createButton(mainWindow, {
        text = "Click Me!",
        height = 50,
        callback = function()
            Library:createNotification({
                title = "Button Clicked!",
                message = "This is a notification",
                duration = 3,
                color = Library:getTheme().success
            })
        end
    })
    
    Library:createTextInput(mainWindow, {
        placeholder = "Enter text here",
        layoutOrder = 1
    })
    
    local slider = Library:createSlider(mainWindow, {
        label = "Volume",
        min = 0,
        max = 100,
        default = 50,
        layoutOrder = 2,
        onChanged = function(value)
            print("Volume:", value)
        end
    })
    
    local toggle = Library:createToggle(mainWindow, {
        label = "Enable Feature",
        enabled = false,
        layoutOrder = 3,
        onToggle = function(state)
            print("Toggle state:", state)
        end
    })
    
    Library:createDropdown(mainWindow, {
        options = {"Option 1", "Option 2", "Option 3"},
        layoutOrder = 4,
        onSelected = function(selected)
            print("Selected:", selected)
        end
    })
    
    Library:createCard(mainWindow, {
        title = "Info Card",
        content = "This is a beautiful glass morphism card with smooth animations!",
        layoutOrder = 5
    })
]]

return GlassWaterUI
