local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

pcall(function()
	if player.PlayerGui:FindFirstChild("SERVERLINE") then
		player.PlayerGui.SERVERLINE:Destroy()
	end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "SERVERLINE"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 370, 0, 430)
frame.Position = UDim2.new(0.5, -185, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "SERVERLINE"
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local scrolling = Instance.new("ScrollingFrame")
scrolling.Size = UDim2.new(1,-10,1,-50)
scrolling.Position = UDim2.new(0,5,0,45)
scrolling.BackgroundTransparency = 1
scrolling.ScrollBarThickness = 6
scrolling.CanvasSize = UDim2.new(0,0,0,0)
scrolling.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.Parent = scrolling

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrolling.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)

local function CreateServer(server)
	local card = Instance.new("TextButton")
	card.Size = UDim2.new(1,-5,0,70)
	card.BackgroundColor3 = Color3.fromRGB(35,35,35)
	card.Text = ""
	card.Parent = scrolling

	Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1,-10,1,-10)
	info.Position = UDim2.new(0,5,0,5)
	info.BackgroundTransparency = 1
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Center
	info.Font = Enum.Font.GothamBold
	info.TextSize = 14
	info.TextColor3 = Color3.new(1,1,1)

	local ping = tostring(server.ping or "?")
	local id = string.sub(server.id,1,12)

	info.Text =
		"👥 Players: "..server.playing.."/"..server.maxPlayers..
		"\n📶 Ping: "..ping.."ms"..
		"\n🆔 "..id

	info.Parent = card

	card.MouseButton1Click:Connect(function()
		TeleportService:TeleportToPlaceInstance(
			game.PlaceId,
			server.id,
			player
		)
	end)
end

task.spawn(function()
	local cursor = ""

	repeat
		local url =
			"https://games.roblox.com/v1/games/"..
			game.PlaceId..
			"/servers/Public?sortOrder=Desc&limit=100"

		if cursor ~= "" then
			url = url.."&cursor="..cursor
		end

		local success, data = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if not success or not data then
			warn("Failed to load servers")
			break
		end

		for _, server in ipairs(data.data) do
			CreateServer(server)
		end

		cursor = data.nextPageCursor
		task.wait(0.2)
	until not cursor
end)
