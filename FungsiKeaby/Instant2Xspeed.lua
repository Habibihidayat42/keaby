-- Instant2Xspeed.lua (no toggle key) - ULTRA SPEED AUTO FISHING
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
        FishingDelay = 0.12, -- lebih cepat
        CancelDelay = 0.05,
        HookFallback = 0.8, -- timeout fallback lebih pendek tapi aman
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- Minigame hook terdeteksi
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(0.06)
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi — ikan ditarik.")
        task.wait(fishing.Settings.CancelDelay)
        pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Ikan tertangkap
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
        task.wait(fishing.Settings.CancelDelay)
        pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle = fishing.CurrentCycle + 1

    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.06)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true

        -- fallback timeout jika hook tidak terdeteksi
        task.delay(fishing.Settings.HookFallback, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("⚠️ Timeout fallback — tarik cepat.")
                task.wait(fishing.Settings.CancelDelay)
                pcall(RF_CancelFishingInputs.InvokeServer, RF_CancelFishingInputs)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED!")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED")
end

return fishing
