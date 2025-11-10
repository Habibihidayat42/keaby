-- KeabyGUI_v4.0.lua - Ultra Modern Edition (MOBILE OPTIMIZED)
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
local TeleportModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/TeleportModule.lua"))()
local TeleportToPlayer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/TeleportSystem/TeleportToPlayer.lua"))()
local AutoSell = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/ShopFeatures/AutoSell.lua"))()
local AutoSellTimer = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/ShopFeatures/AutoSellTimer.lua"))()
local AntiAFK = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Misc/AntiAFK.lua"))()
local UnlockFPS = loadstring(game:HttpGet("https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Misc/UnlockFPS.lua"))()



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

-- FIXED: Smaller window size for mobile (reduced from 700x450 to 520x380)
local win = new("Frame",{
    Parent=gui,
    Size=UDim2.new(0,520,0,380),
    Position=UDim2.new(0.5,-260,0.5,-190),
    BackgroundColor3=colors.darkest,
    BackgroundTransparency=0.05,
    BorderSizePixel=0,
    ClipsDescendants=true,
    ZIndex=3
})
new("UICorner",{Parent=win,CornerRadius=UDim.new(0,16)})

-- Animated border
local neonBorder = new("UIStroke",{
    Parent=win,
    Color=colors.primary,
    Thickness=2,
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

-- Top Bar (smaller)
local topBar = new("Frame",{
    Parent=win,
    Size=UDim2.new(1,0,0,50),
    BackgroundColor3=colors.dark,
    BackgroundTransparency=0.1,
    BorderSizePixel=0,
    ZIndex=4
})
new("UICorner",{Parent=topBar,CornerRadius=UDim.new(0,16)})

-- Logo Container (smaller)
local logoContainer = new("Frame",{
    Parent=topBar,
    Size=UDim2.new(0,38,0,38),
    Position=UDim2.new(0,10,0.5,-19),
    BackgroundColor3=colors.darkest,
    BorderSizePixel=0,
    ZIndex=5
})
new("UICorner",{Parent=logoContainer,CornerRadius=UDim.new(0,10)})

local logoStroke = new("UIStroke",{
    Parent=logoContainer,
    Color=colors.primary,
    Thickness=1.8,
    Transparency=0.3
})

local logoText = new("TextLabel",{
    Parent=logoContainer,
    Text="K",
    Size=UDim2.new(1,0,1,0),
    Font=Enum.Font.GothamBold,
    TextSize=22,
    BackgroundTransparency=1,
    TextColor3=colors.primary,
    ZIndex=6
})

-- Title (smaller)
local titleLabel = new("TextLabel",{
    Parent=topBar,
    Text="Keabyy",
    Size=UDim2.new(0,150,1,0),
    Position=UDim2.new(0,55,0,0),
    Font=Enum.Font.GothamBold,
    TextSize=16,
    BackgroundTransparency=1,
    TextColor3=colors.text,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5
})

-- Control Buttons (smaller)
local controlsContainer = new("Frame",{
    Parent=topBar,
    Size=UDim2.new(0,75,0,30),
    Position=UDim2.new(1,-82,0.5,-15),
    BackgroundTransparency=1,
    ZIndex=5
})
new("UIListLayout",{
    Parent=controlsContainer,
    FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Right,
    Padding=UDim.new(0,6)
})

local function createControlButton(icon, hoverColor)
    local btn = new("TextButton",{
        Parent=controlsContainer,
        Text=icon,
        Size=UDim2.new(0,30,0,30),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        Font=Enum.Font.GothamBold,
        TextSize=icon == "×" and 20 or 16,
        TextColor3=colors.textDim,
        AutoButtonColor=false,
        ZIndex=6
    })
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
    new("UIStroke",{Parent=btn,Color=colors.border,Thickness=1.2,Transparency=0.6})
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{
            BackgroundColor3=hoverColor,
            BackgroundTransparency=0,
            TextColor3=colors.text,
            Size=UDim2.new(0,32,0,32)
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.2),{
            BackgroundColor3=colors.glass,
            BackgroundTransparency=0.3,
            TextColor3=colors.textDim,
            Size=UDim2.new(0,30,0,30)
        }):Play()
    end)
    return btn
end

