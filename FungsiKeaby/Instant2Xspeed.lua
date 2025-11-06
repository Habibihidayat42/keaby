local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

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
local RE_FishCaught = netFolder:WaitForChild("RE/FishCaught")

local Instant2XSpeed = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.3,
        CancelDelay = 0.05,
    },
    OnFishCaught = nil,
    OnStatusChanged = nil
}

local function log(msg)
    print(("[Instant2XSpeed] %s"):format(msg))
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if Instant2XSpeed.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        Instant2XSpeed.WaitingHook = false
        
        task.wait(0.30)
        RE_FishingCompleted:FireServer()
        log("Hook detected - fish pulled")
        
        task.wait(Instant2XSpeed.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("Cancel inputs - quick reset")
        end)
        
        task.wait(Instant2XSpeed.Settings.FishingDelay)
        if Instant2XSpeed.Running then
            Instant2XSpeed.Cast()
        end
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if Instant2XSpeed.Running then
        Instant2XSpeed.WaitingHook = false
        Instant2XSpeed.TotalFish = Instant2XSpeed.TotalFish + 1
        local weight = data and data.Weight or 0
        log("Fish caught: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg)")
        
        if Instant2XSpeed.OnFishCaught then
            Instant2XSpeed.OnFishCaught(Instant2XSpeed.TotalFish, name, weight)
        end
        
        task.wait(Instant2XSpeed.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
            log("Cancel inputs - quick reset")
        end)
        
        task.wait(Instant2XSpeed.Settings.FishingDelay)
        if Instant2XSpeed.Running then
            Instant2XSpeed.Cast()
        end
    end
end)

function Instant2XSpeed.Cast()
    if not Instant2XSpeed.Running or Instant2XSpeed.WaitingHook then return end
    
    Instant2XSpeed.CurrentCycle = Instant2XSpeed.CurrentCycle + 1
    
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("Cast sent")
        task.wait(0.07)

        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("Waiting for hook...")
        Instant2XSpeed.WaitingHook = true

        task.delay(1.1, function()
            if Instant2XSpeed.WaitingHook and Instant2XSpeed.Running then
                Instant2XSpeed.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("Timeout - quick fallback pull")
                
                task.wait(Instant2XSpeed.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                    log("Cancel timeout - quick reset")
                end)
                
                task.wait(Instant2XSpeed.Settings.FishingDelay)
                if Instant2XSpeed.Running then
                    Instant2XSpeed.Cast()
                end
            end
        end)
    end)
end

function Instant2XSpeed.Start()
    if Instant2XSpeed.Running then return end
    Instant2XSpeed.Running = true
    Instant2XSpeed.CurrentCycle = 0
    Instant2XSpeed.TotalFish = 0
    log("Started")
    if Instant2XSpeed.OnStatusChanged then
        Instant2XSpeed.OnStatusChanged(true)
    end
    Instant2XSpeed.Cast()
end

function Instant2XSpeed.Stop()
    Instant2XSpeed.Running = false
    Instant2XSpeed.WaitingHook = false
    log("Stopped")
    if Instant2XSpeed.OnStatusChanged then
        Instant2XSpeed.OnStatusChanged(false)
    end
end

function Instant2XSpeed.SetSettings(settings)
    if settings.FishingDelay then Instant2XSpeed.Settings.FishingDelay = settings.FishingDelay end
    if settings.CancelDelay then Instant2XSpeed.Settings.CancelDelay = settings.CancelDelay end
end

return Instant2XSpeed
