-- KeabyGUI_v4.1 (Performance Edition) - OPTIMIZED
-- Neon Cyberpunk Theme - Fast-load + Low CPU

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Wait for PlayerGui in a single efficient loop
repeat task.wait() until game:IsLoaded() and Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")

-- small helper to create instances quickly
local function new(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do inst[k] = v end
    return inst
end

-- ------------------------------
-- MODULE LOADING (ASYNC + SAFE)
-- ------------------------------
local Modules = {}
local ModuleURLs = {
    Instant = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant.lua",
    Instant2X = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Instant2Xspeed.lua",
    Teleport = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/TeleportModule.lua",
    TeleportToPlayer = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/TeleportSystem/TeleportToPlayer.lua",
    AutoSell = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/ShopFeatures/AutoSell.lua",
    AutoSellTimer = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/ShopFeatures/AutoSellTimer.lua",
    AntiAFK = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Misc/AntiAFK.lua",
    UnlockFPS = "https://raw.githubusercontent.com/Habibihidayat42/keaby/refs/heads/main/FungsiKeaby/Misc/UnlockFPS.lua"
}

-- Create safe stub (so UI won't error if module not loaded yet)
local function make_stub(name)
    local t = {}
    t.Start = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.Stop  = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.SetInterval = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.SetCap = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.SellOnce = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.TeleportTo = function() warn("[KeabyGUI] Module '"..name.."' not ready yet.") end
    t.Locations = {}
    return t
end

-- prefill Modules with stubs
for name,_ in pairs(ModuleURLs) do
    Modules[name] = make_stub(name)
end

-- Async download & load modules in parallel (non-blocking)
task.spawn(function()
    for name, url in pairs(ModuleURLs) do
        task.spawn(function()
            local ok, res = pcall(function()
                local body = game:HttpGet(url)
                local f = loadstring(body)
                if f then
                    return f()
                end
            end)
            if ok and res then
                Modules[name] = res
                print("[KeabyGUI] Module loaded:", name)
            else
                warn("[KeabyGUI] Failed to load module:", name, res)
            end
        end)
    end
end)

-- expose common names for convenience (will point to stub until real module replaces it)
local instant = Modules.Instant
local instant2x = Modules.Instant2X
local TeleportModule = Modules.Teleport
local TeleportToPlayer = Modules.TeleportToPlayer
local AutoSell = Modules.AutoSell
local AutoSellTimer = Modules.AutoSellTimer
local AntiAFK = Modules.AntiAFK
local UnlockFPS = Modules.UnlockFPS

-- When module table replaced later, update local refs (listen for completion)
-- We'll poll Modules table once after a short delay to pick up loaded modules.
task.spawn(function()
    while true do
        -- if actual modules replaced the stub (heuristic: Start ~= stub.Start), update refs
        if Modules.Instant and Modules.Instant.Start ~= make_stub("Instant").Start then instant = Modules.Instant end
        if Modules.Instant2X and Modules.Instant2X.Start ~= make_stub("Instant2X").Start then instant2x = Modules.Instant2X end
        if Modules.Teleport and Modules.Teleport.TeleportTo ~= make_stub("Teleport").TeleportTo then TeleportModule = Modules.Teleport end
        if Modules.TeleportToPlayer and Modules.TeleportToPlayer.TeleportTo ~= make_stub("TeleportToPlayer").TeleportTo then TeleportToPlayer = Modules.TeleportToPlayer end
        if Modules.AutoSell and Modules.AutoSell.SellOnce ~= make_stub("AutoSell").SellOnce then AutoSell = Modules.AutoSell end
        if Modules.AutoSellTimer and Modules.AutoSellTimer.SetInterval ~= make_stub("AutoSellTimer").SetInterval then AutoSellTimer = Modules.AutoSellTimer end
        if Modules.AntiAFK and Modules.AntiAFK.Start ~= make_stub("AntiAFK").Start then AntiAFK = Modules.AntiAFK end
        if Modules.UnlockFPS and Modules.UnlockFPS.SetCap ~= make_stub("UnlockFPS").SetCap then UnlockFPS = Modules.UnlockFPS end
        task.wait(1.5)
    end
end)

-- ------------------------------
-- COLORS / SHARED UTILITIES
-- ------------------------------
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

-- lightweight tween helper (reuse TweenInfo)
local _TI = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local function fastTween(obj, props, time)
    time = time or 0.15
    local t = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ------------------------------
-- INSTANT ANTI-FREEZE GUI (SKELETON)
-- ------------------------------
local gui = new("ScreenGui",{
    Name="KeabyGUI_Ultra_Optimized",
    Parent=localPlayer.PlayerGui,
    IgnoreGuiInset=true,
    ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    DisplayOrder=999
})

-- Input blocker + blur (minimal)
local inputBlocker = new("Frame",{
    Parent=gui,
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=1, -- start hidden to reduce render cost
    BorderSizePixel=0,
    Visible=false,
    ZIndex=1,
    Active=true
})
local blurBg = new("Frame",{
    Parent=gui,
    Size=UDim2.new(1,0,1,0),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    Visible=false,
    ZIndex=2
})

-- Main window skeleton (created immediately, minimal children)
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

local topBar = new("Frame",{ Parent=win, Size=UDim2.new(1,0,0,50), BackgroundColor3=colors.dark, BackgroundTransparency=0.1, BorderSizePixel=0, ZIndex=4 })
new("UICorner",{Parent=topBar,CornerRadius=UDim.new(0,16)})

-- title
local titleLabel = new("TextLabel",{
    Parent=topBar,
    Text="Keaby (loading...)",
    Size=UDim2.new(0,220,1,0),
    Position=UDim2.new(0,12,0,0),
    Font=Enum.Font.GothamBold,
    TextSize=16,
    BackgroundTransparency=1,
    TextColor3=colors.textDim,
    TextXAlignment=Enum.TextXAlignment.Left,
    ZIndex=5
})

-- controls container (placeholders)
local controlsContainer = new("Frame",{ Parent=topBar, Size=UDim2.new(0,75,0,30), Position=UDim2.new(1,-82,0.5,-15), BackgroundTransparency=1, ZIndex=5 })
new("UIListLayout",{ Parent=controlsContainer, FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Right, Padding=UDim.new(0,6) })

local function makeControlButtonSkeleton(icon)
    local btn = new("TextButton",{ Parent = controlsContainer, Text = icon, Size = UDim2.new(0,30,0,30), BackgroundTransparency=0.3, BorderSizePixel=0, Font=Enum.Font.GothamBold, TextSize = 16, TextColor3=colors.textDim, AutoButtonColor=false, ZIndex=6 })
    new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
    return btn
end

local btnMin = makeControlButtonSkeleton("─")
local btnClose = makeControlButtonSkeleton("×")

-- content background skeleton
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

-- Loading placeholder content (shown immediately)
local loadingLabel = new("TextLabel",{
    Parent=contentBg,
    Size=UDim2.new(1,0,1,0),
    Position=UDim2.new(0,0,0,0),
    BackgroundTransparency=1,
    Text="🔄 Loading Keaby GUI modules...\nPlease wait a moment.",
    Font=Enum.Font.Gotham,
    TextSize=14,
    TextWrapped=true,
    TextColor3=colors.textDim,
    ZIndex=5,
    TextYAlignment=Enum.TextYAlignment.Center,
    TextXAlignment=Enum.TextXAlignment.Center
})

-- Show a subtle opening animation (fast)
task.spawn(function()
    win.Size = UDim2.new(0,0,0,0)
    win.Position = UDim2.new(0.5,0,0.5,0)
    inputBlocker.Visible, blurBg.Visible = true, true
    inputBlocker.BackgroundTransparency = 1
    blurBg.BackgroundTransparency = 1

    task.wait(0.05)
    fastTween(inputBlocker, {BackgroundTransparency = 0.3}, 0.25)
    fastTween(blurBg, {BackgroundTransparency = 0.15}, 0.25)
    fastTween(win, {Size = UDim2.new(0,520,0,380), Position = UDim2.new(0.5,-260,0.5,-190)}, 0.35)
    task.wait(0.4)
    inputBlocker.Visible, blurBg.Visible = false, false
end)

-- ------------------------------
-- DEFERRED: build full UI (heavy parts) AFTER skeleton displayed
-- ------------------------------
task.defer(function()
    -- small delay to ensure skeleton rendered first
    task.wait(0.08)

    -- Create reusable stroke/gradient templates to clone (reduces repeated property set cost)
    local baseStroke = Instance.new("UIStroke")
    baseStroke.Color = colors.border
    baseStroke.Thickness = 1.2
    baseStroke.Transparency = 0.6

    local function cloneStroke(parent)
        local s = baseStroke:Clone()
        s.Parent = parent
        return s
    end

    -- Create sidebar & nav buttons (these are heavier and done after skeleton)
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
    cloneStroke(sidebar)

    local navContainer = new("Frame",{
        Parent=sidebar,
        Size=UDim2.new(1,-12,1,-12),
        Position=UDim2.new(0,6,0,6),
        BackgroundTransparency=1,
        ZIndex=5
    })
    new("UIListLayout",{ Parent=navContainer, Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder })

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
        new("UIPadding",{ Parent=page, PaddingTop=UDim.new(0,6), PaddingBottom=UDim.new(0,6), PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3) })
        pages[name] = page
        return page
    end

    local mainPage = createPage("Main")
    local teleportPage = createPage("Teleport")
    local shopPage = createPage("Shop")
    local settingsPage = createPage("Settings")
    local infoPage = createPage("Info")
    mainPage.Visible = true

    -- Nav button creator (lightweight)
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
        cloneStroke(btn)

        local iconLabel = new("TextLabel",{ Parent=btn, Size=UDim2.new(0,28,1,0), Position=UDim2.new(0,6,0,0), BackgroundTransparency=1, Text=icon, Font=Enum.Font.GothamBold, TextSize=15, TextColor3=page == currentPage and colors.primary or colors.textDim, ZIndex=8 })
        local textLabel = new("TextLabel",{ Parent=btn, Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,34,0,0), BackgroundTransparency=1, Text=text, Font=Enum.Font.GothamSemibold, TextSize=11, TextColor3=page == currentPage and colors.text or colors.textDim, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8 })

        navButtons[page] = {btn=btn, icon=iconLabel, text=textLabel}
        btn.MouseButton1Click:Connect(function()
            if currentPage == page then return end
            for _, p in pairs(pages) do p.Visible = false end
            for name, btnData in pairs(navButtons) do
                local isActive = name == page
                btnData.btn.BackgroundTransparency = isActive and 0.1 or 0.5
                btnData.icon.TextColor3 = isActive and colors.primary or colors.textDim
                btnData.text.TextColor3 = isActive and colors.text or colors.textDim
            end
            pages[page].Visible = true
            currentPage = page
        end)
        return btn
    end

    local btnMain = createNavButton("Main", "🏠", "Main")
    local btnTeleport = createNavButton("Teleport", "🌍", "Teleport")
    local btnShop = createNavButton("Shop Features", "🛒", "Shop")
    local btnSettings = createNavButton("Settings", "⚙️", "Settings")
    local btnInfo = createNavButton("Info", "ℹ️", "Info")

    -- Remove loading placeholder now that pages exist; keep until modules ready below
    loadingLabel.Text = "🔄 Loading modules... some features will appear shortly."

    -- Utility creators (toggle, slider, panel) - same logic as before but created now to avoid heavy upfront creation
    local function makePanel(parent,title,icon)
        local p=new("Frame",{ Parent=parent, Size=UDim2.new(0.96,0,0,50), BackgroundColor3=colors.glass, BackgroundTransparency=0.3, BorderSizePixel=0, ClipsDescendants=true, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=6 })
        new("UICorner",{Parent=p,CornerRadius=UDim.new(0,12)})
        cloneStroke(p)
        local header=new("Frame",{ Parent=p, Size=UDim2.new(1,0,0,35), BackgroundTransparency=1, BorderSizePixel=0, ZIndex=7 })
        new("TextLabel",{ Parent=header, Text=icon.." "..title, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0), Font=Enum.Font.GothamBold, TextSize=12, TextColor3=colors.text, BackgroundTransparency=1, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=8 })
        local container=new("Frame",{ Parent=p, Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,38), BackgroundTransparency=1, ClipsDescendants=false, AutomaticSize=Enum.AutomaticSize.Y, ZIndex=7 })
        new("UIListLayout",{ Parent=container, Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder })
        new("UIPadding",{ Parent=container, PaddingBottom=UDim.new(0,8) })
        return container
    end

    local function makeToggle(parent,label,callback)
        local f=new("Frame",{ Parent=parent, Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, ZIndex=6 })
        new("TextLabel",{ Parent=f, Text=label, Size=UDim2.new(0.6,0,1,0), TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1, TextColor3=colors.text, Font=Enum.Font.GothamMedium, TextSize=10, TextWrapped=true, ZIndex=7 })
        local toggleBg=new("Frame",{ Parent=f, Size=UDim2.new(0,42,0,22), Position=UDim2.new(1,-44,0.5,-11), BackgroundColor3=colors.border, BackgroundTransparency=0.3, BorderSizePixel=0, ZIndex=7 })
        new("UICorner",{Parent=toggleBg,CornerRadius=UDim.new(1,0)})
        cloneStroke(toggleBg)
        local toggleCircle=new("Frame",{ Parent=toggleBg, Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,3,0.5,-8), BackgroundColor3=colors.textDim, BorderSizePixel=0, ZIndex=8 })
        new("UICorner",{Parent=toggleCircle,CornerRadius=UDim.new(1,0)})
        local btn=new("TextButton",{ Parent=toggleBg, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=9 })
        local on=false
        btn.MouseButton1Click:Connect(function()
            on = not on
            fastTween(toggleBg, {BackgroundColor3 = on and colors.primary or colors.border, BackgroundTransparency = on and 0 or 0.3}, 0.18)
            fastTween(toggleCircle, {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), BackgroundColor3 = on and colors.text or colors.textDim}, 0.25)
            pcall(function() callback(on) end)
        end)
    end

    local function makeSlider(parent,label,min,max,def,onChange)
        local f=new("Frame",{ Parent=parent, Size=UDim2.new(1,0,0,45), BackgroundTransparency=1, ClipsDescendants=true, ZIndex=6 })
        local lbl=new("TextLabel",{ Parent=f, Text=("%s: %.2fs"):format(label,def), Size=UDim2.new(1,0,0,16), BackgroundTransparency=1, TextColor3=colors.text, TextXAlignment=Enum.TextXAlignment.Left, Font=Enum.Font.GothamMedium, TextSize=10, ZIndex=7 })
        local bar=new("Frame",{ Parent=f, Size=UDim2.new(1,-6,0,8), Position=UDim2.new(0,3,0,26), BackgroundColor3=colors.glass, BackgroundTransparency=0.4, BorderSizePixel=0, ClipsDescendants=false, ZIndex=7 })
        new("UICorner",{Parent=bar,CornerRadius=UDim.new(1,0)})
        cloneStroke(bar)
        local fill=new("Frame",{ Parent=bar, Size=UDim2.new((def-min)/(max-min),0,1,0), BackgroundColor3=colors.primary, BorderSizePixel=0, ZIndex=8 })
        new("UICorner",{Parent=fill,CornerRadius=UDim.new(1,0)})
        local knob=new("Frame",{ Parent=bar, Size=UDim2.new(0,16,0,16), Position=UDim2.new((def-min)/(max-min),-8,0.5,-8), BackgroundColor3=colors.text, BorderSizePixel=0, ZIndex=9 })
        new("UICorner",{Parent=knob,CornerRadius=UDim.new(1,0)})
        new("UIStroke",{Parent=knob,Color=colors.primary,Thickness=1.5,Transparency=0.4})
        local dragging=false
        local function update(x)
            local rel=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
            local val=min+(max-min)*rel
            fill.Size=UDim2.new(rel,0,1,0)
            knob.Position=UDim2.new(rel,-8,0.5,-8)
            lbl.Text=("%s: %.2fs"):format(label,val)
            pcall(function() onChange(val) end)
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true update(i.Position.X) end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    end

    -- Build main page controls (panels + toggles)
    local pnl1 = makePanel(mainPage,"⚡ Instant Fishing","")
    makeToggle(pnl1,"Enable Instant Fishing",function(on) pcall(function() instant.Start(on) end) end)
    makeSlider(pnl1,"Fishing Delay",0.01,5.0,1.30,function(v) pcall(function() instant.Settings.MaxWaitTime = v end) end)
    makeSlider(pnl1,"Cancel Delay",0.01,1.5,0.19,function(v) pcall(function() instant.Settings.CancelDelay = v end) end)

    local pnl2 = makePanel(mainPage,"🚀 Instant 2x Speed","")
    makeToggle(pnl2,"Enable Instant 2x Speed",function(on) pcall(function() instant2x.Start(on) end) end)
    makeSlider(pnl2,"Fishing Delay",0,5.0,0.30,function(v) pcall(function() instant2x.Settings.FishingDelay = v end) end)
    makeSlider(pnl2,"Cancel Delay",0.01,1.5,0.19,function(v) pcall(function() instant2x.Settings.CancelDelay = v end) end)

    -- Teleport dropdowns (build lightweight dropdowns)
    local function makeDropdown(parent, title, icon, items, onSelect)
        local dropdownFrame = new("Frame",{ Parent = parent, Size = UDim2.new(0.96, 0, 0, 44), BackgroundColor3 = colors.glass, BackgroundTransparency = 0.25, BorderSizePixel = 0, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 6 })
        new("UICorner",{Parent = dropdownFrame, CornerRadius = UDim.new(0, 14)})
        cloneStroke(dropdownFrame)
        local header = new("TextButton",{ Parent = dropdownFrame, Size = UDim2.new(1, -16, 0, 38), Position = UDim2.new(0, 8, 0, 3), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 7 })
        new("TextLabel",{ Parent = header, Text = icon.." "..title, Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = colors.text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8 })
        local listContainer = new("Frame",{ Parent = dropdownFrame, Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 0, 46), BackgroundTransparency = 1, Visible = false, ZIndex = 10 })
        new("UIListLayout",{ Parent = listContainer, Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })
        local isOpen = false
        header.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            listContainer.Visible = isOpen
            if isOpen then
                listContainer.Size = UDim2.new(1, -16, 0, math.min(#items * 32, 180))
            else
                listContainer.Size = UDim2.new(1, -16, 0, 0)
            end
        end)
        for _, itemName in ipairs(items) do
            local itemBtn = new("TextButton",{ Parent = listContainer, Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 0.4, BorderSizePixel = 0, Text = itemName, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = colors.textDim, AutoButtonColor=false, ZIndex = 11 })
            new("UICorner",{Parent=itemBtn,CornerRadius=UDim.new(0,9)})
            itemBtn.MouseButton1Click:Connect(function()
                pcall(function() onSelect(itemName) end)
                isOpen = false
                listContainer.Visible = false
            end)
        end
        return dropdownFrame
    end

    -- Teleport locations: if TeleportModule not loaded yet, show placeholder list; refresh later
    local function getLocationItems()
        local out = {}
        local ok, locs = pcall(function() return TeleportModule and TeleportModule.Locations end)
        if ok and locs then
            for name,_ in pairs(locs) do table.insert(out, name) end
            table.sort(out)
        else
            table.insert(out, "Loading locations...")
        end
        return out
    end

    makeDropdown(teleportPage, "Teleport to Location", "📍", getLocationItems(), function(selectedLocation)
        pcall(function()
            if TeleportModule and TeleportModule.TeleportTo then TeleportModule.TeleportTo(selectedLocation) end
        end)
    end)

    -- Player teleport dropdown
    local function getPlayerItems()
        local out = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then table.insert(out, player.Name) end
        end
        table.sort(out)
        if #out == 0 then table.insert(out, "No players") end
        return out
    end

    makeDropdown(teleportPage, "Teleport to Player", "👤", getPlayerItems(), function(selectedPlayer)
        pcall(function() if TeleportToPlayer and TeleportToPlayer.TeleportTo then TeleportToPlayer.TeleportTo(selectedPlayer) end end)
    end)

    -- auto sell panel
    local pnlSell = makePanel(shopPage, "💰 Auto Sell System", "")
    local sellBtn = new("TextButton",{ Parent = pnlSell, Size=UDim2.new(0.96,0,0,40), BackgroundTransparency=0, BackgroundColor3=colors.darker, Text="Sell All", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=colors.text, ZIndex=7 })
    new("UICorner",{Parent=sellBtn,CornerRadius=UDim.new(0,10)})
    cloneStroke(sellBtn)
    sellBtn.MouseButton1Click:Connect(function()
        pcall(function() if AutoSell and AutoSell.SellOnce then AutoSell.SellOnce() else warn("AutoSell not ready") end end)
    end)

    -- auto sell timer
    local pnlTimer = makePanel(shopPage, "⏰ Auto Sell Timer", "")
    makeSlider(pnlTimer, "Sell Interval (detik)", 1, 60, 5, function(value)
        pcall(function() if AutoSellTimer and AutoSellTimer.SetInterval then AutoSellTimer.SetInterval(value) end end)
    end)
    local startBtn = new("TextButton",{ Parent = pnlTimer, Size=UDim2.new(0.96,0,0,40), BackgroundTransparency=0, BackgroundColor3=colors.darker, Text="Start Auto Sell", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=colors.text, ZIndex=7 })
    new("UICorner",{Parent=startBtn,CornerRadius=UDim.new(0,10)})
    cloneStroke(startBtn)
    startBtn.MouseButton1Click:Connect(function()
        pcall(function() if AutoSellTimer and AutoSellTimer.Start then AutoSellTimer.Start(AutoSellTimer.Interval) end end)
    end)
    local stopBtn = new("TextButton",{ Parent = pnlTimer, Size=UDim2.new(0.96,0,0,40), BackgroundTransparency=0, BackgroundColor3=colors.darker, Text="Stop Auto Sell", Font=Enum.Font.GothamBold, TextSize=13, TextColor3=colors.text, ZIndex=7 })
    new("UICorner",{Parent=stopBtn,CornerRadius=UDim.new(0,10)})
    cloneStroke(stopBtn)
    stopBtn.MouseButton1Click:Connect(function() pcall(function() if AutoSellTimer and AutoSellTimer.Stop then AutoSellTimer.Stop() end end) end)

    -- settings: Anti-AFK + FPS dropdown
    local settingsPnl = makePanel(settingsPage,"⚙️ General Settings","")
    local pnlAntiAFK = makePanel(settingsPage, "Anti-AFK Protection", "🧍‍♂️")
    makeToggle(pnlAntiAFK, "Enable Anti-AFK", function(on)
        pcall(function() if AntiAFK and AntiAFK.Start and AntiAFK.Stop then if on then AntiAFK.Start() else AntiAFK.Stop() end end end)
    end)

    -- FPS dropdown (simple)
    local pnlFPS = makePanel(settingsPage, "🎞️ FPS Unlocker", "")
    local fpsDropdown = makeDropdown(pnlFPS, "Select FPS Limit", "⚙️", {"60 FPS","90 FPS","120 FPS","240 FPS"}, function(selected)
        local fpsValue = tonumber(selected:match("%d+"))
        if fpsValue then
            pcall(function() if UnlockFPS and UnlockFPS.SetCap then UnlockFPS.SetCap(fpsValue) else warn("UnlockFPS not ready") end end)
        end
    end)

    -- Info page (copy trimmed info)
    local infoText = new("TextLabel",{ Parent=infoPage, Size=UDim2.new(0.96,0,0,260), BackgroundColor3=colors.glass, BackgroundTransparency=0.3, BorderSizePixel=0, Text="🌟 KEABY ULTRA v4.1\n\nPerformance mode enabled.", Font=Enum.Font.Gotham, TextSize=11, TextColor3=colors.textDim, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, ZIndex=7 })
    new("UICorner",{Parent=infoText,CornerRadius=UDim.new(0,12)})
    cloneStroke(infoText)

    -- finalize: update title to show ready status after modules loaded (poll and update once a core module appears)
    task.spawn(function()
        local tries = 0
        while tries < 30 do
            if Modules.Instant and Modules.Instant.Start ~= make_stub("Instant").Start then
                titleLabel.Text = "Keaby • Ready"
                loadingLabel:Destroy()
                break
            end
            tries = tries + 1
            task.wait(0.5)
        end
        if tries >= 30 then
            titleLabel.Text = "Keaby (partial)"
            loadingLabel.Text = "⚠️ Some modules failed to load. Check console."
        end
    end)

end) -- end deferred UI build