local btnMin = createControlButton("─", colors.warning)
local btnClose = createControlButton("×", colors.danger)

-- Sidebar (smaller)
local sidebar = new("Frame",{
    Parent=win,
    Size=UDim2.new(0,130,1,-60),
    Position=UDim2.new(0,6,0,54),
    BackgroundColor3=colors.sidebarBg,
    BackgroundTransparency=0.2,
    BorderSizePixel=0,
    ZIndex=4
})
new("UICorner",{Parent=sidebar,CornerRadius=UDim.new(0,12)})
new("UIStroke",{Parent=sidebar,Color=colors.border,Thickness=1.2,Transparency=0.6})

local navContainer = new("Frame",{
    Parent=sidebar,
    Size=UDim2.new(1,-12,1,-12),
    Position=UDim2.new(0,6,0,6),
    BackgroundTransparency=1,
    ZIndex=5
})
new("UIListLayout",{
    Parent=navContainer,
    Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder
})

local currentPage = "Main"
local navButtons = {}

local function createNavButton(text, icon, page)
    local btn = new("TextButton",{
        Parent=navContainer,
        Size=UDim2.new(1,0,0,38),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=page == currentPage and 0.1 or 0.5,
        BorderSizePixel=0,
        Text="",
        AutoButtonColor=false,
        ZIndex=7
    })
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,10)})
    
    local btnStroke = new("UIStroke",{
        Parent=btn,
        Color=page == currentPage and colors.primary or colors.border,
        Thickness=page == currentPage and 1.8 or 1.2,
        Transparency=page == currentPage and 0.3 or 0.7
    })
    
    local iconLabel = new("TextLabel",{
        Parent=btn,
        Size=UDim2.new(0,28,1,0),
        Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,
        Text=icon,
        Font=Enum.Font.GothamBold,
        TextSize=15,
        TextColor3=page == currentPage and colors.primary or colors.textDim,
        ZIndex=8
    })
    
    local textLabel = new("TextLabel",{
        Parent=btn,
        Size=UDim2.new(1,-38,1,0),
        Position=UDim2.new(0,34,0,0),
        BackgroundTransparency=1,
        Text=text,
        Font=Enum.Font.GothamSemibold,
        TextSize=11,
        TextColor3=page == currentPage and colors.text or colors.textDim,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8
    })
    
    navButtons[page] = {btn=btn, icon=iconLabel, text=textLabel, stroke=btnStroke}
    return btn
end

-- Content Area (adjusted)
local contentBg = new("Frame",{
    Parent=win,
    Size=UDim2.new(1,-145,1,-64),
    Position=UDim2.new(0,142,0,57),
    BackgroundColor3=colors.darker,
    BackgroundTransparency=0.15,
    BorderSizePixel=0,
    ClipsDescendants=true,
    ZIndex=4
})
new("UICorner",{Parent=contentBg,CornerRadius=UDim.new(0,12)})
new("UIStroke",{Parent=contentBg,Color=colors.border,Thickness=1.2,Transparency=0.6})

local pages = {}

local function createPage(name)
    local page = new("ScrollingFrame",{
        Parent=contentBg,
        Size=UDim2.new(1,-12,1,-12),
        Position=UDim2.new(0,6,0,6),
        BackgroundTransparency=1,
        ScrollBarThickness=4,
        ScrollBarImageColor3=colors.primary,
        BorderSizePixel=0,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,
        ClipsDescendants=true,
        ZIndex=5
    })
    new("UIListLayout",{
        Parent=page,
        Padding=UDim.new(0,10),
        SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment=Enum.HorizontalAlignment.Center
    })
    new("UIPadding",{
        Parent=page,
        PaddingTop=UDim.new(0,6),
        PaddingBottom=UDim.new(0,6),
        PaddingLeft=UDim.new(0,3),
        PaddingRight=UDim.new(0,3)
    })
    pages[name] = page
    return page
end

local mainPage = createPage("Main")
local teleportPage = createPage("Teleport")
local shopPage = createPage("Shop")
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
        btnData.stroke.Thickness = isActive and 1.8 or 1.2
        btnData.stroke.Transparency = isActive and 0.3 or 0.7
        btnData.icon.TextColor3 = isActive and colors.primary or colors.textDim
        btnData.text.TextColor3 = isActive and colors.text or colors.textDim
    end
    
    pages[pageName].Visible = true
    currentPage = pageName
