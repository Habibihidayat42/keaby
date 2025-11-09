-- ⚡ ULTRA SPEED AUTO FISHING (Instant2Xspeed.lua, no toggle key, Full Disable Animations)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Hentikan script lama jika masih aktif
if _G.FishingScript then
    pcall(function() _G.FishingScript.Stop() end)
    task.wait(0.1)
end

-- Network setup
local netFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

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
        FishingDelay = 0.3,
        CancelDelay = 0.05,
        HookDetectionDelay = 0.10,
        RetryDelay = 0.1,
        MaxWaitTime = 1.1,
    }
}
_G.FishingScript = fishing

local function log(msg)
    print(("[Fishing] %s"):format(msg))
end

---------------------------------------------------------------------
-- 🔇 Fungsi untuk menonaktifkan SEMUA animasi di karakter
---------------------------------------------------------------------
local function disableAllAnimations()
    pcall(function()
        -- Hentikan semua track yang sedang dimainkan
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            track:Stop(0)
        end

        -- Nonaktifkan "Animate" default Roblox
        local animate = Character:FindFirstChild("Animate")
        if animate then
            animate.Disabled = true
        end

        -- Hapus animator tambahan
        for _, obj in ipairs(Character:GetDescendants()) do
            if obj:IsA("Animator") or obj:IsA("Animation") or obj:IsA("AnimationTrack") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

---------------------------------------------------------------------
-- 🧩 Disable animasi fishing + posisi rod (gaya v29.1)
---------------------------------------------------------------------
local function disableFishingAnim()
    pcall(function()
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            local n = track.Name:lower()
            if n:find("fish") or n:find("rod") or n:find("cast") or n:find("reel") then
                track:Stop(0)
            end
        end
    end)

    -- Perbaiki posisi rod agar selalu stabil
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

---------------------------------------------------------------------
-- 🎣 CAST utama
---------------------------------------------------------------------
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end

    disableFishingAnim()
    disableAllAnimations()
    fishing.CurrentCycle += 1
    log("⚡ Lempar pancing (Cycle " .. fishing.CurrentCycle .. ")")

    local success = pcall(function()
        RF_ChargeFishingRod:InvokeServer({[22] = tick()})
        task.wait(0.07)
        RF_RequestMinigame:InvokeServer(9, 0, tick())
        fishing.WaitingHook = true
        log("🎯 Menunggu hook...")

        -- Proteksi hook
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

---------------------------------------------------------------------
-- 🚀 START
---------------------------------------------------------------------
function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0

    log("🚀 FISHING STARTED!")
    disableAllAnimations()
    disableFishingAnim()

    fishing.Connections.Minigame = RE_MinigameChanged.OnClientEvent:Connect(function(state)
        if fishing.WaitingHook and typeof(state) == "string" then
            local s = state:lower()
            if s:find("hook") or s:find("bite") or s:find("catch") then
                fishing.WaitingHook = false
                task.wait(fishing.Settings.HookDetectionDelay)
                pcall(function()
                    RE_FishingCompleted:FireServer()
                    log("✅ Hook terdeteksi — ikan ditarik!")
                end)
                task.wait(fishing.Settings.CancelDelay)
                pcall(function() RF_CancelFishingInputs:InvokeServer() end)
                task.wait(fishing.Settings.FishingDelay)
                if fishing.Running then fishing.Cast() end
            end
        end
    end)

    fishing.Connections.Caught = RE_FishCaught.OnClientEvent:Connect(function(name, data)
        if fishing.Running then
            fishing.WaitingHook = false
            fishing.TotalFish += 1
            log("🐟 Ikan tertangkap: " .. tostring(name))
            task.wait(fishing.Settings.CancelDelay)
            pcall(function() RF_CancelFishingInputs:InvokeServer() end)
            task.wait(fishing.Settings.FishingDelay)
            if fishing.Running then fishing.Cast() end
        end
    end)

    -- Loop disable animasi terus-menerus
    fishing.Connections.AnimLoop = task.spawn(function()
        while fishing.Running do
            disableAllAnimations()
            disableFishingAnim()
            task.wait(0.15)
        end
    end)

    task.wait(0.3)
    fishing.Cast()
end

---------------------------------------------------------------------
-- 🛑 STOP
---------------------------------------------------------------------
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
    log("🛑 FISHING STOPPED")
end

return fishing
