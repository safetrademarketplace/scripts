local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local CustomThemes = {
    CerberusDark = {
        TextColor = Color3.fromRGB(230, 230, 255),
        Background = Color3.fromRGB(15, 15, 30),
        Topbar = Color3.fromRGB(20, 20, 35),
        Shadow = Color3.fromRGB(10, 10, 20),
        NotificationBackground = Color3.fromRGB(25, 25, 35),
        NotificationActionsBackground = Color3.fromRGB(40, 40, 50),
        TabBackground = Color3.fromRGB(25, 25, 40),
        TabStroke = Color3.fromRGB(30, 30, 50),
        TabBackgroundSelected = Color3.fromRGB(60, 60, 90),
        TabTextColor = Color3.fromRGB(200, 200, 255),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(20, 20, 35),
        ElementBackgroundHover = Color3.fromRGB(25, 25, 40),
        SecondaryElementBackground = Color3.fromRGB(18, 18, 30),
        ElementStroke = Color3.fromRGB(30, 30, 50),
        SecondaryElementStroke = Color3.fromRGB(25, 25, 45),
        SliderBackground = Color3.fromRGB(80, 120, 255),
        SliderProgress = Color3.fromRGB(100, 140, 255),
        SliderStroke = Color3.fromRGB(120, 160, 255),
        ToggleBackground = Color3.fromRGB(20, 20, 30),
        ToggleEnabled = Color3.fromRGB(80, 120, 255),
        ToggleDisabled = Color3.fromRGB(70, 70, 70),
        ToggleEnabledStroke = Color3.fromRGB(100, 140, 255),
        ToggleDisabledStroke = Color3.fromRGB(90, 90, 90),
        ToggleEnabledOuterStroke = Color3.fromRGB(120, 160, 255),
        ToggleDisabledOuterStroke = Color3.fromRGB(60, 60, 60),
        DropdownSelected = Color3.fromRGB(30, 30, 50),
        DropdownUnselected = Color3.fromRGB(25, 25, 40),
        InputBackground = Color3.fromRGB(22, 22, 35),
        InputStroke = Color3.fromRGB(40, 40, 60),
        PlaceholderColor = Color3.fromRGB(150, 150, 180)
    },

    CerberusWave = {
        TextColor = Color3.fromRGB(230, 255, 255),
        Background = Color3.fromRGB(18, 25, 35),
        Topbar = Color3.fromRGB(25, 35, 45),
        Shadow = Color3.fromRGB(10, 15, 20),
        NotificationBackground = Color3.fromRGB(20, 30, 40),
        NotificationActionsBackground = Color3.fromRGB(40, 60, 70),
        TabBackground = Color3.fromRGB(35, 45, 55),
        TabStroke = Color3.fromRGB(45, 60, 70),
        TabBackgroundSelected = Color3.fromRGB(0, 170, 200),
        TabTextColor = Color3.fromRGB(180, 220, 240),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(30, 40, 50),
        ElementBackgroundHover = Color3.fromRGB(40, 50, 60),
        SecondaryElementBackground = Color3.fromRGB(25, 35, 45),
        ElementStroke = Color3.fromRGB(50, 70, 80),
        SecondaryElementStroke = Color3.fromRGB(40, 60, 70),
        SliderBackground = Color3.fromRGB(0, 140, 180),
        SliderProgress = Color3.fromRGB(0, 180, 220),
        SliderStroke = Color3.fromRGB(0, 210, 255),
        ToggleBackground = Color3.fromRGB(30, 45, 55),
        ToggleEnabled = Color3.fromRGB(0, 180, 255),
        ToggleDisabled = Color3.fromRGB(90, 110, 120),
        ToggleEnabledStroke = Color3.fromRGB(0, 210, 255),
        ToggleDisabledStroke = Color3.fromRGB(110, 130, 140),
        ToggleEnabledOuterStroke = Color3.fromRGB(60, 90, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 70),
        DropdownSelected = Color3.fromRGB(35, 50, 60),
        DropdownUnselected = Color3.fromRGB(30, 40, 50),
        InputBackground = Color3.fromRGB(30, 45, 55),
        InputStroke = Color3.fromRGB(60, 80, 90),
        PlaceholderColor = Color3.fromRGB(160, 180, 200)
    }
}

-- // SERVICES // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

