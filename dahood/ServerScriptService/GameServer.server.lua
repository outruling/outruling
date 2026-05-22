-- GameServer.server.lua
-- Place in: ServerScriptService

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== Remotes =====
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage

local PunchEvent = Instance.new("RemoteEvent")
PunchEvent.Name = "Punch"
PunchEvent.Parent = Remotes

-- ===== Config =====
local PUNCH_DAMAGE = 12
local PUNCH_RANGE = 6
local PUNCH_COOLDOWN = 0.4
local KILL_REWARD = 50
local DEATH_CASH_LOSS = 0.25
local STARTING_CASH = 100

-- ===== Player setup =====
local lastPunch = {}

local function setupPlayer(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = STARTING_CASH
	cash.Parent = leaderstats

	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Value = 0
	kills.Parent = leaderstats
end

local function onCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100

	-- Track last attacker for kill credit
	local lastAttacker = nil
	character:SetAttribute("LastAttacker", nil)

	humanoid.Died:Connect(function()
		-- Lose cash on death
		local cash = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Cash")
		if cash then
			cash.Value = math.floor(cash.Value * (1 - DEATH_CASH_LOSS))
		end

		-- Reward killer
		local killerName = character:GetAttribute("LastAttacker")
		if killerName then
			local killer = Players:FindFirstChild(killerName)
			if killer and killer ~= player then
				local stats = killer:FindFirstChild("leaderstats")
				if stats then
					stats.Kills.Value += 1
					stats.Cash.Value += KILL_REWARD
				end
			end
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)
	player.CharacterAdded:Connect(function(char) onCharacterAdded(player, char) end)
end)

Players.PlayerRemoving:Connect(function(player)
	lastPunch[player] = nil
end)

-- ===== Punch handler (server-validated) =====
PunchEvent.OnServerEvent:Connect(function(player)
	local now = tick()
	if lastPunch[player] and now - lastPunch[player] < PUNCH_COOLDOWN then return end
	lastPunch[player] = now

	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	local myHum = character:FindFirstChildOfClass("Humanoid")
	if not hrp or not myHum or myHum.Health <= 0 then return end

	-- Find closest valid target in front of player
	local closest, closestDist = nil, PUNCH_RANGE
	for _, other in ipairs(Players:GetPlayers()) do
		if other == player then continue end
		local otherChar = other.Character
		if not otherChar then continue end
		local otherHrp = otherChar:FindFirstChild("HumanoidRootPart")
		local otherHum = otherChar:FindFirstChildOfClass("Humanoid")
		if otherHrp and otherHum and otherHum.Health > 0 then
			local dir = (otherHrp.Position - hrp.Position)
			local dist = dir.Magnitude
			-- Only hit targets roughly in front (dot > 0)
			if dist <= closestDist and hrp.CFrame.LookVector:Dot(dir.Unit) > 0.3 then
				closest = otherChar
				closestDist = dist
			end
		end
	end

	if closest then
		local targetHum = closest:FindFirstChildOfClass("Humanoid")
		closest:SetAttribute("LastAttacker", player.Name)
		targetHum:TakeDamage(PUNCH_DAMAGE)
	end
end)
