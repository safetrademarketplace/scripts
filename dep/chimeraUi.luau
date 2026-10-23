local cloneref = cloneref or function(object)
	return object
end

local function service(name)
	return cloneref(game:GetService(name))
end

local Players = service("Players")
local RunService = service("RunService")
local TweenService = service("TweenService")
local UserInputService = service("UserInputService")
local CoreGui = service("CoreGui")
local GuiService = service("GuiService")

local LocalPlayer = Players.LocalPlayer
local Environment = (getgenv and getgenv()) or _G
Environment.ChimeraWindows = Environment.ChimeraWindows or {}

local Chimera = {
	Version = "1.0.0",
	Logo = "rbxassetid://109836038071568",
	Windows = {},
}

local Palette = {}
for token, hex in pairs({
	base = "0c0d0d", sunken = "111213", surface = "17181a", raised = "222325", hover = "2c2d30",
	line = "393b3f", lineSoft = "28292c", lineStrong = "494b50", text = "e6e7ea", textSoft = "cdd0d5",
	secondary = "9fa3ad", muted = "7f858f", gutter = "60646c", accent = "d6a84e", accentBright = "edc977",
	accentInk = "1a1408", positive = "8dbf8a", warning = "e0b05a", negative = "e39480",
}) do
	Palette[token] = Color3.fromHex(hex)
end

local Painted = setmetatable({}, { __mode = "k" })

local function toColor(value)
	if typeof(value) == "Color3" then
		return value
	end
	local ok, color = pcall(Color3.fromHex, tostring(value))
	return ok and color or nil
end

local function font(family, weight)
	local ok, result = pcall(Font.new, family, weight)
	return ok and result or Font.fromEnum(Enum.Font.Gotham)
end

local function enumFamily(name, fallback)
	local ok, family = pcall(function()
		return Font.fromEnum(Enum.Font[name]).Family
	end)
	return ok and family or fallback
end

local SANS = "rbxasset://fonts/families/BuilderSans.json"
local MONO = enumFamily("RobotoMono", SANS)

local Fonts = {
	regular = font(SANS, Enum.FontWeight.Regular),
	medium = font(SANS, Enum.FontWeight.Medium),
	semibold = font(SANS, Enum.FontWeight.SemiBold),
	bold = font(SANS, Enum.FontWeight.Bold),
	mono = font(MONO, Enum.FontWeight.Medium),
}

local EASE = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function timed(duration, style, direction)
	return TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
end

local function tween(object, goal, info)
	local animation = TweenService:Create(object, info or EASE, goal)
	animation:Play()
	return animation
end

local function resolve(value)
	if type(value) == "string" then
		return Palette[value]
	elseif type(value) == "function" then
		return value(Palette)
	end
	return value
end

local function repaint(object, instant)
	local spec = Painted[object]
	if not spec then
		return
	end
	local goal = {}
	for property, value in pairs(spec) do
		goal[property] = resolve(value)
	end
	if instant then
		for property, value in pairs(goal) do
			object[property] = value
		end
	else
		tween(object, goal)
	end
end

local function repaintAll(objects, instant)
	for _, object in ipairs(objects) do
		repaint(object, instant)
	end
end

local function paint(object, spec)
	Painted[object] = spec
	repaint(object, true)
	return object
end

local TEXT_CLASSES = { TextLabel = true, TextButton = true, TextBox = true }

local DEFAULTS = {
	Frame = { BorderSizePixel = 0 },
	ScrollingFrame = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		ScrollBarThickness = 2,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
	},
	TextLabel = { BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left },
	TextButton = { BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextSize = 13, AutoButtonColor = false },
	TextBox = { BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", TextSize = 13, ClearTextOnFocus = false },
	ImageLabel = { BackgroundTransparency = 1, BorderSizePixel = 0 },
}

local function new(class, properties)
	local object = Instance.new(class)
	if TEXT_CLASSES[class] then
		object.FontFace = Fonts.regular
	end
	for property, value in pairs(DEFAULTS[class] or {}) do
		object[property] = value
	end
	local parent, theme
	for property, value in pairs(properties or {}) do
		if property == "Parent" then
			parent = value
		elseif property == "Theme" then
			theme = value
		else
			object[property] = value
		end
	end
	if theme then
		paint(object, theme)
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function corner(parent, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, token, thickness)
	return new("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = thickness or 1,
		Theme = { Color = token or "line" },
		Parent = parent,
	})
end

local function padding(parent, top, right, bottom, left)
	top = top or 0
	right = right or top
	return new("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom or top),
		PaddingLeft = UDim.new(0, left or right),
		Parent = parent,
	})
end

local function layout(parent, gap, direction, properties)
	local object = new("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = parent,
	})
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	return object
end

local function fill(parent)
	return (pcall(function()
		new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = parent })
	end))
end

local function pointer()
	return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
end

local function inside(object, point)
	local position, size = object.AbsolutePosition, object.AbsoluteSize
	return point.X >= position.X and point.X <= position.X + size.X and point.Y >= position.Y and point.Y <= position.Y + size.Y
end

local function fire(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local arguments = table.pack(...)
	task.spawn(function()
		local ok, problem = pcall(callback, table.unpack(arguments, 1, arguments.n))
		if not ok then
			warn("[Chimera] " .. tostring(problem))
		end
	end)
end

local function decimalsOf(step)
	local text = tostring(step)
	local dot = text:find(".", 1, true)
	return dot and #text - dot or 0
end

local MAC = (function()
	local ok, platform = pcall(function()
		return UserInputService:GetPlatform()
	end)
	return ok and platform == Enum.Platform.OSX
end)()

local KEY_LABELS = {
	LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftAlt = MAC and "LOpt" or "LAlt", RightAlt = MAC and "ROpt" or "RAlt",
	LeftSuper = MAC and "LCmd" or "LWin", RightSuper = MAC and "RCmd" or "RWin",
	MouseButton1 = "MB1", MouseButton2 = "MB2", MouseButton3 = "MB3",
	Return = "Enter", Backquote = "`", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]",
	BackSlash = "\\", Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/",
	CapsLock = "Caps", PageUp = "PgUp", PageDown = "PgDn", Insert = "Ins", Delete = "Del",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
}

local function keyLabel(key)
	if not key then
		return "None"
	end
	return KEY_LABELS[key.Name] or (key.Name:gsub("^Keypad", "Num"))
end

local KEY_WORDS = MAC and { Alt = "Option", Super = "Command" } or { Super = "Windows" }

local function keyWords(key)
	return (key.Name:gsub("(%l)(%u)", "%1 %2"):gsub("%a+$", KEY_WORDS))
end

local function sideless(words)
	return (words:gsub("^Left ", ""):gsub("^Right ", ""))
end

local function describeKeys(keys)
	local names = {}
	for _, key in ipairs(keys) do
		local words = keyWords(key)
		for _, other in ipairs(keys) do
			if other ~= key and sideless(keyWords(other)) == sideless(words) then
				words = sideless(words)
			end
		end
		if not table.find(names, words) then
			table.insert(names, words)
		end
	end
	return table.concat(names, " or ")
end

local function parseKey(value)
	if typeof(value) == "EnumItem" then
		return value
	end
	if type(value) ~= "string" or value == "" or value == "None" then
		return nil
	end
	local kind, name = value:match("^Enum%.(%w+)%.(%w+)$")
	local candidates = kind and { { kind, name } } or { { "KeyCode", value }, { "UserInputType", value } }
	for _, candidate in ipairs(candidates) do
		local ok, item = pcall(function()
			return Enum[candidate[1]][candidate[2]]
		end)
		if ok and item then
			return item
		end
	end
	return nil
end

local function parseKeys(value)
	local keys = {}
	for _, item in ipairs(typeof(value) == "table" and value or { value }) do
		local key = parseKey(item)
		if key then
			table.insert(keys, key)
		end
	end
	return keys
end

local function matches(key, input)
	if not key then
		return false
	end
	if key.EnumType == Enum.KeyCode then
		return input.KeyCode == key
	end
	return input.UserInputType == key
end

local function mount(gui)
	local protect = protectgui or (syn and syn.protect_gui)
	if protect then
		pcall(protect, gui)
	end
	local ok = pcall(function()
		gui.Parent = (gethui and gethui()) or CoreGui
	end)
	if not ok or not gui.Parent then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Element = {}
Element.__index = Element

local function class()
	local object = setmetatable({}, Element)
	object.__index = object
	return object
end

local Toggle, Slider, Button, Dropdown, Input = class(), class(), class(), class(), class()
local Keybind, ColorPicker, Label, Paragraph = class(), class(), class(), class()

local HEADER = 40
local TONES = { info = "accent", success = "positive", warning = "warning", error = "negative" }