-- // UI Setup // --
local Window = Rayfield:CreateWindow({
    Name = "Volleyball Legends | Cerberus",
    Theme = "Default",
    LoadingTitle = "Loading Volleyball Legends...",
    LoadingSubtitle = "Cerberus | Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Cerberus",
        FileName = "VolleyballConfig"
    }
})

-- // TAB SETUP // --
local MainTab = Window:CreateTab("Main", "home")
local PlayerTab = Window:CreateTab("Player", "circle-user")
local MiscTab = Window:CreateTab("Misc", "menu")

-- // HITBOX EXPANDER // --
MainTab:CreateSection("Hitbox Expander")

local hitboxEnabled    = false
local hitboxSize       = 10
local hitboxCount      = 1       -- ← new
local ghostTransparency= 0.5
_G.GhostBallColor     = Color3.fromRGB(0, 255, 255)

local originalBallData = {}

-- your existing core-finder here (unchanged)...
local function GetModelCenter(model)
    local sum, count = Vector3.new(), 0
    for _, p in ipairs(model:GetChildren()) do
        if p:IsA("BasePart") then
            sum = sum + p.Position
            count = count + 1
        end
    end
    if count > 0 then
        return sum / count
    else
        return (model:GetPrimaryPartCFrame() and model:GetPrimaryPartCFrame().p)
            or model:GetModelCFrame().p
    end
end

local function GetCorePart(model)
    local center = GetModelCenter(model)
    local biggest, maxVol = nil, 0
    for _, part in ipairs(model:GetChildren()) do
        if part:IsA("BasePart")
        and part.Name:lower() ~= "highlight"
        and (part.Position - center).Magnitude <= 5
        then
            local s, vol = part.Size, part.Size.X * part.Size.Y * part.Size.Z
            if vol > maxVol then
                biggest, maxVol = part, vol
            end
        end
    end
    return biggest
end

-- toggles + sliders (with the new Hitbox Count)  
MainTab:CreateToggle({
    Name = "Expand Ball Hitbox",
    Flag = "hitboxToggle",
    CurrentValue = false,
    Callback = function(state) hitboxEnabled = state end
})

MainTab:CreateSlider({
    Name = "Hitbox Size",
    Flag = "hitboxSize",
    Range = {5, 40},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(val) hitboxSize = val end
})

MainTab:CreateSlider({
    Name = "Hitbox Count",
    Flag = "hitboxCount",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = 1,
    Callback = function(val) hitboxCount = val end
})

MainTab:CreateSlider({
    Name = "Ghost Transparency",
    Flag = "ghostTrans",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.5,
    Callback = function(val) ghostTransparency = val end
})

MainTab:CreateColorPicker({
    Name = "Ghost Color",
    Flag = "ghostColor",
    Color = Color3.fromRGB(0, 255, 255),
    Callback = function(color) _G.GhostBallColor = color end
})

MainTab:CreateButton({
    Name = "Reset",
    Flag = "Reset",
    Callback = function()
        for model, original in pairs(originalBallData) do
            if model and model:IsDescendantOf(workspace) then
                local core = GetCorePart(model)
                if core then
                    core.Size        = original.Size
                    core.Color       = original.Color
                    core.Material    = original.Material
                    core.Transparency= original.Transparency
                end
                -- destroy CoreBall + all GhostBall* children
                for _, child in ipairs(model:GetChildren()) do
                    if child.Name == "CoreBall" or child.Name:match("^GhostBall%d+$") then
                        child:Destroy()
                    end
                end
            end
        end
        originalBallData = {}
    end
})

