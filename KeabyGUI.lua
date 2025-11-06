-- KeabyGUI_v2.4.lua
-- Keaby (Honey UI) v2.4 - flat matte oranye pekat, toggle fade animation, sliders fixed, auto-start features
-- Single-file. Place in executor and run. Requires internet if features not available locally.

-- Services & player
repeat task.wait() until game and game.GetService
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
repeat task.wait() until localPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Colors
local HONEY_PRIMARY = Color3.fromRGB(217,140,48) -- #D98C30 (oranye pekat hangat)
local HONEY_LIGHT = Color3.fromRGB(254,205,80)
local HONEY_BG = Color3.fromRGB(255,244,214)
local HONEY_MUTED = Color3.fromRGB(245,200,95)
local TEXT_DARK = Color3.fromRGB(40,20,0)

-- GitHub raw base (fallback)
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- safe loader: readfile/isfile first, else HttpGet
local function safeLoadFeature(filename)
    local code
    local ok, hasIsfile = pcall(function() return isfile end)
    if ok and hasIsfile and isfile(filename) then
        code = readfile(filename)
    else
        local suc, res = pcall(function() return game:HttpGet(GITHUB_RAW_BASE .. filename) end)
        if suc then code = res end
    end
    if not code then return nil, "failed to fetch "..filename end
    local fn, err = loadstring(code)
    if not fn then return nil, err end
    local ok2, result = pcall(fn)
    if not ok2 then return nil, result end
    return result
end

-- Instance helper
local function new(class, props)
    local inst = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then inst.Parent = v else inst[k] = v end
        end
    end
    return inst
end

-- cleanup previous
for _,c in ipairs(playerGui:GetChildren()) do
    if c.Name == "KeabyGUI" or c.Name == "KeabyMinIcon" then
        pcall(function() c:Destroy() end)
    end
end

-- ScreenGui
local screenGui = new("ScreenGui", {Name = "KeabyGUI", ResetOnSpawn = false, Parent = playerGui})
screenGui.IgnoreGuiInset = true

-- Modal blocker (captures input while GUI open)
local blocker = new("Frame", {Parent = screenGui, Size = UDim2.fromScale(1,1), Position = UDim2.new(0,0), BackgroundTransparency = 1, Active = true, ZIndex = 1})

-- Main window
local window = new("Frame", {
    Parent = screenGui,
    Name = "KeabyWindow",
    Size = UDim2.new(0,760,0,440),
    Position = UDim2.new(0.5,-380,0.5,-220),
    BackgroundColor3 = HONEY_PRIMARY,
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0,14)})

local inner = new("Frame", {
    Parent = window,
    Size = UDim2.new(1,-12,1,-12),
    Position = UDim2.new(0,6,0,6),
    BackgroundColor3 = HONEY_BG,
    BackgroundTransparency = 0.22,
    BorderSizePixel = 0,
    ZIndex = 3,
})
new("UICorner", {Parent = inner, CornerRadius = UDim.new(0,12)})

