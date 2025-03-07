local function GOON()
_G.Loaded = true
local baseMinSpeed = _G.baseMinSpeed        -- Base minimum speed when `targetCharacter` is stationary
local maxSpeed = _G. maxSpeed           -- Maximum speed when far from `targetBlock`
local distanceFactor = _G.distanceFactor         -- Factor to scale speed increase with distance
local velocityFactor = _G.velocityFactor         -- Factor to adjust minimum speed based on `targetCharacter`'s speed
local interceptionThreshold = _G.interceptionThreshold  -- Distance threshold for successful interception
local curveIntensity = _G.  curveIntensity     -- Intensity factor to control the curvature of the path
local PingMS = _G.PingMS
local PingMult = _G.PingMult
	for i,v in game:GetService("Workspace"):GetChildren() do
		if v.Name == "TargetBlock"  then
			v:Destroy()
		end
	end



	for i,v in game:GetService("Workspace"):GetChildren() do
		if v.Name == "Highlights"  then
			v:Destroy()
		end
	end

	local assignableTargetBlock = nil  -- Can be set later to a valid target block

	local aircraft = game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]






	local function foundWelds(obj)
		local gyat = false
		for i,v in obj:GetChildren() do
			if v:IsA("Weld") or v:IsA("ManualWeld") then gyat = true end
		end
		return gyat
	end

	for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do

		if v:IsA("BasePart") and v.Color == Color3.fromRGB(0,255,0) then
			assignableTargetBlock = v

		end

	end



	if assignableTargetBlock == nil then print("boowomp") return end


	local player = game.Players.LocalPlayer
	local targetCharacter = nil
	local targetBlock = Instance.new("Part")
	targetBlock.Name = "TargetBlock"
	targetBlock.Shape = Enum.PartType.Ball  -- Change to a ball shape
	local blocksize = 1
	targetBlock.Size = Vector3.new(blocksize, blocksize, blocksize)  -- Adjust the size to be spherical
	targetBlock.Position = Vector3.new(0, 251521215215251, 0)
	targetBlock.Anchored = true  -- Make sure it is not anchored
	targetBlock.CanCollide = false  -- Disable collision
	targetBlock.Massless = true
	targetBlock.Parent = workspace


	local targetBlock2 = Instance.new("Part")
	targetBlock2.Name = "TargetBlock"
	targetBlock2.Shape = Enum.PartType.Ball  -- Change to a ball shape
	targetBlock2.Size = Vector3.new(blocksize, blocksize, blocksize)  -- Adjust the size to be spherical
	targetBlock2.Position = Vector3.new(0, 251521215215251, 0)
	targetBlock2.Anchored = true  -- Make sure it is not anchored
	targetBlock2.CanCollide = false  -- Disable collision
	targetBlock2.Massless = true
	targetBlock2.Parent = workspace

	local targetBlock21 = Instance.new("Part")
	targetBlock21.Name = "TargetBlock"
	targetBlock21.Shape = Enum.PartType.Ball  -- Change to a ball shape
	targetBlock21.Size = Vector3.new(blocksize, blocksize, blocksize)  -- Adjust the size to be spherical
	targetBlock21.Position = Vector3.new(0, 251521215215251, 0)
	targetBlock21.Anchored = true  -- Make sure it is not anchored
	targetBlock21.CanCollide = false  -- Disable collision
	targetBlock21.Massless = true
	targetBlock21.Parent = workspace




	local players = game:GetService("Players")
	local npcFolder = game.ReplicatedFirst -- Folder containing NPCs
	local highlightFolder
	if workspace:FindFirstChild("Highlights") then

		highlightFolder =  workspace:FindFirstChild("Highlights")
	else
		highlightFolder = Instance.new("Folder", workspace)
		highlightFolder.Name = "Highlights"
	end



	local screenRadius = 50 -- Radius in 2D screen space for selection
	local camera = workspace.CurrentCamera

	-- Function to create a highlight for a target
	local function createHighlight(target, color,name1)
		local highlight = highlightFolder:FindFirstChild(name1 .. "_Highlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Adornee = target
			highlight.FillColor = color
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Name = name1.. "_Highlight"
			highlight.Parent = highlightFolder
		end
		return highlight
	end




	local function calculateInterceptionPoint()
		local assignablePos = assignableTargetBlock.Position
		local targetPos = targetBlock.Position
		local targetVelocity = targetCharacter.HumanoidRootPart.Velocity

		-- Calculate relative position and speed
		local relativePosition = targetPos - assignablePos
		local targetSpeed = targetVelocity.Magnitude

		-- Calculate assignableTargetBlock's speed dynamically based on distance and target speed
		local distanceToTarget = relativePosition.Magnitude
		local assignableSpeed = math.clamp(baseMinSpeed + (distanceToTarget * distanceFactor), baseMinSpeed, maxSpeed)

		-- Calculate time to interception point based on relative velocity and positions
		local interceptTime = relativePosition.Magnitude / (assignableSpeed + targetSpeed)

		-- Predict future position of `targetBlock` based on its velocity and calculated intercept time
		return targetPos + targetVelocity * interceptTime
	end
	local hasIntercept = false

	local ended = false
	local function handleAssignableTargetBlock()

		local error1 = pcall(function()
			if assignableTargetBlock and targetCharacter and ended == false and targetCharacter:FindFirstChild("HumanoidRootPart") ~= nil then
				-- Ensure assignableTargetBlock has a BodyVelocity for movement
				if not assignableTargetBlock:FindFirstChildOfClass("BodyVelocity") then
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bodyVelocity.Velocity = Vector3.zero
					bodyVelocity.Parent = assignableTargetBlock
				end

				-- Calculate the interception point
				local targetPosition = calculateInterceptionPoint()


				local directionToTarget = (targetPosition - assignableTargetBlock.Position).unit
				local perpendicularDirection = Vector3.new(-directionToTarget.Z, 0, directionToTarget.X) * curveIntensity
				targetBlock2.Position = targetPosition
				targetBlock21.Position = targetCharacter.HumanoidRootPart.Position
				-- Combine direction with perpendicular direction to get a smooth curve
				local curvedDirection = (directionToTarget + perpendicularDirection).unit
				local distanceToTarget = (targetPosition - assignableTargetBlock.Position).Magnitude
				local targetCharacterSpeed = targetCharacter.HumanoidRootPart.Velocity.Magnitude
				local minSpeed = baseMinSpeed + (targetCharacterSpeed * velocityFactor)
				local customSpeed = math.clamp(minSpeed + (distanceToTarget * distanceFactor), minSpeed, maxSpeed)

				-- Move assignableTargetBlock towards the target position with the curved path
				local bodyVelocity = assignableTargetBlock:FindFirstChildOfClass("BodyVelocity")

				-- Check if `assignableTargetBlock` has intercepted `targetBlock`
				if ((assignableTargetBlock.Position - targetPosition).Magnitude <= interceptionThreshold and hasIntercept == false) or hasIntercept == true then
					
					hasIntercept = true
					task.delay(2,function()
						hasIntercept = false
					end)

					if bodyVelocity then
						bodyVelocity.Velocity = bodyVelocity.Velocity
					end

					-- Make assignableTargetBlock face the direction it's moving
					if bodyVelocity.Velocity.Magnitude > 0 then
						assignableTargetBlock.CFrame = CFrame.lookAt(assignableTargetBlock.Position, assignableTargetBlock.Position + bodyVelocity.Velocity.unit)
					end


				else

					if bodyVelocity then
						bodyVelocity.Velocity = curvedDirection * customSpeed
					end

					-- Make assignableTargetBlock face the direction it's moving
					if bodyVelocity.Velocity.Magnitude > 0 then
						assignableTargetBlock.CFrame = CFrame.lookAt(assignableTargetBlock.Position, assignableTargetBlock.Position + bodyVelocity.Velocity.unit)
					end
				end

			end
		end)

	end


	-- Function to update highlight colors
	local function updateHighlights()
		if ended == false then

			for _, highlight in pairs(highlightFolder:GetChildren()) do
				highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Default red for non-targets
			end
			if targetCharacter then
				local targetHighlight = highlightFolder:FindFirstChild(targetCharacter.Name .. "_Highlight")
				if targetHighlight then
					targetHighlight.FillColor = Color3.fromRGB(0, 255, 0) -- Green for the current target
				end
			end
		end

	end

	-- Function to set a new target
	local function setTarget(newTarget)
		if ended == false then



			for i,v in pairs(game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants()) do
				if v:IsA("BasePart") and v ~= assignableTargetBlock then
					v.CanCollide = false
				end
			end

			targetCharacter = newTarget
			updateHighlights()
		end

	end

	-- Function to create and refresh highlights for players and NPCs
	local function setupHighlights()
		for _, otherPlayer in pairs(players:GetPlayers()) do
			if otherPlayer ~= player and otherPlayer.Character then
				local AHGAHAHAH = workspace:FindFirstChild("PIayerAircraft"):FindFirstChild(otherPlayer.Name) or game:GetService("Workspace"):FindFirstChild(otherPlayer.Name .. " Aircraft")
				createHighlight(AHGAHAHAH, Color3.fromRGB(255, 0, 0),otherPlayer.Name) -- Default red
			end
		end
		for _, npc in pairs(npcFolder:GetChildren()) do
			if npc:FindFirstChild("HumanoidRootPart") then
				createHighlight(npc, Color3.fromRGB(255, 0, 0)) -- Default red
			end
		end
	end


	local function createBillboardGui(targetPart, color)





		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Adornee = targetPart
		billboardGui.Size = UDim2.new(0, 40, 0, 40) -- Adjust size of the outline
		billboardGui.StudsOffset = Vector3.new(0, 0, 0) -- Adjust height above the target
		billboardGui.AlwaysOnTop = true
		billboardGui.Parent = targetBlock

		-- Frame for the outline
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(.4, 0, .4, 0)
		frame.Position = UDim2.new(0.5, 0, 0.5, 0)
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 0.6
		frame.BorderColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 3
		frame.Parent = billboardGui

		-- TextLabel for the distance display
		local distanceLabel = Instance.new("TextLabel")
		distanceLabel.Size = UDim2.new(.9, 0, .9, 0) -- Adjust to fill the billboard
		distanceLabel.Position = UDim2.new(0, 10, 0, -20)
		distanceLabel.BackgroundTransparency = 1 -- Transparent background
		distanceLabel.TextScaled = true
		distanceLabel.TextColor3 = color -- White text
		distanceLabel.TextTransparency = 0
		distanceLabel.TextSize = 24 -- Make the text bigger
		distanceLabel.Text = "Distance: 0.00 meters" -- Default text
		distanceLabel.Parent = billboardGui


		-- Center the text
		distanceLabel.TextXAlignment = Enum.TextXAlignment.Center -- Center horizontally
		distanceLabel.TextYAlignment = Enum.TextYAlignment.Center  -- Center vertically
		-- Add a black outline to the text
		distanceLabel.TextStrokeTransparency = 0 -- Set stroke transparency (0 = no stroke, 1 = full stroke)
		distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0) -- Black outline color

		local function updateDistance1()


			local gagaga = (targetPart.Position - assignableTargetBlock.Position).Magnitude
			local roundedDistance = math.round(gagaga) -- Round to the nearest whole number
			distanceLabel.Text = roundedDistance .. " Studs"


		end



		game:GetService("RunService").RenderStepped:Connect(updateDistance1)
		return billboardGui,distanceLabel
	end

	-- Periodically check if players or NPCs need highlights
	game:GetService("RunService").Heartbeat:Connect(setupHighlights)
	game:GetService("RunService").Heartbeat:Connect(function()
		handleAssignableTargetBlock()  -- Handle the assignable target block if it exists
	end)
	-- Function to update the target block's position with prediction based on ping



	local function updateTargetBlock()
		if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") and ended == false then
			local targetRootPart = targetCharacter.HumanoidRootPart
			local pingInSeconds = (PingMS * PingMult) / 2000
			local velocity = targetRootPart.Velocity
			local direction = targetRootPart.CFrame.LookVector
			local up = targetRootPart.CFrame.UpVector
			local predictedPosition = targetRootPart.Position + targetRootPart.AssemblyLinearVelocity * pingInSeconds
			local horizontalSensitivity = 0
			local verticalSensitivity = 0
			local horizontalOffset = direction * (velocity.X * pingInSeconds * horizontalSensitivity)
			local verticalOffset = up * (velocity.Y * pingInSeconds * verticalSensitivity)
			predictedPosition = predictedPosition --+ horizontalOffset + verticalOffset
			targetBlock.Position = predictedPosition
		end
	end





	-- Function to detect and set the closest target within a 2D screen radius
	local function onPlayerClicked(mousePosition)
		local closestTarget = nil
		local closestDistance = screenRadius
		if ended == false then
			for _, otherPlayer in pairs(players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
					local screenPoint, onScreen = camera:WorldToScreenPoint(otherPlayer.Character.HumanoidRootPart.Position)
					if onScreen then
						local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePosition.X, mousePosition.Y)).Magnitude
						if distance <= closestDistance then
							closestTarget = otherPlayer.Character
							closestDistance = distance
						end

					end
				end
			end
			for _, npc in pairs(npcFolder:GetChildren()) do
				if npc:FindFirstChild("HumanoidRootPart") then
					local screenPoint, onScreen = camera:WorldToScreenPoint(npc.HumanoidRootPart.Position)
					if onScreen then
						local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(mousePosition.X, mousePosition.Y)).Magnitude
						if distance <= closestDistance then
							closestTarget = npc
							closestDistance = distance
						end
					end
				end
			end

			if closestTarget then
				setTarget(closestTarget)
			end

		end
		-- Check all players and NPCs within the radius around the mouse position in screen space

	end

	-- Click event for targeting within a radius in screen space
	local userInputService = game:GetService("UserInputService")
	userInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = player:GetMouse()
			local mousePosition = Vector2.new(mouse.X, mouse.Y)
			onPlayerClicked(mousePosition)
		end
	end)

	local function checkProximity()
		if assignableTargetBlock and targetBlock and ended == false then
			local distance = (assignableTargetBlock.Position - targetBlock.Position).Magnitude
			if distance <= 5 then  -- You can adjust this threshold as needed
				local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
				local explode = remotes:WaitForChild("Explode")

				for i, v in pairs(aircraft:GetChildren()) do
					if v.Name == "ExplosiveBlock" then
						--explode:FireServer(v, 2500, 12)
					end
				end
			end
		end
	end

	local targetgobye = false




	local player = game.Players.LocalPlayer
	local playerGui = player:FindFirstChildOfClass("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = playerGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Parent = screenGui
	textLabel.Size = UDim2.new(0.2, 0, 0.05, 0) -- Adjust size as needed
	textLabel.Position = UDim2.new(0.8, 0, 0, 0) -- Top right
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "Ping: "
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true

	task.spawn(function()
		while targetgobye == false do
			local pingRf = game:GetService("ReplicatedStorage").NexusAdmin_GetPersistentBanList
			local start = time()
			pingRf:InvokeServer()
			local yooo = (time() - start)

			PingMS = (yooo * 1000)

			if PingMS <= 5 then
				PingMS = 70
			end


			textLabel.Text = "Ping: ".. PingMS


			task.wait(3)
		end
	end)

	local function onTargetBlockDestroyed()
		targetgobye = true
		ended = true
		textLabel.Text = "NOIOOOOOO"
		assignableTargetBlock:Destroy()
		targetBlock:Destroy()
		targetBlock21:Destroy()
		targetBlock2:Destroy()
		highlightFolder:Destroy()
		screenGui:Destroy()
		--script:Destroy()

	end

	-- Connect the event to detect if targetBlock gets destroyed

	-- Periodically check proximity
	game:GetService("RunService").Heartbeat:Connect(function()
		if game:GetService("Workspace"):FindFirstChild(game.Players.LocalPlayer.Name .. " Aircraft") == nil and targetgobye == false then 
			onTargetBlockDestroyed()
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(checkProximity)
	-- Initial setup of highlights and main loop
	setupHighlights()
	game:GetService("RunService").RenderStepped:Connect(updateTargetBlock)

	local ee,label31 = createBillboardGui(targetBlock,Color3.fromRGB(0, 0, 255))
	local ee1,label32 = createBillboardGui(targetBlock2,Color3.fromRGB(255, 255, 0))
	local ee2,label3 = createBillboardGui(targetBlock21,Color3.fromRGB(255, 0, 0))

--[[ Add a blue highlight to the target block for visibility
local targetBlockHighlight = Instance.new("Highlight")
targetBlockHighlight.Adornee = targetBlock
targetBlockHighlight.FillColor = Color3.fromRGB(0, 0, 255) -- Blue
targetBlockHighlight.Parent = targetBlock
targetBlockHighlight.OutlineTransparency = 1
--]]
	local targetBlockHighlight1 = Instance.new("Highlight")
	targetBlockHighlight1.Adornee = assignableTargetBlock
	targetBlockHighlight1.FillColor = Color3.fromRGB(100, 0, 255) -- gren
	targetBlockHighlight1.Parent = assignableTargetBlock
	targetBlockHighlight1.OutlineTransparency = 1
end


--GOON()


workspace.ChildAdded:Connect(function(chil)
	task.spawn(function()
		local air = game:GetService("Workspace"):WaitForChild(game.Players.LocalPlayer.Name .. " Aircraft",2)

		if air ~= chil then return end
		if air== nil then return end
		print("tahoe")

		local ticklepickle = true		
		local thingy
		thingy = game:GetService("RunService").RenderStepped:Connect(function()
			if ticklepickle == false then return end
			for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do

				if v:IsA("BasePart") and v.Color == Color3.fromRGB(0,255,0) then
					ticklepickle = false
					GOON()
					thingy:Disconnect()

				end

			end
		end)
	end)


end)
