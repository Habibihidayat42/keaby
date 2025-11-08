-- KeabyGUI_v4.0.lua - Ultra Modern Edition (FIXED)
-- Neon Cyberpunk Theme with Refined Design 🌟

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

repeat task.wait() until localPlayer:FindFirstChild("PlayerGui")

local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    return inst
end

local instant = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant.lua"))()
local instant2x = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant2Xspeed.lua"))()

-- Ultra Modern Cyberpunk Palette
local colors = {
    primary = Color3.fromRGB(0, 255, 255),
    secondary = Color3.fromRGB(255, 0, 255),
    accent = Color3.fromRGB(138, 43, 226),
    success = Color3.fromRGB(0, 255, 157),
    warning = Color3.fromRGB(255, 215, 0),
    danger = Color3.fromRGB(255, 20, 147),
    dark = Color3.fromRGB(10, 10, 15),
    darker = Color3.fromRGB(15, 15, 25),
    darkest = Color3.fromRGB(5, 5, 10),
    glass = Color3.fromRGB(20, 20, 35),
    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(160, 180, 220),
    border = Color3.fromRGB(0, 200, 255),
    sidebarBg = Color3.fromRGB(12, 12, 20),
}

local gui = new("ScreenGui",{
    Name="KeabyGUI_Ultra",
    Parent=localPlayer.PlayerGui,
    IgnoreGuiInset=true,
    ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=999
})

local inputBlocker = new("Frame",{
    Parent=gui,
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0.3,
    BorderSizePixel=0,
    Visible=false,
    ZIndex=1,
    Active=true
})

local blurBg = new("Frame",{
    Parent=gui,
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0.15,
    BorderSizePixel=0,
    Visible=false,
    ZIndex=2
})

local win = new("Frame",{
    Parent=gui,
    Size=UDim2.new(0,700,0,450),
    Position=UDim2.new(0.5,-350,0.5,-225),
    BackgroundColor3=colors.darkest,
    BackgroundTransparency=0.05,
    BorderSizePixel=0,
    ClipsDescendants=true,
    ZIndex=3
})
new("UICorner",{Parent=win,CornerRadius=UDim.new(0,20)})

-- Animated border only on the window
local neonBorder = new("UIStroke",{
    Parent=win,
    Color=colors.primary,
    Thickness=2.5,
    Transparency=0,
    ApplyStrokeMode=Enum.ApplyStrokeMode.Border
})

local neonGradient = new("UIGradient",{
    Parent=neonBorder,
    Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(0.33, colors.secondary),
        ColorSequenceKeypoint.new(0.66, colors.accent),
        ColorSequenceKeypoint.new(1, colors.primary)
    },
    Rotation=0
})

task.spawn(function()
    while gui.Parent do
        for i = 0, 360, 2 do
            if not gui.Parent then break end
            neonGradient.Rotation = i
            task.wait(0.03)
        end
    end
end)

-- Top Bar
local topBar = new("Frame",{
    Parent=win,
    Size=UDim2.new(1,0,0,60),
    BackgroundColor3=colors.dark,
    BackgroundTransparency=0.1,
    BorderSizePixel=0,
    ZIndex=4
})
new("UICorner",{Parent=topBar,CornerRadius=UDim.new(0,20)})

-- Logo Container
local logoContainer = new("Frame",{
    Parent=topBar,
    Size=UDim2.new(0,45,0,45),
    Position=UDim2.new(0,12,0.5,-22.5),
    BackgroundColor3=colors.darkest,
    BorderSizePixel=0,
    ZIndex=5
})
new("UICorner",{Parent=logoContainer,CornerRadius=UDim.new(0,12)})

local logoStroke = new("UIStroke",{
    Parent=logoContainer,
    Color=colors.primary,
    Thickness=2,
    Transparency=0.3
})

local logoText = new("TextLabel",{
    Parent=logoContainer,
    Text="K",
    Size=UDim2.new(1,0,1,0),
    Font=Enum.Font.GothamBold,
    TextSize=28,
    BackgroundTransparency=1,
    TextColor3=colors.primary,
    ZIndex=6
})

