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

-- #### UI Setup #### --
local Window = Rayfield:CreateWindow({
    Name = "Mugen | Cerberus",
    Theme = "Default",
    LoadingTitle = "Loading Mugen...",
    LoadingSubtitle = "Cerberus | Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Cerberus",
        FileName = "Mugen"
    }
})

-- #### Tabs #### --
local MainTab = Window:CreateTab("Main", "home")
local PlayerTab = Window:CreateTab("Player", "circle-user")
local ESPTab = Window:CreateTab("Visual", "eye")
local MiscTab = Window:CreateTab("Misc", "menu")

-- #### Services #### --
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

-- #### References #### --
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local Terrain = workspace:FindFirstChildOfClass("Terrain")

-- #### GET PARRY CONFIG #### --
local configName = "ParryConfigMgn.json"
local configUrl  = "https://gitlab.com/newtoyotacamry/helpers/-/raw/main/ParryConfigRS.json?ref_type=heads"

if not (isfile and isfile(configName)) then
    if writefile and syn and syn.request then
        local resp = syn.request({Url = configUrl, Method = "GET"})
        if resp and resp.StatusCode == 200 and resp.Body then
            writefile(configName, resp.Body)
            print("[AutoParry] Wrote default config:", configName)
        else
            warn("[AutoParry] Failed to download config! ("..tostring(resp and resp.StatusCode)..")")
        end
    elseif writefile and http_request then
        local resp = http_request({Url = configUrl, Method = "GET"})
        if resp and resp.StatusCode == 200 and resp.Body then
            writefile(configName, resp.Body)
            print("[AutoParry] Wrote default config:", configName)
        else
            warn("[AutoParry] Failed to download config! ("..tostring(resp and resp.StatusCode)..")")
        end
    elseif writefile and request then
        local resp = request({Url = configUrl, Method = "GET"})
        if resp and resp.StatusCode == 200 and resp.Body then
            writefile(configName, resp.Body)
            print("[AutoParry] Wrote default config:", configName)
        else
            warn("[AutoParry] Failed to download config! ("..tostring(resp and resp.StatusCode)..")")
        end
    else
        warn("[AutoParry] Your executor does not support HTTP/file APIs")
    end
end

-- #### WEBHOOK SENDER #### --
local function sendToWebhook(webhookUrl, embedTitle, messageContent)
    local embed = {
        ["title"]       = embedTitle, 
        ["description"] = messageContent,
        ["color"]       = 0x50C9F1,   
        ["timestamp"]   = os.date("!%Y-%m-%dT%H:%M:%SZ"), 
    }
    
    local payload = {
        ["username"]   = "Cerberus Logger",
        ["avatar_url"] = "https://media.discordapp.net/attachments/936776180026204241/1351880348728037517/Nox_hub_banner.png?ex=683d8b2f&is=683c39af&hm=76cce0ce6792f011cfe6124bfb71e099cff554e162776905ba6d19e6fd4ed4b0&=&format=webp&quality=lossless&width=2638&height=1484",
        ["embeds"]     = { embed },
    }

    local jsonBody = HttpService:JSONEncode(payload)

    local success, response = pcall(function()
        return syn and syn.request({
            Url     = webhookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = jsonBody
        }) or http_request and http_request({
            Url     = webhookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = jsonBody
        }) or request and request({
            Url     = webhookUrl,
            Method  = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = jsonBody
        })
    end)

    return success, response
end

-- #### TWEENING HELPER FUNCTION #### --
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

-- #### TWEENING HELPER FUNCTION #### --
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

-- ################## --
-- #### MAIN TAB #### --
-- ################## --


-- #### AUTO PARRY #### --
MainTab:CreateSection("Auto Parry")

local parryLookup = {}
local function loadConfig()
    local file = "ParryConfigMgn.json"
    if isfile and isfile(file) then
        local content = readfile(file)
        local success, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and type(data) == "table" then
            for _, list in pairs(data) do
                for _, entry in ipairs(list) do
                    if entry.id and entry.startTime and entry.holdTime then
                        parryLookup[entry.id] = {
                            startTime = entry.startTime,
                            holdTime = entry.holdTime
                        }
                    end
                end
            end
        end
    end
end
loadConfig()

local isAutoParryEnabled = false
local pingCompEnabled = false
local pingMs = 0
local pingPercent = 100
local parryRange = 10

-- 📶 Ping Monitor
task.spawn(function()
    while true do
        if player and player:GetNetworkPing() then
            pingMs = math.floor(player:GetNetworkPing() * 1000)
        end
        task.wait(5)
    end
end)

-- 📏 Check range to attacker
local function isInRange(model)
    if model == player.Character then return false end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    local lhrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    return hrp and lhrp and (hrp.Position - lhrp.Position).Magnitude <= parryRange
end

-- 🗡️ AutoParry Logic
local humanoidConnections = {}

local function hookHumanoid(humanoid)
    if humanoidConnections[humanoid] then return end
    humanoidConnections[humanoid] = humanoid.AnimationPlayed:Connect(function(track)
        if not isAutoParryEnabled then return end
        local animId = tostring(track.Animation.AnimationId):match("%d+")
        if not animId or not isInRange(humanoid.Parent) then return end
        local cfg = parryLookup[animId]
        if not cfg then return end

        local duration = track.Length or 0
        if duration <= 0 then return end

        local baseDelay = (cfg.startTime / 100) * duration
        local pingAdjust = pingCompEnabled and (pingMs / 1000) * (pingPercent / 100) or 0
        local pressDelay = math.max(0, baseDelay - pingAdjust)

        task.spawn(function()
            task.wait(pressDelay)
            if not isAutoParryEnabled then return end
            VirtualInputManager:SendKeyEvent(true, "F", false, game)
            task.wait(cfg.holdTime)
            VirtualInputManager:SendKeyEvent(false, "F", false, game)
        end)
    end)