-- Sidebar
local sidebar = new("Frame", {Parent = inner, Size = UDim2.new(0,200,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(180,110,30), BackgroundTransparency = 0.06, ZIndex = 4})
new("UICorner", {Parent = sidebar, CornerRadius = UDim.new(0,10)})

local sideHeader = new("Frame", {Parent = sidebar, Size = UDim2.new(1,0,0,96), BackgroundTransparency = 1})
local logoOuter = new("Frame", {Parent = sideHeader, Size = UDim2.new(0,60,0,60), Position = UDim2.new(0,16,0,18), BackgroundColor3 = HONEY_LIGHT, BorderSizePixel = 0})
new("UICorner", {Parent = logoOuter, CornerRadius = UDim.new(1,0)})
local hex = new("Frame", {Parent = logoOuter, Size = UDim2.new(0.66,0,0.66,0), Position = UDim2.new(0.17,0,0.17,0), BackgroundColor3 = Color3.fromRGB(200,120,36)})
new("UICorner", {Parent = hex, CornerRadius = UDim.new(0,8)})
local titleLabel = new("TextLabel", {Parent = sideHeader, Size = UDim2.new(1,-92,0,56), Position = UDim2.new(0,84,0,22), BackgroundTransparency = 1, Text = "Keaby", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = TEXT_DARK, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6})

-- Sidebar menu
local menu = new("Frame", {Parent = sidebar, Size = UDim2.new(1,-24,1,-120), Position = UDim2.new(0,12,0,120), BackgroundTransparency = 1})
local menuLayout = new("UIListLayout", {Parent = menu, Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder})
menuLayout.Padding = UDim.new(0,10)

local function makeSidebarButton(txt, order)
    local b = new("TextButton", {
        Parent = menu,
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = HONEY_MUTED,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        Text = txt,
        Font = Enum.Font.GothamSemibold,
        TextSize = 15,
        TextColor3 = TEXT_DARK,
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

-- Header bar (drag area + controls)
local headerBar = new("Frame", {Parent = inner, Size = UDim2.new(1,-220,0,56), Position = UDim2.new(0,220,0,6), BackgroundTransparency = 1, ZIndex = 6})
local dragArea = new("Frame", {Parent = headerBar, Size = UDim2.new(1,-120,1,0), BackgroundTransparency = 1})
local btnMin = new("TextButton", {Parent = headerBar, Size = UDim2.new(0,38,0,34), Position = UDim2.new(1,-90,0.5,-17), BackgroundColor3 = HONEY_LIGHT, Text = "—", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = TEXT_DARK, ZIndex = 7})
new("UICorner", {Parent = btnMin, CornerRadius = UDim.new(0,8)})
local btnClose = new("TextButton", {Parent = headerBar, Size = UDim2.new(0,38,0,34), Position = UDim2.new(1,-44,0.5,-17), BackgroundColor3 = Color3.fromRGB(200,80,60), Text = "✕", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(255,255,255), ZIndex = 7})
new("UICorner", {Parent = btnClose, CornerRadius = UDim.new(0,8)})

-- Content
local content = new("Frame", {Parent = inner, Size = UDim2.new(1,-244,1,-24), Position = UDim2.new(0,220,0,12), BackgroundColor3 = Color3.fromRGB(255,245,220), BackgroundTransparency = 0.24, BorderSizePixel = 0, ZIndex = 6})
new("UICorner", {Parent = content, CornerRadius = UDim.new(0,10)})
local pageTitle = new("TextLabel", {Parent = content, Size = UDim2.new(1,-24,0,32), Position = UDim2.new(0,12,0,8), BackgroundTransparency = 1, Text = "Main", Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = TEXT_DARK, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})
local pageSub = new("TextLabel", {Parent = content, Size = UDim2.new(1,-24,0,18), Position = UDim2.new(0,12,0,44), BackgroundTransparency = 1, Text = "Auto Fishing features", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Color3.fromRGB(70,35,10), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 7})

local scrollFrame = new("ScrollingFrame", {Parent = content, Size = UDim2.new(1,-24,1,-90), Position = UDim2.new(0,12,0,72), BackgroundTransparency = 1, ScrollBarThickness = 8, ZIndex = 7})
local scrollLayout = new("UIListLayout", {Parent = scrollFrame, Padding = UDim.new(0,12), SortOrder = Enum.SortOrder.LayoutOrder})
scrollLayout.Padding = UDim.new(0,12)

-- makePanel helper
local function makePanel(title)
    local p = new("Frame", {Parent = scrollFrame, Size = UDim2.new(1,0,0,220), BackgroundColor3 = Color3.fromRGB(255,245,220), BackgroundTransparency = 0.14, BorderSizePixel = 0, ZIndex = 8})
    new("UICorner", {Parent = p, CornerRadius = UDim.new(0,10)})
    local ttl = new("TextLabel", {Parent = p, Size = UDim2.new(1,-24,0,28), Position = UDim2.new(0,12,0,12), BackgroundTransparency = 1, Text = title, Font = Enum.Font.GothamSemibold, TextSize = 15, TextColor3 = TEXT_DARK, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9})
    return p
end

-- Toggle with tween animation
local function createToggle(parent, label, default, callback)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,-24,0,52), BackgroundTransparency = 1, ZIndex = 9})
    f.LayoutOrder = parent.LayoutOrder and parent.LayoutOrder + 1 or 1
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(0.66,0,1,0), BackgroundTransparency = 1, Text = label, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = TEXT_DARK, TextXAlignment = Enum.TextXAlignment.Left})
    local btn = new("TextButton", {Parent = f, Size = UDim2.new(0,66,0,32), Position = UDim2.new(1,-82,0.5,-16), BackgroundColor3 = default and HONEY_LIGHT or Color3.fromRGB(210,210,210), Text = default and "ON" or "OFF", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TEXT_DARK, ZIndex = 9, AutoButtonColor = false})
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    local state = default

    local function setStateIcon(s, instant)
        state = s
        local targetColor = state and HONEY_LIGHT or Color3.fromRGB(210,210,210)
        local tween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor})
        tween:Play()
        btn.Text = state and "ON" or "OFF"
        -- callback after animation for smoother UX
        if instant then
            pcall(callback, state)
        else
            tween.Completed:Connect(function() pcall(callback, state) end)
        end
    end

    btn.MouseButton1Click:Connect(function()
        setStateIcon(not state, false)
    end)

    return f, function() return state end, btn, function(s) setStateIcon(s, true) end
end

