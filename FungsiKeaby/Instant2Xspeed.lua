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
        FishingDelay = 0.3,
        CancelDelay = 0.05,
        CastDelay = 0.5, -- Delay antara lempar dan tarik
        PullDelay = 0.3, -- Delay setelah menarik
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        log("✅ Hook terdeteksi — ikan ditarik.")
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
    end
end)

function fishing.Cast()
    if not fishing.Running then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    
    pcall(function()
        -- Lempar kail
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar pancing.")
        
        task.wait(fishing.Settings.CastDelay)
        
        -- Tarik kail tanpa menunggu hook
        RE_FishingCompleted:FireServer()
        log("🎯 Tarik kail otomatis.")
        
        task.wait(fishing.Settings.PullDelay)
        
        -- Reset dan siapkan untuk lempar berikutnya
        pcall(function() 
            RF_CancelFishingInputs:InvokeServer() 
        end)
        
        task.wait(fishing.Settings.FishingDelay)
        
        -- Lanjut ke cycle berikutnya
        if fishing.Running then 
            fishing.Cast() 
        end
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED! (Mode Instant)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED")
end

return fishing
