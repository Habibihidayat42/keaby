-- KeabyGUI.lua v2.2
-- Honey flat matte theme, fixed sliders, toggles call module Start/Stop, minimize -> draggable bee emote icon
-- Place this file outside FungsiKeaby and make sure FungsiKeaby/Instant.lua and Instant2Xspeed.lua exist in repo or local files.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Fallback GitHub raw base (used only if readfile/isfile not available)
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- Safe loader: try local file then HttpGet
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
    if not code then return nil, "Keaby: failed to fetch " .. filename end
    local fn, err = loadstring(code)
    if not fn then return nil, err end
    local ok2, result = pcall(fn)
    if not ok2 then return nil, result end
    return result
end

-- quick instance maker
local function new(class, props)
    local i = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then i.Parent = v else i[k] = v end
        end
    end
    return i
end

-- ensure PlayerGui and remove old GUI
local playerGui = localPlayer:WaitForChild("PlayerGui")
for _,c in ipairs(playerGui:GetChildren()) do
    if c.Name == "KeabyGUI" then c:Destroy() end
end

local screenGui = new("ScreenGui", {Name = "KeabyGUI", ResetOnSpawn = false, Parent = playerGui})
screenGui.IgnoreGuiInset = true

-- Modal blocker (active only when main window shown)
local blocker = new("Frame", {
    Parent = screenGui,
    Size = UDim2.fromScale(1,1),
    Position = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
    Active = true, -- will toggle
    ZIndex = 1,
})

-- Main window
local window = new("Frame", {
    Parent = screenGui,
    Name = "KeabyWindow",
    Size = UDim2.new(0,760,0,440),
    Position = UDim2.new(0.5,-380,0.5,-220),
    BackgroundColor3 = Color3.fromRGB(200,120,30),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0,14)})

local inner = new("Frame", {
    Parent = window,
    Size = UDim2.new(1,-12,1,-12),
    Position = UDim2.new(0,6,0,6),
    BackgroundColor3 = Color3.fromRGB(240,200,120),
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    ZIndex = 3,
})
new("UICorner", {Parent = inner, CornerRadius = UDim.new(0,12)})

-- Sidebar
local sidebar = new("Frame", {
    Parent = inner,
    Size = UDim2.new(0,200,1,0),
    Position = UDim2.new(0,0,0,0),
    BackgroundColor3 = Color3.fromRGB(180,110,30),
    BackgroundTransparency = 0.06,
    ZIndex = 4,
})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,10)})

