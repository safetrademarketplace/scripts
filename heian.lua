-- #### UI SETUP #### --
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local GUI = Mercury:Create{
    Name = "Mercury",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "Heian | Cerberus"
}

local MainTab = GUI:Tab{
	Name = "Main",
	Icon = "rbxassetid://13060262529"
}

local PlayerTab = GUI:Tab{
	Name = "Player",
	Icon = "rbxassetid://117259180607823"
}

local ESPTab = GUI:Tab{
	Name = "ESP",
	Icon = "rbxassetid://6523858394"
}

-- #### SERVICES AND REFERENCES #### --
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local LocalPlayer= Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local UserInputService  = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local mouse    = player:GetMouse()

-- // TWEENING HELPER FUNCTION // --
local speed = 300
local offsetY = 0
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
        task.wait(0.01)
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

        if distance < 0.1 then
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
    speed = flightSpeed or 60
    offsetY = offset or 8
    targetPosition = pos
    arrivalTargetPosition = pos
    flyingEnabled = true
    startFlight(hover)
end


-- ################## --
-- #### MAIN TAB #### --
-- ################## --

-- #### TELEPORTS #### --
local function keyList(tbl)
    local out = {}
    for k in pairs(tbl) do out[#out+1] = k end
    table.sort(out)
    return out
end

local function getNpcTPs()
    local out  = {}
    local root = workspace:FindFirstChild("NPCs")
    if not root then return out end
    for _, m in ipairs(root:GetChildren()) do
        if m:IsA("Model") then
            local pos = (m.PrimaryPart and m.PrimaryPart.Position)
                        or m:GetPivot().Position
            out[m.Name] = pos
        end
    end
    return out
end

local npcTbl      = getNpcTPs()
local npcNames    = keyList(npcTbl)
local selectedNpc = npcNames[1] or "-"

local npcDropdown = MainTab:Dropdown{
    Name         = "Select NPC",
    StartingText = selectedNpc,
    Items        = npcNames,
    Callback     = function(choice)
        selectedNpc = choice
    end,
}

MainTab:Button{
    Name     = "TP to NPC (slow)",
    Callback = function()
        local pos = npcTbl[selectedNpc]
        if not pos then
            GUI:Notification{
                Title    = "Teleport Failed",
                Text     = "NPC not found!",
                Duration = 3,
            }
            return
        end

        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")
        local curr = hrp.Position

        setFlightTarget(curr - Vector3.new(0, 60, 0), 40, false, 0)
        wait(1)

        setFlightTarget(pos - Vector3.new(0, 40, 0), 65, false, 0)
        repeat RunService.Heartbeat:Wait() until not flyingEnabled

        setFlightTarget(pos + Vector3.new(0, 5, 0), 40, false, 2)
        wait(1)

        GUI:Notification{
            Title    = "Teleported",
            Text     = "Arrived at " .. selectedNpc,
            Duration = 2,
        }
    end,
}

MainTab:Button{
    Name     = "TP to Closest Quest Board (slow)",
    Callback = function()
        local root = workspace:FindFirstChild("JobBoards") 
                     and workspace.JobBoards:FindFirstChild("BountyBoards")

        local char = Players.LocalPlayer.Character 
                     or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp  = char:WaitForChild("HumanoidRootPart")
        local curr = hrp.Position

        local closest, closestDist
        for _, m in ipairs(root:GetChildren()) do
            if m:IsA("Model") then
                local pivot = (m.PrimaryPart and m.PrimaryPart.Position)
                              or m:GetPivot().Position
                local d = (curr - pivot).Magnitude
                if not closest or d < closestDist then
                    closest     = m
                    closestDist = d
                end
            end
        end

        if not closest then
            GUI:Notification{
                Title    = "Teleport Failed",
                Text     = "No quest boards found!",
                Duration = 3,
            }
            return
        end
        local targetPos = (closest.PrimaryPart and closest.PrimaryPart.Position)
                          or closest:GetPivot().Position

        setFlightTarget(curr - Vector3.new(0, 60, 0), 40, false, 0)
        wait(1)

        setFlightTarget(targetPos - Vector3.new(0, 40, 0), 65, false, 0)
        repeat RunService.Heartbeat:Wait() until not flyingEnabled

        setFlightTarget(targetPos + Vector3.new(0, 5, 0), 40, false, 2)
        wait(1)

        GUI:Notification{
            Title    = "Teleported",
            Text     = "Arrived at closest quest board",
            Duration = 2,
        }
    end,
}

MainTab:Button{
    Name     = "Show Bounty Targets",
    Callback = function()
        local jbRoot = workspace:FindFirstChild("JobBoards")
        local bbRoot = jbRoot:FindFirstChild("BountyBoards")

        local texts = {}
        for _, boardModel in ipairs(bbRoot:GetChildren()) do
            if boardModel:IsA("Model") then
                local boardFolder = boardModel:FindFirstChild("Board")
                if boardFolder then
                    for _, placeholder in ipairs(boardFolder:GetChildren()) do
                        if placeholder:IsA("BasePart") then
                            local bountyFolder = placeholder:FindFirstChild("Bounty")
                            if bountyFolder then
                                for _, gui in ipairs(bountyFolder:GetChildren()) do
                                    if gui:IsA("SurfaceGui") then
                                        local jobFrame = gui:FindFirstChild("Job")
                                        if jobFrame then
                                            local targetLabel = jobFrame:FindFirstChild("Target")
                                            if targetLabel and targetLabel:IsA("TextLabel") then
                                                table.insert(texts, targetLabel.Text)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local content = #texts > 0 and table.concat(texts, ", ") or "No targets found"
        GUI:Notification{
            Title    = "Targets",
            Text     = content,
            Duration = 5,
        }
    end,
}

-- #################### --
-- #### PLAYER TAB #### --
-- #################### --

-- #### FULLBRIGHT TOGGLE ####
local fullbrightEnabled = false
local originalSettings  = {}

local function storeOriginalSettings()
    originalSettings = {
        Brightness     = Lighting.Brightness,
        GlobalShadows  = Lighting.GlobalShadows,
        Ambient        = Lighting.Ambient,
    }
end

local function setFullbright(enabled)
    fullbrightEnabled = enabled
    if enabled then
        storeOriginalSettings()
    else
        if next(originalSettings) then
            Lighting.Brightness    = originalSettings.Brightness
            Lighting.GlobalShadows = originalSettings.GlobalShadows
            Lighting.Ambient       = originalSettings.Ambient
        end
    end
end

RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness     = 2
        Lighting.GlobalShadows  = false
        Lighting.Ambient        = Color3.new(1, 1, 1)
    end
end)