function Chimera.Window(_, options)
	options = options or {}
	local title = options.Title or "Chimera"
	local size = options.Size or Vector2.new(360, 440)
	local previous = Environment.ChimeraWindows[title]
	if previous then
		pcall(previous.Destroy, previous)
	end

	local window = setmetatable({
		Title = title,
		Width = size.X,
		Height = size.Y,
		MenuKeys = options.Keybind == nil and { Enum.KeyCode.LeftAlt, Enum.KeyCode.RightAlt } or parseKeys(options.Keybind),
		Tabs = {},
		Binds = {},
		Connections = {},
		Unloaders = {},
		Notices = {},
		Visible = true,
		Minimized = false,
		UIScale = 1,
		NoticeCount = 0,
	}, Window)
	Environment.ChimeraWindows[title] = window
	table.insert(Chimera.Windows, window)

	window.Gui = new("ScreenGui", {
		Name = "Chimera",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 10000,
	})
	window.Frame = new("Frame", {
		BackgroundTransparency = 1,
		Position = options.Position or UDim2.fromOffset(16, GuiService:GetGuiInset().Y + 16),
		Size = UDim2.fromOffset(size.X, size.Y),
		Parent = window.Gui,
	})
	window.Scale = new("UIScale", { Parent = window.Frame })
	for layer = 1, 5 do
		local shade = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 3),
			Size = UDim2.new(1, layer * 4, 1, layer * 4),
			BackgroundColor3 = Color3.new(),
			BackgroundTransparency = 0.88 + layer * 0.02,
			ZIndex = 0,
			Parent = window.Frame,
		})
		corner(shade, 8 + layer * 2)
	end
	window.Root = new("Frame", {
		Active = true,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		Theme = { BackgroundColor3 = "base" },
		Parent = window.Frame,
	})
	corner(window.Root, 8)
	stroke(window.Root, "line")

	window:_header(options.Subtitle)
	window:_tabBar()
	window.Body = new("Frame", { BackgroundTransparency = 1, ClipsDescendants = true, Parent = window.Root })
	window:_grip()
	window:_layers()
	window:_input()
	window:_layout()

	mount(window.Gui)
	window.Scale.Scale = 0.96
	tween(window.Scale, { Scale = 1 }, timed(0.25))
	return window
end

function Window:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function Window:_hover(target, state, objects)
	local function set(hovered)
		state.hovered = hovered
		repaintAll(objects)
	end
	self:_connect(target.MouseEnter, function()
		set(true)
	end)
	self:_connect(target.MouseLeave, function()
		set(false)
	end)
end

function Window:_drag(handle, began, moved, ended)
	self:_connect(handle.InputBegan, function(input)
		local kind = input.UserInputType
		if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
			return
		end
		local origin = pointer()
		local state = began and began(origin)
		if state == false then
			return
		end
		local move, finish
		move = UserInputService.InputChanged:Connect(function(change)
			local changed = change.UserInputType
			if changed == Enum.UserInputType.MouseMovement or changed == Enum.UserInputType.Touch then
				local point = pointer()
				moved(point - origin, point, state)
			end
		end)
		finish = UserInputService.InputEnded:Connect(function(change)
			if change.UserInputType == kind then
				move:Disconnect()
				finish:Disconnect()
				if ended then
					ended(state)
				end
			end
		end)
	end)
end

function Window:_iconButton(parent, order, glyph)
	local state = { hovered = false }
	local button = new("TextButton", {
		Size = UDim2.fromOffset(24, 24),
		LayoutOrder = order,
		Theme = {
			BackgroundColor3 = "hover",
			BackgroundTransparency = function()
				return state.hovered and 0 or 1
			end,
		},
		Parent = parent,
	})
	corner(button, 5)
	local mark = glyph(button, function(theme)
		return state.hovered and theme.text or theme.secondary
	end)
	self:_hover(button, state, { button, mark })
	return button
end

function Window:_header(subtitle)
	local header = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HEADER), Parent = self.Root })
	new("ImageLabel", {
		Image = Chimera.Logo,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		Parent = header,
	})

	local heading = new("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.new(1, -100, 1, 0),
		ClipsDescendants = true,
		Parent = header,
	})
	layout(heading, 7, Enum.FillDirection.Horizontal, { VerticalAlignment = Enum.VerticalAlignment.Center })
	self.TitleLabel = new("TextLabel", {
		Text = self.Title,
		FontFace = Fonts.semibold,
		TextSize = 14,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		Theme = { TextColor3 = "text" },
		Parent = heading,
	})
	self.SubtitleLabel = new("TextLabel", {
		Text = subtitle or "",
		TextSize = 13,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		LayoutOrder = 1,
		Visible = subtitle ~= nil,
		Theme = { TextColor3 = "muted" },
		Parent = heading,
	})

	local grab = new("TextButton", { Size = UDim2.new(1, -64, 1, 0), Parent = header })
	self:_drag(grab, function()
		return self:_local(self.Frame.AbsolutePosition)
	end, function(delta, _, start)
		local screen = self.Gui.AbsoluteSize
		local width = self.Frame.AbsoluteSize.X
		local x = math.clamp(start.X + delta.X, 72 - width, math.max(72 - width, screen.X - 72))
		local y = math.clamp(start.Y + delta.Y, 0, math.max(0, screen.Y - HEADER))
		self.Frame.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
	end)

	local controls = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(52, 24),
		Parent = header,
	})
	layout(controls, 4, Enum.FillDirection.Horizontal, {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})
	local minimize = self:_iconButton(controls, 1, function(parent, color)
		return new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(10, 1),
			Theme = { BackgroundColor3 = color },
			Parent = parent,
		})
	end)
	local close = self:_iconButton(controls, 2, function(parent, color)
		return new("TextLabel", {
			Text = "×",
			FontFace = Fonts.medium,
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(1, 1),
			Theme = { TextColor3 = color },
			Parent = parent,
		})
	end)
	self:_connect(minimize.MouseButton1Click, function()
		self:SetMinimized(not self.Minimized)
	end)
	self:_connect(close.MouseButton1Click, function()
		self:Destroy()
	end)

	new("Frame", {
		Position = UDim2.fromOffset(0, HEADER),
		Size = UDim2.new(1, 0, 0, 1),
		Theme = { BackgroundColor3 = "lineSoft" },
		Parent = self.Root,
	})
end

function Window:_tabBar()
	self.TabBar = new("Frame", {
		Position = UDim2.fromOffset(10, HEADER + 9),
		Size = UDim2.new(1, -20, 0, 30),
		Visible = false,
		Theme = { BackgroundColor3 = "sunken" },
		Parent = self.Root,
	})
	corner(self.TabBar, 6)
	stroke(self.TabBar, "lineSoft")
	padding(self.TabBar, 3)
	self.Indicator = new("Frame", { Size = UDim2.fromScale(0, 1), Theme = { BackgroundColor3 = "raised" }, Parent = self.TabBar })
	corner(self.Indicator, 4)
	stroke(self.Indicator, "lineSoft")
	self.TabList = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = self.TabBar })
	layout(self.TabList, 0, Enum.FillDirection.Horizontal)
end

function Window:_grip()
	self.Grip = new("TextButton", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		Size = UDim2.fromOffset(16, 16),
		ZIndex = 5,
		Parent = self.Root,
	})
	for _, offset in ipairs({ Vector2.new(10, 10), Vector2.new(6, 10), Vector2.new(10, 6) }) do
		new("Frame", {
			Position = UDim2.fromOffset(offset.X, offset.Y),
			Size = UDim2.fromOffset(2, 2),
			Theme = { BackgroundColor3 = "gutter" },
			Parent = self.Grip,
		})
	end
	self:_drag(self.Grip, function()
		return Vector2.new(self.Width, self.Height)
	end, function(delta, _, start)
		local screen = self.Gui.AbsoluteSize / self.UIScale
		self.Width = math.floor(math.clamp(start.X + delta.X / self.UIScale, 300, math.max(300, screen.X)))
		self.Height = math.floor(math.clamp(start.Y + delta.Y / self.UIScale, 220, math.max(220, screen.Y)))
		self.Frame.Size = UDim2.fromOffset(self.Width, self.Height)
	end)
end

function Window:_layers()
	self.Overlay = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 10, Parent = self.Gui })
	self.OverlayScale = new("UIScale", { Parent = self.Overlay })
	self.NoticeList = new("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -16, 1, -16),
		Size = UDim2.new(0, 280, 1, -32),
		ZIndex = 20,
		Parent = self.Gui,
	})
	layout(self.NoticeList, 8, nil, { VerticalAlignment = Enum.VerticalAlignment.Bottom })
	self.Tip = new("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 0,
		TextSize = 12,
		TextWrapped = true,
		Visible = false,
		ZIndex = 30,
		Theme = { BackgroundColor3 = "raised", TextColor3 = "textSoft" },
		Parent = self.Gui,
	})
	corner(self.Tip, 5)
	stroke(self.Tip, "line")
	padding(self.Tip, 5, 8)
	new("UISizeConstraint", { MaxSize = Vector2.new(240, math.huge), Parent = self.Tip })
