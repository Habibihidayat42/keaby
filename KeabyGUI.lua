local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

if _G.KeabyGUI then
    if _G.KeabyGUI.Destroy then
        _G.KeabyGUI:Destroy()
    end
    task.wait(0.1)
end

local Keaby = {
    GUI = nil,
    Minimized = false,
    InstantFishing = nil,
    Instant2XSpeed = nil,
    GitHubRepo = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/"
}

_G.KeabyGUI = Keaby

local function createHexagon(parent, size, position, color, zindex)
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = size or UDim2.new(0, 60, 0, 60)
    hexFrame.Position = position or UDim2.new(0, 0, 0, 0)
    hexFrame.BackgroundTransparency = 1
    hexFrame.ZIndex = zindex or 1
    hexFrame.Parent = parent
    
    local hex = Instance.new("ImageLabel")
    hex.Size = UDim2.new(1, 0, 1, 0)
    hex.BackgroundTransparency = 1
    hex.Image = "rbxassetid://6671315751"
    hex.ImageColor3 = color or Color3.fromRGB(255, 180, 70)
    hex.ScaleType = Enum.ScaleType.Fit
    hex.ZIndex = zindex or 1
    hex.Parent = hexFrame
    
    return hexFrame
end

local function createBeeIcon(parent, size, position)
    local beeFrame = Instance.new("Frame")
    beeFrame.Size = size or UDim2.new(0, 40, 0, 40)
    beeFrame.Position = position or UDim2.new(0.5, -20, 0.5, -20)
    beeFrame.BackgroundTransparency = 1
    beeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    beeFrame.Parent = parent
    
    local body = Instance.new("Frame")
    body.Size = UDim2.new(0.7, 0, 0.8, 0)
    body.Position = UDim2.new(0.15, 0, 0.1, 0)
    body.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    body.Parent = beeFrame
    Instance.new("UICorner", body).CornerRadius = UDim.new(0.5, 0)
    
    local stripe1 = Instance.new("Frame")
    stripe1.Size = UDim2.new(1, 0, 0.2, 0)
    stripe1.Position = UDim2.new(0, 0, 0.25, 0)
    stripe1.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    stripe1.BorderSizePixel = 0
    stripe1.Parent = body
    
    local stripe2 = Instance.new("Frame")
    stripe2.Size = UDim2.new(1, 0, 0.2, 0)
    stripe2.Position = UDim2.new(0, 0, 0.55, 0)
    stripe2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    stripe2.BorderSizePixel = 0
    stripe2.Parent = body
    
    local wing1 = Instance.new("Frame")
    wing1.Size = UDim2.new(0.3, 0, 0.4, 0)
    wing1.Position = UDim2.new(-0.15, 0, 0.2, 0)
    wing1.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
    wing1.BackgroundTransparency = 0.3
    wing1.Rotation = -20
    wing1.Parent = beeFrame
    Instance.new("UICorner", wing1).CornerRadius = UDim.new(0.5, 0)
    
    local wing2 = Instance.new("Frame")
    wing2.Size = UDim2.new(0.3, 0, 0.4, 0)
    wing2.Position = UDim2.new(0.85, 0, 0.2, 0)
    wing2.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
    wing2.BackgroundTransparency = 0.3
    wing2.Rotation = 20
    wing2.Parent = beeFrame
    Instance.new("UICorner", wing2).CornerRadius = UDim.new(0.5, 0)
    
    return beeFrame
end

local function loadFromGitHub(scriptPath)
    local success, result = pcall(function()
        return game:HttpGet(Keaby.GitHubRepo .. scriptPath)
    end)
    
    if success then
        local loadSuccess, module = pcall(function()
            return loadstring(result)()
        end)
        if loadSuccess then
            return module
        else
            warn("[Keaby] Error loading module: " .. tostring(module))
            return nil
        end
    else
        warn("[Keaby] Error fetching from GitHub: " .. tostring(result))
        return nil
    end
end

