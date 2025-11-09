-- Instant2Xspeed.lua - ULTRA FAST & SPAMMABLE AUTO FISHING (Fixed Path Error)
-- Fixes: Corrected RE_MinigameChanged path to "RE/FishingMinigameChanged" to avoid infinite yield
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
local RF_RequestMinigame = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_CancelFishingInputs = netFolder:WaitForChild("RF/CancelFishingInputs")
local RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
local RE_MinigameChanged = netFolder:WaitForChild("RE/FishingMinigameChanged")  -- Fixed: Back to original path
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")
local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Connections = {}, -- Store connections here for proper cleanup
    FallbackTimeout = 1.2,  -- Ultra-fast: Reduced to 1.2s for quicker cycles (tweak if too aggressive)
    SpamMode = false,  -- New: Enable for spammable casts (ignores WaitingHook, risky but fast)
}
_G.FishingScript = fishing
local function log(msg)
    print("[Fishing] " .. msg)
end

-- Ultra-fast recast (no wait for max speed)
local function recastIfRunning()
    if fishing.Running then
        fishing.Cast()  -- Instant recast, no delay
    end
end

-- ForceCast for spamming (ignores WaitingHook check)
function fishing.ForceCast()
    if not fishing.Running then return end  -- Still respect Running state
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        -- No wait here: Instant charge + request for spam speed
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        if not fishing.SpamMode then
            fishing.WaitingHook = true  -- Only set if not spamming
        end
        log("🎯 Force Cast " .. fishing.CurrentCycle .. " (Spam Mode: " .. tostring(fishing.SpamMode) .. ")")
        
        -- Fallback only if not spamming (in spam mode, no auto-pull to allow overlap)
        if not fishing.SpamMode then
            task.delay(fishing.FallbackTimeout, function()
                if fishing.WaitingHook and fishing.Running then
                    fishing.WaitingHook = false
                    RE_FishingCompleted:FireServer()
                    log("🔄 Fallback tarik (fast)")
                    recastIfRunning()
                end
            end)
        end
    end)
end

-- Connect events with proper storage
fishing.Connections.MinigameChanged = RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi")
        recastIfRunning()  -- Instant recast
    end
end)

fishing.Connections.FishCaught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
        recastIfRunning()  -- Instant recast
    end
end)

-- Main Cast (optimized: minimal checks/delays)
function fishing.Cast()
    if not fishing.Running then return end
    
    -- In spam mode, always use ForceCast for overlap
    if fishing.SpamMode then
        fishing.ForceCast()
        return
    end
    
    -- Normal mode: Respect WaitingHook to avoid overlap
    if fishing.WaitingHook then return end
    
    fishing.ForceCast()  -- Reuse optimized logic
end

function fishing.Start(spamEnabled)
    if fishing.Running then return end
    fishing.Running = true
    fishing.SpamMode = spamEnabled or false  -- Optional: Start in spam mode
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false
    log("🚀 FISHING START! (Speed Mode - " .. fishing.FallbackTimeout .. "s timeout, Spam: " .. tostring(fishing.SpamMode) .. ")")
    fishing.Cast()
end

-- Toggle spam mode on the fly
function fishing.ToggleSpam()
    fishing.SpamMode = not fishing.SpamMode
    log("🔄 Spam Mode: " .. tostring(fishing.SpamMode) .. " (Use ForceCast() for manual spam)")
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    fishing.SpamMode = false
    log("🛑 FISHING STOP")
   
    -- Proper cleanup: Disconnect all stored connections safely
    for name, connection in pairs(fishing.Connections) do
        if connection and typeof(connection) == "RBXScriptConnection" then
            pcall(function()
                connection:Disconnect()
            end)
            fishing.Connections[name] = nil
        elseif typeof(connection) == "thread" then
            warn("[Fishing] Warning: Found thread in connections, skipping Disconnect: " .. tostring(name))
        end
    end
end

return fishing
