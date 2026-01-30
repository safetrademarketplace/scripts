local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RayfieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},

		Ocean = {
			TextColor = Color3.fromRGB(230, 240, 240),

			Background = Color3.fromRGB(20, 30, 30),
			Topbar = Color3.fromRGB(25, 40, 40),
			Shadow = Color3.fromRGB(15, 20, 20),

			NotificationBackground = Color3.fromRGB(25, 35, 35),
			NotificationActionsBackground = Color3.fromRGB(230, 240, 240),

			TabBackground = Color3.fromRGB(40, 60, 60),
			TabStroke = Color3.fromRGB(50, 70, 70),
			TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
			TabTextColor = Color3.fromRGB(210, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(20, 50, 50),

			ElementBackground = Color3.fromRGB(30, 50, 50),
			ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
			ElementStroke = Color3.fromRGB(45, 70, 70),
			SecondaryElementStroke = Color3.fromRGB(40, 65, 65),

			SliderBackground = Color3.fromRGB(0, 110, 110),
			SliderProgress = Color3.fromRGB(0, 140, 140),
			SliderStroke = Color3.fromRGB(0, 160, 160),

			ToggleBackground = Color3.fromRGB(30, 50, 50),
			ToggleEnabled = Color3.fromRGB(0, 130, 130),
			ToggleDisabled = Color3.fromRGB(70, 90, 90),
			ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
			ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
			ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),

			DropdownSelected = Color3.fromRGB(30, 60, 60),
			DropdownUnselected = Color3.fromRGB(25, 40, 40),

			InputBackground = Color3.fromRGB(30, 50, 50),
			InputStroke = Color3.fromRGB(50, 70, 70),
			PlaceholderColor = Color3.fromRGB(140, 160, 160)
		},

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200), 
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235), 
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240), 
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45), 
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), 
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60), 
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235),  -- Lighter shade
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
	}
}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInputManager")

local localPlayer = Players.LocalPlayer

local defaultWalkSpeed, defaultJumpPower, defaultJumpHeight
local function updateDefaultHumanoidValues(humanoid)
    if humanoid then
        defaultWalkSpeed = humanoid.WalkSpeed
        defaultJumpPower = humanoid.JumpPower
        if humanoid.UseJumpPower ~= nil and humanoid.UseJumpPower == false then
            defaultJumpHeight = humanoid.JumpHeight
        else
            defaultJumpHeight = nil
        end
    end
end

if localPlayer.Character then
    local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    updateDefaultHumanoidValues(hum)
else
    -- Wait for character if not spawned
    localPlayer.CharacterAdded:Wait()
    local hum = localPlayer.Character:WaitForChild("Humanoid")
    updateDefaultHumanoidValues(hum)
end

-- Setup main Window
local Window = Rayfield:CreateWindow({
    Name = "Bubble Gum Infinity Sim | Cerberus",
    LoadingTitle = "Loading Bubble Gum Infinity Sim...",
    LoadingSubtitle = "Cerberus | Premium Scripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Cerberus",
        FileName = "BubbleConfig"
    }
})

-- Flags and state variables
local highJumpEnabled = false
local highJumpPower = 500

local noFogEnabled = false
local perfModeEnabled = false
local noVoidEnabled = false
local infZoomEnabled = false

local autoBlowEnabled = false
local autoSellEnabled = false
local autoPickupEnabled = false
local sellThreshold = 50 

-- Variables for auto bubble logic
local blowCount = 0
local capacityCalls = 1000 
local bubbleFullDetected = false
local lastBubbleSize = nil

-- MAIN Tab
local MainTab = Window:CreateTab("Main", "home")  -- using a generic icon (ID 4483362458)

MainTab:CreateSection("Movement")

-- High Jump Toggle + Slider
local HighJumpToggle = MainTab:CreateToggle({
    Name = "High Jump",
    CurrentValue = false,
    Flag = "HighJumpToggle",
    Callback = function(state)
        highJumpEnabled = state
        local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if state then
            if humanoid then
                -- Store default jump and apply higher jump power/height
                defaultJumpPower = humanoid.JumpPower
                defaultJumpHeight = humanoid.UseJumpPower == false and humanoid.JumpHeight or defaultJumpHeight
                if humanoid.UseJumpPower ~= nil then humanoid.UseJumpPower = true end
                humanoid.JumpPower = highJumpPower
            end
        else
            if humanoid then
                -- Restore default jump values
                if humanoid.UseJumpPower ~= nil and defaultJumpHeight then
                    humanoid.UseJumpPower = false
                    humanoid.JumpHeight = defaultJumpHeight
                else
                    humanoid.JumpPower = defaultJumpPower or 50
                end
            end
        end
    end
})
local HighJumpSlider = MainTab:CreateSlider({
    Name = "Jump Height",
    Range = {50, 5000},
    Increment = 10,
    Suffix = "",
    CurrentValue = 500,
    Flag = "HighJumpPower",
    Callback = function(value)
        highJumpPower = value
        if highJumpEnabled then
            local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.UseJumpPower ~= nil then hum.UseJumpPower = true end
                hum.JumpPower = highJumpPower
            end
        end
    end
})

MainTab:CreateSection("Royal Rift Chest")

MainTab:CreateButton({
	Name = "Check for Royal Rift Chest",
	Callback = function()
		local chest = workspace:FindFirstChild("Rendered") and workspace.Rendered.Rifts:FindFirstChild("royal-chest")
		if chest and chest:IsA("Model") then
			local y = chest:GetPivot().Position.Y
			Rayfield:Notify({
				Title = "Royal Rift Chest Found",
				Content = "Height: " .. tostring(math.floor(y)) .. " studs",
				Duration = 5
			})
		else
			Rayfield:Notify({
				Title = "Chest Not Found",
				Content = "No Royal Rift Chest detected.",
				Duration = 5
			})
		end
	end
})

MainTab:CreateButton({
	Name = "Go to Royal Rift Chest",
	Callback = function()
		local chest = workspace:FindFirstChild("Rendered") and workspace.Rendered.Rifts:FindFirstChild("royal-chest")
		if chest and chest:IsA("Model") then
			local y = chest:GetPivot().Position.Y
			Rayfield:Notify({
				Title = "Moving to Royal Rift Chest",
				Content = "Height: " .. tostring(math.floor(y)) .. " studs",
				Duration = 4
			})

			-- Tween Setup
			local TweenService = game:GetService("TweenService")
			local Players = game:GetService("Players")
			local player = Players.LocalPlayer

			local function setCharacterCollision(state, char)
				char = char or player.Character
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = state
					end
				end
			end

			local function moveToTarget(target, speed, callback)
				if typeof(target) ~= "Vector3" or typeof(speed) ~= "number" then
					if callback then callback() end
					return
				end

				local character = player.Character or player.CharacterAdded:Wait()
				local hrp = character:WaitForChild("HumanoidRootPart")
				setCharacterCollision(false, character)
				local startPos = hrp.Position
				local distance = (target - startPos).Magnitude
				local duration = distance / speed

				local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
				tween:Play()
				tween.Completed:Connect(function()
					setCharacterCollision(true, character)
					if callback then callback() end
				end)
			end

			local targetPosition = chest:GetPivot().Position + Vector3.new(0, 35, 0)
			moveToTarget(targetPosition, 500)
		else
			Rayfield:Notify({
				Title = "Chest Not Found",
				Content = "No Royal Rift Chest detected.",
				Duration = 5
			})
		end
	end
})

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local royalChestHopperEnabled = false

