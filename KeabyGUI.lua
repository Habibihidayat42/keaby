-- KeabyGUI.lua
-- GUI utama "Keaby" (tema lebah / sarang madu)
-- Compatible PC / Android / iOS. Uses modal blocker so underlying UI is not reachable.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Config: paste your GitHub raw base if needed (branch main)
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- Utility: safe load feature script (tries local readfile if available, else HttpGet)
local function safeLoadFeature(filename)
    local code
    -- try exploit file APIs
    local ok, isfile = pcall(function() return isfile end)
    if ok and isfile and isfile(filename) then
        code = readfile(filename)
    else
        -- try raw github
        local url = GITHUB_RAW_BASE .. filename
        local ok2, res = pcall(function() return game:HttpGet(url) end)
        if ok2 then code = res end
    end
    if not code then return nil, "failed to fetch " .. filename end
    local func, err = loadstring(code)
    if not func then return nil, err end
    local status, result = pcall(func)
    if not status then return nil, result end
    return result
end

-- small helper to create UI elements easier
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k,v in pairs(props) do
            if k == "Parent" then obj.Parent = v
            else obj[k] = v end
        end
    end
    return obj
end

-- Create ScreenGui
local screenGui = new("ScreenGui", {Name = "KeabyGUI", ResetOnSpawn = false, Parent = localPlayer:WaitForChild("PlayerGui")})

-- Modal blocker: full-screen transparent frame that captures input so underlying UI can't be touched
local blocker = new("Frame", {
    Parent = screenGui,
    Size = UDim2.fromScale(1,1),
    Position = UDim2.fromScale(0,0),
    BackgroundTransparency = 1, -- invisible
    ZIndex = 1,
    Active = true, -- captures input
})
-- If you want a slight dark overlay behind GUI, uncomment:
-- blocker.BackgroundTransparency = 0.4; blocker.BackgroundColor3 = Color3.fromRGB(0,0,0)

-- Main window (hive-shaped look via rounded corners and honey colors)
local window = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 420, 0, 300),
    Position = UDim2.new(0.5, -210, 0.4, -150),
    BackgroundColor3 = Color3.fromRGB(220,165,50), -- madu
    BackgroundTransparency = 0.12,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0, 18)})
-- Add faint inner to look like honey gradient (Frame)
local inner = new("Frame", {
    Parent = window,
    Size = UDim2.new(1, -6, 1, -6),
    Position = UDim2.new(0, 3, 0, 3),
    BackgroundColor3 = Color3.fromRGB(230,185,80),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 3,
})
new("UICorner", {Parent = inner, CornerRadius = UDim.new(0, 16)})

-- Header (draggable area) with small hive icon
local header = new("Frame", {
    Parent = inner,
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0,0,0,0),
    BackgroundTransparency = 1,
    ZIndex = 4,
})
local title = new("TextLabel", {
    Parent = header,
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Keaby",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(40,20,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
})
-- custom "hive" logo (no emoji)
local function makeHiveIcon(parent, size)
    local g = new("Frame", {
        Parent = parent,
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(1, -54, 0.5, -size/2),
        BackgroundColor3 = Color3.fromRGB(210,150,40),
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    new("UICorner", {Parent = g, CornerRadius = UDim.new(1,0)})
    -- little hexagon visual (approx)
    local hex = new("ImageLabel", {
        Parent = g,
        Size = UDim2.fromScale(0.86,0.86),
        Position = UDim2.fromScale(0.07,0.07),
        BackgroundTransparency = 1,
        Image = "", -- empty, using shapes
        ZIndex = 6,
    })
    return g
end
local hiveIcon = makeHiveIcon(header, 36)

-- Minimize button (small) and close (optional)
local minBtn = new("TextButton", {
    Parent = header,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -92, 0.5, -14),
    BackgroundTransparency = 0,
    BackgroundColor3 = Color3.fromRGB(200,140,30),
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(30,20,0),
    ZIndex = 6,
})
new("UICorner", {Parent = minBtn, CornerRadius = UDim.new(0,6)})

local closeBtn = new("TextButton", {
    Parent = header,
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -52, 0.5, -14),
    BackgroundTransparency = 0,
    BackgroundColor3 = Color3.fromRGB(180,60,40),
    Text = "x",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(255,255,255),
    ZIndex = 6,
})
new("UICorner", {Parent = closeBtn, CornerRadius = UDim.new(0,6)})