end

function Window:_input()
	self:_connect(UserInputService.InputBegan, function(input)
		local kind = input.UserInputType
		if self.Popup and (kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch) then
			local point = pointer()
			if not inside(self.Popup.Frame, point) and not inside(self.Popup.Anchor, point) then
				self:_closePopup()
			end
		end
		if self.Listening and self.Listening:_capture(input) then
			return
		end
		if kind ~= Enum.UserInputType.Keyboard and kind ~= Enum.UserInputType.MouseButton2 and kind ~= Enum.UserInputType.MouseButton3 then
			return
		end
		if UserInputService:GetFocusedTextBox() then
			return
		end
		for _, menuKey in ipairs(self.MenuKeys) do
			if matches(menuKey, input) then
				self:Toggle()
				break
			end
		end
		for _, bind in ipairs(self.Binds) do
			if matches(bind.Value, input) then
				bind:_press()
			end
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		for _, bind in ipairs(self.Binds) do
			if matches(bind.Value, input) then
				bind:_release()
			end
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self.Tip.Visible then
			self:_placeTip()
		end
	end)
	self:_connect(RunService.RenderStepped, function()
		if self.Popup then
			self:_placePopup()
		end
	end)
end

function Window:_layout()
	local count = #self.Tabs
	local top = HEADER + 1 + (count > 1 and 38 or 0)
	self.TabBar.Visible = count > 1
	self.Body.Position = UDim2.fromOffset(0, top)
	self.Body.Size = UDim2.new(1, 0, 1, -top)
	for _, tab in ipairs(self.Tabs) do
		tab.Button.Size = UDim2.fromScale(1 / count, 1)
	end
	self:_moveIndicator(true)
end

function Window:_moveIndicator(instant)
	local index = self.CurrentTab and table.find(self.Tabs, self.CurrentTab)
	if not index then
		return
	end
	local count = #self.Tabs
	local goal = { Position = UDim2.fromScale((index - 1) / count, 0), Size = UDim2.fromScale(1 / count, 1) }
	if instant then
		self.Indicator.Position, self.Indicator.Size = goal.Position, goal.Size
	else
		tween(self.Indicator, goal, timed(0.22))
	end
end

function Window:_local(point)
	return point - self.Overlay.AbsolutePosition
end

function Window:_placeTip()
	local point = self:_local(pointer())
	local screen = self.Gui.AbsoluteSize
	local size = self.Tip.AbsoluteSize
	local x = math.min(point.X + 14, screen.X - size.X - 8)
	local y = point.Y + 18
	if y + size.Y > screen.Y - 8 then
		y = point.Y - size.Y - 10
	end
	self.Tip.Position = UDim2.fromOffset(x, y)
end

function Window:_tooltip(target, text)
	self:_connect(target.MouseEnter, function()
		self.TipTarget = target
		task.delay(0.35, function()
			if self.TipTarget ~= target or self.Destroyed then
				return
			end
			local message = text
			if type(text) == "function" then
				message = text()
			end
			if type(message) ~= "string" or message == "" then
				return
			end
			self.Tip.Text = message
			self.Tip.Visible = true
			self:_placeTip()
		end)
	end)
	self:_connect(target.MouseLeave, function()
		if self.TipTarget == target then
			self:_hideTip()
		end
	end)
end

function Window:_hideTip()
	self.TipTarget = nil
	self.Tip.Visible = false
end

function Window:_openPopup(frame, anchor, owner, onClose)
	self:_closePopup()
	self:_hideTip()
	self.Popup = { Frame = frame, Anchor = anchor, Owner = owner, OnClose = onClose }
	frame.Visible = true
	self:_placePopup()
end

function Window:_closePopup(owner)
	local popup = self.Popup
	if not popup or (owner and popup.Owner ~= owner) then
		return
	end
	self.Popup = nil
	popup.Frame.Visible = false
	if popup.OnClose then
		popup.OnClose()
	end
end

function Window:_placePopup()
	local popup = self.Popup
	local anchor = popup.Anchor
	local page = self.CurrentTab and self.CurrentTab.Page
	local center = anchor.AbsolutePosition + anchor.AbsoluteSize / 2
	if not anchor.Parent or not self.Visible or self.Minimized or (page and not inside(page, center)) then
		self:_closePopup()
		return
	end
	local scale = self.UIScale
	local screen = self.Gui.AbsoluteSize
	local size = popup.Frame.AbsoluteSize
	local origin = self:_local(anchor.AbsolutePosition)
	local x = origin.X + anchor.AbsoluteSize.X - size.X
	local y = origin.Y + anchor.AbsoluteSize.Y + 4 * scale
	if y + size.Y > screen.Y - 8 then
		y = origin.Y - size.Y - 4 * scale
	end
	x = math.clamp(x, 8, math.max(8, screen.X - size.X - 8))
	popup.Frame.Position = UDim2.fromOffset(math.floor(x / scale), math.floor(y / scale))
end

function Window:_popupFrame(width, inset)
	local frame = new("Frame", {
		Active = true,
		Size = UDim2.fromOffset(width, 0),
		Visible = false,
		Theme = { BackgroundColor3 = "raised" },
		Parent = self.Overlay,
	})
	corner(frame, 8)
	stroke(frame, "line")
	padding(frame, inset or 4)
	return frame
end

function Window:_listen(bind)
	local previous = self.Listening
	self.Listening = bind
	if previous and previous ~= bind then
		previous:_render()
	end
	bind:_render()
end

function Window:Tab(name)
	local tab = setmetatable({ Window = self, Name = name or "Tab", Sections = {}, Count = 0 }, Tab)
	local state = { hovered = false }
	tab.Page = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Theme = { ScrollBarImageColor3 = "line" },
		Parent = self.Body,
	})
	padding(tab.Page, 10, 10, 12, 10)
	layout(tab.Page, 12)
	self:_connect(tab.Page:GetPropertyChangedSignal("CanvasPosition"), function()
		self:_closePopup()
		self:_hideTip()
	end)
	tab.Button = new("TextButton", {
		Text = tab.Name,
		FontFace = Fonts.medium,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		LayoutOrder = #self.Tabs + 1,
		Theme = {
			TextColor3 = function(theme)
				if self.CurrentTab == tab then
					return theme.text
				end
				return state.hovered and theme.textSoft or theme.secondary
			end,
		},
		Parent = self.TabList,
	})
	self:_hover(tab.Button, state, { tab.Button })
	self:_connect(tab.Button.MouseButton1Click, function()
		self:SelectTab(tab)
	end)
	table.insert(self.Tabs, tab)
	self:_layout()
	if not self.CurrentTab then
		self:SelectTab(tab, true)
	end
	return tab
end

function Window:Section(name)
	return (self.Tabs[1] or self:Tab("Main")):Section(name)
end

function Window:SelectTab(tab, instant)
	if type(tab) == "string" then
		for _, candidate in ipairs(self.Tabs) do
			if candidate.Name == tab then
				tab = candidate
				break
			end
		end
	end
	if type(tab) ~= "table" or self.CurrentTab == tab then
		return
	end
	self:_closePopup()
	self.CurrentTab = tab
	for _, other in ipairs(self.Tabs) do
		other.Page.Visible = other == tab
		repaint(other.Button, instant)
	end
	if not instant then
		tab.Page.Position = UDim2.fromOffset(0, 6)
		tween(tab.Page, { Position = UDim2.new() }, timed(0.22))
	end
	self:_moveIndicator(instant)
end

function Window:SetVisible(visible)
	visible = visible ~= false
	if self.Visible == visible then
		return
	end
	self.Visible = visible
	self:_closePopup()
	self:_hideTip()
	self.Frame.Visible = visible
	if visible then
		self.Scale.Scale = self.UIScale * 0.96
		tween(self.Scale, { Scale = self.UIScale }, timed(0.22))
	elseif #self.MenuKeys > 0 and not self.HintShown then
		self.HintShown = true
		self:Notify({ Title = "Menu hidden", Content = "Press " .. describeKeys(self.MenuKeys) .. " to bring it back." })
	end
end

function Window:Toggle()
	self:SetVisible(not self.Visible)
end

function Window:SetMinimized(minimized)
	self.Minimized = minimized == true
	self:_closePopup()
	self.Grip.Visible = not self.Minimized
	tween(self.Frame, { Size = UDim2.fromOffset(self.Width, self.Minimized and HEADER or self.Height) }, timed(0.25))
end