-- Slider creator: returns (frame, setValueFn)
local function createSlider(parent, labelText, min, max, default, onChange)
    local f = new("Frame", {Parent = parent, Size = UDim2.new(1,-24,0,64), BackgroundTransparency = 1, ZIndex = 9})
    f.LayoutOrder = (parent:GetAttribute and parent:GetAttribute("nextLayout") or 0) + 1
    local lbl = new("TextLabel", {Parent = f, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, Text = string.format("%s: %.2fs", labelText, default), Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = TEXT_DARK, TextXAlignment = Enum.TextXAlignment.Left})
    local barBg = new("Frame", {Parent = f, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,36), BackgroundColor3 = HONEY_PRIMARY, BackgroundTransparency = 0.18, BorderSizePixel = 0})
    new("UICorner", {Parent = barBg, CornerRadius = UDim.new(1,0)})
    local fill = new("Frame", {Parent = barBg, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = HONEY_LIGHT, BorderSizePixel = 0})
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
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)

    local function setValue(v)
        local rel = math.clamp((v - min) / (max - min), 0, 1)
        fill.Size = UDim2.new(rel,0,1,0)
        lbl.Text = string.format("%s: %.2fs", labelText, v)
        pcall(onChange, v)
    end

    return f, setValue
end

-- Feature storage
local loaded = { Instant = {mod=nil, inst=nil}, Instant2X = {mod=nil, inst=nil} }

-- Panels: Instant Fishing
local pnlInstant = makePanel("Instant Fishing")
pnlInstant.LayoutOrder = 1
pnlInstant.Size = UDim2.new(1,0,0,220)

-- create toggle with animation
local _, _, toggleBtnI, setStateI = createToggle(pnlInstant, "Enable Instant Fishing", false, function(enabled)
    if enabled then
        if not loaded.Instant.mod then
            local mod, err = safeLoadFeature("Instant.lua")
            if not mod then
                warn("Keaby: failed loading Instant.lua", err)
                toggleBtnI.BackgroundColor3 = Color3.fromRGB(210,210,210)
                toggleBtnI.Text = "OFF"
                return
            end
            loaded.Instant.mod = mod
        end
        local mod = loaded.Instant.mod
        mod.Settings = mod.Settings or {}
        mod.Settings.HookDelay = pnlInstant._hookVal or mod.Settings.HookDelay or 0.06
        mod.Settings.FishingDelay = pnlInstant._fishVal or mod.Settings.FishingDelay or 0.12
        mod.Settings.CancelDelay = pnlInstant._cancelVal or mod.Settings.CancelDelay or 0.05
        loaded.Instant.inst = mod
        -- remove toggle key if present to avoid double toggles
        if mod.ToggleKey then pcall(function() mod.ToggleKey = nil end) end
        if type(mod.Start) == "function" then
            task.defer(function() pcall(mod.Start, mod) end)
        end
    else
        if loaded.Instant.inst and type(loaded.Instant.inst.Stop) == "function" then
            pcall(loaded.Instant.inst.Stop, loaded.Instant.inst)
        end
    end
end)

-- sliders for Instant
local hookFrame, hookSet = createSlider(pnlInstant, "Hook Delay", 0.01, 0.25, 0.06, function(v)
    pnlInstant._hookVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.HookDelay = v end
end)
hookFrame.LayoutOrder = 2

local fishFrame, fishSet = createSlider(pnlInstant, "Fishing Delay", 0.05, 1.0, 0.12, function(v)
    pnlInstant._fishVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.FishingDelay = v end
end)
fishFrame.LayoutOrder = 3

local cancelFrame, cancelSet = createSlider(pnlInstant, "Cancel Delay", 0.01, 0.25, 0.05, function(v)
    pnlInstant._cancelVal = v
    if loaded.Instant.mod then loaded.Instant.mod.Settings = loaded.Instant.mod.Settings or {}; loaded.Instant.mod.Settings.CancelDelay = v end
end)
cancelFrame.LayoutOrder = 4

-- Panels: Instant 2x Speed
local pnl2x = makePanel("Instant 2x Speed")
pnl2x.LayoutOrder = 2
pnl2x.Size = UDim2.new(1,0,0,180)

