local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local TeleportToPlayer = {}

-- Fungsi untuk teleport ke player lain
function TeleportToPlayer.Teleport(playerName)
    local targetPlayer = Players:FindFirstChild(playerName)
    local myChar = localPlayer.Character
    if not targetPlayer or not targetPlayer.Character then return end

    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if targetHRP and myHRP then
        myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
        print("[Teleport] 🚀 Teleported to player: " .. playerName)
    else
        warn("[Teleport] Gagal teleport ke player (HRP tidak ditemukan)")
    end
end

-- 🔄 Fungsi untuk mengambil daftar player yang sedang online
function TeleportToPlayer.GetPlayerList()
    local playerNames = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then
            table.insert(playerNames, plr.Name)
        end
    end
    print("[Teleport] 🔄 Player list refreshed (" .. #playerNames .. " players)")
    return playerNames
end

-- Opsional: event otomatis untuk update ketika ada player masuk/keluar
Players.PlayerAdded:Connect(function(plr)
    print("[Teleport] 👤 Player joined: " .. plr.Name)
end)

Players.PlayerRemoving:Connect(function(plr)
    print("[Teleport] ❌ Player left: " .. plr.Name)
end)

return TeleportToPlayer
