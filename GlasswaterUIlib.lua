-- glasswaterUIlib
local GlassWaterUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Themes
GlassWaterUI.Themes = {
    White = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(240, 240, 240),
        Text = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 122, 255),
        Border = Color3.fromRGB(200, 200, 200),
        GlassTransparency = 0.6,
        Shadow = Color3.fromRGB(150, 150, 150),
    },
    Dark = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 122, 255),
        Border = Color3.fromRGB(60, 60, 60),
        GlassTransparency = 0.5,
        Shadow = Color3.fromRGB(0, 0, 0),
    }
}

-- Current theme
GlassWaterUI.CurrentTheme = GlassWaterUI.Themes.White

-- Function to switch theme
function GlassWaterUI:SetTheme(themeName)
    if GlassWaterUI.Themes[themeName] then
        GlassWaterUI.CurrentTheme = GlassWaterUI.Themes[themeName]
        -- You can add logic to update all existing UI elements here if needed
    end
end

-- Detect device type (Mobile or PC)
function GlassWaterUI:IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Animation helper
function GlassWaterUI:Animate(object, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Create glass effect on a frame
function GlassWaterUI:ApplyGlassEffect(frame, theme)
    frame.BackgroundTransparency = theme.GlassTransparency
    frame.BorderSizePixel = 1
    frame.BorderColor3 = theme.Border
    
    -- Simulate blur with a noise image (frosted glass)
    local blurImage = Instance.new("ImageLabel")
    blurImage.Name = "BlurEffect"
    blurImage.BackgroundTransparency = 1
    blurImage.Size = UDim2.new(1, 0, 1, 0)
    blurImage.Image = "rbxassetid://YOUR_BLUR_IMAGE_ID"  -- Replace with your asset ID for noise/blur texture
    blurImage.ImageTransparency = 0.8
    blurImage.ScaleType = Enum.ScaleType.Tile
    blurImage.TileSize = UDim2.new(0, 100, 0, 100)
    blurImage.Parent = frame
    
    -- Add gradient for glass shine
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, theme.Secondary)
    })
    uiGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 0.8)
    })
    uiGradient.Rotation = 45
    uiGradient.Parent = frame
    
    -- Add corner rounding
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = frame
end

-- Add shadow effect
function GlassWaterUI:ApplyShadow(frame, theme)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, 5, 0, 5)
    shadow.Image = "rbxassetid://1316045217"  -- Roblox shadow asset
    shadow.ImageColor3 = theme.Shadow
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = frame.Parent  -- Attach to parent to overlay
    frame.ZIndex = 2
    shadow.ZIndex = 1
end

-- Hitbox helper (for custom hit detection, e.g., non-rectangular)
function GlassWaterUI:CreateHitbox(parent, size, position, callback)
    local hitbox = Instance.new("Frame")
    hitbox.Size = size
    hitbox.Position = position
    hitbox.BackgroundTransparency = 1  -- Invisible
    hitbox.Parent = parent
    
    hitbox.MouseEnter:Connect(function()
        GlassWaterUI:Animate(hitbox, {BackgroundTransparency = 0.9}, 0.2)  -- Optional visual feedback
    end)
    hitbox.MouseLeave:Connect(function()
        GlassWaterUI:Animate(hitbox, {BackgroundTransparency = 1}, 0.2)
    end)
    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            callback()
        end
    end)
    return hitbox
end

