while not game:IsLoaded() do wait() end

local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()

local Window = Luna:CreateWindow({
	Name = "Foresaken",
	Subtitle = "Cerberus",
	LogoID = nil,
	LoadingEnabled = true,
	LoadingTitle = "Loading Foresaken...",
	LoadingSubtitle = "Cerberus | Premium Scripts",
	ConfigSettings = {
		RootFolder = "Cerberus",
		ConfigFolder = "Foresaken"
	},
	KeySystem = false
})

local AutomationTab = Window:CreateTab({
	Name = "Automation",
	Icon = "memory",
	ImageSource = "Material",
	ShowTitle = true
})

AutomationTab:CreateSection("Main Control")

_G.autoRun = false
local botThread = nil

local function startBot()
	botThread = task.spawn(function()
		-- Rewrite: 2
while not game:IsLoaded() do
    wait()
end

local PFS = game:GetService("PathfindingService")
local VIM = game:GetService("VirtualInputManager")

local testPath = PFS:CreatePath({
    AgentRadius = 2,
    AgentHeight = 5,
    AgentCanJump = false,
    AgentJumpHeight = 10,
    AgentCanClimb = true,
    AgentMaxSlope = 45
})

local isInGame, currentCharacter, humanoid, waypoints, counter, gencompleted, s, f, stopbreakingplease, isSprinting, stamina, busy, reached, start_time, fail_attempt
local Spectators = {}
fail_attempt = 0
-- In-game check
task.spawn(function()
while true do
    Spectators = {}
    print("     <- All")
    for i, child in game.Workspace.Players.Spectating:GetChildren() do
        print("[In-game Check] - A loop just being ran")
        print("      -> ".. child.Name)
        table.insert(Spectators, child.Name)
    end
    if table.find(Spectators, game.Players.LocalPlayer.Name) then
        isInGame = false
        print("    - Not in game")
        wait(1)
    else
        print("    + Is in game")
        isInGame = true
        wait(1)
    end
end
end)

task.spawn(function()
isSprinting = false
while true do
    if isInGame then
    local success, err = pcall(function()
        currentCharacter.Humanoid:SetAttribute("BaseSpeed", 14)
        local barText = game.Players.LocalPlayer.PlayerGui.TemporaryUI.PlayerInfo.Bars.Stamina.Amount.Text
        stamina = tonumber(string.split(barText, "/")[1])
        print("âš¡ Stamina read:", stamina)

        local isSprintingFOV = currentCharacter.FOVMultipliers.Sprinting.Value == 1.125
        print("ğŸƒâ€â™‚ï¸ Is currently sprinting (FOV check):", isSprintingFOV)

        if not isSprintingFOV then
            print("ğŸ” Not sprinting, evaluating sprint conditions...")
            
            if stamina >= 70 then
                print("âœ… Stamina sufficient (", stamina, ") â€” attempting to sprint...")
            else
                print("ğŸ›‘ Conditions not met for sprinting. Stamina:", stamina, " | Busy:", tostring(busy))
                wait(0.1)
                return
            end
            if busy then
                print("busy")
                return
            end

            print("âŒ¨ï¸ Sending LeftShift key event to initiate sprint.")
            VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
        else
            print("âœ”ï¸ Already sprinting â€” no action taken.")
        end
    end)

    if not success then
        warn("âŒ Error occurred during loop:", err)
    end
    end
    wait(1)
end
end)

--Hopping Handler
task.spawn(function()
wait(20*60)
local ts = game:GetService("TeleportService")
ts:Teleport(game.placeId)
end)


-- Main loop
while true do
if isInGame then
    for _, surv in ipairs(game.Workspace.Players.Survivors:GetChildren()) do
        if surv:GetAttribute("Username") == game.Players.LocalPlayer.Name then
            currentCharacter = surv
            print("    -> currentCharacter set to", surv.Name)
        end
    end
    -- Death handler
    task.spawn(function()
        while true do
            if currentCharacter and currentCharacter:FindFirstChild("Humanoid") then
                if currentCharacter.Humanoid.Health <= 0 then
                    print("ğŸ’€ You died.")
                    isInGame = false
                    isSprinting = false
                    busy = false
                    break
                end
            end
        wait(0.5)
        end
    end)

    for _, completedgen in ipairs(game.ReplicatedStorage.ObjectiveStorage:GetChildren()) do
        if not isInGame then
            warn("???")
            break
        end
        local required = completedgen:GetAttribute("RequiredProgress")
        if completedgen.Value == required then
            print("âœ… Completed all gens, proceed to RUN!")
            while #game.Workspace.Players:WaitForChild("Killers"):GetChildren() >= 1 do
                if #game.Workspace.Players.Killers:GetChildren() == 0 then
                        isInGame = false
                        break
                    end
                s, f = pcall(function()
                    for _, killer in ipairs(game.Workspace.Players.Killers:GetChildren()) do
                        local dist = (killer.HumanoidRootPart.Position - currentCharacter.HumanoidRootPart.Position).Magnitude
                        if dist <= 100 then
                            print("âš ï¸ Killer nearby! Running...")

                            testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, currentCharacter.HumanoidRootPart.Position + (-killer.HumanoidRootPart.CFrame.LookVector).Unit * 50)
                            waypoints = testPath:GetWaypoints()
                            humanoid = currentCharacter:WaitForChild("Humanoid")

                            print("ğŸ“ Got", #waypoints, "waypoints. Moving...")
                            
                            local conn
                            for idx, wp in ipairs(waypoints) do
                                if stopbreakingplease then
                                    humanoid:MoveTo(currentCharacter.HumanoidRootPart.Position)
                                    break
                                end

                                reached = false
                                start_time = os.clock()
                                conn = humanoid.MoveToFinished:Connect(function(s)
                                    reached = s
                                    print("    Reached waypoint", idx)
                                    conn:Disconnect()
                                end)

                                humanoid:MoveTo(wp.Position)
                                repeat wait(0.01) until reached or (os.clock() - start_time) >= 10
                                if not reached then
                                    testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, goalPos)
                                    waypoints = testPath:GetWaypoints()
                                    warn(("ğŸ“ Waypoint %d timed out after 10 secs â€” gen another path"):format(idx))
                                    fail_attempt = fail_attempt + 1
                                    warn(fail_attempt)
                                    if counter >= 5 then
                                        warn("Fail, break")
                                        fail_attempt = 0
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
                wait(0.1)
            end
            print(s)
            print(f)

        else
            -- Try to repair a generator
            for _, gen in ipairs(game.Workspace.Map.Ingame:WaitForChild("Map"):GetChildren()) do
                if gen.Name == "Generator" and gen.Progress.Value ~= 100 then
                    print("ğŸ”§ Generator found:", gen.Name, "progress =", gen.Progress.Value)
                    local goalPos = gen:WaitForChild("Positions").Right.Position
                    print("ğŸ§­ Computing path to", goalPos)
                    testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, goalPos)
                    print("      Path status =", testPath.Status)
                    
                    if testPath.Status == Enum.PathStatus.Success then
                        waypoints = testPath:GetWaypoints()
                        humanoid = currentCharacter:WaitForChild("Humanoid")

                        print("ğŸš¶ Moving along", #waypoints, "waypoints...")
                        for idx, wp in ipairs(waypoints) do
                            if stopbreakingplease then
                                humanoid:MoveTo(currentCharacter.HumanoidRootPart.Position)
                                break
                            end
                            humanoid:MoveTo(wp.Position)
                            reached = false
                            start_time = os.clock()
                            conn = humanoid.MoveToFinished:Connect(function(s)
                                reached = s
                                print("    Reached waypoint", idx)
                                conn:Disconnect()
                            end)
                            humanoid:MoveTo(wp.Position)
                            repeat wait(0.01) until reached or (os.clock() - start_time) >= 10
                            if not reached then
                                warn(("ğŸ“ Waypoint %d timed out after 10 secs â€” gen another path"):format(idx))
                                fail_attempt = fail_attempt + 1
                                warn(fail_attempt)
                                if fail_attempt >= 5 then
                                    warn("fail")
                                    fail_attempt = 0
                                    break
                                end
                                testPath:ComputeAsync(currentCharacter.HumanoidRootPart.Position, goalPos)
                                waypoints = testPath:GetWaypoints()
                            end
                        end

                        print("ğŸ› ï¸ Interacting with generator prompt")
                        if not isInGame then
                            warn("???")
                            break
                        end
                        local thing = gen.Main.Prompt
                        if thing then
                            print("Yes!")
                        else
                            print("This gen somehow got no prompt, switchedd")
                            break
                        end
                        thing.HoldDuration = 0
                        thing.RequiresLineOfSight = false
                        thing.MaxActivationDistance = 99999

                        game.Workspace.Camera.CFrame = CFrame.new(201.610779, 64.460968, 1307.98096, 0.99840349, -0.0556023642, 0.00994364079, -1.31681965e-09, 0.176041901, 0.984382629, -0.0564845055, -0.982811034, 0.17576085)
                        wait(0.1)
                        thing:InputHoldBegin()
                        thing:InputHoldEnd()
                        busy = true
                        counter = 0
                        while gen.Progress.Value ~= 100 do
                            thing:InputHoldBegin()
                            thing:InputHoldEnd()
                            gen.Remotes.RE:FireServer()
                            wait(2.5)
                            if counter >= 10 or not isInGame then
                                warn("??")
                                break
                            end
                        end
                        print("âœ… Generator fixed!")
                        busy = false
                        if not isInGame then
                            break
                        end
                    else
                        warn("âŒ Path failed with status", testPath.Status)
                    end
                end
            end
        end
    end
end
wait(0.1)
end
	end)
