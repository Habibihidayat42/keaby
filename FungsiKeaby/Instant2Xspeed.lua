-- ⚡ ULTRA SPEED AUTO FISHING v29.1 (Clean Passive Version - For External GUI)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

print("=== 🚀 ULTRA SPEED MODULE LOADED ===")

-- Network remotes
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

-- =================================================================
-- Core Fishing Object
-- =================================================================
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Connections = {},
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

-- =================================================================
-- Internal Functions
-- =================================================================
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    fishing.CurrentCycle += 1
    fishing.WaitingHook = true
    log("🎣 Cast #" .. fishing.CurrentCycle)

    local ok = pcall(function()
        RF_ChargeFishingRod:InvokeServer({[1] = tick()})
        task.wait(fishing.Settings.CastDelay)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("⚡ Minigame requested")

        -- Timeout fallback (auto pull)
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
    end)

    if not ok then
        log("❌ Cast failed, retrying...")
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- =================================================================
-- Control Functions
-- =================================================================
function fishing.Start()
    if fishing.Running then return end

    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false

    log("🚀 ULTRA SPEED FISHING STARTED!")

    -- Connect event for hook detection
    fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if fishing.Running and fishing.WaitingHook and typeof(state) == "string" then
            local s = string.lower(state)
            if s:find("hook") or s:find("bite") then
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
        end
    end)

    -- Start first cast
    task.wait(0.25)
    fishing.Cast()
end

function fishing.Stop()
    if not fishing.Running then return end

    fishing.Running = false
    fishing.WaitingHook = false

    -- Disconnect all connections
    for _, conn in pairs(fishing.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        elseif typeof(conn) == "thread" then
            task.cancel(conn)
        end
    end
    fishing.Connections = {}

    log("🛑 ULTRA SPEED FISHING STOPPED - Total: " .. fishing.TotalFish .. " fish")
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
-- ✅ MANUAL MODE ONLY
-- Call these from your GUI or other module:
--     _G.UltraFishing.Start()
--     _G.UltraFishing.Stop()
--     _G.UltraFishing.SetTurboMode()
-- =================================================================

return fishing