end

local btnMain = createNavButton("Main", "🏠", "Main")
local btnTeleport = createNavButton("Teleport", "🌍", "Teleport")
local btnShop = createNavButton("Shop Features", "🛒", "Shop")
local btnSettings = createNavButton("Settings", "⚙️", "Settings")
local btnInfo = createNavButton("Info", "ℹ️", "Info")

btnMain.MouseButton1Click:Connect(function() switchPage("Main") end)
btnTeleport.MouseButton1Click:Connect(function() switchPage("Teleport") end)
btnShop.MouseButton1Click:Connect(function() switchPage("Shop") end)
btnSettings.MouseButton1Click:Connect(function() switchPage("Settings") end)
btnInfo.MouseButton1Click:Connect(function() switchPage("Info") end)

-- Compact Toggle (smaller)
local function makeToggle(parent,label,callback)
    local f=new("Frame",{
        Parent=parent,
        Size=UDim2.new(1,0,0,32),
        BackgroundTransparency=1,
        ZIndex=6
    })
    
    new("TextLabel",{
        Parent=f,
        Text=label,
        Size=UDim2.new(0.6,0,1,0),
        TextXAlignment=Enum.TextXAlignment.Left,
        BackgroundTransparency=1,
        TextColor3=colors.text,
        Font=Enum.Font.GothamMedium,
        TextSize=10,
        TextWrapped=true,
        ZIndex=7
    })
    
    local toggleBg=new("Frame",{
        Parent=f,
        Size=UDim2.new(0,42,0,22),
        Position=UDim2.new(1,-44,0.5,-11),
        BackgroundColor3=colors.border,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        ZIndex=7
    })
    new("UICorner",{Parent=toggleBg,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=toggleBg,Color=colors.border,Thickness=1.2,Transparency=0.5})
    
    local toggleCircle=new("Frame",{
        Parent=toggleBg,
        Size=UDim2.new(0,16,0,16),
        Position=UDim2.new(0,3,0.5,-8),
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
            Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
            BackgroundColor3=on and colors.text or colors.textDim
        }):Play()
        callback(on)
    end)
end