end

AutomationTab:CreateToggle({
	Name = "Autofarm",
	Description = "AI Powered",
	CurrentValue = false,
	Callback = function(state)
		_G.autoRun = state
		print("Bot Status: ", _G.autoRun and "Running" or "Stopped")
		Luna:Notification({
			Title = "Autofarm Quest",
			Icon = "toggle_on",
			ImageSource = "Material",
			Content = _G.autoRun and "Bot activated. Autofarming started!" or "Bot deactivated. Autofarming stopped."
		})

		if _G.autoRun and not botThread then
			startBot()
		elseif not _G.autoRun and botThread then
			task.cancel(botThread)
			botThread = nil
		end
	end
}, "AutoRunToggle")
-- Killer Tab with Toggles
local KillerTab = Window:CreateTab({
	Name = "Killer",
	Icon = "gavel",
	ImageSource = "Material",
	ShowTitle = true
})

AutomationTab:CreateToggle({
	Name = "Infinite Stamina",
	Description = "Disables stamina loss",
	CurrentValue = false,
	Callback = function(state)
		staminaLossEnabled = state
		if staminaLoopThread then
			task.cancel(staminaLoopThread)
			staminaLoopThread = nil
		end
		staminaLoopThread = task.spawn(function()
			while true do
				require(game.ReplicatedStorage.Systems.Character.Game.Sprinting).StaminaLossDisabled = staminaLossEnabled
				task.wait(0.1)
			end
		end)
	end
})

