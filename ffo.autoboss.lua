-- // UI SETUP AND THEMES // --
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

-- // UI Setup // --
local Window = Rayfield:CreateWindow({
    Name = "Fire Force AutoBoss | Cerberus",
    Theme = "Default",
    LoadingTitle = "Loading Fire Force AutoBoss...",
    LoadingSubtitle = "Cerberus | Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Cerberus",
        FileName = "FireForce"
    }
})

-- // Tabs // --
local MainTab = Window:CreateTab("Main", "home")
local PlayerTab = Window:CreateTab("Player", "circle-user")
local AutoTab = Window:CreateTab("Auto", "bot")

-- // Services // --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualInputManager  = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- // References // --
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local Drawing            = Drawing
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local viewport = camera and camera.ViewportSize or Vector2.new(0, 0)

-- // WEBHOOK SENDER // --
local function sendToWebhook(webhookUrl, messageContent)
    local payload = {
        ["content"] = messageContent,
        ["username"] = "Cerberus Logger",
        ["avatar_url"] = "https://media.discordapp.net/attachments/936776180026204241/1351880348728037517/Nox_hub_banner.png?ex=6814acaf&is=68135b2f&hm=6e7ff57031a094a0b58d38fe0857845b66af92f2a904f482efbb78054e9343ac&=&format=webp&quality=lossless&width=2638&height=1484"
    }

    local success, response = pcall(function()
        return syn and syn.request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        }) or http_request and http_request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        }) or request and request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)

    return success, response
end

-- // TWEENING HELPER FUNCTION // --
local speed = 300
local offsetY = 8
local flyingEnabled = false
local targetPosition = nil
local arrivalTargetPosition = nil
local activeConnection = nil

-- RESPAWN PROTECTION
local function refreshCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

local function disableCollisions(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

local function enableCollisions(model)
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = true end
    end
end

local function stopCurrentMovement()
    if activeConnection then activeConnection:Disconnect() activeConnection = nil end
    if humanoidRootPart then
        humanoidRootPart.Anchored = false
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.RotVelocity = Vector3.zero
    end
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.1)
        humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    if character then
        enableCollisions(character)
    end
end

local function startFlight(hover)
    if activeConnection then activeConnection:Disconnect() end

    humanoid.PlatformStand = true
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    activeConnection = RunService.Heartbeat:Connect(function(dt)
        if not humanoidRootPart or not humanoid then
            stopCurrentMovement()
            refreshCharacter()
            return
        end
        if not flyingEnabled or not targetPosition then
            stopCurrentMovement()
            return
        end

        disableCollisions(character)

        local adjustedTarget = hover
            and Vector3.new(targetPosition.X, targetPosition.Y + offsetY, targetPosition.Z)
            or targetPosition

        local direction = (adjustedTarget - humanoidRootPart.Position)
        local distance = direction.Magnitude

        if arrivalTargetPosition and (humanoidRootPart.Position - arrivalTargetPosition).Magnitude <= 2 then
            flyingEnabled = hover
            if not hover then
                stopCurrentMovement()
            end
            arrivalTargetPosition = nil
            return
        end

        if distance < 2 then
            humanoidRootPart.Velocity = Vector3.zero
            humanoidRootPart.RotVelocity = Vector3.zero
            return
        end

        local moveVector = direction.Unit * math.min(speed, distance / dt) * dt
        humanoidRootPart.CFrame = CFrame.new(humanoidRootPart.Position + moveVector) * humanoidRootPart.CFrame.Rotation
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.RotVelocity = Vector3.zero
    end)
end

local function setFlightTarget(pos, flightSpeed, hover, offset)
    speed = flightSpeed or 300
    offsetY = offset or 8
    targetPosition = pos
    arrivalTargetPosition = pos
    flyingEnabled = true
    startFlight(hover)
end

-- ############## --
-- // MAIN TAB // --
-- ############## --

MainTab:CreateSection("Webhook")
local userWebhook = ""

MainTab:CreateInput({
    Name = "Input Discord Webhook",
    Flag = "Webhook",
    PlaceholderText = "Paste full webhook URL here...",
    RemoveTextAfterFocusLost = false,
    Callback = function(input)
        userWebhook = input
    end
})

local function getBackpackItems()
    local tools = {}
    for _, item in ipairs(player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, item.Name)
        end
    end
    return #tools > 0 and table.concat(tools, ", ") or "No tools"
end

-- Get money stat
local function getMoney()
    local stats = player:FindFirstChild("Stats")
    local money = stats and stats:FindFirstChild("Money")
    return money and tostring(money.Value) or "N/A"
end

-- Get dungeon coin label
local function getDungeonCoins()
    local gui = player:FindFirstChild("PlayerGui")
    local label = gui
        and gui:FindFirstChild("BackpackGUI")
        and gui.BackpackGUI:FindFirstChild("EscPack")
        and gui.BackpackGUI.EscPack:FindFirstChild("Dungeon Coins")
        and gui.BackpackGUI.EscPack["Dungeon Coins"]:FindFirstChild("Stack")
    return label and label.Text or "N/A"
