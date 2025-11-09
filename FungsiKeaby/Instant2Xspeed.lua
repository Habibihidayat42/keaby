-- ⚡ ULTRA SPEED AUTO FISHING (Instant2Xspeed.lua, no toggle key, Disable Animations)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

-- 🔇 Fungsi Disable Animations
local function disableAnimations()
    for _, obj in ipairs(Character:GetDescendants()) do
        if obj:IsA("Animator") or obj:IsA("Animation") or obj:IsA("AnimationTrack") then
            pcall(function() obj:Destroy() end)
        end
    end
    local humanoid = Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function()
            local animate = Character:FindFirstChild("Animate")
            if animate then animate.Disabled = true end
            for _, playingAnim in ipairs(humanoid:GetPlayingAnimationTracks()) do
                playingAnim:Stop()
            end
        end)
    end
end

-- Jalankan disable animasi awal
disableAnimations()
-- Pastikan animasi tetap nonaktif ketika respawn
localPlayer.CharacterAdded:Connect(function(char)
    Character = char
    task.wait(1)
    disableAnimations()
end)

-- 🎣 Core Fishing System
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
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[Fishing] " .. msg)
end

-- Hook detection
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        task.wait(0.30)
        RE_FishingCompleted:FireServer()
        log("✅ Hook terdeteksi — ikan ditarik.")
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Fish caught event
RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        log("🐟 Ikan tertangkap: " .. tostring(name))
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end
end)

-- Casting logic
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        log("⚡ Lempar pancing.")
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        log("🎯 Menunggu hook...")
        fishing.WaitingHook = true

        -- Fallback cepat jika hook tidak muncul
        task.delay(1.1, function()
            if fishing.WaitingHook and fishing.Running then
                fishing.WaitingHook = false
                RE_FishingCompleted:FireServer()
                log("⚠️ Timeout pendek — fallback tarik cepat.")
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
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    log("🚀 FISHING STARTED!")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED")
end

return fishing
