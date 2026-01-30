-- ################## --
-- #### UI SETUP #### --
-- ################## --

-- ================== --
-- #### UI Setup #### --
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
	Title = "Cerberus",
	Footer = "Type://Soul",
	Icon = 136497541793809,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
    Main       = Window:AddTab("Main", "gamepad-2"),
    Player     = Window:AddTab("Plr", "circle-user"),
    Auto       = Window:AddTab("Auto", "bot"),
    Combat     = Window:AddTab("Cmbt", "swords"),
    ESP        = Window:AddTab("ESP", "eye"),
    Misc       = Window:AddTab("Misc", "menu"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}
-- #### UI Setup #### --
-- ================== --

-- ================== --
-- #### Services #### --
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService         = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualInputManager  = game:GetService("VirtualInputManager")
-- #### Services #### --
-- ================== --

-- ==================== --
-- #### References #### --
local player = (function() local p=Players.LocalPlayer if p then return p end local t=os.clock() repeat task.wait() p=Players.LocalPlayer until p or (os.clock()-t)>0.2 return p end)()
local character = (function() if not player then return nil end local c=player.Character if c then return c end local t=os.clock() repeat task.wait() c=player.Character until c or (os.clock()-t)>0.2 return c end)()
local humanoidRootPart = (character and (character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 0.2))) or nil
local humanoid         = (character and (character:FindFirstChildOfClass("Humanoid")   or character:WaitForChild("Humanoid", 0.2))) or nil
local camera     = Workspace.CurrentCamera
local terrain = Workspace:FindFirstChildOfClass("Terrain", 0.2)
local entitiesFolder = Workspace:FindFirstChild("Entities", 0.2)
local PlayerGui = player:WaitForChild("PlayerGui", 0.2)

-- #### References #### --
-- =================== --

-- ########################### --
-- #### UNIVERSAL HELPERS #### --
-- ########################### --

-- ================= --
-- #### WEBHOOK #### --
local function sendToWebhook(webhookUrl, embedTitle, messageContent)
    local embed = {
        ["title"]       = embedTitle, 
        ["description"] = messageContent,
        ["color"]       = 0x50C9F1,
        ["timestamp"]   = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    local payload = {
        ["username"]   = "Cerberus Type://Soul",
        ["avatar_url"] = "https://media.discordapp.net/attachments/936776180026204241/1351880348728037517/Nox_hub_banner.png",
        ["embeds"]     = { embed }
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
-- #### WEBHOOK #### --
-- ================= --

-- =================== --
-- #### LOCATIONS #### --
local function getPosition(obj)
    if typeof(obj) == "table" then
        local results = {}
        for _, item in ipairs(obj) do
            local pos = getPosition(item) 
            if pos then
                table.insert(results, pos)
            end
        end
        return results
    end
    if not obj then return nil end
    if obj:IsA("BasePart") then
        return obj.Position
    end
    if obj:IsA("Model") then
        if obj.PrimaryPart then
            return obj.PrimaryPart.Position
        elseif obj:FindFirstChildWhichIsA("BasePart") then
            return obj:GetBoundingBox().Position 
        end
    end
    if obj:IsA("SelectionBox") or obj:IsA("SelectionSphere") or obj:IsA("SelectionPartLasso") then
        if obj.Adornee and obj.Adornee:IsA("BasePart") then
            return obj.Adornee.Position
        end
    end
    if obj:IsA("HandleAdornment") or obj:IsA("BillboardGui") then
        if obj.Adornee and obj.Adornee:IsA("BasePart") then
            return obj.Adornee.Position
        end
    end
    if obj:IsA("Attachment") then
        return obj.WorldPosition
    end
    if obj.GetBoundingBox then
        return obj:GetBoundingBox().Position
    end
    return nil 
end

local function getClosestPosition(reference, objects)
    local closestObj, closestPos
    local closestDist = math.huge

    for _, obj in ipairs(objects) do
        local pos = getPosition(obj)
        if pos then
            local dist = (pos - reference).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestObj = obj
                closestPos = pos
            end
        end
    end

    return closestObj, closestPos
end
-- #### LOCATIONS #### --
-- =================== --

-- ========================== --
-- #### CLICK DETECTORS #### --
local function fireAllClickDetectors(obj)
    if not obj then return end
    for _, descendant in ipairs(obj:GetDescendants()) do
        if descendant:IsA("ClickDetector") then
            fireclickdetector(descendant)
        end
    end
end
-- #### CLICK DETECTORS #### --
-- ========================== --

-- ========================== --
-- #### ENTITY CHECKS #### --
local PLACE_ALLOW_ZERO = 17047374266

local function isEntityAlive(inst)
	if not (inst and inst.Parent and inst:IsDescendantOf(Workspace)) then return false end
	local model = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
	if not model then return inst:IsA("BasePart") end
	if not model:FindFirstChildWhichIsA("BasePart") then return false end

	local rag = model:GetAttribute("CurrentlyRagdolled") == true
	local h
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then
		h = hum.Health
	else
		h = typeof(model:GetAttribute("Health")) == "number" and model:GetAttribute("Health") or nil
		if h == nil then
			local v = model:FindFirstChild("Health")
			if v and (v:IsA("NumberValue") or v:IsA("IntValue")) then h = v.Value end
		end
	end

	if h ~= nil then
		h = tonumber(h) or 0
		-- Special case: in this place, 0-HP entities are still valid targets
		if game.PlaceId == PLACE_ALLOW_ZERO and h == 0 then
			return true
		end
		return (h > 0) or (h <= 0 and rag)
	end
	-- If we can't read health, treat as valid (original behavior)
	return true
end

local function rebuildEntitiesList()
	local nameSet = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		nameSet[plr.Name] = true
		local dn = plr.DisplayName
		if typeof(dn) == "string" and dn ~= "" then nameSet[dn] = true end
	end

	local list = {}
	for _, child in ipairs(entitiesFolder:GetChildren()) do
		local n = string.lower(child.Name or "")
		if n:find("clone", 1, true) then
		elseif not Players:GetPlayerFromCharacter(child)
		and not nameSet[child.Name]
		and isEntityAlive(child) then
			table.insert(list, child)
		end
	end
	return list
end
-- #### ENTITY CHECKS #### --
-- ========================== --

-- ========================== --
-- #### FLIGHT AND HOVER #### --
local hoverConn
local targetConn
local hoverPos

local function setNoClip(character, state)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not state
		end
	end
end

local _ap, _ao, _attHRP, _attWorld

local function _ensureHoverConstraints()
	_attHRP = _attHRP or Instance.new("Attachment")
	_attHRP.Name = "_NoxHover_AttHRP"
	_attHRP.Parent = humanoidRootPart
	_attWorld = _attWorld or Instance.new("Attachment")
	_attWorld.Name = "_NoxHover_AttWorld"
	_attWorld.Parent = Workspace.Terrain
	_ap = _ap or Instance.new("AlignPosition")
	_ap.Name = "_NoxHover_AlignPosition"
	_ap.Mode = Enum.PositionAlignmentMode.TwoAttachment
	_ap.Attachment0 = _attHRP
	_ap.Attachment1 = _attWorld
	_ap.ApplyAtCenterOfMass = true
	_ap.Responsiveness = 200        
	_ap.MaxForce = math.huge
	_ap.ReactionForceEnabled = false
	_ap.RigidityEnabled = true
	_ap.Parent = humanoidRootPart

	_ao = _ao or Instance.new("AlignOrientation")
	_ao.Name = "_NoxHover_AlignOrientation"
	_ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
	_ao.Attachment0 = _attHRP
	_ao.Responsiveness = 200
	_ao.MaxTorque = math.huge
	_ao.ReactionTorqueEnabled = false
	_ao.RigidityEnabled = true
	_ao.Parent = humanoidRootPart
end

local function _destroyHoverConstraints()
	if _ap then _ap:Destroy() _ap = nil end
	if _ao then _ao:Destroy() _ao = nil end
	if _attHRP then _attHRP:Destroy() _attHRP = nil end
	if _attWorld then _attWorld:Destroy() _attWorld = nil end
end

local function stopHover()
	if hoverConn then hoverConn:Disconnect() hoverConn = nil end
	if targetConn then targetConn:Disconnect() targetConn = nil end
	hoverPos = nil
	_destroyHoverConstraints()
	if character then setNoClip(character, false) end
end

local function hover(targetPos)
	stopHover()
	setNoClip(character, true)
	hoverPos = (typeof(targetPos) == "Vector3") and targetPos or humanoidRootPart.Position
	_ensureHoverConstraints()
	_attWorld.WorldPosition = hoverPos
	humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
	humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
	local look = humanoidRootPart.CFrame.LookVector
	_ao.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + look)
	hoverConn = RunService.Heartbeat:Connect(function()
		if hoverPos then
			_attWorld.WorldPosition = hoverPos
		end
	end)
end

local function moveTo(targetPos, speed, hoverAtEnd, onArrive)
	stopHover()
	setNoClip(character, true)

	local start = humanoidRootPart.Position
	local dist = (targetPos - start).Magnitude
	if dist == 0 then
		if onArrive then onArrive() end
		return
	end

	local duration = dist / speed
	local elapsed = 0

	targetConn = RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local alpha = math.clamp(elapsed / duration, 0, 1)

		humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

        local pos = start:Lerp(targetPos, alpha)
		humanoidRootPart.CFrame = CFrame.new(pos, pos + humanoidRootPart.CFrame.LookVector)

		if alpha >= 1 then
			targetConn:Disconnect()
			targetConn = nil

			if hoverAtEnd then
				hover()
			else
				setNoClip(character, false)
			end

			if onArrive then
				onArrive()
			end
		end
	end)
end
-- #### FLIGHT AND HOVER #### --
-- ========================== --

-- ======================== --
-- #### VIRTUAL INPUTS #### --
local function showRedDot(x, y, duration)
    local indicatorGui = player.PlayerGui:FindFirstChild("VIMIndicatorGui")
    if not indicatorGui then
        indicatorGui = Instance.new("ScreenGui")
        indicatorGui.Name           = "VIMIndicatorGui"
        indicatorGui.IgnoreGuiInset = true
        indicatorGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
        indicatorGui.Parent         = player.PlayerGui
    end
    local dot = Instance.new("Frame", indicatorGui)
    dot.Size                   = UDim2.new(0, 20, 0, 20)
    dot.Position               = UDim2.new(0, x - 10, 0, y - 10)
    dot.BackgroundColor3       = Color3.fromRGB(255, 0, 0)
    dot.BackgroundTransparency = 0.1
    dot.BorderSizePixel        = 0
    task.delay(duration or 0.3, function()
        if dot and dot.Parent then dot:Destroy() end
    end)
end

local function universalClick(guiObject)
    if not guiObject or not guiObject.Parent then return false end
    local pos = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    local clickX = pos.X + (size.X / 2)
    local clickY = pos.Y + (size.Y / 2)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
	showRedDot(clickX, clickY, 1)
    return true
end

local function clickButton(btn)
    pcall(function() btn.Active = true end)
    if not pcall(function() universalClick(btn) end) or (btn.Parent and btn.Visible) then
        if typeof(firesignal) == "function" and btn.MouseButton1Click then
            pcall(firesignal, btn.MouseButton1Click)
        end
    end
end

local function clickSelectionObject(sel)
	if not (sel and PlayerGui) then return false end
	GuiService.SelectedObject = sel
		task.wait()
		VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Return, false, nil)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
		task.wait()
	success = true
	if GuiService.SelectedObject == sel then
		if prevSel and prevSel.Parent then
			GuiService.SelectedObject = prevSel
		else
			GuiService.SelectedObject = nil
		end
	end
end
-- #### VIRTUAL INPUTS #### --
-- ======================== --

local function _getToggle(idx)
    local T = rawget(getgenv(), "Toggles") or (Library and Library.Toggles)
    return T and T[idx] or nil
end


-- ################## --
-- #### MAIN TAB #### --
-- ################## --

-- ==================== --
-- #### TELEPORTS  #### --
local npcModelByLabel = {}  
local function uniqLabel(map, base)
    local k, n = base, 1
    while map[k] do
        n += 1
        k = string.format("%s (%d)", base, n)
    end
    return k
end

local function npcScanDeep()
    table.clear(npcModelByLabel)
    local out = {}
    local base = Workspace:FindFirstChild("NPCs")
    if not base then return out end

    for _, m in ipairs(base:GetDescendants()) do
        if m:IsA("Model") then
            local pos
            local ok, cf = pcall(function() return m:GetPivot() end)
            if ok and typeof(cf) == "CFrame" then
                pos = cf.Position
            else
                local hrp = m:FindFirstChild("HumanoidRootPart", true)
                if hrp then
                    pos = hrp.Position
                else
                    local hasCD = false
                    for _, d in ipairs(m:GetDescendants()) do
                        if d:IsA("ClickDetector") then hasCD = true break end
                    end
                    if hasCD then
                        local bp = m:FindFirstChildWhichIsA("BasePart", true)
                        pos = bp and bp.Position or nil
                    end
                end
            end

            if pos then
                local lbl = (m:FindFirstChild("DisplayName") and m.DisplayName:IsA("StringValue") and m.DisplayName.Value)
                           or m.Name or "NPC"
                lbl = uniqLabel(out, lbl)
                out[lbl] = pos
                npcModelByLabel[lbl] = m
            end
        end
    end
    return out
end