end

-- 🧠 Initial and dynamic humanoid hooking
for _, inst in ipairs(Workspace:GetDescendants()) do
    if inst:IsA("Humanoid") then hookHumanoid(inst) end
end

Workspace.DescendantAdded:Connect(function(inst)
    if inst:IsA("Humanoid") then
        task.delay(0.05, function()
            if inst.Parent and inst:IsDescendantOf(Workspace) then
                hookHumanoid(inst)
            end
        end)
    end
end)

Workspace.DescendantRemoving:Connect(function(inst)
    if inst:IsA("Humanoid") and humanoidConnections[inst] then
        humanoidConnections[inst]:Disconnect()
        humanoidConnections[inst] = nil
    end
end)

-- 🧩 UI Controls
MainTab:CreateToggle({
    Name = "Enable Auto Parry",
    CurrentValue = false,
    Flag = "AutoParryToggle",
    Callback = function(v) isAutoParryEnabled = v end,
})

MainTab:CreateSlider({
    Name = "Parry Range",
    Range = {0, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = parryRange,
    Flag = "ParryRangeSlider",
    Callback = function(v) parryRange = v end,
})

MainTab:CreateToggle({
    Name = "Enable Ping Compensation",
    CurrentValue = false,
    Flag = "PingCompToggle",
    Callback = function(v) pingCompEnabled = v end,
})

MainTab:CreateSlider({
    Name = "Ping Compensation %",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = pingPercent,
    Flag = "PingPercentSlider",
    Callback = function(v) pingPercent = v end,
})

MainTab:CreateButton({
    Name = "Show Current Ping",
    Callback = function()
        local msg = pingMs > 0 and (pingMs .. " ms") or "Ping unavailable"
        Rayfield:Notify({ Title = "Current Ping", Content = msg, Duration = 3 })
    end
})

MainTab:CreateButton({
    Name = "Load AutoParry Builder",
    Callback = function()
        loadstring(game:HttpGet('https://gitlab.com/newtoyotacamry/helpers/-/raw/main/autoParryBuilderRS.lua?ref_type=heads'))()
    end
})

-- #################### --
-- #### PLAYER TAB #### --
-- #################### --

PlayerTab:CreateSection("Movement")

-- #### FLIGHT #### --
local flying       = false
local flySpeed     = 100
local lastY        = nil
local bodyGyro     = nil

local flightToggle = PlayerTab:CreateToggle({
    Name         = "Flight",
    Flag         = "Flight",
    CurrentValue = false,
    Callback     = function(state)
        flying = state
        if humanoid and hrp then
            if state then
                humanoid.PlatformStand = true
                lastY = hrp.Position.Y
                local bg = Instance.new("BodyGyro")
                bg.Name      = "FlightGyro"
                bg.P         = 20000
                bg.D         = 1000
                bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                bg.CFrame    = hrp.CFrame
                bg.Parent    = hrp
                bodyGyro     = bg
            else
                humanoid.PlatformStand = false
                if bodyGyro then
                    bodyGyro:Destroy()
                    bodyGyro = nil
                end
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end,
})

PlayerTab:CreateKeybind({
    Name             = "Toggle Flight",
    Flag             = "flightBind",
    CurrentKeybind   = "G",
    HoldToInteract   = false,
    Callback         = function(state)
        if flying then
        flightToggle:Set(false)
        else
        flightToggle:Set(true)
        end
    end,
})

PlayerTab:CreateSlider({
    Name         = "Flight Speed",
    Flag         = "flightSpeed",
    Range        = { 10, 300 },
    Increment    = 10,
    CurrentValue = flySpeed,
    Callback     = function(val)
        flySpeed = val
    end,
})

local function onCharacterAdded(char)
    character = char
    humanoid   = char:WaitForChild("Humanoid")
    hrp        = char:WaitForChild("HumanoidRootPart")
    if flying and hrp then
        humanoid.PlatformStand = true
        lastY = hrp.Position.Y

        local bg = Instance.new("BodyGyro")
        bg.Name      = "FlightGyro"
        bg.P         = 20000
        bg.D         = 1000
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.CFrame    = hrp.CFrame
        bg.Parent    = hrp
        bodyGyro     = bg
    end
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local inputState = {
    Forward  = false,
    Backward = false,
    Left     = false,
    Right    = false,
    Up       = false,
    Down     = false,
}

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if     k == Enum.KeyCode.W then inputState.Forward  = true
        elseif k == Enum.KeyCode.S then inputState.Backward = true
        elseif k == Enum.KeyCode.A then inputState.Left     = true
        elseif k == Enum.KeyCode.D then inputState.Right    = true
        elseif k == Enum.KeyCode.Space then inputState.Up    = true
        elseif k == Enum.KeyCode.LeftShift then inputState.Down = true
        end
    end
end

local function onInputEnded(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local k = input.KeyCode
        if     k == Enum.KeyCode.W then inputState.Forward  = false
        elseif k == Enum.KeyCode.S then inputState.Backward = false
        elseif k == Enum.KeyCode.A then inputState.Left     = false
        elseif k == Enum.KeyCode.D then inputState.Right    = false
        elseif k == Enum.KeyCode.Space then inputState.Up    = false
        elseif k == Enum.KeyCode.LeftShift then inputState.Down = false
        end
    end
end

UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputEnded:Connect(onInputEnded)

local function getMobileMoveVector()
    if humanoid and UserInputService.TouchEnabled then
        local dir = humanoid.MoveDirection
        if dir.Magnitude > 0 then
            local cf      = camera.CFrame
            local forward = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z).Unit
            local right   = Vector3.new(cf.RightVector.X, 0, cf.RightVector.Z).Unit
            return (forward * dir.Z + right * dir.X).Unit
        end
    end
    return Vector3.zero
end

RunService.RenderStepped:Connect(function()
    if not flying or not humanoid or not hrp then
        return
    end

    local moveDir = Vector3.new(0, 0, 0)
    local camCF   = camera.CFrame
    if not UserInputService.TouchEnabled then
        if inputState.Forward  then moveDir = moveDir + camCF.LookVector end
        if inputState.Backward then moveDir = moveDir - camCF.LookVector end
        if inputState.Left     then moveDir = moveDir - camCF.RightVector end
        if inputState.Right    then moveDir = moveDir + camCF.RightVector end
    else
        moveDir = getMobileMoveVector()
    end

    if inputState.Up   then moveDir = moveDir + Vector3.new(0, 1, 0) end
    if inputState.Down then moveDir = moveDir - Vector3.new(0, 1, 0) end

    if bodyGyro then
        bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + camCF.LookVector)
    end

    local velocity = Vector3
    if moveDir.Magnitude > 0 then
        velocity = moveDir.Unit * flySpeed
        lastY    = hrp.Position.Y
    else
        local yOffset = lastY and (lastY - hrp.Position.Y) or 0
        velocity = Vector3.new(0, yOffset * 5, 0)
    end

    hrp.Velocity = velocity
end)