MainTab:CreateToggle({
	Name = "Server Hop Until Royal Rift Chest",
	Flag = "RoyalChestHop",
	CurrentValue = false,
	Callback = function(state)
		royalChestHopperEnabled = state

		if state then
			task.spawn(function()
				while royalChestHopperEnabled do
					local chest = workspace:FindFirstChild("Rendered") and workspace.Rendered.Rifts:FindFirstChild("royal-chest")
					if chest and chest:IsA("Model") then
						Rayfield:Notify({
							Title = "Royal Rift Chest Found",
							Content = "Chest found in this server.",
							Duration = 5
						})
						royalChestHopperEnabled = false
						break
					end

					-- Get list of public servers
					local success, response = pcall(function()
						return HttpService:JSONDecode(game:HttpGet(
							string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
						))
					end)

					if success and response and response.data then
						local currentJobId = game.JobId
						local servers = response.data

						-- Pick random new server
						local viable = {}
						for _, s in ipairs(servers) do
							if s.playing < s.maxPlayers and s.id ~= currentJobId then
								table.insert(viable, s.id)
							end
						end

						if #viable > 0 then
							local randomServer = viable[math.random(1, #viable)]
							TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
						else
							Rayfield:Notify({
								Title = "No Servers Available",
								Content = "Retrying in 5 seconds...",
								Duration = 5
							})
							task.wait(5)
						end
					else
						warn("Failed to fetch servers")
						task.wait(5)
					end
				end
			end)
		end
	end
})



MainTab:CreateSection("Gum Selector")

-- Define options for the gum dropdown (template items)
local updateOptions = { "Bubble Gum", "Blueberry", "Cherry", "Pizza", "Watermelon", "Chocolate", "Contrast", "Gold", "Lemon", "Donut", "Swirl", "Molten" }
local storageOptions = { "Basic Gum", "Stretchy Gum", "VIP Gum", "Chewy Gum", "Epic Gum", "Ultra Gum", "Omega Gum", "Unreal Gum", "Cosmic Gum", "XL Gum", "Mega Gum", "Quantum Gum", "Alien Gum", "Radioactive Gum", "Experiment #52" }

if SelectedItem == "" then
    return
end
if SelectedStorage == "" then
    return
end


-- Create the Gum dropdown for selecting the item
local ItemDropdown = MainTab:CreateDropdown({
    Name = "Select Update Item",
    Options = updateOptions,
    CurrentOption = "",  -- Set default selection to empty
    Flag = "ItemDropdown",
    Callback = function(option)
        local choice = typeof(option) == "table" and option[1] or option
        if choice then
            SelectedItem = choice  -- Update the selected gum flavor
        end
    end
})

-- Create the Storage dropdown for selecting storage
local StorageDropdown = MainTab:CreateDropdown({
    Name = "Select Storage Item",
    Options = storageOptions,
    CurrentOption = "",  -- Set default selection to empty
    Flag = "StorageDropdown",
    Callback = function(option)
        local choice = typeof(option) == "table" and option[1] or option
        if choice then
            SelectedStorage = choice  -- Update the selected storage item
        end
    end
})

-- Button to trigger the auto-update action with selected item
MainTab:CreateButton({
    Name = "Update Flavor",
    Callback = function()
        if SelectedItem == "" then
            return
        end
        
        local args = {
            [1] = "UpdateFlavor",
            [2] = SelectedItem  -- Use the selected gum item from the dropdown
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
        
        print("Favor updated to: " .. SelectedItem)
    end
})

-- Button to trigger the auto-update action with selected storage
MainTab:CreateButton({
    Name = "Update Storage",
    Callback = function()
        if SelectedStorage == "" then
            print("Please select a storage item.")
            return
        end
        
        local args = {
            [1] = "UpdateStorage",
            [2] = SelectedStorage  -- Use the selected storage item from the dropdown
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
        
        print("Storage updated to: " .. SelectedStorage)
    end
})

-- Button to trigger the purchase action for both gum and storage
MainTab:CreateButton({
    Name = "Buy Both Items",
    Callback = function()
        if SelectedItem == "" then
            return
        end
        
        if SelectedStorage == "" then
            return
        end
        
        -- Buy the selected gum item
        local gumArgs = {
            [1] = "GumShopPurchase",
            [2] = SelectedItem  -- Use the selected gum item from the dropdown
        }
        
        -- Buy the selected storage item
        local storageArgs = {
            [1] = "GumShopPurchase",
            [2] = SelectedStorage  -- Use the selected storage item from the dropdown
        }

        -- Fire the purchase events for both gum and storage
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(gumArgs))
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(storageArgs))
        
        print("Purchased: " .. SelectedItem .. " and " .. SelectedStorage)
    end
})


MainTab:CreateSection("Utils")

local VirtualInput = game:GetService("VirtualInputManager")

local antiAfkEnabled = false

MainTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(state)
        antiAfkEnabled = state

        if antiAfkEnabled then

            task.spawn(function()
                while antiAfkEnabled do
                    -- Press and release A (left)
                    VirtualInput:SendKeyEvent(true, Enum.KeyCode.A, false, game)
                    task.wait(0.2)
                    VirtualInput:SendKeyEvent(false, Enum.KeyCode.A, false, game)

                    task.wait(0.5)

                    -- Press and release D (right)
                    VirtualInput:SendKeyEvent(true, Enum.KeyCode.D, false, game)
                    task.wait(0.2)
                    VirtualInput:SendKeyEvent(false, Enum.KeyCode.D, false, game)

                    task.wait(300) -- Repeat every 60 seconds
                end
            end)
        end
    end
})


-- Respawn Button
--// SERVICES
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
HRP = Character:WaitForChild("HumanoidRootPart")

local touchParts = {
    workspace.Worlds["The Overworld"].Islands["Floating Island"].Island.UnlockHitbox,
    workspace.Worlds["The Overworld"].Islands["Outer Space"].Island.UnlockHitbox,
    workspace.Worlds["The Overworld"].Islands["The Void"].Island.UnlockHitbox,
    workspace.Worlds["The Overworld"].Islands.Twilight.Island.UnlockHitbox,
    workspace.Worlds["The Overworld"].Islands.Zen.Island.UnlockHitbox,
}

--// FUNCTION: Trigger all TouchInterests
local function fireAllTouchInterests()
    for _, part in ipairs(touchParts) do
        if part and part:IsA("BasePart") then
            pcall(function()
                firetouchinterest(HRP, part, 0) -- Touch begin
                firetouchinterest(HRP, part, 1) -- Touch end
            end)
        end
        task.wait(1)
    end