function Window:SetScale(scale)
	self.UIScale = math.clamp(tonumber(scale) or 1, 0.6, 2)
	self.Scale.Scale = self.UIScale
	self.OverlayScale.Scale = self.UIScale
	self:_closePopup()
end

function Window:SetSize(size)
	self.Width, self.Height = size.X, size.Y
	if not self.Minimized then
		self.Frame.Size = UDim2.fromOffset(size.X, size.Y)
	end
end

function Window:SetTitle(title)
	self.TitleLabel.Text = title
end

function Window:SetSubtitle(subtitle)
	self.SubtitleLabel.Text = subtitle or ""
	self.SubtitleLabel.Visible = subtitle ~= nil and subtitle ~= ""
end

function Window:GetMenuKeyText()
	return describeKeys(self.MenuKeys)
end

function Window:SetMenuKey(keys)
	self.MenuKeys = parseKeys(keys)
end

function Window:OnUnload(callback)
	table.insert(self.Unloaders, callback)
end

function Window:Notify(options)
	if type(options) == "string" then
		options = { Content = options }
	end
	options = options or {}
	local tone = TONES[options.Tone or "info"] or TONES.info
	local duration = options.Duration or 4
	self.NoticeCount += 1

	local holder = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = self.NoticeCount,
		Parent = self.NoticeList,
	})
	local card = new("TextButton", {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 0,
		Position = UDim2.new(1, 24, 0, 0),
		Size = UDim2.fromScale(1, 0),
		Theme = { BackgroundColor3 = "raised" },
		Parent = holder,
	})
	corner(card, 8)
	stroke(card, "line")
	padding(card, 10, 12, 10, 12)
	layout(card, 4)

	local head = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Parent = card })
	local dot = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(6, 6),
		Theme = { BackgroundColor3 = tone },
		Parent = head,
	})
	corner(dot, 3)
	new("TextLabel", {
		Text = options.Title or self.Title,
		FontFace = Fonts.semibold,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(1, -14, 1, 0),
		Theme = { TextColor3 = "text" },
		Parent = head,
	})
	if options.Content and options.Content ~= "" then
		new("TextLabel", {
			Text = options.Content,
			TextSize = 12,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			LayoutOrder = 1,
			Theme = { TextColor3 = "secondary" },
			Parent = card,
		})
	end
	local foot = new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8), LayoutOrder = 2, Parent = card })
	local track = new("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 0, 2),
		Theme = { BackgroundColor3 = "lineSoft" },
		Parent = foot,
	})
	corner(track, 1)
	local bar = new("Frame", { Size = UDim2.fromScale(1, 1), Theme = { BackgroundColor3 = tone }, Parent = track })
	corner(bar, 1)

	tween(card, { Position = UDim2.new() }, timed(0.35))
	local progress = tween(bar, { Size = UDim2.fromScale(0, 1) }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
	local notice = { Dismissed = false }
	function notice.Dismiss()
		if notice.Dismissed then
			return
		end
		notice.Dismissed = true
		progress:Cancel()
		local index = table.find(self.Notices, notice)
		if index then
			table.remove(self.Notices, index)
		end
		if not holder.Parent then
			return
		end
		tween(card, { Position = UDim2.new(1, 24, 0, 0) }, timed(0.25))
		holder.AutomaticSize = Enum.AutomaticSize.None
		holder.Size = UDim2.new(1, 0, 0, holder.AbsoluteSize.Y)
		task.delay(0.18, function()
			tween(holder, { Size = UDim2.fromScale(1, 0) }, timed(0.2))
			task.delay(0.22, function()
				holder:Destroy()
			end)
		end)
	end
	card.MouseButton1Click:Connect(notice.Dismiss)
	table.insert(self.Notices, notice)
	if #self.Notices > 5 then
		self.Notices[1].Dismiss()
	end
	task.delay(duration, notice.Dismiss)
	return notice
end

function Window:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true
	for _, callback in ipairs(self.Unloaders) do
		local ok, problem = pcall(callback)
		if not ok then
			warn("[Chimera] " .. tostring(problem))
		end
	end
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	for object in pairs(Painted) do
		if not object.Parent or object:IsDescendantOf(self.Gui) then
			Painted[object] = nil
		end
	end
	self.Gui:Destroy()
	if Environment.ChimeraWindows[self.Title] == self then
		Environment.ChimeraWindows[self.Title] = nil
	end
	local index = table.find(Chimera.Windows, self)
	if index then
		table.remove(Chimera.Windows, index)
	end
end

Window.Unload = Window.Destroy

function Tab:Select()
	self.Window:SelectTab(self)
end

function Tab:Section(name)
	self.Count += 1
	local section = setmetatable({ Tab = self, Window = self.Window, Elements = {}, Count = 0 }, Section)
	section.Frame = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = self.Count,
		Visible = false,
		Parent = self.Page,
	})
	layout(section.Frame, 6)
	if name and name ~= "" then
		section.Heading = new("TextLabel", {
			Text = string.upper(name),
			FontFace = Fonts.semibold,
			TextSize = 11,
			Size = UDim2.new(1, 0, 0, 14),
			Theme = { TextColor3 = "muted" },
			Parent = section.Frame,
		})
		padding(section.Heading, 0, 0, 0, 2)
	end
	section.Card = new("Frame", {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = 1,
		Theme = { BackgroundColor3 = "surface" },
		Parent = section.Frame,
	})
	corner(section.Card, 8)
	stroke(section.Card, "lineSoft")
	layout(section.Card, 0)
	table.insert(self.Sections, section)
	return section
end

function Section:_refresh()
	local first = true
	for _, element in ipairs(self.Elements) do
		if element.Row.Visible then
			element.Divider.Visible = not first
			first = false
		end
	end
	self.Frame.Visible = not first and not self.Hidden
end

function Section:SetVisible(visible)
	self.Hidden = visible == false
	self:_refresh()
	return self
end

function Section:SetTitle(name)
	if self.Heading then
		self.Heading.Text = string.upper(name)
	end
	return self
end

function Section:_element(kind, options, spec)
	spec = spec or {}
	self.Count += 1
	local window = self.Window
	local element = setmetatable({
		Section = self,
		Window = window,
		Config = options,
		Listeners = {},
		Painted = {},
	}, kind)
	local height = spec.height or (options.Description and 50 or 38)
	local automatic = spec.auto and Enum.AutomaticSize.Y or Enum.AutomaticSize.None

	element.Row = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = automatic,
		Size = UDim2.new(1, 0, 0, spec.auto and 0 or height),
		LayoutOrder = self.Count,
		Parent = self.Card,
	})
	element.Divider = new("Frame", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, 1),
		Theme = { BackgroundColor3 = "lineSoft" },
		Parent = element.Row,
	})
	element.Content = new("Frame", {
		BackgroundTransparency = 1,
		AutomaticSize = automatic,
		Size = UDim2.new(1, 0, 0, spec.auto and 0 or (spec.content or height)),
		Parent = element.Row,
	})
	padding(element.Content, spec.auto and 10 or 0, 12)

	if not spec.bare then
		layout(element.Content, 10, Enum.FillDirection.Horizontal, { VerticalAlignment = Enum.VerticalAlignment.Center })
		element.Info = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(0.5, 1), Parent = element.Content })
		if fill(element.Info) then
			element.Info.Size = UDim2.fromScale(0, 1)
		end
		layout(element.Info, 1, nil, { VerticalAlignment = Enum.VerticalAlignment.Center })
		element.NameLabel = new("TextLabel", {
			Text = options.Name or "",
			TextSize = 14,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, 17),
			Theme = { TextColor3 = "textSoft" },
			Parent = element.Info,
		})
		if options.Description then
			element.DescriptionLabel = new("TextLabel", {
				Text = options.Description,
				TextSize = 12,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, 0, 0, 14),
				LayoutOrder = 1,
				Theme = { TextColor3 = "muted" },
				Parent = element.Info,
			})
		end
		element.Controls = new("Frame", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromScale(0, 1),
			LayoutOrder = 1,
			Parent = element.Content,
		})
		layout(element.Controls, 6, Enum.FillDirection.Horizontal, {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})
	end

	if options.Tooltip then
		window:_tooltip(element.Row, options.Tooltip)
	end
	table.insert(self.Elements, element)
	self:_refresh()
	return element
end

function Element:Get()
	return self.Value
end

function Element:_coerce(value)
	return value
end

function Element:_same(value)
	return self.Value == value
end

function Element:_render(instant)
	repaintAll(self.Painted, instant)
end

function Element:_changed()
	fire(self.Config.Callback, self:Get())
	for _, listener in ipairs(self.Listeners) do
		fire(listener, self:Get())
	end
end

function Element:Set(value, silent)
	value = self:_coerce(value)
	if self:_same(value) then
		return self
	end
	self.Value = value
	self:_render()
	if not silent then
		self:_changed()
	end
	return self
