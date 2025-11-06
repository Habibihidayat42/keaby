-- KeabyGUI.lua (v2.1) — Honey / Hexagon minimize icon, draggable icon, modal disabled on minimize
-- Save as KeabyGUI.lua and run in executor. Modules loaded from FungsiKeaby/Instant.lua and Instant2Xspeed.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- GitHub raw base fallback
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- safe loader: try local readfile/isfile first, else HttpGet
local function safeLoadFeature(filename)
    local code
    local ok, hasIsfile = pcall(function() return isfile end)
    if ok and hasIsfile and isfile(filename) then
        code = readfile(filename)
    else
        local url = GITHUB_RAW_BASE .. filename
        local suc, res = pcall(function() return game:HttpGet(url) end)
        if suc then code = res end
    end
    if not code then return nil, "failed to load "..filename end
    local func, err = loadstring(code)
    if not func then return nil, err end
    local ok2, result = pcall(func)
    if not ok2 then return nil, result end
    return result
end

-- small instance creator
local function new(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then inst.Parent = v else inst[k] = v end
        end
    end
    return inst
end

-- ensure PlayerGui
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- remove old
for _,c in pairs(playerGui:GetChildren()) do
    if c.Name == "KeabyGUI" then c:Destroy() end
end

-- ScreenGui
local screenGui = new("ScreenGui", {Name = "KeabyGUI", ResetOnSpawn = false, Parent = playerGui})
screenGui.IgnoreGuiInset = true

-- blocker (modal) - will be toggled active only when window visible
local blocker = new("Frame", {
    Parent = screenGui,
    Size = UDim2.fromScale(1,1),
    Position = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
    Active = true,
    ZIndex = 1,
})
-- initially activated; we'll set active after building window
blocker.Active = true

-- Main window
local window = new("Frame", {
    Parent = screenGui,
    Name = "KeabyWindow",
    Size = UDim2.new(0, 740, 0, 420),
    Position = UDim2.new(0.5, -370, 0.5, -210),
    BackgroundColor3 = Color3.fromRGB(210,130,30), -- base honey (will be subtle via transparency)
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 12)})

local inner = new("Frame", {
    Parent = window,
    Size = UDim2.new(1, -12, 1, -12),
    Position = UDim2.new(0,6,0,6),
    BackgroundColor3 = Color3.fromRGB(240,200,120),
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    ZIndex = 3,
})
new("UICorner", {Parent = inner, CornerRadius = UDim.new(0, 10)})

-- Sidebar (left)
local sidebar = new("Frame", {
    Parent = inner,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0,0,0,0),
    BackgroundColor3 = Color3.fromRGB(180,110,30),
    BackgroundTransparency = 0.08,
    ZIndex = 4,
})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,8)})

-- Sidebar header + hex logo
local sideHeader = new("Frame", {Parent = sidebar, Size = UDim2.new(1,0,0,92), BackgroundTransparency = 1})
local logoOuter = new("Frame", {
    Parent = sideHeader,
    Size = UDim2.new(0,56,0,56),
    Position = UDim2.new(0,16,0,18),
    BackgroundColor3 = Color3.fromRGB(255,215,120),
    BorderSizePixel = 0,
    ZIndex = 5,
})
new("UICorner", {Parent = logoOuter, CornerRadius = UDim.new(1,0)})
-- hex (approx) using ImageLabel with custom shaped image would be better; here we use small square and rotate to give hex-ish feel
local hex = new("Frame", {
    Parent = logoOuter,
    Size = UDim2.new(0.64,0,0.64,0),
    Position = UDim2.new(0.18,0,0.18,0),
    BackgroundColor3 = Color3.fromRGB(195,115,30),
    ZIndex = 6,
})
new("UICorner", {Parent = hex, CornerRadius = UDim.new(0,6)})

