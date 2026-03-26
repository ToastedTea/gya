
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
				for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do
					if v:IsA("BasePart") and v.Color == _G.SECONDARYCOLOR then secondary = v end
				end

			end
			for i,v in game:GetService("Workspace")[game.Players.LocalPlayer.Name .. " Aircraft"]:GetDescendants() do

				if v:IsA("BasePart") and v.Color == _G.TARGETCOLOR then
					ticklepickle = false
					primary = v
					loadstring(game:HttpGet("https://raw.githubusercontent.com/ToastedTea/gya/refs/heads/main/gyaaa.lua"))()(v)
					done = true
					thingy:Disconnect()
				end

			end
			done = true
		end)
		repeat task.wait() until done == true
			
		if primary ~= nil and secondary ~= nil then
			repeat task.wait() until primary.Parent == nil
			loadstring(game:HttpGet("https://raw.githubusercontent.com/ToastedTea/gya/refs/heads/main/gyaaa.lua"))()(secondary)
		end
			
	end)


end)