end

function Element:OnChanged(callback)
	table.insert(self.Listeners, callback)
	return self
end

function Element:SetVisible(visible)
	self.Row.Visible = visible ~= false
	if not self.Row.Visible then
		self.Window:_closePopup(self)
	end
	self.Section:_refresh()
	return self
end

function Element:SetName(name)
	if self.NameLabel then
		self.NameLabel.Text = name
	end
	return self
end

function Element:SetDescription(text)
	if self.DescriptionLabel then
		self.DescriptionLabel.Text = text
	end
	return self
end

function Element:SetLocked(locked, reason)
	self.Locked = locked ~= false
	self.LockReason = reason
	if not self.Lock then
		self.Lock = new("TextButton", {
			BackgroundTransparency = 0.3,
			Position = UDim2.fromOffset(4, 2),
			Size = UDim2.new(1, -8, 1, -4),
			ZIndex = 8,
			Theme = { BackgroundColor3 = "surface" },
			Parent = self.Row,
		})
		corner(self.Lock, 6)
		self.Window:_tooltip(self.Lock, function()
			return self.LockReason
		end)
	end
	self.Lock.Visible = self.Locked
	if self.Locked then
		self.Window:_closePopup(self)
	end
	return self
end

function Element:Destroy()
	local window = self.Window
	window:_closePopup(self)
	for index = #window.Binds, 1, -1 do
		local bind = window.Binds[index]
		if bind == self or bind.Target == self then
			table.remove(window.Binds, index)
		end
	end
	local index = table.find(self.Section.Elements, self)
	if index then
		table.remove(self.Section.Elements, index)
	end
	if self.Popup then
		self.Popup:Destroy()
	end
	self.Row:Destroy()
	self.Section:_refresh()
end

function Section:Toggle(options)
	options = options or {}
	local toggle = self:_element(Toggle, options)
	local window = self.Window
	local state = { hovered = false }
	toggle.Value = options.Default == true

	local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), ZIndex = 0, Parent = toggle.Row })
	local switch = new("Frame", {
		Size = UDim2.fromOffset(30, 16),
		LayoutOrder = 10,
		Theme = {
			BackgroundColor3 = function(theme)
				return toggle.Value and theme.accent or theme.base
			end,
		},
		Parent = toggle.Controls,
	})
	corner(switch, 8)
	local edge = stroke(switch, function(theme)
		if toggle.Value then
			return theme.accent
		end
		return state.hovered and theme.lineStrong or theme.line
	end)
	toggle.Knob = new("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, toggle.Value and 17 or 3, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		Theme = {
			BackgroundColor3 = function(theme)
				return toggle.Value and theme.accentInk or theme.secondary
			end,
		},
		Parent = switch,
	})
	corner(toggle.Knob, 5)
	paint(toggle.NameLabel, {
		TextColor3 = function(theme)
			return (state.hovered or toggle.Value) and theme.text or theme.textSoft
		end,
	})

	toggle.Painted = { switch, edge, toggle.Knob, toggle.NameLabel }
	window:_hover(hit, state, toggle.Painted)
	window:_connect(hit.MouseButton1Click, function()
		toggle:Set(not toggle.Value)
	end)
	return toggle
end

function Toggle:_coerce(value)
	return value == true
end

function Toggle:_render(instant)
	repaintAll(self.Painted, instant)
	local position = UDim2.new(0, self.Value and 17 or 3, 0.5, 0)
	if instant then
		self.Knob.Position = position
	else
		tween(self.Knob, { Position = position }, timed(0.2))
	end
end