PlayerTab:CreateSection("Misc Utils")

-- #### NO CLIP #### --
local noclipEnabled = false
local noclipConn    = nil

local function setCharacterCollisions(state)
    if not player.Character then return end
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end

local function toggleNoClip(on)
    noclipEnabled = on
    if on then
        noclipConn = RunService.Stepped:Connect(function()
            setCharacterCollisions(false)
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
        setCharacterCollisions(true)
    end
end

player.CharacterAdded:Connect(function(char)
    character    = char
    humanoidRoot = char:WaitForChild("HumanoidRootPart")
    if noclipEnabled then
        if noclipConn then
            noclipConn:Disconnect()
        end
        noclipConn = RunService.Stepped:Connect(function()
            setCharacterCollisions(false)
        end)
    end
end)

PlayerTab:CreateToggle({
    Name         = "NoClip",
    CurrentValue = false,
    Flag         = "NoClipToggle",
    Callback     = function(state)
        toggleNoClip(state)
    end,
})

-- #### PERFORMANCE MODE #### --
local original = {
    QualityLevel     = settings().Rendering.QualityLevel,
    GlobalShadows    = Lighting.GlobalShadows,
    Ambient          = Lighting.Ambient,
    Brightness       = Lighting.Brightness,
    FogEnd           = Lighting.FogEnd,
    FogStart         = Lighting.FogStart,
    EffectsEnabled   = {}, 
    WaterWaveSize    = nil,
    WaterReflectance = nil,
    WaterTransparency= nil,
}

local effectClasses = {
    "BloomEffect",
    "ColorCorrectionEffect",
    "SunRaysEffect",
    "DepthOfFieldEffect",
    "BlurEffect",
    "ShadowMap",
}

for _, className in ipairs(effectClasses) do
    for _, inst in ipairs(Lighting:GetDescendants()) do
        if inst.ClassName == className then
            original.EffectsEnabled[inst] = inst.Enabled
        end
    end
end

local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
    original.WaterWaveSize     = terrain.WaterWaveSize
    original.WaterReflectance  = terrain.WaterReflectance
    original.WaterTransparency = terrain.WaterTransparency
end

local performanceEnabled = false

PlayerTab:CreateToggle({
    Name         = "Performance Mode",
    CurrentValue = false,
    Flag         = "PerformanceMode",
    Callback     = function(enabled)
        performanceEnabled = enabled

        if enabled then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Ambient    = Color3.new(0.3, 0.3, 0.3)
            Lighting.Brightness = 1
            Lighting.FogEnd   = 1e10
            Lighting.FogStart = 1e10
            for inst, wasEnabled in pairs(original.EffectsEnabled) do
                if inst and inst.Parent then
                    inst.Enabled = false
                end
            end
            if terrain then
                terrain.WaterWaveSize     = 0
                terrain.WaterReflectance  = 0
                terrain.WaterTransparency = 1
            end
            for _, particle in ipairs(Workspace:GetDescendants()) do
                if particle:IsA("ParticleEmitter") or particle:IsA("Trail") then
                    particle.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = original.QualityLevel
            Lighting.GlobalShadows = original.GlobalShadows
            Lighting.Ambient       = original.Ambient
            Lighting.Brightness    = original.Brightness
            Lighting.FogEnd        = original.FogEnd
            Lighting.FogStart      = original.FogStart
            for inst, wasEnabled in pairs(original.EffectsEnabled) do
                if inst and inst.Parent then
                    inst.Enabled = wasEnabled
                end
            end
            if terrain then
                terrain.WaterWaveSize     = original.WaterWaveSize
                terrain.WaterReflectance  = original.WaterReflectance
                terrain.WaterTransparency = original.WaterTransparency
            end
            for _, particle in ipairs(Workspace:GetDescendants()) do
                if particle:IsA("ParticleEmitter") or particle:IsA("Trail") then
                    particle.Enabled = true
                end
            end
        end
    end,
})

-- #### RESET #### --
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

-- #### FOV SLIDER #### --
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

-- ################## --
-- #### AUTO TAB #### --
-- ################## --



-- ################# --
-- #### ESP TAB #### --
-- ################# --

ESPTab:CreateSection("Visual")

-- #### FULLBRIGHT #### --
local fullbrightEnabled = false
local originalSettings = {}

local function storeOriginalSettings()
    originalSettings = {
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient
    }
end

local function setFullbright(enabled)
    fullbrightEnabled = enabled
    if enabled then
        storeOriginalSettings()
    else
        if next(originalSettings) then
            Lighting.Brightness = originalSettings.Brightness
            Lighting.GlobalShadows = originalSettings.GlobalShadows
            Lighting.Ambient = originalSettings.Ambient
        end
    end
end

RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end)

ESPTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        setFullbright(Value)
    end
})

-- #### NO FOG #### --
local originalFogEnd      = Lighting.FogEnd
local originalFogStart    = Lighting.FogStart
local originalFogColor    = Lighting.FogColor
local removedWeatherItems = {}

local childAddedConn      = nil

local WEATHER_CLASSES = {
    Atmosphere      = true,
    BloomEffect     = true,
    SunRaysEffect   = true,
    Sky             = true,
}

local function isWeatherObject(inst)
    return WEATHER_CLASSES[inst.ClassName] == true
end

local function removeExistingWeather()
    for _, child in ipairs(Lighting:GetChildren()) do
        if isWeatherObject(child) then
            removedWeatherItems[#removedWeatherItems + 1] = child
            child.Parent = nil
        end
    end
end

local function onChildAdded(child)
    if isWeatherObject(child) then
        removedWeatherItems[#removedWeatherItems + 1] = child
        child.Parent = nil
    end
end

local function enableNoFog()
    removeExistingWeather()
    childAddedConn = Lighting.ChildAdded:Connect(onChildAdded)
    Lighting.FogEnd   = 1e10
    Lighting.FogStart = 1e10
    Lighting.FogColor = Color3.new(0, 0, 0)
end

local function restoreFogAndWeather()
    if childAddedConn then
        childAddedConn:Disconnect()
        childAddedConn = nil
    end

    Lighting.FogEnd   = originalFogEnd
    Lighting.FogStart = originalFogStart
    Lighting.FogColor = originalFogColor

    for _, inst in ipairs(removedWeatherItems) do
        if inst and inst.Parent == nil then
            inst.Parent = Lighting
        end
    end
    table.clear(removedWeatherItems)
end

ESPTab:CreateToggle({
    Name         = "No Fog",
    Flag         = "noFog",
    CurrentValue = false,
    Callback     = function(state)
        if state then
            enableNoFog()
        else
            restoreFogAndWeather()
        end
    end,
})

-- #### FREECAM #### --
local camDummy = Instance.new("Part")
camDummy.Name         = "FreecamSubject"
camDummy.Size         = Vector3.new(1, 1, 1)
camDummy.Transparency = 1
camDummy.Anchored     = true
camDummy.CanCollide   = false
camDummy.Parent       = workspace

local flying     = false
local flySpeed   = 100
local flyKeyDown = {}
local camConn    = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = false
    end
end)

ESPTab:CreateToggle({
    Name         = "Freecam",
    Flag         = "freecamToggle",
    CurrentValue = false,
    Callback     = function(state)
        flying = state
        if state then
            if humanoidRootPart then
                humanoidRootPart.Anchored = true
            end

            camDummy.CFrame = camera.CFrame
            camera.CameraType    = Enum.CameraType.Custom
            camera.CameraSubject = camDummy

            camConn = RunService.RenderStepped:Connect(function(dt)
                local moveVec = Vector3.new(0, 0, 0)
                local camCF   = camera.CFrame
                if flyKeyDown[Enum.KeyCode.W] then
                    moveVec = moveVec + camCF.LookVector
                end
                if flyKeyDown[Enum.KeyCode.S] then
                    moveVec = moveVec - camCF.LookVector
                end
                if flyKeyDown[Enum.KeyCode.A] then
                    moveVec = moveVec - camCF.RightVector
                end
                if flyKeyDown[Enum.KeyCode.D] then
                    moveVec = moveVec + camCF.RightVector
                end
                if flyKeyDown[Enum.KeyCode.Space] then
                    moveVec = moveVec + camCF.UpVector
                end
                if flyKeyDown[Enum.KeyCode.LeftShift] then
                    moveVec = moveVec - camCF.UpVector
                end
                if moveVec.Magnitude > 0 then
                    local delta = moveVec.Unit * flySpeed * dt
                    camDummy.CFrame = camDummy.CFrame + delta
                end
            end)
        else
            if camConn then
                camConn:Disconnect()
                camConn = nil
            end
            camera.CameraType = Enum.CameraType.Custom
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("Humanoid") or char:FindFirstChildWhichIsA("BasePart")
                if hrp then
                    camera.CameraSubject = hrp
                end
            end
            if humanoidRootPart then
                humanoidRootPart.Anchored = false
            end
        end
    end,
})

-- #### ESP #### --
local function findPart(obj)
    if not obj then
        return nil
    end
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart
        else
            for _, descendant in ipairs(obj:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    return descendant
                end
            end
        end
    end
    return nil
end

local function worldToScreenPos(worldPos)
    local screenPos, onScreen = camera:WorldToViewportPoint(worldPos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function getBounding2DCorners(rootModel)
    local rootPart = findPart(rootModel)
    if not rootPart then
        return nil
    end

    local cframe, size
    if rootModel:IsA("Model") then
        if not rootModel.PrimaryPart and not rootPart:IsDescendantOf(workspace) then
            return nil
        end
        cframe = rootModel:GetModelCFrame()
        size   = rootModel:GetExtentsSize()
    else
        if not rootPart:IsDescendantOf(workspace) then
            return nil
        end
        cframe = rootPart.CFrame
        size   = rootPart.Size
    end

    local half = size * 0.5
    local corners = {
        Vector3.new( half.X,  half.Y,  half.Z),
        Vector3.new( half.X,  half.Y, -half.Z),
        Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new(-half.X,  half.Y,  half.Z),
        Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z),
        Vector3.new(-half.X, -half.Y, -half.Z),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    for _, offset in ipairs(corners) do
        local worldCorner = (cframe * CFrame.new(offset)).Position
        local screenPos, _ = camera:WorldToViewportPoint(worldCorner)
        local sx, sy = screenPos.X, screenPos.Y
        if sx < minX then minX = sx end
        if sx > maxX then maxX = sx end
        if sy < minY then minY = sy end
        if sy > maxY then maxY = sy end
    end

    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local TracerOriginMode     = "Center"
local TextSize             = 14
local HealthBarThickness   = 4

local function getGlobalTracerOrigin()
    local vs = camera.ViewportSize
    if TracerOriginMode == "Center" then
        return vs * 0.5
    elseif TracerOriginMode == "Top" then
        return Vector2.new(vs.X * 0.5, 0)
    elseif TracerOriginMode == "Bottom" then
        return Vector2.new(vs.X * 0.5, vs.Y)
    elseif TracerOriginMode == "Mouse" then
        return UserInputService:GetMouseLocation()
    end
    return vs * 0.5
end

-- CATERGORIES
local categories = {
    {
        Name          = "Players",
        FetchFunction = function()
            local list = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local human = plr.Character:FindFirstChildWhichIsA("Humanoid")
                    local hrp   = plr.Character:FindFirstChild("HumanoidRootPart")
                    if human and hrp and human.Health > 0 then
                        list[#list + 1] = plr
                    end
                end
            end
            return list
        end,
        DefaultColor = Color3.fromRGB(  0, 170, 255),
        OrderIndex   = 1,
        Supports     = { tracer = true, name = true, box = true, health = true, weapon = true },
        Defaults     = { tracer = false, name = false, box = false, health = false, weapon = false },
    },
}

table.sort(categories, function(a, b)
    return a.OrderIndex < b.OrderIndex
end)

local states = {}

ESPTab:CreateSection("Universal ESP Settings")

ESPTab:CreateDropdown({
    Name          = "Tracer Origin",
    Options       = {"Center", "Top", "Bottom", "Mouse"},
    CurrentOption = {TracerOriginMode},
    Flag          = "ESP_TracerOriginMode",
    Callback      = function(opt)
        TracerOriginMode = opt[1]
    end,
})

ESPTab:CreateSlider({
    Name         = "Text Size",
    Range        = {8, 48},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = TextSize,
    Flag         = "ESP_TextSize",
    Callback     = function(v)
        TextSize = v
        for _, catState in pairs(states) do
            for _, data in pairs(catState.objects) do
                if data.nameText then
                    data.nameText.Size = TextSize
                end
            end
        end
    end,
})

ESPTab:CreateSlider({
    Name         = "Health Bar Thickness",
    Range        = {3, 10},
    Increment    = 1,
    Suffix       = "px",
    CurrentValue = HealthBarThickness,
    Flag         = "ESP_HealthBarThickness",
    Callback     = function(v)
        HealthBarThickness = v
        for _, catState in pairs(states) do
            for _, data in pairs(catState.objects) do
                if data.healthBarBg then
                    data.healthBarBg.Thickness = 1 
                end
                if data.healthBarFg then
                    data.healthBarFg.Thickness = 0  
                end
            end
        end
    end,
})

for _, catDef in ipairs(categories) do
    local cname = catDef.Name

    states[cname] = {
        Color         = catDef.DefaultColor,
        tracerEnabled = catDef.Defaults.tracer,
        nameEnabled   = catDef.Defaults.name,
        boxEnabled    = catDef.Defaults.box,
        healthEnabled = catDef.Defaults.health,
        weaponEnabled = catDef.Defaults.weapon,
        objects       = {}, 
    }
    local catState = states[cname]

    ESPTab:CreateSection(cname)

    ESPTab:CreateColorPicker({
        Name     = "Color",
        Color    = catDef.DefaultColor,
        Flag     = "ESP_" .. cname .. "_Color",
        Callback = function(newColor)
            catState.Color = newColor
        end,
    })

    if catDef.Supports.tracer then
        ESPTab:CreateToggle({
            Name         = "Tracers",
            CurrentValue = catState.tracerEnabled,
            Flag         = "ESP_" .. cname .. "_Tracer",
            Callback     = function(enabled)
                catState.tracerEnabled = enabled
                if not enabled then
                    for _, data in pairs(catState.objects) do
                        if data.tracerLine then
                            pcall(data.tracerLine.Remove, data.tracerLine)
                            data.tracerLine = nil
                        end
                    end
                end
            end,
        })
    end

    if catDef.Supports.name then
        ESPTab:CreateToggle({
            Name         = "Names",
            CurrentValue = catState.nameEnabled,
            Flag         = "ESP_" .. cname .. "_Name",
            Callback     = function(enabled)
                catState.nameEnabled = enabled
                if not enabled then
                    for _, data in pairs(catState.objects) do
                        if data.nameText then
                            pcall(data.nameText.Remove, data.nameText)
                            data.nameText = nil
                        end
                    end
                end
            end,
        })
    end

    if catDef.Supports.box then
        ESPTab:CreateToggle({
            Name         = "Boxes",
            CurrentValue = catState.boxEnabled,
            Flag         = "ESP_" .. cname .. "_Box",
            Callback     = function(enabled)
                catState.boxEnabled = enabled
                if not enabled then
                    for _, data in pairs(catState.objects) do
                        if data.boxLines then
                            for _, ln in ipairs(data.boxLines) do
                                pcall(ln.Remove, ln)
                            end
                            data.boxLines = nil
                        end
                    end
                end
            end,
        })
    end

    if catDef.Supports.health then
        ESPTab:CreateToggle({
            Name         = "Health Bars",
            CurrentValue = catState.healthEnabled,
            Flag         = "ESP_" .. cname .. "_Health",
            Callback     = function(enabled)
                catState.healthEnabled = enabled
                if not enabled then
                    for _, data in pairs(catState.objects) do
                        if data.healthBarBg then
                            pcall(data.healthBarBg.Remove, data.healthBarBg)
                            data.healthBarBg = nil
                        end
                        if data.healthBarFg then
                            pcall(data.healthBarFg.Remove, data.healthBarFg)
                            data.healthBarFg = nil
                        end
                    end
                end
            end,
        })
    end

    if catDef.Supports.weapon then
    ESPTab:CreateToggle({
        Name         = "Show Weapon",
        CurrentValue = catState.weaponEnabled or false,
        Flag         = "ESP_" .. cname .. "_Weapon",
        Callback     = function(enabled)
            catState.weaponEnabled = enabled
            if not enabled then
                for _, data in pairs(catState.objects) do
                    if data.weaponText then
                        pcall(data.weaponText.Remove, data.weaponText)
                        data.weaponText = nil
                    end
                end
            end
        end,
    })
    end

end

RunService.RenderStepped:Connect(function()
    local cameraPos = camera.CFrame.Position
    local localHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    for _, catDef in ipairs(categories) do
        local cname      = catDef.Name
        local fetchFunc  = catDef.FetchFunction
        local catState   = states[cname]
        local color      = catState.Color
        local tracerOn   = catState.tracerEnabled
        local nameOn     = catState.nameEnabled
        local boxOn      = catState.boxEnabled
        local healthOn   = catState.healthEnabled
        local weaponOn   = catState.weaponEnabled

        local currentList = fetchFunc()
        local seenThisFrame = {}

        for _, obj in ipairs(currentList) do
            local objName = obj.Name
            if type(objName) ~= "string" or objName == "" or objName == player.Name then
            else
                local rootModel = nil
                if cname == "Players" then
                    if obj and obj.Character and obj.Character.Parent then
                        local hrp = obj.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and hrp ~= localHRP then
                            rootModel = obj.Character
                        end
                    end
                else
                    if obj and obj.Parent then
                        rootModel = obj
                    end
                end

                if rootModel then
                    local rootPart = findPart(rootModel)
                    if rootPart and rootPart:IsDescendantOf(workspace) and (rootPart.Position - cameraPos).Magnitude <= 10000 then
                        local data = catState.objects[obj]
                        if not data then
                            data = {
                                tracerLine  = nil,
                                nameText    = nil,
                                boxLines    = nil,
                                healthBarBg = nil,
                                healthBarFg = nil,
                            }
                            catState.objects[obj] = data
                        end

                        local screenPos, onScreen = worldToScreenPos(rootPart.Position)

                        -- ===== TRACERS =====
                        if tracerOn then
                            if not data.tracerLine then
                                local line = Drawing.new("Line")
                                line.Thickness    = 1
                                line.Transparency = 1
                                line.Color        = color
                                line.ZIndex       = 2
                                data.tracerLine   = line
                            end
                            if onScreen then
                                data.tracerLine.Visible = true
                                local origin = getGlobalTracerOrigin()
                                data.tracerLine.From  = origin
                                data.tracerLine.To    = screenPos
                                data.tracerLine.Color = color
                            else
                                data.tracerLine.Visible = false
                            end
                        elseif data.tracerLine then
                            pcall(data.tracerLine.Remove, data.tracerLine)
                            data.tracerLine = nil
                        end

                        -- ===== NAMES =====
                        if nameOn then
                            if not data.nameText then
                                local txt = Drawing.new("Text")
                                txt.Size         = TextSize
                                txt.Center       = true
                                txt.Outline      = true
                                txt.Color        = color
                                txt.Transparency = 1
                                txt.Font         = 3 -- SourceSansBold
                                txt.ZIndex       = 2
                                data.nameText    = txt
                            end
                            if onScreen then
                                data.nameText.Visible = true
                                data.nameText.Text     = objName
                                data.nameText.Position = Vector2.new(
                                    screenPos.X,
                                    screenPos.Y - (TextSize + 4)
                                )
                                data.nameText.Color    = color
                            else
                                data.nameText.Visible = false
                            end
                        elseif data.nameText then
                            pcall(data.nameText.Remove, data.nameText)
                            data.nameText = nil
                        end

                                                -- ===== WEAPON (above name) =====
                        if weaponOn and cname == "Players" then
                            if not data.weaponText then
                                local txt = Drawing.new("Text")
                                txt.Size         = TextSize
                                txt.Center       = true
                                txt.Outline      = true
                                txt.Color        = color
                                txt.Transparency = 1
                                txt.Font         = 3 -- SourceSansBold
                                txt.ZIndex       = 2
                                data.weaponText  = txt
                            end
                            if onScreen then
                                -- Find weapon model in workspace.Characters.<PlayerName>.<Model>
                                local weaponName = "Default"
                                local CharactersFolder = workspace:FindFirstChild("Characters")
                                if CharactersFolder then
                                    local charModel = CharactersFolder:FindFirstChild(objName)
                                    if charModel then
                                        local found = {}
                                        for _, child in ipairs(charModel:GetChildren()) do
                                            if child:IsA("Model") and child.Name:sub(-5) == "Model" then
                                                table.insert(found, child)
                                            end
                                        end
                                        if #found == 1 then
                                            weaponName = found[1].Name:sub(1, #found[1].Name-5)
                                        end
                                    end
                                end
                                data.weaponText.Visible  = true
                                data.weaponText.Text     = weaponName
                                data.weaponText.Position = Vector2.new(
                                    screenPos.X,
                                    screenPos.Y - (TextSize * 2 + 8) -- above name
                                )
                                data.weaponText.Color    = color
                            else
                                data.weaponText.Visible = false
                            end
                        elseif data.weaponText then
                            pcall(data.weaponText.Remove, data.weaponText)
                            data.weaponText = nil
                        end

                        -- ===== BOXES =====
                        if boxOn then
                            if not data.boxLines then
                                data.boxLines = {}
                                for i = 1, 4 do
                                    local ln = Drawing.new("Line")
                                    ln.Thickness    = 1
                                    ln.Transparency = 1
                                    ln.Color        = color
                                    ln.ZIndex       = 2
                                    data.boxLines[i] = ln
                                end
                            end

                            local topLeft, bottomRight = getBounding2DCorners(rootModel)
                            if topLeft and bottomRight then
                                local minX, minY = topLeft.X, topLeft.Y
                                local maxX, maxY = bottomRight.X, bottomRight.Y

                                data.boxLines[1].From = Vector2.new(minX, minY)
                                data.boxLines[1].To   = Vector2.new(maxX, minY)
                                data.boxLines[2].From = Vector2.new(maxX, minY)
                                data.boxLines[2].To   = Vector2.new(maxX, maxY)
                                data.boxLines[3].From = Vector2.new(maxX, maxY)
                                data.boxLines[3].To   = Vector2.new(minX, maxY)
                                data.boxLines[4].From = Vector2.new(minX, maxY)
                                data.boxLines[4].To   = Vector2.new(minX, minY)

                                for i = 1, 4 do
                                    data.boxLines[i].Visible = true
                                    data.boxLines[i].Color   = color
                                end
                            else
                                for i = 1, 4 do
                                    data.boxLines[i].Visible = false
                                end
                            end
                        elseif data.boxLines then
                            for i = 1, 4 do
                                pcall(data.boxLines[i].Remove, data.boxLines[i])
                            end
                            data.boxLines = nil
                        end

                        -- ===== HEALTH BARS =====
                        if healthOn then
                            local human = nil
                            if cname == "Players" then
                                human = rootModel:FindFirstChildWhichIsA("Humanoid")
                            else
                                if rootModel:IsA("Model") then
                                    human = rootModel:FindFirstChildWhichIsA("Humanoid")
                                elseif rootModel:IsA("BasePart") then
                                    local parentModel = rootModel.Parent
                                    if parentModel and parentModel:IsA("Model") then
                                        human = parentModel:FindFirstChildWhichIsA("Humanoid")
                                    end
                                end
                            end

                            if human and human.Health > 0 then
                                local healthPct = math.clamp(human.Health / human.MaxHealth, 0, 1)

                                local topLeft, bottomRight = getBounding2DCorners(rootModel)
                                if topLeft and bottomRight then
                                    local minX, minY = topLeft.X, topLeft.Y
                                    local maxY       = bottomRight.Y
                                    local boxHeight  = maxY - minY

                                    local barColor
                                    if healthPct > 0.5 then
                                        barColor = Color3.new(0, 1, 0)
                                    elseif healthPct > 0.2 then
                                        barColor = Color3.new(1, 1, 0)
                                    else
                                        barColor = Color3.new(1, 0, 0)
                                    end

                                    if not data.healthBarBg then
                                        local bg = Drawing.new("Square")
                                        bg.Thickness    = 1
                                        bg.Filled       = false
                                        bg.Color        = Color3.new(0, 0, 0)
                                        bg.Transparency = 1
                                        bg.ZIndex       = 2
                                        data.healthBarBg = bg
                                    end
                                    if not data.healthBarFg then
                                        local fg = Drawing.new("Square")
                                        fg.Thickness    = 0
                                        fg.Filled       = true
                                        fg.Color        = barColor
                                        fg.Transparency = 1
                                        fg.ZIndex       = 2
                                        data.healthBarFg = fg
                                    end

                                    local barWidth  = HealthBarThickness
                                    local barX      = minX - barWidth - 2
                                    local barY      = minY
                                    local barHeight = boxHeight

                                    data.healthBarBg.Position = Vector2.new(barX, barY)
                                    data.healthBarBg.Size     = Vector2.new(barWidth, barHeight)
                                    data.healthBarBg.Visible  = true

                                    local fillHeight = barHeight * healthPct
                                    local fillY      = barY + (barHeight - fillHeight)
                                    data.healthBarFg.Position = Vector2.new(barX + 1, fillY)
                                    data.healthBarFg.Size     = Vector2.new(barWidth - 2, fillHeight)
                                    data.healthBarFg.Visible  = true

                                    data.healthBarBg.Color = Color3.new(0, 0, 0)
                                    data.healthBarFg.Color = barColor
                                else
                                    if data.healthBarBg then data.healthBarBg.Visible = false end
                                    if data.healthBarFg then data.healthBarFg.Visible = false end
                                end
                            else
                                if data.healthBarBg then data.healthBarBg.Visible = false end
                                if data.healthBarFg then data.healthBarFg.Visible = false end
                            end
                        elseif data.healthBarBg or data.healthBarFg then
                            if data.healthBarBg then
                                pcall(data.healthBarBg.Remove, data.healthBarBg)
                                data.healthBarBg = nil
                            end
                            if data.healthBarFg then
                                pcall(data.healthBarFg.Remove, data.healthBarFg)
                                data.healthBarFg = nil
                            end
                        end

                        seenThisFrame[obj] = true
                    end
                end
            end
        end

        for existingObj, data in pairs(catState.objects) do
            if not seenThisFrame[existingObj] then
                if data.tracerLine then
                    pcall(data.tracerLine.Remove, data.tracerLine)
                end
                if data.nameText then
                    pcall(data.nameText.Remove, data.nameText)
                end
                if data.boxLines then
                    for _, ln in ipairs(data.boxLines) do
                        pcall(ln.Remove, ln)
                    end
                end
                if data.healthBarBg then
                    pcall(data.healthBarBg.Remove, data.healthBarBg)
                end
                if data.healthBarFg then
                    pcall(data.healthBarFg.Remove, data.healthBarFg)
                end
                catState.objects[existingObj] = nil
            end
        end
    end
end)



-- ################## --
-- #### MISC TAB #### --
-- ################## --

-- #### SERVER PANEL #### --
local PlaceId = game.PlaceId
local JobId   = game.JobId
local player  = Players.LocalPlayer

MiscTab:CreateSection("Server Panel")

MiscTab:CreateButton({
    Name     = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
    end,
})

MiscTab:CreateButton({
    Name     = "Join Random Server",
    Callback = function()
        local success, response = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. PlaceId ..
                    "/servers/Public?sortOrder=Asc&limit=100"
                )
            )
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, player)
                    return
                end
            end
        end

        Rayfield:Notify({
            Title   = "Server Join Failed",
            Content = "Couldn't find a different server.",
            Duration = 5,
            Image    = "x"
        })
    end,
})

MiscTab:CreateButton({
    Name     = "Join Lowest Server",
    Callback = function()
        local success, response = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. PlaceId ..
                    "/servers/Public?sortOrder=Asc&limit=100"
                )
            )
        end)

        if success and response and response.data then
            for _, server in ipairs(response.data) do
                if server.playing < server.maxPlayers and server.id ~= JobId then
                    TeleportService:TeleportToPlaceInstance(PlaceId, server.id, player)
                    return
                end
            end
        end

        Rayfield:Notify({
            Title    = "Server Join Failed",
            Content  = "No suitable server found with fewer players.",
            Duration = 5,
            Image    = "x"
        })
    end,
})

