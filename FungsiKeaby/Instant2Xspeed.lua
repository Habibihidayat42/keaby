-- Instant2Xspeed.lua - ULTRA FAST AUTO FISHING (VinzHub-Inspired: Instant Catch & Zero Delay)
-- Features: Instant pull on hook detect, parallel recast with task.spawn, 1s fallback, spam mode for burst
-- Based on VinzHub logic: Minimal latency, no waits, optimized for 50+ fish/min

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
    Connections = {},
    FallbackTimeout = 1.0,  -- VinzHub-style: Super short 1s for quick cycles
    InstantMode = false,  -- Enable for spam/overlap casts like VinzHub's "Instant Fishing"
}
_G.FishingScript = fishing
local function log(msg)
    print("[Fishing] " .. msg)
end

-- VinzHub-inspired: Instant cast with zero delay
local function instantCast()
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        RF_RequestMinigame:InvokeServer(9, 0, tick())  -- No wait, pure instant!
        if not fishing.InstantMode then
            fishing.WaitingHook = true
        end
        fishing.CurrentCycle = fishing.CurrentCycle + 1
        log("🎯 Instant Cast " .. fishing.CurrentCycle .. " (Instant: " .. tostring(fishing.InstantMode) .. ")")
        
        -- Short fallback only in normal mode
        if not fishing.InstantMode then
            task.delay(fishing.FallbackTimeout, function()
                if fishing.WaitingHook and fishing.Running then
                    fishing.WaitingHook = false
                    RE_FishingCompleted:FireServer()
                    log("🔄 Quick fallback pull")
                    task.spawn(instantRecast)  -- Parallel recast
                end
            end)
        end
    end)
end

-- Parallel recast like VinzHub (task.spawn for no block)
local function instantRecast()
    if fishing.Running then
        instantCast()
    end
end

-- Event: Instant hook detect & pull (zero delay)
fishing.Connections.MinigameChanged = RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        RE_FishingCompleted:FireServer()  -- Instant pull, NO WAIT!
        log("✅ Instant hook pull!")
        task.spawn(instantRecast)  -- Parallel, VinzHub-style
    end
end)

-- Event: Fish caught with instant recast
fishing.Connections.FishCaught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Caught: " .. tostring(name) .. " (Total: " .. fishing.TotalFish .. ")")
        task.spawn(instantRecast)  -- Instant parallel recast
    end
end)

-- Main Cast: Handles modes
function fishing.Cast()
    if not fishing.Running then return end
    instantCast()
end

function fishing.Start(instantEnabled)
    if fishing.Running then return end
    fishing.Running = true
    fishing.InstantMode = instantEnabled or false
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false
    log("🚀 ULTRA FAST FISHING START! (1s timeout, Instant: " .. tostring(fishing.InstantMode) .. ")")
    fishing.Cast()
end

-- Toggle instant mode on-the-fly (like VinzHub toggle)
function fishing.ToggleInstant()
    fishing.InstantMode = not fishing.InstantMode
    if fishing.InstantMode then
        fishing.WaitingHook = false  -- Reset for spam
    end
    log("🔄 Instant Mode: " .. tostring(fishing.InstantMode) .. " (Zero waits, overlap OK)")
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    fishing.InstantMode = false
    log("🛑 STOPPED (Total Fish: " .. fishing.TotalFish .. ")")
    for name, conn in pairs(fishing.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(conn.Disconnect, conn)
            fishing.Connections[name] = nil
        end
    end
end

return fishing
