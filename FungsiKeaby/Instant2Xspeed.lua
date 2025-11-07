-- AdaptiveUltraFishing.lua - SMART FISHING FOR ALL LOCATIONS
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

print("=== 🧠 ADAPTIVE FISHING LOADED ===")

-- Network remotes
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
    CurrentLocation = "Unknown"
}

_G.AdaptiveFishing = fishing

local function log(msg)
    print("[🧠ADAPT] " .. msg)
end

-- **DETECT LOCATION FUNCTION**
local function GetCurrentLocation()
    local character = localPlayer.Character
    if not character then return "Unknown" end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return "Unknown" end
    
    local position = humanoidRootPart.Position
    
    -- Detect berdasarkan position
    if position.Y < -100 then
        return "DeepSea"  -- Deep water areas
    elseif position.X > 1000 then
        return "AncientJungle"
    elseif position.Z > 1500 then
        return "LostIsle" 
    elseif position.Y > 50 then
        return "Mountain"
    else
        return "Shallow"  -- Default/shallow water
    end
end

-- **ADAPTIVE PARAMETERS BASED ON LOCATION**
local function GetFishingParameters()
    local location = GetCurrentLocation()
    fishing.CurrentLocation = location
    
    local parameters = {
        -- Format: {chargePower, chargeTime, timeout}
        Shallow = {9, 0, 0.8},           -- Normal areas
        DeepSea = {15, 2.0, 1.2},        -- Deep water, butuh power lebih
        AncientJungle = {22, 1.95, 1.5}, -- Heavy fish area
        LostIsle = {25, 2.2, 1.8},       -- Very heavy fish
        Mountain = {12, 1.5, 1.0}        -- Medium difficulty
    }
    
    return parameters[location] or parameters["Shallow"]
end

-- **SMART EVENT HANDLERS**
RE_MinigameChanged.OnClientEvent:Connect(function(state)
    if fishing.WaitingHook and typeof(state) == "string" and string.find(string.lower(state), "hook") then
        fishing.WaitingHook = false
        
        -- Adaptive delay based on location
        local location = fishing.CurrentLocation
        local hookDelay = 0.25
        if location == "AncientJungle" or location == "LostIsle" then
            hookDelay = 0.35  -- Butuh waktu lebih untuk fish berat
        end
        
        task.wait(hookDelay)
        RE_FishingCompleted:FireServer()
        log("✅ HOOK @ " .. location .. " - Power pull")
        task.wait(0.02)
        RF_CancelFishingInputs:InvokeServer()
        task.wait(0.15)
        if fishing.Running then fishing.Cast() end
    end
end)

RE_FishCaught.OnClientEvent:Connect(function(name, data)
    if fishing.Running then
        fishing.WaitingHook = false
        fishing.TotalFish = fishing.TotalFish + 1
        local weight = data and data.Weight or 0
        log("🐟 CAUGHT: " .. tostring(name) .. " (" .. string.format("%.2f", weight) .. " kg) @ " .. fishing.CurrentLocation)
        task.wait(0.02)
        RF_CancelFishingInputs:InvokeServer()
        task.wait(0.15)
        if fishing.Running then fishing.Cast() end
    end
end)

-- **ADAPTIVE CASTING FUNCTION**
function fishing.Cast()
    if not fishing.Running or fishing.WaitingHook then return end
    
    fishing.CurrentCycle = fishing.CurrentCycle + 1
    
    -- Get adaptive parameters
    local chargePower, chargeTime, timeout = unpack(GetFishingParameters())
    
    log("🎣 Cast #" .. fishing.CurrentCycle .. " @ " .. fishing.CurrentLocation .. " [Power:" .. chargePower .. "]")
    
    fishing.WaitingHook = true
    
    -- Reset previous
    RF_CancelFishingInputs:InvokeServer()
    task.wait(0.05)
    
    -- Charge dengan power sesuai lokasi
    RF_ChargeFishingRod:InvokeServer({[22] = tick()})
    task.wait(0.05)
    
    -- Request minigame dengan parameter adaptive
    RF_RequestMinigame:InvokeServer(chargeTime, chargePower, tick())
    
    -- Adaptive timeout
    task.delay(timeout, function()
        if fishing.WaitingHook and fishing.Running then
            fishing.WaitingHook = false
            RE_FishingCompleted:FireServer()
            log("⏱️ TIMEOUT @ " .. fishing.CurrentLocation .. " - Retrying...")
            task.wait(0.02)
            RF_CancelFishingInputs:InvokeServer()
            task.wait(0.15)
            if fishing.Running then fishing.Cast() end
        end
    end)
end

function fishing.Start()
    if fishing.Running then return end
    fishing.Running = true
    fishing.CurrentCycle = 0
    fishing.TotalFish = 0
    fishing.WaitingHook = false
    
    -- Detect location pertama kali
    fishing.CurrentLocation = GetCurrentLocation()
    
    log("🚀 ADAPTIVE FISHING STARTED!")
    log("📍 Location: " .. fishing.CurrentLocation)
    fishing.Cast()
end

function fishing.Stop()
    fishing.Running = false
    fishing.WaitingHook = false
    log("🛑 FISHING STOPPED - Total: " .. fishing.TotalFish .. " fish")
end

-- Manual location override
function fishing.SetLocation(location)
    fishing.CurrentLocation = location
    log("📍 Manual location set: " .. location)
end

-- Auto start
task.delay(2, function()
    fishing.Start()
end)

return fishing