-- Title
local titleLabel = new("TextLabel",{
    Parent=topBar,
    Text="Keabyy",
    Size=UDim2.new(0,200,1,0),
    Position=UDim2.new(0,65,0,0),
    Font=Enum.Font.GothamBold,
    TextSize=20,
    BackgroundTransparency=1,
    TextColor3=colors.text,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5
})

-- Control Buttons
local controlsContainer = new("Frame",{
    Parent=topBar,
    Size=UDim2.new(0,90,0,35),
    Position=UDim2.new(1,-100,0.5,-17.5),
    BackgroundTransparency=1,
    ZIndex=5
})
new("UIListLayout",{
    Parent=controlsContainer,
    FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Right,
    Padding=UDim.new(0,8)
})

local function createControlButton(icon, hoverColor)
    local btn = new("TextButton",{
        Parent=controlsContainer,
        Text=icon,
        Size=UDim2.new(0,35,0,35),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        Font=Enum.Font.GothamBold,
        TextSize=icon == "×" and 24 or 18,
        TextColor3=colors.textDim,
        AutoButtonColor=false,
        ZIndex=6
    })
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,10)})
    new("UIStroke",{Parent=btn,Color=colors.border,Thickness=1.5,Transparency=0.6})
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{
            BackgroundColor3=hoverColor,
            BackgroundTransparency=0,
            TextColor3=colors.text,
            Size=UDim2.new(0,38,0,38)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{
            BackgroundColor3=colors.glass,
            BackgroundTransparency=0.3,
            TextColor3=colors.textDim,
            Size=UDim2.new(0,35,0,35)
        }):Play()
    end)
    return btn
end

local btnMin = createControlButton("─", colors.warning)
local btnClose = createControlButton("×", colors.danger)

-- Sidebar
local sidebar = new("Frame",{
    Parent=win,
    Size=UDim2.new(0,160,1,-72),
    Position=UDim2.new(0,8,0,64),
    BackgroundColor3=colors.sidebarBg,
    BackgroundTransparency=0.2,
    BorderSizePixel=0,
    ZIndex=4
})
new("UICorner",{Parent=sidebar,CornerRadius=UDim.new(0,16)})
new("UIStroke",{Parent=sidebar,Color=colors.border,Thickness=1.5,Transparency=0.6})

local navContainer = new("Frame",{
    Parent=sidebar,
    Size=UDim2.new(1,-16,1,-16),
    Position=UDim2.new(0,8,0,8),
    BackgroundTransparency=1,
    ZIndex=5
})
new("UIListLayout",{
    Parent=navContainer,
    Padding=UDim.new(0,10),
    SortOrder=Enum.SortOrder.LayoutOrder
})

local currentPage = "Main"
local navButtons = {}

local function createNavButton(text, icon, page)
    local btn = new("TextButton",{
        Parent=navContainer,
        Size=UDim2.new(1,0,0,45),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=page == currentPage and 0.1 or 0.5,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
        ZIndex=7
    })
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,12)})
    
    local btnStroke = new("UIStroke",{
        Parent=btn,
        Color=page == currentPage and colors.primary or colors.border,
        Thickness=page == currentPage and 2 or 1.5,
        Transparency=page == currentPage and 0.3 or 0.7
    })
    
    local iconLabel = new("TextLabel",{
        Parent=btn,
        Size=UDim2.new(0,35,1,0),
        Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,
        Text=icon,
        Font=Enum.Font.GothamBold,
        TextSize=18,
        TextColor3=page == currentPage and colors.primary or colors.textDim,
        ZIndex=8
    })
    
    local textLabel = new("TextLabel",{
        Parent=btn,
        Size=UDim2.new(1,-48,1,0),
        Position=UDim2.new(0,43,0,0),
        BackgroundTransparency=1,
        Text=text,
        Font=Enum.Font.GothamSemibold,
        TextSize=13,
        TextColor3=page == currentPage and colors.text or colors.textDim,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8
    })
    
    navButtons[page] = {btn=btn, icon=iconLabel, text=textLabel, stroke=btnStroke}
    return btn