MiscTab:CreateButton({
    Name = "Copy Join Script",
    Callback = function()
        local snippet = "local TeleportService = game:GetService('TeleportService')\n" ..
                        "TeleportService:TeleportToPlaceInstance(" .. PlaceId .. ", '" .. JobId .. "', game.Players.LocalPlayer)\n"
        if setclipboard then
            setclipboard(snippet)
            Rayfield:Notify({
                Title   = "Copied!",
                Content = "Run this in an executor to join the current server.",
                Duration = 4,
                Image    = "check"
            })
        else
            Rayfield:Notify({
                Title   = "Clipboard Error",
                Content = "setclipboard() not available.",
                Duration = 4,
                Image    = "x"
            })
        end
    end,
})

-- #### THEMES #### --
MiscTab:CreateSection("Theme")

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

-- #### AMBIENT #### --
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

-- #### CUSTOM TIME #### --
local timeLockEnabled = false
local timeLockConn    = nil
local timeValue = Lighting.ClockTime

MiscTab:CreateToggle({
    Name         = "Custom Time of Day",
    CurrentValue = false,
    Flag         = "LockTimeOfDayToggle",
    Callback     = function(enabled)
        timeLockEnabled = enabled
        if enabled then
        Rayfield:Notify({
            Title = "Time of Day Locked",
            Content = "The daylight cycle is frozen",
            Duration = 5,
            Image = "timer"
        })
            Lighting.ClockTime = timeValue
            timeLockConn = RunService.RenderStepped:Connect(function()
                Lighting.ClockTime = timeValue
            end)
        else
        Rayfield:Notify({
            Title = "Time of Day Unlocked",
            Content = "The daylight cycle will resume",
            Duration = 5,
            Image = "timer"
        })
            if timeLockConn then
                timeLockConn:Disconnect()
                timeLockConn = nil
            end
        end
    end,
})

MiscTab:CreateSlider({
    Name         = "Time of Day",
    Range        = { 0, 24 },
    Increment    = 1,
    Suffix       = "h",
    CurrentValue = timeValue,
    Flag         = "TimeOfDaySlider",
    Callback     = function(val)
        timeValue = val
        if timeLockEnabled then
            Lighting.ClockTime = timeValue
        end
    end,
})
