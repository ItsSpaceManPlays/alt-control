local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lPlayer = Players.LocalPlayer

local plrToFollow = nil
local altOwner = nil
local spinSpeed = 0

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
		
		if not args[1] or args[1] == "" then
			plrToFollow = nil
			return
		end

		local targetName = args[1]
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
		
		local target = plrToFollow
		if not target then
			target = getPlayerByName(args[1])
		end
		
		if not target then
			return
		end
		
		plrToFollow = target

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
		
	elseif cmd == "/vkill" then
		
		local humanoid = getMyHumanoid()
		local hrp = getMyHrp()
		if not humanoid or not hrp then
			return
		end
		
		local seatPart = humanoid.SeatPart
		if not seatPart or not seatPart:IsA("VehicleSeat") then
			for _, v in pairs(workspace:GetDescendants()) do

				if v:IsA("VehicleSeat") and v.Occupant == nil then
					seatPart = v
					v:Sit(humanoid)
				end

			end
		end
		
		if not seatPart then
			return
		end
		
		local target = getPlayerByName(args[1])
		
		if not target then
			return
		end
		
		local targetHrp = nil
		if target.Character then
			targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
		end
		
		if not targetHrp then
			return
		end
		
		local startCFrame = hrp.CFrame
		local ancestorModel = seatPart:FindFirstAncestorWhichIsA("Model")
		
		task.wait(0.7)
		
		local targetCFrame = targetHrp.CFrame
		
		ancestorModel:PivotTo(targetCFrame)
		
		task.wait(1)

		ancestorModel:PivotTo(CFrame.new(10000, workspace.FallenPartsDestroyHeight + 100, 10000))
		
		task.wait(0.95)
		
		humanoid.Sit = false
		
		hrp.CFrame = startCFrame

	elseif cmd == "/spin" then

		local targetSpeed = args[1]
		if not targetSpeed or targetSpeed == "" then
			print("bad")
			return
		end
		
		spinSpeed = tonumber(targetSpeed) or 100

	end

end

local function chatted(plr, message)

	if plr.Name == "ItsSpaceManPlays" or plr.Name == "haxedacc2" or plr.Name == "liamdanmark" or plr.Name == "PostOfficeUpgrader2" or plr == altOwner then

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

RunService.RenderStepped:Connect(function(dt)

	local humanoid = getMyHumanoid()

	if spinSpeed < 0 or spinSpeed == 0 then
		if humanoid then
			humanoid.AutoRotate = true
		end

		return
	end

	local hrp = getMyHrp()

	if humanoid then
		humanoid.AutoRotate = false
	end

	if hrp then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed * dt), 0)
	end

end)

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