end

--// UI Button
MainTab:CreateButton({
    Name = "Unlock All Islands",
    Callback = function()
        fireAllTouchInterests()
    end
})

-- Fullbright function implementation
local fullbrightEnabled = false
local originalSettings = {}

-- Function to store original settings before enabling fullbright
local function storeOriginalSettings()
    originalSettings = {
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        GlobalShadows = Lighting.GlobalShadows,
        Ambient = Lighting.Ambient
    }
end

-- Function to enable or disable fullbright
local function setFullbright(enabled)
    fullbrightEnabled = enabled
    if enabled then
        storeOriginalSettings()
    else
        if next(originalSettings) then
            Lighting.Brightness = originalSettings.Brightness
            Lighting.ClockTime = originalSettings.ClockTime
            Lighting.GlobalShadows = originalSettings.GlobalShadows
            Lighting.Ambient = originalSettings.Ambient
        end
    end
end

-- Continuously apply fullbright settings when enabled
RunService.RenderStepped:Connect(function()
    if fullbrightEnabled then
        Lighting.Brightness = 0.6
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
end)

-- Fullbright Toggle
local FullbrightToggle = MainTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(state)
        setFullbright(state)  -- Toggle fullbright on or off
    end
})

-- Respawn Button
MainTab:CreateButton({
    Name = "Respawn",
    Callback = function()
        local char = localPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0  -- kill the player to force respawn
            else
                -- Fallback if no humanoid
                char:BreakJoints()
            end
        end
    end
})

-- Performance Mode Toggle
local PerformanceToggle = MainTab:CreateToggle({
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
                elseif obj:IsA("BasePart") and not obj:IsDescendantOf(localPlayer.Character) then
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
            -- Re-enable effects and restore parts
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

-- AUTOS Tab
local AutosTab = Window:CreateTab("Autos", "bot")

AutosTab:CreateSection("AutoFarm")

-- Auto Blow Bubbles with Toggle
local VIM = game:GetService("VirtualInputManager")
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize

local absX = 0.1 * screenSize.X
local absY = 0.2 * screenSize.Y
local autoBlowEnabled = false

AutosTab:CreateParagraph({
    Title = "AutoBubble Requirement",
    Content = "For AutoBubble to work make sure you close chat."
})

-- Toggle button for Auto Blow Bubbles
local AutoBlowToggle = AutosTab:CreateToggle({
    Name = "AutoBubble",
    CurrentValue = false,
    Flag = "AutoBlowToggle",
    Callback = function(state)
        autoBlowEnabled = state
        if state then
            -- Start the bubble blowing hold
            spawn(function()
                while autoBlowEnabled do
                    -- Press and hold mouse
                    VIM:SendMouseButtonEvent(absX, absY, 0, true, game, 0)
                    task.wait(1) -- Hold for 1 second

                    -- Release mouse
                    VIM:SendMouseButtonEvent(absX, absY, 0, false, game, 0)
                    task.wait(0.01) -- Short gap before next press
                end
            end)
        end
    end
})

-- Auto Sell Bubbles with Toggle
local SELL_THRESHOLD = 30 -- Default Sell threshold

local label = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui")
    :WaitForChild("HUD")
    :WaitForChild("Left")
    :WaitForChild("Currency")
    :WaitForChild("Bubble")
    :WaitForChild("Frame")
    :WaitForChild("Label")

local autoSellEnabled = false

local function checkCurrencyProgress()
    local text = label.ContentText or ""  -- Ensure text is not nil
    local x, y = string.match(text, "(%d+)%s*/%s*(%d+)")

    if x and y then
        x, y = tonumber(x), tonumber(y)

        if x and y and y ~= 0 then
            local percentage = math.floor((x / y) * 100 + 0.5)

            if percentage >= SELL_THRESHOLD then
                local args = {
                    [1] = "SellBubble"
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))                
            end
        else
            local args = {
                [1] = "SellBubble"
            }
            
            game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))            
        end
    else
        local args = {
            [1] = "SellBubble"
        }
        
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))        
    end
end


-- Toggle button for Auto Sell Bubbles
local AutoSellToggle = AutosTab:CreateToggle({
    Name = "AutoSell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(state)
        autoSellEnabled = state
        if state then
            spawn(function()
                while autoSellEnabled do
                    checkCurrencyProgress()
                    task.wait(2) -- ✅ now always runs every 5s whether parsed or fallback
                end
            end)
        end
        
    end
})