end

-- // CONSTANTS // --
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

local KILL_RANGE = 200
local MIN_HEALTH_PERCENT = 90
local VOID_Y = -1000
local LOOP_DELAY = 0.1
local BURST_DURATION = 1
local BURST_GAP = 2

-- // VARIABLES // --
local char = player.Character or player.CharacterAdded:Wait()
local rootPart = char:WaitForChild("HumanoidRootPart")
local killing = false
local killThread

-- // FUNCTIONS // --

local function getClosestEnemy()
	local best, bestDistSq = nil, KILL_RANGE * KILL_RANGE
	for _, mdl in ipairs(workspace:GetDescendants()) do
		if mdl:IsA("Model") and not Players:GetPlayerFromCharacter(mdl) then
			local hum = mdl:FindFirstChildOfClass("Humanoid")
			local hrp = mdl.PrimaryPart or mdl:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and hrp then
				local healthPct = (hum.Health / hum.MaxHealth) * 100
				if healthPct <= MIN_HEALTH_PERCENT then
					local distSq = (hrp.Position - rootPart.Position).Magnitude^2
					if distSq < bestDistSq then
						best, bestDistSq = mdl, distSq
					end
				end
			end
		end
	end
	return best
end

-- Claims network ownership of all parts in a model
local function claimOwnership(model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part:SetNetworkOwner(player)
			end)
		end
	end
end

-- Instantly kills the target by setting health to 0
local function voidAndKill(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		pcall(function()
			hum.Health = 0
		end)
	end
end

-- Core killing loop with burst and cooldown
local function killLoop()
	while killing do
		local burstStart = tick()
		while killing and (tick() - burstStart < BURST_DURATION) do
			local enemy = getClosestEnemy()
			if enemy then
				claimOwnership(enemy)
				voidAndKill(enemy)
			end
			task.wait(LOOP_DELAY)
		end
		local cooldownStart = tick()
		while killing and (tick() - cooldownStart < BURST_GAP) do
			task.wait()
		end
	end
end

-- Starts the instakill loop
local function startKill()
	if killing then return end
	killing = true
	pcall(function()
		sethiddenproperty(player, "SimulationRadius", math.huge)
		sethiddenproperty(player, "MaxSimulationRadius", math.huge)
	end)
	killThread = task.spawn(killLoop)
end

-- Stops the instakill loop
local function stopKill()
	killing = false
	killThread = nil
end

-- // UI & HOOKS (External Executor Integration) // --
MainTab:CreateSection("InstaKill")

MainTab:CreateToggle({
	Name = "Enable Instakill",
	Flag = "EnableInstakill",
	CurrentValue = false,
	Callback = function(state)
		if state then
			startKill()
		else
			stopKill()
		end
	end,
})

MainTab:CreateSlider({
	Name = "Range",
	Range = {10, 400},
	Increment = 1,
	CurrentValue = KILL_RANGE,
	Flag = "KillRange",
	Callback = function(val)
		KILL_RANGE = val
	end,
})

MainTab:CreateSlider({
	Name = "Health Threshold (%)",
	Range = {1, 100},
	Increment = 1,
	CurrentValue = MIN_HEALTH_PERCENT,
	Flag = "KillHealthThreshold",
	Callback = function(val)
		MIN_HEALTH_PERCENT = val
	end,
})

-- // AUTO CLICK CHESTS // --
local liveChests = workspace:WaitForChild("LiveChests")
local clicking = false
local chestThread

local function fireAllClicks()
	for _, obj in ipairs(liveChests:GetDescendants()) do
		if obj:IsA("ClickDetector") then
			pcall(function()
				fireclickdetector(obj)
			end)
		end
	end
end

local function clickLoop()
	while clicking do
		fireAllClicks()
		task.wait(1)
	end
end

MainTab:CreateToggle({
	Name = "Auto Click Chests",
	Flag = "AutoClickChests",
	CurrentValue = false,
	Callback = function(state)
		clicking = state
		if state then
			chestThread = task.spawn(clickLoop)
		else
			clicking = false
			chestThread = nil
		end
	end,
})
-- // AUTO ATTACK MODULE // --

MainTab:CreateSection("Kill Aura")

local HRP = character:WaitForChild("HumanoidRootPart")

local WeaponInfo = character:WaitForChild("FistCombat"):WaitForChild("WeaponInfoFolder"):WaitForChild("Fist")
local CombatEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CombatEvent")
local killauraEnabled = false
local enableKillAuraToggle

local function startKillAura()
    local cycle = 1
    while killauraEnabled do
        CombatEvent:FireServer(cycle, WeaponInfo, CFrame.new(HRP.Position), true, WeaponInfo)
        cycle += 1
        if cycle > 3 then cycle = 1 end
        task.wait(0.1)
    end
end

enableKillAuraToggle = MainTab:CreateToggle({
    Name = "Kill Aura V2",
    Flag = "KillAuraV2",
    CurrentValue = false,
    Callback = function(state)
        killauraEnabled = state
        if killauraEnabled then
            startKillAura()
        end
    end,
})

MainTab:CreateKeybind({
    Name = "Toggle Kill Aura V2",
    Flag = "KillAuraHotkey",
    CurrentKeybind = "P",
    HoldToInteract = false,
    Callback = function()
        local newState = not killauraEnabled
        enableKillAuraToggle:Set(newState)
    end,
})

-- ################ --
-- // PLAYER TAB // --
-- ################ --

-- // FLIGHT // --
local flying = false
local flySpeed = 100
local flyKeyDown = {}
local lastY
local flightToggle

local function getHRP()
    character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end
local function getMobileMoveVector()
    if humanoid and UserInputService.TouchEnabled then
        local dir = humanoid.MoveDirection
        if dir.Magnitude > 0 then
            local cf = camera.CFrame
            local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
            local right = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
            return (forward * dir.Z + right * dir.X).Unit
        end
    end
    return Vector3.zero
end

PlayerTab:CreateSection("Movement")

flightToggle = PlayerTab:CreateToggle({
    Name = "Flight",
    Flag = "Flight",
    CurrentValue = false,
    Callback = function(state)
        flying = state
        local hrp = getHRP()
        if state and hrp then
            lastY = hrp.Position.Y
        end
    end
})

PlayerTab:CreateKeybind({
    Name = "Toggle Flight",
    Flag = "flightBind",
    CurrentKeybind = "G",
    HoldToInteract = false,
    Callback = function()
        if flightToggle and flightToggle.Set then
            flightToggle:Set(not flying)
        end
    end
})

PlayerTab:CreateSlider({
    Name = "Flight Speed",
    Flag = "flightSpeed",
    Range = {10, 300},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(val)
        flySpeed = val
    end
})

-- FLIGHT LOGIC MOBILE AND PC
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = false
    end
end)