RunService.RenderStepped:Connect(function()
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:upper():find("CLIENT_BALL") then
            local core = GetCorePart(model)
            if core and core:IsA("BasePart") then
                local original = originalBallData[model]
                if hitboxEnabled then
                    -- store original core once
                    if not original then
                        originalBallData[model] = {
                            Size        = core.Size,
                            Color       = core.Color,
                            Material    = core.Material,
                            Transparency= core.Transparency,
                            Textures    = {}
                        }
                        for _, c in ipairs(core:GetChildren()) do
                            if c:IsA("Texture") or c:IsA("Decal")
                            or (c:IsA("SurfaceAppearance") and core:IsA("MeshPart")) then
                                table.insert(originalBallData[model].Textures, c:Clone())
                            end
                        end
                    end

                    -- hide real core
                    core.Transparency = 1
                    core.CanCollide   = false
                    core.Massless     = true

                    -- recreate CoreBall visual
                    local cb = model:FindFirstChild("CoreBall")
                    if not cb then
                        cb = Instance.new("Part")
                        cb.Name         = "CoreBall"
                        cb.Anchored     = true
                        cb.CanCollide   = false
                        cb.Massless     = true
                        cb.Shape        = Enum.PartType.Ball
                        cb.Size        = originalBallData[model].Size
                        cb.Material    = originalBallData[model].Material
                        cb.Color       = originalBallData[model].Color
                        cb.Transparency= 0
                        for _, tex in ipairs(originalBallData[model].Textures) do
                            pcall(function() tex:Clone().Parent = cb end)
                        end
                        cb.Parent = model
                    end
                    cb.CFrame = core.CFrame

                    -- multiple GhostBall layers
                    for i = 1, hitboxCount do
                        local name = "GhostBall"..i
                        local ghost = model:FindFirstChild(name)
                        if not ghost then
                            ghost = Instance.new("Part")
                            ghost.Name       = name
                            ghost.Anchored   = true
                            ghost.CanCollide = false
                            ghost.Massless   = true
                            ghost.Shape      = Enum.PartType.Ball
                            ghost.Material   = Enum.Material.SmoothPlastic
                            ghost.Parent     = model
                        end
                        local size = hitboxSize * i
                        ghost.Size         = Vector3.new(size, size, size)
                        ghost.CFrame       = core.CFrame
                        ghost.Color        = _G.GhostBallColor
                        ghost.Transparency = (ghostTransparency >= 1 and 0.95) or ghostTransparency
                    end

                else
                    -- reset single core & destroy visuals
                    if original then
                        core.Size        = original.Size
                        core.Color       = original.Color
                        core.Material    = original.Material
                        core.Transparency= original.Transparency
                    end
                    for _, child in ipairs(model:GetChildren()) do
                        if child.Name == "CoreBall" or child.Name:match("^GhostBall%d+$") then
                            child:Destroy()
                        end
                    end
                    originalBallData[model] = nil
                end
            end
        end
    end
end)

MainTab:CreateSection("Visual")

-- // BALL PATH PREDICTION // --
local ballPathEnabled = false

MainTab:CreateToggle({
	Flag = "ballPath",
	Name = "Ball Path Predictor [BETA]",
	CurrentValue = false,
	Callback = function(state)
		ballPathEnabled = state
	end
})

local PREDICT_DURATION = 1.5
local STEP_TIME = 0.05
local GRAVITY = workspace.Gravity
local MAX_DISTANCE = 15

local beamModel = Instance.new("Model", workspace)
beamModel.Name = "BallPathBeam"

local a1 = Instance.new("Attachment")
local a2 = Instance.new("Attachment")

local part1 = Instance.new("Part")
part1.Anchored = true
part1.CanCollide = false
part1.Transparency = 1
part1.Size = Vector3.new(0.1, 0.1, 0.1)
a1.Parent = part1
part1.Parent = beamModel

local part2 = part1:Clone()
a2 = part2:FindFirstChildOfClass("Attachment")
part2.Parent = beamModel

local beam = Instance.new("Beam")
beam.Attachment0 = a1
beam.Attachment1 = a2
beam.Width0 = 0.15
beam.Width1 = 0.15
beam.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))
}
beam.Transparency = NumberSequence.new(0.1)
beam.CurveSize0 = 4
beam.CurveSize1 = 4
beam.FaceCamera = true
beam.Segments = 32
beam.LightEmission = 1
beam.Parent = part1

local lastBall = nil
local lastPos = nil
local lastVel = Vector3.zero

RunService.RenderStepped:Connect(function()
	if not ballPathEnabled then
		beam.Enabled = false
		return
	end

	local ball, core = nil, nil
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name:upper():find("BALL") then
			local candidate = obj:FindFirstChild("Cube.001")
			if candidate and candidate:IsA("BasePart") then
				ball = obj
				core = candidate
				break
			end
		end
	end

	if not core then
		beam.Enabled = false
		return
	end

	local pos = core.Position
	if not lastPos then
		lastPos = pos
		return
	end

	local vel = (pos - lastPos) / RunService.RenderStepped:Wait()
	lastPos = pos

	if vel.Magnitude < 0.1 then
		beam.Enabled = false
		return
	end

	local simulated = pos
	local totalTime = 0
	while totalTime < PREDICT_DURATION do
		simulated = simulated + vel * STEP_TIME + 0.5 * Vector3.new(0, -GRAVITY, 0) * STEP_TIME ^ 2
		vel = vel + Vector3.new(0, -GRAVITY, 0) * STEP_TIME
		totalTime += STEP_TIME
		if (simulated - pos).Magnitude >= MAX_DISTANCE then break end
	end

	part1.Position = pos
	part2.Position = simulated
	beam.Enabled = true
end)