local _, _, toggleBtn2, setState2 = createToggle(pnl2x, "Enable Instant 2x Speed", false, function(enabled)
    if enabled then
        if not loaded.Instant2X.mod then
            local mod, err = safeLoadFeature("Instant2Xspeed.lua")
            if not mod then
                warn("Keaby: failed loading Instant2Xspeed.lua", err)
                toggleBtn2.BackgroundColor3 = Color3.fromRGB(210,210,210)
                toggleBtn2.Text = "OFF"
                return
            end
            loaded.Instant2X.mod = mod
        end
        local mod = loaded.Instant2X.mod
        mod.Settings = mod.Settings or {}
        mod.Settings.FishingDelay = pnl2x._fishVal or mod.Settings.FishingDelay or 0.3
        mod.Settings.CancelDelay = pnl2x._cancelVal or mod.Settings.CancelDelay or 0.05
        loaded.Instant2X.inst = mod
        if mod.ToggleKey then pcall(function() mod.ToggleKey = nil end) end
        if type(mod.Start) == "function" then
            task.defer(function() pcall(mod.Start, mod) end)
        end
    else
        if loaded.Instant2X.inst and type(loaded.Instant2X.inst.Stop) == "function" then
            pcall(loaded.Instant2X.inst.Stop, loaded.Instant2X.inst)
        end
    end
end)

local twoFishFrame, twoFishSet = createSlider(pnl2x, "Fishing Delay", 0.0, 1.0, 0.3, function(v)
    pnl2x._fishVal = v
    if loaded.Instant2X.mod then loaded.Instant2X.mod.Settings = loaded.Instant2X.mod.Settings or {}; loaded.Instant2X.mod.Settings.FishingDelay = v end
end)
twoFishFrame.LayoutOrder = 2

local twoCancelFrame, twoCancelSet = createSlider(pnl2x, "Cancel Delay", 0.01, 0.2, 0.05, function(v)
    pnl2x._cancelVal = v
    if loaded.Instant2X.mod then loaded.Instant2X.mod.Settings = loaded.Instant2X.mod.Settings or {}; loaded.Instant2X.mod.Settings.CancelDelay = v end
end)
twoCancelFrame.LayoutOrder = 3

-- Update canvas size
local function recalcCanvas()
    task.wait(0.03)
    local total = 0
    for _,c in ipairs(scrollFrame:GetChildren()) do
        if c:IsA("Frame") then total = total + c.AbsoluteSize.Y + scrollLayout.Padding.Offset end
    end
    scrollFrame.CanvasSize = UDim2.new(0,0,0, math.max(total + 16, 1))
end
spawn(function() wait(0.08) recalcCanvas() end)
window:GetPropertyChangedSignal("AbsoluteSize"):Connect(recalcCanvas)

-- sidebar action
mainBtn.MouseButton1Click:Connect(function()
    local targetY = mainBtn.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
    indicator:TweenPosition(UDim2.new(0,6,0,targetY), "Out", "Quad", 0.18, true)
    pageTitle.Text = "Main"
    pageSub.Text = "Auto Fishing features"
end)

-- drag window by header
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

-- resizer
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
UserInputService.InputEnded:Connect(function(input) if resizing then resizing = false end end)

-- Minimize -> create draggable bee icon with soft honey background + fade-in restore
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
        BackgroundColor3 = HONEY_LIGHT,
        BackgroundTransparency = 0.14,
        BorderSizePixel = 0,
        Text = "🐝",
        Font = Enum.Font.SourceSans,
        TextSize = 28,
        ZIndex = 60,
        AutoButtonColor = false,
    })
    new("UICorner", {Parent = minIcon, CornerRadius = UDim.new(1,0)})

    minIcon.MouseButton1Click:Connect(function()
        if minimized then
            minIcon.Visible = false
            window.Position = savedPos or window.Position
            window.Size = savedSize or window.Size
            window.Visible = true
            inner.Visible = true
            blocker.Active = true
            -- fade-in appearance
            window.BackgroundTransparency = 1
            inner.BackgroundTransparency = 1
            TweenService:Create(window, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.18}):Play()
            TweenService:Create(inner, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.22}):Play()
            minimized = false
            spawn(function() wait(0.08) recalcCanvas() end)
        end
    end)

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
    UserInputService.InputEnded:Connect(function(input) if iconDrag.dragging then iconDrag.dragging = false end end)
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
        if minIcon then minIcon.Visible = false end
        window.Visible = true
        blocker.Active = true
        minimized = false
    end
end)

-- Close: stop features & destroy
btnClose.MouseButton1Click:Connect(function()
    if loaded.Instant.inst and type(loaded.Instant.inst.Stop) == "function" then pcall(loaded.Instant.inst.Stop, loaded.Instant.inst) end
    if loaded.Instant2X.inst and type(loaded.Instant2X.inst.Stop) == "function" then pcall(loaded.Instant2X.inst.Stop, loaded.Instant2X.inst) end
    if minIcon and minIcon.Parent then minIcon:Destroy() end
    screenGui:Destroy()
end)

-- Ensure blocker + ordering
blocker.ZIndex = 1
window.ZIndex = 2

-- finalize
spawn(function() wait(0.12) recalcCanvas() end)
print("KeabyGUI v2.4 loaded — honey oranye pekat, toggles animated, sliders fixed. Minimize -> draggable 🐝 (left-middle).")

return screenGui