PlayerTab:Toggle{
    Name          = "Fullbright",
    StartingState = false,
    Callback      = function(state)
        setFullbright(state)
    end,
}

-- #### NO CLIP TOGGLE ####
local noclipEnabled = false
local noclipConn    = nil

local function setCharacterCollisions(state)
    local char = Players.LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = state
        end
    end
end

local function toggleNoClip(on)
    noclipEnabled = on
    if on then
        if noclipConn then noclipConn:Disconnect() end
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

Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if noclipEnabled then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            setCharacterCollisions(false)
        end)
    end
end)

-- #### NO FOG #### --
local noFogEnabled       = false
local originalFogEnd     = Lighting.FogEnd
local originalFogStart   = Lighting.FogStart
local originalFogColor   = Lighting.FogColor
local removedWeatherItems = {}
local childAddedConn     = nil

local WEATHER_CLASSES = {
    Atmosphere    = true,
    BloomEffect   = true,
    SunRaysEffect = true,
    Sky           = true,
}

local function isWeatherObject(inst)
    return WEATHER_CLASSES[inst.ClassName] == true
end

local function removeExistingWeather()
    for _, child in ipairs(Lighting:GetChildren()) do
        if isWeatherObject(child) then
            table.insert(removedWeatherItems, child)
            child.Parent = nil
        end
    end
end

local function onChildAdded(child)
    if isWeatherObject(child) then
        table.insert(removedWeatherItems, child)
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
        if inst and not inst.Parent then
            inst.Parent = Lighting
        end
    end
    removedWeatherItems = {}
end

PlayerTab:Toggle{
    Name          = "No Fog (use with fullbright)",
    StartingState = false,
    Callback      = function(state)
        if state then
            enableNoFog()
        else
            restoreFogAndWeather()
        end
    end,
}

PlayerTab:Toggle{
    Name          = "NoClip",
    StartingState = false,
    Callback      = function(state)
        toggleNoClip(state)
    end,
}

-- #### V + RIGHT-CLICK TP TOGGLE ####
local vDown        = false
local vDownConn    = nil
local vUpConn      = nil
local rightConn    = nil

local function teleportToCursor()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = mouse.Hit.Position
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, hrp.Size.Y/2 + 1, 0))
end

local function onRightClick()
    if vDown then
        teleportToCursor()
    end
end