-- Sidebar header with hexagon placeholder
local sideHeader = new("Frame", {Parent = sidebar, Size = UDim2.new(1,0,0,96), BackgroundTransparency = 1})
local logoOuter = new("Frame", {Parent = sideHeader, Size = UDim2.new(0,60,0,60), Position = UDim2.new(0,16,0,18), BackgroundColor3 = Color3.fromRGB(255,215,120), BorderSizePixel = 0, ZIndex = 5})
new("UICorner", {Parent = logoOuter, CornerRadius = UDim.new(1,0)})
local hex = new("Frame", {Parent = logoOuter, Size = UDim2.new(0.66,0,0.66,0), Position = UDim2.new(0.17,0,0.17,0), BackgroundColor3 = Color3.fromRGB(200,120,36)})
new("UICorner", {Parent = hex, CornerRadius = UDim.new(0,8)})
local titleLabel = new("TextLabel", {Parent = sideHeader, Size = UDim2.new(1,-92,0,56), Position = UDim2.new(0,84,0,22), BackgroundTransparency = 1, Text = "Keaby", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(35,20,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})

-- Sidebar menu area
local menu = new("Frame", {Parent = sidebar, Size = UDim2.new(1,-24,1,-120), Position = UDim2.new(0,12,0,120), BackgroundTransparency = 1})
local menuLayout = new("UIListLayout", {Parent = menu, Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder})
menuLayout.Padding = UDim.new(0,10)

local function makeSidebarButton(txt, order)
    local b = new("TextButton", {
        Parent = menu,
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Color3.fromRGB(245,200,95),
        BackgroundTransparency = 0.06,
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
local indicator = new("Frame", {Parent = sidebar, Size = UDim2.new(0,6,0,48), Position = UDim2.new(0,6,0,120), BackgroundColor3 = Color3.fromRGB(110,55,6), ZIndex = 7})
new("UICorner", {Parent = indicator, CornerRadius = UDim.new(0,4)})

-- Top header controls
local headerBar = new("Frame", {Parent = inner, Size = UDim2.new(1,-220,0,56), Position = UDim2.new(0,220,0,6), BackgroundTransparency = 1, ZIndex = 6})
local dragArea = new("Frame", {Parent = headerBar, Size = UDim2.new(1,-120,1,0), BackgroundTransparency = 1})
local btnMin = new("TextButton", {Parent = headerBar, Size = UDim2.new(0,38,0,34), Position = UDim2.new(1,-90,0.5,-17), BackgroundColor3 = Color3.fromRGB(250,210,100), Text = "—", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(40,20,0), ZIndex = 7})
new("UICorner", {Parent = btnMin, CornerRadius = UDim.new(0,8)})
local btnClose = new("TextButton", {Parent = headerBar, Size = UDim2.new(0,38,0,34), Position = UDim2.new(1,-44,0.5,-17), BackgroundColor3 = Color3.fromRGB(200,80,60), Text = "✕", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255,255,255), ZIndex = 7})
new("UICorner", {Parent = btnClose, CornerRadius = UDim.new(0,8)})

-- Content panel
local content = new("Frame", {Parent = inner, Size = UDim2.new(1,-244,1,-24), Position = UDim2.new(0,220,0,12), BackgroundColor3 = Color3.fromRGB(255,245,220), BackgroundTransparency = 0.24, BorderSizePixel = 0, ZIndex = 6})
new("UICorner", {Parent = content, CornerRadius = UDim.new(0,10)})
local pageTitle = new("TextLabel", {Parent = content, Size = UDim2.new(1,-24,0,32), Position = UDim2.new(0,12,0,8), BackgroundTransparency = 1, Text = "Main", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = Color3.fromRGB(45,20,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
local pageSub = new("TextLabel", {Parent = content, Size = UDim2.new(1,-24,0,18), Position = UDim2.new(0,12,0,44), BackgroundTransparency = 1, Text = "Auto Fishing features", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(70,35,10), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})

local scrollFrame = new("ScrollingFrame", {Parent = content, Size = UDim2.new(1,-24,1,-90), Position = UDim2.new(0,12,0,72), BackgroundTransparency = 1, ScrollBarThickness = 8, ZIndex = 7})
local scrollLayout = new("UIListLayout", {Parent = scrollFrame, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})
scrollLayout.Padding = UDim.new(0,12)

-- helpers
local function makePanel(title)
    local p = new("Frame", {Parent = scrollFrame, Size = UDim2.new(1,0,0,220), BackgroundColor3 = Color3.fromRGB(255,245,220), BackgroundTransparency = 0.14, BorderSizePixel = 0, ZIndex = 8})
    new("UICorner", {Parent = p, CornerRadius = UDim.new(0,10)})
    local ttl = new("TextLabel", {Parent = p, Size = UDim2.new(1,-24,0,28), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamSemibold, TextSize = 15, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9})
    return p
end

local function createToggle(parent, label, default, callback)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,-24,0,44), BackgroundTransparency = 1, ZIndex = 9})
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(0.7,0,1,0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new("TextButton", {Parent = f, Size = UDim2.new(0,64,0,30), Position = UDim2.new(1,-80,0.5,-15), BackgroundColor3 = default and Color3.fromRGB(255,200,80) or Color3.fromRGB(210,210,210), Text = default and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(40,20,0), ZIndex = 9})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255,200,80) or Color3.fromRGB(210,210,210)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    return f, function() return state end, btn
end

local function createSlider(parent, labelText, min, max, default, onChange)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,-24,0,56), BackgroundTransparency = 1, ZIndex = 9})
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = string.format("%s: %.2fs", labelText, default), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(40,20,0), TextXAlignment = Enum.TextXAlignment.Left})
    local barBg = new("Frame", {Parent = f, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,32), BackgroundColor3 = Color3.fromRGB(200,120,30), BackgroundTransparency = 0.18, BorderSizePixel = 0})
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
    return f, function(v)
        -- programmatically set slider fill/label
        local rel = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(rel,0,1,0)
        lbl.Text = string.format("%s: %.2fs", labelText, v)
        pcall(onChange, v)
    end
end

-- feature module storage
local loaded = { Instant = {mod=nil, inst=nil}, Instant2X = {mod=nil, inst=nil} }

-- create feature panels
local pnlInstant = makePanel("Instant Fishing")
pnlInstant.LayoutOrder = 1
pnlInstant.Size = UDim2.new(1,0,0,220)