local titleLabel = new("TextLabel", {
    Parent = sideHeader,
    Size = UDim2.new(1, -92, 0, 56),
    Position = UDim2.new(0, 84, 0, 24),
    BackgroundTransparency = 1,
    Text = "Keaby",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(35,20,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
})

-- Sidebar menu
local menu = new("Frame", {Parent = sidebar, Size = UDim2.new(1, -24, 1, -120), Position = UDim2.new(0,12,0,120), BackgroundTransparency = 1})
local menuLayout = new("UIListLayout", {Parent = menu, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
menuLayout.Padding = UDim.new(0,8)
local function makeSidebarButton(txt, order)
    local b = new("TextButton", {
        Parent = menu,
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Color3.fromRGB(240,200,100),
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Text = txt,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(40,20,0),
        AutoButtonColor = false,
        ZIndex = 6,
    })
    new("UICorner", {Parent = b, CornerRadius = UDim.new(0,8)})
    b.LayoutOrder = order or 1
    return b
end
local mainBtn = makeSidebarButton("Main", 1)

-- Indicator bar
local indicator = new("Frame", {Parent = sidebar, Size = UDim2.new(0,6,0,48), Position = UDim2.new(0,6,0,120), BackgroundColor3 = Color3.fromRGB(110,55,6), ZIndex = 7})
new("UICorner", {Parent = indicator, CornerRadius = UDim.new(0,4)})

-- Top header controls (drag + minimize + close)
local headerBar = new("Frame", {Parent = inner, Size = UDim2.new(1, -220, 0, 52), Position = UDim2.new(0, 220, 0, 6), BackgroundTransparency = 1, ZIndex = 6})
local dragArea = new("Frame", {Parent = headerBar, Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1})
local btnMin = new("TextButton", {
    Parent = headerBar,
    Size = UDim2.new(0,36,0,32),
    Position = UDim2.new(1, -86, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(250,210,100),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(40,20,0),
    ZIndex = 7,
})
new("UICorner", {Parent = btnMin, CornerRadius = UDim.new(0,6)})
local btnClose = new("TextButton", {
    Parent = headerBar,
    Size = UDim2.new(0,36,0,32),
    Position = UDim2.new(1, -40, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(200,80,60),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
    ZIndex = 7,
})
new("UICorner", {Parent = btnClose, CornerRadius = UDim.new(0,6)})

-- Content panel (right)
local content = new("Frame", {
    Parent = inner,
    Size = UDim2.new(1, -240, 1, -22),
    Position = UDim2.new(0, 220, 0, 14),
    BackgroundColor3 = Color3.fromRGB(255,245,220),
    BackgroundTransparency = 0.24,
    BorderSizePixel = 0,
    ZIndex = 6,
})
new("UICorner", {Parent = content, CornerRadius = UDim.new(0, 10)})

local pageTitle = new("TextLabel", {Parent = content, Size = UDim2.new(1, -24, 0, 30), Position = UDim2.new(0,12,0,8), BackgroundTransparency = 1, Text = "Main", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(45,20,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
local pageSub = new("TextLabel", {Parent = content, Size = UDim2.new(1, -24, 0, 18), Position = UDim2.new(0,12,0,40), BackgroundTransparency = 1, Text = "Auto Fishing features", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(70,35,10), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})

local scrollFrame = new("ScrollingFrame", {
    Parent = content,
    Size = UDim2.new(1, -24, 1, -86),
    Position = UDim2.new(0,12,0,66),
    BackgroundTransparency = 1,
    ScrollBarThickness = 8,
    ZIndex = 7,
})
local scrollLayout = new("UIListLayout", {Parent = scrollFrame, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})
scrollLayout.Padding = UDim.new(0,12)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)

-- UI helpers: panel, toggle, slider
local function makePanel(title)
    local p = new("Frame", {Parent = scrollFrame, Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = Color3.fromRGB(255,245,220), BackgroundTransparency = 0.14, BorderSizePixel = 0, ZIndex = 8})
    new("UICorner", {Parent = p, CornerRadius = UDim.new(0,8)})
    local ttl = new("TextLabel", {Parent = p, Size = UDim2.new(1, -24, 0, 28), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamSemibold, TextSize = 15, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9})
    return p
end

local function createToggle(parent, label, default, callback)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1, -24, 0, 44), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new("TextButton", {Parent = f, Size = UDim2.new(0,60,0,30), Position = UDim2.new(1,-72,0.5,-15), BackgroundColor3 = default and Color3.fromRGB(255,200,80) or Color3.fromRGB(220,220,220), Text = default and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(40,20,0), ZIndex = 9})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255,200,80) or Color3.fromRGB(220,220,220)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    return f
end

local function createSlider(parent, labelText, min, max, default, onChange)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1, -24, 0, 56), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = string.format("%s: %.2fs", labelText, default), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left})
    local barBg = new("Frame", {Parent = f, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,30), BackgroundColor3 = Color3.fromRGB(200,120,30), BackgroundTransparency = 0.22, BorderSizePixel = 0})
    new("UICorner", {Parent = barBg, CornerRadius = UDim.new(1,0)})
    local fill = new("Frame", {Parent = barBg, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = Color3.fromRGB(255,205,85), BorderSizePixel = 0})
    new("UICorner", {Parent = fill, CornerRadius = UDim.new(1,0)})
    local dragging = false
    local function updateFromPos(absX)
        local rel = math.clamp((absX - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X,1), 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = string.format("%s: %.2fs", labelText, val)
        pcall(onChange, val)
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromPos(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromPos(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
        end
    end)
    return f
end

-- store loaded modules/features
local loadedFeatures = { Instant = {mod=nil, inst=nil}, Instant2X = {mod=nil, inst=nil} }

-- Build panels
local panelInstant = makePanel("Instant Fishing")
panelInstant.LayoutOrder = 1
panelInstant.Size = UDim2.new(1,0,0,220)
local instantToggle = createToggle(panelInstant, "Enable Instant Fishing", false, function(enabled)
    if enabled then
        if not loadedFeatures.Instant.mod then
            local mod, err = safeLoadFeature("Instant.lua")
            if not mod then warn("Keaby: failed load Instant.lua", err); return end
            loadedFeatures.Instant.mod = mod
        end
        local mod = loadedFeatures.Instant.mod
        mod.Settings = mod.Settings or {}
        mod.Settings.HookDelay = panelInstant._hookVal or mod.Settings.HookDelay or 0.06
        mod.Settings.FishingDelay = panelInstant._fishVal or mod.Settings.FishingDelay or 0.12
        mod.Settings.CancelDelay = panelInstant._cancelVal or mod.Settings.CancelDelay or 0.05
        loadedFeatures.Instant.inst = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant.inst and loadedFeatures.Instant.inst.Stop then pcall(loadedFeatures.Instant.inst.Stop, loadedFeatures.Instant.inst) end
    end
end)
local hookSlider = createSlider(panelInstant, "Hook Delay", 0.01, 0.25, 0.06, function(v) panelInstant._hookVal = v end)
hookSlider.LayoutOrder = 2
local fishSlider = createSlider(panelInstant, "Fishing Delay", 0.05, 1.0, 0.12, function(v) panelInstant._fishVal = v end)
fishSlider.LayoutOrder = 3
local cancelSlider = createSlider(panelInstant, "Cancel Delay", 0.01, 0.25, 0.05, function(v) panelInstant._cancelVal = v end)
cancelSlider.LayoutOrder = 4

local panel2x = makePanel("Instant 2x Speed")
panel2x.LayoutOrder = 2
panel2x.Size = UDim2.new(1,0,0,180)
local twoToggle = createToggle(panel2x, "Enable Instant 2x Speed", false, function(enabled)
    if enabled then
        if not loadedFeatures.Instant2X.mod then
            local mod, err = safeLoadFeature("Instant2Xspeed.lua")
            if not mod then warn("Keaby: failed load Instant2Xspeed.lua", err); return end
            loadedFeatures.Instant2X.mod = mod
        end
        local mod = loadedFeatures.Instant2X.mod
        mod.Settings = mod.Settings or {}
        mod.Settings.FishingDelay = panel2x._fishVal or mod.Settings.FishingDelay or 0.3
        mod.Settings.CancelDelay = panel2x._cancelVal or mod.Settings.CancelDelay or 0.05
        loadedFeatures.Instant2X.inst = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant2X.inst and loadedFeatures.Instant2X.inst.Stop then pcall(loadedFeatures.Instant2X.inst.Stop, loadedFeatures.Instant2X.inst) end
    end
end)
local twoFish = createSlider(panel2x, "Fishing Delay", 0.0, 1.0, 0.3, function(v) panel2x._fishVal = v end)
twoFish.LayoutOrder = 2
local twoCancel = createSlider(panel2x, "Cancel Delay", 0.01, 0.2, 0.05, function(v) panel2x._cancelVal = v end)
twoCancel.LayoutOrder = 3

-- add panels into scrollFrame (they were parented when created)
local function updateCanvas()
    local total = 0
    for _,c in ipairs(scrollFrame:GetChildren()) do
        if c:IsA("Frame") then
            total = total + c.AbsoluteSize.Y + scrollLayout.Padding.Offset
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0, total + 16)
end
-- small delay to compute sizes
spawn(function() wait(0.12) updateCanvas() end)

-- sidebar button action
mainBtn.MouseButton1Click:Connect(function()
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator:TweenPosition(UDim2.new(0,6,0,targetY), "Out", "Quad", 0.18, true)
    pageTitle.Text = "Main"
    pageSub.Text = "Auto Fishing features"
end)

-- window dragging
do
    local dragging = false
    local dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)
end

-- resizer bottom-right
local resizer = new("ImageButton", {Parent = window, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -22, 1, -22), BackgroundColor3 = Color3.fromRGB(230,160,40), ZIndex = 9, AutoButtonColor = false})
new("UICorner", {Parent = resizer, CornerRadius = UDim.new(0,4)})
local resizing = false
local startSize, startMouse
resizer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        startSize = window.Size
        startMouse = input.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startMouse
        local newW = math.clamp(startSize.X.Offset + delta.X, 380, 1400)
        local newH = math.clamp(startSize.Y.Offset + delta.Y, 220, 1000)
        window.Size = UDim2.new(0, newW, 0, newH)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if resizing then resizing = false end
