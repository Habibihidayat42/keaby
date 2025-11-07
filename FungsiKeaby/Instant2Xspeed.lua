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
        FishingDelay = 0.12,       -- delay antar cast
        CancelDelay = 0.05,        -- delay cancel
        HookFallback = 0.8,        -- timeout fallback hook
        RetryDelay = 0.05,         -- delay retry jika server gagal
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

local function SafeInvoke(remote, ...)
    if remote:IsA("RemoteFunction") then
        local success, result = pcall(function()
            return remote:InvokeServer(...)
        end)
        if not success then
            task.wait(fishing.Settings.RetryDelay)
            pcall(function() remote:InvokeServer(...) end)
        end
        return result
    elseif remote:IsA("RemoteEvent") then
        local success = pcall(function()
            remote:FireServer(...)
        end)
        if not success then
            task.wait(fishing.Settings.RetryDelay)
            pcall(function() remote:FireServer(...) end)
        end
    end
end


-- Event: Minigame hook terdeteksi
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(0.06)
        SafeInvoke(RE_FishingCompleted)
        log("✅ Hook terdeteksi — ikan ditarik.")
        task.wait(fishing.Settings.CancelDelay)
        SafeInvoke(RF_CancelFishingInputs)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Event: Ikan tertangkap
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
        task.wait(fishing.Settings.CancelDelay)
        SafeInvoke(RF_CancelFishingInputs)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Fungsi cast pancing
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle = fishing.CurrentCycle + 1

    pcall(function()
        SafeInvoke(RF_ChargeFishingRod, {[22] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.06)
        SafeInvoke(RF_RequestMinigame, 9, 0, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true
        local castStart = tick()

        -- fallback adaptif jika hook tidak terdeteksi
        task.delay(fishing.Settings.HookFallback, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                SafeInvoke(RE_FishingCompleted)
                log("⚠️ Timeout fallback ("..string.format("%.2f", tick()-castStart).."s) — tarik cepat.")
                task.wait(fishing.Settings.CancelDelay)
                SafeInvoke(RF_CancelFishingInputs)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

-- Start fishing
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED!")
    fishing.Cast()
end

-- Stop fishing
function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED")
end

return fishing