local toggleFrameI, getStateI, toggleBtnI = createToggle(pnlInstant, "Enable Instant Fishing", false, function(enabled)
    -- toggle callback
    if enabled then
        if not loaded.Instant.mod then
            local mod, err = safeLoadFeature("Instant.lua")
            if not mod then warn("Keaby: failed loading Instant.lua", err); -- flip button back safely
                toggleBtnI.BackgroundColor3 = Color3.fromRGB(210,210,210); toggleBtnI.Text = "OFF"; return end
            loaded.Instant.mod = mod
        end
        local mod = loaded.Instant.mod
        mod.Settings = mod.Settings or {}
        -- apply current slider values if present
        mod.Settings.HookDelay = pnlInstant._hookVal or mod.Settings.HookDelay or 0.06
        mod.Settings.FishingDelay = pnlInstant._fishVal or mod.Settings.FishingDelay or 0.12
        mod.Settings.CancelDelay = pnlInstant._cancelVal or mod.Settings.CancelDelay or 0.05
        loaded.Instant.inst = mod
        -- start if method available
        if type(mod.Start) == "function" then pcall(mod.Start, mod) end
    else
        if loaded.Instant.inst and type(loaded.Instant.inst.Stop) == "function" then pcall(loaded.Instant.inst.Stop, loaded.Instant.inst) end
    end
end)

-- Ensure sliders are visible by setting LayoutOrder and Parent set by creator
local hookSlider, setHookVal = createSlider(pnlInstant, "Hook Delay", 0.01, 0.25, 0.06, function(v)
    pnlInstant._hookVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.HookDelay = v end
end)
hookSlider.LayoutOrder = 2

local fishSlider, setFishVal = createSlider(pnlInstant, "Fishing Delay", 0.05, 1.0, 0.12, function(v)
    pnlInstant._fishVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.FishingDelay = v end
end)
fishSlider.LayoutOrder = 3

local cancelSlider, setCancelVal = createSlider(pnlInstant, "Cancel Delay", 0.01, 0.25, 0.05, function(v)
    pnlInstant._cancelVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.CancelDelay = v end
end)
cancelSlider.LayoutOrder = 4

-- Instant 2x
local pnl2x = makePanel("Instant 2x Speed")
pnl2x.LayoutOrder = 2
pnl2x.Size = UDim2.new(1,0,0,180)

local toggleFrame2, getState2, toggleBtn2 = createToggle(pnl2x, "Enable Instant 2x Speed", false, function(enabled)
    if enabled then
        if not loaded.Instant2X.mod then
            local mod, err = safeLoadFeature("Instant2Xspeed.lua")
            if not mod then warn("Keaby: failed loading Instant2Xspeed.lua", err); toggleBtn2.BackgroundColor3 = Color3.fromRGB(210,210,210); toggleBtn2.Text = "OFF"; return end
            loaded.Instant2X.mod = mod
        end
        local mod = loaded.Instant2X.mod
        mod.Settings = mod.Settings or {}
        mod.Settings.FishingDelay = pnl2x._fishVal or mod.Settings.FishingDelay or 0.3
        mod.Settings.CancelDelay = pnl2x._cancelVal or mod.Settings.CancelDelay or 0.05
        loaded.Instant2X.inst = mod
        if type(mod.Start) == "function" then pcall(mod.Start, mod) end
    else
        if loaded.Instant2X.inst and type(loaded.Instant2X.inst.Stop) == "function" then pcall(loaded.Instant2X.inst.Stop, loaded.Instant2X.inst) end
    end
end)

local twoFish, setTwoFish = createSlider(pnl2x, "Fishing Delay", 0.0, 1.0, 0.3, function(v)
    pnl2x._fishVal = v
    if loaded.Instant2X.mod then loaded.Instant2X.mod.Settings = loaded.Instant2X.mod.Settings or {}; loaded.Instant2X.mod.Settings.FishingDelay = v end
end)
twoFish.LayoutOrder = 2

local twoCancel, setTwoCancel = createSlider(pnl2x, "Cancel Delay", 0.01, 0.2, 0.05, function(v)
    pnl2x._cancelVal = v
    if loaded.Instant2X.mod then loaded.Instant2X.mod.Settings = loaded.Instant2X.mod.Settings or {}; loaded.Instant2X.mod.Settings.CancelDelay = v end
end)
twoCancel.LayoutOrder = 3