KillerTab:CreateSection("COMING SOON")

local simulateKnifeThrow = false
local killAuraCon = nil

KillerTab:CreateToggle({
	Name = "Simulate Knife Throw",
	Description = "More legit looking kill, less reliable",
	CurrentValue = false,
	Callback = function(state)
		simulateKnifeThrow = state
		Luna:Notification({
			Title = "Knife Throw",
			Icon = "toggle_on",
			ImageSource = "Material",
			Content = simulateKnifeThrow and "Simulated knife throw enabled." or "Simulated knife throw disabled."
		})
	end
})

KillerTab:CreateButton({
	Name = "Kill Closest",
	Description = "Only works as murderer.",
	Callback = function()
		if findMurderer() ~= localplayer then
			fu.notification("You're not murderer.") return
		end

		if not localplayer.Character:FindFirstChild("Knife") then
			if localplayer.Backpack:FindFirstChild("Knife") then
				localplayer.Character:FindFirstChild("Humanoid"):EquipTool(localplayer.Backpack:FindFirstChild("Knife"))
			else
				fu.notification("You don't have the knife..?")
				return
			end
		end

		local NearestPlayer = findNearestPlayer()
		if not NearestPlayer or not NearestPlayer.Character then
			fu.notification("Can't find a player!?")
			return
		end

		local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not nearestHRP then
			fu.notification("Can't find the player's pivot.")
			return
		end

		if not localplayer.Character:FindFirstChild("HumanoidRootPart") then
			fu.notification("You're not a valid character.")
			return
		end

		if not simulateKnifeThrow then
			nearestHRP.Anchored = true
			nearestHRP.CFrame = localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localplayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
			task.wait(0.1)
			localplayer.Character.Knife.Stab:FireServer("Slash")
		else
			local lpknife = localplayer.Character:FindFirstChild("Knife")
			if not lpknife then return end
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.FilterDescendantsInstances = {localplayer.Character}
			local rayResult = workspace:Raycast(lpknife:GetPivot().Position, (nearestHRP.Position - localplayer.Character:FindFirstChild("HumanoidRootPart").Position).Unit * 350, raycastParams)
			local toThrow = nearestHRP.Position
			local args = {
				lpknife:GetPivot(),
				toThrow
			}
			localplayer.Character.Knife.Throw:FireServer(unpack(args))
		end
	end
})