-- // LOS BEAMS // --
local losEnabled = false
local losThickness = 0.5

MainTab:CreateToggle({
	Name = "LOS Visualiser",
	Flag = "LOS",
	CurrentValue = false,
	Callback = function(state)
		losEnabled = state
	end
})

MainTab:CreateSlider({
	Name = "Beam Thickness",
	Flag = "beamThickness",
	Range = {0.2, 0.8},
	Increment = 0.01,
	CurrentValue = 0.5,
	Callback = function(val)
		losThickness = val
	end
})

local LOSBeams = {}

local function getColorFromUser(user)
	local userId = user.UserId
	local hue = (userId % 360) / 360
	return Color3.fromHSV(hue, 1, 1)
end

RunService.RenderStepped:Connect(function()
	for _, beam in pairs(LOSBeams) do
		beam:Destroy()
	end
	LOSBeams = {}

	if not losEnabled then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer then
			local character = player.Character
			local head = character and character:FindFirstChild("Head")
			local humanoidRoot = character and character:FindFirstChild("HumanoidRootPart")
			if head and humanoidRoot then
				local origin = head.Position
				local direction = humanoidRoot.CFrame.LookVector * 1000 -- Adjust range if needed

				local result = workspace:Raycast(origin, direction)

				local attachment0 = Instance.new("Attachment", workspace.Terrain)
				attachment0.WorldPosition = origin

				local attachment1 = Instance.new("Attachment", workspace.Terrain)
				attachment1.WorldPosition = result and result.Position or (origin + direction)

				local beam = Instance.new("Beam")
				beam.Attachment0 = attachment0
				beam.Attachment1 = attachment1
				beam.FaceCamera = true
				beam.Width0 = losThickness
				beam.Width1 = losThickness
				beam.LightEmission = 1
				beam.LightInfluence = 0
				beam.Color = ColorSequence.new(getColorFromUser(player))
				beam.Parent = workspace.Terrain

				table.insert(LOSBeams, beam)
				table.insert(LOSBeams, attachment0)
				table.insert(LOSBeams, attachment1)
			end
		end
	end
end)


MainTab:CreateSection("Other")

-- // PERFECT SERVE // --
local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")

local BallServiceRF = KnitServices:WaitForChild("BallService"):WaitForChild("RF")
local GameServiceRF = KnitServices:WaitForChild("GameService"):WaitForChild("RF")
local autoServeEnabled = false

local serveArgs = {
	Vector3.new(0.000005638277343678055, 0, 0.00005710769255529158),
	1
}
local spawnBallArgs = {
	Vector3.new(0.000005638277343678055, 0, 0.00005710769255529158)
}

local function runAutoServe()
	task.delay(1, function()
		if not autoServeEnabled then return end
		GameServiceRF:WaitForChild("Serve"):InvokeServer(unpack(serveArgs))
		task.wait(0.05)
		BallServiceRF:WaitForChild("SpawnBall"):InvokeServer(unpack(spawnBallArgs))
	end)
end

if not getgenv()._AutoServeHooked then
	getgenv()._AutoServeHooked = true
	local mt = getrawmetatable(game)
	local oldNamecall = mt.__namecall
	setreadonly(mt, false)
	mt.__namecall = function(self, ...)
		local method = getnamecallmethod()
		if method == "InvokeServer" and typeof(self) == "Instance" and self.Name == "SpawnServeBall" then
			if autoServeEnabled then
				task.spawn(runAutoServe)
			end
		end
		return oldNamecall(self, ...)
	end
	setreadonly(mt, true)
end

MainTab:CreateKeybind({
	Name = "Perfect Serve",
	Flag = "perfectServe",
	CurrentKeybind = "C", 
	HoldToInteract = false,
	Callback = function()
		autoServeEnabled = not autoServeEnabled
		if autoServeEnabled then
			runAutoServe()
		end
	end
})