function Keaby:CreateGUI()
    if self.GUI then
        self.GUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "KeabyGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    self.GUI = gui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 380, 0, 480)
    mainFrame.Position = UDim2.new(0.5, -190, 0.5, -240)
    mainFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 210, 90)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 180, 60))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    createHexagon(mainFrame, UDim2.new(0, 50, 0, 50), UDim2.new(0, 10, 0, 10), Color3.fromRGB(255, 220, 100), 1)
    createHexagon(mainFrame, UDim2.new(0, 40, 0, 40), UDim2.new(1, -50, 0, 15), Color3.fromRGB(255, 190, 70), 1)
    createHexagon(mainFrame, UDim2.new(0, 35, 0, 35), UDim2.new(0, 15, 1, -45), Color3.fromRGB(255, 210, 85), 1)
    createHexagon(mainFrame, UDim2.new(0, 45, 0, 45), UDim2.new(1, -55, 1, -55), Color3.fromRGB(255, 200, 75), 1)
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(230, 170, 50)
    header.BorderSizePixel = 0
    header.ZIndex = 2
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header
    
    local headerBottom = Instance.new("Frame")
    headerBottom.Size = UDim2.new(1, 0, 0, 20)
    headerBottom.Position = UDim2.new(0, 0, 1, -20)
    headerBottom.BackgroundColor3 = Color3.fromRGB(230, 170, 50)
    headerBottom.BorderSizePixel = 0
    headerBottom.ZIndex = 2
    headerBottom.Parent = header
    
    createBeeIcon(header, UDim2.new(0, 40, 0, 40), UDim2.new(0, 30, 0.5, 0))
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 70, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KEABY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 3
    title.Parent = header
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -140, 0, 20)
    subtitle.Position = UDim2.new(0, 70, 0, 28)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Honeycomb Fishing Script"
    subtitle.TextColor3 = Color3.fromRGB(255, 240, 200)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 3
    subtitle.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(100, 70, 30)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.ZIndex = 3
    minimizeBtn.Parent = header
    
    local minBtnCorner = Instance.new("UICorner")
    minBtnCorner.CornerRadius = UDim.new(0, 8)
    minBtnCorner.Parent = minimizeBtn
    
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -80)
    content.Position = UDim2.new(0, 10, 0, 70)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = Color3.fromRGB(230, 170, 50)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ZIndex = 2
    content.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 15)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    self:CreateFeatureToggle(content, "Instant Fishing", 1, {"Hook Delay", "Fishing Delay", "Cancel Delay"}, 
        {0.06, 0.12, 0.05}, {0.01, 0.05, 0.01}, {0.25, 1.0, 0.25})
    
    self:CreateFeatureToggle(content, "Instant 2x Speed", 2, {"Fishing Delay", "Cancel Delay"}, 
        {0.3, 0.05}, {0.0, 0.01}, {1.0, 0.2})
    
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundColor3 = Color3.fromRGB(230, 170, 50)
    resizeHandle.ZIndex = 4
    resizeHandle.Parent = mainFrame
    
    local resizeCorner = Instance.new("UICorner")
    resizeCorner.CornerRadius = UDim.new(0, 5)
    resizeCorner.Parent = resizeHandle
    
    local minimizedIcon = Instance.new("Frame")
    minimizedIcon.Name = "MinimizedIcon"
    minimizedIcon.Size = UDim2.new(0, 60, 0, 60)
    minimizedIcon.Position = UDim2.new(0, 20, 0, 20)
    minimizedIcon.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
    minimizedIcon.Visible = false
    minimizedIcon.ZIndex = 5
    minimizedIcon.Parent = gui
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 15)
    iconCorner.Parent = minimizedIcon
    
    createBeeIcon(minimizedIcon, UDim2.new(0, 40, 0, 40), UDim2.new(0.5, 0, 0.5, 0))
    
    local iconButton = Instance.new("TextButton")
    iconButton.Size = UDim2.new(1, 0, 1, 0)
    iconButton.BackgroundTransparency = 1
    iconButton.Text = ""
    iconButton.ZIndex = 6
    iconButton.Parent = minimizedIcon
    
    self:SetupDragging(header, mainFrame)
    self:SetupMinimize(minimizeBtn, iconButton, mainFrame, minimizedIcon)
    self:SetupResize(resizeHandle, mainFrame, content)
    
    return gui