RunService.RenderStepped:Connect(function()
    if not flying then return end
    local hrp = getHRP()
    if not hrp then return end
    local moveDir = Vector3.zero
    local camCF = camera.CFrame
    if not UserInputService.TouchEnabled then
        if flyKeyDown[Enum.KeyCode.W] then moveDir += camCF.LookVector end
        if flyKeyDown[Enum.KeyCode.S] then moveDir -= camCF.LookVector end
        if flyKeyDown[Enum.KeyCode.A] then moveDir -= camCF.RightVector end
        if flyKeyDown[Enum.KeyCode.D] then moveDir += camCF.RightVector end
    else
        moveDir += getMobileMoveVector()
    end
    if flyKeyDown[Enum.KeyCode.Space] then moveDir += Vector3.yAxis end
    if flyKeyDown[Enum.KeyCode.LeftShift] then moveDir -= Vector3.yAxis end
    local velocity
    if moveDir.Magnitude > 0 then
        velocity = moveDir.Unit * flySpeed
        lastY = hrp.Position.Y
    else
        local yOffset = (lastY and (lastY - hrp.Position.Y)) or 0
        velocity = Vector3.new(0, yOffset * 5, 0)
    end
    hrp.Velocity = velocity
end)

-- RESPAWN PROTECTION
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
    if flying then
        lastY = humanoidRootPart.Position.Y
    end
end)

PlayerTab:CreateSection("Utils")

-- // PERFORMANCE MODES // --
local function applyPerformanceMode()
    _G._DisabledEffects = {}
    _G._ChangedParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                if obj.Enabled ~= false then
                    obj.Enabled = false
                    table.insert(_G._DisabledEffects, obj)
                end
            elseif obj:IsA("Light") then
                if obj.Enabled ~= false then
                    obj.Enabled = false
                    table.insert(_G._DisabledEffects, obj)
                end
            elseif obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
                _G._ChangedParts[obj] = {
                    Material = obj.Material,
                    CastShadow = obj.CastShadow
                }
                obj.Material = Enum.Material.Plastic
                obj.CastShadow = false
            end
        end)
    end
end

local function restorePerformanceChanges()
    if _G._DisabledEffects then
        for _, obj in ipairs(_G._DisabledEffects) do
            pcall(function()
                if obj and obj.Parent then obj.Enabled = true end
            end)
        end
        _G._DisabledEffects = {}
    end
    if _G._ChangedParts then
        for obj, props in pairs(_G._ChangedParts) do
            pcall(function()
                if obj and obj.Parent then
                    obj.Material = props.Material or Enum.Material.Plastic
                    obj.CastShadow = props.CastShadow or true
                    if props.Transparency then obj.Transparency = props.Transparency end
                    if props.Anchored ~= nil then obj.Anchored = props.Anchored end
                end
            end)
        end
        _G._ChangedParts = {}
    end
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.FogEnd = 1000
        Lighting.Brightness = 2
    end)
    if Terrain then
        pcall(function()
            Terrain.WaterTransparency = 0.5
            Terrain.WaterWaveSize = 0.2
            Terrain.WaterWaveSpeed = 10
            Terrain.WaterReflectance = 0.05
            Terrain.Decorations = true
        end)
    end
end

