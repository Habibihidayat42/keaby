-- 🌍 TeleportModule.lua
-- Modul fungsi teleport + daftar lokasi

local TeleportModule = {}

TeleportModule.Locations = {
    ["Ancient Jungle"] = Vector3.new(130.70089721679688, 3.5315709114074707, 2769.5888671875),
    ["Sysiphus Statue"] = Vector3.new(-3656.56201171875, -134.5314178466797, -964.3167724609375),
    ["Frost Cavern"] = Vector3.new(250.219, 5.014, 3500.002),
    ["Volcanic Rift"] = Vector3.new(-500.011, 4.312, 2600.755)
}

function TeleportModule.TeleportTo(name)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local target = TeleportModule.Locations[name]
    if not target then
        warn("⚠️ Lokasi '" .. tostring(name) .. "' tidak ditemukan!")
        return
    end

    root.CFrame = CFrame.new(target)
    print("✅ Teleported to:", name)
end

return TeleportModule
