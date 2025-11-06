-- ⚡ INSTANT BITE FISHING v31.1 (NORMAL SYNC MODE)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

-- stop previous instance
if _G.FishingScript then
    _G.FishingScript.Stop()
    if _G.FishingScript.GUI then _G.FishingScript.GUI:Destroy() end
    task.wait(0.1)
end

-- net references
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- main table
local fishing = {
    Running = false,
    WaitingHook = false,
    TotalFish = 0,
    ToggleKey = "F",
    Settings = {
        FishingDelay = 0.12, -- waktu sebelum cast berikutnya (aman)
        CancelDelay = 0.05,  -- waktu untuk cancel input setelah hook
        HookDelay = 0.06,    -- delay sebelum FireServer(RE_FishingCompleted) setelah terdeteksi "hook"
        ChargeToRequestDelay = 0.05, -- micro delay antara Charge dan RequestMinigame (sinkron aman)
        FallbackTimeout = 1.5, -- timeout fallback jika server tidak merespon
    },
    GUI = nil
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- RE_MinigameChanged: menunggu state "hook" atau "bite"
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end

    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        fishing.WaitingHook = false

        -- beri jeda kecil agar server benar-benar ready menerima complete
        task.spawn(function()
            task.wait(fishing.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook -> FishingCompleted fired (synced)")

            task.wait(fishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
        end)
    end
end)

-- ketika server mengirim event fish caught (safeguard)
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    fishing.TotalFish = fishing.TotalFish + 1
    local weight = data and data.Weight or 0
    log(("🐟 Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))

    if fishing.FishLabel then fishing.FishLabel.Text = "Fish: " .. fishing.TotalFish end

    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)
end)

-- Cast function (NORMAL SYNC): Charge -> small wait -> RequestMinigame -> wait RE_MinigameChanged
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.WaitingHook = true

    task.spawn(function()
        -- pastikan sesi lama dibersihkan dulu
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)

        -- Charge rod
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)

        -- micro delay agar server register charge sebelum minigame request
        task.wait(fishing.Settings.ChargeToRequestDelay)

        -- request minigame (menimbulkan tanda seru di atas karakter)
        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("🎯 Cast sent (Charge -> Request)")

        -- fallback timeout: bila RE_MinigameChanged tidak muncul dalam timeout, selesaikan paksa dan lanjut
        task.delay(fishing.Settings.FallbackTimeout, function()
            if fishing.Running and fishing.WaitingHook then
                fishing.WaitingHook = false
                log("⏱️ Fallback timeout — forcing complete")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- GUI (tetap tampilan sama; slider untuk HookDelay, FishingDelay, CancelDelay dikekalkan)
function fishing.CreateGUI()
    if fishing.GUI then fishing.GUI:Destroy() end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FishingControlGUI"
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    fishing.GUI = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 280)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(35,35,50)
    Instance.new("UICorner", header).CornerRadius = UDim.new(0,10)

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1,0,1,0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ INSTANT BITE FISHING"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16

    local statsFrame = Instance.new("Frame", mainFrame)
    statsFrame.Size = UDim2.new(1, -20, 0, 40)
    statsFrame.Position = UDim2.new(0, 10, 0, 45)
    statsFrame.BackgroundTransparency = 1

    fishing.StatusLabel = Instance.new("TextLabel", statsFrame)
    fishing.StatusLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.StatusLabel.Text = "STOPPED"
    fishing.StatusLabel.BackgroundTransparency = 1
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    fishing.StatusLabel.Font = Enum.Font.GothamBold
    fishing.StatusLabel.TextSize = 14
    fishing.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    fishing.FishLabel = Instance.new("TextLabel", statsFrame)
    fishing.FishLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.FishLabel.Position = UDim2.new(0.5, 5, 0, 0)
    fishing.FishLabel.BackgroundTransparency = 1
    fishing.FishLabel.Text = "Fish: 0"
    fishing.FishLabel.TextColor3 = Color3.fromRGB(100,255,100)
    fishing.FishLabel.Font = Enum.Font.Gotham
    fishing.FishLabel.TextSize = 14
    fishing.FishLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- slider helper (preserve look)
    local function createSlider(name, key, defaultValue, min, max, yPosition, color)
        local sliderFrame = Instance.new("Frame", mainFrame)
        sliderFrame.Size = UDim2.new(1, -20, 0, 40)
        sliderFrame.Position = UDim2.new(0, 10, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", sliderFrame)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. string.format("%.2fs", defaultValue)
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left

        local sliderBg = Instance.new("Frame", sliderFrame)
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60,60,80)
        Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", sliderBg)
        fill.Size = UDim2.new((defaultValue - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = color
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local btn = Instance.new("TextButton", sliderBg)
        btn.Size = UDim2.new(1,0,2,0)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        btn.MouseButton1Down:Connect(function()
            local conn
            conn = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    local val = min + (max - min) * rel
                    val = math.floor(val * 100) / 100
                    fill.Size = UDim2.new(rel,0,1,0)
                    label.Text = name .. ": " .. string.format("%.2fs", val)
                    fishing.Settings[key] = val
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and conn then
                    conn:Disconnect()
                end
            end)
        end)
    end

    -- original sliders kept
    createSlider("Hook Delay", "HookDelay", fishing.Settings.HookDelay, 0.01, 0.25, 90, Color3.fromRGB(100,255,100))
    createSlider("Fishing Delay", "FishingDelay", fishing.Settings.FishingDelay, 0.05, 1.0, 135, Color3.fromRGB(0,170,255))
    createSlider("Cancel Delay", "CancelDelay", fishing.Settings.CancelDelay, 0.01, 0.25, 180, Color3.fromRGB(255,100,100))

    -- toggle button (same look)
    local toggleBtn = Instance.new("TextButton", mainFrame)
    toggleBtn.Size = UDim2.new(1, -20, 0, 35)
    toggleBtn.Position = UDim2.new(0, 10, 0, 230)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60,255,60)
    toggleBtn.Text = "START FISHING"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
    toggleBtn.MouseButton1Click:Connect(function() fishing.Toggle() end)
    fishing.ToggleButton = toggleBtn
end

-- controls
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    if fishing.StatusLabel then
        fishing.StatusLabel.Text = "RUNNING"
        fishing.StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
    end
    if fishing.ToggleButton then
        fishing.ToggleButton.Text = "STOP FISHING"
        fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(255,60,60)
    end
    if fishing.FishLabel then fishing.FishLabel.Text = "Fish: 0" end
    log("🚀 Normal Sync mode started")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    if fishing.StatusLabel then
        fishing.StatusLabel.Text = "STOPPED"
        fishing.StatusLabel.TextColor3 = Color3.fromRGB(255,100,100)
    end
    if fishing.ToggleButton then
        fishing.ToggleButton.Text = "START FISHING"
        fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(60,255,60)
    end
    log("🛑 Stopped")
end

function fishing.Toggle()
    if fishing.Running then fishing.Stop() else fishing.Start() end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode[fishing.ToggleKey] then fishing.Toggle() end
end)

-- init
fishing.CreateGUI()
task.wait(1)
fishing.Start()
log("✅ Normal Sync fishing ready")
return fishing