PlayerTab:CreateToggle({
    Name = "Performance Mode",
    Flag = "PerformanceMode",
    CurrentValue = false,
    Callback = function(state)
        if state then
            applyPerformanceMode()
        else
            restorePerformanceChanges()
        end
    end
})


-- // ANTI AFK // --
local antiAfkConnection = nil

PlayerTab:CreateToggle({
    Name = "Anti-AFK",
    Flag = "AntiAFK",
    CurrentValue = false,
    Callback = function(enabled)
        if enabled then
            antiAfkConnection = player.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end
})

-- // NO CLIP // --
local noclipConn = nil
local noclipEnabled = false

local function setCharacterCollision(enabled)
	local char = player.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = enabled
			end
		end
	end
end

player.CharacterAdded:Connect(function()
	if noclipEnabled then
		task.wait(0.5)
		setCharacterCollision(false)
	end
end)

PlayerTab:CreateToggle({
	Name = "No Clip",
	Flag = "noClip",
	CurrentValue = false,
	Callback = function(state)
		noclipEnabled = state

		if state then
			setCharacterCollision(false)

			if not noclipConn then
				noclipConn = RunService.Stepped:Connect(function()
					local char = player.Character
					if char then
						for _, part in ipairs(char:GetDescendants()) do
							if part:IsA("BasePart") and part.CanCollide then
								part.CanCollide = false
							end
						end
					end
				end)
			end
		else
			if noclipConn then
				noclipConn:Disconnect()
				noclipConn = nil
			end
			setCharacterCollision(true)
		end
	end
})

PlayerTab:CreateSlider({
    Name = "FOV",
    Range = {50, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = game:GetService("Workspace").CurrentCamera.FieldOfView,
    Callback = function(value)
        game:GetService("Workspace").CurrentCamera.FieldOfView = value
    end,
})

PlayerTab:CreateButton({
    Name = "Reset",
    Callback = function()
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
})

PlayerTab:CreateButton({
    Name = "Ragdoll",
    Callback = function()
        local evt = game:GetService("ReplicatedStorage")
            :WaitForChild("Events")
            :WaitForChild("Ragdoll")
        local args = { "" }
        evt:FireServer(unpack(args))
    end,
})

-- ################ --
-- // AUTO TAB // --
-- ################ --

AutoTab:CreateSection("AutoFarm Mobs")

-- // AUTO M1 // --
local defaultX, defaultY = 0, viewport.Y
local targetX, targetY   = defaultX, defaultY
local clickInterval      = 0.3
local m1Running          = false

local clickPositionInput = AutoTab:CreateInput({
    Name                    = "Click Position (X, Y)",
    CurrentValue            = "",
    PlaceholderText         = ("%d, %d"):format(defaultX, defaultY),
    RemoveTextAfterFocusLost= false,
    Flag                    = "ClickPosition",
    Callback                = function(text) end,
})

AutoTab:CreateButton({
    Name     = "Set Click Pos",
    Callback = function()
        Rayfield:Notify({
            Title   = "Auto M1",
            Content = "Click anywhere to set spam location",
            Duration= 2,
        })
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                targetX, targetY = input.Position.X, input.Position.Y
                clickPositionInput:Set(("%d, %d"):format(targetX, targetY))
                Rayfield:Notify({
                    Title   = "Auto M1",
                    Content = ("Location set: %d, %d"):format(targetX, targetY),
                    Duration= 2,
                    Image   = "pin",
                })
                conn:Disconnect()
            end
        end)
    end,
})

local autom1Toggle = AutoTab:CreateToggle({
    Name         = "Auto M1",
    CurrentValue = false,
    Flag         = "AutoM1",
    Callback = function(state)
        m1Running = state
        if m1Running then
            local saved = Rayfield.Flags.ClickPosition and Rayfield.Flags.ClickPosition.CurrentValue
            if type(saved) == "string" then
                local xStr, yStr = saved:match("^(%-?%d+),%s*(%-?%d+)$")
                if xStr and yStr then
                    targetX, targetY = tonumber(xStr), tonumber(yStr)
                end
            end
            clickPositionInput:Set(("%d, %d"):format(targetX, targetY))
            task.spawn(function()
                while m1Running do
                    VirtualInputManager:SendMouseButtonEvent(targetX, targetY, 0, true,  game, 0)
                    VirtualInputManager:SendMouseButtonEvent(targetX, targetY, 0, false, game, 0)
                    task.wait(clickInterval)
                end
            end)
        end
    end,
})

AutoTab:CreateDivider()

-- // AUTOFARM MOBS // --
local detectionRadius     = 100
local defaultOffset       = 8
local flightSpeed         = 200

local OFFSET_OVERRIDES = {
    ["Infernal"] = 8,
}
local WHITELIST = {}
for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then
        WHITELIST[plr.Character.Name] = true
    end
end
local CUSTOM_WHITELIST = {
    "FireForceGuard1",
    "FireForceScientist",
    "HolySolCommander",
    "HolySolAssassin",
    "IgorCombatNPC",
    "AdultCivilianNPC",
}
for _, name in ipairs(CUSTOM_WHITELIST) do
    WHITELIST[name] = true
