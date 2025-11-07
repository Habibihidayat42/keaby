-- ⚡ ULTRA SPEED AUTO FISHING (Stable Cast Version)
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
        FishingDelay = 0.25,  -- waktu antar lempar (default 0.3)
        CancelDelay = 0.05,   -- waktu cancel input
        FallbackTimeout = 1.25 -- fallback auto tarik
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- 🔁 Fungsi aman untuk reset dan lanjut lempar berikutnya
local function safeNextCast(reason)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    log(reason or "➡️ Lanjut cast berikutnya")
    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)
end

-- 🎣 Event: Minigame berubah ke fase Hook (tanda seru!)
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end
    local s = string.lower(state)
    if s:find("hook") then
        fishing.WaitingHook = false
        task.spawn(function()
            task.wait(0.25)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("✅ Hook terdeteksi — tarik ikan.")
            safeNextCast("🐟 Hook selesai")
        end)
    end
end)

-- 🐠 Event: Ikan tertangkap
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    fishing.TotalFish += 1
    log(("🐟 Ikan tertangkap: %s"):format(tostring(name or "Fish")))
    safeNextCast("🎯 FishCaught event selesai")
end)

-- 🎯 Fungsi utama untuk lempar pancing
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle += 1
    fishing.WaitingHook = true

    task.spawn(function()
        pcall(function() RF_ChargeFishingRod:InvokeServer({[22] = tick()}) end)
        task.wait(0.07)
        pcall(function() RF_RequestMinigame:InvokeServer(9, 0, tick()) end)
        log(("⚡ Lempar pancing #%d — menunggu hook..."):format(fishing.CurrentCycle))

        -- fallback agar tidak macet jika bite gagal
        task.delay(fishing.Settings.FallbackTimeout, function()
            if fishing.Running and fishing.WaitingHook then
                log("⚠️ Timeout — paksa tarik cepat & lanjut")
                pcall(function() RE_FishingCompleted:FireServer() end)
                safeNextCast("♻️ Fallback selesai")
            end
        end)
    end)
end

-- 🚀 Start / Stop
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 Auto fishing dimulai (Stable Cast Mode)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 Auto fishing dihentikan")
end

return fishing
