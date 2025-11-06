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

local InstantFishing = {
    Running = false,
    WaitingHook = false,
    TotalFish = 0,
    Settings = {
        FishingDelay = 0.12,
        CancelDelay = 0.05,
        HookDelay = 0.06,
        ChargeToRequestDelay = 0.05,
        FallbackTimeout = 1.5,
    },
    OnFishCaught = nil,
    OnStatusChanged = nil
}

local function log(msg)
    print("[InstantFishing] " .. msg)
end

RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not InstantFishing.Running or not InstantFishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end

    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        InstantFishing.WaitingHook = false

        task.spawn(function()
            task.wait(InstantFishing.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("Hook -> FishingCompleted fired")

            task.wait(InstantFishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)

            task.wait(InstantFishing.Settings.FishingDelay)
            if InstantFishing.Running then InstantFishing.Cast() end
        end)
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not InstantFishing.Running then return end
    InstantFishing.WaitingHook = false
    InstantFishing.TotalFish = InstantFishing.TotalFish + 1
    local weight = data and data.Weight or 0
    log(("Fish caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))

    if InstantFishing.OnFishCaught then
        InstantFishing.OnFishCaught(InstantFishing.TotalFish, name, weight)
    end

    task.spawn(function()
        task.wait(InstantFishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(InstantFishing.Settings.FishingDelay)
        if InstantFishing.Running then InstantFishing.Cast() end
    end)
end)

function InstantFishing.Cast()
    if not InstantFishing.Running or InstantFishing.WaitingHook then return end
    InstantFishing.WaitingHook = true

    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)
        
        task.wait(InstantFishing.Settings.ChargeToRequestDelay)
        
        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("Cast sent (Charge -> Request)")

        task.delay(InstantFishing.Settings.FallbackTimeout, function()
            if InstantFishing.Running and InstantFishing.WaitingHook then
                InstantFishing.WaitingHook = false
                log("Fallback timeout - forcing complete")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(InstantFishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(InstantFishing.Settings.FishingDelay)
                if InstantFishing.Running then InstantFishing.Cast() end
            end
        end)
    end)
end

function InstantFishing.Start()
    if InstantFishing.Running then return end
    InstantFishing.Running = true
    InstantFishing.TotalFish = 0
    log("Started")
    if InstantFishing.OnStatusChanged then
        InstantFishing.OnStatusChanged(true)
    end
    InstantFishing.Cast()
end

function InstantFishing.Stop()
    InstantFishing.Running = false
    InstantFishing.WaitingHook = false
    log("Stopped")
    if InstantFishing.OnStatusChanged then
        InstantFishing.OnStatusChanged(false)
    end
end

function InstantFishing.SetSettings(settings)
    if settings.HookDelay then InstantFishing.Settings.HookDelay = settings.HookDelay end
    if settings.FishingDelay then InstantFishing.Settings.FishingDelay = settings.FishingDelay end
    if settings.CancelDelay then InstantFishing.Settings.CancelDelay = settings.CancelDelay end
end

return InstantFishing