end

local character, hrp
local function onCharacterAdded(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart")
end
player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
    onCharacterAdded(player.Character)
end

local autoFarmEnabled   = false
local autoGripEnabled   = true  
local farmConn
local lastMob, knockStart, isRescuing = nil, nil, false

AutoTab:CreateSlider({
    Name         = "Detection Radius",
    Range        = {10, 1000},
    Increment    = 10,
    Suffix       = "studs",
    CurrentValue = detectionRadius,
    Flag         = "DetectionRadius",
    Callback     = function(v) detectionRadius = v end,
})
AutoTab:CreateSlider({
    Name         = "Default Offset",
    Range        = {0, 20},
    Increment    = 0.5,
    Suffix       = "studs",
    CurrentValue = defaultOffset,
    Flag         = "DefaultOffset",
    Callback     = function(v) defaultOffset = v end,
})
AutoTab:CreateToggle({
    Name         = "Auto Grip",
    CurrentValue = true,
    Flag         = "autoGrip",
    Callback     = function(v)
        autoGripEnabled = v
    end,
})
local function findClosestMob()
    if not hrp then return nil end
    local alive = workspace:FindFirstChild("Alive")
    if not alive then return nil end

    local origin       = hrp.Position
    local bestD_high   = math.huge
    local bestD_norm   = math.huge
    local closest_high, closest_norm = nil, nil

    for _, mdl in ipairs(alive:GetDescendants()) do
        if mdl:IsA("Model") and not WHITELIST[mdl.Name] then
            local hum = mdl:FindFirstChildOfClass("Humanoid")
            if hum then
                local state = hum:GetState()
                if state ~= Enum.HumanoidStateType.Physics then
                    local hp = hum.Health
                    if autoGripEnabled or hp > 1 then
                        local pivot = mdl:GetPivot().Position
                        local d = (pivot - origin).Magnitude
                        if d <= detectionRadius then
                            if hp > 1 then
                                if d < bestD_high then
                                    bestD_high, closest_high = d, mdl
                                end
                            elseif hp > 0 then
                                if d < bestD_norm then
                                    bestD_norm, closest_norm = d, mdl
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closest_high or closest_norm
end

local function otherMobNearby(exclude)
    if not hrp then return false end
    local origin = hrp.Position
    local alive  = workspace:FindFirstChild("Alive")
    if not alive then return false end

    for _, mdl in ipairs(alive:GetDescendants()) do
        if mdl ~= exclude and mdl:IsA("Model") and not WHITELIST[mdl.Name] then
            local hum = mdl:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Physics then
                if (mdl:GetPivot().Position - origin).Magnitude <= 15 then
                    return true
                end
            end
        end
    end
    return false
end

local function doRescue(mob)
    isRescuing = true
    autom1:Set(false)
    if farmConn then farmConn:Disconnect(); farmConn = nil end
    stopCurrentMovement()

    task.wait(0.5)
    hrp.CFrame = CFrame.new(mob:GetPivot().Position + Vector3.new(0,3,0))
    task.wait(1)
    VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.B, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.B, false, game)

    local startTime = tick()
    while tick() - startTime < 5 do
        if otherMobNearby(mob) then break end
        task.wait(0.1)
    end

    enableKillAuraToggle:Set(true)
    lastMob, knockStart, isRescuing = nil, nil, false

    if autoFarmEnabled then
        farmConn = RunService.Heartbeat:Connect(farmLoop)
    end
end

local healthRetreatEnabled = false
local retreating           = false

AutoTab:CreateToggle({
    Name         = "Health Retreat",
    CurrentValue = false,
    Flag         = "HealthRetreat",
    Callback     = function(enabled)
        healthRetreatEnabled = enabled
        if not enabled then
            retreating = false
        end
    end,
})

local retreatAlign

function farmLoop()
    if isRescuing or not autoFarmEnabled or not hrp then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if healthRetreatEnabled and humanoid then
        local pct = humanoid.Health / humanoid.MaxHealth

        if pct <= 0.30 then
            if not retreating then
                retreating = true
                stopCurrentMovement()
                if not retreatAlign then
                    retreatAlign = Instance.new("AlignPosition")
                    retreatAlign.Name = "RetreatAlign"
                    retreatAlign.Mode = Enum.PositionAlignmentMode.OneAttachment
                    retreatAlign.Attachment0 = hrp:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", hrp)
                    retreatAlign.RigidityEnabled = true
                    retreatAlign.MaxForce = 1e9
                    retreatAlign.Responsiveness = 200
                    retreatAlign.Parent = hrp
                end

                retreatAlign.Position = hrp.Position + Vector3.new(0, -50, 0)
                retreatAlign.Enabled = true

                Rayfield:Notify({
                    Title   = "Health Retreat",
                    Content = "Low health! Holding position 50 studs above…",
                    Duration= 3,
                    Image   = "shield-alert",
                })
            end
            return -- Suspend all other logic during retreat
        elseif retreating and pct >= 0.80 then
            retreating = false
            if retreatAlign then
                retreatAlign.Enabled = false
            end
            Rayfield:Notify({
                Title   = "Health Retreat",
                Content = "Health restored—resuming auto-farm",
                Duration= 3,
                Image   = "shield-check",
            })
        elseif retreating then
            return -- Still retreating and not healed
        end
    end

    -- FARMING logic continues below ONLY if not retreating
    local mob = findClosestMob()
    if mob then
        if autoGripEnabled and mob:FindFirstChild("Knocked") then
            if lastMob ~= mob then
                lastMob, knockStart = mob, tick()
            elseif tick() - knockStart >= 3 then
                doRescue(mob)
                return
            end
        else
            lastMob, knockStart = nil, nil
        end

        local offset = OFFSET_OVERRIDES[mob.Name] or defaultOffset
        local target = mob:GetPivot().Position
        setFlightTarget(target, flightSpeed, true, -offset)
        hrp.CFrame = CFrame.new(hrp.Position, target)
    else
        stopCurrentMovement()
    end