-- Slider for Sell Threshold
local SellThresholdSlider = AutosTab:CreateSlider({
    Name = "Sell Threshold",
    Range = {1, 100}, -- From 1% to 100%
    Increment = 1,
    Suffix = "%",
    CurrentValue = SELL_THRESHOLD, -- Default threshold
    Flag = "SellThresholdSlider",
    Callback = function(value)
        SELL_THRESHOLD = value
    end
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local collectPickupEvent = ReplicatedStorage:WaitForChild("Remotes")
    :WaitForChild("Pickups")
    :WaitForChild("CollectPickup")

local coinLabel = player:WaitForChild("PlayerGui")
    :WaitForChild("ScreenGui")
    :WaitForChild("HUD")
    :WaitForChild("Left")
    :WaitForChild("Currency")
    :WaitForChild("Coins")
    :WaitForChild("Frame")
    :WaitForChild("Label")

local renderedFolder = workspace:WaitForChild("Rendered")
local failureCount = {}
local autoPickupEnabled = false

local function getTargetFolder()
    local children = renderedFolder:GetChildren()
    return children[12] or nil
end

-- Get closest valid model
local function getClosestModel(folder)
    local closest = nil
    local shortestDistance = math.huge

    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local success, pivot = pcall(function()
                return model:GetPivot().Position
            end)
            if success then
                local distance = (pivot - rootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closest = model
                end
            end
        end
    end

    return closest
end

-- Toggle button for Infinite Pickup
local AutoPickupToggle = AutosTab:CreateToggle({
    Name = "Infinite Collect",
    CurrentValue = false,
    Flag = "AutoPickupToggle",
    Callback = function(state)
        autoPickupEnabled = state
        if state then
            -- Start collecting pickups by continuously checking for nearest pickups
            spawn(function()
                while autoPickupEnabled do
                    local folder = getTargetFolder()
                    if not folder then
                        break
                    end

                    local model = getClosestModel(folder)
                    if model then
                        local modelName = model.Name
                        local before = coinLabel.ContentText

                        collectPickupEvent:FireServer(modelName)

                        -- Verification process for successful collection
                        local verified = false
                        local timeout = 0
                        while timeout < 0.5 do
                            task.wait(0.1)
                            timeout = timeout + 0.1
                            if coinLabel.ContentText ~= before then
                                verified = true
                                break
                            end
                        end

                        -- Handle collection results
                        if verified then
                            model:Destroy()
                            failureCount[modelName] = nil
                        else
                            failureCount[modelName] = (failureCount[modelName] or 0) + 1

                            if failureCount[modelName] >= 2 then
                                model:Destroy()
                            end
                        end
                    else
                        task.wait(0.05)
                    end
                end
            end)
        end
    end
})


-- Section for Auto Hatch
AutosTab:CreateSection("AutoHatch")

AutosTab:CreateParagraph({
    Title = "Hatch Requirement",
    Content = "You must be within range of the selected egg to hatch it."
})

AutosTab:CreateParagraph({
    Title = "AutoDelete Feature",
    Content = "Go to the Pet tab to auto delete unwanted pet types."
})

AutosTab:CreateParagraph({
    Title = "Unlock Requirement",
    Content = "You must be able to afford at least one hatch for unlocking to work"
})

-- Define the egg types
local eggTypes = { "Common Egg", "Spotted Egg", "Iceshard Egg", "Spikey Egg", "Magma Egg", "Crystal Egg", "Lunar Egg", "Void Egg", "Hell Egg", "Nightmare Egg", "Rainbow Egg", "Infinity Egg" }

local selectedEgg = "Iceshard Egg"

-- Dropdown to select egg type
AutosTab:CreateDropdown({
    Name = "Select Egg Type",
    Options = eggTypes,
    CurrentOption = {selectedEgg},
    Flag = "EggTypeDropdown",
    Callback = function(option)
        local choice = typeof(option) == "table" and option[1] or option
        if choice then
            selectedEgg = choice
            print("Selected Egg: " .. selectedEgg)
        end
    end
})

-- Function to unlock and hatch manually
local function unlockAndHatchEgg()
    local eggFolder = workspace.Rendered:GetChildren()[11]
    local selectedEggModel = nil

    for _, model in ipairs(eggFolder:GetChildren()) do
        if model:IsA("Model") and model.Name == selectedEgg then
            selectedEggModel = model
            break
        end
    end

    if selectedEggModel then
        selectedEggModel:SetAttribute("Unlocked", true)
        local args = {
            [1] = "HatchEgg",
            [2] = selectedEgg,
            [3] = 1
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Shared")
            :WaitForChild("Framework"):WaitForChild("Network")
            :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

        print(selectedEgg .. " has been unlocked and hatched!")
    end
end

-- Unlock egg button
AutosTab:CreateButton({
    Name = "Unlock Egg",
    Callback = function()
        unlockAndHatchEgg()
    end
})

-- Toggles
local multiHatch = false
local hatchClosestEnabled = false
local autoHatchRunning = false

AutosTab:CreateToggle({
    Name = "Multi Hatch",
    CurrentValue = false,
    Flag = "MultiHatchToggle",
    Callback = function(state)
        multiHatch = state
        print("[AutoHatch] Multi Hatch is now", state and "ENABLED" or "DISABLED")
    end
})

AutosTab:CreateToggle({
    Name = "Hatch Closest",
    CurrentValue = false,
    Flag = "HatchClosestToggle",
    Callback = function(state)
        hatchClosestEnabled = state
        print("[AutoHatch] Hatch Closest is now", state and "ENABLED" or "DISABLED")
    end
})

-- Get distance from player
local function getDistanceTo(pos)
    local char = Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return (char.HumanoidRootPart.Position - pos).Magnitude
    end
    return math.huge
end

-- Get closest egg
local function getClosestValidEgg()
    local eggFolder = workspace.Rendered:GetChildren()[13]
    local closest, minDist = nil, math.huge

    for _, obj in ipairs(eggFolder:GetChildren()) do
        if table.find(eggTypes, obj.Name) and obj:IsA("Model") then
            local pos = obj:GetPivot().Position
            local dist = getDistanceTo(pos)
            if dist < minDist then
                closest = obj
                minDist = dist
            end
        end
    end

    return closest
end

-- Auto hatch logic
local function toggleAutoHatch(state)
    if state then
        if not autoHatchRunning then
            autoHatchRunning = true
            spawn(function()
                while autoHatchRunning do
                    local hatchAmount = multiHatch and 2 or 1
                    local currentEgg = selectedEgg

                    if hatchClosestEnabled then
                        local closestEgg = getClosestValidEgg()
                        if closestEgg then
                            currentEgg = closestEgg.Name
                        else
                            print("[AutoHatch] No valid nearby eggs found, using selected egg.")
                        end
                    end

                    local args = {
                        [1] = "HatchEgg",
                        [2] = currentEgg,
                        [3] = hatchAmount
                    }

                    game:GetService("ReplicatedStorage"):WaitForChild("Shared")
                        :WaitForChild("Framework"):WaitForChild("Network")
                        :WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

                    wait(0.1)
                end
            end)
        end
    else
        autoHatchRunning = false
    end
end

AutosTab:CreateToggle({
    Name = "AutoHatch",
    CurrentValue = false,
    Flag = "AutoHatchToggle",
    Callback = function(state)
        toggleAutoHatch(state)
    end
})

AutosTab:CreateSection("AutoClaim")

AutosTab:CreateButton({
    Name = "Claim Chests",
    Callback = function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local TeleportRemote = ReplicatedStorage.Shared.Framework.Network.Remote.Event
        local player = game:GetService("Players").LocalPlayer
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

        -- Teleport to Floating Island
        local args1 = {
            [1] = "Teleport",
            [2] = "Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
        }
        TeleportRemote:FireServer(unpack(args1))

        wait(0.1)

        -- Claim Giant Chest
        local args2 = {
            [1] = "ClaimChest",
            [2] = "Giant Chest"
        }
        TeleportRemote:FireServer(unpack(args2))

        wait(1)

-- Teleport to Void Island
local args3 = {
    [1] = "Teleport",
    [2] = "Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
}
TeleportRemote:FireServer(unpack(args3))

wait(0.5)

-- 🧭 Walk to the target location
local destination = Vector3.new(72.83, 10148.05, 69.13) -- 👈 Replace with your actual location
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:FindFirstChildOfClass("Humanoid")
local hrp = char:FindFirstChild("HumanoidRootPart")

if humanoid and hrp then
    humanoid:MoveTo(destination)

    local reached = false
    local connection
    connection = humanoid.MoveToFinished:Connect(function(success)
        reached = true
        connection:Disconnect()
    end)

    local timeout = 4 
    local timer = 0

    while not reached and timer < timeout do
        task.wait(0.1)
        timer += 0.1
    end
end

wait(0.5)

-- Claim Void Chest
local args4 = {
    [1] = "ClaimChest",
    [2] = "Void Chest"
}
TeleportRemote:FireServer(unpack(args4))

print("Claimed both chests successfully.")
    end
})


-- Variable to store the toggle state
local claimGiftActive = false

local function claimGift()
    for i = 1, 9 do
        local args = {
            [1] = "ClaimPlaytime",
            [2] = i
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer(unpack(args))
        wait(0.1)  -- Small wait between each claim to avoid spamming too quickly
    end
end

-- Toggle button for claiming the gift every minute
AutosTab:CreateToggle({
    Name = "AutoGifts",
    CurrentValue = false,
    Flag = "ClaimGiftToggle",
    Callback = function(state)
        claimGiftActive = state
        if claimGiftActive then
            -- Start the loop to claim the gift every minute
            while claimGiftActive do
                claimGift()
                wait(60) 
            end
        end
    end
})

-- Variable to store the toggle state
local claimGiftActive = false

local function claimGift()
    -- Get the player's position
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Function to find the closest part
    local function getClosestGift()
        local closestPart = nil
        local shortestDistance = math.huge  -- Start with a very large number
        local giftParts = workspace.Rendered.Gifts:GetChildren()

        for _, part in ipairs(giftParts) do
            if part:IsA("BasePart") then  -- Ensure we're checking parts
                local distance = (humanoidRootPart.Position - part.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPart = part
                end
            end
        end

        return closestPart
    end

    -- Get the closest gift part
    local closestGift = getClosestGift()

    if closestGift then
        -- Fire the event with the closest gift's ID
        local args = {
            [1] = "ClaimGift",
            [2] = closestGift.Name  -- Using the part's name as the ID
        }

        -- Fire the server event with the closest gift's ID
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))

        -- Delete the closest gift after claiming
        closestGift:Destroy()
    end
end

AutosTab:CreateToggle({
    Name = "AutoMysteryBox",
    CurrentValue = false,
    Flag = "AutoClaimGiftsToggle",
    Callback = function(state)
        claimGiftActive = state
        if claimGiftActive then
            -- Start the loop to claim the gift every 2 seconds
            spawn(function()
                while claimGiftActive do
                    local args = {
                        [1] = "UseGift",
                        [2] = "Mystery Box",
                        [3] = 3
                    }
                    
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
                    wait(0.3)                    
                    claimGift()
                    wait(0.05)
                    claimGift()
                    wait(0.05)
                    claimGift()
                    wait(0.05)
                    wait(1)  -- Wait for 2 seconds before claiming again
                end
            end)
        end
    end
})


local autoWheelSpinActive = false

local function claimAndSpinWheel()
    local claimArgs = {
        [1] = "ClaimFreeWheelSpin"
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(claimArgs))

    wait(0.4)

    -- Perform the wheel spin action
    local spinArgs = {
        [1] = "WheelSpin"
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Function"):InvokeServer(unpack(spinArgs))
end

-- Toggle button for auto wheel spin
AutosTab:CreateToggle({
    Name = "Auto Wheel Spin",
    CurrentValue = false,
    Flag = "AutoWheelSpinToggle",
    Callback = function(state)
        autoWheelSpinActive = state
        if autoWheelSpinActive then
            -- Start the process to claim and spin the wheel every 50 seconds
            spawn(function()
                while autoWheelSpinActive do
                    claimAndSpinWheel()  -- Run the function to claim and spin the wheel
                    wait(50)  -- Wait for 50 seconds before running again
                end
            end)
        end
    end
})

-- Variable to store the toggle state for running the function
local autoDoggyJumpActive = false

-- Function to trigger the DoggyJumpWin event
local function triggerDoggyJumpWin()
    -- Prepare the args for DoggyJumpWin event
    local args = {
        [1] = "DoggyJumpWin",
        [2] = 3  -- The value for DoggyJumpWin
    }

    -- Fire the event with the provided args
    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
end

-- Toggle button for auto Doggy Jump Win action
AutosTab:CreateToggle({
    Name = "Auto DoggyJump",
    CurrentValue = false,
    Flag = "AutoDoggyJumpToggle",
    Callback = function(state)
        autoDoggyJumpActive = state
        if autoDoggyJumpActive then
            -- Start the process to trigger the event every 70 seconds
            spawn(function()
                while autoDoggyJumpActive do
                    triggerDoggyJumpWin()  -- Run the function to trigger the event
                    wait(70)  -- Wait for 70 seconds before running again
                end
            end)
        end
    end
})

AutosTab:CreateToggle({
    Name = "Auto Rift Gift",
    CurrentValue = false,
    Flag = "AutoRiftGiftToggle",
    Callback = function(state)
        RiftGiftActive = state

        if RiftGiftActive then
            task.spawn(function()
                while RiftGiftActive do
                    local args = {
                        [1] = "ClaimRiftGift",
                        [2] = "gift-rift"
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Shared"):WaitForChild("Framework")
                        :WaitForChild("Network"):WaitForChild("Remote")
                        :WaitForChild("Event"):FireServer(unpack(args))
                    task.wait(55)
                end
            end)
        end
    end
})


-- Pet Utils Tab
local PlayerTab = Window:CreateTab("Player", "circle-user")

PlayerTab:CreateSection("Teleports")

local islandOptions = { "Spawn", "Floating Island", "Outer Space", "Twilight Island", "Void Island", "Zen Island" }

local IslandDropdown = PlayerTab:CreateDropdown({
    Name = "Select Island",
    Options = islandOptions,
    CurrentOption = {},
    Flag = "IslandDropdown",
    Callback = function(option)
        local choice = typeof(option) == "table" and option[1] or option
        if not choice or choice == "" then return end
        selectedIsland = choice  -- Store the selected island
    end
})

-- Teleport Button
PlayerTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not selectedIsland or selectedIsland == "" then
            print("No island selected!")
            return
        end

        -- Prepare teleport remote code based on the selected island
        local args = {}
        if selectedIsland == "Spawn" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.PortalSpawn"
            }
        elseif selectedIsland == "Floating Island" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.Islands.Floating Island.Island.Portal.Spawn"
            }
        elseif selectedIsland == "Outer Space" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.Islands.Outer Space.Island.Portal.Spawn"
            }
        elseif selectedIsland == "Twilight Island" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.Islands.Twilight.Island.Portal.Spawn"
            }
        elseif selectedIsland == "Void Island" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.Islands.The Void.Island.Portal.Spawn"
            }
        elseif selectedIsland == "Zen Island" then
            args = {
                [1] = "Teleport",
                [2] = "Workspace.Worlds.The Overworld.Islands.Zen.Island.Portal.Spawn"
            }
        end

        -- Fire the remote to teleport to the selected island
        game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("Remote"):WaitForChild("Event"):FireServer(unpack(args))
    end
})