-- Compact Slider (smaller)
local function makeSlider(parent,label,min,max,def,onChange)
    local f=new("Frame",{
        Parent=parent,
        Size=UDim2.new(1,0,0,45),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        ZIndex=6
    })
    
    local lbl=new("TextLabel",{
        Parent=f,
        Text=("%s: %.2fs"):format(label,def),
        Size=UDim2.new(1,0,0,16),
        BackgroundTransparency=1,
        TextColor3=colors.text,
        TextXAlignment=Enum.TextXAlignment.Left,
        Font=Enum.Font.GothamMedium,
        TextSize=10,
        ZIndex=7
    })
    
    local bar=new("Frame",{
        Parent=f,
        Size=UDim2.new(1,-6,0,8),
        Position=UDim2.new(0,3,0,26),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.4,
        BorderSizePixel=0,
        ClipsDescendants=false,
        ZIndex=7
    })
    new("UICorner",{Parent=bar,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=bar,Color=colors.border,Thickness=1.2,Transparency=0.7})
    
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
        Size=UDim2.new(0,16,0,16),
        Position=UDim2.new((def-min)/(max-min),-8,0.5,-8),
        BackgroundColor3=colors.text,
        BorderSizePixel=0,
        ZIndex=9
    })
    new("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})
    new("UIStroke",{Parent=knob,Color=colors.primary,Thickness=1.5,Transparency=0.4})
    
    local dragging=false
    local function update(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        local val=min+(max-min)*rel
        fill.Size=UDim2.new(rel,0,1,0)
        knob.Position=UDim2.new(rel,-8,0.5,-8)
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

-- Compact Panel (smaller)
local function makePanel(parent,title,icon)
    local p=new("Frame",{
        Parent=parent,
        Size=UDim2.new(0.96,0,0,50),
        BackgroundColor3=colors.glass,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        ClipsDescendants=true,
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=6
    })
    new("UICorner",{Parent=p,CornerRadius=UDim.new(0,12)})
    new("UIStroke",{Parent=p,Color=colors.primary,Thickness=1.2,Transparency=0.6})
    
    local header=new("Frame",{
        Parent=p,
        Size=UDim2.new(1,0,0,35),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=7
    })
    
    new("TextLabel",{
        Parent=header,
        Text=icon.." "..title,
        Size=UDim2.new(1,-16,1,0),
        Position=UDim2.new(0,8,0,0),
        Font=Enum.Font.GothamBold,
        TextSize=12,
        TextColor3=colors.text,
        BackgroundTransparency=1,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=8
    })
    
    local container=new("Frame",{
        Parent=p,
        Size=UDim2.new(1,-16,0,0),
        Position=UDim2.new(0,8,0,38),
        BackgroundTransparency=1,
        ClipsDescendants=false,
        AutomaticSize=Enum.AutomaticSize.Y,
        ZIndex=7
    })
    new("UIListLayout",{
        Parent=container,
        Padding=UDim.new(0,6),
        SortOrder=Enum.SortOrder.LayoutOrder
    })
    new("UIPadding",{
        Parent=container,
        PaddingBottom=UDim.new(0,8)
    })
    
    return container
end

-- IMPROVED DROPDOWN FUNCTION
local function makeDropdown(parent, title, icon, items, onSelect, uniqueId)
    local dropdownFrame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(0.96, 0, 0, 44),
        BackgroundColor3 = colors.glass,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 6,
        Name = uniqueId or "Dropdown"
    })
    new("UICorner", {Parent = dropdownFrame, CornerRadius = UDim.new(0, 14)})
    
    local dropStroke = new("UIStroke", {
        Parent = dropdownFrame, 
        Color = colors.primary, 
        Thickness = 1.5, 
        Transparency = 0.5
    })
    
    -- Gradient background
    local dropGradient = new("UIGradient", {
        Parent = dropdownFrame,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, colors.glass),
            ColorSequenceKeypoint.new(1, colors.darker)
        },
        Rotation = 45,
        Transparency = NumberSequence.new(0.3)
    })
    
    local header = new("TextButton", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -16, 0, 38),
        Position = UDim2.new(0, 8, 0, 3),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 7
    })
    
    local iconLabel = new("TextLabel", {
        Parent = header,
        Text = icon,
        Size = UDim2.new(0, 24, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = colors.primary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })
    
    local headerLabel = new("TextLabel", {
        Parent = header,
        Text = title,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    })
    
    local arrow = new("TextLabel", {
        Parent = header,
        Text = "▼",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = colors.primary,
        ZIndex = 8
    })
    
    local listContainer = new("ScrollingFrame", {
        Parent = dropdownFrame,
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 46),
        BackgroundTransparency = 1,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.primary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 10
    })
    new("UIListLayout", {Parent = listContainer, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
    new("UIPadding", {Parent = listContainer, PaddingBottom = UDim.new(0, 8)})
    
    local isOpen = false
    local selectedItem = nil
    
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        listContainer.Visible = isOpen
        
        -- Animate arrow
        TweenService:Create(arrow, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
            Rotation = isOpen and 180 or 0
        }):Play()
        
        -- Animate dropdown
        TweenService:Create(dropStroke, TweenInfo.new(0.2), {
            Color = isOpen and colors.success or colors.primary,
            Thickness = isOpen and 2 or 1.5,
            Transparency = isOpen and 0.3 or 0.5
        }):Play()
        
        -- Limit height for scrolling
        if isOpen and #items > 6 then
            listContainer.Size = UDim2.new(1, -16, 0, 180)
        else
            listContainer.Size = UDim2.new(1, -16, 0, math.min(#items * 35, 210))
        end
    end)
    
    local itemButtons = {}
    
    local function resetAllButtons()
        for _, btn in pairs(itemButtons) do
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = colors.darker,
                BackgroundTransparency = 0.4,
                TextColor3 = colors.textDim
            }):Play()
            if btn:FindFirstChild("UIStroke") then
                btn.UIStroke.Color = colors.border
                btn.UIStroke.Transparency = 0.7
            end
        end
    end
    
    for _, itemName in ipairs(items) do
        local itemBtn = new("TextButton", {
            Parent = listContainer,
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = colors.darker,
            BackgroundTransparency = 0.4,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 11
        })
        new("UICorner", {Parent = itemBtn, CornerRadius = UDim.new(0, 9)})
        
        local btnStroke = new("UIStroke", {
            Parent = itemBtn, 
            Color = colors.border, 
            Thickness = 1.2, 
            Transparency = 0.7
        })
        
        local btnIcon = new("TextLabel", {
            Parent = itemBtn,
            Text = "◆",
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 9,
            TextColor3 = colors.primary,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 12
        })
        
        local btnLabel = new("TextLabel", {
            Parent = itemBtn,
            Text = itemName,
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = 10,
            TextColor3 = colors.textDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12
        })
        
        table.insert(itemButtons, itemBtn)
        
        itemBtn.MouseEnter:Connect(function()
            if selectedItem ~= itemName then
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = colors.primary,
                    BackgroundTransparency = 0.15,
                }):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.15), {
                    TextColor3 = colors.text
                }):Play()
                TweenService:Create(btnIcon, TweenInfo.new(0.15), {
                    TextColor3 = colors.text
                }):Play()
                TweenService:Create(btnStroke, TweenInfo.new(0.15), {
                    Color = colors.primary,
                    Transparency = 0.4
                }):Play()
            end
        end)
        
        itemBtn.MouseLeave:Connect(function()
            if selectedItem ~= itemName then
                TweenService:Create(itemBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = colors.darker,
                    BackgroundTransparency = 0.4,
                }):Play()
                TweenService:Create(btnLabel, TweenInfo.new(0.15), {
                    TextColor3 = colors.textDim
                }):Play()
                TweenService:Create(btnIcon, TweenInfo.new(0.15), {
                    TextColor3 = colors.primary
                }):Play()
                TweenService:Create(btnStroke, TweenInfo.new(0.15), {
                    Color = colors.border,
                    Transparency = 0.7
                }):Play()
            end
        end)
        
        itemBtn.MouseButton1Click:Connect(function()
            resetAllButtons()
            selectedItem = itemName
            onSelect(itemName)
            
            -- Close dropdown after selection
            task.wait(0.1)
            isOpen = false
            listContainer.Visible = false
            TweenService:Create(arrow, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
                Rotation = 0
            }):Play()
            TweenService:Create(dropStroke, TweenInfo.new(0.2), {
                Color = colors.primary,
                Thickness = 1.5,
                Transparency = 0.5
            }):Play()
        end)
    end
    
    return dropdownFrame