end

local originalDevCamMode = player.DevCameraOcclusionMode

local function startAutoFarm()
    if farmConn then return end
    autoFarmEnabled = true
    player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
    farmConn = RunService.Heartbeat:Connect(farmLoop)
end

local function stopAutoFarm()
    autoFarmEnabled = false
    if farmConn then
        farmConn:Disconnect()
        farmConn = nil
    end
    player.DevCameraOcclusionMode = originalDevCamMode
    stopCurrentMovement()
    task.wait(3)
end

local toggleAutoFarmMobs = AutoTab:CreateToggle({
    Name         = "AutoFarm Mobs",
    CurrentValue = false,
    Flag         = "autoFarmMobs",
    Callback     = function(v)
        if v then 
            startAutoFarm()
            enableKillAuraToggle:Set(true)
        else 
            stopAutoFarm() 
        end
    end,
})

-- // RAID // --
AutoTab:CreateSection("Reaper Dungeon")

AutoTab:CreateParagraph({
    Title = "Reaper Dungeon Info",
    Content = "Make sure you have kill aura and instakill turned on, and the health threshold set to 90%."
})

local function moveToAndWait(pos, label, range, timeout, sendKeys)
	setFlightTarget(pos, 300, false, 8)

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		player.CharacterAdded:Wait()
		hrp = player.Character:WaitForChild("HumanoidRootPart")
	end

	local startTime = tick()
	while (hrp.Position - pos).Magnitude > range do
		if tick() - startTime > timeout then
			Rayfield:Notify({
				Title = label,
				Content = "Timeout while moving.",
				Duration = 3,
				Image = "alert-triangle",
			})
			return false
		end
		task.wait(0.25)
	end

	if sendKeys then
		task.spawn(function()
			local VirtualInputManager = game:GetService("VirtualInputManager")
			local camera = workspace.CurrentCamera
			if not VirtualInputManager or not camera then return end

			local screenSize = camera.ViewportSize
			local centerX, centerY = screenSize.X / 2, screenSize.Y / 2

			local function sendSequence(includeBackslash)
				VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
				VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
				task.wait(4)

				local sequence = {
					includeBackslash and Enum.KeyCode.BackSlash or nil,
					Enum.KeyCode.Right,
					Enum.KeyCode.Right,
					Enum.KeyCode.Right,
					Enum.KeyCode.Down,
					Enum.KeyCode.Return
				}

				for _, key in ipairs(sequence) do
					if key then
						VirtualInputManager:SendKeyEvent(true, key, false, game)
						task.wait(0.1)
						VirtualInputManager:SendKeyEvent(false, key, false, game)
						task.wait(0.1)
					end
				end
			end

			sendSequence(true)   -- first run includes Backslash
			task.wait(3)
			sendSequence(false)  -- second run skips Backslash
		end)
	end

	return true
end

local function waitForBoss(modelName, timeout)
    local aliveFolder = workspace:FindFirstChild("Alive")
    if not aliveFolder then return nil end

    local startTime = tick()
    while tick() - startTime < timeout do
        local boss = aliveFolder:FindFirstChild(modelName)
        if boss and boss:IsA("Model") and boss:FindFirstChild("HumanoidRootPart") then
            return boss
        end
        task.wait(1)
    end
    return nil
end