end

-- Content Area
local contentBg = new("Frame",{
    Parent=win,
    Size=UDim2.new(1,-180,1,-76),
    Position=UDim2.new(0,176,0,68),
    BackgroundColor3=colors.darker,
    BackgroundTransparency=0.15,
    BorderSizePixel=0,
    ClipsDescendants=true,  -- FIXED: Added ClipsDescendants
    ZIndex=4
})
new("UICorner",{Parent=contentBg,CornerRadius=UDim.new(0,16)})
new("UIStroke",{Parent=contentBg,Color=colors.border,Thickness=1.5,Transparency=0.6})

local pages = {}

local function createPage(name)
    local page = new("ScrollingFrame",{
        Parent=contentBg,
        Size=UDim2.new(1,-16,1,-16),
        Position=UDim2.new(0,8,0,8),
        BackgroundTransparency=1,
        ScrollBarThickness=5,
        ScrollBarImageColor3=colors.primary,
        BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,
        ClipsDescendants=true,  -- FIXED: Added ClipsDescendants
        ZIndex=5
    })
    new("UIListLayout",{
        Parent=page,
        Padding=UDim.new(0,12),
        SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment=Enum.HorizontalAlignment.Center
    })
    -- FIXED: Added padding to prevent content touching edges
    new("UIPadding",{
        Parent=page,
        PaddingTop=UDim.new(0,8),
        PaddingBottom=UDim.new(0,8),
        PaddingLeft=UDim.new(0,4),
        PaddingRight=UDim.new(0,4)
    })
    pages[name] = page
    return page
end

local mainPage = createPage("Main")
local settingsPage = createPage("Settings")
local infoPage = createPage("Info")
mainPage.Visible = true

local function switchPage(pageName)
    if currentPage == pageName then return end
    for _, page in pairs(pages) do page.Visible = false end
    
    for name, btnData in pairs(navButtons) do
        local isActive = name == pageName
        btnData.btn.BackgroundTransparency = isActive and 0.1 or 0.5
        btnData.stroke.Color = isActive and colors.primary or colors.border
        btnData.stroke.Thickness = isActive and 2 or 1.5
        btnData.stroke.Transparency = isActive and 0.3 or 0.7
        btnData.icon.TextColor3 = isActive and colors.primary or colors.textDim
        btnData.text.TextColor3 = isActive and colors.text or colors.textDim
    end
    
    pages[pageName].Visible = true
    currentPage = pageName
end

local btnMain = createNavButton("Main", "🏠", "Main")
local btnSettings = createNavButton("Settings", "⚙️", "Settings")
local btnInfo = createNavButton("Info", "ℹ️", "Info")

btnMain.MouseButton1Click:Connect(function() switchPage("Main") end)
btnSettings.MouseButton1Click:Connect(function() switchPage("Settings") end)
btnInfo.MouseButton1Click:Connect(function() switchPage("Info") end)