-- // AUTO M1 // --
local autoM1Enabled = false
local clickRange = 10 
local lastClickedTime = 0

MainTab:CreateToggle({
    Name = "Auto Hit",
	Flag = "autoHit",
    CurrentValue = false,
    Callback = function(state)
        autoM1Enabled = state
    end
})

MainTab:CreateSlider({
    Name = "Auto Hit Range",
	Flag = "autoHitRange",
    Range = {2, 40},
    Increment = 1,
    CurrentValue = clickRange,
    Callback = function(val)
        clickRange = val
    end
})

local function pressM1()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

RunService.Heartbeat:Connect(function()
    if not autoM1Enabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetBall, closestDist = nil, math.huge

    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name:upper():find("BALL") then
            local core = model:FindFirstChild("Cube.001")
            if core and core:IsA("BasePart") then
                local dist = (core.Position - hrp.Position).Magnitude
                if dist < closestDist then
                    targetBall = core
                    closestDist = dist
                end
            end
        end
    end

    if targetBall and closestDist <= clickRange then
        pressM1()
    end
end)

local autoFarmEnabled = false
local autoServeEnabled = false
local pauseUntil = 0
local nextPauseTime = tick() + math.random(18, 40)
local lastPathTime = 0
local idleCooldown = 0
local idleOrigin = nil
local freezeUntil = 0
local lastBallPosition = nil

MainTab:CreateToggle({
	Name = "AutoFarm [BETA]",
	Flag = "autoFarm",
	CurrentValue = false,
	Callback = function(state)
		autoFarmEnabled = state
		autoServeEnabled = state
	end
})

local function pressSpaceOnce()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
	task.wait(0.05)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

