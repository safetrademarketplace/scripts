loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

print("check 1")

-- =================== --
-- ==== INIT PT 1 ==== --
-- =================== --

local function waitForCerberusAccess(timeoutSeconds)
    local deadline = timeoutSeconds and (os.clock() + timeoutSeconds)
    while not getgenv().CERBERUS_ACCESS_OK do
        if deadline and os.clock() >= deadline then return false end
        task.wait(0.05)
    end
    return true
end

if getgenv().CERBERUS_LOADED then
    Library:Notify(m or "Cerberus is already running! Please close the existing menu first, then run this script again.",
        5)
    return
end
if not game:IsLoaded() then game.Loaded:Wait() end

loadstring(game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/init.lua"))()

-- ==== FETCH DEPENDENCIES ==== --
local t0 = tick()
local Dependencies = {
    -- lib
    obsidianSrc      = (function()
        local ok, res = pcall(game.HttpGet, game,
            "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"); return ok and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/Obsidian/main/Library.lua")
    end)(),
    obsidianThemeSrc = (function()
        local ok, res = pcall(game.HttpGet, game,
            "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"); return ok and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/Obsidian/main/addons/ThemeManager.lua")
    end)(),
    obsidianSaveSrc  = (function()
        local ok, res = pcall(game.HttpGet, game,
            "https://raw.githubusercontent.com/whodunitwww/Obsidian/main/addons/SaveManager.lua"); return ok and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/Obsidian/main/addons/SaveManager.lua")
    end)(),

    -- other
    autoFarmSrc      = (function()
        local ok, res = pcall(function() if isfile and isfile("autoFarmSrc.lua") then return readfile("autoFarmSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet(
        "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/the-forge/autoFarmSrc.lua")
    end)(),
    mazeSrc          = (function()
        local ok, res = pcall(function() if isfile and isfile("mazeSrc.lua") then return readfile("mazeSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/the-forge/mazeSrc.lua")
    end)(),
    homeSrc          = (function()
        local ok, res = pcall(function() if isfile and isfile("homeSrc.lua") then return readfile("homeSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/the-forge/homeSrc.lua")
    end)(),
    attachSrc        = (function()
        local ok, res = pcall(function() if isfile and isfile("attachSrc.lua") then return readfile("attachSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/liteAttach.lua")
    end)(),
    aimbotSrc        = (function()
        local ok, res = pcall(function() if isfile and isfile("aimbotSrc.lua") then return readfile("aimbotSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/aimbotModule.lua")
    end)(),
    movementSrc      = (function()
        local ok, res = pcall(function() if isfile and isfile("movementSrc.lua") then return readfile("movementSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/movement.lua")
    end)(),
    senseSrc         = game:HttpGet(
    "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/sense/main.lua"),
    macroSrc         = (function()
        local ok, res = pcall(function() if isfile and isfile("macrosrc.lua") then return readfile("macrosrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/macros.lua")
    end)(),
    visualsSrc       = (function()
        local ok, res = pcall(function() if isfile and isfile("visualsSrc.lua") then return readfile("visualsSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/visuals.lua")
    end)(),
    miscSrc          = (function()
        local ok, res = pcall(function() if isfile and isfile("miscsrc.lua") then return readfile("miscsrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/miscTab.lua")
    end)(),
    funSrc           = (function()
        local ok, res = pcall(function() if isfile and isfile("funSrc.lua") then return readfile("funSrc.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/funSrc.lua")
    end)(),
    autoSellEditor   = (function()
        local ok, res = pcall(function() if isfile and isfile("autoSellEditor.lua") then return readfile(
                "autoSellEditor.lua") end end)
        return (ok and type(res) == "string" and #res > 0) and res or
        game:HttpGet(
        "https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/the-forge/autoSellEditor.lua")
    end)(),
}
print(string.format("got dependencies in %.2f seconds", tick() - t0))
assert(waitForCerberusAccess(20), "[Cerberus] Access validation timed out.")

-- =============== --
-- ==== SETUP ==== --
-- =============== --

-- ==== SERVICES ==== --
local Services = {
    CollectionService = game:GetService("CollectionService"),
    ContextActionService = game:GetService("ContextActionService"),
    Debris = game:GetService("Debris"),
    GuiService = game:GetService("GuiService"),
    HttpService = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    LogService = game:GetService("LogService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    PathfindingService = game:GetService("PathfindingService"),
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    SoundService = game:GetService("SoundService"),
    StarterGui = game:GetService("StarterGui"),
    Teams = game:GetService("Teams"),
    TeleportService = game:GetService("TeleportService"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    Workspace = game:GetService("Workspace"),
}

print("check 2")

-- ==== REFERENCES ==== --
local References = {
    player = Services.Players.LocalPlayer,
    character = nil,
    humanoid = nil,
    humanoidRootPart = nil,
    camera = Services.Workspace.CurrentCamera,
    gameName = "The Forge",
    gameDir = ("Cerberus/%s"):format("The Forge"),
    executorName = identifyexecutor() or "Unknown",
    mouse = game.Players.LocalPlayer:GetMouse()
}

local Shared = Services.ReplicatedStorage:WaitForChild("Shared")
local Knit   = require(Shared:WaitForChild("Packages"):WaitForChild("Knit"))

local KnitServices = Shared
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")

-- lazy-initialised controller (non-blocking)
local KnitPlayerController
local lastKnitWarn = 0

local function tryGetKnitPlayerController()
    -- if we already cached it, just reuse
    if KnitPlayerController then
        return KnitPlayerController
    end

    local ok, controller = pcall(function()
        return Knit.GetController("PlayerController")
    end)

    if not ok or not controller then
        -- throttle warnings so the console doesn’t fill up
        local now = os.clock()
        if now - lastKnitWarn > 10 then
            lastKnitWarn = now
            warn("[Cerberus] PlayerController not ready yet (Knit).")
        end
        return nil
    end

    KnitPlayerController = controller
    return KnitPlayerController
end

if makefolder then
    pcall(makefolder, "Cerberus"); pcall(makefolder, References.gameDir)
end

-- ==== OBSIDIAN UI SETUP ==== --
local Library = loadstring(Dependencies.obsidianSrc)()
local ThemeManager = loadstring(Dependencies.obsidianThemeSrc)()
local SaveManager = loadstring(Dependencies.obsidianSaveSrc)()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
    Title = "Cerberus",
    Footer = References.gameName .. " | https://getcerberus.com",
    Icon = 136497541793809,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Home = Window:AddTab("Home", "house"),
    Main = Window:AddTab("Main", "menu"),
    Player = Window:AddTab("Player", "circle-user"),
    ESP = Window:AddTab("ESP", "eye"),
    Auto = Window:AddTab("Auto", "bot"),
    Misc = Window:AddTab("Misc", "archive"),
    Fun = Window:AddTab("Fun", "joystick"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

print("check 3")

-- ========================== --
-- ==== HELPER FUNCTIONS ==== --
-- ========================== --

-- ==== NOCLIP ==== --
local noclipConn
local noclipRefCount = 0

local function startNoclip()
    noclipRefCount = noclipRefCount + 1
    if noclipConn then return end

    noclipConn = Services.RunService.Stepped:Connect(LPH_NO_VIRTUALIZE(function()
        if not References.character then return end
        for _, part in ipairs(References.character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end))
end

local function stopNoclip()
    noclipRefCount = math.max(0, noclipRefCount - 1)
    if noclipRefCount == 0 and noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
end

-- ====  MOVE TO POS ==== --
local function MoveToPos(targetPos, studsPerSecond, dynamicTargetFunc)
    startNoclip()

    for _, v in ipairs(References.humanoidRootPart:GetChildren()) do
        if v:IsA("Attachment") or v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            pcall(function() v:Destroy() end)
        end
    end

    studsPerSecond = math.max(0, tonumber(studsPerSecond) or 0)
    if studsPerSecond == 0 then
        return function() stopNoclip() end
    end

    if References.humanoid then
        References.humanoid.AutoRotate = false
    end
    References.humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

    local a0 = Instance.new("Attachment")
    a0.Parent = References.humanoidRootPart

    local ap = Instance.new("AlignPosition")
    ap.Mode = Enum.PositionAlignmentMode.OneAttachment
    ap.Attachment0 = a0
    ap.ApplyAtCenterOfMass = true
    ap.RigidityEnabled = false
    ap.Responsiveness = 200
    ap.MaxForce = math.huge
    ap.MaxVelocity = studsPerSecond
    ap.Position = targetPos
    ap.Parent = References.humanoidRootPart

    local ao = Instance.new("AlignOrientation")
    ao.Attachment0 = a0
    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
    ao.Responsiveness = 100
    ao.RigidityEnabled = true
    ao.MaxTorque = math.huge
    ao.Parent = References.humanoidRootPart

    local alive = true
    local conn

    local function cleanup()
        if not alive then return end
        alive = false
        if conn then
            conn:Disconnect(); conn = nil
        end
        for _, obj in ipairs({ ao, ap, a0 }) do
            if obj then pcall(function() obj:Destroy() end) end
        end
        if References.humanoid then References.humanoid.AutoRotate = true end
        stopNoclip()
    end

    local startT = os.clock()
    conn = Services.RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
        if not alive then return end
        local hrp = References.humanoidRootPart
        if not (hrp and hrp.Parent) then
            cleanup(); return
        end

        local targetNow = dynamicTargetFunc and dynamicTargetFunc() or targetPos
        if not targetNow then
            cleanup(); return
        end

        ap.Position = targetNow
        ao.CFrame = CFrame.lookAt(hrp.Position, targetNow)

        local dist = (hrp.Position - targetNow).Magnitude
        if dist <= 3 or (os.clock() - startT) > 15 then
            cleanup(); return
        end
    end))

    return cleanup
end

-- ==== SEND TO DISCORD WEBHOOK ==== --
local function SendDiscordWebhook(webhookUrl, title, description, nickname, color, iconUrl, anonymize)
    local EMBED_COLOR_DEC = color or 3577389
    local ICON_URL = iconUrl or
        "https://media.discordapp.net/attachments/1349939253739651134/1428995137505067069/cerberus_logo.png"
    local SHOULD_ANON = (anonymize == true)

    local playerName, gameName = "Unknown Player", "Unknown Game"
    pcall(function()
        local Players = game:GetService("Players")
        playerName = Players.LocalPlayer and Players.LocalPlayer.Name or "Unknown Player"
        gameName = (References and References.gameName) or gameName
    end)

    local desc = tostring(description or "")
    if not SHOULD_ANON then
        desc = desc .. string.format(
            "\n\n**Player:** `%s`\n**Game:** `%s`",
            tostring(playerName),
            tostring(gameName)
        )
    end

    local payload = {
        username = nickname or "Cerberus Macro Logger",
        avatar_url = ICON_URL,
        embeds = { {
            title = tostring(title or "Cerberus Event"),
            description = desc,
            color = EMBED_COLOR_DEC
        } }
    }

    local body = Services.HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json"
    }

    local ok, res
    if syn and syn.request then
        ok, res = pcall(function()
            return syn.request({
                Url = webhookUrl,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)
    elseif http_request then
        ok, res = pcall(function()
            return http_request({
                Url = webhookUrl,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)
    elseif request then
        ok, res = pcall(function()
            return request({
                Url = webhookUrl,
                Method = "POST",
                Headers = headers,
                Body = body
            })
        end)
    else
        ok, res = pcall(function()
            return Services.HttpService:PostAsync(webhookUrl, body, Enum.HttpContentType.ApplicationJson)
        end)
    end
end

-- ==== COPY LINK TO CLIPBOARD ==== --
local function copyLink(u, m)
    if setclipboard then
        pcall(setclipboard, u); Library:Notify(m or "Link copied.", 3)
    else
        Library:Notify("Clipboard not supported in this executor.", 3)
    end
end

local META = {
    name      = "Cerberus | The Forge",
    version   = "v2.6.5",
    updated   = "2026-1-12",
    status    = "Stable Release",
    changelog = {
        "Updated for The Maze"
    },
    urls      = {
        docs     = "https://getcerberus.com/docs",
        website  = "https://getcerberus.com",
        discord  = "https://getcerberus.com/discord",
        youtube  = "https://youtube.com/@getcerberus",
        scripts  = "https://getcerberus.com/scripts",
        bunni    = "https://getcerberus.com/bunni",
        obsidian = "https://github.com/deividvd/obsidian",
    },
}

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
    Default = "75%",

    Text = "DPI Scale",

    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)

        Library:SetDPIScale(DPI)
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
    :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true })

MenuGroup:AddButton("Unload", function()
    Library:Unload()
    getgenv().CERBERUS_LOADED = nil
    getgenv().CERBERUS_ACCESS_OK = nil
end)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Cerberus")
SaveManager:SetFolder("Cerberus/" .. References.gameName)
SaveManager:SetSubFolder("Configurations")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
ThemeManager:ApplyTheme("Mint")

-- ================== --
-- ==== HOME TAB ==== --
-- ================== --

-- ==== HOME TAB ==== --
local HomePanel = (loadstring(Dependencies.homeSrc)())(setmetatable({
    Services           = Services,
    Tabs               = Tabs,
    References         = References,
    Library            = Library,
    Options            = Options,
    Toggles            = Toggles,
    META               = META,
    copyLink           = copyLink,
    SendDiscordWebhook = SendDiscordWebhook,
}, { __index = _G }))

-- ================== --
-- ==== MAIN TAB ==== --
-- ================== --

-- ==================== --
-- ==== BOSSES GRP ==== --
-- ==================== --

local BossesGroup = Tabs.Main:AddLeftGroupbox("Bosses", "skull")

-- State storage for the UI
local GolemTimerUI = {
    Instance = nil,
    Connection = nil
}

BossesGroup:AddToggle("Boss_GolemTimerUI", {
    Text = "Golem Timer",
    Default = false,
    Tooltip = "Shows a movable UI tracking the Golem spawn timer.",
    Callback = function(state)
        -- 1. Cleanup existing UI/Connections if they exist
        if GolemTimerUI.Instance then 
            pcall(function() GolemTimerUI.Instance:Destroy() end) 
            GolemTimerUI.Instance = nil 
        end
        if GolemTimerUI.Connection then 
            GolemTimerUI.Connection:Disconnect() 
            GolemTimerUI.Connection = nil 
        end

        -- 2. Stop here if disabling
        if not state then return end

        -- 3. Create Lightweight GUI
        local sg = Instance.new("ScreenGui")
        sg.Name = "CerberusGolemTimer"
        -- Try CoreGui first for security, fallback to PlayerGui
        if pcall(function() sg.Parent = game:GetService("CoreGui") end) then
        else
            sg.Parent = Services.Players.LocalPlayer:WaitForChild("PlayerGui")
        end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 140, 0, 50)
        
        -- CHANGED: Top Left (20px padding), 0.2 Scale Y (which is 4/5ths up from bottom)
        frame.Position = UDim2.new(0, 20, 0.15, 0) 
        
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true -- Allows dragging
        frame.Parent = sg

        -- Rounded Corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = frame

        -- UI Stroke
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 60, 60)
        stroke.Thickness = 1.5
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        stroke.Parent = frame

        -- Title Label
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 18)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(180, 180, 180)
        title.TextSize = 11
        title.Font = Enum.Font.GothamBold
        title.Text = "GOLEM TIMER"
        title.Parent = frame

        -- Value Label
        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, 0, 0, 28)
        value.Position = UDim2.new(0, 0, 0, 18)
        value.BackgroundTransparency = 1
        value.TextColor3 = Color3.fromRGB(255, 255, 255)
        value.TextSize = 16
        value.Font = Enum.Font.Gotham
        value.Text = "Waiting..."
        value.Parent = frame

        GolemTimerUI.Instance = sg

        -- 4. Start Update Loop
        GolemTimerUI.Connection = Services.RunService.RenderStepped:Connect(function()
            -- Safe path lookup
            local target = workspace:FindFirstChild("Proximity")
            if target then target = target:FindFirstChild("CreateParty") end
            if target then target = target:FindFirstChild("Golem") end
            if target then target = target:FindFirstChild("Timer") end
            if target then target = target:FindFirstChild("Container") end
            if target then target = target:FindFirstChild("Label") end

            if target and (target:IsA("TextLabel") or target:IsA("TextButton")) then
                value.Text = target.Text
                value.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                value.Text = "Inactive"
                value.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
    end
})

-- ==== TELEPORTS ==== --
local TeleportsGroupbox = Tabs.Main:AddLeftGroupbox("Teleports", "move-3d")
local tpMap, npcModelByLabel, wpList, wpOrder = {}, {}, {}, {}
local wpFile = References.gameDir .. "/waypoints.json"

local function getCannonPart()
    local land = workspace.Assets:FindFirstChild("Main Island [2]")
    if land then
        local subLand = land:FindFirstChild("Land [2]")
        if subLand then
            local children = subLand:GetChildren()
            -- Try known index 21 first for speed
            if children[21] and children[21]:FindFirstChild("CannonPart") then
                return children[21].CannonPart
            end
            -- Fallback search
            for _, child in ipairs(children) do
                if child:FindFirstChild("CannonPart") then
                    return child.CannonPart
                end
            end
        end
    end
    return nil
end

local function v3_to_tbl(v) return { x = v.X, y = v.Y, z = v.Z } end
local function tbl_to_v3(t)
    if typeof(t) == "Vector3" then return t end
    if type(t) == "table" then
        local x = t.x or t.X or t[1]
        local y = t.y or t.Y or t[2]
        local z = t.z or t.Z or t[3]
        if tonumber(x) and tonumber(y) and tonumber(z) then
            return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
    return nil
end

-- Load saved waypoints
if isfile and isfile(wpFile) then
    local ok, data = pcall(readfile, wpFile)
    if ok and data and #data > 0 then
        local ok2, obj = pcall(function() return Services.HttpService:JSONDecode(data) end)
        if ok2 and type(obj) == "table" then
            local L = obj.list or {}
            local O = obj.order or {}
            wpList, wpOrder = {}, {}
            for name, posObj in pairs(L) do
                local v = tbl_to_v3(posObj)
                if v then wpList[name] = v end
            end
            for i = 1, #O do
                local nm = O[i]
                if wpList[nm] then wpOrder[#wpOrder + 1] = nm end
            end
            if #wpOrder == 0 then
                for nm in pairs(wpList) do wpOrder[#wpOrder + 1] = nm end
                table.sort(wpOrder)
            end
        end
    end
end

local function saveWP()
    if not writefile then return end
    local enc = { list = {}, order = wpOrder }
    for name, v in pairs(wpList) do
        if typeof(v) == "Vector3" then
            enc.list[name] = v3_to_tbl(v)
        elseif type(v) == "table" then
            enc.list[name] = v
        end
    end
    pcall(function() writefile(wpFile, Services.HttpService:JSONEncode(enc)) end)
end

local function uniq(used, base)
    local k, n = base, 1
    while used[k] do
        n = n + 1
        k = ("%s (%d)"):format(base, n)
    end
    used[k] = true
    return k
end

-- Collect destinations per category
local function scan(category)
    table.clear(tpMap)
    table.clear(npcModelByLabel)

    if category == "Players" then
        local used = {}
        for _, pl in ipairs(Services.Players:GetPlayers()) do
            if pl ~= References.player then
                local ch  = pl.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local base = (pl.DisplayName ~= "" and pl.DisplayName) or pl.Name
                    tpMap[uniq(used, base)] = hrp.Position
                end
            end
        end
    elseif category == "Monsters" then
        local folder = workspace:FindFirstChild("Living")
        if not folder then return end

        local used = {}
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") then
                local hum = m:FindFirstChildOfClass("Humanoid")
                if hum then
                    local isPlayerChar = false
                    for _, pl in ipairs(Services.Players:GetPlayers()) do
                        local ch = pl.Character
                        if ch and (m == ch or m:IsDescendantOf(ch)) then
                            isPlayerChar = true
                            break
                        end
                    end
                    if not isPlayerChar then
                        local pos
                        local ok, piv = pcall(m.GetPivot, m)
                        if ok and typeof(piv) == "CFrame" then
                            pos = piv.Position
                        else
                            local hrp = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart")
                            pos = hrp and hrp.Position
                        end
                        if pos then
                            local dn = m:FindFirstChild("DisplayName")
                            local baseName = (dn and dn:IsA("StringValue") and dn.Value) or m.Name or "Monster"
                            local label = uniq(used, baseName)
                            tpMap[label] = pos
                            npcModelByLabel[label] = m
                        end
                    end
                end
            end
        end
    elseif category == "NPCs" then
        local folder = workspace:FindFirstChild("Proximity")
        if not folder then return end

        local used = {}
        for _, m in ipairs(folder:GetChildren()) do
            if m:IsA("Model") then
                local pos
                local ok, piv = pcall(m.GetPivot, m)
                if ok and typeof(piv) == "CFrame" then
                    pos = piv.Position
                else
                    local root = m:FindFirstChildWhichIsA("BasePart")
                    pos = root and root.Position
                end
                if pos then
                    local baseName = m.Name or "NPC"
                    local label = uniq(used, baseName)
                    tpMap[label] = pos
                    npcModelByLabel[label] = m
                end
            end
        end
    elseif category == "Waypoints" then
        for i = 1, #wpOrder do
            local k = wpOrder[i]
            local v = wpList[k]
            if v then tpMap[k] = v end
        end
    end
end

local function namesFor(category)
    local t = {}
    if category == "Waypoints" then
        for i = 1, #wpOrder do
            local k = wpOrder[i]
            if tpMap[k] then t[#t + 1] = k end
        end
    else
        for n in pairs(tpMap) do t[#t + 1] = n end
        table.sort(t)
    end
    return t
end

TeleportsGroupbox:AddDropdown("TP_TravelMode", {
    Text = "Travel Mode",
    Values = { "Teleport", "Tween" },
    Default = "Teleport",
})

TeleportsGroupbox:AddSlider("TP_TravelSpeed", {
    Text = "Flight Speed",
    Default = 80,
    Min = 30,
    Max = 250,
    Rounding = 0,
    Suffix = " studs/s"
})

TeleportsGroupbox:AddToggle("TP_SafetyMode", {
    Text = "Safety Mode",
    Default = false,
    Tooltip = "Blocks teleport if a player is near the destination."
})

TeleportsGroupbox:AddSlider("TP_SafetyRange", {
    Text = "Safety Range",
    Default = 50,
    Min = 10,
    Max = 250,
    Rounding = 0,
    Suffix = " studs"
})

local function isPlayerNear(pos, range)
    range = tonumber(range) or 50
    for _, pl in ipairs(Services.Players:GetPlayers()) do
        if pl ~= References.player then
            local ch  = pl.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - pos).Magnitude <= range then
                return true, pl
            end
        end
    end
    return false, nil
end

local current = "Players"
scan(current)
local names    = namesFor(current)
local selected = names[1]

local ddCat    = TeleportsGroupbox:AddDropdown("TP_Category", {
    Text    = "Category",
    Values  = { "Players", "Monsters", "NPCs", "Waypoints" },
    Default = current
})
local ddLoc    = TeleportsGroupbox:AddDropdown("TP_Location", {
    Text    = "Select Location",
    Values  = names,
    Default = selected
})

local function refreshList(preserve)
    local prev = preserve and ddLoc.Value or selected
    scan(current)
    names = namesFor(current)

    if #names == 0 then
        selected = nil
        ddLoc:SetValues({})
        ddLoc:SetValue(nil)
        return
    end

    if prev and table.find(names, prev) then
        selected = prev
    else
        selected = names[1]
    end

    ddLoc:SetValues(names)
    ddLoc:SetValue(selected)
end

ddCat:OnChanged(function(v)
    current = v
    refreshList(false)
end)
ddLoc:OnChanged(function(v)
    selected = v
end)

TeleportsGroupbox:AddButton({
    Text = "Teleport",
    Func = function()
        if not References.humanoidRootPart then
            return Library:Notify("No character.", 3)
        end

        -- FIX: Safety check for FarmState before accessing .enabled
        if FarmState and FarmState.enabled then
            if stopFarm then
                stopFarm()
                Library:Notify("Farming stopped for teleport.", 2)
            end
        end

        scan(current)
        local choice = ddLoc.Value or selected
        if not choice then
            return Library:Notify("No destination in this category.", 3)
        end

        local p = tpMap[choice]
        if not p then
            return Library:Notify("Invalid destination.", 3)
        end

        -- Safety Check
        if Toggles.TP_SafetyMode and Toggles.TP_SafetyMode.Value then
            local inRange, who = isPlayerNear(p, Options.TP_SafetyRange.Value)
            if inRange then
                local nm = (who and ((who.DisplayName ~= "" and who.DisplayName) or who.Name)) or "a player"
                return Library:Notify("Safety Mode: Aborted, " .. nm .. " is near destination.", 5)
            end
        end

        -- Execute Travel Logic
        local mode = Options.TP_TravelMode.Value
        local hrp = References.humanoidRootPart
        local targetPos = p + Vector3.new(0, 3, 0)

        if mode == "Teleport" then
            -- CANNON BYPASS LOGIC
            local cannonPart = getCannonPart()
            if cannonPart then
                local prompt = cannonPart:FindFirstChildOfClass("ProximityPrompt")
                local active = true

                -- 1. Spammer
                task.spawn(function()
                    while active do
                        if prompt then fireproximityprompt(prompt) end
                        task.wait(0.1)
                    end
                end)

                task.spawn(function()
                    -- 2. Move to Cannon & Wait
                    local startWait = os.clock()
                    repeat
                        hrp.CFrame = cannonPart.CFrame
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        task.wait()
                    until (hrp.Position - cannonPart.Position).Magnitude < 10 or (os.clock() - startWait > 2)

                    task.wait(0.55)     -- Interaction Buffer

                    active = false      -- Stop Spammer

                    -- Force unsit
                    local hum = References.humanoid
                    if hum then hum.Sit = false end

                    -- 3. Move to Destination (Loop to override rubber-band)
                    hrp.Anchored = true
                    for i = 1, 15 do
                        hrp.CFrame = CFrame.new(targetPos)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        if hum then hum.Sit = false end
                        task.wait(0.05)
                    end
                    hrp.Anchored = false
                end)
            else
                Library:Notify("Cannon not found! Falling back to Flight.", 3)
                local spd = math.max(10, Options.TP_TravelSpeed.Value or 80)
                MoveToPos(targetPos, spd)
            end
        else
            -- TWEEN / FLIGHT LOGIC
            local spd = math.max(10, Options.TP_TravelSpeed.Value or 80)
            MoveToPos(targetPos, spd)
        end
    end
})

TeleportsGroupbox:AddButton({
    Text = "Refresh",
    Func = function()
        refreshList(true)
    end
})

TeleportsGroupbox:AddDivider()

TeleportsGroupbox:AddInput("TP_WP_Name", {
    Text = "Waypoint Name",
    Placeholder = "My Waypoint",
    ClearTextOnFocus = false,
    Finished = false
})

local function _trim(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end

TeleportsGroupbox:AddButton({
    Text = "Add Waypoint",
    Tooltip = "Adds a waypoint at your current location.",
    Func = function()
        if not References.humanoidRootPart then return Library:Notify("No character.", 3) end

        local base = _trim(Options.TP_WP_Name.Value)
        if base == "" then base = "Waypoint" end

        local name = base
        if wpList[name] ~= nil then
            local used = {}; for _, n in ipairs(wpOrder) do used[n] = true end
            name = uniq(used, base)
        end

        wpList[name] = References.humanoidRootPart.Position
        wpOrder[#wpOrder + 1] = name
        saveWP()

        if current == "Waypoints" then
            refreshList(true)
            ddLoc:SetValue(name)
            selected = name
        end

        Library:Notify("Added waypoint: " .. name, 3)
    end
})

TeleportsGroupbox:AddButton({
    Text = "Remove Waypoint",
    Tooltip = "Removes the currently selected waypoint.",
    Func = function()
        if current ~= "Waypoints" then return Library:Notify("Switch to Waypoints to remove.", 3) end
        local choice = ddLoc.Value or selected
        if not choice or not wpList[choice] then return Library:Notify("Select a waypoint to remove.", 3) end

        wpList[choice] = nil
        for i = #wpOrder, 1, -1 do
            if wpOrder[i] == choice then table.remove(wpOrder, i) end
        end
        saveWP()
        refreshList(true)
        Library:Notify("Removed waypoint: " .. choice, 3)
    end
})

-- ==== MAZE MODULE ==== --
local MazeModule = (loadstring(Dependencies.mazeSrc)())(setmetatable({
    Services   = Services,
    Tabs       = Tabs,
    References = References,
    Library    = Library,
    Options    = Options,
    Toggles    = Toggles,
    MoveToPos  = MoveToPos,
}, { __index = _G }))

-- ================== --
-- ===== FORGING ==== --
-- ================== --

local ForgingGroupbox  = Tabs.Main:AddRightGroupbox("Forging", "hammer")

local PlayerGui        = References.player:WaitForChild("PlayerGui")
local RunService       = Services.RunService or game:GetService("RunService")
local Vim              = Services.VirtualInputManager or game:GetService("VirtualInputManager")
local Camera           = workspace.CurrentCamera

local AutoForgeEnabled = false

-- POUR state
local PourState        = {
    pressed     = false,
    lastX       = 0,
    lastY       = 0,
    deadzone    = 3,     -- centre band where we do nothing
    hysteresis  = 1.5,   -- extra margin before flipping state, reduces jitter
    lastVisible = -1e9,
    wasVisible  = false,
    cycleId     = 0,
    lastEndTime = -1e9,
}

-- POST-POUR “continue / next” clicker
local PostPour         = {
    active          = false,
    clicksRemaining = 0,
    nextClickTime   = 0,
    handledCycleId  = 0,
}

-- HAMMER state
local HammerState      = {
    active = false,
    circles = {}, -- [circleImageLabel] = { lastDiff, lastTime, clicked }
}

-- MELT / HEATER macro state
local MeltState        = {
    mouseDown = false,
    lastPos   = nil,
    step      = 0,
    steps     = 5,
    goingDown = true,
}

-- post-pour click positions (relative to screen)
local CLICK_REL_X      = 0.583
local CLICK_REL_Y      = 0.429
local POST_CLICK_REL_Y = math.clamp(CLICK_REL_Y + 0.05, 0, 1)

-- ============================== --
-- ===== GENERIC HELPERS ======= --
-- ============================== --

local function getForgeGui()
    return PlayerGui:FindFirstChild("Forge")
end

local function safeReleaseMouse()
    if MeltState.mouseDown and MeltState.lastPos then
        pcall(function()
            Vim:SendMouseButtonEvent(MeltState.lastPos.X, MeltState.lastPos.Y, 0, false, game, false)
        end)
    end
    MeltState.mouseDown = false

    if PourState.pressed then
        pcall(function()
            Vim:SendMouseButtonEvent(PourState.lastX, PourState.lastY, 0, false, game, false)
        end)
    end
    PourState.pressed = false
end

local function clickScreenAtRelative(rx, ry)
    if not Camera then
        Camera = workspace.CurrentCamera
        if not Camera then return end
    end

    local vp = Camera.ViewportSize
    local x  = vp.X * rx
    local y  = vp.Y * ry

    Vim:SendMouseMoveEvent(x, y, game)
    task.wait(0.01)
    Vim:SendMouseButtonEvent(x, y, 0, true, game, false)
    task.wait(0.01)
    Vim:SendMouseButtonEvent(x, y, 0, false, game, false)
end

local function clickAtFrame(frame)
    local absPos  = frame.AbsolutePosition
    local absSize = frame.AbsoluteSize

    local cx      = absPos.X + absSize.X * 0.5
    local cy      = absPos.Y + absSize.Y * 0.5

    -- click a bit lower inside the ring to be safe
    local x       = cx
    local y       = cy + absSize.Y * 0.75

    if Camera then
        local vp = Camera.ViewportSize
        y = math.clamp(y, 0, vp.Y)
    end

    Vim:SendMouseMoveEvent(x, y, game)
    task.wait(0.01)
    Vim:SendMouseButtonEvent(x, y, 0, true, game, false)
    task.wait(0.01)
    Vim:SendMouseButtonEvent(x, y, 0, false, game, false)
end

-- ============================== --
-- ======= POUR MINIGAME ======== --
-- ============================== --

local function clearPourLineLock()
    if PourState.pressed then
        pcall(function()
            Vim:SendMouseButtonEvent(PourState.lastX, PourState.lastY, 0, false, game, false)
        end)
    end
    PourState.pressed = false
    PourState.lastX   = 0
    PourState.lastY   = 0
end

local function setPourHold(hold, cx, cy)
    PourState.lastX, PourState.lastY = cx, cy

    if hold and not PourState.pressed then
        Vim:SendMouseButtonEvent(cx, cy, 0, true, game, false)
        PourState.pressed = true
    elseif (not hold) and PourState.pressed then
        Vim:SendMouseButtonEvent(cx, cy, 0, false, game, false)
        PourState.pressed = false
    end
end

RunService.RenderStepped:Connect(function()
    local forge       = getForgeGui()
    local pour        = forge and forge:FindFirstChild("PourMinigame")

    local now         = os.clock()
    local pourVisible = (pour ~= nil and pour.Visible == true)

    -- track visibility & cycles for the post-pour clicker
    if pourVisible then
        PourState.lastVisible = now
    end

    if pourVisible and not PourState.wasVisible then
        -- pour just started
        PourState.wasVisible = true
        clearPourLineLock()
    elseif (not pourVisible) and PourState.wasVisible then
        -- pour just ended
        PourState.wasVisible  = false
        PourState.cycleId     = PourState.cycleId + 1
        PourState.lastEndTime = now
        clearPourLineLock()
    end

    if not AutoForgeEnabled then
        clearPourLineLock()
        return
    end

    if not pourVisible then
        clearPourLineLock()
        return
    end

    local frame = pour:FindFirstChild("Frame")
    local line  = frame and frame:FindFirstChild("Line")
    local area  = frame and frame:FindFirstChild("Area")

    if not (frame and line and area and line:IsA("Frame") and area:IsA("Frame")) then
        clearPourLineLock()
        return
    end

    -- compute current / target Y
    local linePos  = line.AbsolutePosition
    local lineSize = line.AbsoluteSize
    local areaPos  = area.AbsolutePosition
    local areaSize = area.AbsoluteSize

    local lineCy   = linePos.Y + lineSize.Y * 0.5
    local targetCy = areaPos.Y + areaSize.Y * 0.5

    -- click at AREA centre, not the line itself
    local clickCx  = areaPos.X + areaSize.X * 0.5
    local clickCy  = targetCy

    local diff     = lineCy - targetCy -- >0 = below target, <0 = above
    local dz       = PourState.deadzone
    local hys      = PourState.hysteresis

    -- simple bang-bang with hysteresis
    -- zone layout:  [ release zone ] | [ dead band ] | [ hold zone ]
    if diff > (dz + hys) then
        -- line is well below target => hold to move up
        setPourHold(true, clickCx, clickCy)
    elseif diff < -(dz + hys) then
        -- line is well above => release to let it drop
        setPourHold(false, clickCx, clickCy)
    else
        -- inside "do nothing" band => keep current mouse state to avoid jitter
    end
end)

-- ============================== --
-- ======= POST-POUR CLICKS ===== --
-- ============================== --

task.spawn(function()
    while true do
        task.wait(0.05)

        if not AutoForgeEnabled then
            PostPour.active          = false
            PostPour.clicksRemaining = 0
            continue
        end

        local now = os.clock()

        -- if we just finished a pour cycle, wait ~3s then tap a few times
        if (not PostPour.active)
            and (PourState.cycleId > PostPour.handledCycleId)
            and (now - PourState.lastEndTime >= 3)
        then
            PostPour.active          = true
            PostPour.clicksRemaining = 3
            PostPour.nextClickTime   = now
            PostPour.handledCycleId  = PourState.cycleId
        end

        if PostPour.active and PostPour.clicksRemaining > 0 and now >= PostPour.nextClickTime then
            clickScreenAtRelative(CLICK_REL_X, POST_CLICK_REL_Y)

            PostPour.clicksRemaining -= 1
            if PostPour.clicksRemaining > 0 then
                PostPour.nextClickTime = now + 0.5
            else
                PostPour.active = false
            end
        end
    end
end)

-- ============================== --
-- ========= HAMMER GAME ======== --
-- ============================== --

task.spawn(function()
    while task.wait(0.01) do
        if not AutoForgeEnabled then
            HammerState.active = false
            for k in pairs(HammerState.circles) do
                HammerState.circles[k] = nil
            end
            continue
        end

        local forge  = getForgeGui()
        local hammer = forge and forge:FindFirstChild("HammerMinigame")
        if not (hammer and hammer.Visible) then
            HammerState.active = false
            for k in pairs(HammerState.circles) do
                HammerState.circles[k] = nil
            end
            continue
        end

        HammerState.active = true

        local root = hammer:FindFirstChild("Frame")
        if not root then
            for k in pairs(HammerState.circles) do
                HammerState.circles[k] = nil
            end
            continue
        end

        -- cleanup dead circles
        for circle in pairs(HammerState.circles) do
            if not circle or not circle.Parent then
                HammerState.circles[circle] = nil
            end
        end

        for _, ring in ipairs(root:GetDescendants()) do
            if ring:IsA("ImageLabel") and ring.Name == "Frame" and ring.Visible then
                local circle = ring:FindFirstChild("Circle")
                if circle and circle:IsA("ImageLabel") and circle.Visible then
                    local state = HammerState.circles[circle]
                    if not state then
                        state = { lastDiff = nil, lastTime = nil, clicked = false }
                        HammerState.circles[circle] = state
                    end

                    if not state.clicked then
                        local frameSize  = ring.AbsoluteSize
                        local circleSize = circle.AbsoluteSize

                        local diff       = math.abs(circleSize.X - frameSize.X)
                        local now        = os.clock()

                        -- treat “growing” circles differently: only consider when circle > frame
                        local larger     = (circleSize.X > frameSize.X) and (circleSize.Y > frameSize.Y)
                        if larger then
                            -- if we've already collected at least one sample, do a tiny prediction
                            if state.lastTime and state.lastDiff then
                                local dt = now - state.lastTime
                                if dt > 0 then
                                    local dDiff = state.lastDiff - diff
                                    if dDiff > 0 then
                                        local speed = dDiff / dt
                                        local t_rem = diff / speed

                                        -- click slightly early so we land on the “perfect” band
                                        if t_rem <= 0.1 then
                                            state.clicked = true
                                            clickAtFrame(ring)
                                        end
                                    end
                                end
                            end

                            state.lastTime = now
                            state.lastDiff = diff

                            -- safety: if we ever get extremely close, just click anyway
                            if diff <= 3 and not state.clicked then
                                state.clicked = true
                                clickAtFrame(ring)
                            end
                        end
                    end
                end
            end
        end
    end
end)

print("check 5")

-- ============================== --
-- ========= MELT / HEATER ====== --
-- ============================== --

local function getMeltMinigame()
    local forge = getForgeGui()
    if not forge then return end

    local melt = forge:FindFirstChild("MeltMinigame")
    if not (melt and melt.Visible) then
        return
    end

    return melt
end

local function getHeaterTop()
    local melt = getMeltMinigame()
    if not melt then return end

    local heater = melt:FindFirstChild("Heater")
    if not heater then return end

    local top = heater:FindFirstChild("Top")
    return top, heater
end

task.spawn(function()
    while true do
        task.wait()

        if not AutoForgeEnabled then
            -- ensure we release the mouse if the heater stops
            if MeltState.mouseDown and MeltState.lastPos then
                Vim:SendMouseButtonEvent(
                    MeltState.lastPos.X,
                    MeltState.lastPos.Y,
                    0,
                    false,
                    game,
                    false
                )
            end
            MeltState.mouseDown = false
            continue
        end

        local top, heater = getHeaterTop()

        if not (top and heater) then
            if MeltState.mouseDown and MeltState.lastPos then
                Vim:SendMouseButtonEvent(
                    MeltState.lastPos.X,
                    MeltState.lastPos.Y,
                    0,
                    false,
                    game,
                    false
                )
            end
            MeltState.mouseDown = false
            task.wait(0.1)
            continue
        end

        local absPos    = top.AbsolutePosition
        local absSize   = top.AbsoluteSize
        local centerX   = absPos.X + absSize.X * 0.5

        local trackPos  = heater.AbsolutePosition
        local trackSize = heater.AbsoluteSize

        -- small high / low band so we constantly “scrub” the heater
        local highY     = trackPos.Y + trackSize.Y * 0.05
        local lowY      = trackPos.Y + trackSize.Y * 1.2

        -- simple up-and-down beep-boop along the track
        if MeltState.goingDown then
            MeltState.step += 1
            if MeltState.step >= MeltState.steps then
                MeltState.step = MeltState.steps
                MeltState.goingDown = false
            end
        else
            MeltState.step -= 1
            if MeltState.step <= 0 then
                MeltState.step = 0
                MeltState.goingDown = true
            end
        end

        local alpha    = MeltState.step / MeltState.steps
        local currentY = highY + (lowY - highY) * alpha

        if not MeltState.mouseDown then
            Vim:SendMouseButtonEvent(centerX, currentY, 0, true, game, false)
            MeltState.mouseDown = true
        end

        Vim:SendMouseMoveEvent(centerX, currentY, game)
        MeltState.lastPos = Vector2.new(centerX, currentY)
    end
end)

-- ============================== --
-- ========= UI TOGGLE ========= --
-- ============================== --

ForgingGroupbox:AddLabel("Don't tab out while Auto Forging.", true)


ForgingGroupbox:AddToggle("FORGE_AutoForge", {
    Text     = "Auto Forge",
    Tooltip  = "Completes all minigames automatically. Do not tab out while using.",
    Default  = false,
    Callback = function(state)
        AutoForgeEnabled = state

        if not state then
            -- hard reset everything when toggled off
            clearPourLineLock()
            HammerState.active = false
            for k in pairs(HammerState.circles) do
                HammerState.circles[k] = nil
            end

            if MeltState.mouseDown and MeltState.lastPos then
                Vim:SendMouseButtonEvent(
                    MeltState.lastPos.X,
                    MeltState.lastPos.Y,
                    0,
                    false,
                    game,
                    false
                )
            end
            MeltState.mouseDown      = false

            PostPour.active          = false
            PostPour.clicksRemaining = 0
        end
    end,
})

-- ==== REMOTE FORGE ==== --
ForgingGroupbox:AddButton({
    Text = "Remote Forge",
    Func = function()
        local forgeNode = workspace:FindFirstChild("Proximity")
            and workspace.Proximity:FindFirstChild("Forge")

        if not forgeNode then
            Library:Notify("Remote Forge failed: could not find workspace.Proximity.Forge", 4)
            return
        end

        local ok, err = pcall(function()
            KnitServices
                :WaitForChild("ProximityService")
                :WaitForChild("RF")
                :WaitForChild("Forge")
                :InvokeServer(forgeNode)
        end)

        if not ok then
            Library:Notify("Remote Forge failed: " .. tostring(err), 4)
        end
    end,
})

-- ==== SELL ALL EQUIPMENT ==== --
local function sellAllInventory()
    local success, err = pcall(function()
        local controller = getKnitPlayerController()
        local replica    = controller and controller.Replica
        local inv        = replica and replica.Data and replica.Data.Inventory

        if not inv then
            error("Replica / Inventory not ready")
        end

        local equipments = inv.Equipments or {}
        local basket     = {}
        local count      = 0

        for _, item in pairs(equipments) do
            if item.GUID then
                basket[item.GUID] = true
                count += 1
            end
        end

        if not next(basket) then
            Library:Notify("No equipment to sell.", 3)
            return
        end

        DialogueRunCommandRF:InvokeServer("SellConfirm", { Basket = basket })
        Library:Notify(("Sell request sent for %d item(s)."):format(count), 3)
    end)

    if not success then
        warn("Sell failed:", err)
        Library:Notify("Sell failed: " .. tostring(err) .. "\n(try talking to the merchant first)", 4)
    end
end

ForgingGroupbox:AddButton({
    Text = "Sell All Equipment",
    Tooltip = "Will sell all your equipment that you don't have equipped",
    Func = sellAllInventory,
})

ForgingGroupbox:AddLabel("For this to work, first talk to Wo.", true)

-- ==== AUTO SELL ==== --
local AutoSellGroupbox = Tabs.Main:AddRightGroupbox("Auto Sell", "shopping-bag")
AutoSellGroupbox:AddLabel("If this doesn't work straight away, open your stash and talk to Greedy Cee.", true)

-- Standard Dialogue Remotes
local DialogueRunCommandRF = KnitServices
    :WaitForChild("DialogueService")
    :WaitForChild("RF")
    :WaitForChild("RunCommand")

local ProximityDialogueRF  = KnitServices
    :WaitForChild("ProximityService")
    :WaitForChild("RF")
    :WaitForChild("Dialogue")

-- New Gamepass Sell Remote
local SellAnywhereRF = game:GetService("ReplicatedStorage")
    :WaitForChild("Shared")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("InventoryService")
    :WaitForChild("RF")
    :WaitForChild("SellAnywhere")

local AutoSellConfigFile   = References.gameDir .. "/AutoSellConfig.json"
local AutoSellConfig       = nil
local DRY_RUN              = false

local AUTOSELL_LOG         = false
local RUNE_DEBUG_VERBOSE   = false

local function debugLog(...)
    if not AUTOSELL_LOG then return end
    warn("[DEBUG]", ...)
end

local function runeLog(...)
    if not AUTOSELL_LOG then return end
    print("[AutoSell]", ...)
end

local function runeDebug(...)
    if not AUTOSELL_LOG or not RUNE_DEBUG_VERBOSE then return end
    print("[AutoSell][RuneDebug]", ...)
end

----------------------------------------------------------------
-- DATA & MAPS
----------------------------------------------------------------
local EssenceRarityMap = {
    ["Tiny Essence"]      = "Common",
    ["Small Essence"]     = "Common",
    ["Medium Essence"]    = "Uncommon",
    ["Large Essence"]     = "Uncommon",
    ["Greater Essence"]   = "Rare",
    ["Superior Essence"]  = "Epic",
    ["Epic Essence"]      = "Epic",
    ["Legendary Essence"] = "Legendary",
    ["Mythical Essence"]  = "Mythical",
}

local OreRarityMap = {
    ["Aether Lotus"] = "Rare",
    ["Aetherit"] = "Rare",
    ["Aite"] = "Epic",
    ["Amethyst"] = "Rare",
    ["Aqujade"] = "Epic",
    ["Arcane Crystal"] = "Mythical",
    ["Bananite"] = "Uncommon",
    ["Blue Crystal"] = "Epic",
    ["Boneite"] = "Rare",
    ["Cardboardite"] = "Common",
    ["Ceyite"] = "Exotic",
    ["Cobalt"] = "Uncommon",
    ["Coinite"] = "Legendary", -- Updated from Epic
    ["Copper"] = "Common",
    ["Crimson Crystal"] = "Epic",
    ["Crimsonite"] = "Epic",
    ["Cryptex"] = "Epic",
    ["Cuprite"] = "Epic",
    ["Dark Boneite"] = "Rare",
    ["Darkryte"] = "Mythical",
    ["Demonite"] = "Mythical",
    ["Diamond"] = "Rare",
    ["Duranite"] = "Mythical", -- New
    ["Emerald"] = "Epic",
    ["Etherealite"] = "Mythical",
    ["Evil Eye"] = "Mythical", -- New
    ["Eye Ore"] = "Legendary",
    ["Fichillium"] = "Relic",
    ["Fireite"] = "Legendary",
    ["Frogite"] = "Epic", -- New
    ["Frost Fossil"] = "Epic",
    ["Galaxite"] = "Divine",
    ["Galestor"] = "Epic",
    ["Gargantuan"] = "Divine",
    ["Gold"] = "Uncommon",
    ["Graphite"] = "Rare",
    ["Grass"] = "Common",
    ["Green Crystal"] = "Epic",
    ["Gulabite"] = "Legendary", -- New
    ["Heart Of The Island"] = "Relic", -- New
    ["Heavenite"] = "Divine",
    ["Iceite"] = "Mythical",
    ["Iron"] = "Common",
    ["Jade"] = "Rare",
    ["Lapis Lazuli"] = "Uncommon",
    ["Larimar"] = "Epic",
    ["Lgarite"] = "Rare",
    ["Lightite"] = "Legendary",
    ["Magenta Crystal"] = "Epic",
    ["Magmaite"] = "Legendary",
    ["Malachite"] = "Epic",
    ["Marblite"] = "Exotic",
    ["Mistvein"] = "Rare",
    ["Moltenfrost"] = "Epic",
    ["Moon Stone"] = "Legendary", -- New
    ["Mosasaursit"] = "Exotic",
    ["Mushroomite"] = "Rare",
    ["Mythril"] = "Legendary",
    ["Neurotite"] = "Epic",
    ["Obsidian"] = "Epic",
    ["Orange Crystal"] = "Epic",
    ["Platinum"] = "Rare",
    ["Poopite"] = "Epic",
    ["Pumice"] = "Rare",
    ["Quartz"] = "Rare",
    ["Rainbow Crystal"] = "Legendary",
    ["Rivalite"] = "Epic",
    ["Ruby"] = "Epic",
    ["Sanctis"] = "Legendary",
    ["Sand Stone"] = "Common",
    ["Sapphire"] = "Rare",
    ["Scheelite"] = "Rare",
    ["Silver"] = "Uncommon",
    ["Slimite"] = "Epic",
    ["Snowite"] = "Legendary",
    ["Starite"] = "Mythical",
    ["Stolen Heart"] = "Divine", -- New
    ["Stone"] = "Common",
    ["Sulfur"] = "Uncommon",
    ["Suryafal"] = "Relic",
    ["Tide Carve"] = "Epic",
    ["Tin"] = "Uncommon",
    ["Titanium"] = "Uncommon",
    ["Topaz"] = "Rare",
    ["Tungsten"] = "Common",
    ["Uranium"] = "Legendary",
    ["Vanegos"] = "Rare",
    ["Velchire"] = "Legendary",
    ["Voidfractal"] = "Rare",
    ["Voidstar"] = "Legendary",
    ["Volcanic Rock"] = "Rare",
    ["Vooite"] = "Exotic",
    ["Zephyte"] = "Rare",
}

local RuneValues = {
    "Miner Shard", "Blast Chip", "Flame Spark", "Frost Speck", "Briar Notch",
    "Rage Mark", "Drain Edge", "Ward Patch", "Venom Crumb",
}

----------------------------------------------------------------
-- CONFIG LOADING
----------------------------------------------------------------
local function makeDefaultConfig()
    return {
        version         = 1,
        ores            = {},
        oreRarities     = {},
        essence         = {},
        essenceRarities = {},
        runes           = {},
        runeTraits      = {},
    }
end

local function loadAutoSellConfig()
    if not (isfile and readfile) or not isfile(AutoSellConfigFile) then
        return makeDefaultConfig()
    end

    local ok, decoded = pcall(function()
        return Services.HttpService:JSONDecode(readfile(AutoSellConfigFile))
    end)

    if not ok or type(decoded) ~= "table" then
        return makeDefaultConfig()
    end

    decoded.runeTraits = decoded.runeTraits or {}
    for _, rule in pairs(decoded.runeTraits) do
        if type(rule) == "table" then
            rule.enabled = rule.enabled == true
            rule.params  = rule.params or {}
        end
    end

    return decoded
end

AutoSellConfig = loadAutoSellConfig()

----------------------------------------------------------------
-- KNIT HELPERS (NON-BLOCKING)
----------------------------------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared            = ReplicatedStorage:WaitForChild("Shared")
local Knit              = require(Shared:WaitForChild("Packages"):WaitForChild("Knit"))

local KnitPlayerController
local lastKnitWarn = 0

local function tryGetKnitPlayerController()
    if KnitPlayerController then
        return KnitPlayerController
    end

    local ok, controller = pcall(function()
        return Knit.GetController("PlayerController")
    end)

    if not ok or not controller then
        local now = os.clock()
        if now - lastKnitWarn > 10 then
            lastKnitWarn = now
            warn("[Cerberus] PlayerController not ready yet (Knit).")
        end
        return nil
    end

    KnitPlayerController = controller
    return KnitPlayerController
end

----------------------------------------------------------------
-- RUNE ANALYSIS & PROTECTION LOGIC
----------------------------------------------------------------
local RuneRuntime = {
    Replica         = nil,
    Misc            = nil,
    protectedRunes  = {},
    lastScan        = 0,
    protectionReady = false,
}

local lastScanFailWarn = 0

local function getReplicaMisc()
    -- reuse cached Misc if we have it
    if RuneRuntime.Misc and RuneRuntime.Replica then
        return RuneRuntime.Misc
    end

    local controller = tryGetKnitPlayerController()
    if not controller then
        return nil
    end

    local replica = rawget(controller, "Replica")
   if replica
        and replica.Data
        and replica.Data.Inventory
        and replica.Data.Inventory.Misc
    then
        RuneRuntime.Replica = replica
        RuneRuntime.Misc    = replica.Data.Inventory.Misc
        return RuneRuntime.Misc
    end

    -- throttle the SCAN FAIL spam
    local now = os.clock()
    if now - lastScanFailWarn > 10 then
        lastScanFailWarn = now
        debugLog("SCAN FAIL: Could not find Replica.Data.Inventory.Misc")
    end

    return nil
end

-- cache the Runes data module once
local RunesModule = nil
local runesModuleFailed = false

local function getRunesModule()
    if runesModuleFailed then return nil end
    if RunesModule ~= nil then return RunesModule end

    local ok, mod = pcall(function()
        return require(Shared:WaitForChild("Data"):WaitForChild("Runes"))
    end)

    if not ok or not mod then
        runesModuleFailed = true
        warn("[Cerberus] Runes module is unavailable (Game Error). Skipping rune calculation.")
        return nil
    end

    RunesModule = mod
    return RunesModule
end

-- returns: statsList (array of {name,value}), statsByName map
local function getNumericStats(trait)
    local Runes = getRunesModule()
    if not Runes then
        return {}, {}
    end

    local adjusted
    local ok = pcall(function()
        adjusted = Runes:AdjustTraitData(trait)
    end)
    if not ok or type(adjusted) ~= "table" then
        adjusted = trait
    end

    local statsList   = {}
    local statsByName = {}

    for k, v in pairs(adjusted) do
        if type(v) == "number" then
            local lk = string.lower(k)
            if not lk:find("tier") and not lk:find("level") and k ~= "Stackable" and k ~= "UseLowest" then
                table.insert(statsList, { name = k, value = v })
                statsByName[k] = v
            end
        end
    end

    table.sort(statsList, function(a, b)
        return a.name < b.name
    end)

    return statsList, statsByName
end

-- configRule.params is an array; index 1..N maps to the Nth numeric stat in statsList
local function evaluateTrait(traitId, traitData, configRule, runeUUID, runeName)
    if not configRule or not configRule.enabled then
        return false
    end

    local statsList, statsByName = getNumericStats(traitData)

    runeDebug(("=== Trait check: %s on rune %s (%s) ===")
        :format(tostring(traitId), tostring(runeName or "?"), tostring(runeUUID or "?")))

    if #statsList == 0 then
        runeDebug("  No numeric stats found for this trait; cannot evaluate; result = NOT PROTECTED")
        return false
    end

    for i, s in ipairs(statsList) do
        runeDebug(("  Stat[%d]: %s = %s")
            :format(i, tostring(s.name), tostring(s.value)))
    end

    local params = configRule.params or {}
    if #params == 0 then
        runeDebug("  Rule has no params; treating as 'protect any presence of this trait'.")
        return true
    end

    local allParamsPass = true

    for i, param in ipairs(params) do
        local statObj = statsList[i]
        local req     = tonumber(param.value) or 0
        local dir     = (param.direction == "below") and "below" or "above"

        if not statObj then
            runeDebug(("  Param[%d]: target %s %s but NO STAT at this index → FAIL")
                :format(i, dir, tostring(req)))
            allParamsPass = false
        else
            local val    = tonumber(statObj.value) or 0
            local passed = (dir == "below" and val <= req) or (val >= req)

            runeDebug(("  Param[%d]: %s %s %s (stat=%s) → %s")
                :format(
                    i,
                    statObj.name,
                    (dir == "below") and "<=" or ">=",
                    tostring(req),
                    tostring(val),
                    passed and "PASS" or "FAIL"
                ))

            if not passed then
                allParamsPass = false
            end
        end
    end

    runeDebug(("  FINAL RESULT for trait %s = %s")
        :format(tostring(traitId), allParamsPass and "PROTECT" or "NO PROTECT"))

    return allParamsPass
end

local function scanRunesForProtection()
    local misc = getReplicaMisc()
    if not misc then
        RuneRuntime.protectionReady = false
        return
    end

    RuneRuntime.protectionReady = true
    table.clear(RuneRuntime.protectedRunes)

    for k, item in pairs(misc) do
        local uuid

        if type(item) == "table" then
            if item.GUID then
                uuid = item.GUID
            elseif item.UUID then
                uuid = item.UUID
            elseif item.UniqueId then
                uuid = item.UniqueId
            elseif item.id then
                uuid = item.id
            end
        end

        if not uuid and type(k) == "string" and #k > 10 then
            uuid = k
        end

        local isRune   = item.Traits and #item.Traits > 0
        local itemName = item.Id or item.Name or "Unknown"

        if isRune then
            local isProtected = false

            for _, trait in ipairs(item.Traits) do
                local traitId = trait.Id
                local rule    = AutoSellConfig.runeTraits[traitId]

                if rule and rule.enabled then
                    if evaluateTrait(traitId, trait, rule, uuid, itemName) then
                        isProtected = true
                        break
                    end
                end
            end

            if isProtected and uuid then
                RuneRuntime.protectedRunes[uuid] = true
                runeLog("PROTECTING: " .. itemName .. " | GUID: " .. tostring(uuid))
            elseif isProtected and not uuid then
                runeLog("CRITICAL: Rune " .. itemName .. " passed checks but HAS NO GUID TO SAVE.")
            end
        end
    end

    RuneRuntime.lastScan = os.clock()
end

----------------------------------------------------------------
-- HELPER: STASH READING
----------------------------------------------------------------
local function isFavorited(frame)
    local ok, val = pcall(function()
        return frame:GetAttribute("IsFavorited")
    end)
    return ok and val == true
end

local function getStashItems()
    local player = game:GetService("Players").LocalPlayer
    local stash = player.PlayerGui.Menu.Frame.Frame.Menus.Stash.Background
    return stash:GetChildren()
end

----------------------------------------------------------------
-- MAIN LOOP / UI
----------------------------------------------------------------
local isRunning = false
local isGamepassSell = false -- Toggle State

AutoSellGroupbox:AddToggle("AutoSell_Enable", {
    Text     = "Enable Auto Sell",
    Default  = false,
    Callback = function(val)
        isRunning = val
        if val then
            scanRunesForProtection()
        end
    end,
})

AutoSellGroupbox:AddToggle("GamepassSell_Enable", {
    Text     = "Gamepass Sell",
    Default  = false,
    Tooltip  = "Use this if you have the Sell Anywhere gamepass",
    Callback = function(val)
        isGamepassSell = val
    end,
})

AutoSellGroupbox:AddButton({
    Text = "Open Config Editor",
    Func = function()
        loadstring(Dependencies.autoSellEditor)()
    end,
})

AutoSellGroupbox:AddButton({
    Text = "Reload Config",
    Func = function()
        AutoSellConfig = loadAutoSellConfig()
    end,
})

task.spawn(function()
    while true do
        task.wait(2)
        if not isRunning then
            continue
        end

        scanRunesForProtection()

        local basket = {}
        local bg

        pcall(function()
            bg = getStashItems()
        end)

        if not bg then
            continue
        end

        for _, itemFrame in ipairs(bg) do
            if itemFrame:IsA("Frame")
                and itemFrame:FindFirstChild("Main")
                and not isFavorited(itemFrame)
            then
                -- GUI DATA
                local itemUUID  = itemFrame.Name
                local nameLabel = itemFrame.Main:FindFirstChild("ItemName")
                local itemName  = nameLabel and nameLabel.Text or "Unknown"

                local qtyLabel  = itemFrame.Main:FindFirstChild("Quantity")
                local amount    = 1
                if qtyLabel then
                    local txt = qtyLabel.Text:gsub("%D+", "")
                    amount = tonumber(txt) or 1
                end

                local rule      = nil
                local category  = "None"
                local cleanName = itemName:gsub("%s*%[T%d+%]", "")

                -- CATEGORY DETECTION
                if OreRarityMap[itemName] then
                    category = "Ore"
                    rule = AutoSellConfig.ores[itemName]
                        or AutoSellConfig.oreRarities[OreRarityMap[itemName]]

                elseif EssenceRarityMap[itemName] then
                    category = "Essence"
                    rule = AutoSellConfig.essence[itemName]
                        or AutoSellConfig.essenceRarities[EssenceRarityMap[itemName]]

                elseif table.find(RuneValues, cleanName)
                    or string.find(itemName, "Shard")
                    or string.find(itemName, "Chip")
                then
                    category = "Rune"

                    local isProt = false

                    if not RuneRuntime.protectionReady then
                        -- HARD SAFETY: never sell runes if we couldn't scan traits
                        isProt = true
                        runeLog("KEEPING (Scanner not ready): " .. itemName .. " (" .. itemUUID .. ")")
                    else
                        isProt = RuneRuntime.protectedRunes[itemUUID] == true
                    end

                    if isProt then
                        category = "Rune_Protected"
                        runeLog("KEEPING (Protected): " .. itemName .. " (" .. itemUUID .. ")")
                    else
                        rule = AutoSellConfig.runes[cleanName]
                    end
                end

                -- ADD TO BASKET
                if category == "Rune_Protected" then
                    -- skip
                elseif rule and rule.enabled then
                    local keepAmount = tonumber(rule.threshold) or 0
                    local toSell     = amount - keepAmount

                    if toSell > 0 then
                        basket[itemUUID] = (basket[itemUUID] or 0) + toSell
                        if category == "Rune" then
                            runeLog("QUEUED TO SELL: " .. itemName .. " | GUID: " .. itemUUID)
                        end
                    end
                end
            end
        end

        -- EXECUTE SELL
        if next(basket) then
            if DRY_RUN then
                warn("[DRY RUN] Would have sold items:", basket)
                warn("[DRY RUN] Set DRY_RUN = false at top of script to enable real selling.")
            else
                local ok, err = pcall(function()
                    if isGamepassSell then
                        -- Uses the SellAnywhere remote if toggle is ON
                        SellAnywhereRF:InvokeServer(basket)
                    else
                        -- Uses the standard NPC dialogue remote
                        DialogueRunCommandRF:InvokeServer("SellConfirm", { Basket = basket })
                    end
                end)
                if not ok then
                    warn("[AutoSell] Sell failed:", err)
                end
            end
            task.wait(2)
        end
    end
end)

-- ==== QUICK ROLLS ==== --
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer       = Players.LocalPlayer

local RaceListFolder    = LocalPlayer:WaitForChild("PlayerGui")
    :WaitForChild("Menu")
    :WaitForChild("Frame")
    :WaitForChild("Frame")
    :WaitForChild("Menus")
    :WaitForChild("Shop")
    :WaitForChild("Background")
    :WaitForChild("Reroll")
    :WaitForChild("RaceMain")
    :WaitForChild("RaceList")

local AllRaces          = {}
local AllRacesSet       = {}

for _, child in ipairs(RaceListFolder:GetChildren()) do
    if child.Name ~= "UIListLayout" and child.Name and child.Name ~= "" then
        table.insert(AllRaces, child.Name)
        AllRacesSet[child.Name] = true
    end
end

table.sort(AllRaces)

local RerollRemote = ReplicatedStorage
    :WaitForChild("Shared")
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("RaceService")
    :WaitForChild("RF")
    :WaitForChild("Reroll")

local function notify(msg, t)
    t = t or 3
    if Library and Library.Notify then
        Library:Notify(msg, t)
    else
        print("[REROLL]", msg)
    end
end

local RerollGroupbox = Tabs.Main:AddRightGroupbox("Race Reroll", "dice-5")

local SelectedRaces = {}

local RaceDropdown = RerollGroupbox:AddDropdown("RaceReroll_Targets", {
    Text     = "Target Races",
    Values   = AllRaces,
    Default  = {},
    Multi    = true,
    Tooltip  = "Reroll until you hit one of these races.",
    Callback = function(selectedTable)
        SelectedRaces = {}
        for name, isOn in pairs(selectedTable) do
            if isOn then
                SelectedRaces[name] = true
            end
        end
    end,
})

print("check 7")

-- Extract the race name from whatever the server returns
local function extractRaceName(result)
    if typeof(result) == "string" then
        return result
    end

    if typeof(result) == "table" then
        -- Try several common patterns
        if result.Race then
            return tostring(result.Race)
        elseif result.race then
            return tostring(result.race)
        elseif result.Name then
            return tostring(result.Name)
        elseif result[1] then
            return tostring(result[1])
        end
    end

    return tostring(result)
end

local isRerolling = false

RerollGroupbox:AddButton({
    Text = "Quick Roll",
    Func = function()
        if isRerolling then
            notify("Already rerolling, please wait...", 3)
            return
        end

        if next(SelectedRaces) == nil then
            notify("No target races selected!", 4)
            return
        end

        isRerolling = true

        task.spawn(function()
            while isRerolling do
                local success, result = pcall(function()
                    return RerollRemote:InvokeServer()
                end)

                if not success then
                    notify("Reroll failed: " .. tostring(result), 4)
                    break
                end

                local raceName = extractRaceName(result)
                notify("Rolled race: " .. raceName, 3)

                if SelectedRaces[raceName] then
                    notify("Desired race rolled: " .. raceName, 5)
                    break
                end
                if not AllRacesSet[raceName] then
                    notify("Out of rerolls.", 5)
                    break
                end

                task.wait(0.15)
            end

            isRerolling = false
        end)
    end,
})


-- ==================== --
-- ==== PLAYER TAB ==== --
-- ==================== --

-- ==== MOVEMENT ==== --
local MovementPanel = (loadstring(Dependencies.movementSrc)())(setmetatable(
    { Services = Services, Tabs = Tabs, References = References, Library = Library, Options = Options, Toggles = Toggles },
    { __index = _G }))

-- ==== PLAYER UTILS ==== --
local UtilsGroup = Tabs.Player:AddRightGroupbox("Utils", "lightbulb")

-- ==== NO CLIP ==== --
UtilsGroup:AddToggle("NoclipEnabled", {
    Text = "NoClip",
    Default = false,
    Tooltip = "Walk through any structures",
}):AddKeyPicker("NoclipKey", {
    Default = "N",
    SyncToggleState = true,
    Mode = "Toggle",
})

Toggles.NoclipEnabled:OnChanged(function()
    if Toggles.NoclipEnabled.Value then
        startNoclip()
        Library:Notify("NoClip enabled.", 2)
    else
        stopNoclip()
        Library:Notify("NoClip disabled.", 2)
    end
end)

-- ==== DESYNC ==== --
UtilsGroup:AddToggle("DesyncEnabled", {
    Text = "Desync [MACOS]",
    Default = false,
    Tooltip = "Perform movements and actions client-side without server recognition until re-synced",
}):AddKeyPicker("DesyncKey", {
    Default = nil,
    SyncToggleState = true,
    Mode = "Toggle",
})

Toggles.DesyncEnabled:OnChanged(function()
    if type(server_desync) == "function" then
        server_desync(Toggles.DesyncEnabled.Value)
        if Toggles.DesyncEnabled.Value then
            Library:Notify("Server Desync enabled.", 2)
        else
            Library:Notify("Server Desync disabled.", 2)
        end
    else
        Library:Notify(
        "This function is not available in your executor. If you have an executor with FFlags capabilties, then use the button below.",
            3)
    end
end)

-- ==== FFLAGS DESYNC ==== --
local function quickReset()
    local player = Services.Players.LocalPlayer
    if not player then return end

    local char = player.Character
    local hum  = char and char:FindFirstChildWhichIsA("Humanoid")

    if replicatesignal and player.Kill then
        pcall(function()
            replicatesignal(player.Kill)
        end)
    elseif hum then
        pcall(function()
            hum:ChangeState(Enum.HumanoidStateType.Dead)
        end)
    elseif char then
        pcall(function()
            char:BreakJoints()
        end)
    end
end

local function resolveSetFFlag()
    if typeof(setfflag) == "function" then
        return true
    end

    if typeof(getgenv) == "function" then
        local g = getgenv()
        if g and typeof(g.setfflag) == "function" then
            setfflag = g.setfflag
            return true
        end
    end

    if typeof(getrenv) == "function" then
        local r = getrenv()
        if r and typeof(r.setfflag) == "function" then
            setfflag = r.setfflag
            return true
        end
    end

    return false
end

local function applyFFlagOnly()
    if not resolveSetFFlag() then
        Library:Notify("[Desync FFLAGS] Your executor does NOT expose setfflag; cannot re-apply.", 5)
        return false
    end

    local success, err = pcall(function()
        setfflag("NextGenReplicatorEnabledWrite4", "true")
    end)

    if success then
        Library:Notify("[Desync FFLAGS] Re-applied after respawn.", 3)
    else
        Library:Notify("[Desync FFLAGS] Re-apply failed: " .. tostring(err), 5)
    end

    return success
end

-- FIRST-TIME: kill once, then set flag
local function applyFFlagDesyncInitial()
    local player = Services.Players.LocalPlayer
    if not player then return false end

    if not resolveSetFFlag() then
        if Library and Library.Notify then
            Library:Notify(
                "[Desync FFLAGS] Your executor does NOT expose setfflag; cannot apply.",
                5
            )
        end
        return false
    end

    if Library and Library.Notify then
        Library:Notify("Dying is intentional (FFLAG desync).", 2)
    end

    quickReset()

    task.delay(1, function()
        local success, err = pcall(function()
            setfflag("NextGenReplicatorEnabledWrite4", "true")
        end)

        if Library and Library.Notify then
            if success then
                Library:Notify("[Desync FFLAGS] Initial apply success.", 3)
            else
                Library:Notify("[Desync FFLAGS] Initial apply failed: " .. tostring(err), 5)
            end
        end
    end)

    return true
end

local AutoDesyncFFlags = {
    Enabled  = false,
    CharConn = nil,
    Busy     = false, -- simple guard so we don't spam on multi CharacterAdded
}

UtilsGroup:AddToggle("AutoDesyncFFlags", {
    Text    = "Auto Desync [FFLAGS]",
    Default = false,
    Tooltip = "Apply FFLAG desync once, then re-apply after each respawn.",
}):AddKeyPicker("AutoDesyncFFlagsKey", {
    Default         = nil,
    SyncToggleState = true,
    Mode            = "Toggle",
})

Toggles.AutoDesyncFFlags:OnChanged(function(on)
    AutoDesyncFFlags.Enabled = on
    local player = Services.Players.LocalPlayer

    -- cleanup old connection
    if AutoDesyncFFlags.CharConn then
        AutoDesyncFFlags.CharConn:Disconnect()
        AutoDesyncFFlags.CharConn = nil
    end

    if not on then
        if Library and Library.Notify then
            Library:Notify(
                "Auto Desync [FFLAGS] disabled. You may need to restart Roblox to fully clear FFlags.",
                4
            )
        end
        return
    end

    local ok = applyFFlagDesyncInitial()
    if not ok then
        if Toggles.AutoDesyncFFlags and Toggles.AutoDesyncFFlags.SetValue then
            Toggles.AutoDesyncFFlags:SetValue(false)
        end
        AutoDesyncFFlags.Enabled = false
        return
    end

    if player then
        AutoDesyncFFlags.CharConn = player.CharacterAdded:Connect(function(char)
            if not AutoDesyncFFlags.Enabled then return end
            if AutoDesyncFFlags.Busy then return end
            AutoDesyncFFlags.Busy = true

            local hum = char:FindFirstChildWhichIsA("Humanoid") or char:WaitForChild("Humanoid", 10)
            if hum then
                task.wait(0.75)
                if AutoDesyncFFlags.Enabled then
                    applyFFlagOnly()
                end
            end

            AutoDesyncFFlags.Busy = false
        end)
    end
end)

-- ==== AUTO-USE TOOLS ==== --
local function getTool()
    if not References.character or not References.character.Parent then return nil end
    for _, inst in ipairs(References.character:GetChildren()) do
        if inst:IsA("Tool") then
            return inst
        end
    end
end

UtilsGroup:AddToggle("AutoUseTool", {
    Text = "AutoUse Tool",
    Default = false,
    Tooltip = "Automatically activates your equipped tool",
}):AddKeyPicker("AutoUseKey", {
    Default = nil,
    SyncToggleState = true,
    Mode = "Toggle",
})

local autoToolLastOn = false

local autoUseConn = nil
autoUseConn = Services.RunService.Heartbeat:Connect(function()
    local on = (Toggles.AutoUseTool and Toggles.AutoUseTool.Value) == true
    if on ~= autoToolLastOn then
        autoToolLastOn = on
        Library:Notify(on and "AutoUse enabled." or "AutoUse disabled.", 2)
        local tool = getTool()
        if tool then
            pcall(function()
                if on then tool:Activate() else tool:Deactivate() end
            end)
        end
    end
    if on then
        local tool = getTool()
        if tool then
            pcall(function() tool:Activate() end)
        end
    end
end)

-- ==== ZOOM ==== --
local Zoom = { on = false, conn = nil, origFov = nil, strength = 2 }

local function applyZoom()
    local cam = References.camera or workspace.CurrentCamera
    if not (cam and Zoom.origFov) then return end
    cam.FieldOfView = math.clamp(Zoom.origFov / math.max(0.1, Zoom.strength), 10, 120)
end

local function stopZoom()
    Zoom.on = false
    if Zoom.conn then
        pcall(function() Zoom.conn:Disconnect() end); Zoom.conn = nil
    end
    local cam = References.camera or workspace.CurrentCamera
    if cam and Zoom.origFov then pcall(function() cam.FieldOfView = Zoom.origFov end) end
end

local tg = UtilsGroup:AddToggle("ZOOM_Enable", {
    Text = "Zoom",
    Default = false,
    Callback = function(on)
        local cam = References.camera or workspace.CurrentCamera
        if not cam then
            Library:Notify("Camera not ready.", 3); if tg.SetValue then tg:SetValue(false) end; return
        end
        if on then
            if not Zoom.origFov then Zoom.origFov = cam.FieldOfView end
            Zoom.on = true; applyZoom()
            if not Zoom.conn then
                Zoom.conn = Services.RunService.RenderStepped:Connect(function() if Zoom.on then applyZoom() end end)
            end
        else
            stopZoom()
        end
    end
}):AddKeyPicker("ZoomKey", {
    Default = nil,
    SyncToggleState = true,
    Mode = "Toggle",
})

UtilsGroup:AddSlider("ZOOM_Strength", {
    Text = "Zoom Strength",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(v)
        Zoom.strength = v; if Zoom.on then applyZoom() end
    end
})

-- ==== PERFORMANCE MODE ==== --
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
        GlobalShadows = Services.Lighting.GlobalShadows,
        Ambient       = Services.Lighting.Ambient,
        Brightness    = Services.Lighting.Brightness,
        FogEnd        = Services.Lighting.FogEnd,
        FogStart      = Services.Lighting.FogStart,
        Effects       = {},
        Terrain       = {},
    }
    for _, inst in ipairs(Services.Lighting:GetDescendants()) do
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
        local ok, dec                       = pcall(function() return terr.Decoration end)
        if ok and type(dec) == "boolean" then
            originals.Terrain.Decoration = dec
        end
    end
end

local function perfOn()
    snapshot()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Services.Lighting.GlobalShadows   = false
    Services.Lighting.Ambient         = Color3.new(0.3, 0.3, 0.3)
    Services.Lighting.Brightness      = 1
    Services.Lighting.FogEnd          = 1e10
    Services.Lighting.FogStart        = 1e10
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
            if d.Enabled then
                d:SetAttribute("PerfWasEnabled", true); d.Enabled = false
            end
        end
    end
end

local function perfOff()
    if not originals then return end
    settings().Rendering.QualityLevel = originals.QualityLevel
    Services.Lighting.GlobalShadows   = originals.GlobalShadows
    Services.Lighting.Ambient         = originals.Ambient
    Services.Lighting.Brightness      = originals.Brightness
    Services.Lighting.FogEnd          = originals.FogEnd
    Services.Lighting.FogStart        = originals.FogStart

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

-- ==== MOD REACTS ==== --
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
            if References.player and References.player.Parent then
                Services.TeleportService:Teleport(game.PlaceId, References.player)
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

-- Anti-AFK
UtilsGroup:AddToggle("AntiAFK_Toggle", {
    Text = "Anti-AFK",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if not getgenv()._AntiAFK_Conn then
                getgenv()._AntiAFK_Conn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    game:GetService("VirtualUser"):CaptureController()
                    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                end)
            end
        else
            if getgenv()._AntiAFK_Conn then
                getgenv()._AntiAFK_Conn:Disconnect()
                getgenv()._AntiAFK_Conn = nil
            end
        end
    end
})

-- ==== FPS Unlocker ==== --
UtilsGroup:AddInput("UTILS_FPSCap", {
    Text = "FPS Cap",
    Placeholder = "Enter target FPS",
    Default = "60",
    Numeric = true,
    Finished = true,
    Tooltip = "Set a custom FPS limit",
    Callback = function(val)
        local fps = tonumber(val)
        if fps and fps > 0 then
            if setfpscap then
                setfpscap(fps)
                Library:Notify(("FPS cap set to %d"):format(fps), 3)
            else
                Library:Notify("FPS unlocker not supported in this executor.", 3)
            end
        else
            Library:Notify("Please enter a positive number for FPS.", 3)
        end
    end
})

UtilsGroup:AddButton({
    Text = "Quick Reset",
    Func = function()
        quickReset()
        if Library and Library.Notify then
            Library:Notify("Quick reset triggered.", 2)
        end
    end,
})

-- ==== AUTO KICK ==== --
local AutoKick = {
    enabled   = false,
    threshold = 12,
    conn      = nil,
}

local function getPlayerCount()
    return #Services.Players:GetPlayers()
end

local function performAutoKick(currentCount)
    AutoKick.enabled = false
    if Toggles.AutoKickOnPlayerCount and Toggles.AutoKickOnPlayerCount.SetValue then
        Toggles.AutoKickOnPlayerCount:SetValue(false)
    end
    if Library and Library.Notify then
        Library:Notify(
            string.format("Auto Kick: player count %d >= %d, kicking...", currentCount, AutoKick.threshold),
            4
        )
    end
    local lp = References.player or Services.Players.LocalPlayer
    if lp then
        pcall(function()
            lp:Kick(string.format(
                "AutoKick triggered: Server reached %d players (limit %d).",
                currentCount,
                AutoKick.threshold
            ))
        end)
    end
end

local function checkAutoKick()
    if not AutoKick.enabled then return end
    local count = getPlayerCount()
    if count >= AutoKick.threshold then
        performAutoKick(count)
    end
end

UtilsGroup:AddToggle("AutoKickOnPlayerCount", {
    Text     = "Auto Kick",
    Default  = false,
    Tooltip  = "Kick yourself if the number of players reaches the limit below",
    Callback = function(on)
        AutoKick.enabled = on

        if AutoKick.conn then
            AutoKick.conn:Disconnect()
            AutoKick.conn = nil
        end

        if on then
            AutoKick.conn = Services.Players.PlayerAdded:Connect(function()
                checkAutoKick()
            end)
            task.defer(checkAutoKick)
        end
    end
})

UtilsGroup:AddSlider("AutoKickPlayerThreshold", {
    Text     = "Player Limit",
    Default  = 12,
    Min      = 2,
    Max      = 24,
    Rounding = 0,
    Callback = function(v)
        v = math.floor(v)
        if v < 2 then v = 2 end
        AutoKick.threshold = v
    end
})

-- ==== VISUAL PLAYER UTILS ==== --
loadstring(Dependencies.visualsSrc)()(Services, Tabs, References, Toggles, Options, Library)

-- ================= --
-- ==== ESP TAB ==== --
-- ================= --

-- xeno warning
if isXeno and Tabs.ESP and Tabs.ESP.UpdateWarningBox then
    Tabs.ESP:UpdateWarningBox({
        Visible = true,
        Title   = "ESP Unsupported",
        Text    = "Xeno detected. <b>ESP will not work</b> due to weak drawing API.",
    })
end

-- ==== ESP [SENSE POWDERED] ==== --
local SENSE

local ESP_CONFIG = {
    universal = {
        textSize     = { default = 13, min = 10, max = 28 },
        tracerOrigin = { default = "Bottom", values = { "Bottom", "Middle", "Top" } },
        limitRange   = { default = false },
        maxRange     = { default = 150, min = 50, max = 2000 },
    },

    groups = {
        {
            key = "Players",
            title = "Player ESP",
            icon = "users",
            type = "players",
            sideDefault = "Enemy",
            features = {
                box       = { color = Color3.fromRGB(255, 60, 60), outline = false, fill = false, fillAlpha = 35 },
                name      = { color = Color3.new(1, 1, 1) },
                distance  = { color = Color3.new(1, 1, 1) },
                healthBar = true,
                weapon    = false,
                tracer    = { color = Color3.fromRGB(255, 60, 60) },
                chams     = true,
            }
        },

        {
            key = "NPCs",
            title = "NPC ESP",
            icon = "user-cog",
            type = "sense_instances",
            subtype = "humanoid",
            selector = function(root)
                local list, nameSet = {}, {}
                for _, plr in ipairs(Services.Players:GetPlayers()) do
                    nameSet[plr.Name] = true
                end
                for _, m in ipairs(root:GetDescendants()) do
                    if m:IsA("Model")
                        and m:FindFirstChildOfClass("Humanoid")
                        and not nameSet[m.Name]
                    then
                        table.insert(list, m)
                    end
                end
                return list
            end,
            features = {
                box       = { color = Color3.fromRGB(255, 255, 0), outline = true, fill = false, fillAlpha = 25 },
                name      = { color = Color3.new(1, 1, 1) },
                distance  = { color = Color3.new(1, 1, 1) },
                tracer    = { color = Color3.fromRGB(255, 255, 0) },
                healthBar = true,
                chams     = true,
            }
        },
    }
}

local function patchSense()
    if not SENSE or SENSE.__CerberusPatched then return end
    SENSE.__CerberusPatched = true

    local oldGetCharacter   = SENSE.getCharacter
    local oldGetHealth      = SENSE.getHealth
    local function resolveCharacter(entity)
        if typeof(entity) ~= "Instance" then
            return nil
        end

        local char

        if entity:IsA("Player") then
            char = entity.Character
        elseif entity:IsA("Model") then
            char = entity
        elseif oldGetCharacter then
            local ok, res = pcall(oldGetCharacter, entity)
            if ok then
                char = res
            end
        end

        if not char then
            return nil
        end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return nil
        end

        if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
            return nil
        end

        return char
    end

    function SENSE.getCharacter(entity)
        return resolveCharacter(entity)
    end

    function SENSE.getHealth(entity)
        local char = resolveCharacter(entity)
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            return hum.Health, hum.MaxHealth
        end
        return 0, 0
    end
end

local function pushSharedToSense()
    if not SENSE then return end

    local o                                  = Options.ESP_TracerOrigin.Value

    SENSE.sharedSettings.textSize            = Options.ESP_TextSize.Value
    SENSE.sharedSettings.limitDistance       = Toggles.ESP_LimitRange.Value
    SENSE.sharedSettings.maxDistance         = Options.ESP_MaxRange.Value

    SENSE.teamSettings.enemy.tracerOrigin    = o
    SENSE.teamSettings.friendly.tracerOrigin = o
    if SENSE.instanceSettings then
        SENSE.instanceSettings.tracerOrigin = o
    end
end

local function ensureSense()
    if not SENSE then
        local ok, ctor = pcall(loadstring, Dependencies.senseSrc)
        if ok and type(ctor) == "function" then
            local ok2, mod = pcall(ctor)
            if ok2 and type(mod) == "table" then
                SENSE = mod
            end
        end
    end

    if not SENSE then return false end
    if not SENSE._hasLoaded and SENSE.Load then
        pcall(SENSE.Load)
    end

    patchSense()
    pushSharedToSense()
    return true
end

local function maybeUnloadSense(allOff)
    if not allOff then return end
    if SENSE and SENSE._hasLoaded and SENSE.Unload then
        pcall(SENSE.Unload)
    end
end

-- universal settings
local Uni = Tabs.ESP:AddLeftGroupbox("Universal", "settings")

Uni:AddSlider("ESP_TextSize", {
    Text = "Text Size",
    Default = ESP_CONFIG.universal.textSize.default,
    Min = ESP_CONFIG.universal.textSize.min,
    Max = ESP_CONFIG.universal.textSize.max,
    Rounding = 0
})

Uni:AddDropdown("ESP_TracerOrigin", {
    Text = "Tracer Origin",
    Values = ESP_CONFIG.universal.tracerOrigin.values,
    Default = ESP_CONFIG.universal.tracerOrigin.default
})

Uni:AddToggle("ESP_LimitRange", {
    Text = "Limit Range",
    Default = ESP_CONFIG.universal.limitRange.default
})

Uni:AddSlider("ESP_MaxRange", {
    Text = "Range (studs)",
    Default = ESP_CONFIG.universal.maxRange.default,
    Min = ESP_CONFIG.universal.maxRange.min,
    Max = ESP_CONFIG.universal.maxRange.max,
    Rounding = 0
})

Options.ESP_TextSize:OnChanged(function()
    if ensureSense() then pushSharedToSense() end
end)
Options.ESP_TracerOrigin:OnChanged(function()
    if ensureSense() then pushSharedToSense() end
end)
Toggles.ESP_LimitRange:OnChanged(function()
    if ensureSense() then pushSharedToSense() end
end)
Options.ESP_MaxRange:OnChanged(function()
    if ensureSense() then pushSharedToSense() end
end)

local function safeOnChanged(id, cb)
    local o = Toggles[id] or Options[id]
    if o and o.OnChanged then
        o:OnChanged(cb)
    end
end

-- player esp
local function buildPlayerUI(group)
    local box = Tabs.ESP:AddRightGroupbox(group.title, group.icon or "users")

    box:AddToggle(group.key .. "_Enable", { Text = "Enable " .. group.title, Default = false })
    box:AddDropdown(group.key .. "_Side", {
        Text = "Apply To",
        Values = { "Enemy", "Friendly", "Both" },
        Default = group.sideDefault or "Enemy"
    })

    if group.features.box then
        box:AddToggle(group.key .. "_Box", { Text = "Boxes", Default = true })
            :AddColorPicker(group.key .. "_BoxColor", { Default = group.features.box.color })
        box:AddToggle(group.key .. "_BoxOutline", { Text = "Box Outline", Default = true })
        box:AddToggle(group.key .. "_BoxFill", { Text = "Box Fill", Default = false })
        box:AddSlider(group.key .. "_BoxFillAlpha", {
            Text = "Fill Alpha",
            Default = group.features.box.fillAlpha or 35,
            Min = 0,
            Max = 100
        })
    end
    if group.features.name then
        box:AddToggle(group.key .. "_Name", { Text = "Names", Default = true })
            :AddColorPicker(group.key .. "_NameColor", { Default = group.features.name.color })
    end
    if group.features.distance then
        box:AddToggle(group.key .. "_Distance", { Text = "Distance", Default = false })
            :AddColorPicker(group.key .. "_DistColor", { Default = group.features.distance.color })
    end
    if group.features.healthBar ~= nil then
        box:AddToggle(group.key .. "_HealthBar", { Text = "Health Bar", Default = group.features.healthBar })
    end
    if group.features.weapon ~= nil then
        box:AddToggle(group.key .. "_Weapon", { Text = "Weapon", Default = group.features.weapon })
    end
    if group.features.tracer then
        box:AddToggle(group.key .. "_Tracer", { Text = "Tracer", Default = false })
            :AddColorPicker(group.key .. "_TracerColor", { Default = group.features.tracer.color })
    end
    if group.features.chams ~= nil then
        box:AddToggle(group.key .. "_Chams", { Text = "Chams", Default = group.features.chams })
    end

    local function apply()
        if not ensureSense() then return end

        local side  = Options[group.key .. "_Side"].Value
        local sides = (side == "Both") and { "enemy", "friendly" } or { side:lower() }

        for _, s in ipairs(sides) do
            local t = SENSE.teamSettings[s]
            if t then
                t.enabled       = Toggles[group.key .. "_Enable"].Value
                t.box           = Toggles[group.key .. "_Box"].Value
                t.name          = Toggles[group.key .. "_Name"].Value
                t.distance      = Toggles[group.key .. "_Distance"].Value
                t.healthBar     = Toggles[group.key .. "_HealthBar"].Value
                t.weapon        = Toggles[group.key .. "_Weapon"].Value
                t.tracer        = Toggles[group.key .. "_Tracer"].Value
                t.chams         = Toggles[group.key .. "_Chams"].Value

                t.boxColor      = { Options[group.key .. "_BoxColor"].Value, 1 }
                t.boxFill       = Toggles[group.key .. "_BoxFill"].Value
                t.boxFillColor  = {
                    Options[group.key .. "_BoxColor"].Value,
                    ((Options[group.key .. "_BoxFillAlpha"] and Options[group.key .. "_BoxFillAlpha"].Value) or 0) / 100
                }

                t.nameColor     = { Options[group.key .. "_NameColor"].Value, 1 }
                t.distanceColor = { Options[group.key .. "_DistColor"].Value, 1 }
                t.tracerColor   = { Options[group.key .. "_TracerColor"].Value, 1 }
            end
        end

        pushSharedToSense()
    end

    safeOnChanged(group.key .. "_Enable", apply)
    for _, id in ipairs({
        group.key .. "_Side",
        group.key .. "_Box", group.key .. "_BoxFill", group.key .. "_BoxFillAlpha",
        group.key .. "_Name", group.key .. "_Distance", group.key .. "_HealthBar", group.key .. "_Weapon",
        group.key .. "_Tracer", group.key .. "_Chams",
        group.key .. "_BoxColor", group.key .. "_NameColor", group.key .. "_DistColor", group.key .. "_TracerColor",
    }) do
        safeOnChanged(id, apply)
    end
end

-- instance esp
local SenseInstCache = {}
local SenseInstConn  = {}

local function clearSenseInstances(group)
    if not SENSE then return end
    local cache = SenseInstCache[group.key]
    if not cache then return end

    for inst in pairs(cache) do
        pcall(function()
            if SENSE.RemoveInstance then
                SENSE.RemoveInstance(inst)
            elseif SENSE.RemoveInstances then
                SENSE.RemoveInstances({ inst })
            end
        end)
    end

    SenseInstCache[group.key] = {}
end

local function applySenseInstanceSettings(group)
    if not ensureSense() then return end
    local IS = SENSE.instanceSettings
    if not IS then return end

    local key          = group.key

    IS.enabled         = (Toggles[key .. "_Enable"] and Toggles[key .. "_Enable"].Value) or false

    IS.box             = (Toggles[key .. "_Box"] and Toggles[key .. "_Box"].Value) or false
    IS.boxOutline      = (Toggles[key .. "_BoxOutline"] and Toggles[key .. "_BoxOutline"].Value) or false
    IS.boxFill         = (Toggles[key .. "_BoxFill"] and Toggles[key .. "_BoxFill"].Value) or false
    IS.boxColor        = { (Options[key .. "_BoxColor"] and Options[key .. "_BoxColor"].Value) or
    group.features.box.color, 1 }
    IS.boxOutlineColor = { Color3.new(), 1 }
    IS.boxFillColor    = {
        (Options[key .. "_BoxColor"] and Options[key .. "_BoxColor"].Value) or group.features.box.color,
        ((Options[key .. "_BoxFillAlpha"] and Options[key .. "_BoxFillAlpha"].Value) or (group.features.box.fillAlpha or 0)) /
        100
    }

    IS.name            = (Toggles[key .. "_Name"] and Toggles[key .. "_Name"].Value) or false
    IS.nameColor       = { (Options[key .. "_NameColor"] and Options[key .. "_NameColor"].Value) or Color3.new(1, 1, 1), 1 }

    IS.distance        = (Toggles[key .. "_Distance"] and Toggles[key .. "_Distance"].Value) or false
    IS.distanceColor   = { (Options[key .. "_DistColor"] and Options[key .. "_DistColor"].Value) or Color3.new(1, 1, 1), 1 }

    IS.tracer          = (Toggles[key .. "_Tracer"] and Toggles[key .. "_Tracer"].Value) or false
    IS.tracerColor     = { (Options[key .. "_TracerColor"] and Options[key .. "_TracerColor"].Value) or
    group.features.tracer.color, 1 }
    IS.tracerOutline   = true

    IS.healthBar       = (Toggles[key .. "_HealthBar"] and Toggles[key .. "_HealthBar"].Value) or false
    IS.chams           = (Toggles[key .. "_Chams"] and Toggles[key .. "_Chams"].Value) or false

    pushSharedToSense()
end

local function rescanSenseInstances(group)
    if not ensureSense() then return end
    SenseInstCache[group.key] = SenseInstCache[group.key] or {}
    local cache = SenseInstCache[group.key]

    local list = {}
    local ok, result = pcall(group.selector, Services.Workspace)
    if ok and type(result) == "table" then list = result end

    local seen = {}
    if #list > 0 then
        for _, inst in ipairs(list) do
            if inst and inst.Parent then
                seen[inst] = true
                if not cache[inst] then
                    cache[inst] = true
                    pcall(function()
                        if SENSE.AddInstances then
                            SENSE.AddInstances({ inst })
                        elseif SENSE.AddInstance then
                            SENSE.AddInstance(inst, SENSE.instanceSettings or {})
                        end
                    end)
                end
            end
        end
    end

    for inst in pairs(cache) do
        if not inst.Parent or not seen[inst] then
            cache[inst] = nil
            pcall(function()
                if SENSE.RemoveInstance then
                    SENSE.RemoveInstance(inst)
                elseif SENSE.RemoveInstances then
                    SENSE.RemoveInstances({ inst })
                end
            end)
        end
    end
end

local function startSenseInstances(group)
    if not ensureSense() then return end
    applySenseInstanceSettings(group)
    rescanSenseInstances(group)

    if SenseInstConn[group.key] then
        SenseInstConn[group.key]:Disconnect()
    end

    SenseInstConn[group.key] = Services.RunService.Heartbeat:Connect(function()
        if not (Toggles[group.key .. "_Enable"] and Toggles[group.key .. "_Enable"].Value) then
            return
        end
        if (tick() % 0.5) < 0.02 then
            applySenseInstanceSettings(group)
            rescanSenseInstances(group)
        end
    end)
end

local function stopSenseInstances(group)
    if SenseInstConn[group.key] then
        SenseInstConn[group.key]:Disconnect()
        SenseInstConn[group.key] = nil
    end
    clearSenseInstances(group)
    if ensureSense() and SENSE.instanceSettings then
        SENSE.instanceSettings.enabled = false
    end
end

local function buildSenseInstanceUI(group, side)
    local add = (side == "left") and Tabs.ESP.AddLeftGroupbox or Tabs.ESP.AddRightGroupbox
    local box = add(Tabs.ESP, group.title, group.icon or "user-cog")

    box:AddToggle(group.key .. "_Enable", { Text = "Enable " .. group.title, Default = false })

    if group.features.box then
        box:AddToggle(group.key .. "_Box", { Text = "Boxes", Default = true })
            :AddColorPicker(group.key .. "_BoxColor", { Default = group.features.box.color })
        box:AddToggle(group.key .. "_BoxOutline", { Text = "Box Outline", Default = group.features.box.outline ~= false })
        box:AddToggle(group.key .. "_BoxFill", { Text = "Box Fill", Default = group.features.box.fill or false })
        box:AddSlider(group.key .. "_BoxFillAlpha", {
            Text = "Fill Alpha",
            Default = group.features.box.fillAlpha or 25,
            Min = 0,
            Max = 100
        })
    end
    if group.features.name then
        box:AddToggle(group.key .. "_Name", { Text = "Names", Default = true })
            :AddColorPicker(group.key .. "_NameColor", { Default = group.features.name.color })
    end
    if group.features.distance then
        box:AddToggle(group.key .. "_Distance", { Text = "Distance", Default = true })
            :AddColorPicker(group.key .. "_DistColor", { Default = group.features.distance.color })
    end
    if group.features.tracer then
        box:AddToggle(group.key .. "_Tracer", { Text = "Tracer", Default = true })
            :AddColorPicker(group.key .. "_TracerColor", { Default = group.features.tracer.color })
    end
    if group.features.healthBar ~= nil then
        box:AddToggle(group.key .. "_HealthBar", { Text = "Health Bar", Default = group.features.healthBar })
    end
    if group.features.chams ~= nil then
        box:AddToggle(group.key .. "_Chams", { Text = "Chams", Default = group.features.chams })
    end

    local function onApply()
        if Toggles[group.key .. "_Enable"].Value then
            startSenseInstances(group)
        else
            stopSenseInstances(group)
        end
    end

    safeOnChanged(group.key .. "_Enable", onApply)
    for _, id in ipairs({
        group.key .. "_Box", group.key .. "_BoxOutline", group.key .. "_BoxFill", group.key .. "_BoxFillAlpha",
        group.key .. "_Name", group.key .. "_Distance", group.key .. "_Tracer",
        group.key .. "_HealthBar", group.key .. "_Chams",
        group.key .. "_BoxColor", group.key .. "_NameColor", group.key .. "_DistColor", group.key .. "_TracerColor",
        "ESP_TextSize", "ESP_TracerOrigin", "ESP_LimitRange", "ESP_MaxRange",
    }) do
        safeOnChanged(id, onApply)
    end
end

for i, group in ipairs(ESP_CONFIG.groups) do
    if group.type == "players" then
        buildPlayerUI(group)
    elseif group.type == "sense_instances" then
        buildSenseInstanceUI(group, (i % 2 == 0) and "left" or "right")
    end
end

local function UnloadESP()
    for _, g in ipairs(ESP_CONFIG.groups) do
        if g.type == "sense_instances" then
            stopSenseInstances(g)
        end
    end

    if SENSE then
        pcall(function()
            if SENSE._hasLoaded and SENSE.Unload then
                SENSE.Unload()
            end
            if SENSE.teamSettings then
                SENSE.teamSettings.enemy.enabled    = false
                SENSE.teamSettings.friendly.enabled = false
            end
            if SENSE.instanceSettings then
                SENSE.instanceSettings.enabled = false
            end
        end)
    end

    if ESP_CONFIG and ESP_CONFIG.groups then
        for _, g in ipairs(ESP_CONFIG.groups) do
            local tid = g.key .. "_Enable"
            if Toggles[tid] and Toggles[tid].SetValue then
                pcall(function() Toggles[tid]:SetValue(false) end)
            end
        end
    end
end
ensureSense()

-- ================== --
-- ==== MISC TAB ==== --
-- ================== --

local MiscPanel = (loadstring(Dependencies.miscSrc)())(setmetatable(
    { Services = Services, Tabs = Tabs, References = References, Library = Library, Options = Options, Toggles = Toggles },
    { __index = _G }))

-- ================== --
-- ==== AUTO TAB ==== --
-- ================== --

-- ==== ATTACH CONFIG ==== --
local AttachConfig = {
    -- defaults
    Defaults = {
        mode        = "Aligned",
        yOffset     = 10,
        horizDist   = 4,
        targetType  = "Bosses",
        autoYOffset = true,
        dodgeMode   = true,
        dodgeRange  = 60,
        movement    = "Teleport", -- Teleport or Approach
    },

    UIText = {
        groupTitle = "Attach",
    },

    Move = {
        approachMaxSecs = 12,
        reachDistance   = 3,
        moveForceResp   = 80,
        moveMaxVelocity = 120,
        orientResp      = 120,
        approachSpeed   = 70,
    },

    DodgeConfig = {
        [74539496231984] = {
            delay = 0.1,
            dodgeY = -12,
            duration = 0.6
        },
    },

    AutoYOffsetConfig = {
        ["Wooden Golem"] = {
            y     = 14,
            mode  = "Aligned",
            horiz = 4,
        },
        ["Chakra Knight"] = {
            y         = 11,
            mode      = "Aligned",
            horizDist = 5,
        },
    },

    TargetTypes = {
        Players = {
            key    = "Players",
            static = {},
        },

        Entities = {
            key    = "Entities",
            static = {},
        },
        --[[
    Bosses = {
        staticOnly = true,
        static = {
            "Wooden Golem",
            "Chakra Knight",
            "Manda",
            "Hyuga Boss",
        },
    },]]
    },
}

local AttachPanel = (loadstring(Dependencies.attachSrc)())(setmetatable({
    Services   = Services,
    Tabs       = Tabs,
    References = References,
    Library    = Library,
    Options    = Options,
    Toggles    = Toggles,
    PREFIX     = PREFIX,
    MoveToPos  = MoveToPos,
    Config     = AttachConfig,
}, { __index = _G }))

-- ==== AUTOFARM MODULE ==== --
local AutoFarmModule = (loadstring(Dependencies.autoFarmSrc)())(setmetatable({
    Services    = Services,
    Tabs        = Tabs,
    References  = References,
    Library     = Library,
    Options     = Options,
    Toggles     = Toggles,
    META        = META,
    AttachPanel = AttachPanel,
    MoveToPos   = MoveToPos,
}, { __index = _G }))

-- ==== MACROS ==== --
local MacroAPI = (loadstring(Dependencies.macroSrc)())(setmetatable(
    {
        Services = Services,
        Tabs = Tabs,
        Library = Library,
        References = References,
        MoveToPos = MoveToPos,
        Toggles = Toggles,
        Options =
            Options
    }, { __index = _G }))

-- ================= --
-- ==== FUN TAB ==== --
-- ================= --

local FunPanel = (loadstring(Dependencies.funSrc)())(setmetatable(
    { Services = Services, Tabs = Tabs, References = References, Library = Library, Options = Options, Toggles = Toggles },
    { __index = _G }))

-- ====================== --
-- ==== FINALISATION ==== --
-- ====================== --

-- ==== UNLOADER ==== --
local UnloadHandlers = {}

table.insert(UnloadHandlers, stopZoom)
table.insert(UnloadHandlers, stopNoclip)
table.insert(UnloadHandlers, perfOff)
table.insert(UnloadHandlers, UnloadESP)
table.insert(UnloadHandlers, function()
    if noFallConn then
        noFallConn:Disconnect(); noFallConn = nil
    end
end)
table.insert(UnloadHandlers, function() setKillBricks(false) end)
table.insert(UnloadHandlers, function()
    if autoUseConn then
        pcall(autoUseConn.Disconnect, autoUseConn); autoUseConn = nil
    end
end)
table.insert(UnloadHandlers, function()
    if getgenv()._AntiAFK_Conn then
        getgenv()._AntiAFK_Conn:Disconnect()
        getgenv()._AntiAFK_Conn = nil
    end
end)
table.insert(UnloadHandlers, function()
    if SENSE then
        if SENSE._hasLoaded and SENSE.Unload then pcall(SENSE.Unload) end
        if SENSE.teamSettings then
            SENSE.teamSettings.enemy.enabled    = false
            SENSE.teamSettings.friendly.enabled = false
        end
        if SENSE.instanceSettings then
            SENSE.instanceSettings.enabled = false
        end
    end
end)
table.insert(UnloadHandlers, function()
    if MacroAPI and MacroAPI.Unload then pcall(MacroAPI.Unload) end
end)
table.insert(UnloadHandlers, function()
    if AttachPanel and AttachPanel.Unload then pcall(AttachPanel.Unload) end
end)
table.insert(UnloadHandlers, function()
    if FunPanel and FunPanel.Unload then pcall(FunPanel.Unload, FunPanel) end
end)
table.insert(UnloadHandlers, function()
    if HomePanel and HomePanel.Unload then pcall(HomePanel.Unload, HomePanel) end
end)
table.insert(UnloadHandlers, function()
    clearJoystickDrag()
    clearPourLineLock()
end)
table.insert(UnloadHandlers, function()
    if MovementPanel and MovementPanel.Unload then pcall(MovementPanel.Unload, MovementPanel) end
end)
table.insert(UnloadHandlers, function()
    if MiscPanel and MiscPanel.Unload then pcall(MiscPanel.Unload, MiscPanel) end
end)
table.insert(UnloadHandlers, function()
    if AutoFarmModule and AutoFarmModule.Unload then pcall(AutoFarmModule.Unload) end
end)
Library:OnUnload(function()
    pcall(SaveManager.Save, SaveManager, cfg)
    for i = 1, #UnloadHandlers do
        local fn = UnloadHandlers[i]
        if typeof(fn) == "function" then
            pcall(fn)
        end
    end
end)

-- ==== INIT PT 2 ==== --
SaveManager:LoadAutoloadConfig()
local function setupReferences(char)
    References.character = char or References.player.Character
    References.humanoid = References.character and References.character:FindFirstChildOfClass("Humanoid") or nil
    References.humanoidRootPart = References.character and References.character:FindFirstChild("HumanoidRootPart") or nil
    References.camera = Services.Workspace.CurrentCamera
end

local function onCharacterAdded(char)
    char:WaitForChild("Humanoid", 5)
    char:WaitForChild("HumanoidRootPart", 5)
    setupReferences(char)

    if Toggles.FlightEnabled and Toggles.FlightEnabled.Value then
        task.spawn(function()
            task.wait(0.25)
            MovementPanel.startFlight()
        end)
    end
    if Toggles.SpeedEnabled and Toggles.SpeedEnabled.Value then
        task.spawn(function()
            task.wait(0.25)
            MovementPanel.startSpeed()
        end)
    end
    if Toggles.JumpPower and Toggles.JumpPower.Value then
        task.spawn(function()
            task.wait(0.25)
            if MovementPanel.startJumpMod then MovementPanel.startJumpMod() end
        end)
    end
    if Toggles.InfiniteJump and Toggles.InfiniteJump.Value then
        task.spawn(function()
            task.wait(0.25)
            if MovementPanel.startInfiniteJump then MovementPanel.startInfiniteJump() end
        end)
    end

    task.spawn(function()
        task.wait(0.15)
        if AutoParry and Toggles.AP_Enable and Toggles.AP_Enable.Value then
            AutoParry.Start()
        end
    end)
end

References.player.CharacterAdded:Connect(onCharacterAdded)

if References.player.Character then
    onCharacterAdded(References.player.Character)
end

References.player.CharacterRemoving:Connect(function()
    MovementPanel.stopFlight()
    if MovementPanel.stopSpeed then MovementPanel.stopSpeed() end
    if MovementPanel.stopJumpMod then MovementPanel.stopJumpMod() end
    if MovementPanel.stopInfiniteJump then MovementPanel.stopInfiniteJump() end
    setupReferences(nil)
end)

Services.Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    References.camera = Services.Workspace.CurrentCamera
end)

getgenv().CERBERUS_LOADED = true

-- logger
scriptName = "The Forge"
loadstring(game:HttpGet("https://raw.githubusercontent.com/whodunitwww/noxhelpers/refs/heads/main/logs.lua"))()