function Section:Slider(options)
	options = options or {}
	local top = options.Description and 46 or 32
	local slider = self:_element(Slider, options, { height = top + 18, content = top })
	local window = self.Window
	slider.Min = options.Min or 0
	slider.Max = options.Max or 100
	slider.Step = options.Step or options.Increment or 1
	slider.Decimals = options.Decimals or decimalsOf(slider.Step)
	slider.Suffix = options.Suffix or ""
	slider.Value = slider:_coerce(options.Default or slider.Min)

	slider.Box = new("TextBox", {
		FontFace = Fonts.mono,
		TextSize = 12,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		Theme = { TextColor3 = "secondary" },
		Parent = slider.Controls,
	})
	local track = new("Frame", {
		Position = UDim2.fromOffset(12, top + 1),
		Size = UDim2.new(1, -24, 0, 4),
		Theme = { BackgroundColor3 = "line" },
		Parent = slider.Row,
	})
	corner(track, 2)
	slider.Fill = new("Frame", { Size = UDim2.fromScale(0, 1), Theme = { BackgroundColor3 = "accent" }, Parent = track })
	corner(slider.Fill, 2)
	slider.Knob = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(12, 12),
		Theme = { BackgroundColor3 = "text" },
		Parent = track,
	})
	corner(slider.Knob, 6)
	local hit = new("TextButton", { Position = UDim2.fromOffset(6, top - 6), Size = UDim2.new(1, -12, 0, 22), Parent = slider.Row })

	local function apply(point)
		local ratio = math.clamp((point.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		slider:Set(slider.Min + (slider.Max - slider.Min) * ratio)
	end
	window:_drag(hit, function(point)
		slider.Dragging = true
		tween(slider.Knob, { Size = UDim2.fromOffset(14, 14) })
		apply(point)
	end, function(_, point)
		apply(point)
	end, function()
		slider.Dragging = false
		tween(slider.Knob, { Size = UDim2.fromOffset(12, 12) })
	end)
	window:_connect(slider.Box.Focused, function()
		slider.Box.Text = slider:_format(false)
	end)
	window:_connect(slider.Box.FocusLost, function()
		local number = tonumber((slider.Box.Text:gsub("[^%d%.%-]", "")))
		if number then
			slider:Set(number)
		end
		slider:_render(true)
	end)
	slider:_render(true)
	return slider
end

function Slider:_coerce(value)
	local low, high = math.min(self.Min, self.Max), math.max(self.Min, self.Max)
	local number = tonumber(value) or self.Value or self.Min
	number = self.Min + math.floor((number - self.Min) / self.Step + 0.5) * self.Step
	return tonumber(string.format("%." .. self.Decimals .. "f", math.clamp(number, low, high)))
end

function Slider:_format(suffix)
	local text = string.format("%." .. self.Decimals .. "f", self.Value)
	if suffix == false then
		return text
	end
	return text .. self.Suffix
end

function Slider:_render(instant)
	local range = self.Max - self.Min
	local ratio = range == 0 and 0 or (self.Value - self.Min) / range
	local size, position = UDim2.fromScale(ratio, 1), UDim2.fromScale(ratio, 0.5)
	if instant or self.Dragging then
		self.Fill.Size, self.Knob.Position = size, position
	else
		tween(self.Fill, { Size = size })
		tween(self.Knob, { Position = position })
	end
	if not self.Box:IsFocused() then
		self.Box.Text = self:_format()
	end
end

function Slider:SetRange(min, max)
	self.Min, self.Max = min, max
	self:Set(self.Value)
	self:_render()
	return self
end

local BUTTON_STYLES = {
	Default = function(state)
		return {
			BackgroundColor3 = function(theme)
				return state.hovered and theme.hover or theme.raised
			end,
			TextColor3 = "text",
		}, "line"
	end,
	Primary = function(state)
		local colour = function(theme)
			return state.hovered and theme.accentBright or theme.accent
		end
		return { BackgroundColor3 = colour, TextColor3 = "accentInk" }, colour
	end,
	Danger = function(state)
		return {
			BackgroundColor3 = function(theme)
				return state.hovered and theme.surface:Lerp(theme.negative, 0.14) or theme.surface
			end,
			TextColor3 = "negative",
		}, function(theme)
			return theme.surface:Lerp(theme.negative, 0.4)
		end
	end,
	Quiet = function(state)
		return {
			BackgroundColor3 = function(theme)
				return state.hovered and theme.hover or theme.surface
			end,
			TextColor3 = function(theme)
				return state.hovered and theme.text or theme.secondary
			end,
		}, function(theme)
			return state.hovered and theme.line or theme.lineSoft
		end
	end,
}

function Window:_button(parent, options, size)
	local state = { hovered = false, armed = false }
	local style = BUTTON_STYLES[options.Style or "Default"] or BUTTON_STYLES.Default
	local theme, edgeToken = style(state)
	local handle = { Name = options.Name or "Button" }
	local button = new("TextButton", {
		Text = handle.Name,
		FontFace = Fonts.medium,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 0,
		Size = size,
		Theme = theme,
		Parent = parent,
	})
	corner(button, 6)
	local edge = stroke(button, edgeToken)
	local scale = new("UIScale", { Parent = button })
	self:_hover(button, state, { button, edge })
	self:_connect(button.MouseButton1Down, function()
		tween(scale, { Scale = 0.97 }, timed(0.08))
	end)
	for _, signal in ipairs({ button.MouseButton1Up, button.MouseLeave }) do
		self:_connect(signal, function()
			tween(scale, { Scale = 1 }, timed(0.14))
		end)
	end

	function handle.Fire()
		fire(options.Callback)
	end

	function handle.SetText(text)
		handle.Name = text
		if not state.armed then
			button.Text = text
		end
	end

	self:_connect(button.MouseButton1Click, function()
		if options.Confirm and not state.armed then
			state.armed = true
			button.Text = type(options.Confirm) == "string" and options.Confirm or "Click again to confirm"
			task.delay(2.5, function()
				if state.armed then
					state.armed = false
					button.Text = handle.Name
				end
			end)
			return
		end
		state.armed = false
		button.Text = handle.Name
		handle.Fire()
	end)
	handle.Instance = button
	return handle
end

function Section:Button(options, callback)
	if type(options) == "string" then
		options = { Name = options, Callback = callback }
	end
	options = options or {}
	local element = self:_element(Button, options, { height = 40, bare = true })
	element.Handle = self.Window:_button(element.Content, options, UDim2.new(1, 0, 0, 28))
	element.Handle.Instance.AnchorPoint = Vector2.new(0, 0.5)
	element.Handle.Instance.Position = UDim2.fromScale(0, 0.5)
	return element
end

function Section:Buttons(list)
	local element = self:_element(Button, {}, { height = 40, bare = true })
	layout(element.Content, 6, Enum.FillDirection.Horizontal, { VerticalAlignment = Enum.VerticalAlignment.Center })
	element.Buttons = {}
	local count = #list
	for index, options in ipairs(list) do
		local handle = self.Window:_button(element.Content, options, UDim2.new(1 / count, -6 * (count - 1) / count, 0, 28))
		handle.Instance.LayoutOrder = index
		element.Buttons[index] = handle
	end
	return element
end

function Button:Fire()
	if self.Handle then
		self.Handle.Fire()
	end
end

function Button:SetText(text)
	if self.Handle then
		self.Handle.SetText(text)
	end
	return self
end

Button.SetName = Button.SetText

function Section:Label(options)
	if type(options) ~= "table" then
		options = { Text = tostring(options) }
	end
	if options.Value ~= nil then
		local label = self:_element(Label, { Name = options.Text, Tooltip = options.Tooltip })
		label.Value = options.Value
		label.Tone = options.Tone
		label.ValueLabel = new("TextLabel", {
			Text = tostring(options.Value),
			FontFace = Fonts.mono,
			TextSize = 12,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 18),
			TextXAlignment = Enum.TextXAlignment.Right,
			Theme = {
				TextColor3 = function(theme)
					return theme[TONES[label.Tone] or "secondary"]
				end,
			},
			Parent = label.Controls,
		})
		label.Painted = { label.ValueLabel }
		return label
	end
	local label = self:_element(Label, { Tooltip = options.Tooltip }, { auto = true, bare = true })
	label.Value = options.Text or ""
	label.TextLabel = new("TextLabel", {
		Text = label.Value,
		TextSize = 13,
		TextWrapped = true,
		RichText = options.RichText == true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Theme = { TextColor3 = "secondary" },
		Parent = label.Content,
	})
	return label
end

function Label:Set(value)
	self.Value = value
	local target = self.ValueLabel or self.TextLabel
	target.Text = tostring(value)
	return self
end

Label.SetValue = Label.Set

function Label:SetText(text)
	if self.ValueLabel then
		self.NameLabel.Text = text
	else
		self:Set(text)
	end
	return self
end

function Label:SetTone(tone)
	self.Tone = tone
	self:_render()
	return self
end

function Section:Paragraph(options)
	if type(options) ~= "table" then
		options = { Content = tostring(options) }
	end
	local paragraph = self:_element(Paragraph, { Tooltip = options.Tooltip }, { auto = true, bare = true })
	layout(paragraph.Content, 3)
	paragraph.TitleLabel = new("TextLabel", {
		Text = options.Title or "",
		FontFace = Fonts.semibold,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		Visible = options.Title ~= nil,
		Theme = { TextColor3 = "text" },
		Parent = paragraph.Content,
	})
	paragraph.Body = new("TextLabel", {
		Text = options.Content or "",
		TextSize = 12,
		TextWrapped = true,
		RichText = options.RichText == true,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = 1,
		Theme = { TextColor3 = "secondary" },
		Parent = paragraph.Content,
	})
	paragraph.Value = options.Content
	return paragraph
end

function Paragraph:Set(content, title)
	self.Value = content
	self.Body.Text = tostring(content or "")
	if title ~= nil then
		self.TitleLabel.Text = title
		self.TitleLabel.Visible = title ~= ""
	end
	return self
end

function Section:Dropdown(options)
	options = options or {}
	local dropdown = self:_element(Dropdown, options)
	local window = self.Window
	local state = { hovered = false }
	dropdown.Multi = options.Multi == true
	dropdown.Items = {}
	for index, item in ipairs(options.Options or options.Values or {}) do
		dropdown.Items[index] = tostring(item)
	end
	dropdown.Value = dropdown:_coerce(options.Default)
	dropdown.Open = false

	dropdown.Trigger = new("TextButton", {
		Size = UDim2.fromOffset(options.Width or 140, 26),
		BackgroundTransparency = 0,
		Theme = { BackgroundColor3 = "base" },
		Parent = dropdown.Controls,
	})
	corner(dropdown.Trigger, 6)
	local edge = stroke(dropdown.Trigger, function(theme)
		if dropdown.Open then
			return theme.accent
		end
		return state.hovered and theme.lineStrong or theme.line
	end)
	dropdown.Display = new("TextLabel", {
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(9, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Theme = {
			TextColor3 = function(theme)
				return dropdown:_empty() and theme.muted or theme.text
			end,
		},
		Parent = dropdown.Trigger,
	})
	dropdown.Chevron = new("TextLabel", {
		Text = "›",
		FontFace = Fonts.medium,
		TextSize = 16,
		Rotation = 90,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -6, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		Theme = {
			TextColor3 = function(theme)
				return dropdown.Open and theme.accent or theme.muted
			end,
		},
		Parent = dropdown.Trigger,
	})
	dropdown.Painted = { edge, dropdown.Display, dropdown.Chevron }
	window:_hover(dropdown.Trigger, state, dropdown.Painted)
	window:_connect(dropdown.Trigger.MouseButton1Click, function()
		dropdown:Toggle()
	end)
	dropdown:_render(true)
	return dropdown
end

function Dropdown:_coerce(value)
	if not self.Multi then
		if value == nil then
			return nil
		end
		return tostring(value)
	end
	local set = {}
	if type(value) == "table" then
		for key, entry in pairs(value) do
			if type(key) == "number" then
				set[tostring(entry)] = true
			elseif entry then
				set[tostring(key)] = true
			end
		end
	elseif value ~= nil then
		set[tostring(value)] = true
	end
	return set
end

function Dropdown:_same(value)
	if not self.Multi then
		return self.Value == value
	end
	for key in pairs(value) do
		if not self.Value[key] then
			return false
		end
	end
	for key in pairs(self.Value) do
		if not value[key] then
			return false
		end
	end
	return true
end

function Dropdown:_empty()
	if self.Multi then
		return next(self.Value) == nil
	end
	return self.Value == nil
end

function Dropdown:_selected(item)
	if self.Multi then
		return self.Value[item] == true
	end
	return self.Value == item
end

function Dropdown:Get()
	if self.Multi then
		return table.clone(self.Value)
	end
	return self.Value
end

function Dropdown:_text()
	if not self.Multi then
		return self.Value or self.Config.Placeholder or "Select..."
	end
	local chosen = {}
	for _, item in ipairs(self.Items) do
		if self.Value[item] then
			table.insert(chosen, item)
		end
	end
	if #chosen == 0 then
		return self.Config.Placeholder or "None"
	end
	return table.concat(chosen, ", ")
end

function Dropdown:_render(instant)
	self.Display.Text = self:_text()
	repaintAll(self.Painted, instant)
	local rotation = self.Open and -90 or 90
	if instant then
		self.Chevron.Rotation = rotation
	else
		tween(self.Chevron, { Rotation = rotation })
	end
	if self.Views then
		for _, view in pairs(self.Views) do
			repaintAll(view.Painted, instant)
		end
	end
end

function Dropdown:_build()
	local window = self.Window
	self.Popup = window:_popupFrame(160)
	layout(self.Popup, 4)
	if self.Config.Search or #self.Items > 8 then
		self.Search = new("TextBox", {
			PlaceholderText = "Search",
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 0,
			Size = UDim2.new(1, 0, 0, 26),
			Theme = { BackgroundColor3 = "base", TextColor3 = "text", PlaceholderColor3 = "muted" },
			Parent = self.Popup,
		})
		corner(self.Search, 5)
		stroke(self.Search, "lineSoft")
		padding(self.Search, 0, 8)
		window:_connect(self.Search:GetPropertyChangedSignal("Text"), function()
			self:_filter()
		end)
	end
	self.List = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 0),
		LayoutOrder = 1,
		Theme = { ScrollBarImageColor3 = "line" },
		Parent = self.Popup,
	})
	layout(self.List, 2)
	self:_populate()
