-- Instant2Xspeed.lua - SIMPLE & SMOOTH AUTO FISHING (Fixed for less stutter)
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
}
_G.FishingScript = fishing
local function log(msg)
    print("[Fishing] " .. msg)
end

-- Helper to recast smoothly
local function recastIfRunning()
    task.wait(0.05) -- Minimal delay for smoothness
    if fishing.Running then
        fishing.Cast()
    end
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi")
        recastIfRunning()
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
        recastIfRunning()
    end
end)

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        task.wait(0.03) -- Slightly reduced for faster charge
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true
        log("🎯 Cast " .. fishing.CurrentCycle)
        
        -- IMPROVED FALLBACK: Longer timeout to avoid early pulls, reducing failed attempts and stutter
        -- This gives more time for hook detection, making it smoother and less frequent fallbacks
        task.delay(2.5, function()  -- Increased from 1.5 to 2.5s for better hook wait
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("🔄 Fallback tarik (delayed for smoothness)")
                recastIfRunning()
            end
        end)
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false
    log("🚀 FISHING START!")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOP")
end

return fishing