-- ------------------------------
-- LIGHTWEIGHT ANIMATIONS (DELAYED & LOW CPU)
-- ------------------------------
-- Neon gradient: delayed, slower and less frequent updates to reduce CPU use
task.delay(1.2, function()
    -- create a stroke/gradient but update slower
    local neonBorder = Instance.new("UIStroke")
    neonBorder.Parent = win
    neonBorder.Color = colors.primary
    neonBorder.Thickness = 2
    neonBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local neonGradient = Instance.new("UIGradient")
    neonGradient.Parent = neonBorder
    neonGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, colors.primary),
        ColorSequenceKeypoint.new(0.33, colors.secondary),
        ColorSequenceKeypoint.new(0.66, colors.accent),
        ColorSequenceKeypoint.new(1, colors.primary)
    }
    -- rotate slowly and less frequently
    task.spawn(function()
        while gui and gui.Parent do
            for i = 0, 360, 6 do
                if not gui or not gui.Parent then break end
                neonGradient.Rotation = i
                task.wait(0.08) -- slower
            end
            task.wait(0.25)
        end
    end)
end)

-- ------------------------------
-- DRAG / MINIMIZE / CLOSE (kept light)
-- ------------------------------
-- Minimal minimize / close logic to avoid heavy tweens
local minimized = false
local icon
local savedIconPos = UDim2.new(0,20,0,120)

