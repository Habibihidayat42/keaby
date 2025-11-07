-- 🐟 UltraSpeed2X.lua - Auto Fishing (Fast & Reliable)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.15,  -- jeda antar lempar
        CancelDelay = 0.03,   -- delay cancel input
        PollInterval = 0.05,  -- cek hook cepat
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- Event: minigame hook berubah
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(0.05)
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi — ikan ditarik.")
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Event: ikan tertangkap
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.TotalFish += 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
    end
end)

-- Fungsi lempar & tunggu hook
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle += 1
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.05)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true

        -- Fallback timeout cepat jika hook tidak muncul (server lag)
        task.delay(0.6, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("⚠️ Timeout fallback — tarik cepat.")
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- Start & Stop
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED (UltraSpeed Mode)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED")
end

return fishing