-- FIXED: Compact Toggle with proper sizing
local function makeToggle(parent,label,callback)
    local f=new("Frame",{
        Parent=parent,
        Size=UDim2.new(1,0,0,38),
        BackgroundTransparency=1,
        ZIndex=6
    })
    
    new("TextLabel",{
        Parent=f,
        Text=label,
        Size=UDim2.new(0.62,0,1,0),  -- FIXED: Reduced width to prevent overlap
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,
        TextColor3=colors.text,
        Font=Enum.Font.GothamMedium,
        TextSize=12,
        TextWrapped=true,
        ZIndex=7
    })
    
    local toggleBg=new("Frame",{
        Parent=f,
        Size=UDim2.new(0,50,0,26),
        Position=UDim2.new(1,-52,0.5,-13),
        BackgroundColor3=colors.border,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        ZIndex=7
    })
    new("UICorner",{Parent=toggleBg,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=toggleBg,Color=colors.border,Thickness=1.5,Transparency=0.5})
    
    local toggleCircle=new("Frame",{
        Parent=toggleBg,
        Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(0,3,0.5,-10),
        BackgroundColor3=colors.textDim,
        BorderSizePixel=0,
        ZIndex=8
    })
    new("UICorner",{Parent=toggleCircle,CornerRadius=UDim.new(1,0)})
    
    local btn=new("TextButton",{
        Parent=toggleBg,
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        ZIndex=9
    })
    
    local on=false
    btn.MouseButton1Click:Connect(function()
        on=not on
        TweenService:Create(toggleBg,TweenInfo.new(0.25),{
            BackgroundColor3=on and colors.primary or colors.border,
            BackgroundTransparency=on and 0 or 0.3
        }):Play()
        TweenService:Create(toggleCircle,TweenInfo.new(0.3,Enum.EasingStyle.Back),{
            Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10),
            BackgroundColor3=on and colors.text or colors.textDim
        }):Play()
        callback(on)
    end)
end