end)

-- minimize behavior: hide window, disable blocker, show draggable hex icon at left middle
local minimized = false
local icon -- will hold hex icon
local iconDrag = {dragging=false, startMouse=Vector2.new(), startPos=UDim2.new()}
local savedWindowPos, savedWindowSize
local function createMinIcon()
    if icon and icon.Parent then icon:Destroy() end
    icon = new("ImageButton", {
        Parent = screenGui,
        Name = "KeabyMinIcon",
        Size = UDim2.new(0,56,0,56),
        Position = UDim2.new(0, 12, 0.5, -28), -- default left middle
        BackgroundColor3 = Color3.fromRGB(255,220,120),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 50,
    })
    new("UICorner", {Parent = icon, CornerRadius = UDim.new(1,0)})
    -- inner hex visual
    local innerHex = new("Frame", {Parent = icon, Size = UDim2.new(0.66,0,0.66,0), Position = UDim2.new(0.17,0,0.17,0), BackgroundColor3 = Color3.fromRGB(200,120,36)})
    new("UICorner", {Parent = innerHex, CornerRadius = UDim.new(0,6)})
    -- shadow / ring
    local ring = new("Frame", {Parent = icon, Size = UDim2.new(1.08,0,1.08,0), Position = UDim2.new(-0.04,0,-0.04,0), BackgroundTransparency = 1})
    ring.ZIndex = 49

    -- click to restore
    icon.MouseButton1Click:Connect(function()
        if minimized then
            -- restore
            icon.Visible = false
            -- show window and re-enable modal
            for _,c in pairs(inner:GetChildren()) do c.Visible = true end
            window.Visible = true
            blocker.Active = true
            blocker.BackgroundTransparency = 1
            -- restore position & size if exists
            if savedWindowPos then window.Position = savedWindowPos end
            if savedWindowSize then window.Size = savedWindowSize end
            minimized = false
        end
    end)

    -- drag logic for icon
    icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDrag.dragging = true
            iconDrag.startMouse = input.Position
            iconDrag.startPos = icon.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if iconDrag.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - iconDrag.startMouse
            local newX = iconDrag.startPos.X.Offset + delta.X
            local newY = iconDrag.startPos.Y.Offset + delta.Y
            -- clamp to screen bounds
            local screenW = workspace.CurrentCamera.ViewportSize.X
            local screenH = workspace.CurrentCamera.ViewportSize.Y
            newX = math.clamp(newX, 6, screenW - icon.AbsoluteSize.X - 6)
            newY = math.clamp(newY, 6, screenH - icon.AbsoluteSize.Y - 6)
            icon.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if iconDrag.dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            iconDrag.dragging = false
        end
    end)
