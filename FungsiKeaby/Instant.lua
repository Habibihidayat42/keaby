-- ⚡ ULTRA SPEED AUTO FISHING v29.1 (Clean Auto-Start, No UI / No Toggle Key)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Hentikan script lama
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
    Settings = {
        FishingDelay = 0.05,
        CancelDelay = 0.19,
        HookDetectionDelay = 0.10,
        RetryDelay = 0.1,
        MaxWaitTime = 1.3,
    }
}

_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

-- Nonaktifkan animasi pancing
local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local name = track.Name:lower()
            if name:find("fish") or name:find("rod") or name:find("cast") or name:find("reel") then
                track:Stop(0)
            end
        end
    end)

    -- Posisi rod diperbaiki
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

-- Disable animasi secara terus-menerus
task.spawn(function()
    while task.wait(0.15) do
        if fishing.Running then
            disableFishingAnim()
        end
    end
end)

-- Hook detection
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" then
        local stateLower = string.lower(state)
        if string.find(stateLower, "hook") or string.find(stateLower, "bite") or string.find(stateLower, "catch") then
            fishing.WaitingHook = false
            task.wait(fishing.Settings.HookDetectionDelay)

            pcall(function()
                RE_FishingCompleted:FireServer()
                log("✅ Hook terdeteksi — ikan ditarik!")
            end)

            task.wait(fishing.Settings.CancelDelay)
            pcall(function()
                RF_CancelFishingInputs:InvokeServer()
                log("🔄 Reset fishing inputs")
            end)

            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then
                fishing.Cast()
            end
        end
    end
end)

-- Handler saat ikan tertangkap
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish += 1
        local weight = data and data.Weight or 0
        log("🐟 Ikan tertangkap: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg)")

        local success = pcall(function()
            task.wait(fishing.Settings.CancelDelay)
            RF_CancelFishingInputs:InvokeServer()
            log("🔄 Reset setelah tangkapan")
        end)

        if not success then
            log("⚠️ Gagal reset, melanjutkan...")
        end

        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end)

-- Fungsi utama lempar pancing
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    fishing.CurrentCycle += 1
    log("⚡ Lempar pancing (Cycle: " .. fishing.CurrentCycle .. ")")

    local castSuccess = pcall(function()
        RF_ChargeFishingRod:InvokeServer({[10] = tick()})
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true
        log("🎯 Menunggu hook...")

        -- Timeout protection
        task.delay(fishing.Settings.MaxWaitTime * 0.7, function()
            if fishing.WaitingHook and fishing.Running then
                log("⏰ Fallback 1 - Cek hook...")
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)
            end
        end)

        task.delay(fishing.Settings.MaxWaitTime, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                log("⚠️ Timeout - Fallback tarik paksa")
                pcall(function()
                    RE_FishingCompleted:FireServer()
                end)

                task.wait(fishing.Settings.RetryDelay)
                pcall(function()
                    RF_CancelFishingInputs:InvokeServer()
                end)

                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then
                    fishing.Cast()
                end
            end
        end)
    end)

    if not castSuccess then
        log("❌ Gagal cast, retrying...")
        task.wait(fishing.Settings.RetryDelay)
        if fishing.Running then
            fishing.Cast()
        end
    end
end

-- Start dan Stop
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 AUTO FISHING STARTED!")
    disableFishingAnim()
    task.wait(0.5)
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 AUTO FISHING STOPPED")
end
return fishing
