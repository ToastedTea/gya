
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
					loadstring(game:HttpGet("https://raw.githubusercontent.com/ToastedTea/gya/refs/heads/main/gyaaa.lua"))()
					thingy:Disconnect()

				end

			end
		end)
	end)


end)
