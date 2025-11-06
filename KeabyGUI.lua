-- KeabyGUI_v2.6.lua
-- Flat honey-orange UI 🐝 with Instant & Instant2X integrated
-- Full offline version, compatible with Xeno executor

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

repeat task.wait() until localPlayer:FindFirstChild("PlayerGui")

-- Helper function to create instances
local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    return inst
end

-- =====================================================
-- LOAD FISHING FUNCTIONS FROM FOLDER FungsiKeaby
-- =====================================================
-- Online load versi raw
local instant = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant.lua"))()
local instant2x = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant2Xspeed.lua"))()

-- =====================================================
-- GUI CREATION
-- =====================================================
local gui = new("ScreenGui",{
    Name="KeabyGUI",
    Parent=localPlayer.PlayerGui,
    IgnoreGuiInset=true,
    ResetOnSpawn=false
})

local win = new("Frame",{
    Parent=gui,
    Size=UDim2.new(0,740,0,430),
    Position=UDim2.new(0.5,-370,0.5,-215),
    BackgroundColor3=Color3.fromRGB(200,90,20)
})
new("UICorner",{Parent=win,CornerRadius=UDim.new(0,12)})

local inner = new("Frame",{
    Parent=win,
    Size=UDim2.new(1,-12,1,-12),
    Position=UDim2.new(0,6,0,6),
    BackgroundColor3=Color3.fromRGB(250,170,50)
})
new("UICorner",{Parent=inner,CornerRadius=UDim.new(0,12)})

local sidebar = new("Frame",{
    Parent=inner,
    Size=UDim2.new(0,200,1,0),
    BackgroundColor3=Color3.fromRGB(140,70,10)
})
new("UICorner",{Parent=sidebar,CornerRadius=UDim.new(0,10)})

new("TextLabel",{
    Parent=sidebar,
    Text="🐝 Keaby",
    Size=UDim2.new(1,0,0,50),
    Font=Enum.Font.GothamBold,
    TextSize=20,
    BackgroundTransparency=1,
    TextColor3=Color3.fromRGB(255,230,180)
})

local content = new("Frame",{
    Parent=inner,
    Size=UDim2.new(1,-220,1,-20),
    Position=UDim2.new(0,210,0,10),
    BackgroundColor3=Color3.fromRGB(255,240,210)
})
new("UICorner",{Parent=content,CornerRadius=UDim.new(0,10)})

local scroll = new("ScrollingFrame",{
    Parent=content,
    Size=UDim2.new(1,-20,1,-20),
    Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1,
    ScrollBarThickness=8
})
new("UIListLayout",{Parent=scroll,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})

-- TOGGLE WITH ANIMATION
local function makeToggle(parent,label,callback)
    local f=new("Frame",{Parent=parent,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1})
    new("TextLabel",{Parent=f,Text=label,Size=UDim2.new(0.7,0,1,0),TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,TextColor3=Color3.fromRGB(40,20,0),Font=Enum.Font.Gotham,TextSize=14})
    local btn=new("TextButton",{Parent=f,Size=UDim2.new(0,60,0,28),Position=UDim2.new(1,-70,0.5,-14),
        Text="OFF",Font=Enum.Font.GothamBold,TextSize=13,BackgroundColor3=Color3.fromRGB(180,180,180)})
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        TweenService:Create(btn,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
            BackgroundColor3=on and Color3.fromRGB(255,140,20) or Color3.fromRGB(180,180,180)
        }):Play()
        btn.Text=on and "ON" or "OFF"
        callback(on)
    end)
end

