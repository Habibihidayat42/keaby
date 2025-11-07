-- Instant.lua (no toggle key) - INSTANT BITE FISHING

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
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.05, -- Diperkecil untuk meningkatkan kecepatan
        CancelDelay = 0.03, -- Diperkecil untuk meningkatkan kecepatan
        HookDelay = 0.04, -- Diperkecil untuk meningkatkan kecepatan
        ChargeToRequestDelay = 0.03, -- Diperkecil untuk meningkatkan kecepatan
        FallbackTimeout = 1.2, -- Dikurangi untuk mempercepat timeout
    },
}

_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end
    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        fishing.WaitingHook = false
        task.spawn(function()
            task.wait(fishing.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook -> FishingCompleted fired (synced)")
            task.wait(fishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then 
                fishing.Cast() 
            end
        end)
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    fishing.TotalFish = fishing.TotalFish + 1
    local weight = data and data.Weight or 0
    log(("🐟 Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))
    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then 
            fishing.Cast() 
        end
    end)
end)

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.WaitingHook = true
    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)
        task.wait(fishing.Settings.ChargeToRequestDelay)
        pcall(function() RF_RequestMinigame:InvokeServer(1.9, 0.4, tick()) end) -- Penyesuaian nilai
        task.delay(fishing.Settings.FallbackTimeout, function()
            if fishing.Running and fishing.WaitingHook then
                fishing.WaitingHook = false
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then 
                    fishing.Cast() 
                end
            end
        end)
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    log("🚀 Normal Sync mode started")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 Stopped")
end

return fishing