end

function Dropdown:_populate()
	local window = self.Window
	for _, view in pairs(self.Views or {}) do
		view.Button:Destroy()
	end
	self.Views = {}
	for index, item in ipairs(self.Items) do
		local state = { hovered = false }
		local button = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = index,
			BackgroundTransparency = 0,
			Theme = {
				BackgroundColor3 = function(theme)
					return state.hovered and theme.hover or theme.raised
				end,
			},
			Parent = self.List,
		})
		corner(button, 5)
		local label = new("TextLabel", {
			Text = item,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -30, 1, 0),
			Theme = {
				TextColor3 = function(theme)
					return (state.hovered or self:_selected(item)) and theme.text or theme.textSoft
				end,
			},
			Parent = button,
		})
		local check = new("TextLabel", {
			Text = "✓",
			FontFace = Fonts.semibold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Center,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(14, 14),
			Theme = {
				TextColor3 = "accent",
				TextTransparency = function()
					return self:_selected(item) and 0 or 1
				end,
			},
			Parent = button,
		})
		local view = { Button = button, Item = item, Painted = { button, label, check } }
		window:_hover(button, state, view.Painted)
		window:_connect(button.MouseButton1Click, function()
			self:_choose(item)
		end)
		self.Views[index] = view
	end
	self:_filter()
end

function Dropdown:_filter()
	local query = self.Search and self.Search.Text:lower() or ""
	local shown = 0
	for _, view in pairs(self.Views) do
		local visible = query == "" or view.Item:lower():find(query, 1, true) ~= nil
		view.Button.Visible = visible
		if visible then
			shown += 1
		end
	end
	local height = math.clamp(shown, 1, 7) * 28 - 2
	self.List.Size = UDim2.new(1, 0, 0, height)
	self.Popup.Size = UDim2.fromOffset(self.Popup.Size.X.Offset, height + 8 + (self.Search and 30 or 0))
end

function Dropdown:_choose(item)
	if self.Multi then
		local value = table.clone(self.Value)
		value[item] = not value[item] or nil
		self:Set(value)
		return
	end
	if self.Value == item and self.Config.AllowNone then
		self:Set(nil)
	else
		self:Set(item)
	end
	self.Window:_closePopup(self)
end

function Dropdown:Show()
	if self.Locked then
		return
	end
	if not self.Popup then
		self:_build()
	end
	local window = self.Window
	local width = math.max(math.floor(self.Trigger.AbsoluteSize.X / window.UIScale), 160)
	self.Popup.Size = UDim2.fromOffset(width, self.Popup.Size.Y.Offset)
	if self.Search then
		self.Search.Text = ""
	end
	self:_filter()
	self.Open = true
	window:_openPopup(self.Popup, self.Trigger, self, function()
		self.Open = false
		self:_render()
	end)
	self:_render()
end

function Dropdown:Hide()
	self.Window:_closePopup(self)
end

function Dropdown:Toggle()
	if self.Open then
		self:Hide()
	else
		self:Show()
	end
end

function Dropdown:Refresh(items)
	self.Items = {}
	for index, item in ipairs(items or {}) do
		self.Items[index] = tostring(item)
	end
	if self.Multi then
		local value = {}
		for item in pairs(self.Value) do
			if table.find(self.Items, item) then
				value[item] = true
			end
		end
		self:Set(value)
	elseif self.Value and not table.find(self.Items, self.Value) then
		self:Set(nil)
	end
	if self.Popup then
		self:_populate()
	end
	self:_render()
	return self
end

Dropdown.SetOptions = Dropdown.Refresh

function Section:Input(options)
	options = options or {}
	local input = self:_element(Input, options)
	local window = self.Window
	local state = { hovered = false, focused = false }
	input.Numeric = options.Numeric == true
	input.Value = input:_coerce(options.Default)

	input.Box = new("TextBox", {
		PlaceholderText = options.Placeholder or "",
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClipsDescendants = true,
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(options.Width or 140, 26),
		Theme = { BackgroundColor3 = "base", TextColor3 = "text", PlaceholderColor3 = "muted" },
		Parent = input.Controls,
	})
	corner(input.Box, 6)
	local edge = stroke(input.Box, function(theme)
		if state.focused then
			return theme.accent
		end
		return state.hovered and theme.lineStrong or theme.line
	end)
	padding(input.Box, 0, 8)
	input.Painted = { edge }
	window:_hover(input.Box, state, input.Painted)
	window:_connect(input.Box.Focused, function()
		state.focused = true
		repaintAll(input.Painted)
	end)
	window:_connect(input.Box.FocusLost, function()
		state.focused = false
		input:Set(input.Box.Text)
		input:_render()
	end)
	window:_connect(input.Box:GetPropertyChangedSignal("Text"), function()
		local text = input.Box.Text
		if input.Numeric then
			text = text:gsub("[^%d%.%-]", "")
		end
		if options.MaxLength then
			text = text:sub(1, options.MaxLength)
		end
		if text ~= input.Box.Text then
			input.Box.Text = text
		elseif options.Live and state.focused then
			input:Set(text)
		end
	end)

	if not options.Name then
		input.Info.Visible = false
		input.Controls.AutomaticSize = Enum.AutomaticSize.None
		input.Controls.Size = UDim2.fromScale(1, 1)
		input.Box.Size = UDim2.new(1, 0, 0, 26)
	end
	input:_render(true)
	return input
end

function Input:_coerce(value)
	if self.Numeric then
		local number = tonumber(value)
		if number == nil then
			return self.Value
		end
		if self.Config.Min then
			number = math.max(number, self.Config.Min)
		end
		if self.Config.Max then
			number = math.min(number, self.Config.Max)
		end
		return number
	end
	if value == nil then
		return ""
	end
	return tostring(value)
end

function Input:_render(instant)
	repaintAll(self.Painted, instant)
	if not self.Box:IsFocused() then
		self.Box.Text = self.Value ~= nil and tostring(self.Value) or ""
	end
end

function Input:Focus()
	self.Box:CaptureFocus()
end

function Keybind:_build(parent, order)
	local window = self.Window
	local state = { hovered = false }
	self.Cap = new("TextButton", {
		FontFace = Fonts.mono,
		TextSize = 11,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		LayoutOrder = order,
		BackgroundTransparency = 0,
		Theme = {
			BackgroundColor3 = "base",
			TextColor3 = function(theme)
				if window.Listening == self then
					return theme.accent
				end
				return self.Value and theme.textSoft or theme.muted
			end,
		},
		Parent = parent,
	})
	corner(self.Cap, 4)
	local edge = stroke(self.Cap, function(theme)
		if window.Listening == self then
			return theme.accent
		end
		return state.hovered and theme.lineStrong or theme.line
	end)
	padding(self.Cap, 0, 7)
	new("UISizeConstraint", { MinSize = Vector2.new(24, 20), Parent = self.Cap })
	self.Painted = { self.Cap, edge }
	window:_hover(self.Cap, state, self.Painted)
	window:_tooltip(self.Cap, "Click, then press a key. Backspace clears it.")
	window:_connect(self.Cap.MouseButton1Click, function()
		if self.CapturedAt and os.clock() - self.CapturedAt < 0.3 then
			return
		end
		window:_listen(self)
	end)
	table.insert(window.Binds, self)
end

function Section:Keybind(options)
	options = options or {}
	local bind = self:_element(Keybind, options)
	bind.Mode = options.Mode or "Press"
	bind.Value = parseKey(options.Default)
	bind:_build(bind.Controls, 1)
	bind:_render(true)
	return bind
end

function Toggle:AddKeybind(options)
	options = options or {}
	local bind = setmetatable({
		Section = self.Section,
		Window = self.Window,
		Config = options,
		Listeners = {},
		Painted = {},
		Row = self.Row,
		Target = self,
		Mode = options.Mode or "Toggle",
	}, Keybind)
	bind.Value = parseKey(options.Default)
	bind:_build(self.Controls, 1)
	bind:_render(true)
	self.Keybind = bind
	return bind
end

function Keybind:_coerce(value)
	return parseKey(value)
end

function Keybind:_render(instant)
	repaintAll(self.Painted, instant)
	self.Cap.Text = self.Window.Listening == self and "..." or keyLabel(self.Value)