local function moveTo(targetPos, humanoid)
	if tick() - lastPathTime < 0.25 then return end
	lastPathTime = tick()

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = true,
		WaypointSpacing = 2
	})

	local success, err = pcall(function()
		path:ComputeAsync(LocalPlayer.Character.HumanoidRootPart.Position, targetPos)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		for _, waypoint in ipairs(path:GetWaypoints()) do
			humanoid:MoveTo(waypoint.Position)
			humanoid.MoveToFinished:Wait()
		end
	else
		humanoid:MoveTo(targetPos)
	end
end

local function idleWander(humanoid, hrp, targetPos)
	if tick() < idleCooldown then return end
	idleCooldown = tick() + math.random(0.8, 1.5)
	if not idleOrigin then
		idleOrigin = hrp.Position
	end

	local directionToTarget = targetPos - hrp.Position
	local directionUnit = directionToTarget.Unit
	local distanceToTarget = directionToTarget.Magnitude

	if distanceToTarget > 5 then
		local offset = directionUnit * math.random(5, 15)
		local target = hrp.Position + offset
		if (target - idleOrigin).Magnitude <= 15 then
			moveTo(target, humanoid)
		end
	else
		if math.random() < 0.2 then
			pressSpaceOnce()
		end
	end
end

RunService.Heartbeat:Connect(function()
	if not autoFarmEnabled then return end
	if tick() < pauseUntil then return end
	if tick() < freezeUntil then return end

	local character = LocalPlayer.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChild("Humanoid")
	if not hrp or not humanoid then return end

	if tick() >= nextPauseTime then
		local pauseDuration = math.random(0.2, 2)
		pauseUntil = tick() + pauseDuration
		nextPauseTime = tick() + math.random(18, 40)
		return
	end

	local targetBall, closestDist = nil, math.huge
	local anyBallsExist = false
	local targetPlayerPosition = nil

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model.Name:upper():find("BALL") then
			local core = model:FindFirstChild("Cube.001")
			if core and core:IsA("BasePart") then
				local dist = (core.Position - hrp.Position).Magnitude
				if dist < closestDist and dist <= 45 then
					targetBall = core
					closestDist = dist
					lastBallPosition = core.Position
				end
			end
		end
	end

	if not targetBall then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local playerHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if playerHRP then
					local dist = (playerHRP.Position - hrp.Position).Magnitude
					if dist < closestDist and dist <= 45 then
						targetPlayerPosition = playerHRP.Position
						closestDist = dist
					end
				end
			end
		end
	end

	if not targetBall and not targetPlayerPosition then return end
	if targetBall then
		if closestDist > 2 then
			moveTo(targetBall.Position, humanoid)
		end

		local verticalOffset = targetBall.Position.Y - hrp.Position.Y
		if humanoid:GetState() == Enum.HumanoidStateType.Running and verticalOffset > 5 and closestDist < 10 then
			pressSpaceOnce()
		end

		if closestDist < 5 then
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
			task.wait(0.01)
			VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
		end
	else
		local targetPos = targetPlayerPosition or lastBallPosition
		idleWander(humanoid, hrp, targetPos)
	end
end)

local KnitServices = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index")
	:WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services")

local BallServiceRF = KnitServices:WaitForChild("BallService"):WaitForChild("RF")

if not getgenv()._AutoServeHooked then
	getgenv()._AutoServeHooked = true

	local mt = getrawmetatable(game)
	local oldNamecall = mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = function(self, ...)
		local method = getnamecallmethod()
		if method == "InvokeServer" and typeof(self) == "Instance" and self.Name == "SpawnServeBall" then
			if autoFarmEnabled then
				freezeUntil = tick() + 1.5
				warn("[AutoFarm] Frozen for 1.5s after Perfect Serve")
			end
		end
		return oldNamecall(self, ...)
	end

	setreadonly(mt, true)
end


-- // INSTA SPIN // --
MainTab:CreateButton({
    Name = "Insta Spin",
	Flag = "instaSpin",
    Callback = function()
        local args = {
            [1] = false
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit"):WaitForChild("Services"):WaitForChild("AbilityService"):WaitForChild("RF"):WaitForChild("Roll"):InvokeServer(unpack(args))
    end
})

PlayerTab:CreateSection("Speed")

-- // WALKSPEED // --
local walkSpeedEnabled = false
local walkSpeedValue = 16

PlayerTab:CreateToggle({
	Name = "Enable WalkSpeed",
	Flag = "walkspeedToggle",
	CurrentValue = false,
	Callback = function(state)
		walkSpeedEnabled = state
		if not state then
			LocalPlayer.Character.Humanoid.WalkSpeed = 16
		end
	end
})

PlayerTab:CreateKeybind({
	Name = "Toggle WalkSpeed",
	Flag = "walkspeedBind",
	CurrentKeybind = "F",
	HoldToInteract = false,
	Callback = function()
		walkSpeedEnabled = not walkSpeedEnabled
		if not walkSpeedEnabled then
			LocalPlayer.Character.Humanoid.WalkSpeed = 16
		end
	end
})

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Flag = "Speed",
	Range = {16, 100},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(val)
		walkSpeedValue = val
	end
})


RunService.RenderStepped:Connect(function()
	if walkSpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeedValue
	end
end)

PlayerTab:CreateSection("Jump")

-- // JUMP // --
local jumpEnabled = false
local jumpPower = 35
local infiniteJumpEnabled = false
local customGravityEnabled = false
local customGravity = 196.2 -- Default gravity (Roblox's default gravity)

PlayerTab:CreateToggle({
    Name = "Enable Jump Height",
	Flag = "enableJumpHeight",
    CurrentValue = false,
    Callback = function(state)
        jumpEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = false
        end
    end
})

PlayerTab:CreateKeybind({
    Name = "Jump Height Bind",
	Flag = "jumpBind",
    CurrentKeybind = "J",
    HoldToInteract = false,
    Callback = function()
        jumpEnabled = not jumpEnabled
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Height",
	Flag = "jumpHeight",
	CurrentKeybind = "J",
    Range = {30, 40},
    Increment = 0.1,
    CurrentValue = 35,
    Callback = function(val)
        jumpPower = val
    end
})

-- // INFINITE JUMP // --
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
	Flag = "infJump",
    CurrentValue = false,
    Callback = function(state)
        infiniteJumpEnabled = state
    end
})

-- // CUSTOM GRAVITY // --
PlayerTab:CreateToggle({
    Name = "Enable Custom Gravity",
	Flag = "customGravToggle",
    CurrentValue = false,
    Callback = function(state)
        customGravityEnabled = state
        if state then
            -- Enable custom gravity by adjusting Workspace.Gravity
            Workspace.Gravity = customGravity
        else
            -- Reset to default gravity
            Workspace.Gravity = 43
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Custom Gravity",
	Flag = "gravitySlider",
    Range = {30, 100},
    Increment = 1,
    CurrentValue = 43,
    Callback = function(val)
        customGravity = val
        if customGravityEnabled then
            Workspace.Gravity = customGravity
        end
    end
})

