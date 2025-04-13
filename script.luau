local Players = game:GetService("Players")

local lPlayer = Players.LocalPlayer

local plrToFollow = nil
local altOwner = nil

local function getPlayerByName(partialName)
	partialName = partialName:lower()

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name:lower():find(partialName) or player.DisplayName:lower():find(partialName) then
			return player
		end
	end

	return nil
end

local function getMyHrp()
	
	if lPlayer.Character then
		local hrp = lPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			return hrp
		end
	end
	
end

local function getMyHumanoid()
	
	if lPlayer.Character then
		local humanoid = lPlayer.Character:FindFirstChild("Humanoid")
		if humanoid then
			return humanoid
		end
	end
	
end

local safePart = Instance.new("Part")
safePart.Size = Vector3.new(100, 5, 100)
safePart.Position = Vector3.new(800, 100, 800)
safePart.Transparency = 0.8
safePart.Anchored = true
safePart.Color = Color3.fromRGB(255, 255, 255)

safePart.Parent = workspace

local function doCommand(executor, cmd, args)
	
	if not args then args = {} end
	
	print(cmd, "args", table.concat(args, ", "))
	
	if cmd == "/tphere" then
		
		local executorCFrame
		
		if executor.Character then
			local eHrp = executor.Character:FindFirstChild("HumanoidRootPart")
			if eHrp then
				executorCFrame = eHrp.CFrame
			end
		end
		
		if not executorCFrame then return end
		
		local char = lPlayer.Character
		if char then
			
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				
				plrToFollow = nil
				hrp.CFrame = executorCFrame + executorCFrame.LookVector * 5
				
			end
			
		end
		
	elseif cmd == "/teleport" then
		
		local targetName = args[1] or ""
		local target = getPlayerByName(targetName)
		
		if not target then return end
		
		local targetCFrame

		if target.Character then
			local tHrp = target.Character:FindFirstChild("HumanoidRootPart")
			if tHrp then
				targetCFrame = tHrp.CFrame
			end
		end
		
		if not targetCFrame then return end
		
		local char = lPlayer.Character
		if char then

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				
				plrToFollow = nil
				hrp.CFrame = targetCFrame

			end

		end
		
	elseif cmd == "/follow" then
		
		local targetName = args[1] or ""
		local target = getPlayerByName(targetName)
		
		if not target and targetName == "me" then
			target = executor
		end
		
		plrToFollow = target
		
	elseif cmd == "/to" then
		
		local targetName = args[1] or ""
		local target = getPlayerByName(targetName)
		
		if target then
			
			altOwner = target
			print("set ownership to", target.Name)
			
		end
		
	elseif cmd == "/safepart" then
		
		local hrp = getMyHrp()
		if hrp then
			
			plrToFollow = nil
			hrp.CFrame = safePart.CFrame + Vector3.yAxis * 20
			
		end
		
	elseif cmd == "/shutdown" then
		
		lPlayer:Kick("shutdown")
		
	elseif cmd == "/vfling" then
		
		local hrp = getMyHrp()
		local humanoid = getMyHumanoid()
		
		if not hrp or not humanoid then
			return
		end
		
		local seatPart = humanoid.SeatPart
		
		if not seatPart then
			for _, v in pairs(workspace:GetDescendants()) do
				if v:IsA("VehicleSeat") then
					hrp.CFrame = v.CFrame
					humanoid:Sit(v)
					seatPart = v
				end
			end
		end
		
		local ancestorModel = seatPart:FindFirstAncestorWhichIsA("Model")
		
		ancestorModel:PivotTo(safePart.CFrame + Vector3.yAxis * 30)
		
	end
	
end

local function chatted(plr, message)
	
	if plr.Name == "ItsSpaceManPlays" or plr == altOwner then
		
		local stuff = string.split(message, " ")
		local args = table.clone(stuff)
		table.remove(args, 1)
		
		doCommand(plr, stuff[1], args)
		
	end
	
end

Players.PlayerAdded:Connect(function(plr)
	
	plr.Chatted:Connect(function(message, recipient)
		chatted(plr, message)
	end)
	
end)

for _, plr in pairs(Players:GetPlayers()) do
	plr.Chatted:Connect(function(msg)
		chatted(plr, msg)
	end)
end

while true do
	
	task.wait()

	local cf = nil

	if plrToFollow then

		if plrToFollow.Character then
			local hrp = plrToFollow.Character:FindFirstChild("HumanoidRootPart")
			if hrp then

				cf = hrp.CFrame

			end
		end

	end

	local ourHrp = nil

	if lPlayer.Character then
		ourHrp = lPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	if ourHrp and cf then
		
		ourHrp.CFrame = cf + cf.LookVector * -3
		
	end

end