-- Body area for features
local body = new("Frame", {
    Parent = inner,
    Size = UDim2.new(1, -20, 1, -70),
    Position = UDim2.new(0,10,0,54),
    BackgroundTransparency = 1,
    ZIndex = 4,
})
-- layout columns
local leftCol = new("Frame", {Parent = body, Size = UDim2.new(0.5, -8, 1, 0), BackgroundTransparency = 1})
local rightCol = new("Frame", {Parent = body, Size = UDim2.new(0.5, -8, 1, 0), Position = UDim2.new(0.5, 8, 0, 0), BackgroundTransparency = 1})

-- UI helper: create toggle with label and callback
local function createToggle(parent, labelText, default, callback)
    local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,48), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.65,0,1,0),
        BackgroundTransparency = 1,
        Text = labelText,
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(35,20,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local btn = new("TextButton", {
        Parent = frame,
        Size = UDim2.new(0,60,0,28),
        Position = UDim2.new(1, -68, 0.5, -14),
        BackgroundColor3 = default and Color3.fromRGB(80,200,60) or Color3.fromRGB(170,170,170),
        Text = default and "ON" or "OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
    })
    new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(80,200,60) or Color3.fromRGB(170,170,170)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    return frame
end

-- UI helper: slider (touch friendly)
local function createSlider(parent, labelText, min, max, default, onChange)
    local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,0,0,56), BackgroundTransparency = 1})
    local lbl = new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1,0,0,20),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1,
        Text = string.format("%s: %.2fs", labelText, default),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(40,20,0),
        TextXAlignment = Enum.TextXAlignment.Left,
    })
    local barBg = new("Frame", {
        Parent = frame,
        Size = UDim2.new(1,0,0,10),
        Position = UDim2.new(0,0,0,30),
        BackgroundColor3 = Color3.fromRGB(210,170,80),
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
    })
    new("UICorner", {Parent = barBg, CornerRadius = UDim.new(1,0)})
    local fill = new("Frame", {Parent = barBg, Size = UDim2.new((default-min)/(max-min),0,1,0), BackgroundColor3 = Color3.fromRGB(120,200,60)})
    new("UICorner", {Parent = fill, CornerRadius = UDim.new(1,0)})
    -- Input handling
    local dragging = false
    local function updateFromPos(absX)
        local rel = math.clamp((absX - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max-min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel,0,1,0)
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
    return frame
end

-- Feature storage
local loadedFeatures = {
    Instant = {module = nil, instance = nil},
    Instant2X = {module = nil, instance = nil},
}

-- ---------- Build UI contents ----------
-- Left column: Instant Fishing (toggle + 3 sliders)
local instantFrame = new("Frame", {Parent = leftCol, Size = UDim2.new(1,0,0,220), BackgroundTransparency = 1})
local instantToggle, instantSliders
instantToggle = createToggle(instantFrame, "Instant Fishing", false, function(enabled)
    if enabled then
        -- load module if not loaded
        if not loadedFeatures.Instant.module then
            local mod, err = safeLoadFeature("Instant.lua")
            if not mod then
                warn("Keaby: failed to load Instant.lua:", err)
                return
            end
            loadedFeatures.Instant.module = mod
        end
        local mod = loadedFeatures.Instant.module
        -- apply settings from slider values
        mod.Settings = mod.Settings or {}
        -- read slider values if exist; default fallback
        local hook, fish, cancel = 0.06, 0.12, 0.05
        if instantSliders then
            hook = instantSliders.hookVal or hook
            fish = instantSliders.fishVal or fish
            cancel = instantSliders.cancelVal or cancel
        end
        mod.Settings.HookDelay = hook
        mod.Settings.FishingDelay = fish
        mod.Settings.CancelDelay = cancel
        -- store instance reference (many modules return table)
        loadedFeatures.Instant.instance = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant.instance and loadedFeatures.Instant.instance.Stop then
            pcall(loadedFeatures.Instant.instance.Stop, loadedFeatures.Instant.instance)
        end
    end
end)

-- sliders for instant fishing
instantSliders = {}
local s1 = createSlider(instantFrame, "Hook Delay", 0.01, 0.25, 0.06, function(val) instantSliders.hookVal = val end)
s1.Position = UDim2.new(0,0,0,48)
local s2 = createSlider(instantFrame, "Fishing Delay", 0.05, 1.0, 0.12, function(val) instantSliders.fishVal = val end)
s2.Position = UDim2.new(0,0,0,104)
local s3 = createSlider(instantFrame, "Cancel Delay", 0.01, 0.25, 0.05, function(val) instantSliders.cancelVal = val end)
s3.Position = UDim2.new(0,0,0,160)

-- Right column: Instant 2x Speed (toggle + 2 sliders)
local twoXFrame = new("Frame", {Parent = rightCol, Size = UDim2.new(1,0,0,160), BackgroundTransparency = 1})
local twoXSliders = {}
createToggle(twoXFrame, "Instant 2x Speed", false, function(enabled)
    if enabled then
        if not loadedFeatures.Instant2X.module then
            local mod, err = safeLoadFeature("Instant2Xspeed.lua")
            if not mod then warn("Keaby: failed to load Instant2Xspeed.lua:",err) return end
            loadedFeatures.Instant2X.module = mod
        end
        local mod = loadedFeatures.Instant2X.module
        mod.Settings = mod.Settings or {}
        mod.Settings.FishingDelay = twoXSliders.fishVal or mod.Settings.FishingDelay or 0.3
        mod.Settings.CancelDelay = twoXSliders.cancelVal or mod.Settings.CancelDelay or 0.05
        loadedFeatures.Instant2X.instance = mod
        if mod.Start then pcall(mod.Start, mod) end
    else
        if loadedFeatures.Instant2X.instance and loadedFeatures.Instant2X.instance.Stop then
            pcall(loadedFeatures.Instant2X.instance.Stop, loadedFeatures.Instant2X.instance)
        end
    end
end)

local sx1 = createSlider(twoXFrame, "Fishing Delay", 0.0, 1.0, 0.3, function(val) twoXSliders.fishVal = val end)
sx1.Position = UDim2.new(0,0,0,48)
local sx2 = createSlider(twoXFrame, "Cancel Delay", 0.01, 0.2, 0.05, function(val) twoXSliders.cancelVal = val end)
sx2.Position = UDim2.new(0,0,0,104)

-- Footer / extra: a small note
local footer = new("TextLabel", {
    Parent = inner,
    Size = UDim2.new(1, -20, 0, 22),
    Position = UDim2.new(0, 10, 1, -28),
    BackgroundTransparency = 1,
    Text = "Keaby • Bee themed UI — Mobile & PC friendly",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(45,25,0),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5,
})

-- ---------- Window behavior: drag, minimize, resize ----------
-- Dragging
do
    local dragging = false
    local dragStartPos, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = input.Position
            startPos = window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartPos
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
        end
    end)