end

function Keybind:_changed()
	fire(self.Config.ChangedCallback, self.Value)
	for _, listener in ipairs(self.Listeners) do
		fire(listener, self.Value)
	end
end

function Keybind:_capture(input)
	local kind = input.UserInputType
	local key = self.Value
	if kind == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.Backspace then
			key = nil
		elseif input.KeyCode ~= Enum.KeyCode.Escape then
			key = input.KeyCode
		end
	elseif kind == Enum.UserInputType.MouseButton2 or kind == Enum.UserInputType.MouseButton3 then
		key = kind
	elseif kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then
		return false
	end
	self.CapturedAt = os.clock()
	self.Window.Listening = nil
	self:Set(key)
	self:_render()
	return true
end

function Keybind:_press()
	if self.Locked or (self.Target and self.Target.Locked) then
		return
	end
	local target = self.Target
	if self.Mode == "Hold" then
		self.Held = true
		if target then
			target:Set(true)
		end
		fire(self.Config.Callback, true)
	elseif self.Mode == "Toggle" then
		if target then
			target:Set(not target.Value)
			self.Active = target.Value
		else
			self.Active = not self.Active
		end
		fire(self.Config.Callback, self.Active)
	else
		fire(self.Config.Callback)
	end
end

function Keybind:_release()
	if self.Mode ~= "Hold" or not self.Held then
		return
	end
	self.Held = false
	if self.Target then
		self.Target:Set(false)
	end
	fire(self.Config.Callback, false)
end

function Keybind:GetState()
	if self.Mode == "Hold" then
		return self.Held == true
	end
	if self.Target then
		return self.Target.Value
	end
	return self.Active == true
end

function Keybind:SetMode(mode)
	self.Mode = mode
	return self
end

function Keybind:SetVisible(visible)
	if self.Target then
		self.Cap.Visible = visible ~= false
		return self
	end
	return Element.SetVisible(self, visible)
end

function Keybind:SetLocked(locked, reason)
	if self.Target then
		self.Locked = locked ~= false
		return self
	end
	return Element.SetLocked(self, locked, reason)
end

function Keybind:Destroy()
	local window = self.Window
	if window.Listening == self then
		window.Listening = nil
	end
	if not self.Target then
		return Element.Destroy(self)
	end
	local index = table.find(window.Binds, self)
	if index then
		table.remove(window.Binds, index)
	end
	self.Target.Keybind = nil
	self.Cap:Destroy()
end

function Section:ColorPicker(options)
	options = options or {}
	local picker = self:_element(ColorPicker, options)
	local window = self.Window
	local state = { hovered = false }
	picker.Value = toColor(options.Default) or Color3.new(1, 1, 1)
	picker.Transparency = options.Transparency
	picker.Hue, picker.Saturation, picker.Brightness = picker.Value:ToHSV()

	picker.Swatch = new("TextButton", {
		Size = UDim2.fromOffset(30, 18),
		BackgroundTransparency = 0,
		Parent = picker.Controls,
	})
	corner(picker.Swatch, 5)
	local edge = stroke(picker.Swatch, function(theme)
		if picker.Open then
			return theme.accent
		end
		return state.hovered and theme.text or theme.lineStrong
	end)
	picker.Painted = { edge }
	window:_hover(picker.Swatch, state, picker.Painted)
	window:_connect(picker.Swatch.MouseButton1Click, function()
		if picker.Open then
			window:_closePopup(picker)
		else
			picker:Show()
		end
	end)
	picker:_render(true)
	return picker
end

function ColorPicker:_build()
	local window = self.Window
	local alpha = self.Transparency ~= nil
	local popup = window:_popupFrame(196, 8)
	local view = {}

	view.Field = new("Frame", { Active = true, Size = UDim2.new(1, 0, 0, 112), Parent = popup })
	corner(view.Field, 5)
	local white = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), Parent = view.Field })
	corner(white, 5)
	new("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = white })
	local black = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(), Parent = view.Field })
	corner(black, 5)
	new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
	view.Cursor = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(10, 10),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = view.Field,
	})
	corner(view.Cursor, 5)
	new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = view.Cursor })

	local function bar(top)
		local frame = new("Frame", {
			Active = true,
			Position = UDim2.fromOffset(0, top),
			Size = UDim2.new(1, 0, 0, 10),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Parent = popup,
		})
		corner(frame, 5)
		local cursor = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(6, 14),
			BackgroundTransparency = 1,
			Parent = frame,
		})
		corner(cursor, 3)
		new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, Parent = cursor })
		return frame, cursor
	end

	local spectrum = {}
	for index = 0, 6 do
		table.insert(spectrum, ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1)))
	end
	view.Hue, view.HueCursor = bar(120)
	new("UIGradient", { Color = ColorSequence.new(spectrum), Parent = view.Hue })
	local top = 138
	if alpha then
		view.Alpha, view.AlphaCursor = bar(138)
		new("UIGradient", { Transparency = NumberSequence.new(1, 0), Parent = view.Alpha })
		stroke(view.Alpha, "lineSoft")
		top = 156
	end

	view.Hex = new("TextBox", {
		FontFace = Fonts.mono,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 0,
		Position = UDim2.fromOffset(0, top),
		Size = UDim2.new(1, 0, 0, 26),
		Theme = { BackgroundColor3 = "base", TextColor3 = "text" },
		Parent = popup,
	})
	corner(view.Hex, 5)
	stroke(view.Hex, "lineSoft")
	padding(view.Hex, 0, 8)
	popup.Size = UDim2.fromOffset(196, top + 42)

	local function ratio(frame, point)
		local position, size = frame.AbsolutePosition, frame.AbsoluteSize
		return math.clamp((point.X - position.X) / math.max(size.X, 1), 0, 1), math.clamp((point.Y - position.Y) / math.max(size.Y, 1), 0, 1)
	end
	local function track(frame, apply)
		window:_drag(frame, function(point)
			apply(ratio(frame, point))
		end, function(_, point)
			apply(ratio(frame, point))
		end)
	end
	track(view.Field, function(x, y)
		self.Saturation, self.Brightness = x, 1 - y
		self:_commit()
	end)
	track(view.Hue, function(x)
		self.Hue = x
		self:_commit()
	end)
	if alpha then
		track(view.Alpha, function(x)
			self.Transparency = 1 - x
			self:_commit()
		end)
	end
	window:_connect(view.Hex.FocusLost, function()
		local color = toColor((view.Hex.Text:gsub("[^%x]", "")))
		if color then
			self:Set(color)
		end
		self:_render()
	end)

	self.Popup, self.View = popup, view
end

function ColorPicker:_commit()
	self.Value = Color3.fromHSV(self.Hue, self.Saturation, self.Brightness)
	self:_render()
	self:_changed()
end

function ColorPicker:Get()
	return self.Value, self.Transparency
end

function ColorPicker:Set(color, transparency, silent)
	color = toColor(color) or self.Value
	local hue, saturation, brightness = color:ToHSV()
	if saturation > 0 and brightness > 0 then
		self.Hue = hue
	end
	self.Saturation, self.Brightness = saturation, brightness
	self.Value = color
	if transparency ~= nil and self.Transparency ~= nil then
		self.Transparency = math.clamp(transparency, 0, 1)
	end
	self:_render()
	if not silent then
		self:_changed()
	end
	return self
end

function ColorPicker:_render(instant)
	repaintAll(self.Painted, instant)
	self.Swatch.BackgroundColor3 = self.Value
	self.Swatch.BackgroundTransparency = self.Transparency or 0
	local view = self.View
	if not view then
		return
	end
	view.Field.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
	view.Cursor.Position = UDim2.fromScale(self.Saturation, 1 - self.Brightness)
	view.HueCursor.Position = UDim2.fromScale(self.Hue, 0.5)
	if view.Alpha then
		view.Alpha.BackgroundColor3 = self.Value
		view.AlphaCursor.Position = UDim2.fromScale(1 - self.Transparency, 0.5)
	end
	if not view.Hex:IsFocused() then
		view.Hex.Text = "#" .. self.Value:ToHex():upper()
	end
end

function ColorPicker:Show()
	if self.Locked then
		return
	end
	if not self.Popup then
		self:_build()
	end
	self.Open = true
	self.Window:_openPopup(self.Popup, self.Swatch, self, function()
		self.Open = false
		self:_render()
	end)
	self:_render()
end

function ColorPicker:Hide()
	self.Window:_closePopup(self)
end

function Chimera:Notify(options)
	local window = self.Windows[#self.Windows]
	if window then
		return window:Notify(options)
	end
end

function Chimera:Unload()
	for index = #self.Windows, 1, -1 do
		self.Windows[index]:Destroy()
	end
end

return Chimera
