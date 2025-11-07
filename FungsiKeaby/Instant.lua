-- Instant.lua (Fish It - Predicted Fast Hook Mode)
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
        FishingDelay = 0.12,
        CancelDelay = 0.05,
        HookDelay = 0.04, -- lebih cepat
        FallbackTimeout = 2.5,
        Adaptive = true,
        PredictBite = true, -- aktifkan prediksi tanda seru cepat
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[FishIt] " .. msg)
end

-- deteksi rod
local function getRodName()
    local char = localPlayer.Character
    if not char then return "Unknown" end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") and v.Name:lower():find("rod") then
            return v.Name
        end
    end
    return "Unknown"
end

local function getDelayForRod()
    local rod = getRodName():lower()
    if rod:find("ghostfinn") then
        return 0.05
    elseif rod:find("steampunk") then
        return 0.22
    elseif rod:find("sunken") then
        return 0.17
    else
        return 0.15
    end
end

-- event normal (fallback)
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end
    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        fishing.WaitingHook = false
        task.spawn(function()
            task.wait(fishing.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook → FishingCompleted fired (server event)")
            task.wait(fishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
        end)
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if not fishing.Running then return end
    fishing.WaitingHook = false
    fishing.TotalFish += 1
    local weight = data and data.Weight or 0
    log(("🐟 %s (%.2f kg)"):format(tostring(name or "Fish"), weight))
    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)
end)

-- casting utama
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.WaitingHook = true

    local delay = fishing.Settings.Adaptive and getDelayForRod() or 0.1
    log(("🎣 Casting (%s | delay=%.2fs)"):format(getRodName(), delay))

    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)
        task.wait(delay)
        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("🎯 RequestMinigame sent")

        -- ⚡ Prediksi tanda seru cepat
        if fishing.Settings.PredictBite then
            task.delay(delay + 0.05, function()
                if fishing.Running and fishing.WaitingHook then
                    log("❗ Predicted bite! (early FishingCompleted)")
                    fishing.WaitingHook = false
                    pcall(function() RE_FishingCompleted:FireServer() end)
                    task.wait(fishing.Settings.CancelDelay)
                    pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then fishing.Cast() end
                end
            end)
        end

        -- fallback safety
        task.delay(fishing.Settings.FallbackTimeout, function()
            if fishing.Running and fishing.WaitingHook then
                fishing.WaitingHook = false
                log("⏱️ Timeout - forcing FishingCompleted")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    log("🚀 Fast Hook Prediction Mode (Fish It)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 Fishing stopped")
end

return fishing
