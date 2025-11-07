-- FixedUltraSpeed.lua - OPTIMIZED VERSION OF YOUR SCRIPT
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
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    
    -- **OPTIMIZED TIMING** - Lebih cepat dari script original
    Settings = {
        FishingDelay = 0.15,      -- Dipercepat dari 0.3
        CancelDelay = 0.02,       -- Dipercepat dari 0.05
        HookDelay = 0.25,         -- Dipercepat dari 0.30
        Timeout = 1.1,           -- Dipercepat dari 1.1
        CastDelay = 0.05,         -- Dipercepat dari 0.07
    }
}

_G.UltraFishing = fishing

local function log(msg)
    print("[⚡ULTRA] " .. msg)
end

-- **OPTIMIZED EVENT HANDLERS**
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(fishing.Settings.HookDelay)  -- Lebih cepat
        RE_FishingCompleted:FireServer()
        log("✅ HOOK DETECTED - Instant pull")
        task.wait(fishing.Settings.CancelDelay)
        RF_CancelFishingInputs:InvokeServer()
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        local weight = data and data.Weight or 0
        log("🐟 CAUGHT: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg)")
        task.wait(fishing.Settings.CancelDelay)
        RF_CancelFishingInputs:InvokeServer()
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- **OPTIMIZED CASTING FUNCTION**
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    fishing.WaitingHook = true
    
    log("🎣 Cast #" .. fishing.CurrentCycle)
    
    -- Gunakan parameter yang sama dengan script original Anda
    RF_ChargeFishingRod:InvokeServer({[4] = tick()})
    task.wait(fishing.Settings.CastDelay)
    
    RF_RequestMinigame:InvokeServer(9, 0, tick())
    log("⚡ Minigame requested")
    
    -- **FASTER TIMEOUT**
    task.delay(fishing.Settings.Timeout, function()
        if fishing.WaitingHook and fishing.Running then
            fishing.WaitingHook = false
            RE_FishingCompleted:FireServer()
            log("⏱️ FAST TIMEOUT - forcing catch")
            task.wait(fishing.Settings.CancelDelay)
            RF_CancelFishingInputs:InvokeServer()
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
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
    log("⚡ Optimized timing: " .. fishing.Settings.HookDelay .. "s hook, " .. fishing.Settings.FishingDelay .. "s cast")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED - Total: " .. fishing.TotalFish .. " fish")
end

-- Performance monitoring
function fishing.SetTurboMode()
    fishing.Settings = {
        FishingDelay = 0.1,   -- Super fast
        CancelDelay = 0.01,   -- Instant
        HookDelay = 0.15,     -- Very fast
        Timeout = 0.7,       -- Short timeout
        CastDelay = 0.03,     -- Quick cast
    }
    log("💨 TURBO MODE ACTIVATED!")
end

-- Auto start dengan turbo mode
task.delay(2, function()
    fishing.SetTurboMode()
    fishing.Start()
end)

return fishing