local function createMinimizedIcon()
    if icon then return end
    icon = new("Frame",{ Parent=gui, Size=UDim2.new(0,50,0,50), Position=savedIconPos, BackgroundColor3=colors.darkest, BorderSizePixel=0, ZIndex=100 })
    new("UICorner",{Parent=icon,CornerRadius=UDim.new(0,14)})
    local logoK = new("TextLabel",{ Parent=icon, Text="K", Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold, TextSize=26, BackgroundTransparency=1, TextColor3=colors.primary, ZIndex=101 })
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
            dragging = false
            savedIconPos = icon.Position
            if not dragMoved then
                win.Visible, inputBlocker.Visible, blurBg.Visible = true, true, true
                fastTween(win, {Size=UDim2.new(0,520,0,380), Position=UDim2.new(0.5,-260,0.5,-190)}, 0.4)
                icon:Destroy()
                icon = nil
                minimized = false
            end
        end
    end)
end

btnMin.MouseButton1Click:Connect(function()
    if not minimized then
        fastTween(win, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.25)
        inputBlocker.Visible, blurBg.Visible = true, true
        task.wait(0.28)
        win.Visible, inputBlocker.Visible, blurBg.Visible = false, false, false
        createMinimizedIcon()
        minimized = true
    end
end)

btnClose.MouseButton1Click:Connect(function()
    fastTween(win, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}, 0.22)
    inputBlocker.Visible, blurBg.Visible = true, true
    task.wait(0.26)
    gui:Destroy()
end)

-- Drag window
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
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- final log
print("✨ Keaby GUI v4.1 Performance Edition loaded (skeleton). Modules will load in background.")
