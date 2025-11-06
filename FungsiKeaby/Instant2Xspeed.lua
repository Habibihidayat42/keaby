-- ⚡ ULTRA SPEED AUTO FISHING v29.0 (With Fishing Delay Slider)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Auto-stop any previous fishing scripts
if _G.FishingScript then
    _G.FishingScript.Stop()
    if _G.FishingScript.GUI then
        _G.FishingScript.GUI:Destroy()
    end
    task.wait(0.1)
end

local netFolder = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

-- Fishing settings
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    ToggleKey = "F",
    
    -- ⚙️ 2 SLIDER UNTUK FLEXIBILITAS
    Settings = {
        FishingDelay = 0.3,    -- Delay setelah cancel inputs sebelum recast
        CancelDelay = 0.05,    -- Delay untuk cancel inputs
    },
    
    GUI = nil
}

_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

-- 🎯 HOOK DETECTION
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        
        -- ⚡ TARIK IKAN DULU - PASTIKAN IKAN NAIK
        task.wait(0.30) -- respon super cepat
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi — ikan ditarik.")
        
        -- CANCEL INPUTS SETELAH BERHASIL TARIK IKAN
        task.wait(fishing.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("🔄 Cancel inputs - reset cepat!")
        end)
        
        -- ⏳ TUNGGU FISHING DELAY YANG DIATUR, BARU RECAST
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- 🐟 FISH CAUGHT
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        local weight = data and data.Weight or 0
        log("🐟 Ikan tertangkap: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg)")
        fishing.UpdateStats()
        
        -- CANCEL INPUTS SETELAH IKAN MASUK INVENTORY
        task.wait(fishing.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("🔄 Cancel inputs - reset cepat!")
        end)
        
        -- ⏳ TUNGGU FISHING DELAY YANG DIATUR, BARU RECAST
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- 🎣 CAST FUNCTION
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    fishing.UpdateStats()
    
    pcall(function()
        -- 1️⃣ LEMPAR KAIL
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.07) -- lempar cepat banget

        -- 2️⃣ MULAI MINIGAME & TUNGGU TANDA SERU
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true

        -- 3️⃣ FALLBACK SUPER CEPAT (1.1 detik)
        task.delay(1.1, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("⚠️ Timeout pendek — fallback tarik cepat.")
                
                -- CANCEL INPUTS PADA TIMEOUT
                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                    log("🔄 Cancel timeout - reset cepat!")
                end)
                
                -- ⏳ TUNGGU FISHING DELAY YANG DIATUR, BARU RECAST
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)
end

-- 🎨 GUI DENGAN 2 SLIDER
function fishing.CreateGUI()
    if fishing.GUI then
        fishing.GUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "FishingControlGUI"
    gui.Parent = localPlayer.PlayerGui
    fishing.GUI = gui

    -- Main Frame (sedikit diperbesar untuk 2 slider)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 220)
    mainFrame.Position = UDim2.new(0, 20, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ FISHING CONTROL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = header

    -- Stats
    fishing.StatusLabel = Instance.new("TextLabel")
    fishing.StatusLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    fishing.StatusLabel.BackgroundTransparency = 1
    fishing.StatusLabel.Text = "STOPPED"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    fishing.StatusLabel.TextSize = 12
    fishing.StatusLabel.Font = Enum.Font.GothamBold
    fishing.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    fishing.StatusLabel.Parent = mainFrame

    fishing.FishLabel = Instance.new("TextLabel")
    fishing.FishLabel.Size = UDim2.new(0.5, -5, 0, 25)
    fishing.FishLabel.Position = UDim2.new(0.5, 5, 0, 45)
    fishing.FishLabel.BackgroundTransparency = 1
    fishing.FishLabel.Text = "Fish: 0"
    fishing.FishLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    fishing.FishLabel.TextSize = 12
    fishing.FishLabel.Font = Enum.Font.Gotham
    fishing.FishLabel.TextXAlignment = Enum.TextXAlignment.Left
    fishing.FishLabel.Parent = mainFrame

    -- Simple Slider Function
    local function createSlider(name, defaultValue, min, max, yPosition, color)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(1, -20, 0, 40)
        sliderFrame.Position = UDim2.new(0, 10, 0, yPosition)
        sliderFrame.BackgroundTransparency = 1
        sliderFrame.Parent = mainFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. string.format("%.2fs", defaultValue)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 6)
        sliderBg.Position = UDim2.new(0, 0, 0, 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        sliderBg.Parent = sliderFrame

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = sliderBg

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = color
        fill.Parent = sliderBg

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 2, 0)
        button.Position = UDim2.new(0, 0, -0.5, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = sliderBg

        local value = defaultValue
        
        button.MouseButton1Down:Connect(function()
            local connection
            connection = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * relativeX
                    fill.Size = UDim2.new(relativeX, 0, 1, 0)
                    label.Text = name .. ": " .. string.format("%.2fs", value)
                    
                    if name == "Fishing Delay" then
                        fishing.Settings.FishingDelay = value
                    elseif name == "Cancel Delay" then
                        fishing.Settings.CancelDelay = value
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end)
        
        return sliderFrame
    end

    -- 2 SLIDER UNTUK FLEXIBILITAS
    createSlider("Fishing Delay", 0.3, 0.0, 1.0, 75, Color3.fromRGB(0, 170, 255))
    createSlider("Cancel Delay", 0.05, 0.01, 0.2, 120, Color3.fromRGB(255, 100, 100))

    -- Info Text
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 0, 20)
    infoText.Position = UDim2.new(0, 10, 0, 165)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Adjust for different rod speeds!"
    infoText.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoText.TextSize = 10
    infoText.Font = Enum.Font.Gotham
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = mainFrame

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(1, -20, 0, 35)
    toggleBtn.Position = UDim2.new(0, 10, 0, 185)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    toggleBtn.Text = "START FISHING"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = toggleBtn

    toggleBtn.MouseButton1Click:Connect(function()
        fishing.Toggle()
    end)

    fishing.ToggleButton = toggleBtn
end

-- Update stats
function fishing.UpdateStats()
    if fishing.FishLabel then
        fishing.FishLabel.Text = "Fish: " .. fishing.TotalFish
    end
end

-- ▶️ Start Fishing
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.StatusLabel.Text = "RUNNING"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    fishing.ToggleButton.Text = "STOP FISHING"
    fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    log("🚀 FISHING STARTED!")
    fishing.Cast()
end

-- ⏹️ Stop Fishing
function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    fishing.StatusLabel.Text = "STOPPED"
    fishing.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    fishing.ToggleButton.Text = "START FISHING"
    fishing.ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    log("🛑 FISHING STOPPED")
end

-- 🔄 Toggle Fishing
function fishing.Toggle()
    if fishing.Running then
        fishing.Stop()
    else
        fishing.Start()
    end
end

-- ⌨️ Key Toggle
local function onInput(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[fishing.ToggleKey] and input.UserInputType == Enum.UserInputType.Keyboard then
        fishing.Toggle()
    end
end

UserInputService.InputBegan:Connect(onInput)

-- Initialize
fishing.CreateGUI()
task.wait(1)
fishing.Start()

log("🔧 Controls: Press " .. fishing.ToggleKey .. " to toggle")
log("🎣 Adjust sliders for different rod speeds!")

return fishing