end

btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        -- save pos & size
        savedWindowPos = window.Position
        savedWindowSize = window.Size
        -- hide window content completely
        window.Visible = false
        -- disable blocker so background usable
        blocker.Active = false
        -- create min icon if not existing
        createMinIcon()
        icon.Visible = true
        minimized = true
    else
        -- restore (shouldn't happen via button when hidden, but safe)
        if icon then icon.Visible = false end
        for _,c in pairs(inner:GetChildren()) do c.Visible = true end
        window.Visible = true
        blocker.Active = true
        minimized = false
    end
end)

-- close: stop modules and destroy gui
btnClose.MouseButton1Click:Connect(function()
    if loadedFeatures.Instant.inst and loadedFeatures.Instant.inst.Stop then pcall(loadedFeatures.Instant.inst.Stop, loadedFeatures.Instant.inst) end
    if loadedFeatures.Instant2X.inst and loadedFeatures.Instant2X.inst.Stop then pcall(loadedFeatures.Instant2X.inst.Stop, loadedFeatures.Instant2X.inst) end
    screenGui:Destroy()
end)

-- ensure blocker active when window visible (initial)
blocker.Active = true
blocker.BackgroundTransparency = 1

-- Resizer inside content (optional visual)
local resizer2 = new("Frame", {Parent = window, Size = UDim2.new(0,12,0,12), Position = UDim2.new(1,-16,1,-16), BackgroundTransparency = 1, ZIndex = 9})
resizer2.InputBegan:Connect(function() end) -- placeholder

-- ensure scroll canvas size on resize / content changes
local function recalcCanvas()
    task.wait(0.05)
    local total = 0
    for _,c in ipairs(scrollFrame:GetChildren()) do
        if c:IsA("Frame") then
            total = total + c.AbsoluteSize.Y + scrollLayout.Padding.Offset
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0, math.max(total + 16, 1))
end
-- run recalc after small delays when needed
spawn(function() wait(0.12) recalcCanvas() end)
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcCanvas)

-- Initial indicator alignment
spawn(function() wait(0.06)
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator.Position = UDim2.new(0,6,0,targetY)
end)

print("Keaby GUI v2.1 loaded — honey theme, minimize icon ready")

return screenGui