-- SLIDER (mobile friendly)
local function makeSlider(parent,label,min,max,def,onChange)
    local f=new("Frame",{Parent=parent,Size=UDim2.new(1,0,0,50),BackgroundTransparency=1})
    local lbl=new("TextLabel",{Parent=f,Text=("%s: %.2fs"):format(label,def),Size=UDim2.new(1,0,0,20),
        BackgroundTransparency=1,TextColor3=Color3.fromRGB(40,20,0),TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.Gotham,TextSize=13})
    local bar=new("Frame",{Parent=f,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,30),
        BackgroundColor3=Color3.fromRGB(160,80,20)})
    new("UICorner",{Parent=bar,CornerRadius=UDim.new(1,0)})
    local fill=new("Frame",{Parent=bar,Size=UDim2.new((def-min)/(max-min),0,1,0),
        BackgroundColor3=Color3.fromRGB(255,130,20)})
    new("UICorner",{Parent=fill,CornerRadius=UDim.new(1,0)})
    local dragging=false
    local function update(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        local val=min+(max-min)*rel
        fill.Size=UDim2.new(rel,0,1,0)
        lbl.Text=("%s: %.2fs"):format(label,val)
        onChange(val)
    end
    bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true update(i.Position.X)end end)
    UserInputService.InputChanged:Connect(function(i)if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then update(i.Position.X)end end)
    UserInputService.InputEnded:Connect(function(i)if dragging then dragging=false end end)
end

-- PANEL BUILDER
local function makePanel(title)
    local p=new("Frame",{Parent=scroll,Size=UDim2.new(1,0,0,210),BackgroundColor3=Color3.fromRGB(255,210,120)})
    new("UICorner",{Parent=p,CornerRadius=UDim.new(0,8)})
    new("TextLabel",{Parent=p,Text=title,Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,10,0,6),
        Font=Enum.Font.GothamSemibold,TextSize=15,TextColor3=Color3.fromRGB(50,25,0),BackgroundTransparency=1})
    new("UIListLayout",{Parent=p,Padding=UDim.new(0,6)})
    return p
end

-- PANEL 1: Instant Fishing
local pnl1=makePanel("Instant Fishing")
makeToggle(pnl1,"Enable Instant Fishing",function(on) if on then instant.Start() else instant.Stop() end end)
makeSlider(pnl1,"Fishing Delay",0.05,1.0,0.12,function(v) instant.Settings.FishingDelay=v end)
makeSlider(pnl1,"Cancel Delay",0.01,0.3,0.05,function(v) instant.Settings.CancelDelay=v end)

-- PANEL 2: Instant 2x Speed
local pnl2=makePanel("Instant 2x Speed")
makeToggle(pnl2,"Enable Instant 2x Speed",function(on) if on then instant2x.Start() else instant2x.Stop() end end)
makeSlider(pnl2,"Fishing Delay",0,1,0.3,function(v) instant2x.Settings.FishingDelay=v end)
makeSlider(pnl2,"Cancel Delay",0.01,0.2,0.05,function(v) instant2x.Settings.CancelDelay=v end)

-- MINIMIZE TO 🐝 ICON
local minimized=false
local icon
local btnMin=new("TextButton",{Parent=win,Text="—",Size=UDim2.new(0,28,0,24),Position=UDim2.new(1,-40,0,10),
    BackgroundColor3=Color3.fromRGB(255,130,20)})
new("UICorner",{Parent=btnMin,CornerRadius=UDim.new(0,6)})
btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        win.Visible=false
        icon=new("TextButton",{Parent=gui,Text="🐝",Size=UDim2.new(0,56,0,56),Position=UDim2.new(0,12,0.5,-28),
            BackgroundColor3=Color3.fromRGB(255,200,100)})
        new("UICorner",{Parent=icon,CornerRadius=UDim.new(1,0)})
        local drag=false;local startPos;local startMouse
        icon.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true startPos=icon.Position startMouse=i.Position end end)
        UserInputService.InputChanged:Connect(function(i)if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-startMouse icon.Position=UDim2.new(0,startPos.X.Offset+d.X,0,startPos.Y.Offset+d.Y) end end)
        UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
        icon.MouseButton1Click:Connect(function()win.Visible=true icon:Destroy() minimized=false end)
        minimized=true
    end
end)

print("🐝 KeabyGUI v2.6 loaded successfully")