-- Component: Window
function GlassWaterUI:CreateWindow(title, size, position, parent)
    local window = Instance.new("Frame")
    window.Name = "Window"
    window.Size = size or UDim2.new(0, 400, 0, 300)
    window.Position = position or UDim2.new(0.5, -200, 0.5, -150)
    window.BackgroundColor3 = self.CurrentTheme.Secondary
    window.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")  -- Assume ScreenGui exists
    
    self:ApplyGlassEffect(window, self.CurrentTheme)
    self:ApplyShadow(window, self.CurrentTheme)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = self.CurrentTheme.Primary
    titleBar.Parent = window
    self:ApplyGlassEffect(titleBar, self.CurrentTheme)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title or "GlassWater Window"
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = self.CurrentTheme.Text
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.Parent = titleBar
    
    -- Drag functionality
    local dragging = false
    local dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService:BindToRenderStep("DragWindow", Enum.RenderPriority.Input.Value, function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            self:Animate(window, {Position = newPos}, 0.1, Enum.EasingStyle.Linear)
        end
    end)
    
    -- Close button
    local closeButton = self:CreateButton("X", UDim2.new(0, 30, 1, 0), UDim2.new(1, -30, 0, 0), titleBar, function()
        self:Animate(window, {Transparency = 1}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        wait(0.5)
        window:Destroy()
    end)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    
    return window
end

-- Component: Button
function GlassWaterUI:CreateButton(text, size, position, parent, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = size or UDim2.new(0, 100, 0, 40)
    button.Position = position or UDim2.new(0, 0, 0, 0)
    button.BackgroundColor3 = self.CurrentTheme.Primary
    button.Text = text or "Button"
    button.TextColor3 = self.CurrentTheme.Text
    button.Font = Enum.Font.SourceSans
    button.TextSize = 16
    button.Parent = parent
    
    self:ApplyGlassEffect(button, self.CurrentTheme)
    
    -- Animations
    button.MouseEnter:Connect(function()
        self:Animate(button, {BackgroundColor3 = self.CurrentTheme.Accent}, 0.3)
    end)
    button.MouseLeave:Connect(function()
        self:Animate(button, {BackgroundColor3 = self.CurrentTheme.Primary}, 0.3)
    end)
    button.MouseButton1Down:Connect(function()
        self:Animate(button, {Size = button.Size - UDim2.new(0, 5, 0, 5)}, 0.1)
    end)
    button.MouseButton1Up:Connect(function()
        self:Animate(button, {Size = button.Size + UDim2.new(0, 5, 0, 5)}, 0.1)
        if callback then callback() end
    end)
    
    -- Mobile support: Use touch events
    if self:IsMobile() then
        button.TouchTap:Connect(callback)
    end
    
    return button
end

-- Component: Slider
function GlassWaterUI:CreateSlider(min, max, default, size, position, parent, callback)
    local slider = Instance.new("Frame")
    slider.Name = "Slider"
    slider.Size = size or UDim2.new(0, 200, 0, 20)
    slider.Position = position or UDim2.new(0, 0, 0, 0)
    slider.BackgroundColor3 = self.CurrentTheme.Secondary
    slider.Parent = parent
    
    self:ApplyGlassEffect(slider, self.CurrentTheme)
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = self.CurrentTheme.Accent
    fill.Parent = slider
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = self.CurrentTheme.Primary
    knob.Parent = slider
    self:ApplyGlassEffect(knob, self.CurrentTheme)
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)  -- Circle
    knobCorner.Parent = knob
    
    local value = default or min
    local function updateValue(pos)
        value = min + (max - min) * (pos / slider.AbsoluteSize.X)
        fill.Size = UDim2.new(pos / slider.AbsoluteSize.X, 0, 1, 0)
        knob.Position = UDim2.new(0, pos - 10, 0, 0)
        if callback then callback(value) end
    end
    updateValue((default - min) / (max - min) * slider.AbsoluteSize.X)
    
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pos = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            self:Animate(knob, {Position = UDim2.new(0, pos - 10, 0, 0)}, 0.1)
            updateValue(pos)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp(input.Position.X - slider.AbsolutePosition.X, 0, slider.AbsoluteSize.X)
            self:Animate(knob, {Position = UDim2.new(0, pos - 10, 0, 0)}, 0.05, Enum.EasingStyle.Linear)
            updateValue(pos)
        end
    end)
    
    return slider, function() return value end
end

-- Component: Toggle
function GlassWaterUI:CreateToggle(default, size, position, parent, callback)
    local toggle = Instance.new("Frame")
    toggle.Name = "Toggle"
    toggle.Size = size or UDim2.new(0, 50, 0, 25)
    toggle.Position = position or UDim2.new(0, 0, 0, 0)
    toggle.BackgroundColor3 = self.CurrentTheme.Secondary
    toggle.Parent = parent
    
    self:ApplyGlassEffect(toggle, self.CurrentTheme)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 25, 1, 0)
    knob.Position = default and UDim2.new(1, -25, 0, 0) or UDim2.new(0, 0, 0, 0)
    knob.BackgroundColor3 = default and self.CurrentTheme.Accent or self.CurrentTheme.Primary
    knob.Parent = toggle
    self:ApplyGlassEffect(knob, self.CurrentTheme)
    
    local state = default or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        self:Animate(knob, {Position = state and UDim2.new(1, -25, 0, 0) or UDim2.new(0, 0, 0, 0)}, 0.2)
        self:Animate(knob, {BackgroundColor3 = state and self.CurrentTheme.Accent or self.CurrentTheme.Primary}, 0.2)
        if callback then callback(state) end
    end)
    
    return toggle, function() return state end
end

