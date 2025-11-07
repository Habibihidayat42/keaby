-- 🐟 Instant2Xspeed.lua - ULTRA SPEED AUTO FISHING (No ! Needed)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

local fishing = {
    Running = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.25,   -- jeda antar lempar
        PullDelay = 0.10,      -- jeda setelah lempar sebelum tarik
        CancelDelay = 0.05,    -- jeda sebelum cancel
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- Event: saat ikan berhasil tertangkap dari server
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.TotalFish += 1
    log("🐟 Ikan tertangkap: " .. tostring(name))
end)

-- Fungsi lempar & tarik cepat
function fishing.Cast()
    if not fishing.Running then return end
    fishing.CurrentCycle += 1
    pcall(function()
        -- Lempar pancing
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar kail ke air.")

        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())

        -- Tunggu sebentar lalu tarik otomatis
        task.wait(fishing.Settings.PullDelay)
        RE_FishingCompleted:FireServer()
        log("🎣 Tarik otomatis (tanpa tanda seru).")

        -- Cancel input biar cepat siap lempar ulang
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)

        -- Ulangi proses
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)
end

-- Fungsi mulai & stop
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED (Instant Mode)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    log("🛑 FISHING STOPPED")
end

return fishing
