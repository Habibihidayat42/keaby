-- ⚡ ULTRA SPEED AUTO FISHING v29.3 (Non-blocking Timeout / Smooth Loop)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Hentikan script lama jika masih aktif
if _G.FishingScript then
    _G.FishingScript.Stop()
    task.wait(0.05)
end

-- Inisialisasi koneksi network
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

-- Modul utama
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
        MaxWaitTime = 1.2, -- sedikit dikurangi agar lebih responsif
        EarlyMinigamePredict = 0.07
    }
}

_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

-- Nonaktifkan animasi fishing
local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
            end
        end
    end)

    -- Perbaiki posisi rod
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

-- Fungsi utama cast
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1
    local cycle = fishing.CurrentCycle
    log("⚡ Lempar pancing (Cycle: " .. cycle .. ")")

    local ok = pcall(function()
        -- Request minigame awal untuk percepatan respon server
        task.spawn(function()
            task.wait(0.01)
            pcall(function()
                RF_RequestMinigame:InvokeServer(9, 0, tick())
            end)
        end)

        -- Lempar kail
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        fishing.WaitingHook = true
        log("🎯 Menunggu hook...")

        --------------------------------------------------------------------
        -- NON-BLOCKING TIMEOUT LOOP
        --------------------------------------------------------------------
        task.spawn(function()
            local elapsed = 0
            while fishing.Running and fishing.WaitingHook and elapsed < fishing.Settings.MaxWaitTime do
                task.wait(0.05)
                elapsed += 0.05
                if not fishing.WaitingHook or fishing.CurrentCycle ~= cycle then
                    return
                end
            end

            -- Fallback sekali tanpa ganggu thread utama
            if fishing.Running and fishing.WaitingHook and fishing.CurrentCycle == cycle then
                fishing.WaitingHook = false
                log("⚠️ Timeout fallback (Cycle " .. cycle .. ")")
                pcall(function() RE_FishingCompleted:FireServer() end)
                task.wait(0.05)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)

                -- Mulai ulang cepat tanpa blocking
                task.spawn(function()
                    task.wait(fishing.Settings.FishingDelay * 0.5)
                    if fishing.Running then fishing.Cast() end
                end)
            end
        end)
        --------------------------------------------------------------------
    end)

    if not ok then
        log("❌ Gagal cast, retry...")
        task.spawn(function()
            task.wait(fishing.Settings.RetryDelay)
            if fishing.Running then fishing.Cast() end
        end)
    end
end

-- Start / Stop
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    disableFishingAnim()
    log("🚀 AUTO FISHING STARTED")

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

                -- Reset cepat
                task.spawn(function()
                    task.wait(fishing.Settings.CancelDelay)
                    pcall(function()
                        RF_CancelFishingInputs:InvokeServer()
                        log("🔄 Reset fishing inputs")
                    end)
                    task.wait(fishing.Settings.FishingDelay)
                    if fishing.Running then fishing.Cast() end
                end)
            end
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if not fishing.Running then return end
        fishing.WaitingHook = false
        fishing.TotalFish += 1
        local weight = data and data.Weight or 0
        log(("🐟 Ikan tertangkap: %s (%.2f kg)"):format(tostring(name), weight))

        task.spawn(function()
            task.wait(fishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
            log("🔄 Reset setelah tangkapan")
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
        end)
    end)

    fishing.Connections.AnimDisabler = task.spawn(function()
        while fishing.Running do
            disableFishingAnim()
            task.wait(0.15)
        end
    end)

    task.wait(0.3)
    fishing.Cast()
end

function fishing.Stop()
    if not fishing.Running then return end
    fishing.Running = false
    fishing.WaitingHook = false
    for _, conn in pairs(fishing.Connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect()
        elseif typeof(conn) == "thread" then task.cancel(conn) end
    end
    fishing.Connections = {}
    log("🛑 AUTO FISHING STOPPED")
end

return fishing