end

function Keaby:CreateFeatureToggle(parent, featureName, layoutOrder, sliderNames, defaultValues, minValues, maxValues)
    local featureFrame = Instance.new("Frame")
    featureFrame.Name = featureName:gsub(" ", "")
    featureFrame.Size = UDim2.new(1, -10, 0, 60)
    featureFrame.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
    featureFrame.BorderSizePixel = 0
    featureFrame.LayoutOrder = layoutOrder
    featureFrame.ZIndex = 2
    featureFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = featureFrame
    
    createHexagon(featureFrame, UDim2.new(0, 30, 0, 30), UDim2.new(0, 8, 0, 15), Color3.fromRGB(255, 200, 70), 3)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -100, 0, 30)
    nameLabel.Position = UDim2.new(0, 45, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = featureName
    nameLabel.TextColor3 = Color3.fromRGB(100, 70, 30)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 3
    nameLabel.Parent = featureFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -100, 0, 20)
    statusLabel.Position = UDim2.new(0, 45, 0, 32)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "OFF"
    statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.ZIndex = 3
    statusLabel.Parent = featureFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0, 70, 0, 35)
    toggleBtn.Position = UDim2.new(1, -80, 0, 12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.ZIndex = 3
    toggleBtn.Parent = featureFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    local slidersFrame = Instance.new("Frame")
    slidersFrame.Name = "SlidersFrame"
    slidersFrame.Size = UDim2.new(1, 0, 0, 0)
    slidersFrame.Position = UDim2.new(0, 0, 0, 60)
    slidersFrame.BackgroundTransparency = 1
    slidersFrame.Visible = false
    slidersFrame.ZIndex = 2
    slidersFrame.Parent = featureFrame
    
    local sliderLayout = Instance.new("UIListLayout")
    sliderLayout.Padding = UDim.new(0, 8)
    sliderLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sliderLayout.Parent = slidersFrame
    
    local sliderValues = {}
    
    for i, sliderName in ipairs(sliderNames) do
        local slider = self:CreateSlider(slidersFrame, sliderName, defaultValues[i], minValues[i], maxValues[i], i)
        sliderValues[sliderName] = defaultValues[i]
        
        slider.Changed:Connect(function(value)
            sliderValues[sliderName] = value
            
            if featureName == "Instant Fishing" and self.InstantFishing and self.InstantFishing.Running then
                self.InstantFishing.SetSettings({
                    HookDelay = sliderValues["Hook Delay"],
                    FishingDelay = sliderValues["Fishing Delay"],
                    CancelDelay = sliderValues["Cancel Delay"]
                })
            elseif featureName == "Instant 2x Speed" and self.Instant2XSpeed and self.Instant2XSpeed.Running then
                self.Instant2XSpeed.SetSettings({
                    FishingDelay = sliderValues["Fishing Delay"],
                    CancelDelay = sliderValues["Cancel Delay"]
                })
            end
        end)
    end
    
    local isActive = false
    toggleBtn.MouseButton1Click:Connect(function()
        isActive = not isActive
        
        if isActive then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            toggleBtn.Text = "ON"
            statusLabel.Text = "ON"
            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
            
            slidersFrame.Visible = true
            local newHeight = 60 + (#sliderNames * 45) + ((#sliderNames - 1) * 8) + 10
            featureFrame:TweenSize(UDim2.new(1, -10, 0, newHeight), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            
            if featureName == "Instant Fishing" then
                if not self.InstantFishing then
                    self.InstantFishing = loadFromGitHub("FungsiKeaby/InstantFishing.lua")
                end
                if self.InstantFishing then
                    self.InstantFishing.SetSettings({
                        HookDelay = sliderValues["Hook Delay"],
                        FishingDelay = sliderValues["Fishing Delay"],
                        CancelDelay = sliderValues["Cancel Delay"]
                    })
                    self.InstantFishing.Start()
                end
            elseif featureName == "Instant 2x Speed" then
                if not self.Instant2XSpeed then
                    self.Instant2XSpeed = loadFromGitHub("FungsiKeaby/Instant2Xspeed.lua")
                end
                if self.Instant2XSpeed then
                    self.Instant2XSpeed.SetSettings({
                        FishingDelay = sliderValues["Fishing Delay"],
                        CancelDelay = sliderValues["Cancel Delay"]
                    })
                    self.Instant2XSpeed.Start()
                end
            end
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 100)
            toggleBtn.Text = "OFF"
            statusLabel.Text = "OFF"
            statusLabel.TextColor3 = Color3.fromRGB(200, 100, 100)
            
            slidersFrame.Visible = false
            featureFrame:TweenSize(UDim2.new(1, -10, 0, 60), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            
            if featureName == "Instant Fishing" and self.InstantFishing then
                self.InstantFishing.Stop()
            elseif featureName == "Instant 2x Speed" and self.Instant2XSpeed then
                self.Instant2XSpeed.Stop()
            end
        end
    end)
end

function Keaby:CreateSlider(parent, name, defaultValue, minValue, maxValue, layoutOrder)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = name:gsub(" ", "")
    sliderFrame.Size = UDim2.new(1, -10, 0, 45)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.LayoutOrder = layoutOrder
    sliderFrame.ZIndex = 2
    sliderFrame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. string.format("%.2fs", defaultValue)
    label.TextColor3 = Color3.fromRGB(100, 70, 30)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 3
    label.Parent = sliderFrame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 23)
    sliderBg.BackgroundColor3 = Color3.fromRGB(230, 170, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.ZIndex = 3
    sliderBg.Parent = sliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 70)
    fill.BorderSizePixel = 0
    fill.ZIndex = 4
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 3, 0)
    button.Position = UDim2.new(0, 0, -1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 5
    button.Parent = sliderBg
    
    local currentValue = defaultValue
    local dragging = false
    
    local function updateSlider(input)
        local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        currentValue = minValue + (maxValue - minValue) * relativeX
        currentValue = math.floor(currentValue * 100) / 100
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        label.Text = name .. ": " .. string.format("%.2fs", currentValue)
    end
    
    button.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    button.TouchLongPress:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    button.MouseButton1Click:Connect(function(x, y)
        local mousePos = UserInputService:GetMouseLocation()
        updateSlider({Position = Vector2.new(mousePos.X, mousePos.Y)})
    end)
    
    button.TouchTap:Connect(function(touchPos)
        updateSlider({Position = touchPos[1]})
    end)
    
    local sliderObj = {}
    sliderObj.Changed = Instance.new("BindableEvent")
    
    task.spawn(function()
        local lastValue = currentValue
        while sliderFrame.Parent do
            if currentValue ~= lastValue then
                sliderObj.Changed:Fire(currentValue)
                lastValue = currentValue
            end
            task.wait(0.1)
        end
    end)
    
    return sliderObj
end

function Keaby:SetupDragging(header, mainFrame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    local function update(input)
        local delta = input.Position - mousePos
        mainFrame.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

function Keaby:SetupMinimize(minimizeBtn, iconButton, mainFrame, minimizedIcon)
    minimizeBtn.MouseButton1Click:Connect(function()
        self.Minimized = true
        mainFrame.Visible = false
        minimizedIcon.Visible = true
    end)
    
    iconButton.MouseButton1Click:Connect(function()
        self.Minimized = false
        mainFrame.Visible = true
        minimizedIcon.Visible = false
    end)
end

function Keaby:SetupResize(resizeHandle, mainFrame, content)
    local resizing = false
    local startSize, startPos
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            startSize = mainFrame.Size
            startPos = input.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startPos
            local newWidth = math.max(300, startSize.X.Offset + delta.X)
            local newHeight = math.max(300, startSize.Y.Offset + delta.Y)
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
end

function Keaby:Destroy()
    if self.InstantFishing then
        self.InstantFishing.Stop()
    end
    if self.Instant2XSpeed then
        self.Instant2XSpeed.Stop()
    end
    if self.GUI then
        self.GUI:Destroy()
    end
end

Keaby:CreateGUI()
print("[Keaby] GUI loaded successfully!")
return Keaby