end

-- Main Page Content
local pnl1=makePanel(mainPage,"⚡ Instant Fishing","")
makeToggle(pnl1,"Enable Instant Fishing",function(on) if on then instant.Start() else instant.Stop() end end)
makeSlider(pnl1,"Fishing Delay",0.01,5.0,1.30,function(v) instant.Settings.MaxWaitTime=v end)
makeSlider(pnl1,"Cancel Delay",0.01,1.5,0.19,function(v) instant.Settings.CancelDelay=v end)

local pnl2=makePanel(mainPage,"🚀 Instant 2x Speed","")
makeToggle(pnl2,"Enable Instant 2x Speed",function(on) if on then instant2x.Start() else instant2x.Stop() end end)
makeSlider(pnl2,"Fishing Delay",0,5.0,0.3,function(v) instant2x.Settings.FishingDelay=v end)
makeSlider(pnl2,"Cancel Delay",0.01,1.5,0.19,function(v) instant2x.Settings.CancelDelay=v end)

-- Teleport Page with Dropdowns
local locationItems = {}
for name, _ in pairs(TeleportModule.Locations) do
    table.insert(locationItems, name)
end
table.sort(locationItems)

makeDropdown(teleportPage, "Teleport to Location", "📍", locationItems, function(selectedLocation)
    TeleportModule.TeleportTo(selectedLocation)
    print("Teleporting to: " .. selectedLocation)
end)

local playerItems = {}
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        table.insert(playerItems, player.Name)
    end
end
table.sort(playerItems)

makeDropdown(teleportPage, "Teleport to Player", "👤", playerItems, function(selectedPlayer)
    TeleportToPlayer.TeleportTo(selectedPlayer)
    print("Teleporting to player: " .. selectedPlayer)
end)