local function optimizedReaperFarm()
    if isReaperAutoRunning then return end
    isReaperAutoRunning = true

    local alive = workspace:FindFirstChild("Alive")
    local boss = alive and alive:FindFirstChild("GrandReaperBoss")
    local hrp = boss and boss:FindFirstChild("HumanoidRootPart")

    if not hrp then
        -- Step 1: Enter Reaper Door (only if boss doesn't already exist)
        local door = workspace:FindFirstChild("ReaperBossDoor")
        local doorPart = door and door:FindFirstChild("ClickPart")
        if doorPart then
            moveToAndWait(doorPart.Position + Vector3.new(0,2,0), "Reaper Door", 10, 15, true)
            local detector = doorPart:FindFirstChild("ClickDetector")
            if detector then fireclickdetector(detector) end
        else
            Rayfield:Notify({ Title = "Error", Content = "Reaper door not found", Duration = 3, Image = "x" })
            isReaperAutoRunning = false
            return
        end
        local waitStart = tick()
        repeat
            boss = workspace:FindFirstChild("Alive") and workspace.Alive:FindFirstChild("GrandReaperBoss")
            hrp = boss and boss:FindFirstChild("HumanoidRootPart")
            task.wait(0.25)
        until hrp or tick() - waitStart >= 20

        if not hrp then
            Rayfield:Notify({
                Title = "Boss Not Found",
                Content = "Reaper boss did not spawn in time.",
                Duration = 3,
                Image = "ghost",
            })
            isReaperAutoRunning = false
            return
        end
    else
        Rayfield:Notify({
            Title = "Boss Already Present",
            Content = "Skipping dungeon door.",
            Duration = 3,
            Image = "arrow-down-to-line",
        })
    end
    local success = moveToAndWait(hrp.Position, "Reaper Boss", 12, 20)
    if not success then
        isReaperAutoRunning = false
        return
    end
    startAutoFarm()
    local function bossExists()
        return workspace:FindFirstChild("Alive")
            and workspace.Alive:FindFirstChild("GrandReaperBoss")
    end
local timeout = 150
local startTime = tick()
local goneTime = nil

while tick() - startTime < timeout do
    if not workspace:FindFirstChild("Alive") or not workspace.Alive:FindFirstChild("GrandReaperBoss") then
        if not goneTime then
            goneTime = tick()
        elseif tick() - goneTime >= 3 then
            break
        end
    else
        goneTime = nil
    end
    task.wait(0.5)
end
    stopAutoFarm()
    Rayfield:Notify({
        Title = "Reaper Cycle Complete",
        Content = "Looping again shortly...",
        Duration = 3,
        Image = "repeat",
    })
    local message = string.format([[
**Reaper Killed**
Backpack: %s
Money: %s
Dungeon Coins: %s
]], getBackpackItems(), getMoney(), getDungeonCoins())
    sendToWebhook(userWebhook, message)
    task.wait(5)
    isReaperAutoRunning = false
end

-- Declare control flag
local autoReaperEnabled = false
isReaperAutoRunning = false

AutoTab:CreateToggle({
    Name = "Auto Reaper Dungeon",
    Flag = "AutoReaperEntry",
    CurrentValue = false,
    Callback = function(state)
        autoReaperEnabled = state

        if not state then
            toggleAutoFarmMobs:Set(false)
            Rayfield:Notify({
                Title = "Reaper AutoFarm",
                Content = "Disabled Reaper dungeon loop.",
                Duration = 3,
                Image = "x"
            })
        else
            Rayfield:Notify({
                Title = "Reaper AutoFarm",
                Content = "Enabled Reaper dungeon loop.",
                Duration = 3,
                Image = "swords"
            })
        end
    end,
})

task.spawn(function()
    while true do
        if autoReaperEnabled and not isReaperAutoRunning then
            optimizedReaperFarm()
        end
        task.wait(1)
    end
end)

AutoTab:CreateSection("Desert Dungeon")

AutoTab:CreateParagraph({
    Title = "Desert Dungeon Boss Info",
    Content = "For the Lorus boss just toggle the AutoKill and it will take you there and kill it using kill aura. For the Wendigo boss press the button to tp there then kill it instantly using the instakill toggle in main tab. Once you have done this you can use the go to dragon button, start the fight by clicking on the chair, setting the health slider to 90% in instakill, then just do 10% of dragon's health and you can just instakill it."
})

AutoTab:CreateButton({
    Name = "Go to Desert Dungeon Door",
    Callback = function()
        task.spawn(function()
            local doorModel = workspace:FindFirstChild("DesertDungeonDoor")
            local model = doorModel and doorModel:FindFirstChild("DoorModel")

            if model then
                local pivotPos = model:GetPivot().Position + Vector3.new(0, 5, 0) -- fly above the model
                setFlightTarget(pivotPos, 200, false, 8)
            else
                warn("❌ DoorModel not found")
            end
        end)
    end,
})

local artifactsAndChestToggle = AutoTab:CreateToggle({
    Name         = "Auto Puzzle",
    CurrentValue = false,
    Callback     = function(on)
        if not on then return end

        task.spawn(function()
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not playerRoot then
                player.CharacterAdded:Wait()
                playerRoot = player.Character:WaitForChild("HumanoidRootPart")
            end
            local function distSq(pos)
                return (playerRoot.Position - pos).Magnitude^2
            end
            local ignore   = workspace:WaitForChild("IgnoreParts")
            local meshNames = {"BladeArtifact", "GemArtifact", "IdolArtifact"}
            local spawnsFolder = workspace:WaitForChild("LibraryDungeon"):WaitForChild("ArtifactSpawns")
            local spawns = spawnsFolder:GetChildren()
            table.sort(spawns, function(a, b)
                return distSq(a.Position) < distSq(b.Position)
            end)

            local clicked = {}

            for _, spawn in ipairs(spawns) do
                if not on then return end
                setFlightTarget(spawn.Position, 300, false, 8)
                repeat task.wait() 
                until (playerRoot.Position - spawn.Position).Magnitude <= 5 or not on
                task.wait(1)

                for _, name in ipairs(meshNames) do
                    if not clicked[name] then
                        local m = ignore:FindFirstChild(name)
                        if m and m:IsA("MeshPart") then
                            if (playerRoot.Position - m.Position).Magnitude <= 10 then
                                local cd = m:FindFirstChild("ClickDetector")
                                if cd then
                                    pcall(fireclickdetector, cd)
									wait(1.4)
                                end
                                clicked[name] = true
                            end
                        end
                    end
                end
                if #clicked >= #meshNames + 1 then
                    break
                end
            end
            if on then
                local pedModel = workspace:FindFirstChild("DesertedDesert")
                                    and workspace.DesertedDesert:FindFirstChild("Pedestal")
                if pedModel and pedModel:IsA("Model") then
                    local pivotPos = pedModel:GetPivot().Position
                    setFlightTarget(pivotPos, 300, false, 8)
                    repeat task.wait() 
                    until (playerRoot.Position - pivotPos).Magnitude <= 5 or not on
                    task.wait(1)
                    local cd = pedModel:FindFirstChild("ClickDetector")
					enableKillAuraToggle:Set(false)
                    pcall(fireclickdetector, cd)
					wait(1)
					enableKillAuraToggle:Set(false)
                end
            end
        end)
    end,
})

local hoveringLorus = false

AutoTab:CreateToggle({
    Name         = "AutoKill Lorus",
    CurrentValue = false,
    Callback     = function(on)
        hoveringLorus = on
        if on then
            task.spawn(function()
                while hoveringLorus do
                    local boss = workspace:FindFirstChild("Alive")
                                 and workspace.Alive:FindFirstChild("InfernalLorus")
                    if not boss then
                        hoveringLorus = false
                        break
                    end
                    local dd   = workspace:FindFirstChild("DesertedDesert")
                    local l    = dd   and dd:FindFirstChild("Lorus")
                    local part = l    and l:FindFirstChild("BossSpawnPart")
                    if not (part and part:IsA("BasePart")) then
                        hoveringLorus = false
                        break
                    end
                    local pivotPos = part:GetPivot().Position
                    setFlightTarget(pivotPos, 300, true, -15)

                    task.wait(0.5)
                end
                stopCurrentMovement()
            end)
        else
            stopCurrentMovement()
        end
    end,
})

AutoTab:CreateSection("Wendigo Helper")

AutoTab:CreateButton({
    Name     = "Go to Wendigo",
    Callback = function()
        local alive = workspace:FindFirstChild("Alive")
        local boss  = alive and alive:FindFirstChild("WendigoInfernal")
        if not (boss and boss:IsA("Model")) then
            Rayfield:Notify({Title = "Go to Wendigo", Content = "Wendigo not spawned.", Duration = 3})
            return
        end
        local dd   = workspace:FindFirstChild("DesertedDesert")
        local w    = dd and dd:FindFirstChild("Wendigo")
        local part = w and w:FindFirstChild("BossSpawnPart")
        if not (part and part:IsA("BasePart")) then
            Rayfield:Notify({Title = "Go to Wendigo", Content = "Spawn part not found.", Duration = 3})
            return
        end

		local pivotPos = part:GetPivot().Position
        setFlightTarget(pivotPos, 300, false, 15)
    end,
})

AutoTab:CreateButton({
    Name = "Click Vending Machine",
    Callback = function()
        local vmPart = workspace:FindFirstChild("DesertedDesert")
                       and workspace.DesertedDesert:FindFirstChild("VendingMachineClickPart")
        if not vmPart then
            warn("VendingMachineClickPart not found")
            return
        end
        local cd = vmPart:FindFirstChildOfClass("ClickDetector")
        if not cd then
            warn("ClickDetector missing on VendingMachineClickPart")
            return
        end
        pcall(fireclickdetector, cd)
    end,
})

AutoTab:CreateButton({
    Name = "Start Dragon Fight",
    Callback = function()
        local bossStuff = workspace:FindFirstChild("DragonBossStuff")
        local clickPart = bossStuff and bossStuff:FindFirstChild("ClickPart")
        if not (clickPart and clickPart:IsA("BasePart")) then
            warn("DragonBossStuff.ClickPart not found")
            return
        end
        setFlightTarget(clickPart.Position, 300, false, 8)
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            player.CharacterAdded:Wait()
            hrp = player.Character:WaitForChild("HumanoidRootPart")
        end
        repeat task.wait(0.1)
        until (hrp.Position - clickPart.Position).Magnitude <= 5
        task.wait(0.5)
        local cd = clickPart:FindFirstChildOfClass("ClickDetector")
        if cd then
            pcall(fireclickdetector, cd)
        else
            warn("ClickDetector missing on DragonBossStuff.ClickPart")
        end
        stopCurrentMovement()
    end,
})

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Cerberus Loaded",
    Content = "Enjoy using our script!",
    Duration = 4,
    Image = "check"
})

