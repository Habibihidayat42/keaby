-- KeabyGUI.lua
-- Keaby UI (Bee / Honey theme) — Sidebar fixed, Main page with Instant and Instant2X features
-- Compatible PC / Android / iOS. Modal-blocker prevents interacting with background.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- GitHub raw base (used as fallback if readfile/isfile unavailable)
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- safe loader: tries local file first, then Github raw via HttpGet
local function safeLoadFeature(filename)
    local code
    local ok, isfileFn = pcall(function() return isfile end)
    if ok and isfileFn and isfile(filename) then
        code = readfile(filename)
    else
        -- try HTTP raw
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

-- helper for creating instances
local function new(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then inst.Parent = v else inst[k] = v end
        end
    end
    return inst
end

-- Ensure PlayerGui
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Remove old Keaby GUI if present
for _,c in pairs(playerGui:GetChildren()) do
    if c.Name == "KeabyGUI" then c:Destroy() end
end

-- ScreenGui
local screenGui = new("ScreenGui", {Name = "KeabyGUI", ResetOnSpawn = false, Parent = playerGui})
screenGui.IgnoreGuiInset = true

-- Modal blocker so background UI isn't clickable
local blocker = new("Frame", {
    Parent = screenGui,
    Size = UDim2.fromScale(1,1),
    Position = UDim2.fromScale(0,0),
    BackgroundTransparency = 1,
    Active = true, -- captures input
    ZIndex = 1,
})

-- Main window container (center)
local window = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 720, 0, 420),
    Position = UDim2.new(0.5, -360, 0.5, -210),
    BackgroundColor3 = Color3.fromRGB(255, 244, 214), -- honey light
    BackgroundTransparency = 0.16,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 12)})
-- subtle shadow (Frame)
local shadow = new("ImageLabel", {
    Parent = window,
    Size = UDim2.new(1, 6, 1, 6),
    Position = UDim2.new(0, -3, 0, -3),
    BackgroundTransparency = 1,
    Image = "rbxassetid://0", -- no image but reserved
    ZIndex = 0,
})
shadow.Visible = false

-- inner container (content + sidebar)
local inner = new("Frame", {
    Parent = window,
    Size = UDim2.new(1, -10, 1, -10),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1,
    ZIndex = 3,
})
new("UICorner", {Parent = inner, CornerRadius = UDim.new(0, 10)})

