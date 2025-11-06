-- KeabyGUI_v2.4_fix.lua
-- Flat matte honey theme 🐝 + fade toggle animation + full slider + safe CoreGui protection for Xeno
repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function protectGui(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = localPlayer:WaitForChild("PlayerGui")
    end
end

-- GitHub raw for modules
local GITHUB = "https://raw.githubusercontent.com/Habibihidayat42/keaby/main/FungsiKeaby/"

-- Loader
local function safeLoadFeature(file)
    local code
    local ok, hasFile = pcall(function() return isfile end)
    if ok and hasFile and isfile(file) then
        code = readfile(file)
    else
        local suc, res = pcall(function() return game:HttpGet(GITHUB .. file) end)
        if suc then code = res end
    end
    if not code then return nil, "cannot load " .. file end
    local fn, err = loadstring(code)
    if not fn then return nil, err end
    local ok2, mod = pcall(fn)
    if not ok2 then return nil, mod end
    return mod
end

local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k == "Parent" then inst.Parent = v else inst[k] = v end
    end
    return inst
end

-- Main GUI
local gui = new("ScreenGui", {Name="KeabyGUI", ResetOnSpawn=false})
protectGui(gui)

-- Background blocker
local blocker = new("Frame", {Parent=gui, Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Active=true, ZIndex=1})

-- Window
local window = new("Frame", {
    Parent = gui,
    Size = UDim2.new(0,760,0,440),
    Position = UDim2.new(0.5,-380,0.5,-220),
    BackgroundColor3 = Color3.fromRGB(217,140,48),
    BackgroundTransparency = 0.1,
    BorderSizePixel = 0,
    ZIndex = 2,
})
new("UICorner", {Parent=window, CornerRadius=UDim.new(0,14)})

-- Inner frame
local inner = new("Frame", {
    Parent=window, Size=UDim2.new(1,-12,1,-12),
    Position=UDim2.new(0,6,0,6),
    BackgroundColor3=Color3.fromRGB(240,200,130),
    BackgroundTransparency=0.18, BorderSizePixel=0, ZIndex=3
})
new("UICorner", {Parent=inner, CornerRadius=UDim.new(0,12)})

-- Sidebar
local sidebar = new("Frame", {
    Parent=inner, Size=UDim2.new(0,200,1,0),
    BackgroundColor3=Color3.fromRGB(180,100,20),
    BackgroundTransparency=0.08, BorderSizePixel=0, ZIndex=4
})
new("UICorner", {Parent=sidebar, CornerRadius=UDim.new(0,10)})

-- Logo
local logo = new("TextLabel", {
    Parent=sidebar, Size=UDim2.new(1,0,0,70),
    Text="🐝 Keaby", Font=Enum.Font.GothamBold, TextSize=24,
    TextColor3=Color3.fromRGB(255,235,180),
    BackgroundTransparency=1, ZIndex=5
})

-- Sidebar button
local menu = new("Frame", {Parent=sidebar, Size=UDim2.new(1,-20,1,-100), Position=UDim2.new(0,10,0,90), BackgroundTransparency=1})
local layout = new("UIListLayout", {Parent=menu, Padding=UDim.new(0,10)})
local mainBtn = new("TextButton", {
    Parent=menu, Size=UDim2.new(1,0,0,46), Text="Main",
    BackgroundColor3=Color3.fromRGB(255,200,80),
    Font=Enum.Font.GothamSemibold, TextSize=16, TextColor3=Color3.fromRGB(40,20,0)
})
new("UICorner", {Parent=mainBtn, CornerRadius=UDim.new(0,8)})

-- Header bar
local header = new("Frame", {Parent=inner, Size=UDim2.new(1,-210,0,50), Position=UDim2.new(0,210,0,6), BackgroundTransparency=1})
local dragArea = new("Frame", {Parent=header, Size=UDim2.new(1,-100,1,0), BackgroundTransparency=1})
local btnMin = new("TextButton", {Parent=header, Size=UDim2.new(0,36,0,30), Position=UDim2.new(1,-80,0.5,-15), Text="—", Font=Enum.Font.GothamBold, TextSize=22, TextColor3=Color3.fromRGB(50,30,0), BackgroundColor3=Color3.fromRGB(250,210,100)})
local btnClose = new("TextButton", {Parent=header, Size=UDim2.new(0,36,0,30), Position=UDim2.new(1,-38,0.5,-15), Text="✕", Font=Enum.Font.GothamBold, TextSize=18, TextColor3=Color3.fromRGB(255,255,255), BackgroundColor3=Color3.fromRGB(200,80,60)})
new("UICorner",{Parent=btnMin,CornerRadius=UDim.new(0,6)})
new("UICorner",{Parent=btnClose,CornerRadius=UDim.new(0,6)})

-- Content
local content = new("Frame", {Parent=inner, Size=UDim2.new(1,-230,1,-20), Position=UDim2.new(0,220,0,10), BackgroundColor3=Color3.fromRGB(255,245,220), BackgroundTransparency=0.18, BorderSizePixel=0, ZIndex=5})
new("UICorner",{Parent=content,CornerRadius=UDim.new(0,10)})

local scroll = new("ScrollingFrame", {Parent=content, Size=UDim2.new(1,-20,1,-60), Position=UDim2.new(0,10,0,50), BackgroundTransparency=1, ScrollBarThickness=8})
local list = new("UIListLayout", {Parent=scroll, Padding=UDim.new(0,12)})

-- Fade color function
local function tweenColor(obj, prop, target, time)
    local t = TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[prop]=target})
    t:Play()
