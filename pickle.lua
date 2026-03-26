workspace.ChildAdded:Connect(function(chil)
	task.spawn(function()
		local air = game:GetService("Workspace"):WaitForChild(game.Players.LocalPlayer.Name .. " Aircraft",2)

		if air ~= chil then return end
		if air== nil then return end
		print("tahoe")

		local ticklepickle = true		
		local thingy
		local secondary = nil
		local primary = nil

		local done = false
		thingy = game:GetService("RunService").RenderStepped:Connect(function()
			if ticklepickle == false then return end
			if not game.Workspace:FindFirstChild(game.Players.LocalPlayer.Name.. " Aircraft") then return end
			for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do
				if v:IsA("BasePart") and v.Color == _G.SECONDARYCOLOR then secondary = v print("found secnd") end
			end

			for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do

				if v:IsA("BasePart") and v.Color == _G.TARGETCOLOR then
					ticklepickle = false
					primary = v
					local fa = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToastedTea/gya/refs/heads/main/gyaaa.lua"))()
					fa(v)
					done = true
					thingy:Disconnect()
				end

			end
		end)


		repeat task.wait() until done == true and primary ~= nil
		if _G.EXPECTSECOND then repeat task.wait() until secondary ~= nil end
		print(primary.Name)
		print(secondary.Name)
		if primary ~= nil and secondary ~= nil then
			repeat task.wait() until primary.Parent == nil or primary == nil or primary:HasTag("byebye")
			local fa = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToastedTea/gya/refs/heads/main/gyaaa.lua"))()
	
			print("Ya")
			fa(secondary)
		end
	end)
end)
