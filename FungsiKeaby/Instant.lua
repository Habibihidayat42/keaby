-- ⚡ ULTRA SPEED AUTO FISHING v29.3 (Stable Fallback System + MaxWaitTime)
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
        RetryDelay = 0,
        MaxWaitTime = 1.3,
        EarlyMinigamePredict = 0.07
    }
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

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1
    local cycle = fishing.CurrentCycle
    log("⚡ Lempar pancing (Cycle: " .. cycle .. ")")

    local ok = pcall(function()
        -- Kirim request minigame sedikit lebih awal (prediksi)
        task.spawn(function()
            task.wait(fishing.Settings.EarlyMinigamePredict)
            pcall(function()
                RF_RequestMinigame:InvokeServer(9, 0, tick())
            end)
        end)

        -- Lempar kail
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        fishing.WaitingHook = true
        log("🎯 Menunggu hook...")

        -- Timeout system (non-blocking, tidak ganggu loop utama)
        task.spawn(function()
            local start = tick()
            while fishing.Running and fishing.WaitingHook and tick() - start < fishing.Settings.MaxWaitTime do
                task.wait(0.05)
                if fishing.CurrentCycle ~= cycle then
                    return -- sudah lanjut ke cycle baru
                end
            end

            -- Jika benar-benar timeout
            if fishing.Running and fishing.WaitingHook and fishing.CurrentCycle == cycle then
                fishing.WaitingHook = false
                log("⚠️ Timeout fallback aktif (Cycle " .. cycle .. ")")

                -- Tarik paksa ikan biar tidak macet
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)

                -- Cancel input agar server siap lempar lagi
                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end)
    end)

    if not ok then
        log("❌ Gagal lempar, retry...")
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then fishing.Cast() end
    end
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    fishing.CurrentCycle = 0
    log("🚀 AUTO FISHING STARTED!")
    disableFishingAnim()

    fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if fishing.WaitingHook and typeof(state) == "string" then
            local s = state:lower()
            if s:find("hook") or s:find("bite") or s:find("catch") then
                fishing.WaitingHook = false
                task.spawn(function()
                    task.wait(fishing.Settings.HookDetectionDelay)
                    pcall(function()
                        RE_FishingCompleted:FireServer()
                        log("✅ Hook cepat — ikan langsung ditarik!")
                    end)
                end)

                task.wait(fishing.Settings.CancelDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                    log("🔄 Reset input selesai")
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if not fishing.Running then return end
        fishing.WaitingHook = false
        fishing.TotalFish += 1
        local weight = data and data.Weight or 0
        log(("🐟 %s (%.2f kg)"):format(tostring(name), weight))

        task.wait(fishing.Settings.CancelDelay)
        pcall(function()
            RF_CancelFishingInputs:InvokeServer()
        end)

        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)

    fishing.Connections.AnimCleaner = task.spawn(function()
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
    for _, conn in pairs(fishing.Connections) do
        if typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        elseif typeof(conn) == "thread" then
            task.cancel(conn)
        end
    end
    fishing.Connections = {}
    log("🛑 AUTO FISHING STOPPED")
end

return fishing