end

-- Toggle
local function createToggle(parent, text, default, callback)
    local f = new("Frame",{Parent=parent,Size=UDim2.new(1,-20,0,40),BackgroundTransparency=1})
    new("UICorner",{Parent=f,CornerRadius=UDim.new(0,8)})
    local lbl = new("TextLabel",{Parent=f,Size=UDim2.new(0.7,0,1,0),Text=text,Font=Enum.Font.Gotham,TextSize=14,TextColor3=Color3.fromRGB(40,20,0),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
    local btn = new("TextButton",{Parent=f,Size=UDim2.new(0,60,0,28),Position=UDim2.new(1,-70,0.5,-14),Text=default and "ON" or "OFF",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=Color3.fromRGB(40,20,0),BackgroundColor3=default and Color3.fromRGB(255,200,80) or Color3.fromRGB(200,200,200)})
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        tweenColor(btn,"BackgroundColor3", state and Color3.fromRGB(255,200,80) or Color3.fromRGB(200,200,200),0.2)
        btn.Text = state and "ON" or "OFF"
        pcall(callback, state)
    end)
    return f
end

-- Slider
local function createSlider(parent,labelText,min,max,default,onChange)
    local f=new("Frame",{Parent=parent,Size=UDim2.new(1,-20,0,50),BackgroundTransparency=1})
    local lbl=new("TextLabel",{Parent=f,Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=string.format("%s: %.2fs",labelText,default),Font=Enum.Font.Gotham,TextSize=13,TextColor3=Color3.fromRGB(40,20,0),TextXAlignment=Enum.TextXAlignment.Left})
    local barBg=new("Frame",{Parent=f,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,28),BackgroundColor3=Color3.fromRGB(180,100,20),BackgroundTransparency=0.25,BorderSizePixel=0})
    new("UICorner",{Parent=barBg,CornerRadius=UDim.new(1,0)})
    local fill=new("Frame",{Parent=barBg,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=Color3.fromRGB(255,200,80),BorderSizePixel=0})
    new("UICorner",{Parent=fill,CornerRadius=UDim.new(1,0)})
    local dragging=false
    local function update(x)
        local rel=math.clamp((x-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
        local val=min+(max-min)*rel
        val=math.floor(val*100)/100
        fill.Size=UDim2.new(rel,0,1,0)
        lbl.Text=string.format("%s: %.2fs",labelText,val)
        pcall(onChange,val)
    end
    barBg.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true update(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i) if dragging then dragging=false end end)
    return f
end

-- Load features
local loaded = {Instant=nil, Instant2X=nil}

-- Panels
local p1=new("Frame",{Parent=scroll,Size=UDim2.new(1,0,0,230),BackgroundColor3=Color3.fromRGB(250,220,150),BackgroundTransparency=0.2})
new("UICorner",{Parent=p1,CornerRadius=UDim.new(0,8)})
local title1=new("TextLabel",{Parent=p1,Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Text="Instant Fishing",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=Color3.fromRGB(40,20,0)})

local tog1=createToggle(p1,"Enable Instant Fishing",false,function(on)
    if on then
        if not loaded.Instant then
            local mod=safeLoadFeature("Instant.lua")
            if mod then loaded.Instant=mod end
        end
        if loaded.Instant and loaded.Instant.Start then pcall(loaded.Instant.Start,loaded.Instant) end
    else
        if loaded.Instant and loaded.Instant.Stop then pcall(loaded.Instant.Stop,loaded.Instant) end
    end
end)
tog1.Position=UDim2.new(0,10,0,40)

createSlider(p1,"Hook Delay",0.01,0.25,0.06,function(v) if loaded.Instant then loaded.Instant.Settings.HookDelay=v end end).Position=UDim2.new(0,10,0,90)
createSlider(p1,"Fishing Delay",0.05,1.0,0.12,function(v) if loaded.Instant then loaded.Instant.Settings.FishingDelay=v end end).Position=UDim2.new(0,10,0,140)
createSlider(p1,"Cancel Delay",0.01,0.25,0.05,function(v) if loaded.Instant then loaded.Instant.Settings.CancelDelay=v end end).Position=UDim2.new(0,10,0,190)

local p2=new("Frame",{Parent=scroll,Size=UDim2.new(1,0,0,180),BackgroundColor3=Color3.fromRGB(250,220,150),BackgroundTransparency=0.2})
new("UICorner",{Parent=p2,CornerRadius=UDim.new(0,8)})
local title2=new("TextLabel",{Parent=p2,Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Text="Instant 2x Speed",Font=Enum.Font.GothamSemibold,TextSize=16,TextColor3=Color3.fromRGB(40,20,0)})

local tog2=createToggle(p2,"Enable Instant 2x Speed",false,function(on)
    if on then
        if not loaded.Instant2X then
            local mod=safeLoadFeature("Instant2Xspeed.lua")
            if mod then loaded.Instant2X=mod end
        end
        if loaded.Instant2X and loaded.Instant2X.Start then pcall(loaded.Instant2X.Start,loaded.Instant2X) end
    else
        if loaded.Instant2X and loaded.Instant2X.Stop then pcall(loaded.Instant2X.Stop,loaded.Instant2X) end
    end
end)
tog2.Position=UDim2.new(0,10,0,40)
createSlider(p2,"Fishing Delay",0.0,1.0,0.3,function(v) if loaded.Instant2X then loaded.Instant2X.Settings.FishingDelay=v end end).Position=UDim2.new(0,10,0,90)
createSlider(p2,"Cancel Delay",0.01,0.2,0.05,function(v) if loaded.Instant2X then loaded.Instant2X.Settings.CancelDelay=v end end).Position=UDim2.new(0,10,0,140)

-- Drag window
do
    local dragging=false local dragStart local startPos
    dragArea.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true dragStart=i.Position startPos=window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local delta=i.Position-dragStart
            window.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if dragging then dragging=false end end)