RunService.RenderStepped:Connect(function()
    if jumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpPower
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= Enum.KeyCode.Space then return end

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not humanoid then return end

    local state = humanoid:GetState()

    if infiniteJumpEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpPower
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    elseif jumpEnabled then
        if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = jumpPower
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

MiscTab:CreateSection("Themes")

-- // AMBIENT // --
MiscTab:CreateSection("Theme")
local ambientEnabled = false
local customAmbientColor = Color3.fromRGB(128, 128, 128)
local originalAmbient = Lighting.Ambient

local function updateAmbient()
	if ambientEnabled then
		Lighting.Ambient = customAmbientColor
	else
		Lighting.Ambient = originalAmbient
	end
end

MiscTab:CreateToggle({
	Name = "Custom Ambient",
    Flag = "Ambient",
	CurrentValue = false,
	Callback = function(state)
		ambientEnabled = state
		updateAmbient()
	end
})

MiscTab:CreateColorPicker({
	Name = "Ambient Color",
    Flag = "ambientColor",
	Color = customAmbientColor,
	Callback = function(newColor)
		customAmbientColor = newColor
		if ambientEnabled then updateAmbient() end
	end
})

-- THEME DROPDOWN --
MiscTab:CreateDropdown({
    Name = "Current Theme",
    Options = {
        "CerberusDark", "CerberusWave", "Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue",
        "Green", "Light", "Ocean", "Serenity"
    },
    CurrentOption = {"Default"},
    MultipleOptions = false,
    Flag = "CurrentTheme",
    Callback = function(Options)
        local theme = Options[1]
        if CustomThemes[theme] then
            Window.ModifyTheme(CustomThemes[theme])
        else
            Window.ModifyTheme(theme)
        end
    end,
})

MiscTab:CreateSection("Misc Utils")

-- Performance Mode Toggle
local PerformanceToggle = MiscTab:CreateToggle({
    Name = "Performance Mode",
    CurrentValue = false,
    Flag = "PerformanceToggle",
    Callback = function(state)
        perfModeEnabled = state
        if state then
            -- Disable particle effects and reduce part quality
            _G._DisabledEffects = {}
            _G._ChangedParts = {}
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                    if obj.Enabled then 
                        obj.Enabled = false 
                        table.insert(_G._DisabledEffects, obj)
                    end
                elseif obj:IsA("Light") then
                    if obj.Enabled then 
                        obj.Enabled = false
                        table.insert(_G._DisabledEffects, obj)
                    end
                elseif obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                    local originalMat = obj.Material
                    local originalCastShadow = obj.CastShadow
                    if originalMat ~= Enum.Material.Plastic or originalCastShadow ~= false then
                        _G._ChangedParts[obj] = {Material = originalMat, CastShadow = originalCastShadow}
                        obj.Material = Enum.Material.Plastic
                        obj.CastShadow = false
                    end
                end
            end
        else
            if _G._DisabledEffects then
                for _, effect in ipairs(_G._DisabledEffects) do
                    if effect and effect.Parent then
                        effect.Enabled = true
                    end
                end
                _G._DisabledEffects = {}
            end
            if _G._ChangedParts then
                for part, origProps in pairs(_G._ChangedParts) do
                    if part and part.Parent then
                        if origProps.Material then
                            part.Material = origProps.Material
                        end
                        if origProps.CastShadow ~= nil then
                            part.CastShadow = origProps.CastShadow
                        end
                    end
                end
                _G._ChangedParts = {}
            end
        end
    end
})

MiscTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        local char = game.Players.LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0  
            else
                char:BreakJoints()  
            end
        end
    end
})

-- // SERVER HOP // --
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false

local File = pcall(function()
    AllIDs = game:GetService('HttpService'):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
    table.insert(AllIDs, actualHour)
    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
end

function TPReturner()
    local Site
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end

    local num = 0
    for i, v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)

        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(4)
            end
        end
    end
end

function Teleport()
    while wait() do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end

MiscTab:CreateButton({
    Name = "Hop to Random Server",
    Callback = function()
        Teleport()
    end
})


Rayfield:LoadConfiguration()