end

-- Minimize behavior: reduce to icon
local minimized = false
local savedSize, savedPos
minBtn.MouseButton1Click:Connect(function()
    if not minimized then
        savedSize, savedPos = window.Size, window.Position
        window:TweenSizeAndPosition(UDim2.new(0,48,0,48), UDim2.new(0,10,0,10), "Out", "Quad", 0.18, true)
        -- hide inner contents (keep icon visible)
        for _,v in pairs(inner:GetChildren()) do
            if v ~= header and v ~= footer then v.Visible = false end
        end
        minimized = true
    else
        -- restore
        window:TweenSizeAndPosition(savedSize, savedPos, "Out", "Quad", 0.18, true)
        for _,v in pairs(inner:GetChildren()) do v.Visible = true end
        minimized = false
    end
end)

-- Close simply destroys GUI
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Resizer (corner)
local resizer = new("Frame", {
    Parent = window,
    Size = UDim2.new(0,16,0,16),
    Position = UDim2.new(1, -18, 1, -18),
    BackgroundTransparency = 1,
    ZIndex = 6,
})
local grip = new("ImageLabel", {Parent = resizer, Size = UDim2.new(1,1,1,1), BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(200,140,40)})
new("UICorner", {Parent = grip, CornerRadius = UDim.new(0,6)})
local resizing = false
local startSize, startPos, startMouse
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
        local newW = math.clamp(startSize.X.Offset + delta.X, 240, 900)
        local newH = math.clamp(startSize.Y.Offset + delta.Y, 160, 700)
        window.Size = UDim2.new(0, newW, 0, newH)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        resizing = false
    end
end)

-- Ensure blocker sits behind window but intercepts input
blocker.ZIndex = 1
window.ZIndex = 2

-- After loading GUI, automatically show main (already visible). Focus mobile input off game
-- (No extra code needed - the UI is ready)

-- Helpful log
print("Keaby GUI loaded — main shown")

-- Return screenGui for external control if executed as module
return screenGui