-- FIXED: Compact Slider with proper boundaries
local function makeSlider(parent,label,min,max,def,onChange)
    local f=new("Frame",{
        Parent=parent,
        Size=UDim2.new(1,0,0,55),
        BackgroundTransparency=1,
        ClipsDescendants=true,  -- FIXED: Added ClipsDescendants
        ZIndex=6
    })
    
    local lbl=new("TextLabel",{
        Parent=f,
        Text=("%s: %.2fs"):format(label,def),
        Size=UDim2.new(1,0,0,20),
        BackgroundTransparency=1,
        TextColor3=colors.text,
        TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamMedium,
        TextSize=12,
        ZIndex=7
    })
    
    local bar=new("Frame",{
        Parent=f,
        Size=UDim2.new(1,-8,0,10),  -- FIXED: Reduced width to add margin
        Position=UDim2.new(0,4,0,32),  -- FIXED: Added left margin
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.4,
        BorderSizePixel=0,
        ClipsDescendants=false,  -- Allow knob to slightly exceed
        ZIndex=7
    })
    new("UICorner",{Parent=bar,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=bar,Color=colors.border,Thickness=1.5,Transparency=0.7})
    
    local fill=new("Frame",{
        Parent=bar,
        Size=UDim2.new((def-min)/(max-min),0,1,0),
        BackgroundColor3=colors.primary,
        BorderSizePixel=0,
        ZIndex=8
    })
    new("UICorner",{Parent=fill,CornerRadius=UDim.new(1,0)})
    
    local knob=new("Frame",{
        Parent=bar,
        Size=UDim2.new(0,20,0,20),  -- FIXED: Reduced knob size
        Position=UDim2.new((def-min)/(max-min),-10,0.5,-10),
        BackgroundColor3=colors.text,
        BorderSizePixel=0,
        ZIndex=9
    })
    new("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=knob,Color=colors.primary,Thickness=2,Transparency=0.4})
    
    local dragging=false
    local function update(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        local val=min+(max-min)*rel
        fill.Size=UDim2.new(rel,0,1,0)
        knob.Position=UDim2.new(rel,-10,0.5,-10)
        lbl.Text=("%s: %.2fs"):format(label,val)
        onChange(val)
    end
    
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then 
            dragging=true 
            update(i.Position.X)
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then 
            update(i.Position.X)
        end 
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end 
    end)
end

-- FIXED: Compact Panel with proper clipping and auto-sizing
local function makePanel(parent,title,icon)
    local p=new("Frame",{
        Parent=parent,
        Size=UDim2.new(0.96,0,0,50),  -- FIXED: Start with small height, will auto-expand
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        ClipsDescendants=true,  -- FIXED: Added ClipsDescendants
        AutomaticSize=Enum.AutomaticSize.Y,  -- FIXED: Auto-resize based on content
        ZIndex=6
    })
    new("UICorner",{Parent=p,CornerRadius=UDim.new(0,14)})
    new("UIStroke",{Parent=p,Color=colors.primary,Thickness=1.5,Transparency=0.6})
    
    local header=new("Frame",{
        Parent=p,
        Size=UDim2.new(1,0,0,42),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=7
    })
    
    new("TextLabel",{
        Parent=header,
        Text=icon.." "..title,
        Size=UDim2.new(1,-20,1,0),
        Position=UDim2.new(0,10,0,0),
        Font=Enum.Font.GothamBold,
        TextSize=14,
        TextColor3=colors.text,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8
    })
    
    local container=new("Frame",{
        Parent=p,
        Size=UDim2.new(1,-20,0,0),  -- FIXED: Start with 0 height
        Position=UDim2.new(0,10,0,47),
        BackgroundTransparency=1,
        ClipsDescendants=false,  -- FIXED: Changed to false to allow content to be visible
        AutomaticSize=Enum.AutomaticSize.Y,  -- FIXED: Auto-resize based on content
        ZIndex=7
    })
    local layout = new("UIListLayout",{
        Parent=container,
        Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder
    })
    -- FIXED: Add padding at bottom
    new("UIPadding",{
        Parent=container,
        PaddingBottom=UDim.new(0,10)
    })
    
    return container
end

-- Main Page Content
local pnl1=makePanel(mainPage,"⚡ Instant Fishing","")
makeToggle(pnl1,"Enable Instant Fishing",function(on) if on then instant.Start() else instant.Stop() end end)
makeSlider(pnl1,"Fishing Delay",0.01,5.0,0.12,function(v) instant.Settings.MaxWaitTime=v end)
makeSlider(pnl1,"Cancel Delay",0.01,1.5,0.19,function(v) instant.Settings.CancelDelay=v end)

local pnl2=makePanel(mainPage,"🚀 Instant 2x Speed","")
makeToggle(pnl2,"Enable Instant 2x Speed",function(on) if on then instant2x.Start() else instant2x.Stop() end end)
makeSlider(pnl2,"Fishing Delay",0,1,0.3,function(v) instant2x.Settings.FishingDelay=v end)
makeSlider(pnl2,"Cancel Delay",0.01,0.2,0.05,function(v) instant2x.Settings.CancelDelay=v end)

-- Settings Page
local settingsPnl = makePanel(settingsPage,"⚙️ General Settings","")
makeToggle(settingsPnl,"Auto Save Settings",function(on) print("Auto Save:",on) end)
makeToggle(settingsPnl,"Show Notifications",function(on) print("Notifications:",on) end)
makeToggle(settingsPnl,"Performance Mode",function(on) print("Performance:",on) end)

-- Info Page
local infoText = new("TextLabel",{
    Parent=infoPage,
    Size=UDim2.new(0.96,0,0,450),
    BackgroundColor3=colors.glass,
    BackgroundTransparency=0.3,
    BorderSizePixel=0,
    Text=[[
🌟 KEABY ULTRA v4.0

Advanced fishing automation with modern cyberpunk design.

⚡ INSTANT FISHING
• Ultra-fast automation
• Customizable delays
• Safe configurations

🚀 2X SPEED MODE
• Double efficiency
• Independent controls
• Optimized performance

⚙️ SETTINGS
• Auto-save
• Notifications
• Performance mode

💡 USAGE TIPS
• Lower delay = faster (riskier)
• Higher delay = safer (slower)
• Recommended: 0.12s fishing, 0.05s cancel

🎮 CONTROLS
• Drag top bar to move
• Click (─) to minimize
• Click (×) to close

Created with 💎 by Keaby Team
Ultra Modern Edition 2024
    ]],
    Font=Enum.Font.Gotham,
    TextSize=11,
    TextColor3=colors.textDim,
    TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Top,
    ZIndex=7
})
new("UICorner",{Parent=infoText,CornerRadius=UDim.new(0,14)})
new("UIStroke",{Parent=infoText,Color=colors.primary,Thickness=1.5,Transparency=0.6})
new("UIPadding",{Parent=infoText,PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})

-- Minimized Icon
local minimized=false
local icon
local savedIconPos = UDim2.new(0,30,0,150)

local function createMinimizedIcon()
    if icon then return end
    icon=new("Frame",{
        Parent=gui,
        Size=UDim2.new(0,70,0,70),
        Position=savedIconPos,
        BackgroundColor3=colors.darkest,
        BorderSizePixel=0,
        ZIndex=100
    })
    new("UICorner",{Parent=icon,CornerRadius=UDim.new(0,18)})
    
    local iconStroke = new("UIStroke",{Parent=icon,Color=colors.primary,Thickness=2.5,Transparency=0.2})
    local iconGrad = new("UIGradient",{
        Parent=iconStroke,
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0, colors.primary),
            ColorSequenceKeypoint.new(1, colors.secondary)
        },
        Rotation=0
    })
    
    task.spawn(function()
        while icon and icon.Parent do
            for i = 0, 360, 3 do
                if not icon or not icon.Parent then break end
                iconGrad.Rotation = i
                task.wait(0.02)
            end
        end
    end)
    
    local logoK = new("TextLabel",{
        Parent=icon,
        Text="K",
        Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold,
        TextSize=36,
        BackgroundTransparency=1,
        TextColor3=colors.primary,
        ZIndex=101
    })
    
    local dragging,dragStart,startPos,dragMoved = false,nil,nil,false
    icon.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging,dragMoved,dragStart,startPos = true,false,input.Position,icon.Position
        end
    end)
    
    icon.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.sqrt(delta.X^2 + delta.Y^2) > 5 then dragMoved = true end
            icon.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
        end
    end)
    
    icon.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                savedIconPos = icon.Position
                if not dragMoved then
                    inputBlocker.Visible,blurBg.Visible,win.Visible = true,true,true
                    TweenService:Create(win,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,700,0,450),Position=UDim2.new(0.5,-350,0.5,-225)}):Play()
                    if icon then icon:Destroy() icon = nil end
                    minimized = false
                end
            end
        end
    end)