local currentSet = "Players"
local SETS = {
    Players = function()
        local locs, seen = {}, {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local base = (plr.DisplayName ~= "" and plr.DisplayName) or plr.Name
                    local lbl = uniqLabel(seen, base)
                    seen[lbl] = true
                    locs[lbl] = hrp.Position
                end
            end
        end
        return locs
    end,
    NPCS = npcScanDeep,
}

local function _worldPos(t)
    if typeof(t) == "Instance" and t:IsA("Model") then
        local ok, cf = pcall(function() return t.WorldPivot end)
        if ok and typeof(cf) == "CFrame" then return cf.Position end
        local ok2, cf2 = pcall(function() return t:GetPivot() end)
        if ok2 and typeof(cf2) == "CFrame" then return cf2.Position end
        return getPosition(t)
    elseif typeof(t) == "Instance" then
        return getPosition(t)
    elseif typeof(t) == "Vector3" then
        return t
    end
    return nil
end

local function smartFlyTo(target)
	if not humanoidRootPart then return false end
	local pos = _worldPos(target)
	if not pos then return false end
	humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(0, -50, 0)
	task.wait(0.05)
	local below = pos + Vector3.new(0, -50, 0)
	local arrived = false
	moveTo(below, 240, true, function()
		arrived = true
		task.wait(0.05)
		humanoidRootPart.AssemblyLinearVelocity  = Vector3.zero
		humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
		humanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
		stopHover()
	end)
	local t0 = os.clock()
	while not arrived and os.clock() - t0 < 12 do
		RunService.Heartbeat:Wait()
	end
	return arrived
end

local teleportTbl = SETS[currentSet]()
local locNames = {}
for n in pairs(teleportTbl) do table.insert(locNames, n) end
table.sort(locNames)
local selectedDest = locNames[1] or "-"

teleportGroupbox = Tabs.Main:AddLeftGroupbox("Teleports", "move-3d")

local locDropdown
teleportGroupbox:AddDropdown("CategoryDropdown", {
    Text = "Category",
    Values = { "Players", "NPCS" },
    Default = currentSet,
    Callback = function(value)
        currentSet  = value
        teleportTbl = SETS[currentSet]()
        locNames = {}
        for n in pairs(teleportTbl) do table.insert(locNames, n) end
        table.sort(locNames)
        selectedDest = locNames[1] or "-"
        if locDropdown then
            locDropdown:SetValues(locNames)
            locDropdown:SetValue(selectedDest)
        end
    end
})

locDropdown = teleportGroupbox:AddDropdown("LocationDropdown", {
    Text = "Select Location",
    Values = locNames,
    Default = selectedDest,
    Callback = function(v) selectedDest = v end
})

teleportGroupbox:AddButton({
    Text = "Fly To Selected",
    Func = function()
        teleportTbl = SETS[currentSet]()
        local pos = teleportTbl[selectedDest]
        if pos and humanoidRootPart then
            local ok = smartFlyTo(pos)
            if ok then
                Library:Notify("Arrived | " .. tostring(selectedDest), 3)
            end
        else
            Library:Notify("Teleport Failed | Invalid location or Character", 3)
        end
    end
})

teleportGroupbox:AddButton({
    Text = "Talk To",
    Func = function()
        if currentSet ~= "NPCS" or not selectedDest or selectedDest == "-" then
            warn("No NPC selected"); return
        end
        local model = npcModelByLabel[selectedDest]
        if not (model and model.Parent) then
            warn("NPC model not found for: " .. tostring(selectedDest)); return
        end
        local hit = 0
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ClickDetector") then
                hit += 1
                pcall(fireclickdetector, d)
            end
        end
        if hit == 0 then
            warn("No ClickDetectors in: " .. tostring(selectedDest))
        end
    end
})

teleportGroupbox:AddButton({
    Text = "Refresh Locations",
    Func = function()
        teleportTbl = SETS[currentSet]()
        locNames = {}
        for n in pairs(teleportTbl) do table.insert(locNames, n) end
        table.sort(locNames)
        selectedDest = locNames[1] or "-"
        if locDropdown then
            locDropdown:SetValues(locNames)
            locDropdown:SetValue(selectedDest)
        end
        Library:Notify("Locations Updated | Re-scanned " .. currentSet, 2)
    end
})
-- #### TELEPORTS  #### --
-- ==================== --

-- ============================= --
-- #### AUTO ATTACK HELPERS #### --
local CombatRemote = (function() local rs=ReplicatedStorage local rem=rs:FindFirstChild("Remotes") or rs:WaitForChild("Remotes",2) if not rem then return nil end return rem:FindFirstChild("ServerCombatHandler") or rem:WaitForChild("ServerCombatHandler",0.2) end)()
local selectedAttacks = {}

local SKILL_OPTIONS = {
	"M1","Critical","Skill 1","Skill 2","Skill 3","Skill 4","Skill 5",
	"Skill 6","Skill 7","Skill 8","Skill 9","Skill 0",
	"Skill -","Skill +",
}
local KEY_OF = {
	["Skill 1"]="One",   ["Skill 2"]="Two",   ["Skill 3"]="Three",
	["Skill 4"]="Four",  ["Skill 5"]="Five",  ["Skill 6"]="Six",
	["Skill 7"]="Seven", ["Skill 8"]="Eight", ["Skill 9"]="Nine",
	["Skill 0"]="Zero",  ["Skill -"]="Minus", ["Skill +"]="Equals",
}

local function getSlotFrame(key)
	local pg = player:FindFirstChildOfClass("PlayerGui")
	local tb = pg and pg:FindFirstChild("Toolbar")
	local fr = tb and tb:FindFirstChild("Frame")
	return fr and fr:FindFirstChild(key) or nil
end

local autoAttackEnabled, lastCritical, autoAttackIncludeTarget, autoAttackTarget = false, 0, false, nil

local function isTargetRagdolled()
	if not (autoAttackIncludeTarget and autoAttackTarget) then return false end
	local model = autoAttackTarget:IsA("Model") and autoAttackTarget or autoAttackTarget:FindFirstAncestorOfClass("Model")
	if not model then return false end
	return model:GetAttribute("CurrentlyRagdolled") == true
end

local function startAutoAttack()
	if autoAttackEnabled then return end
	autoAttackEnabled = true
	task.spawn(function()
		local rng = Random.new()
		while autoAttackEnabled do
			if isTargetRagdolled() then
				local char = player.Character
				local exec = char
					and char:FindFirstChild("CharacterHandler")
					and char.CharacterHandler:FindFirstChild("Remotes")
					and char.CharacterHandler.Remotes:FindFirstChild("Execute")
				if exec then exec:FireServer() end
				task.wait(4)
			else
				local chosen = {}
				if type(selectedAttacks) == "table" then
    				if #selectedAttacks > 0 then
		    			chosen = selectedAttacks
					else
        				for name, on in pairs(selectedAttacks) do
            				if on then chosen[#chosen+1] = name end
						end
					end	
        		end
				local useM1, useCrit = false, false
				local ready = {}

				for _, label in ipairs(chosen) do
					if label == "M1" then
						useM1 = true
					elseif label == "Critical" then
						useCrit = true
					else
						local key = KEY_OF[label]
						if key then
							local slot = getSlotFrame(key)
							if slot then
								local nameObj = slot:FindFirstChild("SkillName")
								local hasName = nameObj and tostring(nameObj.Text or "") ~= ""
								local cdObj   = slot:FindFirstChild("Cooldown")
								local onCD    = cdObj and cdObj.Visible or false
								if hasName and not onCD then
									ready[#ready+1] = key
								end
							end
						end
					end
				end

				if #ready > 0 then
					CombatRemote:FireServer("Skill", ready[rng:NextInteger(1, #ready)], "Pressed")
				else
					local critDue = (os.clock() - lastCritical) >= 5
					if useCrit and critDue then
						lastCritical = os.clock()
						CombatRemote:FireServer("CriticalAttack")
					elseif useM1 then
						CombatRemote:FireServer("LightAttack")
					end
				end

				task.wait(0.5)
			end
		end
	end)
end
-- #### AUTO ATTACK HELPERS #### --
-- ============================= --

-- ======================== --
-- #### AUTO ATTACK UI #### --
autoAttackGroupbox = Tabs.Main:AddLeftGroupbox("AutoAttack", "swords")
autoAttackGroupbox:AddLabel("autoAttackLabel", {
	Text = "Make sure you don't select any skills that don't go on cooldown or it won't work correctly.",
	DoesWrap = true,
})

autoAttackGroupbox:AddDropdown("selectedAttacksDropdown",{
	Text = "Select Attacks",
	Values = SKILL_OPTIONS,
	Default = {},
	Multi = true,
	Callback = function(v) if v then if #v>0 then selectedAttacks=v else local o={} for n,on in pairs(v)do if on then o[#o+1]=n end end selectedAttacks=o end end end
})

autoAttackGroupbox:AddToggle("autoAttack",{
	Text = "AutoAttack",
	Default = false,
	Callback = function(on)
		if on then startAutoAttack() else autoAttackEnabled = false end
	end,
})

local autoEquip = { enabled = false, thread = nil }
autoAttackGroupbox:AddToggle("AutoEquipWeapon", {
	Text = "AutoEquip Weapon",
	Default = false,
	Callback = function(on)
		autoEquip.enabled = on
		if not on then autoEquip.thread = nil; return end
		if autoEquip.thread then return end

		autoEquip.thread = task.spawn(function()
			local cachedChar, weaponRemote
			while autoEquip.enabled do
				if character ~= cachedChar then
					cachedChar = character
					weaponRemote = nil
				end
				if not weaponRemote then
					local ch = character:FindFirstChild("CharacterHandler")
					local rem = ch and ch:FindFirstChild("Remotes")
					weaponRemote = rem and rem:FindFirstChild("Weapon")
				end
				local pf = entitiesFolder and entitiesFolder:FindFirstChild(player.Name)
				local hasZanpakuto = pf and pf:FindFirstChild("Zanpakuto")

				if hasZanpakuto and weaponRemote then
					pcall(function() weaponRemote:FireServer() end)
					task.wait(1)    
				else
					task.wait(0.25)  
				end
			end
			autoEquip.thread = nil
		end)
	end
})
-- #### AUTO ATTACK UI #### --
-- ======================== --

-- =================== --
-- #### INSTAKILL #### --
instakillGroupbox = Tabs.Main:AddRightGroupbox("Instakill", "skull")

local IK = {
    enabled   = false,
    range     = 150,
    threshold = 30,  
    loop      = nil,
    acc       = 0
}

local function isValidEntity(m)
    if not m or not m:IsA("Model") then return false end
    if m == player.Character then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    if m.Name == player.Name or m.Name:find("Clone") then return false end
    local hum = m:FindFirstChildOfClass("Humanoid")
    local hrp = m:FindFirstChild("HumanoidRootPart")
    return hum and hrp and hum.Health > 0
end

local function killEntity(ent)
    local hum = ent and ent:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    pcall(function()
        sethiddenproperty(player, "SimulationRadius", 1e5)
        sethiddenproperty(player, "MaxSimulationRadius", 1e5)
    end)
    for _, part in ipairs(ent:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part:SetNetworkOwner(player) end)
        end
    end

    pcall(function() hum.Health = 0 end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Dead) end)
    pcall(function() ent:SetAttribute("CurrentState", "Unconscious") end)
end

local function scanAndKill()
    local entities = Workspace:FindFirstChild("Entities")
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not (entities and root) then return end

    for _, m in ipairs(entities:GetChildren()) do
        if isValidEntity(m) then
            local hrp = m:FindFirstChild("HumanoidRootPart")
            local hum = m:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist <= IK.range then
                    local max = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
                    local pct = (hum.Health / max) * 100
                    if pct <= IK.threshold then
                        killEntity(m)
                    end
                end
            end
        end
    end
end

instakillGroupbox:AddToggle("NH_Instakill", {
    Text = "Instakill",
    Default = false,
    Callback = function(on)
        IK.enabled = on
        if not on then
            if IK.loop then IK.loop:Disconnect(); IK.loop = nil end
            return
        end
        if IK.loop then IK.loop:Disconnect() end
        IK.acc = 0
        IK.loop = RunService.Heartbeat:Connect(function(dt)
            if not IK.enabled then return end
            IK.acc += dt
            if IK.acc >= 0.12 then 
                IK.acc = 0
                pcall(scanAndKill)
            end
        end)
    end
})

instakillGroupbox:AddSlider("NH_InstakillRange", {
    Text = "Range",
    Default = IK.range,
    Min = 10, Max = 1000, Rounding = 0, Suffix = "studs",
    Callback = function(v) IK.range = v end
})

instakillGroupbox:AddSlider("NH_InstakillThreshold", {
    Text = "Health Threshold",
    Default = IK.threshold,
    Min = 0, Max = 100, Rounding = 0, Suffix = "%",
    Tooltip = "Kill enemies at or below this HP%",
    Callback = function(v) IK.threshold = v end
})
-- #### INSTAKILL #### --
-- =================== --

-- ================= --
-- #### LOOTBOX #### --
lootboxGroupbox = Tabs.Main:AddRightGroupbox("Lootbox", "coins")
lootboxGroupbox:AddLabel("lootboxLabel", {
	Text = "If its not working go closer to the lootbox.",
	DoesWrap = true,
})
local aura = { running = false, task = nil, recent = {} }
lootboxGroupbox:AddToggle("LootboxAura", {
    Text = "Lootbox Aura",
    Default = false,
    Callback = function(state)
        aura.running = state
        if not state then aura.task = nil; return end
        if aura.task then return end
        aura.task = task.spawn(function()
            while aura.running do
                local lootboxes = Workspace:FindFirstChild("Lootboxes")
                if lootboxes then
                    local now = os.clock()
                    local cds = {}
                    local function pull(o)
                        for _, ch in ipairs(o:GetChildren()) do
                            if ch:IsA("ClickDetector") then cds[#cds+1] = ch end
                            pull(ch)
                        end
                    end
                    pull(lootboxes)
                    for _, cd in ipairs(cds) do
                        if cd and cd.Parent then
                            local last = aura.recent[cd] or 0
                            if (now - last) > 0.5 then
                                aura.recent[cd] = now
                                pcall(fireclickdetector, cd)
                            end
                        end
                    end
                    for cd, t in pairs(aura.recent) do
                        if (not cd) or (not cd.Parent) or (now - t) > 3 then
                            aura.recent[cd] = nil
                        end
                    end
                    task.wait(0.05)
                else
                    task.wait(0.5)
                end
            end
            aura.task = nil
        end)
    end
})

local auto = { enabled = false, thread = nil }

local function findRewardsContainer()
    local pg = player:FindFirstChild("PlayerGui"); if not pg then return nil, false end
    for _, gui in ipairs(pg:GetChildren()) do
        local Rewards  = gui:FindFirstChild("Rewards")
        local Content  = Rewards and Rewards:FindFirstChild("Content")
        local C1       = Content and Content:FindFirstChild("Container")
        local Items    = C1 and C1:FindFirstChild("Items")
        local inner    = Items and Items:FindFirstChild("Container")
        if inner then
            local visible = (inner.Parent and inner.Parent.Parent and inner.Parent.Parent.Parent and inner.Parent.Parent.Parent.Visible) or false
            return inner, visible
        end
    end
    return nil, false
end

local function fireCollect(itemName)
    local lb = ReplicatedStorage:FindFirstChild("Lootbox")
    local rems = lb and lb:FindFirstChild("Remotes")
    local collect = rems and rems:FindFirstChild("Collect")
    if collect and itemName and itemName ~= "" then
        pcall(function()
            collect:FireServer("{439b69cb-994c-4c7d-9230-1b5e66993c3e}", itemName)
        end)
    end
end

lootboxGroupbox:AddToggle("AutoCollectLootbox", {
    Text = "AutoCollect Lootbox",
    Default = false,
    Callback = function(on)
        auto.enabled = on
        if not on then auto.thread = nil; return end
        if auto.thread then return end

        auto.thread = task.spawn(function()
            local idx, lastClick, lastClaim = 1, 0, 0
            local rng = Random.new()

            while auto.enabled do
                local container, visible = findRewardsContainer()
                if container and visible then
                    local entries = {}
                    for _, child in ipairs(container:GetChildren()) do
                        if child:IsA("GuiObject") then
                            entries[#entries+1] = child
                        end
                    end
                    table.sort(entries, function(a,b) return a.AbsolutePosition.Y < b.AbsolutePosition.Y end)
                    local now = os.clock()
                    if #entries > 0 and (now - lastClick) >= 0.4 then
                        if idx > #entries then idx = 1 end
                        local gui = entries[idx]
                        local sel = gui.SelectionImageObject or gui
                        pcall(clickSelectionObject, sel)
                        idx = idx + 1
                        lastClick = now
                    end
                    if #entries > 0 and (now - lastClaim) >= 0.6 then
                        local pick = entries[rng:NextInteger(1, #entries)]
                        local itemName = pick and pick.Name
                        fireCollect(itemName)
                        lastClaim = now
                    end

                    task.wait(0.05)
                else
                    idx = 1
                    task.wait(0.1)
                end
            end
            auto.thread = nil
        end)
    end
})
-- #### LOOTBOX #### --
-- ================= --

-- #### HELL #### --
-- ============== --
hellGroupbox = Tabs.Main:AddLeftGroupbox("Hell")
hellGroupbox:AddButton({ Text = "Talk to Felis", Func = function()
    local clickDet = Workspace:FindFirstChild("NPCs")
                    and Workspace.NPCs:FindFirstChild("HighwayQuestGiver")
                    and Workspace.NPCs.HighwayQuestGiver:FindFirstChild("Felis")
                    and Workspace.NPCs.HighwayQuestGiver.Felis:FindFirstChild("ClickPart")
                    and Workspace.NPCs.HighwayQuestGiver.Felis.ClickPart:FindFirstChildOfClass("ClickDetector")
    if clickDet then
        pcall(fireclickdetector, clickDet)
    else
        Library:Notify("Felis | Could not find Felis", 2)
    end
end })
hellGroupbox:AddButton({ Text = "Collect All Soul Crystals", Func = function()
    local clickDetectors = {}
    local function collectAllClickDetectors(parent)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("ClickDetector") then
                table.insert(clickDetectors, child)
            elseif #child:GetChildren() > 0 then
                collectAllClickDetectors(child)
            end
        end
    end
    local root = Workspace:FindFirstChild("SoulCrystalSpawns") and Workspace.SoulCrystalSpawns:FindFirstChild("Spawned")
    if root then
        collectAllClickDetectors(root)
        if #clickDetectors == 0 then
            Library:Notify("Soul Crystal Collector | No crystals found", 3)
            return
        end
        task.spawn(function()
            for _, detector in ipairs(clickDetectors) do
                pcall(fireclickdetector, detector)
                Library:Notify("Soul Crystal Collector | Collected a Soul Crystal!", 1.2)
                task.wait(1)
            end
            Library:Notify("Soul Crystal Collector | All Soul Crystals collected!", 3)
        end)
    else
        Library:Notify("Soul Crystal Collector | No crystals found", 3)
    end
end })

do
    local anchorOn, anchorPos, loopConn, idleConn
    local function clickRaidYes()
        local pg = player:FindFirstChild("PlayerGui"); if not pg then return end
        local rc = pg:FindFirstChild("Settings"); rc = rc and rc:FindFirstChild("RaidConfirm")
        if not (rc and rc.Visible) then return end
        local yes = rc:FindFirstChild("Yes")
        if yes and yes.Visible then pcall(clickSelectionObject, yes) end
    end

    local function enableAntiAfk()
        if idleConn then return end
        local VirtualUser = game:GetService("VirtualUser")
        idleConn = player.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(), camera.CFrame)
                task.wait(0.15)
                VirtualUser:Button2Up(Vector2.new(), camera.CFrame)
            end)
        end)
    end
    local function disableAntiAfk()
        if idleConn then idleConn:Disconnect(); idleConn = nil end
    end

    local function startLoop()
        if loopConn then return end
        local lastCheck = 0
        loopConn = RunService.Heartbeat:Connect(function()
            if not anchorOn then return end
            pcall(clickRaidYes)
            local now = os.clock()
            if (now - lastCheck) >= 5 and anchorPos and humanoidRootPart then
                lastCheck = now
                local dist = (humanoidRootPart.Position - anchorPos).Magnitude
                if dist > 10 then
                    local target = anchorPos + Vector3.new(0, 1, 0)
                    moveTo(target, 150, false, function() stopHover() end)
                end
            end
        end)
    end
    local function stopLoop()
        if loopConn then loopConn:Disconnect(); loopConn = nil end
        stopHover()
    end

    player.CharacterAdded:Connect(function(char)
        humanoid         = char:WaitForChild("Humanoid")
        humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    end)

    hellGroupbox:AddToggle("HellAFK", {
        Text = "Hell AFK",
        Tooltip = "Anchor here, auto-confirm raids, and anti-AFK.",
        Default = false,
        Callback = function(on)
            anchorOn = on
            if on then
                if not humanoidRootPart then
                    Library:Notify("Hell AFK: HumanoidRootPart not found.", 3)
                    anchorOn = false
                    return
                end
                anchorPos = humanoidRootPart.Position
                enableAntiAfk()
                startLoop()
                Library:Notify(("Anchor set at %s"):format(tostring(anchorPos)), 3)
            else
                stopLoop()
                disableAntiAfk()
                Library:Notify("Hell AFK disabled.", 2)
            end
        end
    })
end

-- ======================== --
-- #### MAIN UTILITIES #### --
mainUtilsGroupbox = Tabs.Main:AddRightGroupbox("Utilities", "menu")

-- #### ANTI-AFK #### --
local antiAfkConnection = nil
mainUtilsGroupbox:AddToggle("AntiAFKToggle", { Text = "Anti AFK", Default = false, 
    Callback = function(value)
        if value then
            if antiAfkConnection then antiAfkConnection:Disconnect() end
            antiAfkConnection = player.Idled:Connect(function()
                if value then 
                    VirtualInputManager:SendMouseMoveEvent(0, 0, game, 0)
                    VirtualInputManager:SendMouseMoveEvent(1, 1, game, 0)
                end
            end)
            Library:Notify("Speed Enabled | Anti-AFK activated", 3)
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end
})

-- #### DIV 11 MINIGAME #### --
getgenv()._d11On, getgenv()._d11Task = false, nil
getgenv()._d11Deb = {}

local function _visibleChain(o)
    local cur = o
    while cur and cur ~= player:FindFirstChild("PlayerGui") do
        if cur:IsA("LayerCollector") then
            if cur.Enabled == false then return false end
        elseif cur:IsA("GuiObject") then
            if cur.Visible == false then return false end
            if cur.AbsoluteSize.X <= 0 or cur.AbsoluteSize.Y <= 0 then return false end
        end
        cur = cur.Parent
    end
    return true
end

local function _collectButtons()
    local pg = player:FindFirstChild("PlayerGui"); if not pg then return {} end
    local sg = pg:FindFirstChild("Division11Minigame"); if not (sg and sg.Enabled) then return {} end
    local frame = sg:FindFirstChild("Frame"); if not (frame and frame.Visible) then return {} end
    local out = {}
    for _, o in ipairs(frame:GetDescendants()) do
        if (o:IsA("ImageButton") or o:IsA("TextButton")) and o.Visible and _visibleChain(o) then
            table.insert(out, o)
        end
    end
    table.sort(out, function(a,b)
        local ap, bp = a.AbsolutePosition, b.AbsolutePosition
        return ap.Y == bp.Y and ap.X < bp.X or ap.Y < bp.Y
    end)
    return out
end

local function _startD11()
    if getgenv()._d11Task then return end
    getgenv()._d11Task = task.spawn(function()
        while getgenv()._d11On do
            local list = _collectButtons()
            if #list > 0 then
                for _, btn in ipairs(list) do
                    if not getgenv()._d11On then break end
                    local last = getgenv()._d11Deb[btn]
                    if (not last) or (os.clock() - last > 0.15) then
                        clickButton(btn)
                        getgenv()._d11Deb[btn] = os.clock()
                    end
                end
            end
            task.wait(0.05)
        end
        getgenv()._d11Task = nil
    end)
end

mainUtilsGroupbox:AddToggle("AutoClickDivision11", {
    Text = "Auto Div11 Minigame",
    Default = false,
    Callback = function(on)
        getgenv()._d11On = on
        if on then _startD11() end
    end
})

-- #### AUTO MEDITATE #### --
local autoMeditateTask
mainUtilsGroupbox:AddToggle("AutoMeditate", { Text = "AutoMeditate", Default = false, Callback = function()
    if autoMeditateTask then return end
    autoMeditateTask = task.spawn(function()
        while isOn("AutoMeditate") do
            local ok = pcall(function()
                local myModel  = entitiesFolder:FindFirstChild(player.Name)
                local meditateRemote   = character:WaitForChild("CharacterHandler"):WaitForChild("Remotes"):WaitForChild("Meditate")
                if myModel and myModel:GetAttribute("CurrentState") ~= "Meditating" then
                    meditateRemote:FireServer()
                end
            end)
            if not ok then task.wait(0.5) end
            task.wait(1)
        end
        autoMeditateTask = nil
    end)
end })

-- #### REMOVE KILLBRICKS #### --
mainUtilsGroupbox:AddToggle("RemoveKillbricks", { Text = "Remove Killbricks", Default = false, 
    Callback = function(on)
        local killbrickConnections = {}
        local function isKillbrick(obj)
            return obj:IsA("BasePart") 
                and obj.CanTouch 
                and string.lower(obj.Name):find("kill")
        end
        local function removeKillbricks(folder)
            for _, obj in ipairs(folder:GetDescendants()) do
                if isKillbrick(obj) then
                    obj:Destroy()
                end
            end
        end
        for _, conn in ipairs(killbrickConnections) do
            conn:Disconnect()
        end
        table.clear(killbrickConnections)
        if on then
            removeKillbricks(Workspace)
            table.insert(killbrickConnections, Workspace.DescendantAdded:Connect(function(obj)
                if isKillbrick(obj) then
                    obj:Destroy()
                end
            end))
        end
    end
})

-- #### MOD NOTIFIER AND KICK #### --
local modSettings = { notifier = false, kick = false }
local function onPlayerAdded(plr)
    if not modSettings.notifier and not modSettings.kick then return end
    local success, adminLevel = pcall(function() return plr:GetAttribute("AdminLevel") end)
    if success and adminLevel and adminLevel > 0 then
        if modSettings.notifier then
            Library:Notify("Moderator Joined | " .. plr.Name .. " has joined the game", 6)
        end
        if modSettings.kick and plr ~= player then
            task.delay(0.5, function()
                if plr and plr.Parent then
                    plr:Kick("Moderators joined.")
                end
            end)
        end
    end
end
Players.PlayerAdded:Connect(onPlayerAdded)
for _, plr in ipairs(Players:GetPlayers()) do
    onPlayerAdded(plr)
end
mainUtilsGroupbox:AddToggle("ModNotifierToggle", { Text = "Mod Notifier", Default = false,
    Callback = function(value) modSettings.notifier = value end
})
mainUtilsGroupbox:AddToggle("KickModToggle", { Text = "Kick If Mod Joins", Default = false,
    Callback = function(value) modSettings.kick = value end
})
-- #### MAIN UTILITIES #### --
-- ======================== --

-- #################### --
-- #### PLAYER TAB #### --
-- #################### --

-- ========================== --
-- #### MOVEMENT HELPERS #### --
getgenv().speedEnabled          = (getgenv().speedEnabled ~= nil) and getgenv().speedEnabled or false
getgenv().speedValue            = (getgenv().speedValue   ~= nil) and getgenv().speedValue   or 30
getgenv().flying                = (getgenv().flying       ~= nil) and getgenv().flying       or false
getgenv().flySpeed              = (getgenv().flySpeed     ~= nil) and getgenv().flySpeed     or 100
getgenv().humanoid              = getgenv().humanoid or humanoid
getgenv().humanoidRootPart      = getgenv().humanoidRootPart or humanoidRootPart
getgenv().bodyGyro              = getgenv().bodyGyro or nil
getgenv().lastY                 = getgenv().lastY or nil
getgenv().inputState            = getgenv().inputState or { Forward=false, Backward=false, Left=false, Right=false, Up=false, Down=false }
getgenv()._baseWalkSpeed        = getgenv()._baseWalkSpeed or ((getgenv().humanoid and getgenv().humanoid.WalkSpeed) or 16)
getgenv()._conn_begin           = getgenv()._conn_begin or nil
getgenv()._conn_end             = getgenv()._conn_end   or nil
getgenv()._conn_render          = getgenv()._conn_render or nil
getgenv()._conn_speedEnforce    = getgenv()._conn_speedEnforce or nil
getgenv()._conn_flightKeepAlive = getgenv()._conn_flightKeepAlive or nil
getgenv()._conn_charAdded       = getgenv()._conn_charAdded or nil

if not getgenv()._conn_begin then
	getgenv()._conn_begin = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		local k = input.KeyCode
		if     k == Enum.KeyCode.W         then getgenv().inputState.Forward  = true
		elseif k == Enum.KeyCode.S         then getgenv().inputState.Backward = true
		elseif k == Enum.KeyCode.A         then getgenv().inputState.Left     = true
		elseif k == Enum.KeyCode.D         then getgenv().inputState.Right    = true
		elseif k == Enum.KeyCode.Space     then getgenv().inputState.Up       = true
		elseif k == Enum.KeyCode.LeftShift then getgenv().inputState.Down     = true
		end
	end)
end
if not getgenv()._conn_end then
	getgenv()._conn_end = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		local k = input.KeyCode
		if     k == Enum.KeyCode.W         then getgenv().inputState.Forward  = false
		elseif k == Enum.KeyCode.S         then getgenv().inputState.Backward = false
		elseif k == Enum.KeyCode.A         then getgenv().inputState.Left     = false
		elseif k == Enum.KeyCode.D         then getgenv().inputState.Right    = false
		elseif k == Enum.KeyCode.Space     then getgenv().inputState.Up       = false
		elseif k == Enum.KeyCode.LeftShift then getgenv().inputState.Down     = false
		end
	end)
end

getgenv().enableFlight = getgenv().enableFlight or function()
	if getgenv().humanoid and getgenv().humanoidRootPart then
		getgenv().humanoid.PlatformStand = true
		getgenv().lastY = getgenv().humanoidRootPart.Position.Y
		if getgenv().bodyGyro then getgenv().bodyGyro:Destroy() getgenv().bodyGyro = nil end
		local bg = Instance.new("BodyGyro")
		bg.Name = "FlightGyro"
		bg.P, bg.D, bg.MaxTorque = 20000, 1000, Vector3.new(1e5, 1e5, 1e5)
		bg.CFrame = getgenv().humanoidRootPart.CFrame
		bg.Parent = getgenv().humanoidRootPart
		getgenv().bodyGyro = bg
	end
end
getgenv().disableFlight = getgenv().disableFlight or function()
	if getgenv().humanoid then getgenv().humanoid.PlatformStand = false end
	if getgenv().bodyGyro then getgenv().bodyGyro:Destroy() getgenv().bodyGyro = nil end
	if getgenv().humanoidRootPart then
		getgenv().humanoidRootPart.Velocity = Vector3.new()
		getgenv().humanoidRootPart.AssemblyLinearVelocity = Vector3.new()
	end
end

getgenv()._onCharacterAdded = getgenv()._onCharacterAdded or function(char)
	getgenv().humanoid = char:WaitForChild("Humanoid")
	getgenv().humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	getgenv()._baseWalkSpeed = getgenv().humanoid.WalkSpeed
	if getgenv().speedEnabled then getgenv().humanoid.WalkSpeed = getgenv().speedValue end
	if getgenv().flying then getgenv().lastY = getgenv().humanoidRootPart.Position.Y; if getgenv().bodyGyro then getgenv().bodyGyro:Destroy() getgenv().bodyGyro=nil end; getgenv().enableFlight() end
end
if not getgenv()._conn_charAdded then
	getgenv()._conn_charAdded = player.CharacterAdded:Connect(getgenv()._onCharacterAdded)
	if player.Character then getgenv()._onCharacterAdded(player.Character) end
end

if not getgenv()._conn_speedEnforce then
	getgenv()._conn_speedEnforce = RunService.Heartbeat:Connect(function()
		local hum = rawget(getgenv(), "humanoid")
		if hum and getgenv().speedEnabled and hum.WalkSpeed ~= getgenv().speedValue then hum.WalkSpeed = getgenv().speedValue end
	end)
end

if not getgenv()._conn_flightKeepAlive then
	getgenv()._conn_flightKeepAlive = RunService.Heartbeat:Connect(function()
		if getgenv().flying and getgenv().humanoid and getgenv().humanoidRootPart then
			if getgenv().humanoid.PlatformStand == false then getgenv().humanoid.PlatformStand = true end
			if (not getgenv().bodyGyro) or (getgenv().bodyGyro.Parent ~= getgenv().humanoidRootPart) then getgenv().enableFlight() end
		end
	end)
end

if not getgenv()._conn_render then
	getgenv()._conn_render = RunService.RenderStepped:Connect(function()
		if not getgenv().flying or not getgenv().humanoidRootPart then return end
		local moveDir = Vector3.new()
		local camCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
		if not UserInputService.TouchEnabled then
			if getgenv().inputState.Forward  then moveDir += camCF.LookVector end
			if getgenv().inputState.Backward then moveDir -= camCF.LookVector end
			if getgenv().inputState.Left     then moveDir -= camCF.RightVector end
			if getgenv().inputState.Right    then moveDir += camCF.RightVector end
		else
			local hum = rawget(getgenv(), "humanoid") or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
			local md  = hum and hum.MoveDirection or Vector3.zero
			if md.Magnitude > 0 then moveDir += Vector3.new(md.X, 0, md.Z) end
		end
		if getgenv().inputState.Up   then moveDir += Vector3.new(0, 1, 0) end
		if getgenv().inputState.Down then moveDir -= Vector3.new(0, 1, 0) end
		if getgenv().bodyGyro then getgenv().bodyGyro.CFrame = CFrame.new(getgenv().humanoidRootPart.Position, getgenv().humanoidRootPart.Position + camCF.LookVector) end
		local vel
		if moveDir.Magnitude > 0 then
			vel = moveDir.Unit * getgenv().flySpeed
			getgenv().lastY = getgenv().humanoidRootPart.Position.Y
		else
			local yOffset = getgenv().lastY and (getgenv().lastY - getgenv().humanoidRootPart.Position.Y) or 0
			vel = Vector3.new(0, yOffset * 5, 0)
		end
		getgenv().humanoidRootPart.AssemblyLinearVelocity = vel
	end)
end
-- #### MOVEMENT HELPERS #### --
-- ========================== --

-- ===================== --
-- #### MOVEMENT UI #### --
movementGroupbox = movementGroupbox or Tabs.Player:AddLeftGroupbox("Movement", "footprints")

movementGroupbox:AddToggle("SpeedToggle", {
	Text = "Speed",
	Default = getgenv().speedEnabled,
	Callback = function(state)
		getgenv().speedEnabled = state
		local hum = rawget(getgenv(), "humanoid")
		if hum then
			if state then
				if getgenv()._baseWalkSpeed == nil then getgenv()._baseWalkSpeed = hum.WalkSpeed end
				hum.WalkSpeed = getgenv().speedValue
				Library:Notify("Speed Enabled | ".. tostring(getgenv().speedValue), 3)
			else
				hum.WalkSpeed = getgenv()._baseWalkSpeed or 16
				Library:Notify("Speed Disabled | Reset", 3)
			end
		end
	end
})
movementGroupbox:AddSlider("SpeedSlider", {
	Text = "Speed Value",
	Default = getgenv().speedValue, Min = 16, Max = 500, Rounding = 0,
	Callback = function(val)
		getgenv().speedValue = val
		local hum = rawget(getgenv(), "humanoid")
		if getgenv().speedEnabled and hum then hum.WalkSpeed = val end
	end
})
movementGroupbox:AddToggle("FlightToggle", {
	Text = "Flight",
	Default = getgenv().flying,
	Callback = function(state)
		getgenv().flying = state
		if state then
			getgenv().enableFlight()
			Library:Notify("Flight Enabled | WASD+Space/Shift (PC) | Thumbstick (Mobile)", 4)
		else
			getgenv().disableFlight()
			Library:Notify("Flight Disabled", 3)
		end
	end
})
movementGroupbox:AddSlider("FlightSpeedSlider", {
	Text = "Flight Speed",
	Default = getgenv().flySpeed, Min = 10, Max = 500, Rounding = 0,
	Callback = function(val) getgenv().flySpeed = val end
})
-- #### MOVEMENT UI #### --
-- ===================== --

miscGroupbox = Tabs.Player:AddRightGroupbox("Misc Utils", "menu")

-- ========================== --
-- #### REDEEM ALL CODES #### --
miscGroupbox:AddButton({ Text = "Redeem All Codes", Func = function()
    local CodesList = {
        "setrona1vertagzeu0", "excaliburfool", "higuyscode", "thisiswhywetestthosewhoknow",
        "somebugsfixes", "goplayranked", "raidsfixed", "rerererelease", "thanksforpatience",
        "800kcodeyeah", "compensationforinconvenientrelease", "sorryforthebankbugs",
        "mythoughtsonthislater", "3daysthosewhoknow", "privateservercompensation", "promiseddecembercode"
    }
    local remote = Character:WaitForChild("CharacterHandler"):WaitForChild("Remotes"):WaitForChild("Codes")
    task.spawn(function()
        for _, code in ipairs(CodesList) do
            local success, err = pcall(function() remote:InvokeServer(code) end)
            if success then
                Library:Notify("Code Redeemed | " .. code, 3)
            else
                Library:Notify("Code Failed | " .. code .. ": " .. tostring(err), 3)
            end
            task.wait(0.2)
        end
    end)
end })
-- #### REDEEM ALL CODES #### --
-- ========================== --

-- ===================== --
-- #### SERVER HOP #### --
local serverHop = { enabled = false, thread = nil }

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function hopRandomServer(minPlayers)
    minPlayers = minPlayers or 8

    local success, result = pcall(function()
        local response = game:HttpGet(
            string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", PlaceId)
        )
        return HttpService:JSONDecode(response)
    end)
    if not success or not result or not result.data then
        warn("[ServerHop] Failed to fetch servers:", result)
        return
    end
    local servers = {}
    for _, s in ipairs(result.data) do
        if type(s.playing) == "number" and s.playing >= minPlayers and s.id ~= game.JobId then
            table.insert(servers, s)
        end
    end
    if #servers == 0 then
        warn("[ServerHop] No servers found with at least " .. minPlayers .. " players.")
        return
    end
    local choice = servers[math.random(1, #servers)]
    if choice and choice.id then
        print(string.format("[ServerHop] Hopping to server %s (%d players)", choice.id, choice.playing))
        TeleportService:TeleportToPlaceInstance(PlaceId, choice.id)
    else
        warn("[ServerHop] No valid server ID.")
    end
end

miscGroupbox:AddToggle("ServerHopToggle", { Text = "Auto Server Hop", Default = false,
    Callback = function(state)
        serverHop.enabled = state
        if state then
            serverHop.thread = task.spawn(function()
                while serverHop.enabled do
                    hopRandomServer(8) 
                    for i = 1, 20 do
                        if not serverHop.enabled then break end
                        task.wait(1)
                    end
                end
            end)
        else
            serverHop.enabled = false
            serverHop.thread = nil
        end
    end
})
-- #### SERVER HOP #### --
-- ===================== --

-- ================ --
-- #### NOCLIP #### --
local noClip = { enabled = false, conn = nil }
local function setCharacterCollisions(state)
    if not player.Character then return end
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = state end
    end
end
player.CharacterAdded:Connect(function(char)
    Character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    if noClip.enabled then
        if noClip.conn then noClip.conn:Disconnect() end
        noClip.conn = RunService.Stepped:Connect(function()
            setCharacterCollisions(false)
        end)
    end
end)
miscGroupbox:AddToggle("NoClipToggle", { Text = "NoClip", Default = false,
    Callback = function(state)
        noClip.enabled = state
        if state then
            noClip.conn = RunService.Stepped:Connect(function()
                setCharacterCollisions(false)
            end)
        else
            if noClip.conn then noClip.conn:Disconnect() noClip.conn = nil end
            setCharacterCollisions(true)
        end
    end
})
-- #### NOCLIP #### --
-- ================ --

-- ===================== --
-- #### PERFORMANCE #### --
local originalGraphics = {
    QualityLevel  = settings().Rendering.QualityLevel,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient       = Lighting.Ambient,
    Brightness    = Lighting.Brightness,
    FogEnd        = Lighting.FogEnd,
    FogStart      = Lighting.FogStart,
    EffectsEnabled = {},
    WaterProps = {}
}
for _, className in ipairs({ "BloomEffect", "ColorCorrectionEffect", "SunRaysEffect", "DepthOfFieldEffect", "BlurEffect", "ShadowMap" }) do
    for _, inst in ipairs(Lighting:GetDescendants()) do
        if inst.ClassName == className then
            originalGraphics.EffectsEnabled[inst] = inst.Enabled
        end
    end
end
local terrain = Terrain
if terrain then
    originalGraphics.WaterProps.WaterWaveSize     = terrain.WaterWaveSize
    originalGraphics.WaterReflectance  = terrain.WaterReflectance
    originalGraphics.WaterTransparency = terrain.WaterTransparency
end
local performanceEnabled = false
miscGroupbox:AddToggle("PerformanceMode", { Text = "Performance Mode", Default = false,
    Callback = function(enabled)
        performanceEnabled = enabled
        if enabled then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.Ambient    = Color3.new(0.3, 0.3, 0.3)
            Lighting.Brightness = 1
            Lighting.FogEnd   = 1e10
            Lighting.FogStart = 1e10
            for inst, wasEnabled in pairs(originalGraphics.EffectsEnabled) do
                if inst and inst.Parent then inst.Enabled = false end
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
            settings().Rendering.QualityLevel = originalGraphics.QualityLevel
            Lighting.GlobalShadows = originalGraphics.GlobalShadows
            Lighting.Ambient       = originalGraphics.Ambient
            Lighting.Brightness    = originalGraphics.Brightness
            Lighting.FogEnd        = originalGraphics.FogEnd
            Lighting.FogStart      = originalGraphics.FogStart
            for inst, wasEnabled in pairs(originalGraphics.EffectsEnabled) do
                if inst and inst.Parent then inst.Enabled = wasEnabled end
            end
            if terrain then
                terrain.WaterWaveSize     = originalGraphics.WaterProps.WaterWaveSize
                terrain.WaterReflectance  = originalGraphics.WaterReflectance
                terrain.WaterTransparency = originalGraphics.WaterTransparency
            end
            for _, particle in ipairs(Workspace:GetDescendants()) do
                if particle:IsA("ParticleEmitter") or particle:IsA("Trail") then
                    particle.Enabled = true
                end
            end
        end
    end
})
-- #### PERFORMANCE #### --
-- ===================== --

-- ==================== --
-- #### MISC UTILS #### --
miscGroupbox:AddButton({ Text = "Reset", Func = function()
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.Health = 0 end
end })

miscGroupbox:AddSlider("FOVSlider", { Text = "FOV", Default = camera.FieldOfView, Min = 50, Max = 120, Suffix = "°", Rounding = 0,
    Callback = function(value)
        camera.FieldOfView = value
    end
})
-- #### MISC UTILS #### --
-- ==================== --

-- ################## --
-- #### AUTO TAB #### --
-- ################## --

-- ============================== --
-- #### AUTO MISSION HELPERS #### --
local attachEnabled = false
local attachConn    = nil
local attachTargets = nil
local currentTarget = nil
local isMoving      = false
local hoverYOffset  = -10
local targetAncestryConn, targetHealthConn

local function getClosestMissionBoard(which)
    which = which or 1
    local folder = Workspace:FindFirstChild("NPCs")
    folder = folder and folder:FindFirstChild("MissionNPC")
    local hrp = humanoidRootPart
    if not (folder and hrp) then return end

    local best1, best2 = nil, nil
    local d1, d2 = math.huge, math.huge

    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local ok, union = pcall(function() return model.Board.Union end)
            if ok and union and union:IsA("BasePart") then
                local d = (union.Position - hrp.Position).Magnitude
                if d < d1 then
                    best2, d2 = best1, d1
                    best1, d1 = union, d
                elseif d < d2 then
                    best2, d2 = union, d
                end
            end
        end
    end

    local pick = (which == 2 and best2) or best1
    if pick then return pick, pick.Position end
end

local function disconnectTargetWatch()
	if targetAncestryConn then targetAncestryConn:Disconnect() targetAncestryConn = nil end
	if targetHealthConn  then targetHealthConn:Disconnect()  targetHealthConn  = nil end
end

local function watchTarget(inst)
	disconnectTargetWatch()
	targetAncestryConn = inst.AncestryChanged:Connect(function(_, parent)
		if not attachEnabled then return end
		if parent == nil or not inst:IsDescendantOf(Workspace) then
			currentTarget = nil
			stopHover()
		end
	end)
	local model = inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model")
	local hum = model and model:FindFirstChildOfClass("Humanoid")
	if hum then
		targetHealthConn = hum.HealthChanged:Connect(function(h)
			if not attachEnabled then return end
			if h <= 0 then
				currentTarget = nil
				stopHover()
			end
		end)
	end
end

local function pickTarget()
	if typeof(attachTargets) == "Instance" then
		if isEntityAlive(attachTargets) then return attachTargets end
		attachTargets = nil
	end
	local pool
	if typeof(attachTargets) == "table" then
		pool = {}
		for i = 1, #attachTargets do
			local obj = attachTargets[i]
			if obj and isEntityAlive(obj) then
				pool[#pool + 1] = obj
			end
		end
		if #pool == 0 then
			pool = rebuildEntitiesList()
		end
	else
		pool = rebuildEntitiesList()
	end

	attachTargets = pool
	if #pool == 0 then return nil end

	local closestObj = (getClosestPosition(humanoidRootPart.Position, pool))
	return closestObj
end

local function targetHoverPointAndLookAt(obj)
	local pos = getPosition(obj)
	if not pos then return nil, nil end

	local faceCF
	if obj:IsA("Model") then
		local hrp = obj:FindFirstChild("HumanoidRootPart")
		if hrp then faceCF = hrp.CFrame end
	else
		local model = obj:FindFirstAncestorOfClass("Model")
		local hrp = model and model:FindFirstChild("HumanoidRootPart")
		if hrp then faceCF = hrp.CFrame end
	end

	local myPos = humanoidRootPart.Position
	local dir = faceCF and faceCF.LookVector or (pos - myPos)
	if dir.Magnitude < 1e-6 then
		dir = humanoidRootPart.CFrame.LookVector
	else
		dir = dir.Unit
	end

	local hoverPoint = pos - dir * 3 + Vector3.new(0, hoverYOffset, 0)
	return hoverPoint, pos 
end

local function attachtarget(targets)
	attachTargets, attachEnabled = targets, true
	if attachConn then attachConn:Disconnect() attachConn = nil end
	local trackInterval, reacquireInterval, switchInterval = 1/12, 0.5, 0.4
	local switchHysteresis = 8
	local trackAcc, reacqAcc, switchAcc = 0, 0, 0
	local function pickFreshNearest()
		local pool = rebuildEntitiesList()
		if #pool == 0 then return nil end
		local nearestObj = select(1, getClosestPosition(humanoidRootPart.Position, pool))
		return nearestObj
	end

	attachConn = RunService.Heartbeat:Connect(function(dt)
		if not attachEnabled then return end
		trackAcc  += dt
		reacqAcc  += dt
		switchAcc += dt
		if currentTarget and not isEntityAlive(currentTarget) then
			currentTarget = nil
			stopHover()
		end
		if (not currentTarget) and reacqAcc >= reacquireInterval then
			reacqAcc = 0
			local newTarget = pickFreshNearest()
			if newTarget then
				currentTarget = newTarget
				watchTarget(currentTarget)
				local dest = select(1, targetHoverPointAndLookAt(currentTarget))
				if dest then
					isMoving = true
					stopHover()
					moveTo(dest, 150, false, function()
						isMoving = false
						hover(dest)
					end)
				end
			else
				stopHover()
			end
			return
		end

		if isMoving or not currentTarget then return end
		if trackAcc >= trackInterval then
			trackAcc = 0
			local dest, lookAtPoint = targetHoverPointAndLookAt(currentTarget)
			if dest and lookAtPoint then
				hoverPos = dest
				if _ao then _ao.CFrame = CFrame.lookAt(humanoidRootPart.Position, lookAtPoint) end
			else
				currentTarget = nil
				stopHover()
				return
			end
		end
		if switchAcc >= switchInterval and typeof(attachTargets) ~= "Instance" then
			switchAcc = 0

			local pool = rebuildEntitiesList()
			if #pool == 0 then return end

			local bestObj, bestPos = getClosestPosition(humanoidRootPart.Position, pool)
			if not bestObj or bestObj == currentTarget then return end

			local myPos   = humanoidRootPart.Position
			local currPos = getPosition(currentTarget)
			if not (bestPos and currPos) then return end

			local dBest = (bestPos - myPos).Magnitude
			local dCurr = (currPos - myPos).Magnitude
			if dBest + switchHysteresis < dCurr then
				currentTarget = bestObj
				watchTarget(currentTarget)
				local dest = select(1, targetHoverPointAndLookAt(currentTarget))
				if dest then
					isMoving = true
					stopHover()
					moveTo(dest, 150, false, function()
						isMoving = false
						hover(dest)
					end)
				end
			end
		end
	end)
end

local function detachtarget()
	attachEnabled = false
	if attachConn then attachConn:Disconnect() attachConn = nil end
	disconnectTargetWatch()
	currentTarget = nil
	isMoving = false
	stopHover()
end
-- #### AUTO MISSION HELPERS #### --
-- ============================== --

-- ========================= --
-- #### AUTO MISSION UI #### --
autoMissionGroup = Tabs.Auto:AddLeftGroupbox("AutoMission", "bot")
autoMissionGroup:AddLabel("autoMissionLabel", {
	Text = "Make sure you set the attacks and skills you want to use in AutoAttack (Main Tab)",
	DoesWrap = true,
})
autoMissionGroup:AddSlider("hoverOffsetSlider",{
	Text = "Hover Offset",
	Min = -30,
	Max = 30,
	Rounding = 1,
	Default = hoverYOffset,
	Callback = function(v) hoverYOffset = v end,
})

local autoMissionRunning = false
autoMissionGroup:AddToggle("autoMissionToggle",{
    Text = "AutoMission",
    Default = false,
    Callback = function(enabled)
        autoMissionRunning = enabled
        if enabled then
            task.spawn(function()
                local attached, goingBoard, usingAuto = false, false, false
                local lastTry, attemptStart = 0, 0
                local preferSecond = false

                while autoMissionRunning do
                    local pg = player:FindFirstChildOfClass("PlayerGui")
                    local q  = pg and pg:FindFirstChild("QueueUI")
                    local queued = q and q.Enabled or false

                    if queued then
                        if goingBoard then stopHover(); goingBoard = false end
                        if not attached then attachtarget(nil); attached = true end
                        if not usingAuto then startAutoAttack(); usingAuto = true end
                        autoAttackIncludeTarget = true
                        autoAttackTarget = currentTarget
                        preferSecond, attemptStart = false, 0
                    else
                        if attemptStart > 0 and (os.clock() - attemptStart) > 10 then
                            preferSecond = true
                            lastTry = 0          
                            attemptStart = 0
                        end

                        if attached then detachtarget(); attached = false end
                        if usingAuto then autoAttackEnabled = false; usingAuto = false end
                        autoAttackIncludeTarget = false
                        autoAttackTarget = nil

                        if (not goingBoard) and (os.clock() - lastTry > 3) then
                            goingBoard = true
                            local board, pos = getClosestMissionBoard(preferSecond and 2 or 1)
                            if board and pos then
                                stopHover()
                                moveTo(pos + Vector3.new(0, -10, 0), 150, true, function()
                                    fireAllClickDetectors(board)
                                    task.wait(1.5)
                                    for _,v in ipairs(player:GetDescendants()) do
										if v:IsA("RemoteEvent") and v.Name:lower():find("missionboard",1,true) then v:FireServer("Yes"); break end
									end
									task.wait(1)
                                    attemptStart = os.clock()
                                end)
                            end
                            lastTry = os.clock()
                            goingBoard = false
                        end
                    end

                    task.wait(0.25)
                end

                if attached then detachtarget() end
                if usingAuto then autoAttackEnabled = false end
                autoAttackIncludeTarget, autoAttackTarget = false, nil
                stopHover()
            end)
        else
            detachtarget()
            autoAttackEnabled = false
            autoAttackIncludeTarget, autoAttackTarget = false, nil
            stopHover()
        end
    end,
})
-- #### AUTO MISSION UI #### --
-- ========================= --

-- ======================== --
-- #### ATTACH HELPERS #### --
local function mergedEnemyOptions()
    if not entitiesFolder then return {} end
    local seen = {}
    for _, inst in ipairs(rebuildEntitiesList()) do
        local name = tostring(inst.Name or "")
        local base = name:match("^%u%l+") or name:match("^%a+") or name
        if base and base ~= "" then seen[base] = true end
    end
    local opts = {}
    for k in pairs(seen) do table.insert(opts, k) end
    table.sort(opts)
    return opts
end

local _origRebuild, _patched = nil, false

local function _baseName(s)
    s = tostring(s or "")
    return s:match("^%u%l+") or s:match("^%a+") or s
end

-- players list (Names only; excludes local)
local function mergedPlayerOptions()
    local out = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then out[#out+1] = plr.Name end
    end
    table.sort(out)
    return out
end

-- safe fetchers
local function _getDrop()
    local O = rawget(getgenv(), "Options") or (Library and Library.Options)
    return O and O.entitiesAttachDropdown or nil
end
local function _getPlayerDrop()
    local O = rawget(getgenv(), "Options") or (Library and Library.Options)
    return O and O.playersAttachDropdown or nil
end
local function _getToggle(idx)
    local T = rawget(getgenv(), "Toggles") or (Library and Library.Toggles)
    return T and T[idx] or nil
end
-- #### ATTACH HELPERS #### --
-- ======================== --


-- =================== --
-- #### ATTACH UI #### --
local attachGroupbox = Tabs.Auto:AddRightGroupbox("Attach", "swords")

-- Enemies dropdown (existing)
attachGroupbox:AddDropdown("entitiesAttachDropdown", {
    Text   = "Select Targets",
    Values = mergedEnemyOptions(),
    Multi  = false,
    Callback = function(_) end,
})

do
    local drop = _getDrop()
    if drop then
        local vals = drop.Values or {}
        if #vals > 0 then drop:SetValue(vals[1]) end
    end
end

attachGroupbox:AddButton({
    Text = "Refresh Targets",
    Func = function()
        local drop = _getDrop()
        if not drop then return end
        local prev = drop.Value
        local vals = mergedEnemyOptions()
        drop:SetValues(vals)
        if prev and table.find(vals, prev) then
            drop:SetValue(prev)
        elseif #vals > 0 then
            drop:SetValue(vals[1])
        end
    end,
})

attachGroupbox:AddToggle("attachToggle", {
    Text = "Attach To Closest Target",
    Default = false,
    Callback = function(on)
        local drop = _getDrop()
        if on then
            local sel = drop and drop.Value
            if not sel or sel == "" then
                Library:Notify("Select an Enemy Group first.", 3)
                local t = _getToggle("attachToggle"); if t then t:SetValue(false) end
                return
            end
            -- turn off player attach if on (avoid rebuild conflicts)
            local pt = _getToggle("attachPlayerToggle"); if pt and pt.Value then pt:SetValue(false) end

            if not _patched then
                _origRebuild = rebuildEntitiesList
                rebuildEntitiesList = function()
                    local want = (_getDrop() and _getDrop().Value) or ""
                    if want == "" then return {} end
                    local all = _origRebuild()
                    if type(all) ~= "table" then return {} end
                    local out = {}
                    for _, inst in ipairs(all) do
                        if inst and isEntityAlive(inst) and _baseName(inst.Name) == want then
                            out[#out+1] = inst
                        end
                    end
                    return out
                end
                _patched = true
            end
            detachtarget()
            attachtarget(nil)
        else
            detachtarget()
            if _patched and _origRebuild then
                rebuildEntitiesList = _origRebuild
            end
            _origRebuild, _patched = nil, false
        end
    end
})

do
    local drop = _getDrop()
    if drop then
        drop:OnChanged(function()
            local t = _getToggle("attachToggle")
            if t and t.Value then
                detachtarget()
                attachtarget(nil)
            end
        end)
    end
end

-- Players dropdown (new)
attachGroupbox:AddDropdown("playersAttachDropdown", {
    Text   = "Select Player",
    Values = mergedPlayerOptions(),
    Multi  = false,
    Callback = function(_) end,
})

do
    local pdrop = _getPlayerDrop()
    if pdrop then
        local vals = pdrop.Values or {}
        if #vals > 0 then pdrop:SetValue(vals[1]) end
    end
end

attachGroupbox:AddButton({
    Text = "Refresh Players",
    Func = function()
        local pdrop = _getPlayerDrop()
        if not pdrop then return end
        local prev = pdrop.Value
        local vals = mergedPlayerOptions()
        pdrop:SetValues(vals)
        if prev and table.find(vals, prev) then
            pdrop:SetValue(prev)
        elseif #vals > 0 then
            pdrop:SetValue(vals[1])
        end
    end
})

-- separate patch state for player attach (so we don't collide with enemy patching)
local _origRebuild_Player, _patched_Player = nil, false

attachGroupbox:AddToggle("attachPlayerToggle", {
    Text = "Attach To Selected Player",
    Default = false,
    Callback = function(on)
        local pdrop = _getPlayerDrop()
        if on then
            local name = pdrop and pdrop.Value
            if not name or name == "" then
                Library:Notify("Select a Player first.", 3)
                local t = _getToggle("attachPlayerToggle"); if t then t:SetValue(false) end
                return
            end
            -- turn off enemy attach if on
            local et = _getToggle("attachToggle"); if et and et.Value then et:SetValue(false) end

            if not _patched_Player then
                _origRebuild_Player = rebuildEntitiesList
                rebuildEntitiesList = function()
                    local sel = (_getPlayerDrop() and _getPlayerDrop().Value) or ""
                    if sel == "" then return {} end
                    local plr = Players:FindFirstChild(sel)
                    if not plr or not plr.Character then return {} end
                    local alive = isEntityAlive(plr.Character)
                    if alive then return { plr.Character } end
                    return {}
                end
                _patched_Player = true
            end
            detachtarget()
            attachtarget(nil)
        else
            detachtarget()
            if _patched_Player and _origRebuild_Player then
                rebuildEntitiesList = _origRebuild_Player
            end
            _origRebuild_Player, _patched_Player = nil, false
        end
    end
})

do
    local pdrop = _getPlayerDrop()
    if pdrop then
        pdrop:OnChanged(function()
            local t = _getToggle("attachPlayerToggle")
            if t and t.Value then
                detachtarget()
                attachtarget(nil)
            end
        end)
    end
end
-- #### ATTACH UI #### --
-- =================== --

-- =================== --
-- #### AUTO BOSS #### --
local autoBossGroupbox = Tabs.Auto:AddLeftGroupbox("AutoBoss", "skull")

autoBossGroupbox:AddButton({
    Text = "Go to Raid World",
    Func = function()
        if game.PlaceId ~= 14069678431 then
            if Library and Library.Notify then Library:Notify("You can only join from Karakura.", 3) end
            return
        end
        local model = workspace:FindFirstChild("NPCs")
        model = model and model:FindFirstChild("RaidBoss")
        model = model and model:FindFirstChild("Kisuke")
        if model then pcall(fireAllClickDetectors, model) end
        Library:Notify("Joining Raid World.", 3)
        task.wait(0.5)
        local rem = player and player:FindFirstChild("Kisuke")
        if rem then
            if typeof(rem.FireServer) == "function" then
                pcall(rem.FireServer, rem, "Yes")
            elseif typeof(rem.InvokeServer) == "function" then
                pcall(rem.InvokeServer, rem, "Yes")
            end
        end
    end
})

local autoReplay = { enabled = false, thread = nil }
autoBossGroupbox:AddToggle("autoReplayToggle", {
    Text = "Auto Replay",
    Default = false,
    Callback = function(state)
        autoReplay.enabled = state
        if not state then
            autoReplay.thread = nil
            return
        end
        if autoReplay.thread then return end
        autoReplay.thread = task.spawn(function()
            while autoReplay.enabled do
                local pg  = PlayerGui or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
                local sel = pg and pg:FindFirstChild("Options") and pg.Options:FindFirstChild("Replay")
                if sel then pcall(clickSelectionObject, sel) end
                for _ = 1, 50 do
                    if not autoReplay.enabled then break end
                    task.wait(0.1)
                end
            end
            autoReplay.thread = nil
        end)
    end
})

local BOSS_NAMES = {
	"The Cero King","Unohana","The Fear","Captain of the 6th Division","Captain of the 2nd Division",
	"The Almighty","Captain of the 12th Division","Kenpachi","The Tiger King","Captain of the 9th Division",
	"The Bone King","The Head Captain","Captain of the 8th Division","Captain of the 3rd Division","Captain of the 7th Division",
}

local selectedBosses = {}

autoBossGroupbox:AddDropdown("BossSelectMulti",{
	Text    = "Select Bosses",
	Values  = BOSS_NAMES,
	Default = {},
	Multi   = true,
	Callback = function(v)
		if v then
			if #v > 0 then
				selectedBosses = v
			else
				local out = {}
				for name, on in pairs(v) do if on then out[#out+1] = name end end
				selectedBosses = out
			end
		end
	end
})

local autoBossVote = { enabled = false, thread = nil }
autoBossGroupbox:AddToggle("AutoBossVote",{
	Text = "AutoBoss Select",
	Default = false,
	Callback = function(on)
		autoBossVote.enabled = on
		if not on then autoBossVote.thread = nil; return end
		if autoBossVote.thread then return end

		autoBossVote.thread = task.spawn(function()
			local rng = Random.new()
			while autoBossVote.enabled do
				local pg = PlayerGui or (Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"))
				local bc = pg and pg:FindFirstChild("BossChooser")

				if bc then
					local list = selectedBosses
					if #list == 0 and Options.BossSelectMulti and type(Options.BossSelectMulti.Value) == "table" then
						local tmp = {}
						for name, on in pairs(Options.BossSelectMulti.Value) do if on then tmp[#tmp+1] = name end end
						list = tmp
					end

					if #list > 0 then
						local pick = list[rng:NextInteger(1, #list)]
						local content = bc:FindFirstChild("BossList"); content = content and content:FindFirstChild("Content")
						local bossBtn = content and content:FindFirstChild(pick)
						if bossBtn then pcall(clickSelectionObject, bossBtn) end

						task.wait(1)
						local voteBtn = bc:FindFirstChild("Vote")
						if voteBtn then pcall(clickSelectionObject, voteBtn) end
					end
				end

				for _ = 1, 50 do
					if not autoBossVote.enabled then break end
					task.wait(0.1)
				end
			end
			autoBossVote.thread = nil
		end)
	end
})

local bossHoverOffset = -10
local autoBoss = {
    running = false,
    prevRebuild = nil,
    prevHover = nil,
    startedAA = false,
    -- removed time gate; we now gate on health %
    lockedTarget = nil,
}

autoBossGroupbox:AddSlider("autoBossOffsetSlider", {
    Text = "Boss Hover Offset",
    Min = -30, Max = 30, Rounding = 1,
    Default = bossHoverOffset,
    Callback = function(v)
        bossHoverOffset = v
        if autoBoss.running then hoverYOffset = v end
    end
})

autoBossGroupbox:AddToggle("autoBossToggle", {
    Text = "AutoBoss",
    Default = false,
    Callback = function(on)
        local attachT = _getToggle("attachToggle")

        if on then
            if attachT and attachT.Value then attachT:SetValue(false) end
            autoBoss.running      = true
            autoBoss.lockedTarget = nil
            autoBoss.prevRebuild  = rebuildEntitiesList
            if _patched and _origRebuild then
                rebuildEntitiesList = _origRebuild
            end
            autoBoss.prevHover = hoverYOffset
            hoverYOffset = bossHoverOffset

            detachtarget()
            attachtarget(nil)

            if not autoAttackEnabled then
                startAutoAttack()
                autoBoss.startedAA = true
            else
                autoBoss.startedAA = false
            end
            autoAttackIncludeTarget = true

            task.spawn(function()
                while autoBoss.running do
                    autoAttackTarget = currentTarget
                    hoverYOffset = bossHoverOffset

                    if not autoBoss.lockedTarget and currentTarget then
                        autoBoss.lockedTarget = currentTarget
                    end

                    local inst  = autoBoss.lockedTarget
                    local model = inst and (inst:IsA("Model") and inst or inst:FindFirstAncestorOfClass("Model"))

                    if model and model.Parent and model:IsDescendantOf(Workspace) then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum then
                            local hp, maxhp = tonumber(hum.Health) or 0, tonumber(hum.MaxHealth) or 0
                            local ratio = (maxhp > 0) and (hp / maxhp) or 0 
                            if (ratio <= 0.85) then
                                pcall(killEntity, model)
                            end
                        end
                    else
                        autoBoss.lockedTarget = nil
                    end

                    task.wait(1)
                end
                autoAttackIncludeTarget, autoAttackTarget = false, nil
                if autoBoss.startedAA then autoAttackEnabled = false end
                detachtarget()
                if autoBoss.prevRebuild then rebuildEntitiesList = autoBoss.prevRebuild end
                if autoBoss.prevHover ~= nil then hoverYOffset = autoBoss.prevHover end
                autoBoss.prevRebuild, autoBoss.prevHover, autoBoss.startedAA = nil, nil, false
                autoBoss.lockedTarget = nil
            end)
        else
            autoBoss.running = false
        end
    end
})

-- ========================== --
-- #### AUTO MATCHMAKING #### --
local matchmaking_place = 18637069183
local autoMatchmakingGroupbox = Tabs.Auto:AddRightGroupbox("Matchmaking", "users")

local function _getModeDrop()
    local O = rawget(getgenv(), "Options") or (Library and Library.Options)
    return O and O.selectModeDropdown or nil
end
local function _mmOn()
    local T = rawget(getgenv(), "Toggles") or (Library and Library.Toggles)
    local t = T and T.autoMatchmakingToggle
    return (t and t.Value) or false
end

autoMatchmakingGroupbox:AddDropdown("selectModeDropdown", {
    Values = { "CULLING GAMES","SOUL WARS","CASCADE","KING OF THE WORLD","1 VS 1","2 VS 2","3 VS 3" },
    Default = "CULLING GAMES",
    Multi   = false,
    Text    = "Select Mode",
    Callback = function(_) end,
})

local function fireJoinQueue(mode)
    local d = _getModeDrop()
    mode = tostring(mode or (d and d.Value) or "CULLING GAMES")
    local rem  = ReplicatedStorage:FindFirstChild("Remotes")
    local team = rem and rem:FindFirstChild("Team")
    if team then pcall(function() team:FireServer("JoinQueue", mode) end) end
end

local loopTask = nil
autoMatchmakingGroupbox:AddToggle("autoMatchmakingToggle", {
    Text = "Auto Matchmaking",
    Default = false,
    Callback = function(on)
        if on then
            if loopTask then return end
            loopTask = task.spawn(function()
                local joinedThisSession = false
                while _mmOn() do
                    if game.PlaceId == matchmaking_place then
                        if not joinedThisSession then
                            task.wait(5)
                            if not _mmOn() then break end
                            fireJoinQueue()
                            local t0 = os.clock()
                            while _mmOn() and (os.clock() - t0) < 30 do task.wait(0.1) end
                            if not _mmOn() then break end
                            fireJoinQueue() 
                            joinedThisSession = true
                        end
                    else
                        joinedThisSession = false
                    end
                    task.wait(0.25)
                end
                loopTask = nil
            end)
        else
        end
    end
})
-- #### AUTO MATCHMAKING #### --
-- ========================== --

-- #################### --
-- #### COMBAT TAB #### --
-- #################### --

-- ============================ --
-- #### AUTO PARRY HELPERS #### --
local defaultParryConfig = [[
[{"id":"13406497745","name":"Kneel","hitFrameTime":0.4},{"id":"14068255583","name":"Critical","hitFrameTime":0.517},{"id":"14068257009","name":"LightAttack5","hitFrameTime":0.433},{"id":"14068263374","name":"LightAttack2","hitFrameTime":0.417},{"id":"14068264382","name":"LightAttack1","hitFrameTime":0.417},{"id":"14068978735","name":"Critical","hitFrameTime":0.6},{"id":"14068981715","name":"LightAttack1","hitFrameTime":0.433},{"id":"14068983556","name":"LightAttack2","hitFrameTime":0.433},{"id":"14068997392","name":"Critical","hitFrameTime":0.483},{"id":"14069009404","name":"LightAttack1","hitFrameTime":0.433},{"id":"14069010389","name":"","hitFrameTime":0.433},{"id":"14069017740","name":"","hitFrameTime":0.433},{"id":"14069034915","name":"Critical","hitFrameTime":0.633},{"id":"14069058915","name":"LightAttack1","hitFrameTime":0.417},{"id":"14069061280","name":"LightAttack2","hitFrameTime":0.433},{"id":"14069063230","name":"LightAttack3","hitFrameTime":0.417},{"id":"14069065165","name":"LightAttack4","hitFrameTime":0.425},{"id":"14069066675","name":"LightAttack5","hitFrameTime":0.6},{"id":"14069106034","name":"Block","hitFrameTime":0.4},{"id":"14069107305","name":"BlockHit","hitFrameTime":0.4},{"id":"14069109188","name":"Critical","hitFrameTime":0.533},{"id":"14069110705","name":"Deflected1","hitFrameTime":0.4},{"id":"14069111857","name":"Deflected2","hitFrameTime":0.4},{"id":"14069117225","name":"Grip","hitFrameTime":0.4},{"id":"14069119416","name":"Gripped","hitFrameTime":0.4},{"id":"14069126339","name":"LightAttack1","hitFrameTime":0.4},{"id":"14069127474","name":"LightAttack2","hitFrameTime":0.4},{"id":"14069131362","name":"LightAttack3","hitFrameTime":0.4},{"id":"14069132593","name":"LightAttack4","hitFrameTime":0.4},{"id":"14069133993","name":"LightAttack5","hitFrameTime":0.4},{"id":"14069137920","name":"Parry","hitFrameTime":0.4},{"id":"14069140030","name":"Parrying1","hitFrameTime":0.4},{"id":"14069141165","name":"Parrying2","hitFrameTime":0.4},{"id":"14069142419","name":"Sprint","hitFrameTime":0.4},{"id":"14069149162","name":"LightAttack1","hitFrameTime":0.583},{"id":"14069151789","name":"LightAttack3","hitFrameTime":0.6},{"id":"14069153879","name":"LightAttack4","hitFrameTime":0.4},{"id":"14069155248","name":"LightAttack5","hitFrameTime":0.4},{"id":"14069170145","name":"","hitFrameTime":0.325},{"id":"14069185844","name":"LightAttack1","hitFrameTime":0.417},{"id":"14069186980","name":"LightAttack2","hitFrameTime":0.417},{"id":"14069188532","name":"LightAttack3","hitFrameTime":0.417},{"id":"14069190199","name":"LightAttack4","hitFrameTime":0.417},{"id":"14069191458","name":"LightAttack5","hitFrameTime":0.417},{"id":"14069237877","name":"LightAttack1","hitFrameTime":0.417},{"id":"14069239027","name":"LightAttack2","hitFrameTime":0.417},{"id":"14069241762","name":"","hitFrameTime":0.417},{"id":"14069281959","name":"LightAttack1","hitFrameTime":0.383},{"id":"14069352086","name":"LightAttack1","hitFrameTime":0.45},{"id":"14069353222","name":"LightAttack2","hitFrameTime":0.45},{"id":"14069354535","name":"LightAttack3","hitFrameTime":0.483},{"id":"14069355606","name":"LightAttack4","hitFrameTime":0.533},{"id":"14069362279","name":"LightAttack5","hitFrameTime":0.475},{"id":"14069394981","name":"LightAttack1","hitFrameTime":0.433},{"id":"14069396446","name":"","hitFrameTime":0.433},{"id":"14069404555","name":"LightAttack4","hitFrameTime":0.433},{"id":"14069405919","name":"LightAttack5","hitFrameTime":0.433},{"id":"14069413304","name":"LightAttack1","hitFrameTime":0.433},{"id":"14069414178","name":"LightAttack2","hitFrameTime":0.45},{"id":"14069418978","name":"Critical","hitFrameTime":0.567},{"id":"14069440034","name":"Critical","hitFrameTime":0.5},{"id":"14069449901","name":"LightAttack1","hitFrameTime":0.417},{"id":"14069451875","name":"","hitFrameTime":0.417},{"id":"14069453052","name":"","hitFrameTime":0.417},{"id":"14069454554","name":"","hitFrameTime":0.417},{"id":"14069465592","name":"Critical","hitFrameTime":0.483},{"id":"14069469794","name":"LightAttack3","hitFrameTime":0.4},{"id":"14069869663","name":"Sword","hitFrameTime":0.5},{"id":"14069871085","name":"Crumble","hitFrameTime":0.4},{"id":"14069871811","name":"Sword","hitFrameTime":0.5},{"id":"14069872547","name":"Crumble","hitFrameTime":0.4},{"id":"14069916307","name":"Critical","hitFrameTime":0.567},{"id":"14069933789","name":"LightAttack1","hitFrameTime":0.383},{"id":"14069935839","name":"LightAttack2","hitFrameTime":0.383},{"id":"14069938678","name":"LightAttack3","hitFrameTime":0.383},{"id":"14069940723","name":"LightAttack4","hitFrameTime":0.383},{"id":"14069942258","name":"LightAttack5","hitFrameTime":0.383},{"id":"14070027026","name":"Block","hitFrameTime":0.4},{"id":"14070029680","name":"Critical","hitFrameTime":0.5},{"id":"14070032456","name":"Deflected1","hitFrameTime":0.4},{"id":"14070033247","name":"Deflected2","hitFrameTime":0.4},{"id":"14070034321","name":"Draw1","hitFrameTime":0.4},{"id":"14070037116","name":"Idle1","hitFrameTime":0.4},{"id":"14070037892","name":"Idle2","hitFrameTime":0.4},{"id":"14070038819","name":"LightAttack1","hitFrameTime":0.433},{"id":"14070039756","name":"LightAttack2","hitFrameTime":0.4},{"id":"14070040505","name":"LightAttack3","hitFrameTime":0.4},{"id":"14070041852","name":"LightAttack4","hitFrameTime":0.4},{"id":"14070043081","name":"LightAttack5","hitFrameTime":0.4},{"id":"14070044495","name":"Parry","hitFrameTime":0.4},{"id":"14070045375","name":"Parrying1","hitFrameTime":0.4},{"id":"14070046160","name":"Parrying2","hitFrameTime":0.4},{"id":"14070047196","name":"Sprint","hitFrameTime":0.4},{"id":"14070058236","name":"Block","hitFrameTime":0.4},{"id":"14070059412","name":"BlockHit","hitFrameTime":0.4},{"id":"14070060393","name":"Critical","hitFrameTime":0.6},{"id":"14070061419","name":"Deflected1","hitFrameTime":0.4},{"id":"14070062352","name":"Deflected2","hitFrameTime":0.4},{"id":"14070063494","name":"Draw1","hitFrameTime":0.4},{"id":"14070064469","name":"Draw2","hitFrameTime":0.4},{"id":"14070065324","name":"Draw3","hitFrameTime":0.4},{"id":"14070066303","name":"Draw4","hitFrameTime":0.4},{"id":"14070067279","name":"Grip","hitFrameTime":0.4},{"id":"14070069686","name":"Idle1","hitFrameTime":0.4},{"id":"14070070713","name":"Idle2","hitFrameTime":0.4},{"id":"14070071816","name":"Idle3","hitFrameTime":0.4},{"id":"14070072624","name":"LightAttack1","hitFrameTime":0.467},{"id":"14070073772","name":"LightAttack2","hitFrameTime":0.467},{"id":"14070074688","name":"LightAttack3","hitFrameTime":0.417},{"id":"14070075681","name":"LightAttack4","hitFrameTime":0.417},{"id":"14070076756","name":"LightAttack5","hitFrameTime":0.433},{"id":"14070077646","name":"Parry","hitFrameTime":0.4},{"id":"14070078489","name":"Parrying1","hitFrameTime":0.4},{"id":"14070080166","name":"Parrying2","hitFrameTime":0.4},{"id":"14070081938","name":"ShikaiDraw1","hitFrameTime":0.4},{"id":"14070082649","name":"ShikaiDraw2","hitFrameTime":0.4},{"id":"14070084160","name":"ShikaiDraw3","hitFrameTime":0.4},{"id":"14070085241","name":"Sprint","hitFrameTime":0.4},{"id":"14070163707","name":"LightAttack1","hitFrameTime":0.45},{"id":"14070196670","name":"Critical","hitFrameTime":0.683},{"id":"14070207166","name":"LightAttack1","hitFrameTime":0.45},{"id":"14070208109","name":"LightAttack2","hitFrameTime":0.45},{"id":"14070209278","name":"LightAttack3","hitFrameTime":0.45},{"id":"14070210472","name":"LightAttack4","hitFrameTime":0.45},{"id":"14070211253","name":"LightAttack5","hitFrameTime":0.45},{"id":"14070242975","name":"Block","hitFrameTime":0.4},{"id":"14070243814","name":"BlockHit","hitFrameTime":0.4},{"id":"14070244842","name":"Critical","hitFrameTime":0.533},{"id":"14070246255","name":"Deflected1","hitFrameTime":0.4},{"id":"14070247210","name":"Deflected2","hitFrameTime":0.4},{"id":"14070248213","name":"Draw1","hitFrameTime":0.4},{"id":"14070249198","name":"Grip","hitFrameTime":0.4},{"id":"14070250949","name":"Gripped","hitFrameTime":0.4},{"id":"14070252277","name":"Idle1","hitFrameTime":0.4},{"id":"14070253349","name":"LightAttack1","hitFrameTime":0.417},{"id":"14070254724","name":"LightAttack2","hitFrameTime":0.417},{"id":"14070255779","name":"LightAttack3","hitFrameTime":0.417},{"id":"14070257029","name":"LightAttack4","hitFrameTime":0.417},{"id":"14070257930","name":"LightAttack5","hitFrameTime":0.433},{"id":"14070258976","name":"Parry","hitFrameTime":0.4},{"id":"14070260015","name":"Parrying1","hitFrameTime":0.4},{"id":"14070260856","name":"Parrying2","hitFrameTime":0.4},{"id":"14070261819","name":"Sprint","hitFrameTime":0.4},{"id":"14070270084","name":"Critical","hitFrameTime":0.533},{"id":"14070273745","name":"Block","hitFrameTime":0.4},{"id":"14070275160","name":"BlockHit","hitFrameTime":0.4},{"id":"14070276168","name":"Critical","hitFrameTime":0.533},{"id":"14070277294","name":"Deflected1","hitFrameTime":0.4},{"id":"14070278620","name":"Deflected2","hitFrameTime":0.4},{"id":"14070279637","name":"Draw1","hitFrameTime":0.4},{"id":"14070280587","name":"Grip","hitFrameTime":0.4},{"id":"14070282275","name":"Gripped","hitFrameTime":0.4},{"id":"14070284327","name":"LightAttack2","hitFrameTime":0.4},{"id":"14070285319","name":"LightAttack3","hitFrameTime":0.4},{"id":"14070286355","name":"LightAttack4","hitFrameTime":0.4},{"id":"14070287232","name":"LightAttack5","hitFrameTime":0.4},{"id":"14070288948","name":"Parry","hitFrameTime":0.4},{"id":"14070289961","name":"Parrying1","hitFrameTime":0.4},{"id":"14070291068","name":"Parrying2","hitFrameTime":0.4},{"id":"14070292427","name":"Sprint","hitFrameTime":0.4},{"id":"14070296234","name":"Critical","hitFrameTime":0.533},{"id":"14070297611","name":"LightAttack1","hitFrameTime":0.417},{"id":"14070298769","name":"LightAttack2","hitFrameTime":0.417},{"id":"14070299881","name":"LightAttack3","hitFrameTime":0.417},{"id":"14070301171","name":"LightAttack4","hitFrameTime":0.417},{"id":"14070302098","name":"LightAttack5","hitFrameTime":0.433},{"id":"14070310188","name":"Critical","hitFrameTime":0.733},{"id":"14070311800","name":"LightAttack1","hitFrameTime":0.45},{"id":"14070312870","name":"LightAttack2","hitFrameTime":0.425},{"id":"14070323563","name":"Block","hitFrameTime":0.4},{"id":"14070324809","name":"BlockHit","hitFrameTime":0.4},{"id":"14070325851","name":"Critical","hitFrameTime":0.533},{"id":"14070327258","name":"Deflected1","hitFrameTime":0.4},{"id":"14070329090","name":"Deflected2","hitFrameTime":0.4},{"id":"14070330113","name":"Draw1","hitFrameTime":0.4},{"id":"14070331480","name":"Grip","hitFrameTime":0.4},{"id":"14070332666","name":"Gripped","hitFrameTime":0.4},{"id":"14070333956","name":"Idle1","hitFrameTime":0.4},{"id":"14070335315","name":"LightAttack1","hitFrameTime":0.417},{"id":"14070336542","name":"LightAttack2","hitFrameTime":0.417},{"id":"14070337700","name":"LightAttack3","hitFrameTime":0.417},{"id":"14070338988","name":"LightAttack4","hitFrameTime":0.417},{"id":"14070340037","name":"LightAttack5","hitFrameTime":0.433},{"id":"14070341077","name":"Parry","hitFrameTime":0.4},{"id":"14070342266","name":"Parrying1","hitFrameTime":0.4},{"id":"14070343676","name":"Parrying2","hitFrameTime":0.4},{"id":"14070344754","name":"ShikaiDraw1","hitFrameTime":0.4},{"id":"14070345451","name":"ShikaiDraw2","hitFrameTime":0.4},{"id":"14070346199","name":"ShikaiDraw3","hitFrameTime":0.4},{"id":"14070347357","name":"Sprint","hitFrameTime":0.4},{"id":"14070359369","name":"Block","hitFrameTime":0.4},{"id":"14070360764","name":"BlockHit","hitFrameTime":0.4},{"id":"14070362162","name":"Critical","hitFrameTime":0.7},{"id":"14070363609","name":"Deflected1","hitFrameTime":0.4},{"id":"14070366020","name":"Deflected2","hitFrameTime":0.4},{"id":"14070369375","name":"Grip","hitFrameTime":0.4},{"id":"14070370539","name":"Gripped","hitFrameTime":0.4},{"id":"14070371463","name":"Idle1","hitFrameTime":0.4},{"id":"14070372787","name":"LightAttack1","hitFrameTime":0.467},{"id":"14070373836","name":"LightAttack2","hitFrameTime":0.467},{"id":"14070374931","name":"LightAttack3","hitFrameTime":0.442},{"id":"14070376612","name":"LightAttack4","hitFrameTime":0.467},{"id":"14070378151","name":"LightAttack5","hitFrameTime":0.4},{"id":"14070379401","name":"Parry","hitFrameTime":0.4},{"id":"14070380344","name":"Parrying1","hitFrameTime":0.4},{"id":"14070417983","name":"Critical","hitFrameTime":0.533},{"id":"14070420647","name":"LightAttack1","hitFrameTime":0.45},{"id":"14070422780","name":"","hitFrameTime":0.45},{"id":"14070425159","name":"","hitFrameTime":0.415},{"id":"14070427500","name":"StandIdle","hitFrameTime":0.4},{"id":"14070429541","name":"Walk","hitFrameTime":0.4},{"id":"14070431270","name":"Run","hitFrameTime":0.4},{"id":"14070432845","name":"Fall","hitFrameTime":0.4},{"id":"14070434867","name":"Jump","hitFrameTime":0.4},{"id":"14070436817","name":"Climb","hitFrameTime":0.4},{"id":"14070458696","name":"Grip","hitFrameTime":0.4},{"id":"14070460148","name":"Gripped","hitFrameTime":0.4},{"id":"14070502124","name":"Critical","hitFrameTime":0.533},{"id":"14070512628","name":"","hitFrameTime":0.533},{"id":"14070513782","name":"","hitFrameTime":0.55},{"id":"14070514579","name":"","hitFrameTime":0.55},{"id":"14070515867","name":"","hitFrameTime":0.5},{"id":"14070517297","name":"","hitFrameTime":0.5},{"id":"14070523179","name":"","hitFrameTime":0.517},{"id":"14070534582","name":"Block","hitFrameTime":0.4},{"id":"14070535941","name":"BlockHit","hitFrameTime":0.4},{"id":"14070537001","name":"Critical","hitFrameTime":0.533},{"id":"14070538682","name":"Deflected1","hitFrameTime":0.4},{"id":"14070539924","name":"Deflected2","hitFrameTime":0.4},{"id":"14070541907","name":"Draw1","hitFrameTime":0.4},{"id":"14070543159","name":"Grip","hitFrameTime":0.4},{"id":"14070545003","name":"Gripped","hitFrameTime":0.4},{"id":"14070546542","name":"Idle1","hitFrameTime":0.4},{"id":"14070548188","name":"Idle2","hitFrameTime":0.4},{"id":"14070549660","name":"Idle3","hitFrameTime":0.4},{"id":"14070551048","name":"LightAttack1","hitFrameTime":0.417},{"id":"14070552124","name":"LightAttack2","hitFrameTime":0.417},{"id":"14070553085","name":"LightAttack3","hitFrameTime":0.417},{"id":"14070554241","name":"LightAttack4","hitFrameTime":0.417},{"id":"14070555368","name":"LightAttack5","hitFrameTime":0.433},{"id":"14070556673","name":"Parry","hitFrameTime":0.4},{"id":"14070558152","name":"Parrying1","hitFrameTime":0.4},{"id":"14070558994","name":"Parrying2","hitFrameTime":0.4},{"id":"14070560438","name":"Sprint","hitFrameTime":0.4},{"id":"14070711955","name":"LightAttack1","hitFrameTime":0.4},{"id":"14070792997","name":"","hitFrameTime":0.55},{"id":"14070794188","name":"","hitFrameTime":0.517},{"id":"14070795201","name":"","hitFrameTime":0.5},{"id":"14070798738","name":"","hitFrameTime":1.133},{"id":"14070826348","name":"SkillCoil","hitFrameTime":1.133},{"id":"14070828345","name":"SkillDoubleChomp","hitFrameTime":0.617},{"id":"14070831019","name":"SkillSpin","hitFrameTime":0.5},{"id":"14070836033","name":"Attack1","hitFrameTime":0.467},{"id":"14070837481","name":"","hitFrameTime":0.467},{"id":"14070839321","name":"Critical","hitFrameTime":0.733},{"id":"14070903616","name":"Attack1","hitFrameTime":0.883},{"id":"14071043907","name":"ShikaiSkillRavage","hitFrameTime":0.35},{"id":"14071056551","name":"","hitFrameTime":0.467},{"id":"14071059756","name":"","hitFrameTime":0.55},{"id":"14071109979","name":"ShikaiSkillPayday","hitFrameTime":0.75},{"id":"14071146010","name":"ShikaiSkillWarcry","hitFrameTime":0.5},{"id":"14071264235","name":"","hitFrameTime":0.415},{"id":"14071265653","name":"","hitFrameTime":0.415},{"id":"14071267348","name":"","hitFrameTime":0.415},{"id":"14071268751","name":"","hitFrameTime":0.567},{"id":"14071304790","name":"ShikaiSkillBararaq","hitFrameTime":0.7},{"id":"14071354880","name":"ShikaiSkillConclaveSilence","hitFrameTime":0.45},{"id":"14071361441","name":"ShikaiSkillWindPrison","hitFrameTime":0.5},{"id":"14071441469","name":"ShikaiSkillGiftBad","hitFrameTime":0.5},{"id":"14071443110","name":"ShikaiSkillGiftBall","hitFrameTime":0.517},{"id":"14071445772","name":"ShikaiSkillGiftRing","hitFrameTime":1.433},{"id":"14071458561","name":"ShikaiSkillBurnerFinger1","hitFrameTime":0.5},{"id":"14071461210","name":"ShikaiSkillBurnerFinger3","hitFrameTime":0.6},{"id":"14071462608","name":"ShikaiSkillBurnerFinger4","hitFrameTime":0.633},{"id":"14071463879","name":"ShikaiSkillBurningStomp","hitFrameTime":0.617},{"id":"14071465145","name":"ShikaiSkillFullBurnerFinger","hitFrameTime":0.783},{"id":"14071468437","name":"ShikaiSkillDivinePresence","hitFrameTime":0.55},{"id":"14071471740","name":"ShikaiSkillDivineShot","hitFrameTime":1.05},{"id":"14071474708","name":"ShikaiSkillGodsAuthority","hitFrameTime":0.467},{"id":"14071492012","name":"","hitFrameTime":1.217},{"id":"14071514809","name":"CaughtDragon","hitFrameTime":0.4},{"id":"14071520599","name":"GrabbedByShori","hitFrameTime":0.4},{"id":"14071522684","name":"SkillAbsoluteDefense","hitFrameTime":0.55},{"id":"14071527834","name":"SkillCatchingDragonInitial","hitFrameTime":0.583},{"id":"14071530962","name":"SkillDeathFlairAir","hitFrameTime":0.5},{"id":"14071532590","name":"SkillDemonicEmbrace","hitFrameTime":0.633},{"id":"14071534340","name":"SkillGehenna","hitFrameTime":0.467},{"id":"14071536135","name":"SkillGehennaAir","hitFrameTime":0.3},{"id":"14071541859","name":"SkillNegation","hitFrameTime":0.5},{"id":"14071543948","name":"SkillNegationAir","hitFrameTime":0.467},{"id":"14071545730","name":"SkillNegationOLD","hitFrameTime":0.5},{"id":"14071546900","name":"SkillNegationSuccess","hitFrameTime":0.533},{"id":"14071548275","name":"SkillPantheraCombo","hitFrameTime":0.6},{"id":"14071551958","name":"SkillReiatsuPush","hitFrameTime":0.5},{"id":"14071553774","name":"SkillRisingShot","hitFrameTime":0.483},{"id":"14071555902","name":"SkillShori","hitFrameTime":0.5},{"id":"14071556976","name":"SkillShoriGrabbed","hitFrameTime":0.6},{"id":"14071558168","name":"SkillSpineRend","hitFrameTime":0.8},{"id":"14071559270","name":"SkillToraReach","hitFrameTime":0.567},{"id":"14071561150","name":"SkillToraReachAir","hitFrameTime":0.5},{"id":"14071563707","name":"SkillWhirlwindStep","hitFrameTime":0.5},{"id":"14071565063","name":"TripleStrikerTarget","hitFrameTime":0.4},{"id":"14071570092","name":"SkillRustingSteel","hitFrameTime":0.5},{"id":"14071571127","name":"SkillPalewind","hitFrameTime":0.5},{"id":"14071572390","name":"SkillBlindSeeker","hitFrameTime":0.5},{"id":"14071573432","name":"SkillSparkExchange","hitFrameTime":0.5},{"id":"14071574532","name":"SkillVanishingBurial","hitFrameTime":0.5},{"id":"14071575669","name":"SkillReshape","hitFrameTime":0.5},{"id":"14071595510","name":"","hitFrameTime":0.383},{"id":"14071596676","name":"","hitFrameTime":0.383},{"id":"14071597965","name":"SkillBalaBarrage","hitFrameTime":0.65},{"id":"14071601610","name":"SkillBalaDrive","hitFrameTime":0.7},{"id":"14071603145","name":"SkillBalaDriveDownslam","hitFrameTime":0.383},{"id":"14071605011","name":"SkillBalaGum","hitFrameTime":0.55},{"id":"14071606661","name":"SkillBladeCero","hitFrameTime":1.2},{"id":"14071609753","name":"SkillCeroConfinement","hitFrameTime":0.7},{"id":"14071612854","name":"SkillCeroFireflies","hitFrameTime":0.433},{"id":"14071614685","name":"SkillCeroGrab","hitFrameTime":0.5},{"id":"14071616956","name":"SkillCeroOscuras","hitFrameTime":1.5},{"id":"14071618210","name":"SkillCeroSweep","hitFrameTime":0.7},{"id":"14071622242","name":"SkillHollowBite","hitFrameTime":0.483},{"id":"14071624623","name":"SkillTriCero","hitFrameTime":1.533},{"id":"14071628131","name":"SkillBisection","hitFrameTime":0.667},{"id":"14071632343","name":"SkillDelayedCrossings","hitFrameTime":0.8},{"id":"14071633768","name":"SkillEviscerate","hitFrameTime":0.75},{"id":"14071635270","name":"SkillFlowerPassage","hitFrameTime":0.8},{"id":"14071640478","name":"SkillViper","hitFrameTime":0.5},{"id":"14071640490","name":"SkillFlowerPassageAerial","hitFrameTime":0.817},{"id":"14071641580","name":"SkillFeast","hitFrameTime":0.5},{"id":"14071642506","name":"SkillMortalTies","hitFrameTime":0.867},{"id":"14071642983","name":"SkillDiscordance","hitFrameTime":0.5},{"id":"14071644383","name":"SkillOverpoweringSlash","hitFrameTime":0.683},{"id":"14071644909","name":"SkillShotgunBlow","hitFrameTime":0.5},{"id":"14071646099","name":"SkillDismissal","hitFrameTime":0.5},{"id":"14071647225","name":"SkillJudgement","hitFrameTime":0.5},{"id":"14071648447","name":"SkillSeismicWave","hitFrameTime":0.5},{"id":"14071648861","name":"SkillRisingSwallow","hitFrameTime":0.467},{"id":"14071650108","name":"SkillSenmaioroshi","hitFrameTime":0.55},{"id":"14071651317","name":"SkillSonataFlow","hitFrameTime":0.533},{"id":"14071651673","name":"SkillResonance","hitFrameTime":0.5},{"id":"14071652427","name":"SkillSplitGate","hitFrameTime":0.583},{"id":"14071653124","name":"SkillRaze","hitFrameTime":0.5},{"id":"14071653586","name":"SkillSuikawari","hitFrameTime":0.775},{"id":"14071654292","name":"SkillResonanceActive","hitFrameTime":0.4},{"id":"14071654671","name":"SkillThrust","hitFrameTime":0.55},{"id":"14071655810","name":"","hitFrameTime":0.45},{"id":"14071657488","name":"SkillVerticalDown","hitFrameTime":0.5},{"id":"14071664552","name":"","hitFrameTime":0.55},{"id":"14071666095","name":"","hitFrameTime":0.617},{"id":"14071667644","name":"SkillMetalJacket","hitFrameTime":0.5},{"id":"14071669132","name":"SkillUnwillingSacrifice","hitFrameTime":0.5},{"id":"14071670353","name":"SkillUnseenEyes","hitFrameTime":0.5},{"id":"14071671623","name":"SkillFocalPoint","hitFrameTime":0.567},{"id":"14071671675","name":"SkillSavagery","hitFrameTime":0.5},{"id":"14071673083","name":"SkillMaul","hitFrameTime":0.5},{"id":"14071673176","name":"","hitFrameTime":1.15},{"id":"14071674414","name":"SkillDrawnQuarters","hitFrameTime":0.5},{"id":"14071675871","name":"SkillComradeinArms","hitFrameTime":0.5},{"id":"14071677088","name":"SkillRagnarok","hitFrameTime":0.5},{"id":"14071678361","name":"SkillInferno","hitFrameTime":0.5},{"id":"14071679580","name":"SkillDiable","hitFrameTime":0.5},{"id":"14071680717","name":"SkillOminousNebula","hitFrameTime":0.5},{"id":"14071681882","name":"SkillEnforcedAnchor","hitFrameTime":0.5},{"id":"14071683242","name":"SkillKindle","hitFrameTime":0.5},{"id":"14071684502","name":"SkillGrind","hitFrameTime":0.5},{"id":"14071685941","name":"SkillBlockBreak","hitFrameTime":0.5},{"id":"14071686875","name":"SkillLichtRegen","hitFrameTime":0.833},{"id":"14071687329","name":"SkillExecutioner","hitFrameTime":0.5},{"id":"14071688751","name":"SkillOneHandedGravity","hitFrameTime":0.5},{"id":"14071689928","name":"SkillRapidJabs","hitFrameTime":0.5},{"id":"14071690484","name":"SkillPiercingLight","hitFrameTime":0.5},{"id":"14071691259","name":"SkillLariat","hitFrameTime":0.5},{"id":"14071692128","name":"SkillReishiString","hitFrameTime":0.8},{"id":"14071692611","name":"SkillFlyingPanther","hitFrameTime":0.5},{"id":"14071694023","name":"SkillSkewer","hitFrameTime":0.5},{"id":"14071695362","name":"SkillFiresnap","hitFrameTime":0.5},{"id":"14071696638","name":"SkillExtremities","hitFrameTime":0.5},{"id":"14071697818","name":"SkillCityTremor","hitFrameTime":0.5},{"id":"14071699052","name":"SkillTwinDragonKick","hitFrameTime":0.5},{"id":"14071700142","name":"SkillRisingClaw","hitFrameTime":0.5},{"id":"14071700196","name":"SkillSlide","hitFrameTime":0.233},{"id":"14071701379","name":"SkillDraconicCrusher","hitFrameTime":0.5},{"id":"14071702605","name":"SkillInterceptingStrike","hitFrameTime":0.5},{"id":"14071703407","name":"SkillStillSilver","hitFrameTime":0.9},{"id":"14071703786","name":"SkillMockExecution","hitFrameTime":0.5},{"id":"14071705204","name":"SkillShindenKido","hitFrameTime":0.5},{"id":"14071706441","name":"SkillMortalReversal","hitFrameTime":0.5},{"id":"14071707691","name":"SkillThunderDrop","hitFrameTime":0.5},{"id":"14071708829","name":"SkillUniversalKido","hitFrameTime":0.933},{"id":"14071708972","name":"SkillIaiRush","hitFrameTime":0.5},{"id":"14071710217","name":"SkillIaiStrike","hitFrameTime":0.5},{"id":"14071711531","name":"SkillShreddingStorm","hitFrameTime":0.5},{"id":"14071712668","name":"SkillVolley","hitFrameTime":0.9},{"id":"14071712843","name":"SkillBlitzStance","hitFrameTime":0.5},{"id":"14071714088","name":"SkillDeluge","hitFrameTime":0.5},{"id":"14071715371","name":"SkillSnapTempest","hitFrameTime":0.5},{"id":"14071715538","name":"","hitFrameTime":0.717},{"id":"14071716750","name":"SkillSwiftEscape","hitFrameTime":0.5},{"id":"14071717982","name":"SkillReverseRush","hitFrameTime":0.5},{"id":"14071719239","name":"SkillCounterEdge","hitFrameTime":0.5},{"id":"14071719657","name":"","hitFrameTime":0.967},{"id":"14071720409","name":"SkillRendingSlash","hitFrameTime":0.5},{"id":"14071721603","name":"SkillFallingLionsmane","hitFrameTime":0.5},{"id":"14071722927","name":"SkillRagingSlash","hitFrameTime":0.5},{"id":"14071724187","name":"SkillCounterStance","hitFrameTime":0.4},{"id":"14071725417","name":"SkillInstantRegret","hitFrameTime":0.5},{"id":"14071726667","name":"SkillCataclysmBlade","hitFrameTime":0.5},{"id":"14071727905","name":"SkillFireChariot","hitFrameTime":0.5},{"id":"14071729044","name":"SkillExplosiveBlow","hitFrameTime":0.5},{"id":"14071730316","name":"SkillFallingFist","hitFrameTime":0.5},{"id":"14071731379","name":"HitByCritical","hitFrameTime":0.4},{"id":"14071731540","name":"SkillAtlasBreaker","hitFrameTime":0.5},{"id":"14071732719","name":"SkillGrandSlam","hitFrameTime":0.5},{"id":"14071733976","name":"SkillCycloneTwister","hitFrameTime":0.5},{"id":"14071735258","name":"SkillCalamityFall","hitFrameTime":0.5},{"id":"14071736457","name":"SkillLightningImpulse","hitFrameTime":0.5},{"id":"14071737686","name":"SkillCounterStanceStrike","hitFrameTime":0.5},{"id":"14071738911","name":"SkillJupiterBlade","hitFrameTime":0.5},{"id":"14071740152","name":"SkillMeteorShower","hitFrameTime":0.5},{"id":"14071741339","name":"SkillAuroraFlash","hitFrameTime":0.5},{"id":"14071742607","name":"SkillMutilate","hitFrameTime":0.5},{"id":"14071743826","name":"SkillSacrilege","hitFrameTime":0.5},{"id":"14071745202","name":"SkillMorbidRemedy","hitFrameTime":0.5},{"id":"14071746498","name":"SkillDragonsMaw","hitFrameTime":0.5},{"id":"14071747749","name":"SkillSpectralStep","hitFrameTime":0.5},{"id":"14071748960","name":"SkillSpectralStep2","hitFrameTime":0.5},{"id":"14071750231","name":"SkillSuppressingScream","hitFrameTime":0.5},{"id":"14071751465","name":"SkillRelentlessRoar","hitFrameTime":0.5},{"id":"14071752771","name":"SkillLevitate","hitFrameTime":0.5},{"id":"14071754009","name":"SkillBlackHole","hitFrameTime":0.5},{"id":"14071755283","name":"SkillIceberg","hitFrameTime":0.5},{"id":"14071756561","name":"SkillTyphoon","hitFrameTime":0.5},{"id":"14071758025","name":"SkillPhantomMenace","hitFrameTime":0.5},{"id":"14071758733","name":"SkillGlory","hitFrameTime":0.792},{"id":"14071759237","name":"SkillShadowAssault","hitFrameTime":0.5},{"id":"14071760601","name":"SkillAstralGrasp","hitFrameTime":0.5},{"id":"14071761955","name":"SkillSoulPierce","hitFrameTime":0.5},{"id":"14071763224","name":"SkillGhastlyCleaver","hitFrameTime":0.5},{"id":"14071763292","name":"","hitFrameTime":2.5},{"id":"14071764530","name":"SkillWraithScythe","hitFrameTime":0.5},{"id":"14071765788","name":"SkillSerpentStrike","hitFrameTime":0.5},{"id":"14071767088","name":"SkillDoubleLunge","hitFrameTime":0.5},{"id":"14071768392","name":"SkillBullRush","hitFrameTime":0.5},{"id":"14071769764","name":"SkillCripplingSlash","hitFrameTime":0.5},{"id":"14071770989","name":"SkillInevitableEnd","hitFrameTime":0.5},{"id":"14071788944","name":"SkillTrueGrasp","hitFrameTime":0.55},{"id":"14071794187","name":"SkillDroppingFang","hitFrameTime":0.867},{"id":"14071795665","name":"SkillFastFang","hitFrameTime":0.517},{"id":"14071797324","name":"SkillFlashCut","hitFrameTime":0.6},{"id":"14071798998","name":"SkillFlashFakeout","hitFrameTime":0.783},{"id":"14071801422","name":"SkillFlashFang","hitFrameTime":0.567},{"id":"14071803324","name":"SkillFloatingStrikes","hitFrameTime":0.517},{"id":"14071805394","name":"SkillGhostCleave","hitFrameTime":0.65},{"id":"14071813841","name":"SkillSpecterStep","hitFrameTime":0.4},{"id":"14071815365","name":"SkillSpecterStepStartup","hitFrameTime":0.4},{"id":"14071818194","name":"SkillWaterfallDance","hitFrameTime":0.525},{"id":"14071820438","name":"SpecterStep1","hitFrameTime":0.4},{"id":"14071821529","name":"SpecterStep2","hitFrameTime":0.4},{"id":"14079417198","name":"LightAttackHold","hitFrameTime":0.417},{"id":"14079423115","name":"LightAttackHoldOut","hitFrameTime":0.417},{"id":"14079425533","name":"LightAttackHoldIn","hitFrameTime":0.417},{"id":"14079559124","name":"LightAttack1","hitFrameTime":0.4},{"id":"14079560492","name":"LightAttack2","hitFrameTime":0.4},{"id":"14079561359","name":"LightAttack3","hitFrameTime":0.417},{"id":"14079562496","name":"LightAttack4","hitFrameTime":0.4},{"id":"14079563638","name":"LightAttack5","hitFrameTime":0.45},{"id":"14079571369","name":"Idle1","hitFrameTime":0.4},{"id":"14079591766","name":"DashAttackStrong","hitFrameTime":0.433},{"id":"14079593225","name":"DashAttackStrongOut","hitFrameTime":0.433},{"id":"14079594637","name":"DashAttackStrongIn","hitFrameTime":0.433},{"id":"14079595951","name":"DashAttackWeak","hitFrameTime":0.417},{"id":"14079597322","name":"DashAttackWeakOut","hitFrameTime":0.417},{"id":"14079598672","name":"DashAttackWeakIn","hitFrameTime":0.417},{"id":"14079882612","name":"FistIdle","hitFrameTime":0.4},{"id":"14079884027","name":"FistIdleOut","hitFrameTime":0.4},{"id":"14079885562","name":"FistIdleIn","hitFrameTime":0.4},{"id":"14079888310","name":"LightAttackHold","hitFrameTime":0.417},{"id":"14079889806","name":"LightAttackHoldOut","hitFrameTime":0.417},{"id":"14079891334","name":"LightAttackHoldIn","hitFrameTime":0.417},{"id":"14079891559","name":"FistRun","hitFrameTime":0.4},{"id":"14079892844","name":"DashAttack","hitFrameTime":0.417},{"id":"14079894251","name":"DashAttackOut","hitFrameTime":0.417},{"id":"14079895710","name":"DashAttackIn","hitFrameTime":0.417},{"id":"14079905407","name":"FistRunOut","hitFrameTime":0.4},{"id":"14079907270","name":"FistRunIn","hitFrameTime":0.4},{"id":"14079908720","name":"FistSprint","hitFrameTime":0.4},{"id":"14079910149","name":"FistSprintOut","hitFrameTime":0.4},{"id":"14079911638","name":"FistSprintIn","hitFrameTime":0.4},{"id":"14079914774","name":"FistDash","hitFrameTime":0.4},{"id":"14079916229","name":"FistDashOut","hitFrameTime":0.4},{"id":"14079917618","name":"FistDashIn","hitFrameTime":0.4},{"id":"14079977307","name":"SuperIdle","hitFrameTime":0.4},{"id":"14080118268","name":"Critical","hitFrameTime":0.55},{"id":"14080129863","name":"LightAttack1","hitFrameTime":0.433},{"id":"14080162667","name":"ShikaiSkillScorchedShot","hitFrameTime":0.45},{"id":"14080252620","name":"Idle1","hitFrameTime":0.4},{"id":"14080316837","name":"LightAttack2","hitFrameTime":0.6},{"id":"14080407911","name":"ShikaiSkillBurnBlade","hitFrameTime":0.55},{"id":"14080419406","name":"Parachute","hitFrameTime":0.4},{"id":"14080660172","name":"LightAttack1","hitFrameTime":0.4},{"id":"14081188065","name":"ShikaiSkillLowRuler","hitFrameTime":0.633},{"id":"14081273944","name":"DashAttackWeak","hitFrameTime":0.417},{"id":"14081276126","name":"DashAttackWeakOut","hitFrameTime":0.417},{"id":"14081278406","name":"DashAttackWeakIn","hitFrameTime":0.417},{"id":"14081278472","name":"DashAttackStrong","hitFrameTime":0.433},{"id":"14081280785","name":"DashAttackStrongOut","hitFrameTime":0.433},{"id":"14081282925","name":"DashAttackStrongIn","hitFrameTime":0.433},{"id":"14081509820","name":"ShikaiSkillGodsDirection","hitFrameTime":0.35},{"id":"14081602011","name":"Idle1","hitFrameTime":0.4},{"id":"14081639995","name":"SkillCrescentRelief","hitFrameTime":0.75},{"id":"14081673698","name":"LightAttack4","hitFrameTime":0.417},{"id":"14081676773","name":"LightAttack3","hitFrameTime":0.417},{"id":"14081706722","name":"CatClawsIdle","hitFrameTime":0.4},{"id":"14081708742","name":"CatClawsIdleOut","hitFrameTime":0.4},{"id":"14081711084","name":"CatClawsIdleIn","hitFrameTime":0.4},{"id":"14081740500","name":"SkillPulse","hitFrameTime":0.533},{"id":"14081764057","name":"LightAttackHold","hitFrameTime":0.417},{"id":"14081765890","name":"LightAttackHoldOut","hitFrameTime":0.417},{"id":"14081767591","name":"LightAttackHoldIn","hitFrameTime":0.417},{"id":"14081771371","name":"StealthKill","hitFrameTime":0.417},{"id":"14081773189","name":"StealthKillOut","hitFrameTime":0.417},{"id":"14081775026","name":"StealthKillIn","hitFrameTime":0.417},{"id":"14081783266","name":"CatClawsRunOut","hitFrameTime":0.4},{"id":"14081785047","name":"CatClawsRunIn","hitFrameTime":0.4},{"id":"14081790701","name":"CatClawsSprint","hitFrameTime":0.4},{"id":"14081796040","name":"CatClawsSprintOut","hitFrameTime":0.4},{"id":"14081798265","name":"CatClawsSprintIn","hitFrameTime":0.4},{"id":"14081857355","name":"CatClawsDash","hitFrameTime":0.4},{"id":"14081859584","name":"CatClawsDashOut","hitFrameTime":0.4},{"id":"14081861737","name":"CatClawsDashIn","hitFrameTime":0.4},{"id":"14082062358","name":"CatClawsRun","hitFrameTime":0.4},{"id":"14089440458","name":"Draw1","hitFrameTime":0.4},{"id":"14089639776","name":"Parrying2","hitFrameTime":0.4},{"id":"14092413742","name":"Sprint","hitFrameTime":0.4},{"id":"14092828229","name":"SkillHeadSlam","hitFrameTime":0.783},{"id":"14151201597","name":"ShikaiSkillNightmare","hitFrameTime":0.583},{"id":"14151600402","name":"ShikaiSkillFEImpale","hitFrameTime":0.417},{"id":"14151681576","name":"ShikaiSkillThorn","hitFrameTime":0.8},{"id":"14151735498","name":"ShikaiSkillImpale","hitFrameTime":0.567},{"id":"14231498751","name":"","hitFrameTime":0.6},{"id":"14321526753","name":"LightAttack1","hitFrameTime":0.433},{"id":"14415122747","name":"StealthDash","hitFrameTime":0.4},{"id":"14415123109","name":"StealthDashOut","hitFrameTime":0.4},{"id":"14415123474","name":"AutoDodge","hitFrameTime":0.4},{"id":"14415123616","name":"StealthDashIn","hitFrameTime":0.4},{"id":"14415124348","name":"AutoDodgeOut","hitFrameTime":0.4},{"id":"14415125330","name":"AutoDodgeIn","hitFrameTime":0.4},{"id":"14433388059","name":"Guard","hitFrameTime":0.4},{"id":"14604497773","name":"Stand1","hitFrameTime":0.4},{"id":"14604515824","name":"Stand2","hitFrameTime":0.4},{"id":"14604538621","name":"Stand3","hitFrameTime":0.4},{"id":"14604557210","name":"Stand4","hitFrameTime":0.4},{"id":"14604566859","name":"Stand5","hitFrameTime":0.4},{"id":"14604577905","name":"Stand6","hitFrameTime":0.4},{"id":"14604596404","name":"Stand7","hitFrameTime":0.4},{"id":"14604611364","name":"Stand8","hitFrameTime":0.4},{"id":"14604623802","name":"Stand9","hitFrameTime":0.4},{"id":"14604632769","name":"Stand10","hitFrameTime":0.4},{"id":"14604644689","name":"Stand11","hitFrameTime":0.4},{"id":"14604658596","name":"Stand12","hitFrameTime":0.4},{"id":"14604676900","name":"Stand13","hitFrameTime":0.4},{"id":"14604688162","name":"Stand14","hitFrameTime":0.4},{"id":"14604696852","name":"Stand15","hitFrameTime":0.4},{"id":"14604706112","name":"Stand16","hitFrameTime":0.4},{"id":"14604716084","name":"Stand17","hitFrameTime":0.4},{"id":"14604724418","name":"Stand18","hitFrameTime":0.4},{"id":"14604734510","name":"Stand19","hitFrameTime":0.4},{"id":"14604743229","name":"Stand20","hitFrameTime":0.4},{"id":"14671175653","name":"Drink","hitFrameTime":0.4},{"id":"14671176514","name":"Drink","hitFrameTime":0.4},{"id":"14674451828","name":"LowSweep","hitFrameTime":0.417},{"id":"14674452304","name":"LowSweepOut","hitFrameTime":0.417},{"id":"14674452791","name":"LowSweepIn","hitFrameTime":0.417},{"id":"14674453143","name":"WindUp","hitFrameTime":0.5},{"id":"14674453592","name":"WindUpOut","hitFrameTime":0.5},{"id":"14674454011","name":"WindUpIn","hitFrameTime":0.5},{"id":"14771379522","name":"LightAttack1","hitFrameTime":0.433},{"id":"14774768876","name":"LightAttack2","hitFrameTime":0.433},{"id":"14835823861","name":"ShikaiSkillConsumingWind","hitFrameTime":0.7},{"id":"14843282968","name":"LightAttack1","hitFrameTime":0.383},{"id":"14843286913","name":"LightAttack2","hitFrameTime":0.383},{"id":"14843288316","name":"LightAttack3","hitFrameTime":0.383},{"id":"15325122671","name":"SkillTimeCut","hitFrameTime":0.5},{"id":"15593308308","name":"HumanCharge","hitFrameTime":0.5},{"id":"15593311555","name":"HumanSwing","hitFrameTime":0.417},{"id":"15593314160","name":"HumanImpact","hitFrameTime":0.4},{"id":"15593315667","name":"HumanWring","hitFrameTime":0.4},{"id":"15678789275","name":"Down","hitFrameTime":0.4},{"id":"15678791329","name":"Come","hitFrameTime":0.4},{"id":"15678792905","name":"Beg","hitFrameTime":0.4},{"id":"15678794522","name":"Laugh","hitFrameTime":0.4},{"id":"15678796461","name":"Confirm","hitFrameTime":0.4},{"id":"15678798262","name":"Salute","hitFrameTime":0.4},{"id":"16556613205","name":"GuildAd_Walk","hitFrameTime":0.4},{"id":"16556614349","name":"GuildAd_Run","hitFrameTime":0.4},{"id":"16556615456","name":"GuildAd_StandIdle","hitFrameTime":0.4},{"id":"16556618385","name":"GuildAd_Idle","hitFrameTime":0.4},{"id":"16737652315","name":"Critical","hitFrameTime":0.25},{"id":"16737811628","name":"CriticalPull","hitFrameTime":0.117},{"id":"16749239700","name":"LightAttack1","hitFrameTime":0.317},{"id":"16749243263","name":"","hitFrameTime":0.35},{"id":"16760948872","name":"","hitFrameTime":1.15},{"id":"16862197648","name":"SkillCeroScourge","hitFrameTime":2.45},{"id":"16863583983","name":"GotKicked","hitFrameTime":0.4},{"id":"16876002725","name":"Charge","hitFrameTime":0.5},{"id":"16876008681","name":"Shoot","hitFrameTime":0.5},{"id":"16879385782","name":"Critical","hitFrameTime":0.5},{"id":"16889680733","name":"SkillFlowingPetals","hitFrameTime":0.45},{"id":"16889698337","name":"SkillFlowingPetalsTP","hitFrameTime":0.717},{"id":"16916031436","name":"SkillUnseen","hitFrameTime":0.5},{"id":"16916034284","name":"SkillUnseenBladeFlash","hitFrameTime":0.15},{"id":"16960525303","name":"","hitFrameTime":1.1},{"id":"16978003775","name":"","hitFrameTime":0.415},{"id":"16990963565","name":"LightAttack3","hitFrameTime":0.5},{"id":"16990965363","name":"LightAttack4","hitFrameTime":0.5},{"id":"17001304984","name":"ShikaiSkillPrismatic","hitFrameTime":0.35},{"id":"17006209669","name":"","hitFrameTime":0.45},{"id":"17028467262","name":"ShikaiSkillDevilGodFist","hitFrameTime":0.517},{"id":"17055000652","name":"SkillClaw","hitFrameTime":0.417},{"id":"17055012281","name":"SkillSlam","hitFrameTime":0.417},{"id":"17055017045","name":"SkillSlash1","hitFrameTime":0.367},{"id":"17055022854","name":"SkillSlash2","hitFrameTime":0.367},{"id":"17070610887","name":"BlockHit","hitFrameTime":0.4},{"id":"17070666279","name":"Deflected2","hitFrameTime":0.4},{"id":"17071010713","name":"LightAttack2","hitFrameTime":0.4},{"id":"17071045178","name":"LightAttack3","hitFrameTime":0.4},{"id":"17071146153","name":"Critical","hitFrameTime":0.533},{"id":"17084477793","name":"SkillCeroCyclone","hitFrameTime":0.533},{"id":"17240432507","name":"SonidoPierceSegunda","hitFrameTime":0.45},{"id":"17296971778","name":"SkillDeathFlair","hitFrameTime":1.2},{"id":"17297701980","name":"CatchingDragonTP","hitFrameTime":0.5},{"id":"17305507325","name":"SkillCatchingDragonAir","hitFrameTime":0.5},{"id":"17305548002","name":"CaughtDragon2","hitFrameTime":0.4},{"id":"17310915985","name":"","hitFrameTime":0.45},{"id":"17334442500","name":"ShikaiSkillRend","hitFrameTime":0.517},{"id":"17350839549","name":"","hitFrameTime":0.415},{"id":"17374104901","name":"SkillAnkleSplitter","hitFrameTime":0.5},{"id":"17403725820","name":"","hitFrameTime":0.415},{"id":"17404358557","name":"","hitFrameTime":0.767},{"id":"17438374906","name":"LightAttack2","hitFrameTime":0.25},{"id":"17438387812","name":"LightAttack4","hitFrameTime":0.267},{"id":"17438415897","name":"LightAttack5","hitFrameTime":0.55},{"id":"17440095233","name":"LightAttack1","hitFrameTime":0.283},{"id":"17451431896","name":"SpiralBladeSpin","hitFrameTime":0.4},{"id":"17452315723","name":"CombatIdle","hitFrameTime":0.4},{"id":"17452315894","name":"CombatIdle4","hitFrameTime":0.4},{"id":"17452316532","name":"CombatIdle2","hitFrameTime":0.4},{"id":"17452317377","name":"CombatIdle3","hitFrameTime":0.4},{"id":"17452317679","name":"CombatIdle5","hitFrameTime":0.4},{"id":"17452320451","name":"CombatIdle7","hitFrameTime":0.4},{"id":"17452321377","name":"CombatIdle6","hitFrameTime":0.4},{"id":"17452322489","name":"CombatIdle9","hitFrameTime":0.4},{"id":"17452323689","name":"CombatIdle8","hitFrameTime":0.4},{"id":"17452324899","name":"CombatIdle10","hitFrameTime":0.4},{"id":"17459987417","name":"","hitFrameTime":0.433},{"id":"17461343732","name":"Ragdoll","hitFrameTime":0.4},{"id":"17462101446","name":"Confirm","hitFrameTime":0.4},{"id":"17462116576","name":"Salute","hitFrameTime":0.4},{"id":"17462139960","name":"Up","hitFrameTime":0.4},{"id":"17462154202","name":"Down","hitFrameTime":0.4},{"id":"17462165833","name":"Come","hitFrameTime":0.4},{"id":"17462177651","name":"Beg","hitFrameTime":0.4},{"id":"17462189539","name":"Laugh","hitFrameTime":0.4},{"id":"17462238860","name":"1","hitFrameTime":0.4},{"id":"17465190117","name":"2","hitFrameTime":0.4},{"id":"17465191715","name":"3","hitFrameTime":0.4},{"id":"17465193309","name":"4","hitFrameTime":0.4},{"id":"17487255488","name":"SCriticalHit","hitFrameTime":1.067},{"id":"17489747112","name":"Tumble","hitFrameTime":0.4},{"id":"17498700375","name":"ShikaiSkillThirdStep","hitFrameTime":0.55},{"id":"17506697759","name":"LightAttack1","hitFrameTime":0.467},{"id":"17506699440","name":"LightAttack2","hitFrameTime":0.467},{"id":"17506706406","name":"LightAttack3","hitFrameTime":0.5},{"id":"17506708431","name":"LightAttack4","hitFrameTime":0.5},{"id":"17506710057","name":"LightAttack5","hitFrameTime":0.45},{"id":"17508791926","name":"AizenUltCam","hitFrameTime":0.4},{"id":"17508794285","name":"AizenUlt","hitFrameTime":0.5},{"id":"17527952602","name":"","hitFrameTime":0.583},{"id":"17528739240","name":"SkillBlackClaw","hitFrameTime":0.617},{"id":"17528744811","name":"SkillBlackClawBackstab","hitFrameTime":0.5},{"id":"17548785844","name":"LightAttackHold","hitFrameTime":0.417},{"id":"17548787313","name":"LightAttackHoldOut","hitFrameTime":0.417},{"id":"17548788653","name":"LightAttackHoldIn","hitFrameTime":0.417},{"id":"17548789080","name":"ParrySword","hitFrameTime":0.4},{"id":"17548790323","name":"ParrySwordStrong","hitFrameTime":0.4},{"id":"17548791695","name":"ParrySwordNull","hitFrameTime":0.4},{"id":"17548792850","name":"ParrySwordWeak","hitFrameTime":0.4},{"id":"17548793968","name":"ParrySwordWeakOut","hitFrameTime":0.4},{"id":"17548795017","name":"ParrySwordWeakIn","hitFrameTime":0.4},{"id":"17548796023","name":"ParrySwordWall","hitFrameTime":0.4},{"id":"17548796979","name":"ParrySwordWallOut","hitFrameTime":0.4},{"id":"17548797931","name":"ParrySwordWallIn","hitFrameTime":0.4},{"id":"17548798880","name":"ParrySwordMid","hitFrameTime":0.4},{"id":"17548799877","name":"ParrySwordAir","hitFrameTime":0.4},{"id":"17548801014","name":"ParrySwordAirOut","hitFrameTime":0.4},{"id":"17548802048","name":"ParrySwordAirIn","hitFrameTime":0.4},{"id":"17585437853","name":"SkillUser","hitFrameTime":0.5},{"id":"17585442083","name":"Victim","hitFrameTime":0.4},{"id":"17621431481","name":"WaterRun","hitFrameTime":0.4},{"id":"17621432243","name":"WaterWalk","hitFrameTime":0.4},{"id":"17621432577","name":"WaterIdle","hitFrameTime":0.4},{"id":"17622404913","name":"Sp1","hitFrameTime":0.4},{"id":"17622418673","name":"Sp2","hitFrameTime":0.4},{"id":"17622426037","name":"Sp3","hitFrameTime":0.4},{"id":"17622434536","name":"Sp4","hitFrameTime":0.4},{"id":"17622442176","name":"Sp5","hitFrameTime":0.4},{"id":"17622450505","name":"Sp6","hitFrameTime":0.4},{"id":"17622458592","name":"Sp7","hitFrameTime":0.4},{"id":"17622467349","name":"Sp8","hitFrameTime":0.4},{"id":"17622476303","name":"Sp9","hitFrameTime":0.4},{"id":"17622484278","name":"Sp10","hitFrameTime":0.4},{"id":"17622492623","name":"Sp11","hitFrameTime":0.4},{"id":"17622500999","name":"Sp12","hitFrameTime":0.4},{"id":"17622509747","name":"Sp13","hitFrameTime":0.4},{"id":"17622516381","name":"Sp14","hitFrameTime":0.4},{"id":"17622524814","name":"Sp15","hitFrameTime":0.4},{"id":"17622533637","name":"Sp16","hitFrameTime":0.4},{"id":"17622542852","name":"Sp17","hitFrameTime":0.4},{"id":"17622550431","name":"Sp18","hitFrameTime":0.4},{"id":"17622557987","name":"Sp19","hitFrameTime":0.4},{"id":"17622567145","name":"Sp20","hitFrameTime":0.4},{"id":"17656741268","name":"Cero0","hitFrameTime":0.5},{"id":"17656746776","name":"Cero2","hitFrameTime":0.5},{"id":"17656755136","name":"Cero3","hitFrameTime":0.5},{"id":"17656763865","name":"Cero4","hitFrameTime":0.5},{"id":"17656772710","name":"Cero5","hitFrameTime":0.5},{"id":"17656781722","name":"Cero6","hitFrameTime":0.5},{"id":"17656789390","name":"Cero7","hitFrameTime":0.5},{"id":"17656795557","name":"Cero8","hitFrameTime":0.5},{"id":"17656803160","name":"Cero9","hitFrameTime":0.5},{"id":"17656812032","name":"Cero10","hitFrameTime":0.5},{"id":"17656821007","name":"Cero11","hitFrameTime":0.5},{"id":"17656829139","name":"Cero12","hitFrameTime":0.5},{"id":"17656837233","name":"Cero13","hitFrameTime":0.5},{"id":"17656845677","name":"Cero14","hitFrameTime":0.5},{"id":"17656853714","name":"Cero15","hitFrameTime":0.5},{"id":"17656862003","name":"Cero16","hitFrameTime":0.5},{"id":"17656870092","name":"Cero17","hitFrameTime":0.5},{"id":"17656878330","name":"Cero18","hitFrameTime":0.5},{"id":"17656887266","name":"Cero19","hitFrameTime":0.5},{"id":"17656894917","name":"Cero20","hitFrameTime":0.5},{"id":"17659880684","name":"Open","hitFrameTime":0.4},{"id":"17659890715","name":"OpenLoop","hitFrameTime":0.4},{"id":"17659902927","name":"Close","hitFrameTime":0.4},{"id":"17674369888","name":"ShikaiSkillGeyser","hitFrameTime":0.5},{"id":"17810646655","name":"LightAttack1","hitFrameTime":0.383},{"id":"17810649879","name":"LightAttack2","hitFrameTime":0.367},{"id":"17812172523","name":"SkillExtricate","hitFrameTime":0.5},{"id":"17832740477","name":"Drink","hitFrameTime":0.4},{"id":"17889811842","name":"Critical","hitFrameTime":0.433},{"id":"17895949845","name":"ShikaiSkillShoot","hitFrameTime":0.5},{"id":"17900275042","name":"Critical","hitFrameTime":0.533},{"id":"18106586847","name":"ShikaiSkillHyapponzashi","hitFrameTime":0.3},{"id":"18141314581","name":"LightAttack1","hitFrameTime":0.333},{"id":"18141315844","name":"LightAttack2","hitFrameTime":0.317},{"id":"18174360490","name":"Idle","hitFrameTime":0.4},{"id":"18216186853","name":"","hitFrameTime":0.5},{"id":"18216211089","name":"","hitFrameTime":0.25},{"id":"18216220857","name":"","hitFrameTime":0.3},{"id":"18216226723","name":"","hitFrameTime":0.35},{"id":"18227497975","name":"LightAttack1","hitFrameTime":0.35},{"id":"18227509632","name":"LightAttack2","hitFrameTime":0.35},{"id":"18227538963","name":"LightAttack3","hitFrameTime":0.35},{"id":"18227540151","name":"LightAttack4","hitFrameTime":0.35},{"id":"18227559364","name":"LightAttack5","hitFrameTime":0.35},{"id":"18231067142","name":"","hitFrameTime":0.415},{"id":"18239954322","name":"NewCritical","hitFrameTime":1.117},{"id":"18242209934","name":"Sprint","hitFrameTime":0.4},{"id":"18244318460","name":"","hitFrameTime":0.415},{"id":"18270573533","name":"","hitFrameTime":0.4},{"id":"18416120307","name":"LightAttack1","hitFrameTime":0.317},{"id":"18499126013","name":"Idle1","hitFrameTime":0.4},{"id":"18499148118","name":"Draw1","hitFrameTime":0.4},{"id":"18499793238","name":"LightAttack1","hitFrameTime":0.3},{"id":"18499795881","name":"LightAttack2","hitFrameTime":0.3},{"id":"18499798719","name":"LightAttack3","hitFrameTime":0.3},{"id":"18499801937","name":"LightAttack4","hitFrameTime":0.3},{"id":"18499804340","name":"LightAttack5","hitFrameTime":0.3},{"id":"18500073271","name":"","hitFrameTime":0.25},{"id":"18500195927","name":"","hitFrameTime":0.25},{"id":"18563076445","name":"","hitFrameTime":0.3},{"id":"18564947969","name":"","hitFrameTime":0.383},{"id":"18613611956","name":"LightAttack1","hitFrameTime":0.183},{"id":"18613616177","name":"LightAttack2","hitFrameTime":0.183},{"id":"18613624895","name":"LightAttack3","hitFrameTime":0.183},{"id":"18613631057","name":"LightAttack4","hitFrameTime":0.2},{"id":"18617223357","name":"LightAttack1","hitFrameTime":0.333},{"id":"18617228637","name":"","hitFrameTime":0.333},{"id":"18617235161","name":"","hitFrameTime":0.333},{"id":"18622483748","name":"","hitFrameTime":0.25},{"id":"18624107523","name":"LightAttack1","hitFrameTime":0.333},{"id":"18624112753","name":"LightAttack2","hitFrameTime":0.367},{"id":"18624117097","name":"LightAttack3","hitFrameTime":0.35},{"id":"18624121543","name":"LightAttack4","hitFrameTime":0.367},{"id":"18624125789","name":"LightAttack5","hitFrameTime":0.383},{"id":"18671638457","name":"Critical","hitFrameTime":0.617},{"id":"18747296734","name":"","hitFrameTime":0.417},{"id":"18838191479","name":"Critical","hitFrameTime":0.533},{"id":"18838195174","name":"Critical2","hitFrameTime":0.533},{"id":"18869318338","name":"LightAttack1","hitFrameTime":0.4},{"id":"18869326330","name":"LightAttack2","hitFrameTime":0.367},{"id":"18869335671","name":"LightAttack3","hitFrameTime":0.4},{"id":"18869341514","name":"LightAttack4","hitFrameTime":0.35},{"id":"18869350385","name":"LightAttack5","hitFrameTime":0.383},{"id":"18869408009","name":"Idle1","hitFrameTime":0.4},{"id":"18869414551","name":"Sprint","hitFrameTime":0.4},{"id":"18869424622","name":"BlockHit","hitFrameTime":0.4},{"id":"18869443055","name":"Parry","hitFrameTime":0.4},{"id":"18869444699","name":"Deflected1","hitFrameTime":0.4},{"id":"18891098620","name":"3","hitFrameTime":0.4},{"id":"18891105588","name":"1","hitFrameTime":0.4},{"id":"18891108996","name":"2","hitFrameTime":0.4},{"id":"18913467650","name":"Grip","hitFrameTime":0.4},{"id":"18930454578","name":"Draw1","hitFrameTime":0.4},{"id":"18931484941","name":"Block","hitFrameTime":0.4},{"id":"18946290569","name":"LightAttack2","hitFrameTime":0.333},{"id":"18946430954","name":"1","hitFrameTime":0.4},{"id":"18946433985","name":"2","hitFrameTime":0.4},{"id":"18946438343","name":"3","hitFrameTime":0.4},{"id":"18946441526","name":"4","hitFrameTime":0.4},{"id":"18946444486","name":"5","hitFrameTime":0.4},{"id":"18946547118","name":"LightAttack5","hitFrameTime":0.35},{"id":"18947052596","name":"LightAttack1","hitFrameTime":0.433},{"id":"18953633163","name":"LightAttack3","hitFrameTime":0.533},{"id":"18953647461","name":"LightAttack4","hitFrameTime":0.45},{"id":"18973225144","name":"LightAttack1","hitFrameTime":0.4},{"id":"18973227985","name":"LightAttack2","hitFrameTime":0.4},{"id":"18973231045","name":"LightAttack3","hitFrameTime":0.4},{"id":"18973232786","name":"LightAttack4","hitFrameTime":0.4},{"id":"18973235472","name":"LightAttack5","hitFrameTime":0.4},{"id":"18973572043","name":"Critical","hitFrameTime":0.533},{"id":"18976644625","name":"LightAttack1","hitFrameTime":1.25},{"id":"18977225555","name":"JudgementSword","hitFrameTime":0.617},{"id":"18990320625","name":"","hitFrameTime":0.45},{"id":"19061623817","name":"ParrySwordOut","hitFrameTime":0.4},{"id":"19061633038","name":"ParrySwordIn","hitFrameTime":0.4},{"id":"19061652936","name":"ParrySwordStrongOut","hitFrameTime":0.4},{"id":"19061664403","name":"ParrySwordStrongIn","hitFrameTime":0.4},{"id":"19061675863","name":"ParrySwordMidOut","hitFrameTime":0.4},{"id":"19061687684","name":"ParrySwordMidIn","hitFrameTime":0.4},{"id":"71996010765068","name":"Cheer","hitFrameTime":0.55},{"id":"72125476813742","name":"LightAttack2","hitFrameTime":0.417},{"id":"73831100583754","name":"LightAttack2","hitFrameTime":0.4},{"id":"75294680795819","name":"SkillBusoshoku","hitFrameTime":0.417},{"id":"75810282859696","name":"Critical","hitFrameTime":0.533},{"id":"76024404613808","name":"ShikaiSkillEruption","hitFrameTime":0.383},{"id":"76934429933743","name":"Idle1","hitFrameTime":0.4},{"id":"77556741941431","name":"","hitFrameTime":0.3},{"id":"77928449721855","name":"ShikaiSkillEnhancement","hitFrameTime":1.383},{"id":"78408215042415","name":"SkillBloomingCutAlt","hitFrameTime":0.5},{"id":"80093124338885","name":"","hitFrameTime":0.415},{"id":"80933072062076","name":"","hitFrameTime":0.067},{"id":"81357129424702","name":"SkillPulseDragonEye","hitFrameTime":0.5},{"id":"81926683097609","name":"Idle1","hitFrameTime":0.4},{"id":"82755714455809","name":"BlockHit","hitFrameTime":0.4},{"id":"83044895311287","name":"LightAttack5","hitFrameTime":0.4},{"id":"84000459841794","name":"LightAttack1","hitFrameTime":0.417},{"id":"87357618406139","name":"Critical","hitFrameTime":0.533},{"id":"88193630869318","name":"ShikaiSkillExecution","hitFrameTime":2.783},{"id":"89020106755004","name":"ShikaiSkillOverflow","hitFrameTime":0.6},{"id":"89245704362242","name":"ShikaiSkillResilience","hitFrameTime":0.467},{"id":"89513971538461","name":"SkillElegantSurge","hitFrameTime":0.5},{"id":"91541054815360","name":"Sprint","hitFrameTime":0.4},{"id":"92309466893764","name":"Parrying2","hitFrameTime":0.4},{"id":"94301385736991","name":"Block","hitFrameTime":0.4},{"id":"94492045799378","name":"SkillAnkleSplitter","hitFrameTime":0.5},{"id":"94616613717831","name":"Walk","hitFrameTime":0.4},{"id":"95137636416866","name":"SkillConflictionAirUser","hitFrameTime":0.35},{"id":"98403029357748","name":"LightAttack4","hitFrameTime":0.4},{"id":"98690955288984","name":"SkillTripleStriker","hitFrameTime":0.5},{"id":"99937198109435","name":"","hitFrameTime":0.415},{"id":"100032278211972","name":"SkillGrandEntrance","hitFrameTime":0.5},{"id":"101060594241513","name":"SkillAcuteIncision","hitFrameTime":0.5},{"id":"101666360012442","name":"ShikaiDraw1","hitFrameTime":0.4},{"id":"104735147027450","name":"LightAttack1","hitFrameTime":0.4},{"id":"104942759057637","name":"LightAttack2","hitFrameTime":0.433},{"id":"106475769642579","name":"Critical","hitFrameTime":0.433},{"id":"107149651782942","name":"","hitFrameTime":0.415},{"id":"107337715936090","name":"right","hitFrameTime":0.4},{"id":"107490655083042","name":"","hitFrameTime":0.5},{"id":"108341635519391","name":"","hitFrameTime":0.5},{"id":"109283607506588","name":"LightAttack4","hitFrameTime":0.4},{"id":"110422647795027","name":"ShikaiSkillBlossom","hitFrameTime":0.533},{"id":"110624511808722","name":"LightAttack3","hitFrameTime":0.45},{"id":"110650844036645","name":"","hitFrameTime":0.567},{"id":"110939266289950","name":"LightAttack1","hitFrameTime":0.4},{"id":"111020353010598","name":"LightAttack5","hitFrameTime":0.4},{"id":"112414265892575","name":"","hitFrameTime":0.833},{"id":"112833261161335","name":"Finesse","hitFrameTime":0.4},{"id":"114673758853916","name":"SkillSwiftSlashes","hitFrameTime":0.367},{"id":"114730792097839","name":"SkillSkyscraper","hitFrameTime":0.533},{"id":"115641078211548","name":"LightAttack1","hitFrameTime":0.4},{"id":"115789440497543","name":"","hitFrameTime":0.415},{"id":"116595150441085","name":"LightAttack2","hitFrameTime":0.4},{"id":"116811469180699","name":"LightAttack5","hitFrameTime":0.4},{"id":"117667120617374","name":"SkillStrataStrike","hitFrameTime":0.433},{"id":"117790265111402","name":"ImpaleVictim","hitFrameTime":0.4},{"id":"118813121473831","name":"SkillStrataStrikeCounterFail","hitFrameTime":0.4},{"id":"118827345243484","name":"SkillStrataStrikeCounter","hitFrameTime":0.5},{"id":"118905193577697","name":"SkillDeathFlair","hitFrameTime":0.683},{"id":"119255540226586","name":"LightAttack4","hitFrameTime":0.4},{"id":"121652074574074","name":"","hitFrameTime":0.3},{"id":"122330010123120","name":"","hitFrameTime":0.4},{"id":"122334177552891","name":"LightAttack4","hitFrameTime":0.4},{"id":"122780559010804","name":"","hitFrameTime":0.3},{"id":"123051706196913","name":"LightAttack3","hitFrameTime":0.433},{"id":"123116990834526","name":"SkillStrataStrikeCounterWindow","hitFrameTime":0.4},{"id":"123865316075930","name":"Parrying1","hitFrameTime":0.4},{"id":"126264205316919","name":"CritVictim","hitFrameTime":0.4},{"id":"126980266964809","name":"left","hitFrameTime":0.4},{"id":"127467569960299","name":"LightAttack3","hitFrameTime":0.4},{"id":"128545892117668","name":"CritStompKick","hitFrameTime":0.533},{"id":"128699207583086","name":"LightAttack2","hitFrameTime":0.4},{"id":"130168360103868","name":"SkillGrandEntranceHit","hitFrameTime":0.5},{"id":"130329890101258","name":"Heal","hitFrameTime":0.4},{"id":"130329897788224","name":"Heal","hitFrameTime":0.4},{"id":"130331395166265","name":"Heal","hitFrameTime":0.4},{"id":"130491821005753","name":"AizenUltBlock","hitFrameTime":0.4},{"id":"130491993047530","name":"AizenUltIdle","hitFrameTime":0.4},{"id":"130492093472074","name":"AizenUltBeam","hitFrameTime":0.5},{"id":"130492487892372","name":"AizenUltThrust","hitFrameTime":0.5},{"id":"130492740729171","name":"AizenUltHold","hitFrameTime":0.4},{"id":"131840189107178","name":"Critical2","hitFrameTime":0.983},{"id":"131998597775441","name":"HitByAcute","hitFrameTime":0.4},{"id":"133708496404916","name":"LightAttack3","hitFrameTime":0.417},{"id":"134030338249685","name":"Critical","hitFrameTime":0.533},{"id":"134664715239153","name":"Parry","hitFrameTime":0.4},{"id":"134720868148122","name":"ImpaleUser","hitFrameTime":0.5},{"id":"136030200625532","name":"SkillElegantSurge2","hitFrameTime":0.5},{"id":"136339583668620","name":"LightAttack3","hitFrameTime":0.4},{"id":"136730173773120","name":"SkillBloomingCut","hitFrameTime":0.817},{"id":"138199113509312","name":"Throw","hitFrameTime":0.5},{"id":"138891627866408","name":"","hitFrameTime":0.415},{"id":"140593463506018","name":"Shibari","hitFrameTime":0.4}]
]]

local parryEnabled        = false
local parryRange          = 10
local pressDuration       = 0.15
local pingCompEnabled     = false  
local pingOffsetMs        = 0    
local pingMs              = 0
local latestParryId       = nil
local notifyEachParry     = false
local parryLookup         = {}
local humanoidConnections = {}

local function withinParryRange(targetHumanoid)
    local model = targetHumanoid and targetHumanoid.Parent
    if not model or model == player.Character then return false end
    local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
    if not hrp or not character then return false end
    if not humanoidRootPart then return false end
    return (hrp.Position - humanoidRootPart.Position).Magnitude <= parryRange
end

local function loadParryConfigFromJSON(jsonText)
    local ok, arr = pcall(HttpService.JSONDecode, HttpService, jsonText)
    if not ok or type(arr) ~= "table" then
        Library:Notify("[AutoParry] Local config not found or invalid JSON")
        return false
    end
    local map = {}
    for _, rec in ipairs(arr) do
        local id = tostring(rec.id or ""):match("%d+") or ""
        local t  = tonumber(rec.hitFrameTime) or 0
        if id ~= "" and t >= 0 and t <= 1 then
            map[id] = { name = tostring(rec.name or ("Anim_"..id)), hitFrameTime = t }
        end
    end
    parryLookup = map
    Library:Notify(string.format("[AutoParry] Loaded %d animations", #arr))
    return true
end

local function tryLoadLocalConfig()
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local fname = "ParryConfigTS.json"
        if isfile(fname) then
            return loadParryConfigFromJSON(readfile(fname))
        end
    end
    return false
end

if not tryLoadLocalConfig() then
    loadParryConfigFromJSON(defaultParryConfig)
end

task.spawn(function()
    while true do
        local plr = player
        if plr and plr.GetNetworkPing then
            local v = plr:GetNetworkPing()
            if typeof(v) == "number" then
                pingMs = math.floor(v * 1000)
            end
        end
        task.wait(5)
    end
end)

local function doParryTap()
    local char = player.Character
    if not char then return end
    local ch = char:FindFirstChild("CharacterHandler")
    if not ch then return end
    local remotes = ch:FindFirstChild("Remotes")
    if not remotes then return end
    local block = remotes:FindFirstChild("Block")
    if not block then return end

    block:FireServer("Pressed")
    task.wait(pressDuration)
    block:FireServer("Released")
end

local function onHumanoid(hum)
    return hum.AnimationPlayed:Connect(function(animTrack)
        if not parryEnabled then return end
        if not withinParryRange(hum) then return end

        local rawId = (animTrack.Animation and animTrack.Animation.AnimationId) or ""
        local animId = tostring(rawId):match("%d+") or ""
        if animId == "" then return end

        local cfg = parryLookup[animId]
        if not cfg then return end

        local duration = animTrack.Length or animTrack.TimeLength or 0
        if duration <= 0 then return end
        local baseDelay = duration * cfg.hitFrameTime
        local manualAdj = (pingCompEnabled and (math.clamp(pingOffsetMs, -200, 200) / 1000)) or 0
        local pressDelay = math.max(0, baseDelay + manualAdj)

        latestParryId = animId
        task.spawn(function()
            task.wait(pressDelay)
            if parryEnabled and withinParryRange(hum) then
                doParryTap()

                if notifyEachParry then
                    local dist = 0
                    local model = hum.Parent
                    local hrp = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
                    local humanoidRootPart = player.Character and (player.Character:FindFirstChild("HumanoidRootPart") or player.Character.PrimaryPart)
                    if hrp and humanoidRootPart then
                        dist = (hrp.Position - humanoidRootPart.Position).Magnitude
                    end

					Library:Notify(string.format(
                        "Parried: %s (%s)\nDelay: %.0f ms | Adj: %+d ms | Ping: %d ms | Dist: %.1f",
                        tostring(cfg.name or "Unknown"),
                        animId,
                        pressDelay * 1000,
                        math.floor(math.clamp(pingOffsetMs, -200, 200)),
                        pingMs,
                        dist
                    ))
                end
            end
        end)
    end)
end

local function hookHumanoid(hum)
    if humanoidConnections[hum] then return end
    humanoidConnections[hum] = onHumanoid(hum)
end

local function unhookHumanoid(hum)
    local c = humanoidConnections[hum]
    if c then c:Disconnect() end
    humanoidConnections[hum] = nil
end

for _, inst in ipairs(Workspace:GetDescendants()) do
    if inst:IsA("Humanoid") then hookHumanoid(inst) end
end

Workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Humanoid") then
        task.delay(0.05, function()
            if d.Parent and d:IsDescendantOf(Workspace) then
                hookHumanoid(d)
            end
        end)
    end
end)

Workspace.DescendantRemoving:Connect(function(d)
    if d:IsA("Humanoid") then unhookHumanoid(d) end
end)
-- #### AUTO PARRY HELPERS #### --
-- ============================ --

-- ======================= --
-- #### AUTO PARRY UI #### --
autoParryGroupbox = Tabs.Combat:AddLeftGroupbox("Auto Parry", "shield")

autoParryGroupbox:AddToggle("AP_Enable", {
    Text = "Enable Auto Parry",
    Default = false,
    Callback = function(v) parryEnabled = v end
})

autoParryGroupbox:AddSlider("AP_Range", {
    Text = "Parry Range (studs)",
    Default = parryRange, Min = 0, Max = 50, Rounding = 0,
    Callback = function(v) parryRange = v end
})

autoParryGroupbox:AddSlider("AP_PressDur", {
    Text = "Press Duration (s)",
    Default = pressDuration, Min = 0.05, Max = 0.50, Rounding = 2,
    Callback = function(v) pressDuration = v end
})

autoParryGroupbox:AddToggle("AP_PingComp", {
    Text = "Use Timing Offset (±200 ms)",
    Default = false,
    Callback = function(v) pingCompEnabled = v end
})

autoParryGroupbox:AddSlider("AP_PingOffset", {
    Text = "Timing Offset (ms)",
    Default = pingOffsetMs, Min = -200, Max = 200, Rounding = 0,
    Callback = function(v) pingOffsetMs = v end
})

autoParryGroupbox:AddToggle("AP_NotifyEach", {
    Text = "Notify Each Parry",
    Default = false,
    Callback = function(v) notifyEachParry = v end
})

autoParryGroupbox:AddButton({
    Text = "Show Ping",
    Func = function()
        Library:Notify(("Current Ping: %d ms"):format(tonumber(pingMs) or 0))
    end
})

autoParryGroupbox:AddButton({
    Text = "Reload Config",
    Func = function()
        if not tryLoadLocalConfig() then
            loadParryConfigFromJSON(defaultParryConfig)
            Library:Notify("[AutoParry] Loaded default config")
        end
    end
})
-- #### AUTO PARRY UI #### --
-- ======================= --

-- ======================== --
-- #### AIMBOT HELPERS #### --
local env = getgenv()
env.AimbotEnabled    = env.AimbotEnabled or false
env.AimKey           = env.AimKey or Enum.KeyCode.Q
env.FOV              = env.FOV or 80
env.FOVColor         = env.FOVColor or Color3.fromRGB(0, 255, 0)
env.FOVCircleVisible = env.FOVCircleVisible or false
env.Smoothness       = env.Smoothness or 0.25
env.Prediction       = env.Prediction or 0
env.DropCompensation = env.DropCompensation or 0
env.TargetParts      = env.TargetParts or {"Head"}
env.TargetTypes      = env.TargetTypes or {"Players"}
env.WallCheck        = env.WallCheck or false
env.TeamCheck        = env.TeamCheck or false
env.MobileAutoAim    = env.MobileAutoAim or false
env.ShowAimLine      = env.ShowAimLine or false

env.FOVCircle = env.FOVCircle or Drawing.new("Circle")
env.FOVCircle.Color = env.FOVColor
env.FOVCircle.Thickness = 1
env.FOVCircle.Radius = env.FOV
env.FOVCircle.Filled = false
env.FOVCircle.Visible = env.FOVCircleVisible
env.AimLine = env.AimLine or Drawing.new("Line")
env.AimLine.Visible = false
env.AimLine.Color = Color3.fromRGB(255, 0, 0)
env.AimLine.Thickness = 1
local function updateFOVCirclePosition()
    local size = camera.ViewportSize
    env.FOVCircle.Position = Vector2.new(size.X / 2, size.Y / 2)
end
updateFOVCirclePosition()
RunService.RenderStepped:Connect(updateFOVCirclePosition)

env.CurrentHighlight = env.CurrentHighlight or Instance.new("Highlight")
env.CurrentHighlight.Name = "AimbotTargetHighlight"
env.CurrentHighlight.FillColor = Color3.new(1, 0, 0)
env.CurrentHighlight.OutlineColor = Color3.new(0, 0, 0)
env.CurrentHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
env.CurrentHighlight.FillTransparency = 0.25
env.CurrentHighlight.OutlineTransparency = 0
env.CurrentHighlight.Adornee = nil
env.CurrentHighlight.Enabled = false
env.CurrentHighlight.Parent = game:GetService("CoreGui")

env.allPlayers = {}
local function refreshPlayerList()
    env.allPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and not table.find(env.allPlayers, plr) then
            table.insert(env.allPlayers, plr)
        end
    end
end
refreshPlayerList()
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player and not table.find(env.allPlayers, plr) then
        table.insert(env.allPlayers, plr)
    end
    plr.CharacterAdded:Connect(function()
        if not table.find(env.allPlayers, plr) then
            table.insert(env.allPlayers, plr)
        end
    end)
end)
Players.PlayerRemoving:Connect(function(removingPlayer)
    for i, p in ipairs(env.allPlayers) do
        if p == removingPlayer then table.remove(env.allPlayers, i) break end
    end
end)

local function isAiming()
    if UserInputService.TouchEnabled then
        return env.MobileAutoAim
    end
    if typeof(env.AimKey) ~= "EnumItem" then
        return false
    end
    return UserInputService:IsKeyDown(env.AimKey) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end
local function isVisible(part)
    if not env.WallCheck then return true end
    local bottomScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local rayOrigin = camera:ViewportPointToRay(bottomScreen.X, bottomScreen.Y, 0).Origin
    local direction = (part.Position - rayOrigin).Unit * 500
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = { player.Character }
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(rayOrigin, direction, rayParams)
    return not result or (result and result.Instance and result.Instance:IsDescendantOf(part.Parent))
end
local function getClosestTarget()
    local bestTarget = nil
    local closestDist = math.huge
    local selectedPartName = env.TargetParts[1]
    for _, plr in ipairs(env.allPlayers) do
        if plr.Character then
            if env.TeamCheck and player.Team and plr.Team and player.Team == plr.Team then
                continue
            end
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local part = char:FindFirstChild(selectedPartName)
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - env.FOVCircle.Position).Magnitude
                if onScreen and dist < closestDist and dist <= env.FOV and isVisible(part) then
                    bestTarget = char
                    closestDist = dist
                end
            end
        end
    end
    return bestTarget
end
local function aimAt(target)
    if not target then return end
    local aimPart = target:FindFirstChild(env.TargetParts[1])
    if not aimPart then return end
    local camPos = camera.CFrame.Position
    local targetPos = aimPart.Position + (aimPart.Velocity * env.Prediction)
    local distance = (targetPos - camPos).Magnitude
    local dropAdjust = Vector3.new(0, (distance / 100) * env.DropCompensation, 0)
    local predicted = targetPos + dropAdjust
    local dir = (predicted - camPos).Unit
    local cf = CFrame.new(camPos, camPos + dir)
    camera.CFrame = camera.CFrame:Lerp(cf, env.Smoothness)
    if env.ShowAimLine then
        local bottomScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
        local from3D = camera:ViewportPointToRay(bottomScreen.X, bottomScreen.Y, 0).Origin
        local to2D = camera:WorldToViewportPoint(aimPart.Position)
        local from2D = camera:WorldToViewportPoint(from3D)
        env.AimLine.From = Vector2.new(from2D.X, from2D.Y)
        env.AimLine.To = Vector2.new(to2D.X, to2D.Y)
        env.AimLine.Visible = true
    else
        env.AimLine.Visible = false
    end
end
RunService.RenderStepped:Connect(function()
    if not env.AimbotEnabled then
        env.CurrentHighlight.Enabled = false
        env.CurrentHighlight.Adornee = nil
        env.AimLine.Visible = false
        return
    end
    local target = getClosestTarget()
    if target then
        env.CurrentHighlight.Adornee = target
        env.CurrentHighlight.Enabled = true
        if isAiming() then
            aimAt(target)
        else
            env.AimLine.Visible = false
        end
    else
        env.CurrentHighlight.Enabled = false
        env.CurrentHighlight.Adornee = nil
        env.AimLine.Visible = false
    end
end)
-- #### AIMBOT HELPERS #### --
-- ======================== --

-- =================== --
-- #### AIMBOT UI #### --
aimbotGroupbox = Tabs.Combat:AddRightGroupbox("Aimbot", "crosshair")
aimbotGroupbox:AddToggle("AB_AimbotEnabled", { Text = "Enable Aimbot", Default = env.AimbotEnabled, 
    Callback = function(v) env.AimbotEnabled = v end 
})
aimbotGroupbox:AddToggle("AB_MobileAutoAim", { Text = "Mobile Auto Aim", Default = env.MobileAutoAim,
    Callback = function(v) env.MobileAutoAim = v end 
})
aimbotGroupbox:AddToggle("AB_ShowAimLine", { Text = "Show Aim Line", Default = env.ShowAimLine,
    Callback = function(v)
        env.ShowAimLine = v
        env.AimLine.Visible = false
    end
})
aimbotGroupbox:AddDropdown("AB_TargetTypes", { Text = "Target Types", Values = {"Players", "Mobs"}, Default = env.TargetTypes,
    Multi = true,
    Callback = function(o) env.TargetTypes = o end 
})
aimbotGroupbox:AddDropdown("AB_TargetParts", { Text = "Target Parts", Values = {"Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso"}, Default = env.TargetParts[1],
    Callback = function(o) env.TargetParts = { o } end 
})
aimbotGroupbox:AddToggle("AB_TeamCheck", { Text = "Team Check", Default = env.TeamCheck,
    Callback = function(v) env.TeamCheck = v end 
})
aimbotGroupbox:AddToggle("AB_WallCheck", { Text = "Wall Check", Default = env.WallCheck,
    Callback = function(v) env.WallCheck = v end 
})
aimbotGroupbox:AddLabel("AB_FOV Circle Color"):AddColorPicker("FOVColorPicker", { Default = env.FOVColor,
    Title = "FOV Circle Color",
    Callback = function(c)
        env.FOVColor = c
        env.FOVCircle.Color = c
    end 
})
aimbotGroupbox:AddToggle("AB_ShowFOVCircle", { Text = "Show FOV Circle", Default = env.FOVCircleVisible,
    Callback = function(v)
        env.FOVCircleVisible = v
        env.FOVCircle.Visible = v
    end 
})
aimbotGroupbox:AddSlider("AB_FOVRadius", { Text = "FOV Radius", Default = env.FOV, Min = 20, Max = 200, 
    Callback = function(v)
        env.FOV = v
        env.FOVCircle.Radius = v
    end 
})
aimbotGroupbox:AddSlider("AB_Smoothness", { Text = "Smoothness", Default = env.Smoothness, Min = 0.01, Max = 1, Float = 0.01,
    Callback = function(v) env.Smoothness = v end 
})
aimbotGroupbox:AddSlider("AB_Prediction", { Text = "Prediction", Default = env.Prediction, Min = 0.01, Max = 0.5, Float = 0.01,
    Callback = function(v) env.Prediction = v end 
})
aimbotGroupbox:AddSlider("AB_DropCompensation", { Text = "Drop Compensation", Default = env.DropCompensation, Min = 0, Max = 5, Float = 0.01,
    Callback = function(v) env.DropCompensation = v end 
})
-- #### AIMBOT UI #### --
-- =================== --

-- ################# --
-- #### ESP TAB #### --
-- ################# --

-- ===================== --
-- #### ESP HELPERS #### --
local SENSE = loadstring(game:HttpGet("https://raw.githubusercontent.com/AccountBurner/Lib/refs/heads/main/SENSE.lua"))()
SENSE.Load()

local function isPlayerModel(m)
    return Players:GetPlayerFromCharacter(m) ~= nil
end

local function hasRoot(model)
    return model and model:FindFirstChild("HumanoidRootPart") ~= nil
end

local function validEntity(model)
    return model and model:IsA("Model") and hasRoot(model) and not isPlayerModel(model) and isEntityAlive(model)
end

local Watchers = {
    Mobs = { conns = {}, tracked = {} },
    NPCs = { conns = {}, tracked = {} }
}

local function clearWatch(kind)
    local w = Watchers[kind]
    for inst, _ in pairs(w.tracked) do
        SENSE.RemoveInstance(inst)
    end
    for _, c in ipairs(w.conns) do
        if c.Connected then c:Disconnect() end
    end
    w.conns, w.tracked = {}, {}
end

local function watchChildren(folder, kind, customOptions)
    if not folder then return end
    local w = Watchers[kind]
    for _, m in ipairs(folder:GetChildren()) do
        if validEntity(m) and not w.tracked[m] then
            SENSE.AddInstanceEsp(m, customOptions)
            w.tracked[m] = true
        end
    end
    w.conns[#w.conns+1] = folder.ChildAdded:Connect(function(m)
        if validEntity(m) and not w.tracked[m] then
            SENSE.AddInstanceEsp(m, customOptions)
            w.tracked[m] = true
        end
    end)
    w.conns[#w.conns+1] = folder.ChildRemoved:Connect(function(m)
        if w.tracked[m] then
            SENSE.RemoveInstance(m)
            w.tracked[m] = nil
        end
    end)
end
-- #### ESP HELPERS #### --
-- ===================== --

-- ======================= --
-- #### PLAYER ESP UI #### --
local grpPlayers = Tabs.ESP:AddLeftGroupbox("Players")

grpPlayers:AddToggle("ESP_Player_Enemy", {
    Text = "Enemy ESP",
    Default = false,
    Callback = function(on)
        local t = SENSE.teamSettings.enemy
        t.enabled = on
    end
})

grpPlayers:AddToggle("ESP_Player_Friendly", {
    Text = "Friendly ESP",
    Default = false,
    Callback = function(on)
        local t = SENSE.teamSettings.friendly
        t.enabled = on
    end
})

grpPlayers:AddToggle("ESP_Player_Box", {
    Text = "Boxes",
    Default = false,
    Callback = function(on)
        SENSE.teamSettings.enemy.box = on
        SENSE.teamSettings.friendly.box = on
    end
})

grpPlayers:AddToggle("ESP_Player_Name", {
    Text = "Names",
    Default = true,
    Callback = function(on)
        SENSE.teamSettings.enemy.name = on
        SENSE.teamSettings.friendly.name = on
    end
})

grpPlayers:AddToggle("ESP_Player_Dist", {
    Text = "Distance",
    Default = true,
    Callback = function(on)
        SENSE.teamSettings.enemy.distance = on
        SENSE.teamSettings.friendly.distance = on
    end
})

grpPlayers:AddToggle("ESP_Player_HealthBar", {
    Text = "Health Bar",
    Default = true,
    Callback = function(on)
        SENSE.teamSettings.enemy.healthBar = on
        SENSE.teamSettings.friendly.healthBar = on
    end
})

grpPlayers:AddToggle("ESP_Player_Tracer", {
    Text = "Tracers",
    Default = false,
    Callback = function(on)
        SENSE.teamSettings.enemy.tracer = on
        SENSE.teamSettings.friendly.tracer = on
    end
})

grpPlayers:AddDropdown("ESP_Player_TracerOrigin", {
    Text = "Tracer Origin",
    Values = {"Top","Middle","Bottom"},
    Default = "Bottom",
    Callback = function(v)
        SENSE.teamSettings.enemy.tracerOrigin = v
        SENSE.teamSettings.friendly.tracerOrigin = v
    end
})

grpPlayers:AddToggle("ESP_Player_Offscreen", {
    Text = "Off-screen Arrows",
    Default = false,
    Callback = function(on)
        SENSE.teamSettings.enemy.offScreenArrow = on
        SENSE.teamSettings.friendly.offScreenArrow = on
    end
})

grpPlayers:AddToggle("ESP_Player_Chams", {
    Text = "Chams (Highlight)",
    Default = false,
    Callback = function(on)
        SENSE.teamSettings.enemy.chams = on
        SENSE.teamSettings.friendly.chams = on
    end
})

grpPlayers:AddLabel("Enemy Box Color"):AddColorPicker("ESP_Enemy_BoxColor", {
    Default = Color3.fromRGB(255,0,0),
    Title = "Enemy Box Color",
    Callback = function(c)
        SENSE.teamSettings.enemy.boxColor[1] = c
    end
})

grpPlayers:AddLabel("Friendly Box Color"):AddColorPicker("ESP_Friendly_BoxColor", {
    Default = Color3.fromRGB(0,255,0),
    Title = "Friendly Box Color",
    Callback = function(c)
        SENSE.teamSettings.friendly.boxColor[1] = c
    end
})

grpPlayers:AddLabel("Enemy Tracer Color"):AddColorPicker("ESP_Enemy_TracerColor", {
    Default = Color3.fromRGB(255,0,0),
    Title = "Enemy Tracer Color",
    Callback = function(c)
        SENSE.teamSettings.enemy.tracerColor[1] = c
    end
})

grpPlayers:AddLabel("Friendly Tracer Color"):AddColorPicker("ESP_Friendly_TracerColor", {
    Default = Color3.fromRGB(0,255,0),
    Title = "Friendly Tracer Color",
    Callback = function(c)
        SENSE.teamSettings.friendly.tracerColor[1] = c
    end
})
-- #### PLAYER ESP UI #### --
-- ======================= --

-- ======================= --
-- #### ENTITY ESP UI #### --
grpInst1   = Tabs.ESP:AddRightGroupbox("Entities")

local MOB_OPTS = {
    enabled = true,
    box = true,
    name = true,
    distance = true,
    healthBar = true,
    tracer = false,
    boxColor = { Color3.fromRGB(0,255,0), 1 },
    tracerColor = { Color3.fromRGB(0,255,0), 1 },
    tracerOrigin = "Bottom",
}

grpInst1:AddToggle("ESP_Mobs_Enable", {
    Text = "Enable",
    Default = false,
    Callback = function(on)
        if not on then
            clearWatch("Mobs")
            return
        end
        local folder = Workspace:FindFirstChild("Entities")
        clearWatch("Mobs")
        watchChildren(folder, "Mobs", MOB_OPTS)
    end
})

grpInst1:AddToggle("ESP_Mobs_Box", {
    Text = "Boxes",
    Default = MOB_OPTS.box,
    Callback = function(on) MOB_OPTS.box = on end
})

grpInst1:AddToggle("ESP_Mobs_Name", {
    Text = "Names",
    Default = MOB_OPTS.name,
    Callback = function(on) MOB_OPTS.name = on end
})

grpInst1:AddToggle("ESP_Mobs_Dist", {
    Text = "Distance",
    Default = MOB_OPTS.distance,
    Callback = function(on) MOB_OPTS.distance = on end
})

grpInst1:AddToggle("ESP_Mobs_Health", {
    Text = "Health Bar",
    Default = MOB_OPTS.healthBar,
    Callback = function(on) MOB_OPTS.healthBar = on end
})

grpInst1:AddToggle("ESP_Mobs_Tracer", {
    Text = "Tracers",
    Default = MOB_OPTS.tracer,
    Callback = function(on) MOB_OPTS.tracer = on end
})

grpInst1:AddDropdown("ESP_Mobs_TracerOrigin", {
    Text = "Tracer Origin",
    Values = {"Top","Middle","Bottom"},
    Default = MOB_OPTS.tracerOrigin,
    Callback = function(v) MOB_OPTS.tracerOrigin = v end
})

grpInst1:AddLabel("Mob Box Color"):AddColorPicker("ESP_Mobs_BoxColor", {
    Default = MOB_OPTS.boxColor[1],
    Title = "Mob Box Color",
    Callback = function(c) MOB_OPTS.boxColor[1] = c end
})

grpInst1:AddLabel("Mob Tracer Color"):AddColorPicker("ESP_Mobs_TracerColor", {
    Default = MOB_OPTS.tracerColor[1],
    Title = "Mob Tracer Color",
    Callback = function(c) MOB_OPTS.tracerColor[1] = c end
})

grpInst1:AddButton({ Text = "Refresh Entities", Func = function()
    if Options.ESP_Mobs_Enable and Options.ESP_Mobs_Enable.Value then
        local folder = Workspace:FindFirstChild("Entities")
        clearWatch("Mobs")
        watchChildren(folder, "Mobs", MOB_OPTS)
        Library:Notify("[ESP] Refreshed Entities.", 2)
    end
end })
-- #### ENTITY ESP UI #### --
-- ======================= --

-- ==================== --
-- #### NPC ESP UI #### --
grpInst2   = Tabs.ESP:AddRightGroupbox("NPCs")

local NPC_OPTS = {
    enabled = true,
    box = true,
    name = true,
    distance = true,
    healthBar = false,
    tracer = false,
    boxColor = { Color3.fromRGB(0,200,255), 1 },
    tracerColor = { Color3.fromRGB(255,255,255), 1 },
    tracerOrigin = "Bottom",
}

grpInst2:AddToggle("ESP_NPC_Enable", {
    Text = "Enable",
    Default = false,
    Callback = function(on)
        if not on then
            clearWatch("NPCs")
            return
        end
        clearWatch("NPCs")
        local npcs = Workspace:FindFirstChild("NPCs")
        if npcs then
            for _, d in ipairs(npcs:GetDescendants()) do
                if d:IsA("Model") and hasRoot(d) then
                    if not Watchers.NPCs.tracked[d] then
                        SENSE.AddInstanceEsp(d, NPC_OPTS)
                        Watchers.NPCs.tracked[d] = true
                    end
                end
            end
            Watchers.NPCs.conns[#Watchers.NPCs.conns+1] = npcs.DescendantAdded:Connect(function(d)
                if d:IsA("Model") and hasRoot(d) and not Watchers.NPCs.tracked[d] then
                    SENSE.AddInstanceEsp(d, NPC_OPTS)
                    Watchers.NPCs.tracked[d] = true
                end
            end)
            Watchers.NPCs.conns[#Watchers.NPCs.conns+1] = npcs.DescendantRemoving:Connect(function(d)
                if Watchers.NPCs.tracked[d] then
                    SENSE.RemoveInstance(d)
                    Watchers.NPCs.tracked[d] = nil
                end
            end)
        end
    end
})

grpInst2:AddToggle("ESP_NPC_Box", {
    Text = "Boxes",
    Default = NPC_OPTS.box,
    Callback = function(on) NPC_OPTS.box = on end
})

grpInst2:AddToggle("ESP_NPC_Name", {
    Text = "Names",
    Default = NPC_OPTS.name,
    Callback = function(on) NPC_OPTS.name = on end
})

grpInst2:AddToggle("ESP_NPC_Dist", {
    Text = "Distance",
    Default = NPC_OPTS.distance,
    Callback = function(on) NPC_OPTS.distance = on end
})

grpInst2:AddToggle("ESP_NPC_Tracer", {
    Text = "Tracers",
    Default = NPC_OPTS.tracer,
    Callback = function(on) NPC_OPTS.tracer = on end
})

grpInst2:AddDropdown("ESP_NPC_TracerOrigin", {
    Text = "Tracer Origin",
    Values = {"Top","Middle","Bottom"},
    Default = NPC_OPTS.tracerOrigin,
    Callback = function(v) NPC_OPTS.tracerOrigin = v end
})

grpInst2:AddLabel("NPC Box Color"):AddColorPicker("ESP_NPC_BoxColor", {
    Default = NPC_OPTS.boxColor[1],
    Title = "NPC Box Color",
    Callback = function(c) NPC_OPTS.boxColor[1] = c end
})

grpInst2:AddLabel("NPC Tracer Color"):AddColorPicker("ESP_NPC_TracerColor", {
    Default = NPC_OPTS.tracerColor[1],
    Title = "NPC Tracer Color",
    Callback = function(c) NPC_OPTS.tracerColor[1] = c end
})

grpInst2:AddButton({ Text = "Refresh NPCs", Func = function()
    if Options.ESP_NPC_Enable and Options.ESP_NPC_Enable.Value then
        clearWatch("NPCs")
        local npcs = Workspace:FindFirstChild("NPCs")
        if npcs then
            for _, d in ipairs(npcs:GetDescendants()) do
                if d:IsA("Model") and hasRoot(d) then
                    if not Watchers.NPCs.tracked[d] then
                        SENSE.AddInstanceEsp(d, NPC_OPTS)
                        Watchers.NPCs.tracked[d] = true
                    end
                end
            end
            Library:Notify("[ESP] Refreshed NPCs.", 2)
        end
    end
end })
-- #### NPC ESP UI #### --
-- ==================== --

-- ================================ --
-- #### GLOBAL ESP SETTINGS UI #### --
grpGlobal  = Tabs.ESP:AddRightGroupbox("ESP Global")

grpGlobal:AddToggle("ESP_LimitDistance", {
    Text = "Limit Distance",
    Default = false,
    Callback = function(on)
        SENSE.sharedSettings.limitDistance = on
    end
})

grpGlobal:AddSlider("ESP_MaxDistance", {
    Text = "Max Distance",
    Default = 1000,
    Min = 100, Max = 10000, Rounding = 0, Suffix = "studs",
    Callback = function(v)
        SENSE.sharedSettings.maxDistance = v
        if not Options.ESP_LimitDistance.Value then
            SENSE.sharedSettings.limitDistance = true
            Options.ESP_LimitDistance:SetValue(true)
        end
    end
})

grpGlobal:AddSlider("ESP_TextSize", {
    Text = "Text Size",
    Default = 14,
    Min = 10, Max = 30, Rounding = 0, Suffix = "px",
    Callback = function(v)
        SENSE.sharedSettings.textSize = v
    end
})
grpGlobal:AddButton({ Text = "Enable Enemy/Friendly Preset", Func = function()
    SENSE.EnableEnemyEsp()
    SENSE.EnableFriendlyEsp()
    Options.ESP_Player_Enemy:SetValue(true)
    Options.ESP_Player_Friendly:SetValue(true)
end })

Library:OnUnload(function()
    clearWatch("Mobs")
    clearWatch("NPCs")
    SENSE.Unload()
end)
-- #### GLOBAL ESP SETTINGS UI #### --
-- ================================ --

-- ====================== --
-- #### VISUAL UTILS #### --
visualUtilsGroupbox = Tabs.ESP:AddLeftGroupbox("Visual Utils", "lightbulb")

-- #### FULLBRIGHT #### --
local fullbrightEnabled = false
local originalLighting = {}
local function storeOriginalLighting()
    originalLighting.Brightness = Lighting.Brightness
    originalLighting.GlobalShadows = Lighting.GlobalShadows
    originalLighting.Ambient = Lighting.Ambient
end
local function setFullbright(enabled)
    fullbrightEnabled = enabled
    if enabled then
        storeOriginalLighting()
    else
        if next(originalLighting) then
            Lighting.Brightness = originalLighting.Brightness
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.Ambient = originalLighting.Ambient
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
visualUtilsGroupbox:AddToggle("FullbrightToggle", { Text = "Fullbright", Default = false,
    Callback = function(Value) setFullbright(Value) end 
})

-- #### NO FOG #### --
local originalFogEnd   = Lighting.FogEnd
local originalFogStart = Lighting.FogStart
local originalFogColor = Lighting.FogColor
local removedWeatherItems = {}
local weatherClasses = { Atmosphere=true, BloomEffect=true, SunRaysEffect=true, Sky=true }
local childAddedConn = nil
local function removeExistingWeather()
    for _, child in ipairs(Lighting:GetChildren()) do
        if weatherClasses[child.ClassName] then
            table.insert(removedWeatherItems, child)
            child.Parent = nil
        end
    end
end
local function onChildAdded(child)
    if weatherClasses[child.ClassName] then
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
    if childAddedConn then childAddedConn:Disconnect() childAddedConn = nil end
    Lighting.FogEnd   = originalFogEnd
    Lighting.FogStart = originalFogStart
    Lighting.FogColor = originalFogColor
    for _, inst in ipairs(removedWeatherItems) do
        if inst and not inst.Parent then inst.Parent = Lighting end
    end
    table.clear(removedWeatherItems)
end
visualUtilsGroupbox:AddToggle("noFog", { Text = "No Fog", Default = false,
    Callback = function(state)
        if state then enableNoFog() else restoreFogAndWeather() end
    end
})

-- #### FREECAM #### --
local camDummy = Instance.new("Part")
camDummy.Name = "FreecamSubject"
camDummy.Size = Vector3.new(1, 1, 1)
camDummy.Transparency = 1
camDummy.Anchored = true
camDummy.CanCollide = false
camDummy.Parent = Workspace
local freecamFlying = false
local flyKeyDown = {}
local camConn = nil
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
visualUtilsGroupbox:AddToggle("freecamToggle", { Text = "Freecam", Default = false,
    Callback = function(state)
        freecamFlying = state
        if state then
            if humanoidRootPart then humanoidRootPart.Anchored = true end
            camDummy.CFrame = Camera.CFrame
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = camDummy
            camConn = RunService.RenderStepped:Connect(function(dt)
                local moveVec = Vector3.new(0, 0, 0)
                local camCF = Camera.CFrame
                if flyKeyDown[Enum.KeyCode.W] then moveVec += camCF.LookVector end
                if flyKeyDown[Enum.KeyCode.S] then moveVec -= camCF.LookVector end
                if flyKeyDown[Enum.KeyCode.A] then moveVec -= camCF.RightVector end
                if flyKeyDown[Enum.KeyCode.D] then moveVec += camCF.RightVector end
                if flyKeyDown[Enum.KeyCode.Space] then moveVec += camCF.UpVector end
                if flyKeyDown[Enum.KeyCode.LeftShift] then moveVec -= camCF.UpVector end
                if moveVec.Magnitude > 0 then
                    local delta = moveVec.Unit * 100 * dt
                    camDummy.CFrame = camDummy.CFrame + delta
                end
            end)
        else
            if camConn then camConn:Disconnect() camConn = nil end
            Camera.CameraType = Enum.CameraType.Custom
            if player.Character and humanoidRootPart then 
                Camera.CameraSubject = humanoidRootPart 
            end
            if humanoidRootPart then humanoidRootPart.Anchored = false end
        end
    end
})
-- #### VISUAL UTILS #### --
-- ====================== --

-- ################## --
-- #### MISC TAB #### --
-- ################## --

-- ====================== --
-- #### SERVER PANEL #### --
local PlaceId = game.PlaceId
local JobId   = game.JobId
serverPanelGroupbox = Tabs.Misc:AddLeftGroupbox("Server Panel")
serverPanelGroupbox:AddButton({ Text = "Rejoin Server", Func = function()
    TeleportService:TeleportToPlaceInstance(PlaceId, JobId, player)
end })
serverPanelGroupbox:AddButton({ Text = "Join Random Server", Func = function()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, player)
                return
            end
        end
    end
    Library:Notify("Server Join Failed | Couldn't find a different server.", 5)
end })
serverPanelGroupbox:AddButton({ Text = "Join Lowest Server", Func = function()
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and response and response.data then
        for _, server in ipairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= JobId then
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, player)
                return
            end
        end
    end
    Library:Notify("Server Join Failed | No suitable server found with fewer players.", 5)
end })
serverPanelGroupbox:AddButton({ Text = "Copy Join Script", Func = function()
    local snippet = "local TeleportService = game:GetService('TeleportService')\n" ..
                    "TeleportService:TeleportToPlaceInstance(" .. PlaceId .. ", '" .. JobId .. "', game.Players.player)\n"
    if setclipboard then
        setclipboard(snippet)
        Library:Notify("Copied! | Run this in an executor to join the current server.", 4)
    else
        Library:Notify("Clipboard Error | setclipboard() not available.", 4)
    end
end })
-- #### SERVER PANEL #### --
-- ====================== --

-- ===================== --
-- #### ENVIRONMENT #### --
local environmentSettings = { 
    ambientEnabled = false, customAmbientColor = Color3.fromRGB(128, 128, 128), originalAmbient = Lighting.Ambient,
    timeLockEnabled = false, timeLockConn = nil, timeValue = Lighting.ClockTime
}
local function updateAmbient()
    Lighting.Ambient = environmentSettings.ambientEnabled and environmentSettings.customAmbientColor or environmentSettings.originalAmbient
end
enviromentGroupbox = Tabs.Misc:AddRightGroupbox("Environment")
enviromentGroupbox:AddToggle("Ambient", { Text = "Custom Ambient", Default = false,
    Callback = function(state)
        environmentSettings.ambientEnabled = state
        updateAmbient()
    end
})
enviromentGroupbox:AddLabel("Ambient Color"):AddColorPicker("ambientColor", { Default = environmentSettings.customAmbientColor,
    Title = "Ambient Color",
    Callback = function(newColor)
        environmentSettings.customAmbientColor = newColor
        if environmentSettings.ambientEnabled then updateAmbient() end
    end
})
enviromentGroupbox:AddToggle("LockTimeOfDayToggle", { Text = "Custom Time of Day", Default = false,
    Callback = function(enabled)
        environmentSettings.timeLockEnabled = enabled
        if enabled then
            Library:Notify("Time of Day Locked | The daylight cycle is frozen", 5)
            Lighting.ClockTime = environmentSettings.timeValue
            environmentSettings.timeLockConn = RunService.RenderStepped:Connect(function()
                Lighting.ClockTime = environmentSettings.timeValue
            end)
        else
            Library:Notify("Time of Day Unlocked | The daylight cycle will resume", 5)
            if environmentSettings.timeLockConn then 
                environmentSettings.timeLockConn:Disconnect() 
                environmentSettings.timeLockConn = nil 
            end
        end
    end
})
enviromentGroupbox:AddSlider("TimeOfDaySlider", { Text = "Time of Day", Default = environmentSettings.timeValue, Min = 0, Max = 24, Suffix = "h",
    Callback = function(val)
        environmentSettings.timeValue = val
        if environmentSettings.timeLockEnabled then Lighting.ClockTime = val end
    end
})
-- #### ENVIRONMENT #### --
-- ===================== --

-- ######################### --
-- #### UI SETTINGS TAB #### --
-- ######################### --

local UI = Tabs["UI Settings"]
local MenuGroup = UI:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",  
    NoUI    = false,        
    Text    = "Toggle menu",
    Mode    = "Toggle"  
})
Library.KeybindFrame.Visible = true
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder("Cerberus")
SaveManager:SetFolder("Cerberus")
SaveManager:BuildConfigSection(UI)
ThemeManager:ApplyToTab(UI)
SaveManager:LoadAutoloadConfig()

task.defer(function()
    local O = rawget(getgenv(), "Options") or Library.Options
    local tries = 0
    while (not O or not O.MenuKeybind) and tries < 120 do
        tries += 1
        task.wait()
        O = rawget(getgenv(), "Options") or Library.Options
    end

    if not O or not O.MenuKeybind then
        warn("[UI] MenuKeybind control not available; using RightShift fallback")
        Library.ToggleKeybind = Enum.KeyCode.RightShift
        return
    end
    Library.ToggleKeybind = O.MenuKeybind
    O.MenuKeybind:OnChanged(function()
        Library.ToggleKeybind = O.MenuKeybind
    end)
end)