-- update scroll canvas
local function recalcCanvas()
    task.wait(0.03)
    local total = 0
    for _,c in ipairs(scrollFrame:GetChildren()) do
        if c:IsA("Frame") then
            total = total + c.AbsoluteSize.Y + scrollLayout.Padding.Offset
        end
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0, math.max(total + 16, 1))
end
spawn(function() wait(0.08) recalcCanvas() end)
scrollFrame:GetPropertyChangedSignal("CanvasSize"):Connect(function() end)
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcCanvas)

-- sidebar action
mainBtn.MouseButton1Click:Connect(function()
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator:TweenPosition(UDim2.new(0,6,0,targetY), "Out", "Quad", 0.18, true)
    pageTitle.Text = "Main"
    pageSub.Text = "Auto Fishing features"
end)

-- dragging the whole window by dragArea
do
    local dragging, dragStart, startPos = false, nil, nil
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

-- resizer (bottom-right)
local resizer = new("ImageButton", {Parent = window, Size = UDim2.new(0,18,0,18), Position = UDim2.new(1,-26,1,-26), BackgroundColor3 = Color3.fromRGB(230,160,40), AutoButtonColor = false, ZIndex = 9})
new("UICorner", {Parent = resizer, CornerRadius = UDim.new(0,4)})
local resizing, startSize, startMouse = false, nil, nil
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

-- minimize logic -> hide window & create draggable bee emoji icon on left middle
local minimized = false
local savedPos, savedSize = nil, nil
local minIcon = nil
local iconDrag = {dragging=false, startMouse=Vector2.new(), startPos=UDim2.new()}

local function createMinIcon()
    if minIcon and minIcon.Parent then minIcon:Destroy() end
    minIcon = new("TextButton", {
        Parent = screenGui,
        Name = "KeabyMinIcon",
        Size = UDim2.new(0,56,0,56),
        Position = UDim2.new(0,12,0.5,-28),
        BackgroundColor3 = Color3.fromRGB(255,220,120),
        BorderSizePixel = 0,
        Text = "🐝",
        Font = Enum.Font.SourceSans,
        TextSize = 28,
        ZIndex = 60,
        AutoButtonColor = false,
    })
    new("UICorner", {Parent = minIcon, CornerRadius = UDim.new(1,0)})
    -- click to restore
    minIcon.MouseButton1Click:Connect(function()
        if minimized then
            -- restore
            if minIcon then minIcon.Visible = false end
            window.Position = savedPos or window.Position
            window.Size = savedSize or window.Size
            window.Visible = true
            inner.Visible = true
            blocker.Active = true
            blocker.BackgroundTransparency = 1
            minimized = false
            -- ensure icon remains (hidden) - user can re-minimize later
        end
    end)
    -- drag icon
    minIcon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            iconDrag.dragging = true
            iconDrag.startMouse = input.Position
            iconDrag.startPos = minIcon.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if iconDrag.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - iconDrag.startMouse
            local newX = iconDrag.startPos.X.Offset + delta.X
            local newY = iconDrag.startPos.Y.Offset + delta.Y
            local screenW = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1280
            local screenH = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 720
            newX = math.clamp(newX, 6, screenW - minIcon.AbsoluteSize.X - 6)
            newY = math.clamp(newY, 6, screenH - minIcon.AbsoluteSize.Y - 6)
            minIcon.Position = UDim2.new(0, newX, 0, newY)
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
        savedPos = window.Position
        savedSize = window.Size
        window.Visible = false
        blocker.Active = false
        createMinIcon()
        minimized = true
    else
        -- restore (shouldn't normally be reachable because btn is hidden)
        if minIcon then minIcon.Visible = false end
        window.Visible = true
        blocker.Active = true
        minimized = false
    end
end)

-- close cleanly (stop modules if running)
btnClose.MouseButton1Click:Connect(function()
    -- stop modules
    if loaded.Instant.inst and type(loaded.Instant.inst.Stop) == "function" then pcall(loaded.Instant.inst.Stop, loaded.Instant.inst) end
    if loaded.Instant2X.inst and type(loaded.Instant2X.inst.Stop) == "function" then pcall(loaded.Instant2X.inst.Stop, loaded.Instant2X.inst) end
    if minIcon and minIcon.Parent then minIcon:Destroy() end
    screenGui:Destroy()
end)

-- ensure blocker initially active
blocker.Active = true
blocker.BackgroundTransparency = 1

-- initial indicator align
spawn(function()
    task.wait(0.06)
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator.Position = UDim2.new(0,6,0,targetY)
    recalcCanvas()
end)

-- expose for debugging if needed
print("Keaby GUI v2.2 loaded (flat matte honey).")

return screenGui
