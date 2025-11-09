-- ⚡ ULTRA SPEED AUTO FISHING v29.3 (No Auto-Start / Controlled by GUI + Smart Hook Sync)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

if _G.FishingScript then
    _G.FishingScript.Stop()
    task.wait(0.1)
end

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

local fishing = {
    Running = false,
    WaitingHook = false,
    CurrentCycle = 0,
    TotalFish = 0,
    Connections = {},
    Settings = {
        FishingDelay = 0.01,
        CancelDelay = 0.19,
        HookDetectionDelay = 0.10,
        RetryDelay = 0.1,
        MaxWaitTime = 1.3,
        EarlyMinigamePredict = 0.15,
        SyncHookDelay = 0.18, -- tambahan delay biar hook sinkron dgn kail jatuh
    },
}

_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
            end
        end
    end)

    task.spawn(function()
        local rod = Character:FindFirstChild("Rod") or Character:FindFirstChildWhichIsA("Tool")
        if rod and rod:FindFirstChild("Handle") then
            local handle = rod.Handle
            local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("Motor6D")
            if weld then
                weld.C0 = CFrame.new(0, -1, -1.2) * CFrame.Angles(math.rad(-10), 0, 0)
            end
        end
    end)
end

-- ⏱️ buat tracking sinkronisasi otomatis
local lastCastTime, lastHookTime = 0, 0

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1
    lastCastTime = tick()
    log("⚡ Lempar pancing (Cycle: " .. fishing.CurrentCycle .. ")")

    local success = pcall(function()
        -- Kirim permintaan minigame sedikit lebih awal
        task.spawn(function()
            task.wait(0.08)
            pcall(function()
                RF_RequestMinigame:InvokeServer(9, 0, tick())
            end)
        end)

        -- Lempar kail
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        fishing.WaitingHook = true
        log("🎯 Menunggu hook...")

        -- 🔁 Prediksi tanda seru sinkron dengan kail jatuh
        task.delay(fishing.Settings.EarlyMinigamePredict + fishing.Settings.SyncHookDelay, function()
            if fishing.WaitingHook and fishing.Running then
                log("⚡ [Predict-Sync] Tanda seru muncul sinkron dengan kail jatuh")
                RE_MinigameChanged:Fire("HookPredicted")
            end
        end)

        -- Timeout safety
        task.delay(fishing.Settings.MaxWaitTime * 0.7, function()
            if fishing.WaitingHook and fishing.Running then
                log("⏰ Fallback 1 - Cek hook...")
                pcall(function() RE_FishingCompleted:FireServer() end)
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                log("⚠️ Timeout - tarik paksa")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(fishing.Settings.RetryDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)

    if not success then
        log("❌ Gagal cast, retrying...")
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then fishing.Cast() end
    end
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle, fishing.TotalFish = 0, 0
    disableFishingAnim()
    log("🚀 AUTO FISHING STARTED!")

    fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if fishing.WaitingHook and typeof(state) == "string" then
            local s = state:lower()
            if s:find("hook") or s:find("bite") or s:find("catch") then
                fishing.WaitingHook = false
                lastHookTime = tick() - lastCastTime

                -- ✨ adaptif: update SyncHookDelay berdasar hasil nyata
                local newDelay = math.clamp(lastHookTime * 0.45, 0.12, 0.25)
                fishing.Settings.SyncHookDelay = (fishing.Settings.SyncHookDelay * 0.7) + (newDelay * 0.3)
                log(string.format("⏱️ SyncHookDelay disesuaikan ke %.3f detik", fishing.Settings.SyncHookDelay))

                task.spawn(function()
                    task.wait(fishing.Settings.HookDetectionDelay * 0.7)
                    pcall(function()
                        RE_FishingCompleted:FireServer()
                        log("✅ Hook cepat — ikan langsung ditarik!")
                    end)
                end)

                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                    log("🔄 Reset fishing inputs")
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if fishing.Running then
            fishing.WaitingHook = false
            fishing.TotalFish += 1
            local w = data and data.Weight or 0
            log(("🐟 Ikan tertangkap: %s (%.2f kg)"):format(tostring(name), w))
            pcall(function()
                task.wait(fishing.Settings.CancelDelay)
                RF_CancelFishingInputs:InvokeServer()
                log("🔄 Reset setelah tangkapan")
            end)
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
        end
    end)

    fishing.Connections.AnimDisabler = task.spawn(function()
        while fishing.Running do
            disableFishingAnim()
            task.wait(0.15)
        end
    end)

    task.wait(0.5)
    fishing.Cast()
end

function fishing.Stop()
    if not fishing.Running then return end
    fishing.Running = false
    fishing.WaitingHook = false
    for _, c in pairs(fishing.Connections) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif typeof(c) == "thread" then task.cancel(c) end
    end
    fishing.Connections = {}
    log("🛑 AUTO FISHING STOPPED")
end

return fishing