end

-- Minimize bee icon
local minimized=false
local minIcon=nil
local function makeBeeIcon()
    if minIcon then minIcon:Destroy() end
    minIcon=new("TextButton",{Parent=gui,Size=UDim2.new(0,60,0,60),Position=UDim2.new(0,12,0.5,-30),Text="🐝",Font=Enum.Font.GothamBold,TextSize=32,BackgroundColor3=Color3.fromRGB(255,220,100),BorderSizePixel=0})
    new("UICorner",{Parent=minIcon,CornerRadius=UDim.new(1,0)})
    minIcon.MouseButton1Click:Connect(function()
        window.Visible=true blocker.Active=true minIcon.Visible=false minimized=false
    end)
    local drag=false local startMouse local startPos
    minIcon.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true startMouse=i.Position startPos=minIcon.Position end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-startMouse
            minIcon.Position=UDim2.new(0, startPos.X.Offset+d.X, 0, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() drag=false end)
end

btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        window.Visible=false blocker.Active=false minimized=true makeBeeIcon()
    else
        window.Visible=true blocker.Active=true minimized=false if minIcon then minIcon.Visible=false end
    end
end)

btnClose.MouseButton1Click:Connect(function()
    if loaded.Instant and loaded.Instant.Stop then pcall(loaded.Instant.Stop,loaded.Instant) end
    if loaded.Instant2X and loaded.Instant2X.Stop then pcall(loaded.Instant2X.Stop,loaded.Instant2X) end
    gui:Destroy()
end)

print("🐝 Keaby GUI v2.4 loaded successfully")