local function onInputBegan(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        vDown = true
    end
end

local function onInputEnded(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.V then
        vDown = false
    end
end

PlayerTab:Toggle{
    Name          = "V + Right-Click TP",
    StartingState = false,
    Callback      = function(enabled)
        if enabled then
            vDownConn = UserInputService.InputBegan:Connect(onInputBegan)
            vUpConn   = UserInputService.InputEnded:Connect(onInputEnded)
            rightConn = mouse.Button2Down:Connect(onRightClick)
        else
            if vDownConn then vDownConn:Disconnect() vDownConn = nil end
            if vUpConn   then vUpConn:Disconnect()   vUpConn   = nil end
            if rightConn then rightConn:Disconnect() rightConn = nil end
            vDown = false
        end
    end,
}

-- #### FREECAM SETUP (place near the top of your script) ####
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local player            = Players.LocalPlayer
local camera            = workspace.CurrentCamera

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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        flyKeyDown[input.KeyCode] = false
    end
end)

-- #### FREECAM ####
PlayerTab:Toggle{
    Name          = "Freecam",
    StartingState = false,
    Callback      = function(state)
        flying = state

        if state then
            if humanoidRootPart then
                humanoidRootPart.Anchored = true
            end

            camDummy.CFrame    = camera.CFrame
            camera.CameraType  = Enum.CameraType.Custom
            camera.CameraSubject = camDummy

            camConn = RunService.RenderStepped:Connect(function(dt)
                local moveVec = Vector3.zero
                local cf = camera.CFrame
                if flyKeyDown[Enum.KeyCode.W] then
                    moveVec += cf.LookVector
                end
                if flyKeyDown[Enum.KeyCode.S] then
                    moveVec -= cf.LookVector
                end
                if flyKeyDown[Enum.KeyCode.A] then
                    moveVec -= cf.RightVector
                end
                if flyKeyDown[Enum.KeyCode.D] then
                    moveVec += cf.RightVector
                end
                if flyKeyDown[Enum.KeyCode.Space] then
                    moveVec += cf.UpVector
                end
                if flyKeyDown[Enum.KeyCode.LeftShift] then
                    moveVec -= cf.UpVector
                end
                if moveVec.Magnitude > 0 then
                    camDummy.CFrame = camDummy.CFrame + moveVec.Unit * flySpeed * dt
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
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    camera.CameraSubject = hrp
                end
            end
            if humanoidRootPart then
                humanoidRootPart.Anchored = false
            end
        end
    end,
}

-- #### PERFORMANCE MODE #### --
local original = {
    QualityLevel      = settings().Rendering.QualityLevel,
    GlobalShadows     = Lighting.GlobalShadows,
    Ambient           = Lighting.Ambient,
    Brightness        = Lighting.Brightness,
    FogEnd            = Lighting.FogEnd,
    FogStart          = Lighting.FogStart,
    EffectsEnabled    = {},
    WaterWaveSize     = nil,
    WaterReflectance  = nil,
    WaterTransparency = nil,
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

PlayerTab:Toggle{
    Name          = "Performance Mode",
    StartingState = false,
    Callback      = function(enabled)
        performanceEnabled = enabled

        if enabled then
            -- low‐end settings
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Ambient       = Color3.new(0.3, 0.3, 0.3)
            Lighting.Brightness    = 1
            Lighting.FogEnd        = 1e10
            Lighting.FogStart      = 1e10

            -- disable all cached effects
            for inst, wasEnabled in pairs(original.EffectsEnabled) do
                if inst and inst.Parent then
                    inst.Enabled = false
                end
            end

            -- water tweaks
            if terrain then
                terrain.WaterWaveSize     = 0
                terrain.WaterReflectance  = 0
                terrain.WaterTransparency = 1
            end

            -- kill any particles/trails in the world
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end

        else
            -- restore originals
            settings().Rendering.QualityLevel = original.QualityLevel
            Lighting.GlobalShadows = original.GlobalShadows
            Lighting.Ambient       = original.Ambient
            Lighting.Brightness    = original.Brightness
            Lighting.FogEnd        = original.FogEnd
            Lighting.FogStart      = original.FogStart

            -- restore effects
            for inst, wasEnabled in pairs(original.EffectsEnabled) do
                if inst and inst.Parent then
                    inst.Enabled = wasEnabled
                end
            end

            -- restore water
            if terrain then
                terrain.WaterWaveSize     = original.WaterWaveSize
                terrain.WaterReflectance  = original.WaterReflectance
                terrain.WaterTransparency = original.WaterTransparency
            end

            -- re-enable particles/trails
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = true
                end
            end
        end
    end,
}

-- #### RESET BUTTON #### --
PlayerTab:Button{
    Name     = "Reset",
    Callback = function()
        local player   = Players.LocalPlayer
        local char     = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end,
}

-- ################# --
-- #### ESP TAB #### --
-- ################# --

local IngredientsFolder = workspace:WaitForChild("Ingredients")
local MobFolder       = workspace:WaitForChild("Live")

local ipairs, pairs      = ipairs, pairs
local math_clamp         = math.clamp
local math_floor         = math.floor
local string_format      = string.format

-- ESP settings
local ESPConfig = { TextSize=14, TracerOrigin="Bottom", Range=200 }
local espColor   = Color3.new(1,0,0)

local function getTracerOrigin()
    local w,h = Camera.ViewportSize.X, Camera.ViewportSize.Y
    if ESPConfig.TracerOrigin == "Top"    then return Vector2.new(w/2, 0) end
    if ESPConfig.TracerOrigin == "Center" then return Vector2.new(w/2, h/2) end
    return Vector2.new(w/2, h)
end

local function newDrawSet()
    local box      = Drawing.new("Square")
    local tracer   = Drawing.new("Line")
    local nameTxt  = Drawing.new("Text")
    local healthTxt= Drawing.new("Text")
    local distTxt  = Drawing.new("Text")

    box.Thickness, box.Filled, box.Transparency          = 2, false, 1
    tracer.Thickness, tracer.Transparency                = 1, 1
    for _, txt in ipairs({nameTxt, healthTxt, distTxt}) do
        txt.Center, txt.Outline, txt.Transparency        = true, true, 1
        txt.Size                                       = ESPConfig.TextSize
    end

    return { box=box, tracer=tracer, name=nameTxt, health=healthTxt, distance=distTxt }
end

local ESPGroups = {
    players = {
        enabled  = false,
        features = { Box=false, Name=false, Health=false, Tracer=false, Distance=false },
        items    = {},
        listFn   = function() return Players:GetPlayers() end,
        validFn  = function(p) return p ~= Players.LocalPlayer end,
        posFn    = function(p)
            local c = p.Character
            return (c and c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.Position)
        end,
        colorFn  = function() return espColor end,
        nameFn   = function(p) return p.Name end,
        healthFn = function(p)
            local h = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            return h and h.Health or 0
        end,
        init = function(self)
            for _, p in ipairs(self.listFn()) do
                if self.validFn(p) then
                    self.items[p] = newDrawSet()
                end
            end
            Players.PlayerAdded:Connect(function(p)
                if self.validFn(p) then self.items[p] = newDrawSet() end
            end)
            Players.PlayerRemoving:Connect(function(p)
                local ds = self.items[p]
                if ds then for _, d in pairs(ds) do d:Remove() end end
                self.items[p] = nil
            end)
        end,
    },

    ingredients = {
        enabled  = false,
        features = { Box=false, Name=false, Tracer=false, Distance=false },
        items    = {},
        listFn   = function() return IngredientsFolder:GetChildren() end,
        validFn  = function(o) return o:IsA("Model") or o:IsA("BasePart") end,
        posFn    = function(o)
            if o:IsA("Model") then
                return (o.PrimaryPart or o:GetPivot()).Position
            else
                return o.Position
            end
        end,
        colorFn  = function(o)
            if o:IsA("Model") then
                local ore = o:FindFirstChild("OreBase")
                if ore then return ore.BrickColor.Color end
            elseif o:IsA("BasePart") then
                return o.BrickColor.Color
            end
            return Color3.new(1,1,1)
        end,
        nameFn   = function(o) return o.Name end,
        init = function(self)
            for _, o in ipairs(self.listFn()) do
                self.items[o] = newDrawSet()
            end
            IngredientsFolder.ChildAdded:Connect(function(o)
                self.items[o] = newDrawSet()
            end)
            IngredientsFolder.ChildRemoved:Connect(function(o)
                local ds = self.items[o]
                if ds then for _, d in pairs(ds) do d:Remove() end end
                self.items[o] = nil
            end)
        end,
    },

    mobs = {
        enabled  = false,
        features = { Box=false, Name=false, Health=false, Tracer=false, Distance=false },
        items    = {},
        listFn   = function() return MobFolder:GetChildren() end,
        validFn  = function(m) return m:IsA("Model") and not Players:GetPlayerFromCharacter(m) end,
        posFn    = function(m) return (m.PrimaryPart or m:GetPivot()).Position end,
        colorFn  = function(m)
            local bc = m:FindFirstChild("Body Colors")
            if bc then return bc.TorsoColor.Color end
            return espColor
        end,
        nameFn   = function(m) return m.Name end,
        healthFn = function(m)
            local h = m:FindFirstChildOfClass("Humanoid")
            return h and h.Health or 0
        end,
        init = function(self)
            for _, m in ipairs(self.listFn()) do
                if self.validFn(m) then self.items[m] = newDrawSet() end
            end
            MobFolder.ChildAdded:Connect(function(m)
                if self.validFn(m) then self.items[m] = newDrawSet() end
            end)
            MobFolder.ChildRemoved:Connect(function(m)
                local ds = self.items[m]
                if ds then for _, d in pairs(ds) do d:Remove() end end
                self.items[m] = nil
            end)
        end,
    },
}

ESPGroups.players:init()
ESPGroups.ingredients:init()
ESPGroups.mobs:init()

RunService.RenderStepped:Connect(function()
    local origin2D = getTracerOrigin()
    local camPos3D = Camera.CFrame.Position

    for _, group in pairs(ESPGroups) do
        if not group.enabled then continue end

        local feats, items, posFn, colorFn = group.features, group.items, group.posFn, group.colorFn
        local nameFn, healthFn, range, textSize = group.nameFn, group.healthFn, ESPConfig.Range, ESPConfig.TextSize

        for obj, ds in pairs(items) do
            local wp = posFn(obj)
            if not wp then
                ds.box.Visible = false
            else
                local sp, onScreen = Camera:WorldToViewportPoint(wp)
                if onScreen then
                    local dist = (camPos3D - wp).Magnitude
                    if dist <= range then
                        local size = math_clamp(2000/sp.Z, 30, 200)
                        local lx, ty = sp.X - size/2, sp.Y - size/2
                        local col = colorFn(obj)

                        -- box
                        ds.box.Visible   = feats.Box
                        ds.box.Color     = col
                        ds.box.Position  = Vector2.new(lx, ty)
                        ds.box.Size      = Vector2.new(size, size)

                        -- tracer
                        ds.tracer.Visible = feats.Tracer
                        ds.tracer.Color   = col
                        ds.tracer.From    = origin2D
                        ds.tracer.To      = Vector2.new(sp.X, sp.Y)

                        -- name
                        ds.name.Visible   = feats.Name
                        ds.name.Color     = col
                        ds.name.Text      = nameFn(obj)
                        ds.name.Position  = Vector2.new(sp.X, ty - textSize)
                        ds.name.Size      = textSize

if feats.Health and healthFn then
    ds.health.Visible   = true
    ds.health.Color     = Color3.new(0, 1, 0)           
    ds.health.Text      = tostring(math_floor(healthFn(obj)))
    ds.health.Position  = Vector2.new(sp.X, ty + size + 2)
    ds.health.Size      = textSize
else
    ds.health.Visible = false
end

ds.distance.Visible   = feats.Distance
ds.distance.Color     = Color3.new(1, 1, 0)            
ds.distance.Text      = string_format("%.0f", dist).."m"
ds.distance.Position  = Vector2.new(sp.X, ty + size + 18)
ds.distance.Size      = textSize

                        continue
                    end
                end
            end

            ds.box.Visible = false
            ds.tracer.Visible = false
            ds.name.Visible = false
            ds.health.Visible = false
            ds.distance.Visible = false
        end
    end
end)

ESPTab:Slider{
    Name="Text Size", Min=10, Max=30, Default=ESPConfig.TextSize,
    Callback=function(v) ESPConfig.TextSize = v end,
}
ESPTab:Dropdown{
    Name="Tracer Origin", StartingText=ESPConfig.TracerOrigin,
    Items={"Top","Center","Bottom"},
    Callback=function(v) ESPConfig.TracerOrigin = v end,
}
ESPTab:Slider{
    Name="ESP Range", Min=0, Max=5000, Default=ESPConfig.Range,
    Callback=function(v) ESPConfig.Range = v end,
}

for name, grp in pairs(ESPGroups) do
    local title = name:sub(1,1):upper()..name:sub(2)
    ESPTab:Toggle{
        Name=title.." ESP", StartingState=false,
        Callback=function(on)
            grp.enabled = on
            if not on then
                for _, ds in pairs(grp.items) do
                    for _, d in pairs(ds) do d.Visible = false end
                end
            end
        end,
    }
    ESPTab:Dropdown{
        Name=title.." Features",
        StartingText="Click to toggle…",
        Items=(name=="ingredients") and { "Box", "Name", "Tracer", "Distance" }
                                   or { "Box", "Name", "Health", "Tracer", "Distance" },
        Callback=function(opt) grp.features[opt] = not grp.features[opt] end,
    }
end

ESPTab:Credit{
	Name = "ESP Info",
	Description = "Optimised!",
}

MainTab:Credit{
	Name = "BETA Script - Please submit suggestions and bug reports",
	Description = "Limited features on release due to anti-cheat. Script will be receiving regular updates.",
}
