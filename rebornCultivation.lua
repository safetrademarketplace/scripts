-- =============== --
-- ==== SETUP ==== --
-- =============== --

-- == SERVICES == --
local Services = {
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    RunService = game:GetService("RunService"),
    TweenService = game:GetService("TweenService"),
    Debris = game:GetService("Debris"),
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    ContextActionService = game:GetService("ContextActionService"),
    GuiService = game:GetService("GuiService"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    MarketplaceService = game:GetService("MarketplaceService"),
    TeleportService = game:GetService("TeleportService"),
    SoundService = game:GetService("SoundService"),
    CollectionService = game:GetService("CollectionService"),
    HttpService = game:GetService("HttpService"),
    PathfindingService = game:GetService("PathfindingService"),
}

-- == REFERENCES == --
local References = {
    player = Services.Players.LocalPlayer,
    character = nil,
    humanoid = nil,
    humanoidRootPart = nil,
    camera = Services.Workspace.CurrentCamera,
    gameName = "Grow a Garden"
}

-- == OBSIDIAN UI SETUP == --
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "Cerberus",
	Footer = References.gameName,
	Icon = 136497541793809,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Main = Window:AddTab("Main", "menu"),
    Player = Window:AddTab("Player", "circle-user"),
-- Combat = Window:AddTab("Combat", "swords"),
    ESP = Window:AddTab("ESP", "eye"),
    Auto = Window:AddTab("Auto", "bot"),
    Misc = Window:AddTab("Misc", "archive"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- ========================== --
-- ==== HELPER FUNCTIONS ==== --
-- ========================== --

local RS, W = Services.RunService, Services.Workspace

local Hover = {
    _hoverConn = nil,
    _moveConn  = nil,
    _attHRP    = nil,
    _attWorld  = nil,
    _ap        = nil,
    _ao        = nil,
    _hoverPos  = nil,
    _noclipConn = nil,
    _noclipParts = {}
}

local function HRP()
    return References and References.humanoidRootPart
end

local function Char()
    return References and References.character
end

local function setNoClip(state)
    local char = Char(); if not char then return end
    if state then
        if Hover._noclipConn then return end
        table.clear(Hover._noclipParts)
        Hover._noclipConn = RS.Stepped:Connect(function()
            local c = Char(); if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    Hover._noclipParts[part] = true
                    part.CanCollide = false
                end
            end
        end)
    else
        if Hover._noclipConn then Hover._noclipConn:Disconnect(); Hover._noclipConn = nil end
        for p in pairs(Hover._noclipParts) do
            if p and p.Parent then p.CanCollide = true end
        end
        table.clear(Hover._noclipParts)
    end
end

local function ensureConstraints()
    local hrp = HRP(); if not hrp then return false end

    if not Hover._attHRP then
        local a = Instance.new("Attachment")
        a.Name, a.Parent = "_NoxHover_AttHRP", hrp
        Hover._attHRP = a
    end

    if not Hover._attWorld then
        local a = Instance.new("Attachment")
        a.Name, a.Parent = "_NoxHover_AttWorld", W.Terrain
        Hover._attWorld = a
    end

    if not Hover._ap then
        local ap = Instance.new("AlignPosition")
        ap.Name = "_NoxHover_AlignPosition"
        ap.Mode = Enum.PositionAlignmentMode.TwoAttachment
        ap.Attachment0 = Hover._attHRP
        ap.Attachment1 = Hover._attWorld
        ap.ApplyAtCenterOfMass = true
        ap.Responsiveness = 200 
        ap.MaxForce = math.huge
        ap.ReactionForceEnabled = false
        ap.RigidityEnabled = true
        ap.Parent = hrp
        Hover._ap = ap
    end

    if not Hover._ao then
        local ao = Instance.new("AlignOrientation")
        ao.Name = "_NoxHover_AlignOrientation"
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = Hover._attHRP
        ao.Responsiveness = 200
        ao.MaxTorque = math.huge
        ao.ReactionTorqueEnabled = false
        ao.RigidityEnabled = true
        ao.Parent = hrp
        Hover._ao = ao
    end

    return true
end

local function destroyConstraints()
    if Hover._ap then Hover._ap:Destroy(); Hover._ap = nil end
    if Hover._ao then Hover._ao:Destroy(); Hover._ao = nil end
    if Hover._attHRP then Hover._attHRP:Destroy(); Hover._attHRP = nil end
    if Hover._attWorld then Hover._attWorld:Destroy(); Hover._attWorld = nil end
end

function Hover.Stop()
    if Hover._hoverConn then Hover._hoverConn:Disconnect(); Hover._hoverConn = nil end
    if Hover._moveConn  then Hover._moveConn:Disconnect();  Hover._moveConn  = nil end
    Hover._hoverPos = nil
    destroyConstraints()
    setNoClip(false)

    local hrp = HRP()
    if hrp then
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
end

function Hover.Start(targetPos)
    Hover.Stop()
    local hrp = HRP(); if not hrp then return end
    if not ensureConstraints() then return end

    setNoClip(true)

    Hover._hoverPos = (typeof(targetPos) == "Vector3") and targetPos or hrp.Position
    Hover._attWorld.WorldPosition = Hover._hoverPos
    local look = hrp.CFrame.LookVector
    Hover._ao.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)

    hrp.AssemblyLinearVelocity  = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    Hover._hoverConn = RS.Heartbeat:Connect(function()
        if not Hover._hoverPos then return end
        if not HRP() then Hover.Stop(); return end
        Hover._attWorld.WorldPosition = Hover._hoverPos
    end)
end

function Hover.MoveTo(targetPos, speed, hoverAtEnd, onArrive)
    Hover.Stop()
    local hrp = HRP(); if not hrp or typeof(targetPos) ~= "Vector3" then return end
    speed = tonumber(speed) or 60
    if speed <= 0 then speed = 60 end

    if not ensureConstraints() then return end
    setNoClip(true)

    local start = hrp.Position
    local dist = (targetPos - start).Magnitude
    if dist <= 1e-6 then
        if hoverAtEnd then Hover.Start(targetPos) else setNoClip(false) end
        if onArrive then onArrive() end
        return
    end

    local duration, elapsed = dist / speed, 0
    Hover._moveConn = RS.Heartbeat:Connect(function(dt)
        local h = HRP()
        if not h then Hover.Stop(); return end

        elapsed += dt
        local alpha = math.clamp(elapsed / duration, 0, 1)
        local pos = start:Lerp(targetPos, alpha)

        local dir = (targetPos - start)
        if dir.Magnitude > 1e-6 then
            local now = h.Position
            local face = (pos - now)
            if face.Magnitude > 1e-6 then
                Hover._ao.CFrame = CFrame.lookAt(now, now + face.Unit)
            end
        end

        Hover._attWorld.WorldPosition = pos
        h.AssemblyLinearVelocity  = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero

        if alpha >= 1 then
            Hover._moveConn:Disconnect(); Hover._moveConn = nil
            if hoverAtEnd then
                Hover.Start(targetPos)
            else
                Hover.Stop()
            end
            if onArrive then onArrive() end
        end
    end)
end

References.player.CharacterAdded:Connect(function()
    Hover.Stop()
end)
References.player.CharacterRemoving:Connect(function()
    Hover.Stop()
end)

_G.NoxHover = Hover
-- ========================== --

-- ================== --
-- ==== MAIN TAB ==== --
-- ================== --

local _att = {
    on    = false,
    mode  = "enemy",
    sel   = "",
    conn  = nil,
    wAn   = nil,
    wHp   = nil,
    tgt   = nil,

    off   = { x = 0, y = -10, z = 3 },
    speed = 120,

    moving     = false,
    lastDest   = nil,
    offsetDirty= false,
    lastIssue  = 0,
    recalcCD   = 0.12,  -- seconds between re-issues
}

local P, W, RS = Services.Players, Services.Workspace, Services.RunService
local Hover = _G.NoxHover

local function clearWatch()
    if _att.wAn then _att.wAn:Disconnect() _att.wAn = nil end
    if _att.wHp then _att.wHp:Disconnect() _att.wHp = nil end
end

local function alive(model)
    if not (model and model:IsA("Model") and model.Parent) then return false end
    local h = model:FindFirstChildOfClass("Humanoid"); if not (h and h.Health > 0) then return false end
    return model:FindFirstChild("HumanoidRootPart") ~= nil
end

local function baseName(s) s=tostring(s or ""); return s:match("^%u%l+") or s:match("^%a+") or s end
local function hrpOf(m) return m and m:FindFirstChild("HumanoidRootPart") or nil end

local function desiredHoverPoint(model, off)
    local r = hrpOf(model); if not r then return end
    local cf = r.CFrame
    local right, up, fwd = cf.RightVector, Vector3.new(0,1,0), cf.LookVector
    local dest = r.Position + right*(off.x or 0) + up*(off.y or 0) - fwd*(off.z or 0)
    return dest, r.Position
end

local function nearest(from, list)
    local best, bestPos, bestD = nil, nil, math.huge
    for i=1,#list do
        local r = hrpOf(list[i])
        if r then
            local d = (from - r.Position).Magnitude
            if d < bestD then best, bestPos, bestD = list[i], r.Position, d end
        end
    end
    return best, bestPos
end

local function listEnemiesByBaseName(name)
    local out, want = {}, baseName(name or "")
    for _, d in ipairs(W:GetDescendants()) do
        if d:IsA("Model") and d ~= References.character then
            local h = d:FindFirstChildOfClass("Humanoid")
            local r = d:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 and baseName(d.Name) == want then
                out[#out+1] = d
            end
        end
    end
    return out
end
local function listPlayersExact(name)
    local out, plr = {}, P:FindFirstChild(name or "")
    if plr and plr.Character and alive(plr.Character) then out[1] = plr.Character end
    return out
end
local function reacquire()
    local root = References.humanoidRootPart; if not root then return nil end
    local pool = (_att.mode == "enemy") and listEnemiesByBaseName(_att.sel) or listPlayersExact(_att.sel)
    if #pool == 0 then return nil end
    return nearest(root.Position, pool)
end

local function watchTarget(model)
    clearWatch()
    if not model then return end
    _att.wAn = model.AncestryChanged:Connect(function(_, parent)
        if _att.on and (not parent or not model:IsDescendantOf(W)) then _att.tgt = nil end
    end)
    local h = model:FindFirstChildOfClass("Humanoid")
    if h then
        _att.wHp = h.HealthChanged:Connect(function(v)
            if _att.on and v <= 0 then _att.tgt = nil end
        end)
    end
end

local function now() return os.clock() end

-- single place that (re)issues movement safely
local function issueMove(dest, preferHover)
    local root = References.humanoidRootPart; if not root or not dest then return end
    local t = now()
    if t - _att.lastIssue < _att.recalcCD then return end  -- debounce

    _att.lastIssue = t
    local dist = (root.Position - dest).Magnitude

    if dist <= 2 or preferHover then
        _att.moving = false
        _att.lastDest = dest
        if Hover and Hover.Start then Hover.Start(dest) end
        return
    end

    if _att.moving and Hover and Hover.Stop then
        Hover.Stop()
        _att.moving = false
    end

    _att.moving = true
    _att.lastDest = dest
    if Hover and Hover.MoveTo then
        Hover.MoveTo(dest, _att.speed, true, function()
            _att.moving = false
        end)
    else
        root.CFrame = CFrame.new(dest)
        _att.moving = false
    end
end

local function startAttach()
    if _att.conn then return end
    _att.conn = RS.Heartbeat:Connect(function()
        if not _att.on then return end
        local root = References.humanoidRootPart; if not root then return end

        -- ensure/refresh target
        if (not _att.tgt) or (not alive(_att.tgt)) then
            local t = reacquire()
            if not t then return end
            _att.tgt = t
            watchTarget(_att.tgt)
            _att.lastDest = nil
        end

        local dest = desiredHoverPoint(_att.tgt, _att.off)
        if not dest then _att.tgt = nil; return end
        local preferHover = (not _att.moving)
        if _att.offsetDirty then
            if _att.moving and Hover and Hover.Stop then Hover.Stop(); _att.moving = false end
            _att.offsetDirty = false
            issueMove(dest, preferHover)
            return
        end
        if (not _att.lastDest) or (dest - _att.lastDest).Magnitude > 0.75 then
            issueMove(dest, preferHover)
        end
    end)
end

local function stopAttach()
    _att.on = false
    if _att.conn then _att.conn:Disconnect() _att.conn = nil end
    clearWatch()
    _att.tgt, _att.moving, _att.lastDest = nil, false, nil
    if Hover and Hover.Stop then Hover.Stop() end
end

_G.stopAttach = stopAttach

local AttachGB = Tabs.Main:AddRightGroupbox("Attach", "swords")

-- helper to flag offset changes without spamming movers
local function markOffsetDirty(v, axis)
    _att.off[axis] = v
    _att.offsetDirty = true
end

AttachGB:AddSlider("Attach_OffX", {
    Text = "Offset X (Right +)", Min = -30, Max = 30, Rounding = 0, Default = _att.off.x,
    Callback = function(v) markOffsetDirty(v, "x") end,
})
AttachGB:AddSlider("Attach_OffY", {
    Text = "Offset Y (Up +)", Min = -50, Max = 50, Rounding = 0, Default = _att.off.y,
    Callback = function(v) markOffsetDirty(v, "y") end,
})
AttachGB:AddSlider("Attach_OffZ", {
    Text = "Offset Z (Behind +)", Min = -50, Max = 50, Rounding = 0, Default = _att.off.z,
    Callback = function(v) markOffsetDirty(v, "z") end,
})

AttachGB:AddSlider("Attach_Speed", {
    Text = "Approach Speed", Min = 20, Max = 400, Rounding = 0, Default = _att.speed,
    Callback = function(v) _att.speed = v end,
})

local function enemyNameOptions()
    local seen, out = {}, {}
    for _, d in ipairs(W:GetDescendants()) do
        if d:IsA("Model") then
            local h = d:FindFirstChildOfClass("Humanoid")
            local r = d:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 then
                local b = baseName(d.Name)
                if b ~= "" and not seen[b] then seen[b] = true; out[#out+1] = b end
            end
        end
    end
    table.sort(out)
    return out
end

local function playerNameOptions()
    local out = {}
    for _, pl in ipairs(P:GetPlayers()) do
        if pl ~= References.player then out[#out+1] = pl.Name end
    end
    table.sort(out)
    return out
end

AttachGB:AddDropdown("Attach_EnemySelect", {
    Text = "Enemy Group",
    Values = enemyNameOptions(),
    Default = "",
    Callback = function(v)
        _att.sel  = v or ""
        _att.mode = "enemy"
        _att.tgt, _att.lastDest = nil, nil
    end
})
AttachGB:AddButton("Refresh Enemies", function()
    local vals = enemyNameOptions()
    local cur  = Options.Attach_EnemySelect.Value
    Options.Attach_EnemySelect:SetValues(vals)
    if cur ~= "" and table.find(vals, cur) then
        Options.Attach_EnemySelect:SetValue(cur)
    elseif vals[1] then
        Options.Attach_EnemySelect:SetValue(vals[1])
    end
end)

AttachGB:AddToggle("AttachEnemy", {
    Text = "Attach: Enemies",
    Default = false,
    Callback = function(on)
        if on then
            local pt = Toggles.AttachPlayer
            if pt and pt.Value then pt:SetValue(false) end
            _att.mode = "enemy"
            _att.sel  = Options.Attach_EnemySelect.Value or ""
            if _att.sel == "" then
                Library:Notify("Pick an Enemy Group first.", 3)
                Toggles.AttachEnemy:SetValue(false)
                return
            end
            _att.on = true
            startAttach()
        else
            stopAttach()
        end
    end
})

AttachGB:AddDropdown("Attach_PlayerSelect", {
    Text = "Player",
    Values = playerNameOptions(),
    Default = "",
    Callback = function(v)
        _att.sel  = v or ""
        _att.mode = "player"
        _att.tgt, _att.lastDest = nil, nil
    end
})
AttachGB:AddButton("Refresh Players", function()
    local vals = playerNameOptions()
    local cur  = Options.Attach_PlayerSelect.Value
    Options.Attach_PlayerSelect:SetValues(vals)
    if cur ~= "" and table.find(vals, cur) then
        Options.Attach_PlayerSelect:SetValue(cur)
    elseif vals[1] then
        Options.Attach_PlayerSelect:SetValue(vals[1])
    end
end)

AttachGB:AddToggle("AttachPlayer", {
    Text = "Attach: Player",
    Default = false,
    Callback = function(on)
        if on then
            local et = Toggles.AttachEnemy
            if et and et.Value then et:SetValue(false) end
            _att.mode = "player"
            _att.sel  = Options.Attach_PlayerSelect.Value or ""
            if _att.sel == "" then
                Library:Notify("Pick a Player first.", 3)
                Toggles.AttachPlayer:SetValue(false)
                return
            end
            _att.on = true
            startAttach()
        else
            stopAttach()
        end
    end
})

Services.Players.PlayerAdded:Connect(function()
    local t = Options.Attach_PlayerSelect
    if t then t:SetValues(playerNameOptions()) end
end)
Services.Players.PlayerRemoving:Connect(function()
    local t = Options.Attach_PlayerSelect
    if t then t:SetValues(playerNameOptions()) end
end)

-- == TELEPORTS ==
local TeleportsGroupbox = Tabs.Main:AddLeftGroupbox("Teleports", "move-3d")
local tpMap, npcModelByLabel = {}, {}

local function uniq(used, base)
    local k, n = base, 1
    while used[k] do n += 1; k = (`%s (%d)`):format(base, n) end
    used[k] = true; return k
end

local function scan(category)
    table.clear(tpMap); table.clear(npcModelByLabel)
    if category == "Players" then
        local used = {}
        for _, pl in ipairs(Services.Players:GetPlayers()) do
            if pl ~= References.player then
                local ch = pl.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local base = (pl.DisplayName ~= "" and pl.DisplayName) or pl.Name
                    tpMap[uniq(used, base)] = hrp.Position
                end
            end
        end
    else
        local folder = Services.Workspace:FindFirstChild("Npc"); if not folder then return end
        local used = {}
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
                local pos; local ok, piv = pcall(m.GetPivot, m)
                if ok and typeof(piv)=="CFrame" then pos = piv.Position end
                if not pos then
                    local hrp = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                    pos = hrp and hrp.Position
                end
                if pos then
                    local dn = m:FindFirstChild("DisplayName")
                    local name = (dn and dn:IsA("StringValue") and dn.Value) or m.Name or "NPC"
                    local lbl = uniq(used, name)
                    tpMap[lbl] = pos; npcModelByLabel[lbl] = m
                end
            end
        end
    end
end

local current = "Players"; scan(current)
local names = {}; for n in pairs(tpMap) do names[#names+1]=n end
table.sort(names); local selected = names[1] or "-"

local ddCat = TeleportsGroupbox:AddDropdown("TP_Category", { Text="Category", Values={"Players","NPCS"}, Default=current })
local ddLoc = TeleportsGroupbox:AddDropdown("TP_Location", { Text="Select Location", Values=names, Default=selected })

ddCat:OnChanged(function(v)
    current = v; scan(current)
    names = {}; for n in pairs(tpMap) do names[#names+1]=n end
    table.sort(names); selected = names[1] or "-"
    ddLoc:SetValues(names); ddLoc:SetValue(selected)
end)

ddLoc:OnChanged(function(v) selected = v end)

TeleportsGroupbox:AddButton({
    Text = "Teleport",
    Func = function()
        local root = References.humanoidRootPart
        if not root then return Library:Notify("No character.", 3) end
        scan(current)
        local p = tpMap[selected]
        if p then root.CFrame = CFrame.new(p + Vector3.new(0,3,0))
        else Library:Notify("Invalid destination.", 3) end
    end
})

TeleportsGroupbox:AddButton({
    Text = "Refresh",
    Func = function()
        scan(current)
        names = {}; for n in pairs(tpMap) do names[#names+1]=n end
        table.sort(names); selected = names[1] or "-"
        ddLoc:SetValues(names); ddLoc:SetValue(selected)
        Library:Notify("Locations refreshed: "..current, 2)
    end
})

-- == INSTAKILL == --
--[[ instakill is gone for now. bye bye!!!
local InstakillGroupbox = Tabs.Main:AddRightGroupbox("Instakill","skull")

local S = {on=false, range=150, thr=30, step=0.12, acc=0, tick=nil, addConn=nil}
local pool = {}

local function isPlayerModel(m) return Services.Players:GetPlayerFromCharacter(m) ~= nil end

local function qualify(m)
    if not (m and m:IsA("Model")) then return end
    if m == References.character then return end
    if isPlayerModel(m) then return end
    local h = m:FindFirstChildOfClass("Humanoid"); if not h then pool[m]=nil return end
    local r = m:FindFirstChild("HumanoidRootPart"); if not r then pool[m]=nil return end
    pool[m] = {h=h, r=r}
end

for _,d in ipairs(Services.Workspace:GetDescendants()) do if d:IsA("Model") then qualify(d) end end

local function hookAdds()
    if S.addConn then S.addConn:Disconnect() end
    S.addConn = Services.Workspace.DescendantAdded:Connect(function(d)
        local m = d:IsA("Model") and d or d.Parent
        if m and m:IsA("Model") then qualify(m) end
    end)
end
local function unhookAdds() if S.addConn then S.addConn:Disconnect(); S.addConn=nil end end

local function kill(m,h,r)
    local lpRoot = References.humanoidRootPart
    if not (m and h and r and lpRoot) then return false end

    local dist = (lpRoot.Position - r.Position).Magnitude

    pcall(function()
        sethiddenproperty(References.player,"SimulationRadius",1e5)
        sethiddenproperty(References.player,"MaxSimulationRadius",1e5)
    end)
    for _,p in ipairs(m:GetDescendants()) do
        if p:IsA("BasePart") then pcall(function() p:SetNetworkOwner(References.player) end) end
    end

    local extra={}
    for _,d in ipairs(m:GetDescendants()) do
        if (d:IsA("NumberValue") or d:IsA("IntValue")) then
            local n=d.Name:lower(); if n:find("health") or n:find("hp") then extra[#extra+1]=d end
        end
    end

    local deadline = os.clock()+0.25
    local maxhp = (h.MaxHealth and h.MaxHealth>0) and h.MaxHealth or 100
    local lethal = maxhp*10+1000

    repeat
        pcall(function() h:TakeDamage(lethal) end)
        pcall(function() h.Health = 0 end)
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
        for i=1,#extra do pcall(function() extra[i].Value = 0 end) end
        pcall(function() m:SetAttribute("CurrentState","Unconscious") end)
        Services.RunService.Heartbeat:Wait()
    until os.clock()>deadline or not m.Parent

    local gone = (not m.Parent) or (not m:FindFirstChildOfClass("Humanoid"))
    print(("[Instakill] %s | dist=%.1f | result=%s"):format(
        m.Name, dist, gone and "DEAD" or ("ALIVE (HP "..math.floor(h.Health)..")")))

    return gone
end

local function sweep()
    local root = References.humanoidRootPart; if not root then return end
    for m,t in pairs(pool) do
        local h,r = t.h,t.r
        if (not m) or (not m.Parent) or (not h) or (not h.Parent) or (h.Parent~=m) then
            pool[m] = nil
        else
            local d = (root.Position - r.Position).Magnitude
            if d <= S.range then
                local max = (h.MaxHealth and h.MaxHealth>0) and h.MaxHealth or 100
                local pct = (h.Health/max)*100
                if pct <= S.thr or h.Health <= 0 then
                    if kill(m,h,r) then pool[m] = nil end
                end
            end
        end
    end
end

local function startIK()
    if S.tick then return end
    hookAdds(); S.acc=0
    S.tick = Services.RunService.Heartbeat:Connect(function(dt)
        S.acc += dt
        if S.acc >= S.step then S.acc=0; pcall(sweep) end
    end)
end
local function stopIK()
    if S.tick then S.tick:Disconnect(); S.tick=nil end
    unhookAdds()
end

InstakillGroupbox:AddToggle("IK_Toggle",{Text="Instakill",Default=false,
    Callback=function(v) S.on=v; if v then startIK() else stopIK() end end})
InstakillGroupbox:AddSlider("IK_Range",{Text="Range",Default=S.range,Min=10,Max=1000,Rounding=0,Suffix=" studs",
    Callback=function(v) S.range=v end})
InstakillGroupbox:AddSlider("IK_Threshold",{Text="Health Threshold",Default=S.thr,Min=0,Max=100,Rounding=0,Suffix="%",
    Tooltip="Kill when target HP% is at/below this value",Callback=function(v) S.thr=v end})

--]]

-- ==================== --
-- ==== PLAYER TAB ==== --
-- ==================== --

local UIS = Services.UserInputService
local KC = Enum.KeyCode
local L = Services.Lighting

-- == FLIGHT == --
local FlightGroup = Tabs.Player:AddLeftGroupbox("Flight", "move-3d")

FlightGroup:AddToggle("FlightEnabled", {
    Text = "Flight",
    Default = false,
}):AddKeyPicker("FlightKey", {
    Default = "F",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Flight Key",
})
FlightGroup:AddSlider("FlightSpeed", {
    Text = "Flight Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
})

local flightConn

local function startFlight()
    if flightConn then return end
    flightConn = Services.RunService.RenderStepped:Connect(function()
        local root, cam = References.humanoidRootPart, References.camera
        if not root or not cam then return end

        local cframe = cam.CFrame
        local look, right, up = cframe.LookVector, cframe.RightVector, cframe.UpVector
        local dir = Vector3.zero

        if UIS:IsKeyDown(KC.W) then dir += look end
        if UIS:IsKeyDown(KC.S) then dir -= look end
        if UIS:IsKeyDown(KC.A) then dir -= right end
        if UIS:IsKeyDown(KC.D) then dir += right end
        if UIS:IsKeyDown(KC.Space) then dir += up end
        if UIS:IsKeyDown(KC.LeftShift) or UIS:IsKeyDown(KC.LeftControl) then dir -= up end

        if References.humanoid and UIS.TouchEnabled then
            local md = References.humanoid.MoveDirection
            if md.Magnitude > 0 then
                dir += (look * md.Z * -1) + (right * md.X)
            end
        end

        if dir.Magnitude > 0 then
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = dir.Unit * Options.FlightSpeed.Value
        else
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.new(0, 2.2, 0)
        end
    end)
end

local function stopFlight()
    if flightConn then
        flightConn:Disconnect()
        flightConn = nil
        local root = References.humanoidRootPart
        if root then
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
end

Toggles.FlightEnabled:OnChanged(function()
    if Toggles.FlightEnabled.Value then startFlight() else stopFlight() end
end)

-- == SPEED == --
local SpeedGroup = Tabs.Player:AddLeftGroupbox("Speed", "move")

SpeedGroup:AddToggle("SpeedEnabled", {
    Text = "Speed",
    Default = false,
}):AddKeyPicker("SpeedKey", {
    Default = "G",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Speed Key",
})
SpeedGroup:AddSlider("SpeedValue", {
    Text = "Speed Value",
    Default = 30,
    Min = 16,
    Max = 300,
    Rounding = 0,
})

local speedConn
local function startSpeed()
    if speedConn then return end
    speedConn = Services.RunService.Heartbeat:Connect(function()
        local hum = References.humanoid
        if hum then
            hum.WalkSpeed = Options.SpeedValue.Value
        end
    end)
end

local function stopSpeed()
    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end
    local hum = References.humanoid
    if hum then
        hum.WalkSpeed = 16
    end
end

Toggles.SpeedEnabled:OnChanged(function()
    if Toggles.SpeedEnabled.Value then startSpeed() else stopSpeed() end
end)

-- == JUMP POWER == --
local JumpGroup = Tabs.Player:AddLeftGroupbox("Jump", "move-vertical")

JumpGroup:AddToggle("JumpPower", {
    Text = "Jump Power",
    Default = false,
})
JumpGroup:AddSlider("JumpHeight", {
    Text = "Jump Height",
    Default = 50,
    Min = 16,
    Max = 200,
    Rounding = 0,
})
JumpGroup:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,
})

local function applyJumpHeight()
    local h = References.humanoid
    if not h then return end
    local v = Options.JumpHeight.Value
    if h.UseJumpPower ~= nil then
        h.UseJumpPower = true
        h.JumpPower = v
    end
    if h.JumpHeight ~= nil then
        h.JumpHeight = v * 0.4
    end
end

local jumpConn
local function startJumpMod()
    if jumpConn then return end
    applyJumpHeight()
    jumpConn = Services.RunService.Heartbeat:Connect(applyJumpHeight)
end

local function stopJumpMod()
    if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    local h = References.humanoid
    if h then
        if h.UseJumpPower ~= nil then h.UseJumpPower = true; h.JumpPower = 50 end
        if h.JumpHeight ~= nil then h.JumpHeight = 7.2 end
    end
end

local ijConn
local function startInfiniteJump()
    if ijConn then return end
    ijConn = UIS.JumpRequest:Connect(function()
        local h = References.humanoid
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
            h.Jump = true
        end
    end)
end

local function stopInfiniteJump()
    if ijConn then ijConn:Disconnect(); ijConn = nil end
end

Toggles.JumpPower:OnChanged(function()
    if Toggles.JumpPower.Value then startJumpMod() else stopJumpMod() end
end)
Options.JumpHeight:OnChanged(function()
    if Toggles.JumpPower.Value then applyJumpHeight() end
end)
Toggles.InfiniteJump:OnChanged(function()
    if Toggles.InfiniteJump.Value then startInfiniteJump() else stopInfiniteJump() end
end)

-- == PLAYER UTILS == --
local UtilsGroup = Tabs.Player:AddRightGroupbox("Utils", "lightbulb")

-- == NO CLIP == --
UtilsGroup:AddToggle("NoclipEnabled", {
    Text = "Noclip",
    Default = false,
    Tooltip = "Walk through walls",
}):AddKeyPicker("NoclipKey", {
    Default = "N",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Noclip Key",
})

local noclipConn
local function startNoclip()
    if noclipConn then return end
    noclipConn = Services.RunService.Stepped:Connect(function()
        local char = References.character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

Toggles.NoclipEnabled:OnChanged(function()
    if Toggles.NoclipEnabled.Value then startNoclip() else stopNoclip() end
end)

-- == PERFORMANCE MODE == --
UtilsGroup:AddToggle("PerformanceMode", {
    Text = "Performance Mode",
    Default = false,
    Tooltip = "Reduce visual effects locally for better FPS",
})

local originals = nil

local function snapshot()
    if originals then return end
    originals = {
        QualityLevel  = settings().Rendering.QualityLevel,
        GlobalShadows = L.GlobalShadows,
        Ambient       = L.Ambient,
        Brightness    = L.Brightness,
        FogEnd        = L.FogEnd,
        FogStart      = L.FogStart,
        Effects = {},        
        Terrain = {},  
    }
    for _, inst in ipairs(L:GetDescendants()) do
        if inst:IsA("BloomEffect") or inst:IsA("ColorCorrectionEffect")
        or inst:IsA("SunRaysEffect") or inst:IsA("DepthOfFieldEffect")
        or inst:IsA("BlurEffect") then
            originals.Effects[inst] = inst.Enabled
        end
    end
    local terr = Services.Workspace:FindFirstChildOfClass("Terrain")
    if terr then
        originals.Terrain.WaterWaveSize     = terr.WaterWaveSize
        originals.Terrain.WaterReflectance  = terr.WaterReflectance
        originals.Terrain.WaterTransparency = terr.WaterTransparency
        local ok, dec = pcall(function() return terr.Decoration end)
        if ok and type(dec)=="boolean" then
            originals.Terrain.Decoration = dec
        end
    end
end

local function perfOn()
    snapshot()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    L.GlobalShadows = false
    L.Ambient       = Color3.new(0.3, 0.3, 0.3)
    L.Brightness    = 1
    L.FogEnd        = 1e10
    L.FogStart      = 1e10
    for inst in pairs(originals.Effects) do
        if inst and inst.Parent then inst.Enabled = false end
    end
    local terr = Services.Workspace:FindFirstChildOfClass("Terrain")
    if terr then
        terr.WaterWaveSize     = 0
        terr.WaterReflectance  = 0
        terr.WaterTransparency = 1
        if originals.Terrain.Decoration ~= nil then
            pcall(function() terr.Decoration = false end)
        end
    end
    for _, d in ipairs(Services.Workspace:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Smoke") or d:IsA("Fire") then
            if d.Enabled then d:SetAttribute("PerfWasEnabled", true); d.Enabled = false end
        end
    end
end

local function perfOff()
    if not originals then return end
    settings().Rendering.QualityLevel = originals.QualityLevel
    L.GlobalShadows = originals.GlobalShadows
    L.Ambient       = originals.Ambient
    L.Brightness    = originals.Brightness
    L.FogEnd        = originals.FogEnd
    L.FogStart      = originals.FogStart

    for inst, was in pairs(originals.Effects) do
        if inst and inst.Parent then inst.Enabled = was end
    end
    local terr = Services.Workspace:FindFirstChildOfClass("Terrain")
    if terr then
        terr.WaterWaveSize     = originals.Terrain.WaterWaveSize or terr.WaterWaveSize
        terr.WaterReflectance  = originals.Terrain.WaterReflectance or terr.WaterReflectance
        terr.WaterTransparency = originals.Terrain.WaterTransparency or terr.WaterTransparency
        if originals.Terrain.Decoration ~= nil then
            pcall(function() terr.Decoration = originals.Terrain.Decoration end)
        end
    end
    for _, d in ipairs(Services.Workspace:GetDescendants()) do
        if d:GetAttribute("PerfWasEnabled") then
            d:SetAttribute("PerfWasEnabled", nil)
            if d.Enabled ~= nil then d.Enabled = true end
        end
    end
    originals = nil
end

Toggles.PerformanceMode:OnChanged(function()
    if Toggles.PerformanceMode.Value then perfOn() else perfOff() end
end)

-- == CHAT LOGGER == --
local function setChatUI(on)
    if join then join.Visible = not on end
    if chat then chat.Visible = on end

    if shade2 and shade3 and selectChat and selectJoin then
        local i = table.find(shade3, selectChat); if i then table.remove(shade3, i) end
        i = table.find(shade2, selectJoin);       if i then table.remove(shade2, i) end
        if not table.find(shade2, selectChat) then table.insert(shade2, selectChat) end
        if not table.find(shade3, selectJoin) then table.insert(shade3, selectJoin) end
    end

    if selectJoin and currentShade3 then selectJoin.BackgroundColor3 = currentShade3 end
    if selectChat and currentShade2 then selectChat.BackgroundColor3 = currentShade2 end

    if logs and logs.TweenPosition then
        if on then
            logs:TweenPosition(UDim2.new(0,0,1,-265), "InOut", "Quart", 0.3, true)
        else
            logs:TweenPosition(UDim2.new(0,0,1,0), "InOut", "Quart", 0.3, true)
        end
    end
end

UtilsGroup:AddToggle("ChatLogger", {
    Text = "Chat Logger",
    Default = false,
    Callback = function(v) setChatUI(v) end
})

-- == REMOVE KILLBRICKS == --
local killParts = {}
local function setKillBricks(enabled)
    if not enabled then
        for _, part in ipairs(killParts) do
            if part and part.Parent then
                part.CanTouch = true
                part.CanCollide = true
                part.Transparency = 0
            end
        end
        table.clear(killParts)
        return
    end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            if name:find("kill") or name:find("lava") or name:find("damage") then
                v.CanTouch = false
                v.CanCollide = false
                v.Transparency = 0.5
                table.insert(killParts, v)
            end
        end
    end
end

UtilsGroup:AddToggle("RemoveKillBricks", {
    Text = "Remove KillBricks",
    Default = false,
    Tooltip = "Disable bricks that cause death/damage",
    Callback = function(v) setKillBricks(v) end
})

-- == MOD REACTS == --
local modSettings = { notify = false, leave = false }

local function isStaff(plr)
    local ok, lvl = pcall(function() return plr:GetAttribute("AdminLevel") end)
    if ok and type(lvl) == "number" and lvl > 0 then return true end
    local a = plr:GetAttribute("IsAdmin") or plr:GetAttribute("Moderator") or plr:GetAttribute("Staff")
    if a == true then return true end
    return false
end

local function reactToStaff(plr)
    if not (modSettings.notify or modSettings.leave) then return end
    if not plr or plr == References.player then return end
    if not isStaff(plr) then return end

    if modSettings.notify then
        Library:Notify("Moderator joined: " .. plr.Name, 6)
    end
    if modSettings.leave then
        task.defer(function()
            local lp = References.player
            if lp and lp.Parent then
                Services.TeleportService:Teleport(game.PlaceId, lp)
            end
        end)
    end
end

local modConn = Services.Players.PlayerAdded:Connect(reactToStaff)
local function sweepExisting()
    if not (modSettings.notify or modSettings.leave) then return end
    for _, plr in ipairs(Services.Players:GetPlayers()) do
        reactToStaff(plr)
    end
end

UtilsGroup:AddToggle("ModNotifierToggle", {
    Text = "Mod Notifier",
    Default = false,
    Tooltip = "Notify when a moderator/staff joins",
    Callback = function(v)
        modSettings.notify = v
        if v then sweepExisting() end
    end
})

UtilsGroup:AddToggle("LeaveOnModToggle", {
    Text = "Leave If Mod Joins",
    Default = false,
    Tooltip = "Auto-leave the server if a moderator/staff joins",
    Callback = function(v)
        modSettings.leave = v
        if v then sweepExisting() end
    end
})

-- == QUICK RESET == --
UtilsGroup:AddButton({
    Text = "Quick Reset",
    Func = function()
    References.humanoid.Health = 0
    end,
})

-- == VISUAL PLAYER UTILS == --
local VisualsGroup = Tabs.Player:AddRightGroupbox("Visuals", "glasses")

-- == UNLIMITED CAM DISTANCE == --
VisualsGroup:AddToggle("InfiniteCamera", {
    Text = "Infinite Camera Max",
    Default = false,
})

local origCamMax

Toggles.InfiniteCamera:OnChanged(function()
    local plr = References.player
    if not plr then return end

    if Toggles.InfiniteCamera.Value then
        origCamMax = origCamMax or plr.CameraMaxZoomDistance
        plr.CameraMaxZoomDistance = 1e10
    else
        plr.CameraMaxZoomDistance = origCamMax or 128
        origCamMax = nil
    end
end)

-- == FULLBRIGHT == --
VisualsGroup:AddToggle("Fullbright", {
    Text = "Fullbright",
    Default = false,
    Tooltip = "Forces bright ambient lighting",
})

local fbConn, fbSaved
local function fbOn()
    if fbConn then return end
    fbSaved = fbSaved or {B=L.Brightness, GS=L.GlobalShadows, A=L.Ambient}
    fbConn = Services.RunService.RenderStepped:Connect(function()
        L.Brightness = 2
        L.GlobalShadows = false
        L.Ambient = Color3.new(1,1,1)
    end)
end
local function fbOff()
    if fbConn then fbConn:Disconnect(); fbConn=nil end
    if fbSaved then
        L.Brightness = fbSaved.B
        L.GlobalShadows = fbSaved.GS
        L.Ambient = fbSaved.A
        fbSaved = nil
    end
end
Toggles.Fullbright:OnChanged(function()
    if Toggles.Fullbright.Value then fbOn() else fbOff() end
end)

-- == NO FOG == --
VisualsGroup:AddToggle("NoFog", {
    Text = "No Fog",
    Default = false,
    Tooltip = "Disables fog/atmospheric effects",
})

local nfConn, nfSaved
local function nfDisable(inst)
    if not nfSaved then return end
    if inst:IsA("BloomEffect") or inst:IsA("SunRaysEffect") or inst:IsA("DepthOfFieldEffect") or inst:IsA("ColorCorrectionEffect") or inst:IsA("BlurEffect") then
        if inst.Enabled then inst:SetAttribute("NFWasEnabled", true); inst.Enabled = false end
    elseif inst:IsA("Atmosphere") then
        if nfSaved.Atmo[inst] == nil then
            nfSaved.Atmo[inst] = {D=inst.Density, H=inst.Haze, O=inst.Offset, G=inst.Glare}
        end
        inst.Density = 0; inst.Haze = 0; inst.Glare = 0
    end
end

local function nfOn()
    if nfSaved then return end
    nfSaved = {
        FogEnd   = L.FogEnd,
        FogStart = L.FogStart,
        FogColor = L.FogColor,
        Atmo     = {},
    }
    L.FogEnd, L.FogStart = 1e10, 1e10
    for _,d in ipairs(L:GetDescendants()) do nfDisable(d) end
    nfConn = L.DescendantAdded:Connect(nfDisable)
end

local function nfOff()
    if not nfSaved then return end
    if nfConn then nfConn:Disconnect(); nfConn=nil end
    L.FogEnd, L.FogStart, L.FogColor = nfSaved.FogEnd, nfSaved.FogStart, nfSaved.FogColor
    for _,d in ipairs(L:GetDescendants()) do
        if d:GetAttribute("NFWasEnabled") then
            d:SetAttribute("NFWasEnabled", nil)
            if d.Enabled ~= nil then d.Enabled = true end
        end
    end
    for atmo,vals in pairs(nfSaved.Atmo) do
        if atmo and atmo.Parent then
            atmo.Density, atmo.Haze, atmo.Offset, atmo.Glare = vals.D, vals.H, vals.O, vals.G
        end
    end
    nfSaved = nil
end

Toggles.NoFog:OnChanged(function()
    if Toggles.NoFog.Value then nfOn() else nfOff() end
end)

-- == XRAY ==
VisualsGroup:AddToggle("XRay", {
    Text = "X-Ray",
    Default = false,
    Tooltip = "See through walls.",
})

local function setXRay(enabled)
    for _, v in ipairs(Services.Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if not v.Parent:FindFirstChildOfClass("Humanoid") 
            and not (v.Parent.Parent and v.Parent.Parent:FindFirstChildOfClass("Humanoid")) then
                v.LocalTransparencyModifier = enabled and 0.5 or 0
            end
        end
    end
end

Toggles.XRay:OnChanged(function()
    setXRay(Toggles.XRay.Value)
end)

-- == FOV SLIDER == --
VisualsGroup:AddSlider("CameraFOV", {
    Text = "Camera FOV",
    Default = 70,
    Min = 40,
    Max = 120,
    Rounding = 0,
})

Options.CameraFOV:OnChanged(function()
    local cam = References.camera or Services.Workspace.CurrentCamera
    if cam then cam.FieldOfView = Options.CameraFOV.Value end
end)
do
    local cam = References.camera or Services.Workspace.CurrentCamera
    if cam then cam.FieldOfView = Options.CameraFOV.Value end
end

-- ==================== --
-- ==== COMBAT TAB ==== --
-- ==================== -- COMBAT TAB IS GONE FOR NOW :( MAYBE IT'LL COME BACK SOME DAY!!!

-- local AimbotInit = loadstring(game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/aimbotModule.lua"))()

-- boot it with our context; keep a stop fn for unload
--local stopAimbot = AimbotInit({
--    Services   = Services,
--    References = References,
--    Tabs       = Tabs,
--   Library    = Library,
--})

-- ================= --
-- ==== ESP TAB ==== --
-- ================= --

local SENSE
local SENSE_URL = "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/sense/main.lua"

local function getSENSE()
    if type(SENSE) == "table" then return SENSE end
    local ok, mod = pcall(function() return loadstring(game:HttpGet(SENSE_URL))() end)
    if ok and type(mod) == "table" then SENSE = mod end
    return SENSE
end
local function ensureLoaded()
    local m = getSENSE()
    if not m then return false end
    if not m._hasLoaded and m.Load then pcall(m.Load) end
    return true
end

local function playerOn() return Toggles.PESP_Enable and Toggles.PESP_Enable.Value end
local function npcOn()    return Toggles.NPCESP_Enable and Toggles.NPCESP_Enable.Value end
local function anyOn()    return playerOn() or npcOn() end

local function maybeUnload()
    if anyOn() then return end
    local m = SENSE
    if m and m._hasLoaded and m.Unload then pcall(m.Unload) end
end

-- ===== Universal =====
local Uni = Tabs.ESP:AddLeftGroupbox("Universal", "settings")
Uni:AddSlider  ("ESP_TextSize",     { Text = "Text Size", Default = 13, Min = 10, Max = 28, Rounding = 0 })
Uni:AddDropdown("ESP_TracerOrigin", { Text = "Tracer Origin", Values = { "Bottom", "Middle", "Top" }, Default = "Bottom" })
Uni:AddToggle  ("ESP_LimitRange",   { Text = "Limit Range", Default = false })
Uni:AddSlider  ("ESP_MaxRange",     { Text = "Range (studs)", Default = 150, Min = 50, Max = 2000, Rounding = 0 })

local function pushShared()
    if not anyOn() then return end    
    if not ensureLoaded() then return end
    local m = SENSE
    m.sharedSettings.textSize      = Options.ESP_TextSize.Value
    m.sharedSettings.limitDistance = Toggles.ESP_LimitRange.Value
    m.sharedSettings.maxDistance   = Options.ESP_MaxRange.Value
    local o = Options.ESP_TracerOrigin.Value
    m.teamSettings.enemy.tracerOrigin    = o
    m.teamSettings.friendly.tracerOrigin = o
    m.instanceSettings.tracerOrigin      = o
end

Options.ESP_TextSize:OnChanged(pushShared)
Options.ESP_TracerOrigin:OnChanged(pushShared)
Toggles.ESP_LimitRange:OnChanged(pushShared)
Options.ESP_MaxRange:OnChanged(pushShared)

-- ===== Player ESP =====
local PlayerEspGroupbox = Tabs.ESP:AddRightGroupbox("Player ESP", "users")
PlayerEspGroupbox:AddToggle  ("PESP_Enable", { Text = "Enable Player ESP", Default = false })
PlayerEspGroupbox:AddDropdown("PESP_Side",   { Text = "Apply To", Values = { "Enemy", "Friendly", "Both" }, Default = "Enemy" })

PlayerEspGroupbox:AddToggle("PESP_Box", { Text = "Boxes", Default = true })
    :AddColorPicker("PESP_BoxColor", { Default = Color3.fromRGB(255,60,60), Title = "Box Color" })
PlayerEspGroupbox:AddToggle("PESP_BoxOutline", { Text = "Box Outline", Default = true })
PlayerEspGroupbox:AddToggle("PESP_BoxFill", { Text = "Box Fill", Default = false })
PlayerEspGroupbox:AddSlider("PESP_BoxFillAlpha", { Text = "Fill Alpha", Default = 35, Min = 0, Max = 100, Rounding = 0 })

PlayerEspGroupbox:AddToggle("PESP_Name", { Text = "Names", Default = true })
    :AddColorPicker("PESP_NameColor", { Default = Color3.new(1,1,1), Title = "Name Color" })
PlayerEspGroupbox:AddToggle("PESP_Distance", { Text = "Distance", Default = true })
    :AddColorPicker("PESP_DistColor", { Default = Color3.new(1,1,1), Title = "Distance Color" })

PlayerEspGroupbox:AddToggle("PESP_HealthBar", { Text = "Health Bar", Default = true })
PlayerEspGroupbox:AddToggle("PESP_Weapon",    { Text = "Weapon",     Default = false })
PlayerEspGroupbox:AddToggle("PESP_Tracer",    { Text = "Tracer",     Default = true })
    :AddColorPicker("PESP_TracerColor", { Default = Color3.fromRGB(255,60,60), Title = "Tracer Color" })
PlayerEspGroupbox:AddToggle("PESP_Chams",     { Text = "Chams",      Default = false })

local function sideKeys()
    local v = Options.PESP_Side.Value
    if v == "Both" then return { "enemy", "friendly" } end
    return { v:lower() }
end
local function setTeams(k, val)
    local m = SENSE
    for _, s in ipairs(sideKeys()) do m.teamSettings[s][k] = val end
end
local function colorTuple(opt, a) return { Options[opt].Value, a or 1 } end

local function applyPlayerLive()
    if not playerOn() then return end      
    if not ensureLoaded() then return end
    local m = SENSE

    setTeams("enabled", true)

    setTeams("box",            Toggles.PESP_Box.Value)
    setTeams("boxOutline",     Toggles.PESP_BoxOutline.Value)
    setTeams("boxFill",        Toggles.PESP_BoxFill.Value)
    setTeams("boxColor",       colorTuple("PESP_BoxColor", 1))
    setTeams("boxOutlineColor",{ Color3.new(), 1 })
    setTeams("boxFillColor",   { Options.PESP_BoxColor.Value, (Options.PESP_BoxFillAlpha.Value or 0)/100 })

    setTeams("name",           Toggles.PESP_Name.Value)
    setTeams("nameColor",      colorTuple("PESP_NameColor"))

    setTeams("distance",       Toggles.PESP_Distance.Value)
    setTeams("distanceColor",  colorTuple("PESP_DistColor"))

    setTeams("healthBar",      Toggles.PESP_HealthBar.Value)
    setTeams("weapon",         Toggles.PESP_Weapon.Value)

    setTeams("tracer",         Toggles.PESP_Tracer.Value)
    setTeams("tracerColor",    colorTuple("PESP_TracerColor"))
    setTeams("tracerOutline",  true)

    setTeams("chams",          Toggles.PESP_Chams.Value)

    pushShared()
end

Toggles.PESP_Enable:OnChanged(function()
    if Toggles.PESP_Enable.Value then
        if ensureLoaded() then
            local m = SENSE
            local side = Options.PESP_Side.Value
            m.teamSettings.enemy.enabled    = (side == "Enemy"   or side == "Both")
            m.teamSettings.friendly.enabled = (side == "Friendly" or side == "Both")
            applyPlayerLive()
        end
    else
        if SENSE then
            SENSE.teamSettings.enemy.enabled    = false
            SENSE.teamSettings.friendly.enabled = false
        end
        maybeUnload()
    end
end)

for _, idx in ipairs({
    "PESP_Side","PESP_Box","PESP_BoxOutline","PESP_BoxFill","PESP_Name","PESP_Distance",
    "PESP_HealthBar","PESP_Weapon","PESP_Tracer","PESP_Chams"
}) do
    (Toggles[idx] or Options[idx]):OnChanged(function()
        applyPlayerLive()
    end)
end
Options.PESP_BoxColor:OnChanged(applyPlayerLive)
Options.PESP_BoxFillAlpha:OnChanged(applyPlayerLive)
Options.PESP_NameColor:OnChanged(applyPlayerLive)
Options.PESP_DistColor:OnChanged(applyPlayerLive)
Options.PESP_TracerColor:OnChanged(applyPlayerLive)

-- ===== NPC ESP =====
local NpcESPGroupbox = Tabs.ESP:AddLeftGroupbox("NPC ESP", "user-cog")
NpcESPGroupbox:AddToggle("NPCESP_Enable", { Text = "Enable NPC ESP", Default = false })

NpcESPGroupbox:AddToggle("NPCESP_Box", { Text = "Boxes", Default = true })
    :AddColorPicker("NPCESP_BoxColor", { Default = Color3.fromRGB(255,255,0), Title = "Box Color" })
NpcESPGroupbox:AddToggle("NPCESP_BoxOutline", { Text = "Box Outline", Default = true })
NpcESPGroupbox:AddToggle("NPCESP_BoxFill", { Text = "Box Fill", Default = false })
NpcESPGroupbox:AddSlider("NPCESP_BoxFillAlpha", { Text = "Fill Alpha", Default = 25, Min = 0, Max = 100, Rounding = 0 })

NpcESPGroupbox:AddToggle("NPCESP_Name", { Text = "Names", Default = true })
    :AddColorPicker("NPCESP_NameColor", { Default = Color3.new(1,1,1), Title = "Name Color" })
NpcESPGroupbox:AddToggle("NPCESP_Distance", { Text = "Distance", Default = true })
    :AddColorPicker("NPCESP_DistColor", { Default = Color3.new(1,1,1), Title = "Distance Color" })

NpcESPGroupbox:AddToggle("NPCESP_Tracer", { Text = "Tracer", Default = false })
    :AddColorPicker("NPCESP_TracerColor", { Default = Color3.fromRGB(255,255,0), Title = "Tracer Color" })

local function npcFolder() return workspace:FindFirstChild("Npc") end
local npcAddConn, npcRemConn

local function clearNPCs()
    if not SENSE then return end
    local f = npcFolder(); if not f then return end
    for _, inst in ipairs(f:GetChildren()) do SENSE.RemoveInstance(inst) end
end
local function scanNPCs()
    if not ensureLoaded() then return end
    local f = npcFolder(); if not f then return end
    local list = f:GetChildren()
    if #list > 0 then SENSE.AddInstances(list) end
end
local function watchNPCs(on)
    if on then
        local f = npcFolder(); if not f then return end
        if not npcAddConn then npcAddConn = f.ChildAdded:Connect(function(i) if npcOn() and ensureLoaded() then SENSE.AddInstances({i}) end end) end
        if not npcRemConn then npcRemConn = f.ChildRemoved:Connect(function(i) if SENSE then SENSE.RemoveInstance(i) end end) end
        scanNPCs()
    else
        if npcAddConn then npcAddConn:Disconnect(); npcAddConn=nil end
        if npcRemConn then npcRemConn:Disconnect(); npcRemConn=nil end
        clearNPCs()
    end
end

local function applyNPCLive()
    if not npcOn() then return end              
    if not ensureLoaded() then return end
    local IS = SENSE.instanceSettings

    IS.enabled         = true
    IS.box             = Toggles.NPCESP_Box.Value
    IS.boxOutline      = Toggles.NPCESP_BoxOutline.Value
    IS.boxFill         = Toggles.NPCESP_BoxFill.Value
    IS.boxColor        = { Options.NPCESP_BoxColor.Value, 1 }
    IS.boxOutlineColor = { Color3.new(), 1 }
    IS.boxFillColor    = { Options.NPCESP_BoxColor.Value, (Options.NPCESP_BoxFillAlpha.Value or 0)/100 }

    IS.name            = Toggles.NPCESP_Name.Value
    IS.nameColor       = { Options.NPCESP_NameColor.Value, 1 }

    IS.distance        = Toggles.NPCESP_Distance.Value
    IS.distanceColor   = { Options.NPCESP_DistColor.Value, 1 }

    IS.tracer          = Toggles.NPCESP_Tracer.Value
    IS.tracerColor     = { Options.NPCESP_TracerColor.Value, 1 }

    pushShared()
end

Toggles.NPCESP_Enable:OnChanged(function()
    if Toggles.NPCESP_Enable.Value then
        if ensureLoaded() then
            SENSE.instanceSettings.enabled = true
            applyNPCLive()
            watchNPCs(true)
        end
    else
        watchNPCs(false)
        if SENSE then SENSE.instanceSettings.enabled = false end
        maybeUnload()
    end
end)

for _, idx in ipairs({
    "NPCESP_Box","NPCESP_BoxOutline","NPCESP_BoxFill","NPCESP_Name","NPCESP_Distance","NPCESP_Tracer"
}) do
    (Toggles[idx] or Options[idx]):OnChanged(applyNPCLive)
end
Options.NPCESP_BoxColor:OnChanged(applyNPCLive)
Options.NPCESP_BoxFillAlpha:OnChanged(applyNPCLive)
Options.NPCESP_NameColor:OnChanged(applyNPCLive)
Options.NPCESP_DistColor:OnChanged(applyNPCLive)
Options.NPCESP_TracerColor:OnChanged(applyNPCLive)

pushShared()

-- ================== --
-- ==== AUTO TAB ==== --
-- ================== --

local Farm = Tabs.Auto:AddLeftGroupbox("Autofarm", "settings")
Farm:AddToggle  ("HerbAutofarm",   { Text = "Collect All Herbs", Default = false })
Farm:AddToggle("OreAutofarm",  { Text = "Collect All Ores",  Default = false })



local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local collectHerbEvent = events:WaitForChild("CollectHerb")
local mineOreEvent     = events:WaitForChild("MineOre")

local herbsFolder = workspace:WaitForChild("Herbs")
local oresFolder  = workspace:WaitForChild("Ore")


task.spawn(function()
    while true do
        task.wait(1) 

        -- Herb autofarm
        if Toggles.HerbAutofarm and Toggles.HerbAutofarm.Value then
            for _, herbModel in ipairs(herbsFolder:GetChildren()) do
                local plant = herbModel:FindFirstChildWhichIsA("BasePart")
                if plant then
                    collectHerbEvent:FireServer(plant)
                end
            end
        end

        -- Ore autofarm
        if Toggles.OreAutofarm and Toggles.OreAutofarm.Value then
            for _, oreModel in ipairs(oresFolder:GetChildren()) do
                local rock = oreModel:FindFirstChildWhichIsA("BasePart")
                if rock then
                    mineOreEvent:FireServer(rock)
                end
            end
        end
    end
end)



-- ================== --
-- ==== MISC TAB ==== --
-- ================== --

-- == SERVER PANEL == --
local ServerGroupbox = Tabs.Misc:AddLeftGroupbox("Server Panel", "server")

local PID, JID, LP = game.PlaceId, game.JobId, References.player

ServerGroupbox:AddButton({
    Text = "Rejoin Server",
    Func = function()
        if PID and JID and LP then
            Services.TeleportService:TeleportToPlaceInstance(PID, JID, LP)
        else
            Library:Notify("Rejoin failed: missing ids", 4)
        end
    end
})

local function fetch(cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s")
        :format(PID, cursor and ("&cursor=" .. Services.HttpService:UrlEncode(cursor)) or "")
    local ok, res = pcall(function() return Services.HttpService:JSONDecode(game:HttpGet(url)) end)
    return ok and res or nil
end

ServerGroupbox:AddButton({
    Text = "Join Random Server",
    Func = function()
        local cursor = nil
        for _ = 1, 5 do 
            local res = fetch(cursor)
            if not res or not res.data then break end
            local candidates = {}
            for _, sv in ipairs(res.data) do
                if sv.id ~= JID and sv.playing < sv.maxPlayers then
                    table.insert(candidates, sv)
                end
            end
            if #candidates > 0 then
                local pick = candidates[math.random(1, #candidates)]
                return Services.TeleportService:TeleportToPlaceInstance(PID, pick.id, LP)
            end
            cursor = res.nextPageCursor
            if not cursor then break end
        end
        Library:Notify("Couldn't find an available server.", 5)
    end
})

ServerGroupbox:AddButton({
    Text = "Join Lowest Server",
    Func = function()
        local cursor, best, count = nil, nil, math.huge
        for _ = 1, 6 do
            local res = fetch(cursor); if not res or not res.data then break end
            for _, sv in ipairs(res.data) do
                if sv.id ~= JID and sv.playing < sv.maxPlayers and sv.playing < count then
                    best, count = sv, sv.playing
                end
            end
            cursor = res.nextPageCursor; if not cursor then break end
        end
        if best then
            Services.TeleportService:TeleportToPlaceInstance(PID, best.id, LP)
        else
            Library:Notify("No suitable server with fewer players.", 5)
        end
    end
})

ServerGroupbox:AddButton({
    Text = "Copy Join Script",
    Func = function()
        local s = ("local TS=game:GetService('TeleportService')\nTS:TeleportToPlaceInstance(%d,%q,game.Players.LocalPlayer)\n"):format(PID, JID)
        if setclipboard then
            pcall(setclipboard, s)
            Library:Notify("Copied current-server join snippet.", 4)
        else
            Library:Notify("Clipboard not available.", 4)
        end
    end
})

-- == ENVIROMENT == --
local EnviromentGroup = Tabs.Misc:AddRightGroupbox("Environment", "trees")

local ambientOn, ambientColor = false, Color3.fromRGB(128,128,128)
local ambientOrig = Services.Lighting and Services.Lighting.Ambient or Color3.new()
local timeLocked, timeValue, timeConn = false, (Services.Lighting and Services.Lighting.ClockTime or 12), nil

local function applyAmbient()
    if Services.Lighting then Services.Lighting.Ambient = ambientOn and ambientColor or ambientOrig end
end

EnviromentGroup:AddToggle("ENV_Ambient", {
    Text = "Custom Ambient", Default = false,
    Callback = function(v) ambientOn = v; applyAmbient() end
})
EnviromentGroup:AddLabel("Ambient Color"):AddColorPicker("ENV_AmbientColor", {
    Default = ambientColor, Title = "Ambient Color",
    Callback = function(c) ambientColor = c; if ambientOn then applyAmbient() end end
})

EnviromentGroup:AddToggle("ENV_TimeLock", {
    Text = "Custom Time of Day", Default = false,
    Callback = function(on)
        timeLocked = on
        if on then
            if Services.Lighting then Services.Lighting.ClockTime = timeValue end
            if not timeConn then
                timeConn = Services.RunService.RenderStepped:Connect(function()
                    if Services.Lighting then Services.Lighting.ClockTime = timeValue end
                end)
            end
            Library:Notify("Time of Day locked.", 3)
        else
            if timeConn then timeConn:Disconnect(); timeConn = nil end
            Library:Notify("Time of Day unlocked.", 3)
        end
    end
})

EnviromentGroup:AddSlider("ENV_Time", {
    Text = "Time of Day", Default = timeValue, Min = 0, Max = 24, Rounding = 2, Suffix = "h",
    Callback = function(v) timeValue = v; if timeLocked and L then L.ClockTime = v end end
})

function stopEnvironment()
    if timeConn then timeConn:Disconnect(); timeConn = nil end
    if Services.Lighting then Services.Lighting.Ambient = ambientOrig end
end

-- == SPECTATE ==
local SpectateGroupbox = Tabs.Misc:AddLeftGroupbox("Spectate", "view")

local spectateConn, spectating
local dd = SpectateGroupbox:AddDropdown("SpectateTarget", { Values = {}, Default = nil, Multi = false, Text = "Select Player" })
SpectateGroupbox:AddButton({ Text = "Refresh Players", Func = function()
    local t = {}
    for _, pl in ipairs(Services.Players:GetPlayers()) do if pl ~= References.player then t[#t+1] = pl.Name end end
    dd:SetValues(t)
end })

local tg = SpectateGroupbox:AddToggle("SpectateEnabled", { Text = "Spectate Player", Default = false })

local function stopSpectate()
    if spectateConn then spectateConn:Disconnect(); spectateConn = nil end
    spectating = nil
    if References.humanoid then References.camera.CameraSubject = References.humanoid end
end

local function startSpectate(target)
    stopSpectate()
    spectating = target
    if not spectating then return end
    spectateConn = Services.RunService.RenderStepped:Connect(function()
        local char = spectating.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            References.camera.CameraSubject = hum
        else
            stopSpectate()
            tg:SetValue(false)
        end
    end)
end

tg:OnChanged(function()
    if tg.Value then
        local name = dd.Value
        local target = name and Services.Players:FindFirstChild(name)
        if target then startSpectate(target) else
            Library:Notify("Select a player to spectate.", 3)
            tg:SetValue(false)
        end
    else
        stopSpectate()
    end
end)

dd:OnChanged(function(name)
    if tg.Value then
        local target = name and Services.Players:FindFirstChild(name)
        if target then startSpectate(target) end
    end
end)

Services.Players.PlayerAdded:Connect(function()
    local t = {}
    for _, pl in ipairs(Services.Players:GetPlayers()) do if pl ~= References.player then t[#t+1] = pl.Name end end
    dd:SetValues(t)
end)
Services.Players.PlayerRemoving:Connect(function(leaver)
    local t = {}
    for _, pl in ipairs(Services.Players:GetPlayers()) do if pl ~= References.player and pl ~= leaver then t[#t+1] = pl.Name end end
    dd:SetValues(t)
    if spectating == leaver then tg:SetValue(false) end
end)

do
    local t = {}
    for _, pl in ipairs(Services.Players:GetPlayers()) do if pl ~= References.player then t[#t+1] = pl.Name end end
    dd:SetValues(t)
end


-- ========================== --
-- ==== UI SETTINGS TABS ==== --
-- ========================== --

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")
MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Cerberus")
SaveManager:SetFolder("Cerberus/" .. References.gameName)
SaveManager:SetSubFolder(References.gameName)
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
ThemeManager:ApplyTheme("Ubuntu")

-- ======================== --
-- ==== INITIALISATION ==== --
-- ======================== --

-- ==== UNLOADER ==== --
local UnloadHandlers = {}

table.insert(UnloadHandlers, stopFlight)
table.insert(UnloadHandlers, stopSpeed)
table.insert(UnloadHandlers, stopJumpMod)
table.insert(UnloadHandlers, stopInfiniteJump)
table.insert(UnloadHandlers, stopNoclip)
table.insert(UnloadHandlers, stopEnvironment)
table.insert(UnloadHandlers, stopSpectate)
table.insert(UnloadHandlers, stopAimbot)
table.insert(UnloadHandlers, function()
    if SENSE then
        if SENSE._hasLoaded and SENSE.Unload then
            pcall(SENSE.Unload)
        end
        if SENSE.teamSettings then
            SENSE.teamSettings.enemy.enabled    = false
            SENSE.teamSettings.friendly.enabled = false
        end
        if SENSE.instanceSettings then
            SENSE.instanceSettings.enabled = false
        end
    end
end)

Library:OnUnload(function()
    for i = 1, #UnloadHandlers do
        local fn = UnloadHandlers[i]
        if typeof(fn) == "function" then
            pcall(fn)
        end
    end
end)


-- ==== INIT ==== --
local function setupReferences(char)
    References.character = char or References.player.Character
    References.humanoid = References.character and References.character:FindFirstChildOfClass("Humanoid") or nil
    References.humanoidRootPart = References.character and References.character:FindFirstChild("HumanoidRootPart") or nil
    References.camera = Services.Workspace.CurrentCamera
end

setupReferences(References.player.Character or References.player.CharacterAdded:Wait())

References.player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid", 5)
    char:WaitForChild("HumanoidRootPart", 5)
    setupReferences(char)

    if Toggles.FlightEnabled and Toggles.FlightEnabled.Value then
        task.spawn(function() task.wait(0.25) startFlight() end)
    end
    if Toggles.SpeedEnabled and Toggles.SpeedEnabled.Value then
        task.spawn(function() task.wait(0.25) startSpeed() end)
    end
    if Toggles.JumpPower and Toggles.JumpPower.Value then
        task.spawn(function() task.wait(0.25) if startJumpMod then startJumpMod() end end)
    end
    if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
        task.spawn(function() task.wait(0.25) if startInfiniteJump then startInfiniteJump() end end)
    end
end)

References.player.CharacterRemoving:Connect(function()
    stopFlight()
    if stopSpeed then stopSpeed() end
    if stopJumpMod then stopJumpMod() end
    if stopInfiniteJump then stopInfiniteJump() end
    setupReferences(nil)
end)

Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    References.camera = Services.Workspace.CurrentCamera
end)