-- === Dynamic Update for Player Dropdown ===
local function refreshPlayerList()
    table.clear(playerItems)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(playerItems, player.Name)
        end
    end
    table.sort(playerItems)
end

-- Refresh list when player joins or leaves
Players.PlayerAdded:Connect(function()
    refreshPlayerList()
end)
Players.PlayerRemoving:Connect(function()
    refreshPlayerList()
end)

-- === AUTO SELL BUTTON SECTION ===

-- 🧩 Compact Button (consistent with Keaby style)
local function makeButton(parent, label, callback)
    local btnFrame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(0.96, 0, 0, 40),
        BackgroundColor3 = colors.darker,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        ZIndex = 7
    })
    new("UICorner", { Parent = btnFrame, CornerRadius = UDim.new(0, 10) })
    new("UIStroke", { Parent = btnFrame, Color = colors.border, Thickness = 1.2, Transparency = 0.6 })

    local button = new("TextButton", {
        Parent = btnFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = colors.text,
        AutoButtonColor = false,
        ZIndex = 8
    })

    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.15), {
            BackgroundTransparency = 0,
            BackgroundColor3 = colors.primary
        }):Play()
        TweenService:Create(button, TweenInfo.new(0.15), {
            TextColor3 = colors.dark
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.15), {
            BackgroundTransparency = 0.25,
            BackgroundColor3 = colors.darker
        }):Play()
        TweenService:Create(button, TweenInfo.new(0.15), {
            TextColor3 = colors.text
        }):Play()
    end)

    button.MouseButton1Click:Connect(function()
        pcall(function()
            callback()
        end)
    end)

    return btnFrame
end


-- === SHOP PANEL & BUTTON ===
local pnlSell = makePanel(shopPage, "💰 Auto Sell System", "")

makeButton(pnlSell, "Sell All", function()
	if AutoSell and AutoSell.SellOnce then
		print("🟢 [GUI] Sell All button pressed")
		AutoSell.SellOnce()
	else
		warn("❌ AutoSell module not loaded or missing SellOnce()")
	end
end)

-- 💡 Compact Switch Button (Keaby style)
local function makeSwitch(parent, label, default, callback)
    local frame = new("Frame", {
        Parent = parent,
        Size = UDim2.new(0.96, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })

    new("TextLabel", {
        Parent = frame,
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = colors.text,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local switch = new("Frame", {
        Parent = frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -5, 0.5, 0),
        Size = UDim2.new(0, 46, 0, 24),
        BackgroundColor3 = default and colors.primary or Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
    })
    new("UICorner", { Parent = switch, CornerRadius = UDim.new(1, 0) })

    local knob = new("Frame", {
        Parent = switch,
        Size = UDim2.new(0, 20, 0, 20),
        Position = default and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(220, 220, 220),
        BorderSizePixel = 0,
    })
    new("UICorner", { Parent = knob, CornerRadius = UDim.new(1, 0) })

    local state = default

    local function setState(on)
        state = on
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = on and colors.primary or Color3.fromRGB(60, 60, 60)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = on and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }):Play()

        pcall(function() callback(on) end)
    end

    local button = new("TextButton", {
        Parent = switch,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })

    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return frame
end

-- === PANEL ===
local pnlTimer = makePanel(shopPage, "⏰ Auto Sell Timer", "")

-- === SLIDER UNTUK INTERVAL ===
makeSlider(pnlTimer, "Sell Interval (detik)", 1, 60, 5, function(value)
	AutoSellTimer.SetInterval(value)
end)

-- === TOMBOL START ===
makeButton(pnlTimer, "Start Auto Sell", function()
	if AutoSellTimer then
		AutoSellTimer.Start(AutoSellTimer.Interval)
	else
		warn("❌ AutoSellTimer belum dimuat!")
	end
end)

-- === TOMBOL STOP ===
makeButton(pnlTimer, "Stop Auto Sell", function()
	if AutoSellTimer then
		AutoSellTimer.Stop()
	else
		warn("❌ AutoSellTimer belum dimuat!")
	end
end)

-- Settings Page
local settingsPnl = makePanel(settingsPage,"⚙️ General Settings","")
-- 🔒 Anti-AFK Panel
local pnlAntiAFK = makePanel(settingsPage, "Anti-AFK Protection", "🧍‍♂️")