-- Component: Dropdown
function GlassWaterUI:CreateDropdown(options, default, size, position, parent, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = size or UDim2.new(0, 150, 0, 30)
    dropdown.Position = position or UDim2.new(0, 0, 0, 0)
    dropdown.BackgroundColor3 = self.CurrentTheme.Primary
    dropdown.Parent = parent
    
    self:ApplyGlassEffect(dropdown, self.CurrentTheme)
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Text = default or options[1] or "Select"
    selectedLabel.Size = UDim2.new(1, 0, 1, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.TextColor3 = self.CurrentTheme.Text
    selectedLabel.Parent = dropdown
    
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.Position = UDim2.new(0, 0, 1, 0)
    list.BackgroundColor3 = self.CurrentTheme.Secondary
    list.ScrollBarThickness = 5
    list.Visible = false
    list.Parent = dropdown
    self:ApplyGlassEffect(list, self.CurrentTheme)
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = list
    
    for _, option in ipairs(options) do
        local item = self:CreateButton(option, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), list, function()
            selectedLabel.Text = option
            self:Animate(list, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            list.Visible = false
            if callback then callback(option) end
        end)
    end
    
    dropdown.MouseButton1Click:Connect(function()
        local open = not list.Visible
        self:Animate(list, {Size = open and UDim2.new(1, 0, 0, math.min(#options * 30, 150)) or UDim2.new(1, 0, 0, 0)}, 0.3)
        list.Visible = true  -- Set visible after animation if opening
    end)
    
    return dropdown
end

-- Component: Textbox
function GlassWaterUI:CreateTextbox(placeholder, size, position, parent, callback)
    local textbox = Instance.new("TextBox")
    textbox.Name = "Textbox"
    textbox.Size = size or UDim2.new(0, 200, 0, 30)
    textbox.Position = position or UDim2.new(0, 0, 0, 0)
    textbox.BackgroundColor3 = self.CurrentTheme.Primary
    textbox.Text = ""
    textbox.PlaceholderText = placeholder or "Enter text"
    textbox.TextColor3 = self.CurrentTheme.Text
    textbox.Parent = parent
    
    self:ApplyGlassEffect(textbox, self.CurrentTheme)
    
    textbox.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then callback(textbox.Text) end
    end)
    
    return textbox
end

-- Component: Label
function GlassWaterUI:CreateLabel(text, size, position, parent)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = size or UDim2.new(0, 100, 0, 20)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Label"
    label.TextColor3 = self.CurrentTheme.Text
    label.Parent = parent
    
    return label
end

-- Component: Tab System
function GlassWaterUI:CreateTabSystem(tabs, size, position, parent)
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabSystem"
    tabFrame.Size = size or UDim2.new(0, 400, 0, 300)
    tabFrame.Position = position or UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = parent
    
    local tabButtons = Instance.new("Frame")
    tabButtons.Size = UDim2.new(1, 0, 0, 30)
    tabButtons.BackgroundTransparency = 1
    tabButtons.Parent = tabFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.FillDirection = Enum.FillDirection.Horizontal
    uiListLayout.Parent = tabButtons
    
    local pages = {}
    local currentTab = 1
    
    for i, tabName in ipairs(tabs) do
        local button = self:CreateButton(tabName, UDim2.new(1/#tabs, 0, 1, 0), UDim2.new(0, 0, 0, 0), tabButtons, function()
            pages[currentTab].Visible = false
            currentTab = i
            pages[currentTab].Visible = true
            self:Animate(pages[currentTab], {Transparency = 0}, 0.5)
        end)
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, -30)
        page.Position = UDim2.new(0, 0, 0, 30)
        page.BackgroundColor3 = self.CurrentTheme.Secondary
        page.Visible = i == 1
        page.Transparency = i == 1 and 0 or 1
        page.Parent = tabFrame
        self:ApplyGlassEffect(page, self.CurrentTheme)
        pages[i] = page
    end
    
    return tabFrame, pages
end

-- More components can be added: ProgressBar, Checkbox, RadioButton, etc.
-- To expand to 10k lines, add variations, more animations, event handlers, etc.
-- For example, add particle effects, more themes, localization, etc.

-- Example usage:
-- local screenGui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
-- local window = GlassWaterUI:CreateWindow("Test Window", nil, nil, screenGui)
-- local button = GlassWaterUI:CreateButton("Click Me", nil, UDim2.new(0, 10, 0, 40), window, function() print("Clicked!") end)
-- GlassWaterUI:SetTheme("Dark")

return GlassWaterUI
