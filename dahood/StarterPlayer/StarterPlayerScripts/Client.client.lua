-- Client.client.lua
-- Place in: StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PunchEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Punch")

-- ===== Input =====
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.KeyCode == Enum.KeyCode.ButtonR2 then
		PunchEvent:FireServer()
	end
end)

-- ===== HUD =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameHUD"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Size = UDim2.new(0, 240, 0, 60)
container.Position = UDim2.new(0, 20, 1, -80)
container.BackgroundTransparency = 1
container.Parent = screenGui

local function createBar(yOffset, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 22)
	frame.Position = UDim2.new(0, 0, 0, yOffset)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BorderSizePixel = 0
	frame.Parent = container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 4)
	corner.Parent = frame

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = frame
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	return fill, label
end

local healthFill, healthLabel = createBar(0, Color3.fromRGB(220, 50, 50))
local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.new(1, 0, 0, 24)
cashLabel.Position = UDim2.new(0, 0, 0, 30)
cashLabel.BackgroundTransparency = 1
cashLabel.TextColor3 = Color3.fromRGB(120, 220, 120)
cashLabel.TextStrokeTransparency = 0.4
cashLabel.Font = Enum.Font.GothamBlack
cashLabel.TextSize = 22
cashLabel.TextXAlignment = Enum.TextXAlignment.Left
cashLabel.Text = "$0"
cashLabel.Parent = container

-- ===== Update loop =====
RunService.RenderStepped:Connect(function()
	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.MaxHealth > 0 then
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			healthFill.Size = UDim2.new(pct, 0, 1, 0)
			healthLabel.Text = string.format("HP  %d / %d", math.ceil(hum.Health), hum.MaxHealth)
		end
	end

	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Cash") then
		cashLabel.Text = "$" .. stats.Cash.Value
	end
end)