-- Mastery Section
PlayerTab:CreateSection("Mastery")

-- Mastery values
local masteryTypes = { "Buffs", "Pets", "Shops" }
local selectedMastery = {}
local autoMasteryRunning = false

-- Dropdown to select multiple mastery categories
local masteryDropdown = PlayerTab:CreateDropdown({
    Name = "Select Mastery Types",
    Options = masteryTypes,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "MasteryTypesDropdown",
    Callback = function(selected)
        selectedMastery = selected
        for _, m in ipairs(selected) do
        end
    end
})

-- Toggle to auto run mastery upgrades
PlayerTab:CreateToggle({
    Name = "AutoMastery",
    CurrentValue = false,
    Flag = "AutoMasteryToggle",
    Callback = function(state)
        autoMasteryRunning = state

        if autoMasteryRunning then
            task.spawn(function()
                while autoMasteryRunning do
                    for _, masteryType in ipairs(selectedMastery) do
                        local args = {
                            [1] = "UpgradeMastery",
                            [2] = masteryType
                        }

                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Shared"):WaitForChild("Framework")
                            :WaitForChild("Network"):WaitForChild("Remote")
                            :WaitForChild("Event"):FireServer(unpack(args))

                        task.wait(0.1)
                    end
                    task.wait(60) -- wait between full cycles
                end
            end)
        end
    end
})


