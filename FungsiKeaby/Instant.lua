-- Instant.lua (Fish It - Adaptive Instant Bite)
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
        HookDelay = 0.06,
        FallbackTimeout = 2.5,
        Adaptive = true, -- aktifkan auto timing
    },
}
_G.FishingScript = fishing

local function log(msg)
    print("[FishIt] " .. msg)
end

-- ambil nama rod yang sedang dipegang
local function getRodName()
    local char = localPlayer.Character
    if not char then return "Unknown" end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and item.Name:lower():find("rod") then
            return item.Name
        end
    end
    return "Unknown"
end

-- tentukan delay berdasar rod (Fish It timing)
local function getDelayForRod()
    local name = getRodName():lower()
    if name:find("ghostfinn") then
        return 0.05
    elseif name:find("steampunk") then
        return 0.23
    elseif name:find("sunken") then
        return 0.17
    elseif name:find("wooden") then
        return 0.25
    else
        return 0.15 -- default
    end
end

-- listener minigame
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if not fishing.Running or not fishing.WaitingHook then return end
    if typeof(state) ~= "string" then return end
    local s = string.lower(state)
    if s:find("hook") or s:find("bite") then
        fishing.WaitingHook = false
        task.spawn(function()
            task.wait(fishing.Settings.HookDelay)
            pcall(function() RE_FishingCompleted:FireServer() end)
            log("⚡ Hook → FishingCompleted fired (Fish It sync)")
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
    log(("🐟 Caught: %s (%.2f kg)"):format(tostring(name or "Fish"), weight))
    task.spawn(function()
        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        if fishing.Running then fishing.Cast() end
    end)
end)

function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    fishing.WaitingHook = true

    local rodName = getRodName()
    local delay = getDelayForRod()

    log(("🎣 Casting (rod=%s | delay=%.2fs)"):format(rodName, delay))

    task.spawn(function()
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        pcall(function() RF_ChargeFishingRod:InvokeServer({[4] = tick()}) end)
        task.wait(delay)
        pcall(function() RF_RequestMinigame:InvokeServer(1.95, 0.5, tick()) end)
        log("🎯 Cast sent (Charge → Request)")

        -- ⚡ Cepatkan tanda seru muncul (client-side visual)
        task.delay(0.05, function()
            local char = localPlayer.Character
            if char and char:FindFirstChild("Head") then
                local ex = Instance.new("BillboardGui")
                ex.Name = "QuickExclamation"
                ex.Size = UDim2.new(0, 50, 0, 50)
                ex.StudsOffset = Vector3.new(0, 2.5, 0)
                ex.AlwaysOnTop = true
                ex.Adornee = char.Head

                local label = Instance.new("TextLabel")
                label.Parent = ex
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = "!"
                label.TextColor3 = Color3.fromRGB(255, 255, 100)
                label.TextScaled = true
                label.Font = Enum.Font.GothamBold
                ex.Parent = char.Head

                task.delay(0.25, function()
                    if ex then ex:Destroy() end
                end)
            end
        end)

        -- ⚙️ Fast-sync: tunggu pendek (tapi beri server waktu memulai minigame)
        local hookWait = math.clamp(delay * 1.2, 0.1, 0.25)
        task.wait(hookWait)

        -- Setelah “bite” seharusnya mulai → langsung kirim FishingCompleted
        pcall(function() RE_FishingCompleted:FireServer() end)
        log(("⚡ Fast-sync bite complete (%.2fs delay)"):format(hookWait))

        task.wait(fishing.Settings.CancelDelay)
        pcall(function() RF_CancelFishingInputs:InvokeServer() end)
        task.wait(fishing.Settings.FishingDelay)
        fishing.WaitingHook = false
        if fishing.Running then fishing.Cast() end
    end)
end


function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.TotalFish = 0
    log("🚀 Adaptive Instant Fishing Started (Fish It)")
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 Fishing stopped")
end

return fishing
