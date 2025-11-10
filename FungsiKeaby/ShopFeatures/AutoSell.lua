-- FungsiKeaby/AutoSell.lua
local AutoSell = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local connection
local enabled = false

function AutoSell.Start()
	if enabled then return end
	enabled = true
	print("[🛒 AutoSell] Started")

	connection = RunService.Heartbeat:Connect(function()
		pcall(function()
			-- contoh event jual
			local sellEvent = ReplicatedStorage:FindFirstChild("RE_SellFish") or ReplicatedStorage:FindFirstChild("SellEvent")
			if sellEvent then
				sellEvent:FireServer()
			end
		end)
	end)
end

function AutoSell.Stop()
	if not enabled then return end
	enabled = false
	if connection then connection:Disconnect() end
	print("[🛒 AutoSell] Stopped")
end

return AutoSell