PlayerTab:CreateSection("AutoPotion")
local autoUsePotions = false
local potionDelay = 10 -- default in seconds

local predefinedPotions = {
    "Coins 1", "Coins 2", "Coins 3", "Coins 4", "Coins 5", "Coins 6",
    "Speed 1", "Speed 2", "Speed 3", "Speed 4", "Speed 5", "Speed 6",
    "Lucky 1", "Lucky 2", "Lucky 3", "Lucky 4", "Lucky 5", "Lucky 6"
}

local selectedPotions = {}

-- Dropdown
local potionDropdown = PlayerTab:CreateDropdown({
    Name = "Select Potions",
    Options = predefinedPotions,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PotionMultiDropdown",
    Callback = function(options)
        selectedPotions = options
    end
})

-- Button to trigger usage
PlayerTab:CreateButton({
    Name = "Use Potions",
    Callback = function()
        for _, potion in ipairs(selectedPotions) do
            local word, num = potion:match("^(%w+)%s+(%d+)$")
            if word and num then
                local args = {
                    [1] = "UsePotion",
                    [2] = word,
                    [3] = tonumber(num)
                }

                game:GetService("ReplicatedStorage")
                    :WaitForChild("Shared")
                    :WaitForChild("Framework")
                    :WaitForChild("Network")
                    :WaitForChild("Remote")
                    :WaitForChild("Event"):FireServer(unpack(args))
                task.wait(0.1)
            end
        end
    end
})

-- State variables
local autoUsePotions = false
local potionDelay = 10


-- Toggle to enable/disable auto usage
PlayerTab:CreateToggle({
    Name = "AutoPotions",
    CurrentValue = false,
    Flag = "AutoUsePotionsToggle",
    Callback = function(state)
        autoUsePotions = state

        if autoUsePotions then
            task.spawn(function()
                while autoUsePotions do
                    for _, potion in ipairs(selectedPotions) do
                        local word, num = potion:match("^(%w+)%s+(%d+)$")
                        if word and num then
                            local args = {
                                [1] = "UsePotion",
                                [2] = word,
                                [3] = tonumber(num)
                            }

                            game:GetService("ReplicatedStorage")
                                :WaitForChild("Shared")
                                :WaitForChild("Framework")
                                :WaitForChild("Network")
                                :WaitForChild("Remote")
                                :WaitForChild("Event"):FireServer(unpack(args))

                            task.wait(0.1)
                        end
                    end

                    task.wait(potionDelay)
                end
            end)
        end
    end
})

-- Slider to set delay between auto uses
PlayerTab:CreateSlider({
    Name = "AutoPotion Delay",
    Range = {1, 1200},
    Increment = 1,
    Suffix = "s",
    CurrentValue = potionDelay,
    Flag = "AutoPotionDelay",
    Callback = function(value)
        potionDelay = value
    end
})

PlayerTab:CreateSection("Rift Chests")

PlayerTab:CreateParagraph({
    Title = "Rift Chest Requirement",
    Content = "You must be within range of the rift chest for it to open"
})

local RiftGiftActive = false
local selectedRiftChests = {}
local riftChestAmount = 1

-- 🌟 Dropdown for Rift Chests
PlayerTab:CreateDropdown({
    Name = "Select Rift Chests",
    Options = { "Golden Chest", "Royal Chest" },
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "RiftChestDropdown",
    Callback = function(selected)
        selectedRiftChests = selected
        for _, chest in ipairs(selected) do print(" -", chest) end
    end
})

-- 🔢 Slider for how many times to unlock
PlayerTab:CreateSlider({
    Name = "Amount",
    Range = {1, 25},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "RiftChestUnlockAmount",
    Callback = function(value)
        riftChestAmount = value
    end
})

-- 🔘 Button to trigger chest unlocks
PlayerTab:CreateButton({
    Name = "Unlock Selected Chests",
    Callback = function()
        for _, chest in ipairs(selectedRiftChests) do
            local chestKey = nil

            if chest == "Golden Chest" then
                chestKey = "golden-chest"
            elseif chest == "Royal Chest" then
                chestKey = "royal-chest"
            end

            if chestKey then
                for i = 1, riftChestAmount do
                    local args = {
                        [1] = "UnlockRiftChest",
                        [2] = chestKey
                    }

                    game:GetService("ReplicatedStorage")
                        :WaitForChild("Shared"):WaitForChild("Framework")
                        :WaitForChild("Network"):WaitForChild("Remote")
                        :WaitForChild("Event"):FireServer(unpack(args))

                    task.wait(0.15)
                end
            end
        end
    end
})



PlayerTab:CreateSection("Auto Upgrade Potion")

PlayerTab:CreateParagraph({
    Title = "Potion Upgrade Requirement",
    Content = "Potions will only upgrade if you have the required mastery"
})

local selectedCraftPotion = nil
local selectedCraftPotion = nil
local craftAmount = 1 -- default number of times

local craftablePotions = {
    "Coins 2", "Coins 3", "Coins 4", "Coins 5", "Coins 6",
    "Speed 2", "Speed 3", "Speed 4", "Speed 5", "Speed 6",
    "Lucky 2", "Lucky 3", "Lucky 4", "Lucky 5", "Lucky 6"
}


-- Dropdown for Craftable Potions
local craftPotionDropdown = PlayerTab:CreateDropdown({
    Name = "Select Potion (to craft)",
    Options = craftablePotions,
    CurrentOption = "",
    Flag = "CraftPotionDropdown",
    Callback = function(option)
        selectedCraftPotion = typeof(option) == "table" and option[1] or option
    end
})

PlayerTab:CreateSlider({
    Name = "Upgrade Amount",
    Range = {1, 50},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "CraftAmountSlider",
    Callback = function(value)
        craftAmount = value
    end
})