makeToggle(pnlAntiAFK, "Enable Anti-AFK", function(on)
    if on then
        AntiAFK.Start()
    else
        AntiAFK.Stop()
    end
end)

-- === FPS SETTINGS PANEL ===
local pnlFPS = makePanel(settingsPage, "🎞️ FPS Unlocker", "")
makeDropdown(pnlFPS, "Select FPS Limit", "⚙️", {"60 FPS", "90 FPS", "120 FPS", "240 FPS"}, function(selected)
    local fpsValue = tonumber(selected:match("%d+"))
    if fpsValue then
        if UnlockFPS and UnlockFPS.SetCap then
            UnlockFPS.SetCap(fpsValue)
            print("[KeabyGUI] FPS cap set to:", fpsValue)
        else
            warn("[KeabyGUI] ⚠️ UnlockFPS module not loaded or missing SetCap()")
        end
    else
        warn("[KeabyGUI] Invalid FPS selection:", selected)
    end
end, "FPSDropdown")



makeToggle(settingsPnl,"Auto Save Settings",function(on) print("Auto Save:",on) end)
makeToggle(settingsPnl,"Show Notifications",function(on) print("Notifications:",on) end)
makeToggle(settingsPnl,"Performance Mode",function(on) print("Performance:",on) end)

-- Info Page
local infoText = new("TextLabel",{
    Parent=infoPage,
    Size=UDim2.new(0.96,0,0,350),
    BackgroundColor3=colors.glass,
    BackgroundTransparency=0.3,
    BorderSizePixel=0,
    Text=[[
🌟 KEABY ULTRA v4.0

Advanced fishing automation
Mobile optimized interface

⚡ INSTANT FISHING
• Ultra-fast automation
• Customizable delays
• Safe configurations

🚀 2X SPEED MODE
• Double efficiency
• Independent controls
• Optimized performance

🌍 TELEPORT
• Location teleport
• Player teleport
• Dropdown selection

⚙️ SETTINGS
• Auto-save
• Notifications
• Performance mode

💡 TIPS
• Lower delay = faster (risky)
• Higher delay = safer (slow)
• Recommended settings:
  1.30s fishing, 0.19s cancel

🎮 CONTROLS
• Drag top bar to move
• (─) to minimize
• (×) to close

Created with 💎 by Keaby Team
Mobile Edition 2024
    ]],
    Font=Enum.Font.Gotham,
    TextSize=9,
    TextColor3=colors.textDim,
    TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left,
    TextYAlignment=Enum.TextYAlignment.Top,
    ZIndex=7
})
new("UICorner",{Parent=infoText,CornerRadius=UDim.new(0,12)})
new("UIStroke",{Parent=infoText,Color=colors.primary,Thickness=1.2,Transparency=0.6})
new("UIPadding",{Parent=infoText,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

-- FIXED: Minimized Icon (smaller size: 50x50)
local minimized=false
local icon
local savedIconPos = UDim2.new(0,20,0,120)

local function createMinimizedIcon()
    if icon then return end
    icon=new("Frame",{
        Parent=gui,
        Size=UDim2.new(0,50,0,50),  -- FIXED: Reduced from 70x70 to 50x50
        Position=savedIconPos,
        BackgroundColor3=colors.darkest,
        BorderSizePixel=0,
        ZIndex=100
    })
    new("UICorner",{Parent=icon,CornerRadius=UDim.new(0,14)})
    
    local iconStroke = new("UIStroke",{Parent=icon,Color=colors.primary,Thickness=2,Transparency=0.2})
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
        TextSize=26,  -- FIXED: Reduced from 36 to 26
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
                    TweenService:Create(win,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,520,0,380),Position=UDim2.new(0.5,-260,0.5,-190)}):Play()
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
        Size=UDim2.new(0,520,0,380),
        Position=UDim2.new(0.5,-260,0.5,-190)
    }):Play()
end)

print("✨ Keaby GUI v4.0 Ultra MOBILE OPTIMIZED loaded!")
print("📱 Perfect for mobile devices")
print("🔧 Smaller UI, dropdown teleport system")
print("💎 Created by Keaby Team")