KillerTab:CreateToggle({
	Name = "Kill Aura",
	Description = "Only works as murderer.",
	CurrentValue = false,
	Callback = function(state)
		if killAuraCon then
			killAuraCon:Disconnect()
			killAuraCon = nil
		end
		if state then
			Luna:Notification({
				Title = "Kill Aura",
				Icon = "toggle_on",
				ImageSource = "Material",
				Content = "Kill aura enabled."
			})
			killAuraCon = game:GetService("RunService").Heartbeat:Connect(function()
				for _, player in ipairs(game.Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player ~= localplayer then
						local hrp = player.Character:FindFirstChild("HumanoidRootPart")
						local myHrp = localplayer.Character and localplayer.Character:FindFirstChild("HumanoidRootPart")
						if myHrp and (hrp.Position - myHrp.Position).Magnitude < 7 then
							hrp.Anchored = true
							hrp.CFrame = myHrp.CFrame + myHrp.CFrame.LookVector * 2
							task.wait(0.1)
							localplayer.Character.Knife.Stab:FireServer("Slash")
						end
					end
				end
			end)
		else
			Luna:Notification({
				Title = "Kill Aura",
				Icon = "toggle_off",
				ImageSource = "Material",
				Content = "Kill aura disabled."
			})
		end
	end
})

local ESPTab = Window:CreateTab({
	Name = "ESP",
	Icon = "visibility",
	ImageSource = "Material",
	ShowTitle = true
})

ESPTab:CreateSection("ESP Toggles")

local espPlayers = false
local espGenerators = false
local espItems = false
local espKiller = false
local espConnections = {}

local function clearESP()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Highlight") and (v.Name == "PlayerESP" or v.Name == "GeneratorESP" or v.Name == "ItemESP" or v.Name == "KillerESP") then
			v:Destroy()
		end
	end
	for _, conn in ipairs(espConnections) do
		if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
	end
	table.clear(espConnections)
end

local function setupESP()
	clearESP()

	if espPlayers then
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player ~= game.Players.LocalPlayer and player.Character then
				local highlight = Instance.new("Highlight")
				highlight.Name = "PlayerESP"
				highlight.Adornee = player.Character
				highlight.FillColor = Color3.fromRGB(0, 255, 0)
				highlight.OutlineTransparency = 1
				highlight.Parent = player.Character
			end
		end
	end

	if espGenerators and workspace:FindFirstChild("Map") then
		for _, gen in ipairs(workspace.Map:GetDescendants()) do
			if gen.Name == "Generator" then
				local highlight = Instance.new("Highlight")
				highlight.Name = "GeneratorESP"
				highlight.Adornee = gen
				highlight.FillColor = Color3.fromRGB(255, 255, 0)
				highlight.OutlineTransparency = 1
				highlight.Parent = gen
			end
		end
	end

	if espItems and workspace:FindFirstChild("Map") then
		for _, item in ipairs(workspace.Map:GetDescendants()) do
			if item:IsA("Tool") or (item:IsA("Model") and item.Name == "Medkit") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "ItemESP"
				highlight.Adornee = item
				highlight.FillColor = Color3.fromRGB(0, 200, 255)
				highlight.OutlineTransparency = 1
				highlight.Parent = item
			end
		end
	end

	if espKiller and workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers") then
		for _, killer in ipairs(workspace.Players.Killers:GetChildren()) do
			if killer:FindFirstChild("HumanoidRootPart") then
				local highlight = Instance.new("Highlight")
				highlight.Name = "KillerESP"
				highlight.Adornee = killer
				highlight.FillColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				highlight.OutlineTransparency = 0
				highlight.FillTransparency = 0.2
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				highlight.Parent = killer
			end
		end
	end
end

ESPTab:CreateToggle({
	Name = "Player ESP",
	Description = "Show highlights on players",
	CurrentValue = false,
	Callback = function(state)
		espPlayers = state
		setupESP()
	end
})

ESPTab:CreateToggle({
	Name = "Generator ESP",
	Description = "Show highlights on generators",
	CurrentValue = false,
	Callback = function(state)
		espGenerators = state
		setupESP()
	end
})

ESPTab:CreateToggle({
	Name = "Item ESP",
	Description = "Show highlights on items",
	CurrentValue = false,
	Callback = function(state)
		espItems = state
		setupESP()
	end
})

ESPTab:CreateToggle({
	Name = "Killer ESP",
	Description = "Show highlight on killer",
	CurrentValue = false,
	Callback = function(state)
		espKiller = state
		setupESP()
	end
})