PlayerTab:CreateButton({
    Name = "Upgrade Potion",
    Callback = function()
        if not selectedCraftPotion or selectedCraftPotion == "" then
            warn("No potion selected.")
            return
        end

        local potionType, level = selectedCraftPotion:match("^(%w+)%s+(%d+)$")
        if not potionType or not level then
            return
        end

        for i = 1, craftAmount do
            local args = {
                [1] = "CraftPotion",
                [2] = potionType,
                [3] = tonumber(level),
                [4] = false
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Shared"):WaitForChild("Framework")
                :WaitForChild("Network"):WaitForChild("Remote")
                :WaitForChild("Event"):FireServer(unpack(args))

            task.wait(0.1)
        end
    end
})

PlayerTab:CreateButton({
    Name = "Max Upgrade (All)",
    Callback = function()
        if not selectedCraftPotion or selectedCraftPotion == "" then
            warn("No potion selected.")
            return
        end

        local potionType = selectedCraftPotion:match("^(%w+)")
        if not potionType then
            return
        end

        for level = 2, 6 do
            local args = {
                [1] = "CraftPotion",
                [2] = potionType,
                [3] = level,
                [4] = true -- ⚠ true to signal batch behavior
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Shared"):WaitForChild("Framework")
                :WaitForChild("Network"):WaitForChild("Remote")
                :WaitForChild("Event"):FireServer(unpack(args))

            task.wait(0.1)
        end
    end
})



-- Pet Utils Tab
local PetTab = Window:CreateTab("Pet", "dog")

-- Globals
local petTypes = {}
local allPets = {}

-- UI Elements
local petTypesDropdown
local individualPetsDropdown
local petCountParagraph
local petDetailParagraph

-- Get all pets in the inventory
local function getAllPets()
    local petsFrame = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Pets.Main.ScrollingFrame.Pets
    local petList = {}

    for _, petFrame in pairs(petsFrame:GetChildren()) do
        if petFrame:IsA("Frame") and petFrame:FindFirstChild("Inner") then
            local realName = petFrame.Name
            local displayText = petFrame.Inner:FindFirstChild("Button") and petFrame.Inner.Button.Inner:FindFirstChild("DisplayName")
            local friendlyName = displayText and displayText.ContentText or "Unknown"

            if not petList[friendlyName] then
                petList[friendlyName] = {}
            end
            table.insert(petList[friendlyName], realName)
        end
    end

    local petTypes = {}
    for name in pairs(petList) do
        table.insert(petTypes, name)
    end

    return petTypes, petList
end

local function refreshIndividualPetsDropdown(selectedType)
    local petInstances = allPets[selectedType] or {}
    local indexedOptions = { "None" } -- start with "None" option

    for i, realName in ipairs(petInstances) do
        local label = string.format("[%d] %s", i, selectedType)
        local uniqueName = label .. "##" .. realName
        table.insert(indexedOptions, uniqueName)
    end

    if individualPetsDropdown then
        individualPetsDropdown:Refresh(indexedOptions)
        individualPetsDropdown:Set({ "None" }) -- default to none
    end

    -- Update pet type info paragraph
    if petCountParagraph then
        petCountParagraph:Set({
            Title = "Pet Type Info",
            Content = string.format("You have %d pet(s) of type \"%s\".", #petInstances, selectedType)
        })
    end

    -- Clear details
    if petDetailParagraph then
        petDetailParagraph:Set({
            Title = "Selected Pet Details",
            Content = "Select an individual pet to see its data."
        })
    end
end

local function updatePetDetailParagraph(realPetName)
    local petsFolder = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Inventory.Frame.Inner.Pets.Main.ScrollingFrame.Pets
    local petFrame = petsFolder:FindFirstChild(realPetName)

    if not petFrame then
        petDetailParagraph:Set({
            Title = "Selected Pet Details",
            Content = "Pet not found in UI."
        })
        return
    end

    -- Level
    local levelText = "?"
    local levelLabel = petFrame:FindFirstChild("Inner")
        and petFrame.Inner:FindFirstChild("Button")
        and petFrame.Inner.Button.Inner:FindFirstChild("Level")

    if levelLabel and levelLabel:FindFirstChild("ContextText") then
        levelText = tostring(levelLabel.ContextText)
    elseif levelLabel and levelLabel:IsA("TextLabel") then
        levelText = levelLabel.Text
    end

    -- Attributes
    local incubator = petFrame:GetAttribute("Incubator")
    local mythic = petFrame:GetAttribute("Mythic")
    local shiny = petFrame:GetAttribute("Shiny")

    local incubatorText = (incubator == true and "Yes") or (incubator == false and "No") or "?"
    local mythicText = (mythic == true and "Yes") or (mythic == false and "No") or "?"
    local shinyText = (shiny == true and "Yes") or (shiny == false and "No") or "?"

    petDetailParagraph:Set({
        Title = "Selected Pet Details",
        Content = string.format("Level: %s\nIncubator: %s\nMythic: %s\nShiny: %s", levelText, incubatorText, mythicText, shinyText)
    })
end

-- Load initial data
petTypes, allPets = getAllPets()

PetTab:CreateSection("Pet Selector")

PetTab:CreateParagraph({
    Title = "Pet Selector Requirement",
    Content = "You must have opened your inventory at least once, and have pets unstacked to see pets properly. If pets aren't showing up, do this and click refresh."
})

petTypesDropdown = PetTab:CreateDropdown({
    Name = "Select Pet Type(s)",
    Options = petTypes,
    CurrentOption = {}, -- start with none selected
    Flag = "PetTypeDropdown",
    MultipleOptions = true, -- ✅ THIS ENABLES MULTI-SELECT
    Callback = function(options)
        -- `options` is now a table of selected pet types
        for _, selectedPetType in ipairs(options) do
            refreshIndividualPetsDropdown(selectedPetType)
        end
    end
})


individualPetsDropdown = PetTab:CreateDropdown({
    Name = "Select Pet",
    Options = {}, -- start empty
    CurrentOption = {}, -- ✅ NO default selection
    Flag = "IndividualPets",
    Callback = function(option)
        local label = option[1]
        if not label or label == "None" then
            petDetailParagraph:Set({
                Title = "Selected Pet Details",
                Content = "Select an individual pet to see its data."
            })
            return
        end
    
        local displayLabel = label:match("^(.-)##")
        local _, _, realPetName = label:find("##(.+)$")
    
        if not realPetName then
            return
        end
    
        updatePetDetailParagraph(realPetName)
    end
})
    

-- Paragraph for pet count
petCountParagraph = PetTab:CreateParagraph({
    Title = "Pet Type Info",
    Content = "Select a pet type to view details."
})

-- Paragraph for pet details
petDetailParagraph = PetTab:CreateParagraph({
    Title = "Selected Pet Details",
    Content = "Select an individual pet to see its data."
})

-- Preload UI
if petTypes[1] then
    refreshIndividualPetsDropdown(petTypes[1])
end

-- Refresh Button
PetTab:CreateButton({
    Name = "Refresh Pets",
    Callback = function()
        petTypes, allPets = getAllPets()
        petTypesDropdown:Refresh(petTypes)
        if petTypes[1] then
            petTypesDropdown:Set({petTypes[1]})
            refreshIndividualPetsDropdown(petTypes[1])
        end
    end
})

local function extractUUID(realPetName)
    return string.match(realPetName, "^(.+)%-%d+$") or realPetName
end

PetTab:CreateSection("Delete Pets")

PetTab:CreateButton({
    Name = "Delete Selected",
    Callback = function()
        local selected = individualPetsDropdown.CurrentOption and individualPetsDropdown.CurrentOption[1]
        if not selected or selected == "None" then
            warn("No pet selected to delete.")
            return
        end

        local _, _, fullName = string.find(selected, "##(.+)$")
        local uuid = extractUUID(fullName)
        if not uuid then
            return
        end

        local args = {
            [1] = "DeletePet",
            [2] = uuid,
            [3] = 1,
            [4] = false
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("Shared")
            :WaitForChild("Framework")
            :WaitForChild("Network")
            :WaitForChild("Remote")
            :WaitForChild("Event")
            :FireServer(unpack(args))

    end
})

PetTab:CreateButton({
    Name = "Delete Type",
    Callback = function()
        local selectedType = petTypesDropdown.CurrentOption and petTypesDropdown.CurrentOption[1]
        if not selectedType then return end

        local petList = allPets[selectedType] or {}
        for _, fullName in ipairs(petList) do
            local uuid = extractUUID(fullName)
            local args = {
                [1] = "DeletePet",
                [2] = uuid,
                [3] = 1,
                [4] = false
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Shared")
                :WaitForChild("Framework")
                :WaitForChild("Network")
                :WaitForChild("Remote")
                :WaitForChild("Event")
                :FireServer(unpack(args))

            task.wait(0.1)
        end
    end
})

local deletePetTypeActive = false

PetTab:CreateToggle({
    Name = "AutoDelete Pet Type",
    CurrentValue = false,
    Flag = "DeleteTypeToggle",
    Callback = function(state)
        deletePetTypeActive = state

        if deletePetTypeActive then
            task.spawn(function()
                while deletePetTypeActive do
                    local selectedTypes = petTypesDropdown.CurrentOption or {}
                    for _, typeName in ipairs(selectedTypes) do
                        local pets = allPets[typeName]
                        if pets then
                            for _, fullName in ipairs(pets) do
                                local uuid = extractUUID(fullName)
                                local args = {
                                    [1] = "DeletePet",
                                    [2] = uuid,
                                    [3] = 1,
                                    [4] = false
                                }

                                game:GetService("ReplicatedStorage")
                                    :WaitForChild("Shared")
                                    :WaitForChild("Framework")
                                    :WaitForChild("Network")
                                    :WaitForChild("Remote")
                                    :WaitForChild("Event")
                                    :FireServer(unpack(args))

                                task.wait(0.1)
                            end
                        end
                    end
                    task.wait(1) -- Wait a bit before checking again
                end
            end)
        end
    end
})

PetTab:CreateSection("Enchant Pets (gems)")

PetTab:CreateButton({
    Name = "Reroll Selected (gems)",
    Callback = function()
        local selected = individualPetsDropdown.CurrentOption and individualPetsDropdown.CurrentOption[1]
        if not selected or selected == "None" then return end

        local _, _, fullName = selected:find("##(.+)$")
        local uuid = extractUUID(fullName)

        local args = {
            [1] = "RerollEnchants",
            [2] = uuid
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("Shared"):WaitForChild("Framework")
            :WaitForChild("Network"):WaitForChild("Remote")
            :WaitForChild("Function"):InvokeServer(unpack(args))
    end
})

PetTab:CreateButton({
    Name = "Reroll Type (gems)",
    Callback = function()
        local selectedType = petTypesDropdown.CurrentOption and petTypesDropdown.CurrentOption[1]
        if not selectedType then return end

        for _, fullName in ipairs(allPets[selectedType] or {}) do
            local uuid = extractUUID(fullName)
            local args = {
                [1] = "RerollEnchants",
                [2] = uuid
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Shared"):WaitForChild("Framework")
                :WaitForChild("Network"):WaitForChild("Remote")
                :WaitForChild("Function"):InvokeServer(unpack(args))

            task.wait(0.1)
        end
    end
})

PetTab:CreateButton({
    Name = "Reroll All (gems)",
    Callback = function()
        for _, petGroup in pairs(allPets) do
            for _, fullName in ipairs(petGroup) do
                local uuid = extractUUID(fullName)
                local args = {
                    [1] = "RerollEnchants",
                    [2] = uuid
                }

                game:GetService("ReplicatedStorage")
                    :WaitForChild("Shared"):WaitForChild("Framework")
                    :WaitForChild("Network"):WaitForChild("Remote")
                    :WaitForChild("Function"):InvokeServer(unpack(args))

                task.wait(0.1)
            end
        end
    end
})

PetTab:CreateSection("Enchant Pets (tokens)")

PetTab:CreateButton({
    Name = "Reroll Selected (token)",
    Callback = function()
        local selected = individualPetsDropdown.CurrentOption and individualPetsDropdown.CurrentOption[1]
        if not selected or selected == "None" then return end

        local _, _, fullName = selected:find("##(.+)$")
        local uuid = extractUUID(fullName)

        local args = {
            [1] = "RerollEnchant",
            [2] = uuid,
            [3] = 1
        }

        game:GetService("ReplicatedStorage")
            :WaitForChild("Shared"):WaitForChild("Framework")
            :WaitForChild("Network"):WaitForChild("Remote")
            :WaitForChild("Event"):FireServer(unpack(args))
    end
})

PetTab:CreateButton({
    Name = "Reroll Type (token)",
    Callback = function()
        local selectedType = petTypesDropdown.CurrentOption and petTypesDropdown.CurrentOption[1]
        if not selectedType then return end

        for _, fullName in ipairs(allPets[selectedType] or {}) do
            local uuid = extractUUID(fullName)
            local args = {
                [1] = "RerollEnchant",
                [2] = uuid,
                [3] = 1
            }

            game:GetService("ReplicatedStorage")
                :WaitForChild("Shared"):WaitForChild("Framework")
                :WaitForChild("Network"):WaitForChild("Remote")
                :WaitForChild("Event"):FireServer(unpack(args))

            task.wait(0.1)
        end
    end
})

PetTab:CreateButton({
    Name = "Reroll All (token)",
    Callback = function()
        for _, petGroup in pairs(allPets) do
            for _, fullName in ipairs(petGroup) do
                local uuid = extractUUID(fullName)
                local args = {
                    [1] = "RerollEnchant",
                    [2] = uuid,
                    [3] = 1
                }

                game:GetService("ReplicatedStorage")
                    :WaitForChild("Shared"):WaitForChild("Framework")
                    :WaitForChild("Network"):WaitForChild("Remote")
                    :WaitForChild("Event"):FireServer(unpack(args))

                task.wait(0.1)
            end
        end
    end
})

local ThemeTab = Window:CreateTab("Themes", "menu")


local Dropdown = ThemeTab:CreateDropdown({
    Name = "Select Theme",
    Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = {"Default"}, -- The default selected option
    MultipleOptions = false, -- Set to false since only one theme can be selected at a time
    Flag = "ThemeDropdown", -- A unique identifier for the dropdown
    Callback = function(Options)
        -- Change the theme of the window
        Window.ModifyTheme(Options[1]) -- Access the first (and only) selected option
        print("Theme changed to: " .. Options[1])
    end,
 })

Rayfield:LoadConfiguration()