end

btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        TweenService:Create(win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        TweenService:Create(inputBlocker,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        TweenService:Create(blurBg,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.4)
        win.Visible,inputBlocker.Visible,blurBg.Visible = false,false,false
        createMinimizedIcon()
        minimized = true
    end
end)

btnClose.MouseButton1Click:Connect(function()
    TweenService:Create(win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0),Rotation=180}):Play()
    TweenService:Create(inputBlocker,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
    TweenService:Create(blurBg,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
    task.wait(0.4)
    gui:Destroy()
end)

-- Draggable Window
local dragging,dragStart,startPos = false,nil,nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging,dragStart,startPos = true,input.Position,win.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset + delta.X,startPos.Y.Scale,startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
        dragging = false 
    end
end)

-- Opening Animation
task.spawn(function()
    win.Size = UDim2.new(0,0,0,0)
    win.Position = UDim2.new(0.5,0,0.5,0)
    inputBlocker.Visible,blurBg.Visible = true,true
    inputBlocker.BackgroundTransparency = 1
    blurBg.BackgroundTransparency = 1
    
    task.wait(0.1)
    
    TweenService:Create(inputBlocker,TweenInfo.new(0.4),{BackgroundTransparency=0.3}):Play()
    TweenService:Create(blurBg,TweenInfo.new(0.4),{BackgroundTransparency=0.15}):Play()
    TweenService:Create(win,TweenInfo.new(0.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,700,0,450),
        Position=UDim2.new(0.5,-350,0.5,-225)
    }):Play()
end)

print("✨ Keaby GUI v4.0 Ultra FIXED loaded successfully!")
print("🎨 Refined Cyberpunk Design | Compact Layout")
print("🔧 Fixed overflow issues - all elements stay within bounds")
print("💎 Created by Keaby Team")