-- Left sidebar
local sidebar = new("Frame", {
    Parent = inner,
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0,0,0,0),
    BackgroundColor3 = Color3.fromRGB(199,143,46), -- honey mid
    BackgroundTransparency = 0.08,
    ZIndex = 4,
})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0, 8)})
-- sidebar header
local sideHeader = new("Frame", {
    Parent = sidebar,
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundTransparency = 1,
})
local logoFrame = new("Frame", {
    Parent = sideHeader,
    Size = UDim2.new(0, 46, 0, 46),
    Position = UDim2.new(0, 12, 0, 12),
    BackgroundColor3 = Color3.fromRGB(255, 221, 121),
    ZIndex = 5,
})
new("UICorner", {Parent = logoFrame, CornerRadius = UDim.new(1,0)})
-- small hex inside logo
local hex = new("Frame", {
    Parent = logoFrame,
    Size = UDim2.new(0.7,0,0.7,0),
    Position = UDim2.new(0.15,0,0.15,0),
    BackgroundColor3 = Color3.fromRGB(204,126,34),
    BackgroundTransparency = 0,
})
new("UICorner", {Parent = hex, CornerRadius = UDim.new(0,6)})
local titleLabel = new("TextLabel", {
    Parent = sideHeader,
    Size = UDim2.new(1, -72, 1, 0),
    Position = UDim2.new(0, 68, 0, 18),
    BackgroundTransparency = 1,
    Text = "Keaby",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(35,20,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
})

-- sidebar menu (single fixed button: Main)
local menuFrame = new("Frame", {
    Parent = sidebar,
    Size = UDim2.new(1, -24, 1, -92),
    Position = UDim2.new(0, 12, 0, 92),
    BackgroundTransparency = 1,
    ZIndex = 5,
})
local uiList = new("UIListLayout", {Parent = menuFrame, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder})
uiList.Padding = UDim.new(0,8)

local function makeSidebarButton(text, order)
    local btn = new("TextButton", {
        Parent = menuFrame,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Color3.fromRGB(238,196,87),
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(40,20,0),
        ZIndex = 6,
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    btn.LayoutOrder = order or 1
    return btn
end

local mainBtn = makeSidebarButton("Main", 1)
-- highlight bar indicator
local indicator = new("Frame", {
    Parent = sidebar,
    Size = UDim2.new(0,6,0,48),
    Position = UDim2.new(0,6,0, 92),
    BackgroundColor3 = Color3.fromRGB(110,55,6),
    ZIndex = 6,
})
new("UICorner", {Parent = indicator, CornerRadius = UDim.new(0,4)})

-- Top right control (minimize & close buttons)
local headerBar = new("Frame", {
    Parent = inner,
    Size = UDim2.new(1, -210, 0, 44),
    Position = UDim2.new(0, 210, 0, 0),
    BackgroundTransparency = 1,
    ZIndex = 6,
})
local dragArea = new("Frame", {
    Parent = headerBar,
    Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
})
local btnMin = new("TextButton", {
    Parent = headerBar,
    Size = UDim2.new(0, 34, 0, 30),
    Position = UDim2.new(1, -78, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(250,220,120),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(40,20,0),
    ZIndex = 7,
})
new("UICorner", {Parent = btnMin, CornerRadius = UDim.new(0,6)})
local btnClose = new("TextButton", {
    Parent = headerBar,
    Size = UDim2.new(0, 34, 0, 30),
    Position = UDim2.new(1, -38, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(220,80,60),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
    ZIndex = 7,
})
new("UICorner", {Parent = btnClose, CornerRadius = UDim.new(0,6)})

-- Content area (right)
local content = new("Frame", {
    Parent = inner,
    Size = UDim2.new(1, -230, 1, -20),
    Position = UDim2.new(0, 220, 0, 10),
    BackgroundColor3 = Color3.fromRGB(255, 250, 236),
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    ZIndex = 5,
})
new("UICorner", {Parent = content, CornerRadius = UDim.new(0, 10)})

-- Title & description in content
local pageTitle = new("TextLabel", {
    Parent = content,
    Size = UDim2.new(1, -24, 0, 36),
    Position = UDim2.new(0, 12, 0, 10),
    BackgroundTransparency = 1,
    Text = "Main",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(50,23,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
})
local pageSubtitle = new("TextLabel", {
    Parent = content,
    Size = UDim2.new(1, -24, 0, 18),
    Position = UDim2.new(0, 12, 0, 42),
    BackgroundTransparency = 1,
    Text = "Auto Fishing features",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(60,30,10),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6,
})

-- scrollable area for features
local scrollFrame = new("ScrollingFrame", {
    Parent = content,
    Size = UDim2.new(1, -24, 1, -70),
    Position = UDim2.new(0, 12, 0, 66),
    BackgroundTransparency = 1,
    ScrollBarThickness = 8,
    ZIndex = 6,
})
local uiList2 = new("UIListLayout", {Parent = scrollFrame, Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder})
uiList2.Padding = UDim.new(0,12)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)

-- Common UI elements: panel with title
local function makePanel(title)
    local pnl = new("Frame", {
        Parent = scrollFrame,
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = Color3.fromRGB(255, 242, 205),
        BackgroundTransparency = 0.12,
        BorderSizePixel = 0,
        ZIndex = 7,
    })
    new("UICorner", {Parent = pnl, CornerRadius = UDim.new(0, 8)})
    local ttl = new("TextLabel", {
        Parent = pnl,
        Size = UDim2.new(1, -24, 0, 26),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamSemibold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(40,20,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    return pnl
end

-- Toggle creator
local function createToggle(parent, label, default, callback)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1, -24, 0, 44), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {
        Parent = f,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(40,20,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local btn = new("TextButton", {
        Parent = f,
        Size = UDim2.new(0, 56, 0, 28),
        Position = UDim2.new(1, -66, 0.5, -14),
        BackgroundColor3 = default and Color3.fromRGB(254,208,87) or Color3.fromRGB(220,220,220),
        Text = default and "ON" or "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(40,20,0),
        ZIndex = 8,
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(254,208,87) or Color3.fromRGB(220,220,220)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    return f, function() return state end
end

-- Slider creator (mobile-friendly)
local function createSlider(parent, labelText, min, max, default, onChange)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1, -24, 0, 56), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {
        Parent = f,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = string.format("%s: %.2fs", labelText, default),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(40,20,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local barBg = new("Frame", {
        Parent = f,
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0,0,0,30),
        BackgroundColor3 = Color3.fromRGB(205,150,50),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = barBg, CornerRadius = UDim.new(1,0)})
    local fill = new("Frame", {
        Parent = barBg,
        Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(254,205,80),
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = fill, CornerRadius = UDim.new(1,0)})
    local dragging = false
    local function updateFromPos(absX)
        local rel = math.clamp((absX - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = string.format("%s: %.2fs", labelText, val)
        pcall(onChange, val)
    end
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if dragging then dragging = false end
    end)
    return f
end

-- Feature modules storage
local loadedFeatures = {
    Instant = {module = nil, inst = nil},
    Instant2X = {module = nil, inst = nil},
}

-- Build panels for features
-- Instant Fishing Panel
local panelInstant = makePanel("Instant Fishing")
panelInstant.LayoutOrder = 1
panelInstant.Size = UDim2.new(1, 0, 0, 220)
-- inside layout
local vlistI = new("UIListLayout", {Parent = panelInstant, Padding = UDim.new(0,8)})
vlistI.Padding = UDim.new(0,8)
vlistI.SortOrder = Enum.SortOrder.LayoutOrder

-- toggle
local instantToggle, _ = createToggle(panelInstant, "Enable Instant Fishing", false, function(enabled)
    -- load module if enabling
    if enabled then
        if not loadedFeatures.Instant.module then
            local mod, err = safeLoadFeature("Instant.lua")
            if not mod then warn("Keaby: cannot load Instant.lua", err); return end
            loadedFeatures.Instant.module = mod
        end
        local mod = loadedFeatures.Instant.module
        mod.Settings = mod.Settings or {}
        -- ensure sliders exist and set defaults if missing
        mod.Settings.HookDelay = (panelInstant._hookVal or mod.Settings.HookDelay or 0.06)
        mod.Settings.FishingDelay = (panelInstant._fishVal or mod.Settings.FishingDelay or 0.12)
        mod.Settings.CancelDelay = (panelInstant._cancelVal or mod.Settings.CancelDelay or 0.05)
        loadedFeatures.Instant.inst = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant.inst and loadedFeatures.Instant.inst.Stop then pcall(loadedFeatures.Instant.inst.Stop, loadedFeatures.Instant.inst) end
    end
end)

-- Hook slider
local hookSlider = createSlider(panelInstant, "Hook Delay", 0.01, 0.25, 0.06, function(val) panelInstant._hookVal = val end)
hookSlider.LayoutOrder = 2
-- Fishing delay slider
local fishSlider = createSlider(panelInstant, "Fishing Delay", 0.05, 1.0, 0.12, function(val) panelInstant._fishVal = val end)
fishSlider.LayoutOrder = 3
-- Cancel delay slider
local cancelSlider = createSlider(panelInstant, "Cancel Delay", 0.01, 0.25, 0.05, function(val) panelInstant._cancelVal = val end)
cancelSlider.LayoutOrder = 4

-- Instant 2x Speed Panel
local panel2x = makePanel("Instant 2x Speed")
panel2x.LayoutOrder = 2
panel2x.Size = UDim2.new(1, 0, 0, 180)
local vlist2 = new("UIListLayout", {Parent = panel2x, Padding = UDim.new(0,8)})
vlist2.Padding = UDim.new(0,8)
vlist2.SortOrder = Enum.SortOrder.LayoutOrder

local twoXToggle, _ = createToggle(panel2x, "Enable Instant 2x Speed", false, function(enabled)
    if enabled then
        if not loadedFeatures.Instant2X.module then
            local mod, err = safeLoadFeature("Instant2Xspeed.lua")
            if not mod then warn("Keaby: cannot load Instant2Xspeed.lua", err); return end
            loadedFeatures.Instant2X.module = mod
        end
        local mod = loadedFeatures.Instant2X.module
        mod.Settings = mod.Settings or {}
        mod.Settings.FishingDelay = (panel2x._fishVal or mod.Settings.FishingDelay or 0.3)
        mod.Settings.CancelDelay = (panel2x._cancelVal or mod.Settings.CancelDelay or 0.05)
        loadedFeatures.Instant2X.inst = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant2X.inst and loadedFeatures.Instant2X.inst.Stop then pcall(loadedFeatures.Instant2X.inst.Stop, loadedFeatures.Instant2X.inst) end
    end
end)

local twoFishSlider = createSlider(panel2x, "Fishing Delay", 0.0, 1.0, 0.3, function(val) panel2x._fishVal = val end)
twoFishSlider.LayoutOrder = 2
local twoCancelSlider = createSlider(panel2x, "Cancel Delay", 0.01, 0.2, 0.05, function(val) panel2x._cancelVal = val end)
twoCancelSlider.LayoutOrder = 3

-- Add panels to scrollFrame (must parent already done), set CanvasSize updating
local function updateCanvas()
    local total = 0
    for _,child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            total = total + child.AbsoluteSize.Y + uiList2.Padding.Offset
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0, total + 12)
end

-- parent panels already to scrollFrame through makePanel; ensure layout updated
spawn(function()
    wait(0.1)
    updateCanvas()
end)

-- ensure panels are present (they are already)
-- But in case, parent panelInstant and panel2x explicitly (they were added through makePanel)
-- Done.

-- Sidebar interactions: mainBtn highlight and show "Main" (already)
mainBtn.MouseButton1Click:Connect(function()
    -- animate indicator to align with mainBtn
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator:TweenPosition(UDim2.new(0,6,0,targetY), "Out", "Quad", 0.18, true)
    -- highlight page text
    pageTitle.Text = "Main"
    pageSubtitle.Text = "Auto Fishing features"
end)

-- Dragging the whole window by dragArea
do
    local dragging, dragStart, startPos
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

-- Minimize & restore
local minimized = false
local savedPos, savedSize
btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        savedPos, savedSize = window.Position, window.Size
        window:TweenSizeAndPosition(UDim2.new(0, 64, 0, 64), UDim2.new(0, 10, 0, 10), "Out", "Quad", 0.18, true)
        -- hide content children except sidebar logo
        for _,c in pairs(inner:GetChildren()) do
            if c ~= sidebar then c.Visible = false end
        end
        minimized = true
    else
        window:TweenSizeAndPosition(savedSize or UDim2.new(0,720,0,420), savedPos or UDim2.new(0.5,-360,0.5,-210), "Out", "Quad", 0.18, true)
        for _,c in pairs(inner:GetChildren()) do c.Visible = true end
        minimized = false
    end
end)

-- Close: destroy GUI and stop features
btnClose.MouseButton1Click:Connect(function()
    -- stop running features if any
    if loadedFeatures.Instant.inst and loadedFeatures.Instant.inst.Stop then pcall(loadedFeatures.Instant.inst.Stop, loadedFeatures.Instant.inst) end
    if loadedFeatures.Instant2X.inst and loadedFeatures.Instant2X.inst.Stop then pcall(loadedFeatures.Instant2X.inst.Stop, loadedFeatures.Instant2X.inst) end
    screenGui:Destroy()
end)

-- Resizer (bottom-right corner)
local resizer = new("ImageButton", {
    Parent = window,
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -20, 1, -20),
    BackgroundTransparency = 0,
    BackgroundColor3 = Color3.fromRGB(236,180,80),
    Image = "",
    ZIndex = 9,
})
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
        local newW = math.clamp(startSize.X.Offset + delta.X, 380, 1200)
        local newH = math.clamp(startSize.Y.Offset + delta.Y, 220, 900)
        window.Size = UDim2.new(0, newW, 0, newH)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if resizing then resizing = false end
end)

-- Make sure blocker sits behind window content
blocker.ZIndex = 1
window.ZIndex = 2

-- Finalize layout: small debounce for canvas sizing
spawn(function()
    wait(0.12)
    updateCanvas()
end)

-- Print loaded
print("Keaby GUI loaded — honey theme, sidebar open, main page active")

-- return in case require() used
return screenGui
