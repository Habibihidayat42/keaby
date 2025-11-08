-- ⚡ FIXED ULTRA SPEED AUTO FISHING (Manual Start - For External GUI)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

print("=== 🚀 FIXED ULTRA SPEED LOADED ===")

-- Network remotes dengan path yang benar
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")

-- =================================================================
-- Core Fishing Logic
-- =================================================================
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.15,
        CancelDelay = 0.02,
        HookDelay = 0.2,
        Timeout = 0.8,
        CastDelay = 0.05,
    }
}

_G.UltraFishing = fishing

local function log(msg)
    print("[⚡ULTRA] " .. msg)
end

-- Handle minigame event (detect hook)
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.Running and fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(fishing.Settings.HookDelay)
        RE_FishingCompleted:FireServer()
        log("✅ HOOK DETECTED - Instant pull")
        task.wait(fishing.Settings.CancelDelay)
        RF_CancelFishingInputs:InvokeServer()
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- Core cast logic
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle += 1
    fishing.WaitingHook = true
    log("🎣 Cast #" .. fishing.CurrentCycle)
    
    RF_ChargeFishingRod:InvokeServer({[1] = tick()})
    task.wait(fishing.Settings.CastDelay)
    RF_RequestMinigame:InvokeServer(9, 0, tick())
    log("⚡ Minigame requested")
    
    -- Fast timeout safety
    task.delay(fishing.Settings.Timeout, function()
        if fishing.WaitingHook and fishing.Running then
            fishing.WaitingHook = false
            RE_FishingCompleted:FireServer()
            log("⏱️ FAST TIMEOUT - forcing catch")
            task.wait(fishing.Settings.CancelDelay)
            RF_CancelFishingInputs:InvokeServer()
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.Cast()
            end
        end
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false
    log("🚀 ULTRA SPEED FISHING STARTED!")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED - Total: " .. fishing.TotalFish .. " fish")
end

function fishing.SetTurboMode()
    fishing.Settings = {
        FishingDelay = 0.1,
        CancelDelay = 0.01,
        HookDelay = 0.15,
        Timeout = 0.7,
        CastDelay = 0.03,
    }
    log("💨 TURBO MODE ACTIVATED!")
end

-- =================================================================
-- ✅ Manual Mode Only (No Auto Start)
-- Call these from your GUI:
-- _G.UltraFishing.Start()
-- _G.UltraFishing.Stop()
-- _G.UltraFishing.SetTurboMode()
-- =================================================================

return fishing
