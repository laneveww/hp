local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local State = {
	normalSpeed = 60, carrySpeed = 30, laggerSpeed = 13, laggerCarrySpeed = 13,
	speedType = "normal",
	laggerActive = false,
	autoBatToggled = false,
	hittingCooldown = false, infJumpEnabled = false,
	antiRagdollEnabled = false, fpsBoostEnabled = false,
	guiVisible = true,
	isStealing = false, stealStartTime = nil, lastStealTick = 0,
	medusaLastUsed = 0, medusaDebounce = false, medusaCounterEnabled = false,
	dropBrainrotActive = false,
	autoLeftEnabled = false, autoRightEnabled = false,
	autoLeftPhase = 1, autoRightPhase = 1,
	_tpInProgress = false,
	lastMoveDir = Vector3.new(0,0,0),
	animEnabled = false, unwalkEnabled = false,
}

local Keys = {
	autoBat = Enum.KeyCode.E, speed = Enum.KeyCode.Q,
	lagger = Enum.KeyCode.C,
	guiHide = Enum.KeyCode.LeftControl,
	autoLeft = Enum.KeyCode.L, autoRight = Enum.KeyCode.R,
	dropBrainrot = Enum.KeyCode.H,
	tpDown = Enum.KeyCode.T,
}

-- ========== AUTO-STEAL ==========
local AutoSteal = {
	Enabled = false,
	Radius = 9,
	Duration = 0.3,
	IsStealing = false,
	Data = {},
	ProgressFill = nil,
	ProgressText = nil,
}

local function isMyPlotByName(plotName)
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return false end
	local plot = plots:FindFirstChild(plotName)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign")
	if sign then
		local yb = sign:FindFirstChild("YourBase")
		if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
	end
	return false
end

local function findNearestPrompt()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local bestPrompt, bestDist, bestName = nil, math.huge, nil
	for _, plot in ipairs(plots:GetChildren()) do
		if isMyPlotByName(plot.Name) then continue end
		local podiums = plot:FindFirstChild("AnimalPodiums")
		if not podiums then continue end
		for _, pod in ipairs(podiums:GetChildren()) do
			pcall(function()
				local base = pod:FindFirstChild("Base")
				local spawn = base and base:FindFirstChild("Spawn")
				if spawn then
					local dist = (spawn.Position - root.Position).Magnitude
					if dist < bestDist and dist <= AutoSteal.Radius then
						local att = spawn:FindFirstChild("PromptAttachment")
						if att then
							for _, child in ipairs(att:GetChildren()) do
								if child:IsA("ProximityPrompt") then
									bestPrompt, bestDist, bestName = child, dist, pod.Name
									break
								end
							end
						end
					end
				end
			end)
		end
	end
	return bestPrompt, bestDist, bestName
end

local function executeSteal(prompt, animalName)
	if AutoSteal.IsStealing then return end
	if not AutoSteal.Data[prompt] then
		AutoSteal.Data[prompt] = {hold = {}, trigger = {}, ready = true}
		pcall(function()
			if getconnections then
				for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
					if c.Function then table.insert(AutoSteal.Data[prompt].hold, c.Function) end
				end
				for _, c in ipairs(getconnections(prompt.Triggered)) do
					if c.Function then table.insert(AutoSteal.Data[prompt].trigger, c.Function) end
				end
			end
		end)
	end
	local data = AutoSteal.Data[prompt]
	if not data.ready then return end
	data.ready = false
	AutoSteal.IsStealing = true
	local startTime = tick()

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not AutoSteal.IsStealing then
			conn:Disconnect()
			return
		end
		local prog = math.clamp((tick() - startTime) / AutoSteal.Duration, 0, 1)
		if AutoSteal.ProgressFill then
			AutoSteal.ProgressFill.Size = UDim2.new(prog, 0, 1, 0)
		end
	end)

	task.spawn(function()
		for _, f in ipairs(data.hold) do task.spawn(f) end
		task.wait(AutoSteal.Duration)
		for _, f in ipairs(data.trigger) do task.spawn(f) end
		AutoSteal.IsStealing = false
		data.ready = true
		task.wait(0.6)
		if not AutoSteal.IsStealing and AutoSteal.ProgressFill then
			TweenService:Create(AutoSteal.ProgressFill, TweenInfo.new(0.4), {Size = UDim2.new(0,0,1,0)}):Play()
		end
	end)
end

local autoStealConnection = nil
local function startAutoSteal()
	if autoStealConnection then return end
	autoStealConnection = RunService.Heartbeat:Connect(function()
		if AutoSteal.Enabled and not AutoSteal.IsStealing then
			local p, _, name = findNearestPrompt()
			if p then executeSteal(p, name) end
		end
	end)
end
local function stopAutoSteal()
	if autoStealConnection then
		autoStealConnection:Disconnect()
		autoStealConnection = nil
	end
	AutoSteal.IsStealing = false
	for k, v in pairs(AutoSteal.Data) do
		if v.ready ~= nil then v.ready = true end
	end
end

local MOVE_KEYS = {
	[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,
	[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,
	[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,
	[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,
}

local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150

local POS = {
	L1 = Vector3.new(-476.48,-6.28,92.73), L2 = Vector3.new(-483.12,-4.95,94.80),
	R1 = Vector3.new(-476.16,-6.52,25.62), R2 = Vector3.new(-483.04,-5.09,23.14),
}

local Conns = {
	autoSteal = nil, antiRag = nil,
	autoLeft = nil, autoRight = nil,
	anchor = {}, progress = nil,
}

local h, hrp, speedLbl
local setAutoLeft, setAutoRight
local setInstaGrab, setAutoBat, setInfJump, setAntiRag, setFps, setMedusaCounter
local setAnimToggle, setUnwalkToggle
local setupMedusaCounter, stopMedusaCounter, startAntiRagdoll, stopAntiRagdoll
local applyFPSBoost

local modeValLbl, normalBox, carryBox, laggerBox, carryLaggerBox
local autoBatKeyBtn, speedKeyBtn, laggerKeyBtn
local autoLeftKeyBtn, autoRightKeyBtn
local guiHideKeyBtn
local dropBrainrotKeyBtn, tpDownKeyBtn
local setSpeedToggleUI, setLaggerToggleUI
local progressRadLbl

-- ================= AUTO-SAVE =================
local saveDebounce = false
local function autoSaveConfig()
	if saveDebounce then return end
	saveDebounce = true
	task.delay(0.5, function()
		local cfg = {
			normalSpeed=State.normalSpeed, carrySpeed=State.carrySpeed,
			laggerSpeed=State.laggerSpeed, laggerCarrySpeed=State.laggerCarrySpeed,
			speedType=State.speedType, laggerActive=State.laggerActive,
			autoBatKey=Keys.autoBat.Name, speedKey=Keys.speed.Name, laggerKey=Keys.lagger.Name,
			autoStealEnabled=AutoSteal.Enabled, grabRadius=AutoSteal.Radius,
			infJump=State.infJumpEnabled, antiRagdoll=State.antiRagdollEnabled, fpsBoost=State.fpsBoostEnabled,
			medusaCounter=State.medusaCounterEnabled, dropBrainrotKey=Keys.dropBrainrot.Name,
			autoLeftKey=Keys.autoLeft.Name, autoRightKey=Keys.autoRight.Name,
			guiHideKey=Keys.guiHide.Name,
			animEnabled=State.animEnabled, unwalkEnabled=State.unwalkEnabled,
			tpDownKey=Keys.tpDown.Name,
			mobileVisible=MobileButtons.Visible,
			mobileLocked=MobileButtons.Locked,
		}
		pcall(function() writefile("MachoHubConfig.json", HttpService:JSONEncode(cfg)) end)
		saveDebounce = false
	end)
end

-- ================= MOBILE BUTTONS =================
local MobileButtons = {
	Visible = true,
	Locked = false,
	Frame = nil,
	Buttons = {}
}

local function refreshUIToggles()
	if setSpeedToggleUI then setSpeedToggleUI(State.speedType == "carry") end
	if setLaggerToggleUI then setLaggerToggleUI(State.laggerActive) end
	if State.laggerActive then
		modeValLbl.Text = (State.speedType == "normal") and "Lagger Normal" or "Lagger Carry"
	else
		modeValLbl.Text = (State.speedType == "normal") and "Normal" or "Carry"
	end
end

local function toggleSpeedType()
	State.speedType = (State.speedType == "normal") and "carry" or "normal"
	refreshUIToggles()
	autoSaveConfig()
	if MobileButtons.Buttons.carrySpeed then
		MobileButtons.Buttons.carrySpeed(State.speedType == "carry")
	end
end

local function toggleLagger()
	State.laggerActive = not State.laggerActive
	refreshUIToggles()
	autoSaveConfig()
	if MobileButtons.Buttons.lagger then
		MobileButtons.Buttons.lagger(State.laggerActive)
	end
end

local function getCurrentSpeed()
	if State.laggerActive then
		return State.speedType == "normal" and State.laggerSpeed or State.laggerCarrySpeed
	else
		return State.speedType == "normal" and State.normalSpeed or State.carrySpeed
	end
end

local function getAutoMoveSpeed()
	if State.laggerActive then return State.laggerSpeed else return State.normalSpeed end
end

local function tpToGround()
	local char = LP.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {char}
	local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -500, 0), raycastParams)
	if rayResult then
		root.CFrame = CFrame.new(rayResult.Position + Vector3.new(0, 3, 0))
	else
		root.CFrame = root.CFrame * CFrame.new(0, -20, 0)
	end
end

local function runDropBrainrot()
	if State.dropBrainrotActive then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
	State.dropBrainrotActive=true; local t0=tick(); local dc
	dc=RunService.Heartbeat:Connect(function()
		local r=char and char:FindFirstChild("HumanoidRootPart")
		if not r then dc:Disconnect(); State.dropBrainrotActive=false; return end
		if tick()-t0>=DROP_ASCEND_DURATION then
			dc:Disconnect()
			local rp=RaycastParams.new(); rp.FilterDescendantsInstances={char}; rp.FilterType=Enum.RaycastFilterType.Exclude
			local rr=workspace:Raycast(r.Position,Vector3.new(0,-2000,0),rp)
			if rr then
				local hum2=char:FindFirstChildOfClass("Humanoid")
				local off=(hum2 and hum2.HipHeight or 2)+(r.Size.Y/2)
				r.CFrame=CFrame.new(r.Position.X,rr.Position.Y+off,r.Position.Z); r.AssemblyLinearVelocity=Vector3.new(0,0,0)
			end
			State.dropBrainrotActive=false; return
		end
		r.AssemblyLinearVelocity=Vector3.new(r.AssemblyLinearVelocity.X,DROP_ASCEND_SPEED,r.AssemblyLinearVelocity.Z)
	end)
end

-- ================= LIGHTNING EFFECT =================
local activeLightnings = {}

local function createLightningEffect(button)
	local lightningContainer = Instance.new("Frame")
	lightningContainer.Name = "LightningEffect"
	lightningContainer.Size = UDim2.new(1, 0, 1, 0)
	lightningContainer.BackgroundTransparency = 1
	lightningContainer.ZIndex = 20
	lightningContainer.Parent = button

	local bolt = Instance.new("ImageLabel")
	bolt.Image = "rbxassetid://2534884024"
	bolt.Size = UDim2.new(1.3, 0, 1.3, 0)
	bolt.Position = UDim2.new(-0.15, 0, -0.15, 0)
	bolt.BackgroundTransparency = 1
	bolt.ImageTransparency = 0.3
	bolt.ImageColor3 = Color3.fromRGB(200, 150, 255)
	bolt.ZIndex = 21
	bolt.Parent = lightningContainer

	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 15, 1, 15)
	glow.Position = UDim2.new(0, -7, 0, -7)
	glow.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
	glow.BackgroundTransparency = 0.8
	glow.BorderSizePixel = 0
	glow.ZIndex = 19
	Instance.new("UICorner", glow).CornerRadius = UDim.new(0, 14)
	glow.Parent = lightningContainer

	local sparks = {}
	for i = 1, 12 do
		local spark = Instance.new("Frame")
		spark.Size = UDim2.new(0, 4, 0, 4)
		spark.BackgroundColor3 = Color3.fromRGB(180, 100, 255)
		spark.BackgroundTransparency = 0.5
		spark.BorderSizePixel = 0
		spark.ZIndex = 22
		Instance.new("UICorner", spark).CornerRadius = UDim.new(1, 0)
		spark.Parent = lightningContainer
		table.insert(sparks, spark)
	end

	return {container = lightningContainer, bolt = bolt, glow = glow, sparks = sparks}
end

local function triggerLightning(effectData, intensity)
	if not effectData or not effectData.container then return end
	intensity = intensity or 1
	effectData.container.Visible = true
	TweenService:Create(effectData.glow, TweenInfo.new(0.05), {
		BackgroundTransparency = 0.1,
		Size = UDim2.new(1, 25, 1, 25),
		Position = UDim2.new(0, -12, 0, -12)
	}):Play()
	TweenService:Create(effectData.bolt, TweenInfo.new(0.08), {
		ImageTransparency = 0,
		ImageColor3 = Color3.fromRGB(220, 180, 255),
		Size = UDim2.new(1.5, 0, 1.5, 0),
		Position = UDim2.new(-0.25, 0, -0.25, 0)
	}):Play()
	for i, spark in ipairs(effectData.sparks) do
		local angle = (i / #effectData.sparks) * math.pi * 2
		local radius = 40 + (intensity * 20)
		local delay = i * 0.008
		task.delay(delay, function()
			if not spark or not spark.Parent then return end
			spark.Visible = true
			spark.Position = UDim2.new(0.5, 0, 0.5, 0)
			local targetX = math.cos(angle) * radius
			local targetY = math.sin(angle) * radius
			TweenService:Create(spark, TweenInfo.new(0.15), {
				Position = UDim2.new(0.5, targetX, 0.5, targetY),
				BackgroundTransparency = 0.9
			}):Play()
			task.delay(0.2, function()
				if spark then spark.Visible = false end
			end)
		end)
	end
	task.delay(0.15, function()
		if effectData and effectData.glow then
			TweenService:Create(effectData.glow, TweenInfo.new(0.1), {
				BackgroundTransparency = 0.8,
				Size = UDim2.new(1, 15, 1, 15),
				Position = UDim2.new(0, -7, 0, -7)
			}):Play()
		end
		if effectData and effectData.bolt then
			TweenService:Create(effectData.bolt, TweenInfo.new(0.1), {
				ImageTransparency = 0.5,
				Size = UDim2.new(1.3, 0, 1.3, 0),
				Position = UDim2.new(-0.15, 0, -0.15, 0)
			}):Play()
		end
	end)
	task.delay(0.35, function()
		if effectData and effectData.container then
			effectData.container.Visible = false
			for _, spark in ipairs(effectData.sparks) do
				if spark then spark.Visible = false end
			end
		end
	end)
end

local function globalLightningFlash()
	local originalBrightness = Lighting.Brightness
	local originalOutdoorAmbient = Lighting.OutdoorAmbient
	TweenService:Create(Lighting, TweenInfo.new(0.05), {
		Brightness = 2.5,
		OutdoorAmbient = Color3.fromRGB(200, 150, 255)
	}):Play()
	task.delay(0.08, function()
		TweenService:Create(Lighting, TweenInfo.new(0.15), {
			Brightness = originalBrightness,
			OutdoorAmbient = originalOutdoorAmbient
		}):Play()
	end)
end

-- ================= MOBILE PANEL =================
local function createMobilePanel()
	local panel = Instance.new("ScreenGui")
	panel.Name = "MachoHubButtons"
	panel.Parent = LP:WaitForChild("PlayerGui")
	panel.ResetOnSpawn = false
	panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local BTN_W = 60
	local BTN_H = 50
	local GAP = 10
	local PAD = 12
	local CORNER = 12

	local FRAME_W = PAD + BTN_W + GAP + BTN_W + PAD
	local FRAME_H = PAD + BTN_H + GAP + BTN_H + GAP + BTN_H + GAP + BTN_H + PAD

	local frame = Instance.new("Frame")
	frame.Name = "ButtonsFrame"
	frame.Parent = panel
	frame.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	frame.Position = UDim2.new(0.81, 0, 0.55, 0)
	frame.Size = UDim2.new(0, FRAME_W, 0, FRAME_H)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

	local borderStroke = Instance.new("UIStroke", frame)
	borderStroke.Color = Color3.fromRGB(160, 60, 255)
	borderStroke.Thickness = 2
	borderStroke.Transparency = 0.3

	task.spawn(function()
		while frame and frame.Parent do
			task.wait(2)
			TweenService:Create(borderStroke, TweenInfo.new(0.2), {Transparency = 0, Color = Color3.fromRGB(200, 120, 255)}):Play()
			task.wait(0.15)
			TweenService:Create(borderStroke, TweenInfo.new(0.3), {Transparency = 0.3, Color = Color3.fromRGB(140, 40, 220)}):Play()
		end
	end)

	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function stopDrag()
		dragging = false
		dragInput = nil
		dragStart = nil
		startPos = nil
	end

	frame.InputBegan:Connect(function(input)
		if MobileButtons.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancelled then
					stopDrag()
				end
			end)
		end
	end)

	frame.InputEnded:Connect(function(input)
		if input == dragInput then stopDrag() end
	end)

	UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local function makeBtn(btn, text, col, row, callback, isToggle)
		btn.Parent = frame
		btn.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
		btn.BackgroundTransparency = 0
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
		local x = PAD + (col == 1 and 0 or BTN_W + GAP)
		local y = PAD + (row - 1) * (BTN_H + GAP)
		btn.Position = UDim2.new(0, x, 0, y)
		btn.Font = Enum.Font.GothamBlack
		btn.Text = text
		btn.TextColor3 = Color3.fromRGB(200, 140, 255)
		btn.TextSize = 13
		btn.TextWrapped = true
		btn.AutoButtonColor = false
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, CORNER)

		local btnStroke = Instance.new("UIStroke", btn)
		btnStroke.Color = Color3.fromRGB(160, 60, 255)
		btnStroke.Thickness = 1.5
		btnStroke.Transparency = 0.4

		local lightningData = createLightningEffect(btn)
		lightningData.container.Visible = false

		local active = false

		local function setActive(state)
			active = state
			if active then
				btn.BackgroundColor3 = Color3.fromRGB(130, 40, 220)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btnStroke.Transparency = 0
				btnStroke.Color = Color3.fromRGB(220, 180, 255)
				triggerLightning(lightningData, 1.2)
				globalLightningFlash()
			else
				btn.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
				btn.TextColor3 = Color3.fromRGB(200, 140, 255)
				btnStroke.Transparency = 0.4
				btnStroke.Color = Color3.fromRGB(160, 60, 255)
			end
		end

		btn.MouseEnter:Connect(function()
			if not active then
				TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 20, 70)}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.1), {Transparency = 0.2, Thickness = 2}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if not active then
				TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(20, 10, 40)}):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.1), {Transparency = 0.4, Thickness = 1.5}):Play()
			end
		end)
		btn.MouseButton1Down:Connect(function()
			if not isToggle then
				btn.BackgroundColor3 = Color3.fromRGB(80, 30, 140)
				triggerLightning(lightningData, 1.5)
				globalLightningFlash()
			end
		end)
		btn.MouseButton1Up:Connect(function()
			if not isToggle then
				btn.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
			end
		end)
		btn.MouseButton1Click:Connect(function()
			if isToggle then setActive(not active) end
			triggerLightning(lightningData, 1)
			globalLightningFlash()
			if callback then callback(setActive, active) end
		end)

		task.spawn(function()
			while btn and btn.Parent do
				task.wait(math.random(20, 50))
				if not active and not MobileButtons.Locked then
					if math.random(1, 12) == 1 then
						triggerLightning(lightningData, 0.6)
					end
				end
			end
		end)

		return setActive, lightningData
	end

	-- Row 1
	local dropBtn = Instance.new("TextButton")
	makeBtn(dropBtn, "DROP\nBR", 1, 1, function() runDropBrainrot() end, false)

	local autoLeftSetActive
	local autoLeftBtn = Instance.new("TextButton")
	autoLeftSetActive = makeBtn(autoLeftBtn, "AUTO\nLEFT", 2, 1, function(setActive, currentState)
		local newVal = not State.autoLeftEnabled
		if newVal then
			if State.autoBatToggled then State.autoBatToggled=false; setAutoBat(false); if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(false) end end
			if State.autoRightEnabled then State.autoRightEnabled=false; if setAutoRight then setAutoRight(false) end; stopAutoRight(); if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end end
		end
		State.autoLeftEnabled = newVal
		if setAutoLeft then setAutoLeft(State.autoLeftEnabled) end
		if State.autoLeftEnabled then startAutoLeft(); setActive(true) else stopAutoLeft(); setActive(false) end
		autoSaveConfig()
	end, true)

	-- Row 2
	local autoBatSetActive
	local autoBatBtn = Instance.new("TextButton")
	autoBatSetActive = makeBtn(autoBatBtn, "AUTO\nBAT", 1, 2, function(setActive, currentState)
		if not State.autoBatToggled then
			if State.autoLeftEnabled then State.autoLeftEnabled=false; if setAutoLeft then setAutoLeft(false) end; stopAutoLeft(); if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end end
			if State.autoRightEnabled then State.autoRightEnabled=false; if setAutoRight then setAutoRight(false) end; stopAutoRight(); if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end end
		end
		State.autoBatToggled = not State.autoBatToggled
		setAutoBat(State.autoBatToggled)
		setActive(State.autoBatToggled)
		autoSaveConfig()
	end, true)

	local autoRightSetActive
	local autoRightBtn = Instance.new("TextButton")
	autoRightSetActive = makeBtn(autoRightBtn, "AUTO\nRIGHT", 2, 2, function(setActive, currentState)
		local newVal = not State.autoRightEnabled
		if newVal then
			if State.autoBatToggled then State.autoBatToggled=false; setAutoBat(false); if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(false) end end
			if State.autoLeftEnabled then State.autoLeftEnabled=false; if setAutoLeft then setAutoLeft(false) end; stopAutoLeft(); if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end end
		end
		State.autoRightEnabled = newVal
		if setAutoRight then setAutoRight(State.autoRightEnabled) end
		if State.autoRightEnabled then startAutoRight(); setActive(true) else stopAutoRight(); setActive(false) end
		autoSaveConfig()
	end, true)

	-- Row 3
	local tpDownBtn = Instance.new("TextButton")
	makeBtn(tpDownBtn, "TP\nDOWN", 1, 3, function() tpToGround() end, false)

	local carrySpeedSetActive
	local carrySpeedBtn = Instance.new("TextButton")
	carrySpeedSetActive = makeBtn(carrySpeedBtn, "CARRY\nSPD", 2, 3, function(setActive, currentState)
		toggleSpeedType()
		setActive(State.speedType == "carry")
	end, true)

	-- Row 4
	local laggerSetActive
	local laggerBtn = Instance.new("TextButton")
	laggerSetActive = makeBtn(laggerBtn, "LAGGER\nMODE", 1, 4, function(setActive, currentState)
		toggleLagger()
		setActive(State.laggerActive)
	end, true)

	MobileButtons.Buttons = {
		autoLeft = autoLeftSetActive,
		autoRight = autoRightSetActive,
		autoBat = autoBatSetActive,
		carrySpeed = carrySpeedSetActive,
		lagger = laggerSetActive
	}

	task.spawn(function()
		task.wait(0.1)
		if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(State.autoLeftEnabled) end
		if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(State.autoRightEnabled) end
		if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(State.autoBatToggled) end
		if MobileButtons.Buttons.carrySpeed then MobileButtons.Buttons.carrySpeed(State.speedType == "carry") end
		if MobileButtons.Buttons.lagger then MobileButtons.Buttons.lagger(State.laggerActive) end
	end)

	local savedPos = nil
	pcall(function() savedPos = readfile("MachoMobilePanelPos.txt") end)
	if savedPos and savedPos ~= "" then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			frame.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end

	frame.Visible = MobileButtons.Visible
	MobileButtons.Frame = frame

	task.spawn(function()
		while true do
			task.wait(3)
			if not MobileButtons.Locked and frame and frame.Parent then
				local pos = frame.Position
				local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
				pcall(function() writefile("MachoMobilePanelPos.txt", str) end)
			end
		end
	end)

	return panel
end

-- ================= MAIN GUI COLORS (PURPLE THEME) =================
local C_BG      = Color3.fromRGB(10, 5, 20)
local C_PANEL   = Color3.fromRGB(18, 8, 35)
local C_ROW     = Color3.fromRGB(20, 10, 38)
local C_ROW_HOV = Color3.fromRGB(45, 20, 80)
local C_BORDER  = Color3.fromRGB(140, 60, 220)
local C_BORDER2 = Color3.fromRGB(180, 100, 255)
local C_HEADER  = Color3.fromRGB(12, 5, 25)
local C_ACCENT  = Color3.fromRGB(210, 160, 255)
local C_ACCENT2 = Color3.fromRGB(180, 100, 255)
local C_DIM     = Color3.fromRGB(140, 90, 190)
local C_WHITE   = Color3.fromRGB(255, 255, 255)
local C_ON_BG   = Color3.fromRGB(130, 40, 220)
local C_OFF_BG  = Color3.fromRGB(35, 15, 60)
local C_KEY_BG  = Color3.fromRGB(25, 10, 50)

local Anims = {
	idle1    = "rbxassetid://133806214992291",
	idle2    = "rbxassetid://94970088341563",
	walk     = "rbxassetid://707897309",
	run      = "rbxassetid://707861613",
	jump     = "rbxassetid://116936326516985",
	fall     = "rbxassetid://116936326516985",
	climb    = "rbxassetid://116936326516985",
	swim     = "rbxassetid://116936326516985",
	swimidle = "rbxassetid://116936326516985",
}

task.spawn(function()
	pcall(function()
		ContentProvider:PreloadAsync({
			Anims.idle1, Anims.idle2, Anims.walk, Anims.run,
			Anims.jump, Anims.fall, Anims.climb, Anims.swim, Anims.swimidle,
		})
	end)
end)

local animHeartbeatConn = nil
local savedAnimate = nil
local originalAnims = nil

local function isPackAnim(id)
	if not id then return false end
	for _, v in pairs(Anims) do if v == id then return true end end
	return false
end

local function saveOriginalAnims(char)
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function g(obj) return obj and obj.AnimationId or nil end
	local ids = {
		idle1    = g(animate.idle     and animate.idle.Animation1),
		idle2    = g(animate.idle     and animate.idle.Animation2),
		walk     = g(animate.walk     and animate.walk.WalkAnim),
		run      = g(animate.run      and animate.run.RunAnim),
		jump     = g(animate.jump     and animate.jump.JumpAnim),
		fall     = g(animate.fall     and animate.fall.FallAnim),
		climb    = g(animate.climb    and animate.climb.ClimbAnim),
		swim     = g(animate.swim     and animate.swim.Swim),
		swimidle = g(animate.swimidle and animate.swimidle.SwimIdle),
	}
	if not isPackAnim(ids.walk) then originalAnims = ids end
end

local function applyAnimPack(char)
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function s(obj, id) if obj then obj.AnimationId = id end end
	s(animate.idle     and animate.idle.Animation1,     Anims.idle1)
	s(animate.idle     and animate.idle.Animation2,     Anims.idle2)
	s(animate.walk     and animate.walk.WalkAnim,       Anims.walk)
	s(animate.run      and animate.run.RunAnim,         Anims.run)
	s(animate.jump     and animate.jump.JumpAnim,       Anims.jump)
	s(animate.fall     and animate.fall.FallAnim,       Anims.fall)
	s(animate.climb    and animate.climb.ClimbAnim,     Anims.climb)
	s(animate.swim     and animate.swim.Swim,           Anims.swim)
	s(animate.swimidle and animate.swimidle.SwimIdle,   Anims.swimidle)
end

local function restoreOriginalAnims(char)
	if not originalAnims then return end
	local animate = char:FindFirstChild("Animate")
	if not animate then return end
	local function s(obj, id) if obj and id then obj.AnimationId = id end end
	s(animate.idle     and animate.idle.Animation1,     originalAnims.idle1)
	s(animate.idle     and animate.idle.Animation2,     originalAnims.idle2)
	s(animate.walk     and animate.walk.WalkAnim,       originalAnims.walk)
	s(animate.run      and animate.run.RunAnim,         originalAnims.run)
	s(animate.jump     and animate.jump.JumpAnim,       originalAnims.jump)
	s(animate.fall     and animate.fall.FallAnim,       originalAnims.fall)
	s(animate.climb    and animate.climb.ClimbAnim,     originalAnims.climb)
	s(animate.swim     and animate.swim.Swim,           originalAnims.swim)
	s(animate.swimidle and animate.swimidle.SwimIdle,   originalAnims.swimidle)
	local hum2 = char:FindFirstChildOfClass("Humanoid")
	if hum2 then
		for _, track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end
		hum2:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function startAnimToggle()
	if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
	local char = LP.Character
	if char then
		saveOriginalAnims(char)
		applyAnimPack(char)
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then
			for _, track in ipairs(hum2:GetPlayingAnimationTracks()) do track:Stop(0) end
			hum2:ChangeState(Enum.HumanoidStateType.Running)
		end
	end
	animHeartbeatConn = RunService.Heartbeat:Connect(function()
		if not State.animEnabled then return end
		local c = LP.Character
		if c then applyAnimPack(c) end
	end)
end

local function stopAnimToggle()
	if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
	local char = LP.Character
	if char then restoreOriginalAnims(char) end
end

local function startUnwalk()
	if State.unwalkEnabled then return end
	State.unwalkEnabled = true
	local c = LP.Character
	if not c then return end
	local hum = c:FindFirstChildOfClass("Humanoid")
	if hum then for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
	local anim = c:FindFirstChild("Animate")
	if anim then savedAnimate = anim:Clone(); anim:Destroy() end
end

local function stopUnwalk()
	if not State.unwalkEnabled then return end
	State.unwalkEnabled = false
	local c = LP.Character
	if c and savedAnimate then
		savedAnimate.Parent = c; savedAnimate.Disabled = false; savedAnimate = nil
	end
	task.spawn(function()
		task.wait(0.15)
		local char = LP.Character
		if not char then return end
		if State.animEnabled then saveOriginalAnims(char); applyAnimPack(char)
		else restoreOriginalAnims(char) end
	end)
end

-- Cleanup old GUIs
for _, name in pairs({"MachoHubGUI","ThunderHubGUI"}) do
	local old = game:GetService("CoreGui"):FindFirstChild(name)
	if old then old:Destroy() end
	local old2 = LP:FindFirstChild("PlayerGui") and LP.PlayerGui:FindFirstChild(name)
	if old2 then old2:Destroy() end
end

local closeBtnRef = nil
local miniButtonRef = nil
local miniBtn = nil

local function makeMainDraggable(frame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	local startCloseBtnPos
	frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = frame.Position
			if closeBtnRef then startCloseBtnPos = closeBtnRef.Position end
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End or inp.UserInputState == Enum.UserInputState.Cancelled then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local dx = inp.Position.X - dragStart.X
			local dy = inp.Position.Y - dragStart.Y
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
			if closeBtnRef and startCloseBtnPos then
				closeBtnRef.Position = UDim2.new(startCloseBtnPos.X.Scale, startCloseBtnPos.X.Offset + dx, startCloseBtnPos.Y.Scale, startCloseBtnPos.Y.Offset + dy)
			end
		end
	end)
end

local function makeMiniDraggable(frame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	frame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = frame.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End or inp.UserInputState == Enum.UserInputState.Cancelled then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if inp == dragInput and dragging then
			local dx = inp.Position.X - dragStart.X
			local dy = inp.Position.Y - dragStart.Y
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
		end
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name="MachoHubGUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=10
gui.IgnoreGuiInset=true; gui.Parent=LP:WaitForChild("PlayerGui")

-- ================= RGB DISCORD BANNER (TOP CENTER - BأœYأœK) =================
local discordBanner = Instance.new("Frame", gui)
discordBanner.Name = "DiscordBanner"
discordBanner.Size = UDim2.new(0, 380, 0, 44)
discordBanner.Position = UDim2.new(0.5, -190, 0, 8)
discordBanner.BackgroundColor3 = Color3.fromRGB(8, 4, 18)
discordBanner.BackgroundTransparency = 0.05
discordBanner.BorderSizePixel = 0
discordBanner.ZIndex = 30
discordBanner.Active = true
Instance.new("UICorner", discordBanner).CornerRadius = UDim.new(0, 12)

local discordBannerStroke = Instance.new("UIStroke", discordBanner)
discordBannerStroke.Thickness = 2
discordBannerStroke.Transparency = 0

-- RGB border animation on banner
task.spawn(function()
	local hue = 0
	while discordBanner and discordBanner.Parent do
		hue = (hue + 1) % 360
		discordBannerStroke.Color = Color3.fromHSV(hue/360, 1, 1)
		task.wait(0.03)
	end
end)

local discordLbl = Instance.new("TextLabel", discordBanner)
discordLbl.Size = UDim2.new(1, 0, 1, 0)
discordLbl.BackgroundTransparency = 1
discordLbl.Text = "ًںژ®  MachoHub  |  discord.gg/YhHDwbyfcA"
discordLbl.Font = Enum.Font.GothamBlack
discordLbl.TextSize = 17
discordLbl.TextXAlignment = Enum.TextXAlignment.Center
discordLbl.ZIndex = 31

-- RGB text animation
task.spawn(function()
	local hue = 180
	while discordLbl and discordLbl.Parent do
		hue = (hue + 1) % 360
		discordLbl.TextColor3 = Color3.fromHSV(hue/360, 0.7, 1)
		task.wait(0.04)
	end
end)

-- Draggable banner
local _dbDrag,_dbDragInput,_dbDragStart,_dbStartPos=false,nil,nil,nil
discordBanner.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		_dbDrag=true; _dbDragStart=i.Position; _dbStartPos=discordBanner.Position
	end
end)
discordBanner.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
		_dbDragInput=i
	end
end)
UIS.InputChanged:Connect(function(i)
	if i==_dbDragInput and _dbDrag then
		local d=i.Position-_dbDragStart
		discordBanner.Position=UDim2.new(_dbStartPos.X.Scale,_dbStartPos.X.Offset+d.X,_dbStartPos.Y.Scale,_dbStartPos.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then _dbDrag=false end
end)

-- ========== FPS/PING TITLE BOX (below discord banner) ==========
local titleBox = Instance.new("Frame", gui)
titleBox.Size = UDim2.new(0, 280, 0, 28)
titleBox.Position = UDim2.new(0.5, -140, 0, 60)
titleBox.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
titleBox.BorderSizePixel = 0; titleBox.ZIndex = 20; titleBox.Active = true
Instance.new("UICorner", titleBox).CornerRadius = UDim.new(0, 8)
local tbStroke = Instance.new("UIStroke", titleBox)
tbStroke.Color = Color3.fromRGB(160, 60, 255); tbStroke.Thickness = 1.5; tbStroke.Transparency = 0

local titleBoxLbl = Instance.new("TextLabel", titleBox)
titleBoxLbl.Size = UDim2.new(1, 0, 1, 0)
titleBoxLbl.BackgroundTransparency = 1
titleBoxLbl.Text = "ًں’œ MACHO HUB ًں’œ  |  FPS: --  |  Ping: -- ms"
titleBoxLbl.TextColor3 = Color3.fromRGB(200, 140, 255)
titleBoxLbl.Font = Enum.Font.GothamBlack; titleBoxLbl.TextSize = 11
titleBoxLbl.TextXAlignment = Enum.TextXAlignment.Center; titleBoxLbl.ZIndex = 21

-- Draggable title box
local _tbDrag,_tbDragInput,_tbDragStart,_tbStartPos=false,nil,nil,nil
titleBox.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
		_tbDrag=true;_tbDragStart=i.Position;_tbStartPos=titleBox.Position
	end
end)
titleBox.InputChanged:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then _tbDragInput=i end
end)
UIS.InputChanged:Connect(function(i)
	if i==_tbDragInput and _tbDrag then
		local d=i.Position-_tbDragStart
		titleBox.Position=UDim2.new(_tbStartPos.X.Scale,_tbStartPos.X.Offset+d.X,_tbStartPos.Y.Scale,_tbStartPos.Y.Offset+d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then _tbDrag=false end
end)

-- Live fps/ping
local _stats = game:GetService("Stats")
task.spawn(function()
	local _last=tick(); local _frames=0; local _fps=0
	RunService.RenderStepped:Connect(function()
		_frames=_frames+1; local now=tick()
		if now-_last>=0.5 then
			_fps=math.floor(_frames/(now-_last)+0.5); _frames=0; _last=now
			local ping=0
			pcall(function() ping=math.floor(_stats.Network.ServerStatsItem["Data Ping"]:GetValue()+0.5) end)
			titleBoxLbl.Text=string.format("ًں’œ MACHO HUB ًں’œ  |  FPS: %d  |  Ping: %d ms",_fps,ping)
		end
	end)
end)

-- ========== STEAL PROGRESS BAR ==========
local stealProgressBar = Instance.new("Frame", gui)
stealProgressBar.Size = UDim2.new(0.35, 0, 0, 14)
stealProgressBar.Position = UDim2.new(0.325, 0, 0.95, 0)
stealProgressBar.BackgroundColor3 = Color3.fromRGB(0,0,0)
stealProgressBar.BackgroundTransparency = 0.5
stealProgressBar.BorderSizePixel = 0
stealProgressBar.ZIndex = 100
Instance.new("UICorner", stealProgressBar).CornerRadius = UDim.new(0, 7)

local barFill = Instance.new("Frame", stealProgressBar)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 7)

AutoSteal.ProgressFill = barFill
AutoSteal.ProgressText = nil

local function makeStealBarDraggable(frame)
	local dragging = false; local dragInput = nil; local dragStart = nil; local startPos = nil; local activeDragConn = nil
	local function stopDrag()
		dragging = false; dragInput = nil; dragStart = nil; startPos = nil
		if activeDragConn then activeDragConn:Disconnect(); activeDragConn = nil end
	end
	local function startDragWatch()
		if activeDragConn then activeDragConn:Disconnect() end
		activeDragConn = RunService.Heartbeat:Connect(function()
			if dragging and MobileButtons.Locked then stopDrag() end
		end)
	end
	frame.InputBegan:Connect(function(input)
		if MobileButtons.Locked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true; dragStart = input.Position; startPos = frame.Position; startDragWatch()
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancelled then stopDrag() end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if not dragging then return end
		if MobileButtons.Locked then stopDrag(); return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			if MobileButtons.Locked then stopDrag(); return end
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end
makeStealBarDraggable(stealProgressBar)

local function saveStealBarPosition()
	local pos = stealProgressBar.Position
	local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
	pcall(function() writefile("MachoStealBarPos.txt", str) end)
end
local function loadStealBarPosition()
	local savedPos = nil
	pcall(function() savedPos = readfile("MachoStealBarPos.txt") end)
	if savedPos and savedPos ~= "" then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			stealProgressBar.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end
end
loadStealBarPosition()
local lastStealBarSave = 0
stealProgressBar:GetPropertyChangedSignal("Position"):Connect(function()
	if tick() - lastStealBarSave > 0.5 then lastStealBarSave = tick(); saveStealBarPosition() end
end)

-- ========== MAIN FRAME ==========
local main = Instance.new("Frame",gui)
main.Name="Main"; main.Size=UDim2.new(0,310,0,560)
main.Position=UDim2.new(0,20,0,20)
main.BackgroundColor3=C_BG; main.BorderSizePixel=0; main.Active=true; main.ClipsDescendants=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local mainStroke = Instance.new("UIStroke",main); mainStroke.Color=C_BORDER2; mainStroke.Thickness=1.5

-- Animated main border
task.spawn(function()
	local hue = 270
	while main and main.Parent do
		hue = (hue + 0.5) % 360
		mainStroke.Color = Color3.fromHSV(hue/360, 0.9, 1)
		task.wait(0.05)
	end
end)

local function saveMainPosition()
	local pos = main.Position
	local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
	pcall(function() writefile("MachoHubGUIPos.txt", str) end)
end
local function saveMiniPosition()
	if miniBtn then
		local pos = miniBtn.Position
		local str = string.format("%.3f,%.1f,%.3f,%.1f", pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset)
		pcall(function() writefile("MachoMiniPos.txt", str) end)
	end
end
local function loadMainPosition()
	local savedPos = nil
	pcall(function() savedPos = readfile("MachoHubGUIPos.txt") end)
	if savedPos and savedPos ~= "" then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			main.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end
end
local function loadMiniPosition()
	local savedPos = nil
	pcall(function() savedPos = readfile("MachoMiniPos.txt") end)
	if savedPos and savedPos ~= "" and miniBtn then
		local parts = {}
		for part in string.gmatch(savedPos, "[^,]+") do table.insert(parts, part) end
		if #parts >= 4 then
			miniBtn.Position = UDim2.new(tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3]), tonumber(parts[4]))
		end
	end
end

local header = Instance.new("Frame",main)
header.Size=UDim2.new(1,0,0,44); header.BackgroundColor3=C_HEADER; header.BorderSizePixel=0; header.ZIndex=5
local headerDiv = Instance.new("Frame",header)
headerDiv.Size=UDim2.new(1,0,0,1); headerDiv.Position=UDim2.new(0,0,1,-1)
headerDiv.BackgroundColor3=C_BORDER; headerDiv.BorderSizePixel=0; headerDiv.ZIndex=6

local titleLbl = Instance.new("TextLabel",header)
titleLbl.Size=UDim2.new(0,200,0,20); titleLbl.Position=UDim2.new(0,12,0,8)
titleLbl.BackgroundTransparency=1; titleLbl.Text="ًں’œ MACHO HUB ًں’œ"
titleLbl.TextColor3=C_ACCENT; titleLbl.Font=Enum.Font.GothamBlack; titleLbl.TextSize=15
titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=6

-- RGB title label
task.spawn(function()
	local hue = 270
	while titleLbl and titleLbl.Parent do
		hue = (hue + 1) % 360
		titleLbl.TextColor3 = Color3.fromHSV(hue/360, 0.8, 1)
		task.wait(0.05)
	end
end)

local subLbl = Instance.new("TextLabel",header)
subLbl.Size=UDim2.new(0,200,0,14); subLbl.Position=UDim2.new(0,13,0,28)
subLbl.BackgroundTransparency=1; subLbl.Text="Best Duel Script"
subLbl.TextColor3=C_DIM; subLbl.Font=Enum.Font.Gotham; subLbl.TextSize=10
subLbl.TextXAlignment=Enum.TextXAlignment.Left; subLbl.ZIndex=6

local closeBtn = Instance.new("TextButton",gui)
closeBtn.Size=UDim2.new(0,26,0,26)
closeBtn.BackgroundColor3=Color3.fromRGB(25,10,50); closeBtn.BorderSizePixel=0
closeBtn.Text="X"; closeBtn.TextColor3=Color3.fromRGB(200,140,255)
closeBtn.Font=Enum.Font.GothamBlack; closeBtn.TextSize=13; closeBtn.ZIndex=50
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
local closeBtnStroke = Instance.new("UIStroke",closeBtn)
closeBtnStroke.Color=Color3.fromRGB(160,60,255); closeBtnStroke.Thickness=1.5
closeBtnRef = closeBtn

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(120,20,180),TextColor3=C_WHITE}):Play()
	TweenService:Create(closeBtnStroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(200,100,255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(25,10,50),TextColor3=Color3.fromRGB(200,140,255)}):Play()
	TweenService:Create(closeBtnStroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(160,60,255)}):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	closeBtn.Visible = false
	if miniBtn then miniBtn.Visible = true end
end)

miniBtn = Instance.new("TextButton",gui)
miniBtn.Name = "MachoMiniButton"
miniBtn.Size = UDim2.new(0,46,0,46)
miniBtn.Position = UDim2.new(0,20,0,100)
miniBtn.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
miniBtn.BackgroundTransparency = 0
miniBtn.Text = "ًں’œ"
miniBtn.TextColor3 = Color3.fromRGB(200,140,255)
miniBtn.Font = Enum.Font.GothamBlack
miniBtn.TextSize = 22
miniBtn.BorderSizePixel = 0
miniBtn.Visible = false
miniBtn.ZIndex = 50
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0,10)
local miniBtnStroke = Instance.new("UIStroke", miniBtn)
miniBtnStroke.Color = Color3.fromRGB(160,60,255)
miniBtnStroke.Thickness = 1.5

-- RGB mini button border
task.spawn(function()
	local hue = 270
	while miniBtn and miniBtn.Parent do
		hue = (hue + 1) % 360
		miniBtnStroke.Color = Color3.fromHSV(hue/360, 1, 1)
		task.wait(0.04)
	end
end)

miniBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	closeBtn.Visible = true
	miniBtn.Visible = false
end)
miniBtn.MouseEnter:Connect(function()
	TweenService:Create(miniBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(30,15,60)}):Play()
end)
miniBtn.MouseLeave:Connect(function()
	TweenService:Create(miniBtn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(10,5,20)}):Play()
end)

miniButtonRef = miniBtn
makeMainDraggable(main)
makeMiniDraggable(miniBtn)

local lastSaveTime = 0
main:GetPropertyChangedSignal("Position"):Connect(function()
	if tick() - lastSaveTime > 0.5 then lastSaveTime = tick(); saveMainPosition() end
end)
local lastMiniSaveTime = 0
miniBtn:GetPropertyChangedSignal("Position"):Connect(function()
	if tick() - lastMiniSaveTime > 0.5 then lastMiniSaveTime = tick(); saveMiniPosition() end
end)

local function updateCloseButtonPosition()
	if main.Visible then
		local mainPos = main.Position
		closeBtn.Position = UDim2.new(mainPos.X.Scale, mainPos.X.Offset + 310 - 32, mainPos.Y.Scale, mainPos.Y.Offset + 10)
	end
end
main:GetPropertyChangedSignal("Position"):Connect(updateCloseButtonPosition)
main:GetPropertyChangedSignal("Visible"):Connect(updateCloseButtonPosition)

local scroll = Instance.new("ScrollingFrame",main)
scroll.Size=UDim2.new(1,0,1,-44); scroll.Position=UDim2.new(0,0,0,44)
scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=2
scroll.ScrollBarImageColor3=C_BORDER2; scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.ZIndex=2
local listLayout = Instance.new("UIListLayout",scroll)
listLayout.SortOrder=Enum.SortOrder.LayoutOrder; listLayout.Padding=UDim.new(0,2)
local pad = Instance.new("UIPadding",scroll)
pad.PaddingLeft=UDim.new(0,10); pad.PaddingRight=UDim.new(0,10)
pad.PaddingTop=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,12)

local lo = 0
local function LO() lo+=1; return lo end
local function makeGap(px)
	local f=Instance.new("Frame",scroll); f.Size=UDim2.new(1,0,0,px or 4)
	f.BackgroundTransparency=1; f.BorderSizePixel=0; f.LayoutOrder=LO()
end
local function makeDivider()
	local f=Instance.new("Frame",scroll); f.Size=UDim2.new(1,0,0,1)
	f.BackgroundColor3=C_BORDER; f.BorderSizePixel=0; f.LayoutOrder=LO()
end
local function makeSectionLabel(text)
	local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,26)
	row.BackgroundTransparency=1; row.BorderSizePixel=0; row.LayoutOrder=LO()
	local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency=1; lbl.Text=text:upper(); lbl.TextColor3=C_ACCENT2
	lbl.Font=Enum.Font.GothamBold; lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left
end

local function makeInputRow(label, default, onChange)
	local row = Instance.new("Frame", scroll)
	row.Size = UDim2.new(1,0,0,42)
	row.BackgroundColor3 = C_ROW
	row.BorderSizePixel = 0
	row.LayoutOrder = LO()
	Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)
	local rowStroke = Instance.new("UIStroke",row); rowStroke.Color=C_BORDER; rowStroke.Thickness=1

	local lbl = Instance.new("TextLabel",row)
	lbl.Size = UDim2.new(0.55,0,1,0)
	lbl.Position = UDim2.new(0,12,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = label
	lbl.TextColor3 = C_ACCENT
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 2

	local box = Instance.new("TextBox",row)
	box.Size = UDim2.new(0,90,0,34)
	box.Position = UDim2.new(1,-96,0.5,-17)
	box.BackgroundColor3 = C_KEY_BG
	box.BorderSizePixel = 0
	box.Text = tostring(default)
	box.TextColor3 = C_ACCENT
	box.Font = Enum.Font.GothamBold
	box.TextSize = 14
	box.ClearTextOnFocus = true
	box.PlaceholderText = "0"
	box.ZIndex = 3
	Instance.new("UICorner",box).CornerRadius = UDim.new(0,6)
	local bs = Instance.new("UIStroke",box); bs.Color=C_BORDER; bs.Thickness=1

	box.InputBegan:Connect(function(input) input:StopPropagation() end)
	box.Focused:Connect(function()
		TweenService:Create(bs,TweenInfo.new(0.15),{Color=C_BORDER2}):Play()
		box.BackgroundColor3 = Color3.fromRGB(35,15,65)
	end)
	box.FocusLost:Connect(function(enterPressed)
		TweenService:Create(bs,TweenInfo.new(0.15),{Color=C_BORDER}):Play()
		box.BackgroundColor3 = C_KEY_BG
		local num = tonumber(box.Text)
		if num ~= nil then
			local finalVal = math.floor(math.clamp(num, 0, 500))
			box.Text = tostring(finalVal)
			if onChange then onChange(tostring(finalVal)) end
			autoSaveConfig()
		else
			box.Text = tostring(default)
		end
	end)
	box.Active = true; box.Selectable = true
	row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOV}):Play() end)
	row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW}):Play() end)
	return box
end

local function makeStatusRow(label, valTxt)
	local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,36); row.BackgroundColor3=C_ROW
	row.BorderSizePixel=0; row.LayoutOrder=LO()
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",row).Color=C_BORDER
	local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.5,0,1,0); lbl.Position=UDim2.new(0,12,0,0)
	lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C_ACCENT; lbl.Font=Enum.Font.GothamBold
	lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
	local val=Instance.new("TextLabel",row); val.Size=UDim2.new(0.45,-10,1,0); val.Position=UDim2.new(0.52,0,0,0)
	val.BackgroundTransparency=1; val.Text=valTxt; val.TextColor3=C_ACCENT2
	val.Font=Enum.Font.GothamBlack; val.TextSize=12; val.TextXAlignment=Enum.TextXAlignment.Right
	return val
end

local function makeActionBtn(label, onClick)
	local btn=Instance.new("TextButton",scroll)
	btn.Size=UDim2.new(1,0,0,36); btn.BackgroundColor3=C_PANEL; btn.BorderSizePixel=0
	btn.LayoutOrder=LO(); btn.Text=label; btn.TextColor3=C_WHITE; btn.Font=Enum.Font.GothamBold; btn.TextSize=13
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",btn).Color=C_BORDER2
	btn.MouseButton1Click:Connect(function()
		TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C_BORDER2}):Play()
		task.delay(0.16,function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C_PANEL}):Play() end)
		if onClick then pcall(onClick) end
	end)
	btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOV}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C_PANEL}):Play() end)
	return btn
end

local function makeKeybindRow(label, currentKey, onChanged)
	local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,38); row.BackgroundColor3=C_ROW; row.LayoutOrder=LO()
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",row).Color=C_BORDER
	local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.55,0,1,0); lbl.Position=UDim2.new(0,12,0,0)
	lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C_ACCENT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
	local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(0,82,0,26); btn.Position=UDim2.new(1,-88,0.5,-13)
	btn.BackgroundColor3=C_KEY_BG; btn.BorderSizePixel=0; btn.Text=currentKey.Name; btn.TextColor3=C_ACCENT
	btn.Font=Enum.Font.GothamBold; btn.TextSize=11
	Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
	local bs=Instance.new("UIStroke",btn); bs.Color=C_BORDER2; bs.Thickness=1
	row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOV}):Play() end)
	row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW}):Play() end)
	local listening=false; local listenConn
	local function stopListen(key)
		listening=false; if listenConn then listenConn:Disconnect(); listenConn=nil end
		TweenService:Create(bs,TweenInfo.new(0.12),{Color=C_BORDER2}):Play(); btn.TextColor3=C_ACCENT
		if key then btn.Text=key.Name; if onChanged then onChanged(key) end; autoSaveConfig() end
	end
	btn.MouseButton1Click:Connect(function()
		if listening then stopListen(nil); return end
		listening=true; btn.Text="..."; btn.TextColor3=C_ACCENT2
		TweenService:Create(bs,TweenInfo.new(0.12),{Color=C_ACCENT2}):Play()
		listenConn=UIS.InputBegan:Connect(function(inp, gp)
			if not listening then return end
			if inp.UserInputType == Enum.UserInputType.Keyboard then
				if inp.KeyCode==Enum.KeyCode.Escape then stopListen(nil); return end
				stopListen(inp.KeyCode)
			elseif inp.UserInputType == Enum.UserInputType.Gamepad1 then
				if inp.KeyCode==Enum.KeyCode.Escape then stopListen(nil); return end
				stopListen(inp.KeyCode)
			end
		end)
	end)
	return btn
end

local function makeToggleRow(label, defaultKey, defaultOn, onToggle, onKeyChanged)
	local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,38); row.BackgroundColor3=C_ROW; row.LayoutOrder=LO()
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
	local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=C_BORDER; rowStroke.Thickness=1
	local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0,130,1,0); lbl.Position=UDim2.new(0,12,0,0)
	lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=C_ACCENT; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left
	local keyBtn=nil
	if defaultKey then
		keyBtn=Instance.new("TextButton",row); keyBtn.Size=UDim2.new(0,72,0,24); keyBtn.Position=UDim2.new(1,-130,0.5,-12)
		keyBtn.BackgroundColor3=C_KEY_BG; keyBtn.BorderSizePixel=0; keyBtn.Text=defaultKey.Name
		keyBtn.TextColor3=Color3.fromRGB(220,180,255); keyBtn.Font=Enum.Font.GothamBold; keyBtn.TextSize=10; keyBtn.ZIndex=5
		Instance.new("UICorner",keyBtn).CornerRadius=UDim.new(0,4)
		local ks=Instance.new("UIStroke",keyBtn); ks.Color=C_BORDER; ks.Thickness=1
		local kListening=false; local kConn
		local function kStop(key)
			kListening=false; if kConn then kConn:Disconnect(); kConn=nil end
			TweenService:Create(ks,TweenInfo.new(0.12),{Color=C_BORDER}):Play(); keyBtn.TextColor3=Color3.fromRGB(220,180,255)
			if key then keyBtn.Text=key.Name; if onKeyChanged then onKeyChanged(key) end; autoSaveConfig() end
		end
		keyBtn.MouseButton1Click:Connect(function()
			if kListening then kStop(nil); return end
			kListening=true; keyBtn.Text="..."; keyBtn.TextColor3=C_WHITE
			TweenService:Create(ks,TweenInfo.new(0.12),{Color=C_ACCENT}):Play()
			kConn=UIS.InputBegan:Connect(function(inp, gp)
				if not kListening then return end
				if inp.UserInputType == Enum.UserInputType.Keyboard then
					if inp.KeyCode==Enum.KeyCode.Escape then kStop(nil); return end
					kStop(inp.KeyCode)
				elseif inp.UserInputType == Enum.UserInputType.Gamepad1 then
					if inp.KeyCode==Enum.KeyCode.Escape then kStop(nil); return end
					kStop(inp.KeyCode)
				end
			end)
		end)
	end
	local pillBg=Instance.new("Frame",row); pillBg.Size=UDim2.new(0,40,0,20); pillBg.Position=UDim2.new(1,-46,0.5,-10)
	pillBg.BackgroundColor3=defaultOn and C_ON_BG or C_OFF_BG; pillBg.BorderSizePixel=0; pillBg.ZIndex=5
	Instance.new("UICorner",pillBg).CornerRadius=UDim.new(1,0)
	local pStroke=Instance.new("UIStroke",pillBg); pStroke.Color=defaultOn and C_ACCENT2 or C_BORDER; pStroke.Thickness=1.2
	local dot=Instance.new("Frame",pillBg); dot.Size=UDim2.new(0,14,0,14); dot.Position=defaultOn and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
	dot.BackgroundColor3=C_WHITE; dot.BorderSizePixel=0; dot.ZIndex=6
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local isOn=defaultOn or false
	local function setV(on)
		isOn=on
		TweenService:Create(pillBg,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{BackgroundColor3=on and C_ON_BG or C_OFF_BG}):Play()
		TweenService:Create(pStroke,TweenInfo.new(0.2),{Color=on and C_ACCENT2 or C_BORDER}):Play()
		TweenService:Create(dot,TweenInfo.new(0.2,Enum.EasingStyle.Back),{
			Position=on and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
			BackgroundColor3=C_WHITE
		}):Play()
	end
	local clk=Instance.new("TextButton",row); clk.Size=UDim2.new(1,0,1,0); clk.BackgroundTransparency=1; clk.Text=""; clk.ZIndex=3
	clk.MouseButton1Click:Connect(function()
		isOn=not isOn; setV(isOn); if onToggle then pcall(onToggle,isOn) end
		autoSaveConfig()
	end)
	if keyBtn then keyBtn.ZIndex=6 end
	pillBg.ZIndex=5; dot.ZIndex=6
	clk.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW_HOV}):Play() end)
	clk.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C_ROW}):Play() end)
	return setV, keyBtn
end

-- ================= UI SECTIONS =================
makeSectionLabel("Speed")
normalBox = makeInputRow("Normal Speed", State.normalSpeed, function(v) local n=tonumber(v); if n and n>0 and n<=500 then State.normalSpeed=n end end)
carryBox  = makeInputRow("Carry Speed",  State.carrySpeed,  function(v) local n=tonumber(v); if n and n>0 and n<=500 then State.carrySpeed=n  end end)
setSpeedToggleUI, speedKeyBtn = makeToggleRow("Speed Toggle (Normal/Carry)", Keys.speed, false, function(on) toggleSpeedType() end, function(k) Keys.speed = k end)
modeValLbl = makeStatusRow("Mode","Normal")
makeGap(4); makeDivider(); makeGap(4)

makeSectionLabel("Lagger Speed")
laggerBox = makeInputRow("Lagger Normal", State.laggerSpeed, function(v) local n=tonumber(v); if n and n>0 and n<=500 then State.laggerSpeed=n end end)
carryLaggerBox = makeInputRow("Lagger Carry", State.laggerCarrySpeed, function(v) local n=tonumber(v); if n and n>0 and n<=500 then State.laggerCarrySpeed=n end end)
setLaggerToggleUI, laggerKeyBtn = makeToggleRow("Lagger Toggle", Keys.lagger, false, function(on) toggleLagger() end, function(k) Keys.lagger = k end)
makeGap(4); makeDivider(); makeGap(4)

makeSectionLabel("Combat")
setAutoBat, autoBatKeyBtn = makeToggleRow("Auto Bat", Keys.autoBat, false, function(on) State.autoBatToggled=on; if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(on) end end, function(k) Keys.autoBat=k end)
makeGap(4); makeDivider(); makeGap(4)

makeSectionLabel("Mechanics")
local radiusBox = makeInputRow("Grab Radius", AutoSteal.Radius, function(v)
	local n = tonumber(v)
	if n and n >= 5 and n <= 300 then
		AutoSteal.Radius = math.floor(n)
		if progressRadLbl then progressRadLbl.Text = "Radius: "..AutoSteal.Radius end
	end
end)
setInstaGrab = makeToggleRow("Auto Grab (Progression)", nil, false, function(on)
	AutoSteal.Enabled = on
	if on then startAutoSteal() else stopAutoSteal() end
end)
setInfJump = makeToggleRow("Infinite Jump", nil, false, function(on) State.infJumpEnabled=on end)
setAntiRag = makeToggleRow("Anti Ragdoll", nil, false, function(on)
	State.antiRagdollEnabled=on; if on then startAntiRagdoll() else stopAntiRagdoll() end
end)
setFps = makeToggleRow("FPS Boost", nil, false, function(on)
	State.fpsBoostEnabled=on; if on then pcall(applyFPSBoost) end
end)
setMedusaCounter = makeToggleRow("Medusa Counter", nil, false, function(on)
	State.medusaCounterEnabled=on
	if on then setupMedusaCounter(LP.Character) else stopMedusaCounter() end
end)
setAnimToggle = makeToggleRow("Tryhard Anim", nil, false, function(on)
	State.animEnabled=on
	if on then startAnimToggle() else stopAnimToggle() end
end)
setUnwalkToggle = makeToggleRow("Unwalk", nil, false, function(on)
	if on then startUnwalk() else stopUnwalk() end
end)
makeGap(4); makeDivider(); makeGap(4)

makeSectionLabel("Teleport / Movement")
tpDownKeyBtn = makeKeybindRow("TP Down (sol)", Keys.tpDown, function(k) Keys.tpDown = k end)
dropBrainrotKeyBtn = makeKeybindRow("Drop Brainrot", Keys.dropBrainrot, function(k) Keys.dropBrainrot=k end)
setAutoLeft, autoLeftKeyBtn = makeToggleRow("Auto Left", Keys.autoLeft, false,
	function(on)
		State.autoLeftEnabled=on
		if on and MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(true) end
		if not on and MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end
		if on then startAutoLeft() else stopAutoLeft() end
	end,
	function(k) Keys.autoLeft=k end)
setAutoRight, autoRightKeyBtn = makeToggleRow("Auto Right", Keys.autoRight, false,
	function(on)
		State.autoRightEnabled=on
		if on and MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(true) end
		if not on and MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end
		if on then startAutoRight() else stopAutoRight() end
	end,
	function(k) Keys.autoRight=k end)
makeGap(4); makeDivider(); makeGap(4)

makeSectionLabel("Interface")
guiHideKeyBtn = makeKeybindRow("Hide / Show GUI", Keys.guiHide, function(k) Keys.guiHide=k end)

local lockMobileSetActive, lockMobileKeyBtn = makeToggleRow("Lock Mobile Buttons", nil, false, function(on)
	MobileButtons.Locked = on
	autoSaveConfig()
end)

local manetteNote = Instance.new("TextLabel", scroll)
manetteNote.Size = UDim2.new(1, 0, 0, 18)
manetteNote.BackgroundTransparency = 1
manetteNote.Text = "âœ“ Compatible manette Xbox / Mobile"
manetteNote.TextColor3 = C_DIM
manetteNote.Font = Enum.Font.Gotham
manetteNote.TextSize = 9
manetteNote.TextXAlignment = Enum.TextXAlignment.Center
manetteNote.LayoutOrder = LO()

makeGap(4)

local showRow = Instance.new("Frame", scroll)
showRow.Size = UDim2.new(1,0,0,38)
showRow.BackgroundColor3 = C_ROW
showRow.BorderSizePixel = 0
showRow.LayoutOrder = LO()
Instance.new("UICorner", showRow).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", showRow).Color = C_BORDER

local showLbl = Instance.new("TextLabel", showRow)
showLbl.Size = UDim2.new(0,160,1,0)
showLbl.Position = UDim2.new(0,12,0,0)
showLbl.BackgroundTransparency = 1
showLbl.Text = "Show Mobile Buttons"
showLbl.TextColor3 = C_ACCENT
showLbl.Font = Enum.Font.GothamBold
showLbl.TextSize = 12
showLbl.TextXAlignment = Enum.TextXAlignment.Left

local showPill = Instance.new("Frame", showRow)
showPill.Size = UDim2.new(0,40,0,20)
showPill.Position = UDim2.new(1,-46,0.5,-10)
showPill.BackgroundColor3 = MobileButtons.Visible and C_ON_BG or C_OFF_BG
showPill.BorderSizePixel = 0
Instance.new("UICorner", showPill).CornerRadius = UDim.new(1,0)
local showStroke = Instance.new("UIStroke", showPill)
showStroke.Color = MobileButtons.Visible and C_ACCENT2 or C_BORDER
local showDot = Instance.new("Frame", showPill)
showDot.Size = UDim2.new(0,14,0,14)
showDot.Position = MobileButtons.Visible and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
showDot.BackgroundColor3 = MobileButtons.Visible and C_WHITE or C_DIM
Instance.new("UICorner", showDot).CornerRadius = UDim.new(1,0)

local showClick = Instance.new("TextButton", showRow)
showClick.Size = UDim2.new(1,0,1,0)
showClick.BackgroundTransparency = 1
showClick.Text = ""
showClick.MouseButton1Click:Connect(function()
	MobileButtons.Visible = not MobileButtons.Visible
	if MobileButtons.Frame then MobileButtons.Frame.Visible = MobileButtons.Visible end
	TweenService:Create(showPill, TweenInfo.new(0.2), {BackgroundColor3 = MobileButtons.Visible and C_ON_BG or C_OFF_BG}):Play()
	TweenService:Create(showStroke, TweenInfo.new(0.2), {Color = MobileButtons.Visible and C_ACCENT2 or C_BORDER}):Play()
	TweenService:Create(showDot, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
		Position = MobileButtons.Visible and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
		BackgroundColor3 = MobileButtons.Visible and C_WHITE or C_DIM
	}):Play()
	autoSaveConfig()
end)

makeGap(6)

local footerLbl = Instance.new("TextLabel",scroll)
footerLbl.Size=UDim2.new(1,0,0,18); footerLbl.BackgroundTransparency=1; footerLbl.LayoutOrder=LO()
footerLbl.Text="ًں’œ MACHO HUB ًں’œ  آ·  v1.0  آ·  discord.gg/YhHDwbyfcA"
footerLbl.TextColor3=C_DIM
footerLbl.Font=Enum.Font.Gotham; footerLbl.TextSize=9; footerLbl.TextXAlignment=Enum.TextXAlignment.Center

local function toggleGuiVis()
	State.guiVisible=not State.guiVisible
	main.Visible=State.guiVisible
	closeBtn.Visible=State.guiVisible
	if not State.guiVisible then
		miniBtn.Visible = true
	else
		miniBtn.Visible = false
	end
end

-- ========== MEDUSA ==========
local function findMedusa()
	local char=LP.Character; if not char then return nil end
	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then local tn=tool.Name:lower()
			if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end
	end
	local bp2=LP:FindFirstChild("Backpack")
	if bp2 then for _,tool in ipairs(bp2:GetChildren()) do
		if tool:IsA("Tool") then local tn=tool.Name:lower()
			if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end end
	end end
	return nil
end

local function useMedusaCounter()
	if State.medusaDebounce then return end
	if tick()-State.medusaLastUsed<25 then return end
	local char=LP.Character; if not char then return end
	State.medusaDebounce=true
	local med=findMedusa(); if not med then State.medusaDebounce=false; return end
	if med.Parent~=char then local hum2=char:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(med) end end
	pcall(function() med:Activate() end)
	State.medusaLastUsed=tick(); State.medusaDebounce=false
end

local function onAnchorChanged(part)
	return part:GetPropertyChangedSignal("Anchored"):Connect(function()
		if part.Anchored and part.Transparency==1 then useMedusaCounter() end
	end)
end
setupMedusaCounter = function(char)
	stopMedusaCounter(); if not char then return end
	for _,part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
	end
	table.insert(Conns.anchor, char.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then table.insert(Conns.anchor,onAnchorChanged(part)) end
	end))
end
stopMedusaCounter = function()
	for _,c in pairs(Conns.anchor) do pcall(function() c:Disconnect() end) end; Conns.anchor={}
end

startAutoLeft = function()
	if Conns.autoLeft then Conns.autoLeft:Disconnect() end
	State.autoLeftPhase = 1
	Conns.autoLeft = RunService.Heartbeat:Connect(function()
		if not State.autoLeftEnabled then return end
		local char = LP.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum2 then return end
		local spd = getAutoMoveSpeed()
		if State.autoLeftPhase == 1 then
			local tgt = Vector3.new(POS.L1.X, root.Position.Y, POS.L1.Z)
			if (tgt - root.Position).Magnitude < 1 then State.autoLeftPhase = 2; return end
			local d = (POS.L1 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		elseif State.autoLeftPhase == 2 then
			local tgt = Vector3.new(POS.L2.X, root.Position.Y, POS.L2.Z)
			if (tgt - root.Position).Magnitude < 1 then
				hum2:Move(Vector3.zero, false)
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				State.autoLeftEnabled = false
				if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft = nil end
				State.autoLeftPhase = 1
				if setAutoLeft then setAutoLeft(false) end
				if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end
				return
			end
			local d = (POS.L2 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
end

stopAutoLeft = function()
	if Conns.autoLeft then Conns.autoLeft:Disconnect(); Conns.autoLeft = nil end
	State.autoLeftPhase = 1
	local char = LP.Character
	if char then
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:Move(Vector3.zero, false) end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
	end
	if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end
end

startAutoRight = function()
	if Conns.autoRight then Conns.autoRight:Disconnect() end
	State.autoRightPhase = 1
	Conns.autoRight = RunService.Heartbeat:Connect(function()
		if not State.autoRightEnabled then return end
		local char = LP.Character; if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum2 then return end
		local spd = getAutoMoveSpeed()
		if State.autoRightPhase == 1 then
			local tgt = Vector3.new(POS.R1.X, root.Position.Y, POS.R1.Z)
			if (tgt - root.Position).Magnitude < 1 then State.autoRightPhase = 2; return end
			local d = (POS.R1 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		elseif State.autoRightPhase == 2 then
			local tgt = Vector3.new(POS.R2.X, root.Position.Y, POS.R2.Z)
			if (tgt - root.Position).Magnitude < 1 then
				hum2:Move(Vector3.zero, false)
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
				State.autoRightEnabled = false
				if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight = nil end
				State.autoRightPhase = 1
				if setAutoRight then setAutoRight(false) end
				if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end
				return
			end
			local d = (POS.R2 - root.Position)
			local mv = Vector3.new(d.X, 0, d.Z).Unit
			hum2:Move(mv, false)
			root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
		end
	end)
end

stopAutoRight = function()
	if Conns.autoRight then Conns.autoRight:Disconnect(); Conns.autoRight = nil end
	State.autoRightPhase = 1
	local char = LP.Character
	if char then
		local hum2 = char:FindFirstChildOfClass("Humanoid")
		if hum2 then hum2:Move(Vector3.zero, false) end
		local root = char:FindFirstChild("HumanoidRootPart")
		if root then root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0) end
	end
	if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end
end

startAntiRagdoll = function()
	if Conns.antiRag then return end
	Conns.antiRag=RunService.Heartbeat:Connect(function()
		local char=LP.Character; if not char then return end
		local hum2=char:FindFirstChildOfClass("Humanoid"); local root=char:FindFirstChild("HumanoidRootPart")
		if hum2 then
			local st=hum2:GetState()
			if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
				hum2:ChangeState(Enum.HumanoidStateType.Running); workspace.CurrentCamera.CameraSubject=hum2
				pcall(function() local pm=LP.PlayerScripts:FindFirstChild("PlayerModule"); if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)
				if root then root.Velocity=Vector3.new(0,0,0); root.RotVelocity=Vector3.new(0,0,0) end
			end
		end
		for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end
	end)
end
stopAntiRagdoll = function()
	if Conns.antiRag then Conns.antiRag:Disconnect(); Conns.antiRag=nil end
end

applyFPSBoost = function()
	pcall(function() setfpscap(999999999) end)
	local function processObj(v)
		pcall(function()
			if v:IsA("Model") then v.LevelOfDetail=Enum.ModelLevelOfDetail.Disabled; v.ModelStreamingMode=Enum.ModelStreamingMode.Nonatomic
			elseif v:IsA("MeshPart") then v.CastShadow=false; v.DoubleSided=false; v.RenderFidelity=Enum.RenderFidelity.Performance
			elseif v:IsA("BasePart") then v.CastShadow=false; v.Material=Enum.Material.Plastic; v.Reflectance=0
			elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
			elseif v:IsA("SpecialMesh") then v.TextureId=""
			elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled=false
			elseif v:IsA("SurfaceAppearance") or v:IsA("MaterialVariant") then v:Destroy()
			elseif v:IsA("Attachment") then v.Visible=false end
		end)
	end
	for _,v in pairs(workspace:GetDescendants()) do processObj(v) end
	pcall(function()
		local lighting=game:GetService("Lighting")
		for _,v in pairs(lighting:GetDescendants()) do
			pcall(function()
				if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Clouds") or v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") then v:Destroy() end
			end)
		end
		pcall(function() sethiddenproperty(game:GetService("Lighting"),"Technology",Enum.Technology.Legacy) end)
		local lighting2=game:GetService("Lighting")
		lighting2.GlobalShadows=false; lighting2.FogEnd=9e9; lighting2.Brightness=0
		local terrain=workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			pcall(function() sethiddenproperty(terrain,"Decoration",false) end)
			terrain.WaterReflectance=0; terrain.WaterTransparency=0.7; terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0
		end
	end)
	workspace.DescendantAdded:Connect(function(v) if State.fpsBoostEnabled then task.spawn(processObj,v) end end)
end

local function getBat()
	local char=LP.Character; if not char then return nil end
	local tool=char:FindFirstChild("Bat"); if tool then return tool end
	local bp2=LP:FindFirstChild("Backpack")
	if bp2 then tool=bp2:FindFirstChild("Bat"); if tool then tool.Parent=char; return tool end end
	return nil
end
local function tryHitBat()
	if State.hittingCooldown then return end; State.hittingCooldown=true
	pcall(function()
		local bat=getBat(); if bat then
			bat:Activate(); local ev=bat:FindFirstChildWhichIsA("RemoteEvent")
			if ev then ev:FireServer() end
		end
	end)
	task.delay(0.08, function() State.hittingCooldown=false end)
end

local function loadConfig()
	local hasFile=false; pcall(function() hasFile=isfile("MachoHubConfig.json") end)
	if not hasFile then return end
	local ok,cfg=pcall(function() return HttpService:JSONDecode(readfile("MachoHubConfig.json")) end)
	if not ok or not cfg then return end
	if cfg.normalSpeed and type(cfg.normalSpeed)=="number" then State.normalSpeed=cfg.normalSpeed; normalBox.Text=tostring(cfg.normalSpeed) end
	if cfg.carrySpeed  and type(cfg.carrySpeed)=="number"  then State.carrySpeed=cfg.carrySpeed;   carryBox.Text=tostring(cfg.carrySpeed)   end
	if cfg.laggerSpeed and type(cfg.laggerSpeed)=="number" then State.laggerSpeed=cfg.laggerSpeed; laggerBox.Text=tostring(cfg.laggerSpeed) end
	if cfg.laggerCarrySpeed and type(cfg.laggerCarrySpeed)=="number" then State.laggerCarrySpeed=cfg.laggerCarrySpeed; carryLaggerBox.Text=tostring(cfg.laggerCarrySpeed) end
	if cfg.speedType == "normal" or cfg.speedType == "carry" then State.speedType = cfg.speedType end
	if type(cfg.laggerActive) == "boolean" then State.laggerActive = cfg.laggerActive end
	if cfg.autoBatKey  and Enum.KeyCode[cfg.autoBatKey]    then Keys.autoBat=Enum.KeyCode[cfg.autoBatKey]; if autoBatKeyBtn then autoBatKeyBtn.Text=cfg.autoBatKey end end
	if cfg.speedKey    and Enum.KeyCode[cfg.speedKey]      then Keys.speed=Enum.KeyCode[cfg.speedKey] end
	if cfg.laggerKey   and Enum.KeyCode[cfg.laggerKey]     then Keys.lagger=Enum.KeyCode[cfg.laggerKey] end
	if cfg.autoLeftKey  and Enum.KeyCode[cfg.autoLeftKey]  then Keys.autoLeft=Enum.KeyCode[cfg.autoLeftKey];   if autoLeftKeyBtn  then autoLeftKeyBtn.Text=cfg.autoLeftKey   end end
	if cfg.autoRightKey and Enum.KeyCode[cfg.autoRightKey] then Keys.autoRight=Enum.KeyCode[cfg.autoRightKey]; if autoRightKeyBtn then autoRightKeyBtn.Text=cfg.autoRightKey end end
	if cfg.tpDownKey    and Enum.KeyCode[cfg.tpDownKey]    then Keys.tpDown=Enum.KeyCode[cfg.tpDownKey];       if tpDownKeyBtn    then tpDownKeyBtn.Text=cfg.tpDownKey        end end
	if cfg.grabRadius and type(cfg.grabRadius)=="number" then
		AutoSteal.Radius=cfg.grabRadius; radiusBox.Text=tostring(cfg.grabRadius); if progressRadLbl then progressRadLbl.Text="Radius: "..cfg.grabRadius end end
	if cfg.autoStealEnabled then AutoSteal.Enabled=true; setInstaGrab(true); pcall(startAutoSteal) end
	if cfg.infJump     then State.infJumpEnabled=true;       setInfJump(true)  end
	if cfg.antiRagdoll then State.antiRagdollEnabled=true;   setAntiRag(true); startAntiRagdoll() end
	if cfg.fpsBoost    then State.fpsBoostEnabled=true;      setFps(true);     applyFPSBoost()    end
	if cfg.medusaCounter then State.medusaCounterEnabled=true; setMedusaCounter(true); setupMedusaCounter(LP.Character) end
	if cfg.dropBrainrotKey and Enum.KeyCode[cfg.dropBrainrotKey] then
		Keys.dropBrainrot=Enum.KeyCode[cfg.dropBrainrotKey]
		if dropBrainrotKeyBtn then dropBrainrotKeyBtn.Text=cfg.dropBrainrotKey end end
	if cfg.guiHideKey and Enum.KeyCode[cfg.guiHideKey] then
		Keys.guiHide=Enum.KeyCode[cfg.guiHideKey]; if guiHideKeyBtn then guiHideKeyBtn.Text=cfg.guiHideKey end end
	if cfg.animEnabled then
		State.animEnabled = true; setAnimToggle(true)
		task.spawn(function()
			task.wait(0.5)
			if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
			local c = LP.Character
			if c then saveOriginalAnims(c) end
			startAnimToggle()
			if c then applyAnimPack(c) end
		end)
	end
	if cfg.unwalkEnabled then
		setUnwalkToggle(true)
		task.spawn(function()
			task.wait(0.5); State.unwalkEnabled = false; startUnwalk()
		end)
	end
	if cfg.mobileVisible ~= nil then
		MobileButtons.Visible = cfg.mobileVisible
		if MobileButtons.Frame then MobileButtons.Frame.Visible = MobileButtons.Visible end
	end
	if cfg.mobileLocked ~= nil then
		MobileButtons.Locked = cfg.mobileLocked
		if lockMobileSetActive then lockMobileSetActive(cfg.mobileLocked) end
	end
	refreshUIToggles()
end

task.spawn(function()
	task.wait(0.5)
	createMobilePanel()
end)

local function setupChar(char)
	task.wait(0.1)
	originalAnims = nil
	h=char:WaitForChild("Humanoid",5); hrp=char:WaitForChild("HumanoidRootPart",5)
	if not h or not hrp then return end
	local head=char:FindFirstChild("Head")
	if head then
		local oldBB=head:FindFirstChild("SpeedBillboard"); if oldBB then oldBB:Destroy() end
		local bb=Instance.new("BillboardGui",head)
		bb.Name="SpeedBillboard"; bb.Size=UDim2.new(0,140,0,25); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
		speedLbl=Instance.new("TextLabel",bb); speedLbl.Size=UDim2.new(1,0,1,0)
		speedLbl.BackgroundTransparency=1; speedLbl.TextColor3=C_ACCENT2
		speedLbl.Font=Enum.Font.GothamBold; speedLbl.TextScaled=true; speedLbl.TextStrokeTransparency=0
	end
	if State.antiRagdollEnabled and not Conns.antiRag then task.wait(0.5); startAntiRagdoll() end
	if State.medusaCounterEnabled then setupMedusaCounter(char) end
	if State.animEnabled then task.wait(0.3); saveOriginalAnims(char); applyAnimPack(char) end
	if State.unwalkEnabled then
		State.unwalkEnabled = false; task.wait(0.3); startUnwalk()
	end
end

LP.CharacterAdded:Connect(setupChar)
if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

RunService.Stepped:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP and p.Character then
			for _,part in ipairs(p.Character:GetChildren()) do
				if part:IsA("BasePart") then part.CanCollide=false end
			end
		end
	end
end)

UIS.JumpRequest:Connect(function()
	if not State.infJumpEnabled then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	if root then root.Velocity=Vector3.new(root.Velocity.X,55,root.Velocity.Z) end
end)
RunService.Heartbeat:Connect(function()
	if not State.infJumpEnabled then return end
	local char=LP.Character; if not char then return end
	local root=char:FindFirstChild("HumanoidRootPart")
	if root and root.Velocity.Y<-120 then root.Velocity=Vector3.new(root.Velocity.X,-120,root.Velocity.Z) end
end)

RunService.RenderStepped:Connect(function()
	if not (h and hrp) then return end
	if State._tpInProgress then return end
	if State.autoLeftEnabled or State.autoRightEnabled then
		if speedLbl then
			local hs=Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude
			speedLbl.Text="Speed: "..string.format("%.1f",hs)
		end
		return
	end
	local md = h.MoveDirection
	local spd = getCurrentSpeed()
	if md.Magnitude > 0 then
		State.lastMoveDir = md
		hrp.Velocity = Vector3.new(md.X * spd, hrp.Velocity.Y, md.Z * spd)
	elseif State.antiRagdollEnabled and State.lastMoveDir.Magnitude > 0 then
		local anyHeld = false
		for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld = true; break end end
		if anyHeld then
			hrp.Velocity = Vector3.new(State.lastMoveDir.X * spd, hrp.Velocity.Y, State.lastMoveDir.Z * spd)
		end
	end
	if speedLbl then
		local hs = Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude
		speedLbl.Text = "Speed: " .. string.format("%.1f", hs)
	end
end)

local function getClosestPlayer()
	if not hrp then return nil,math.huge end
	local cp,cd=nil,math.huge
	for _,p in pairs(Players:GetPlayers()) do
		if p~=LP and p.Character then
			local tr=p.Character:FindFirstChild("HumanoidRootPart")
			if tr then local d=(hrp.Position-tr.Position).Magnitude; if d<cd then cd=d; cp=p end end
		end
	end
	return cp,cd
end

RunService.Heartbeat:Connect(function()
	if not (State.autoBatToggled and h and hrp) then return end
	local target,dist=getClosestPlayer()
	if target and target.Character then
		local tr=target.Character:FindFirstChild("HumanoidRootPart")
		if tr then
			local fp=tr.Position+tr.CFrame.LookVector*1.5
			local dir=(fp-hrp.Position).Unit
			hrp.Velocity=Vector3.new(dir.X*56.5,dir.Y*56.5,dir.Z*56.5)
			if dist<=5 then tryHitBat() end
		end
	end
end)

UIS.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.UserInputType ~= Enum.UserInputType.Keyboard and inp.UserInputType ~= Enum.UserInputType.Gamepad1 then return end
	local kc = inp.KeyCode
	if (State.autoLeftEnabled or State.autoRightEnabled) then
		if MOVE_KEYS[kc] then return end
	end
	if kc == Keys.speed then
		toggleSpeedType()
	elseif kc == Keys.lagger then
		toggleLagger()
	elseif kc == Keys.autoBat then
		local newVal = not State.autoBatToggled
		if newVal then
			if State.autoLeftEnabled then State.autoLeftEnabled=false; if setAutoLeft then setAutoLeft(false) end; stopAutoLeft(); if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end end
			if State.autoRightEnabled then State.autoRightEnabled=false; if setAutoRight then setAutoRight(false) end; stopAutoRight(); if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end end
		end
		State.autoBatToggled = newVal
		setAutoBat(State.autoBatToggled)
		if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(State.autoBatToggled) end
		autoSaveConfig()
	elseif kc == Keys.autoLeft then
		local newVal = not State.autoLeftEnabled
		if newVal then
			if State.autoBatToggled then State.autoBatToggled=false; setAutoBat(false); if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(false) end end
			if State.autoRightEnabled then State.autoRightEnabled=false; if setAutoRight then setAutoRight(false) end; stopAutoRight(); if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(false) end end
		end
		State.autoLeftEnabled = newVal
		if setAutoLeft then setAutoLeft(State.autoLeftEnabled) end
		if State.autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
		if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(State.autoLeftEnabled) end
		autoSaveConfig()
	elseif kc == Keys.autoRight then
		local newVal = not State.autoRightEnabled
		if newVal then
			if State.autoBatToggled then State.autoBatToggled=false; setAutoBat(false); if MobileButtons.Buttons.autoBat then MobileButtons.Buttons.autoBat(false) end end
			if State.autoLeftEnabled then State.autoLeftEnabled=false; if setAutoLeft then setAutoLeft(false) end; stopAutoLeft(); if MobileButtons.Buttons.autoLeft then MobileButtons.Buttons.autoLeft(false) end end
		end
		State.autoRightEnabled = newVal
		if setAutoRight then setAutoRight(State.autoRightEnabled) end
		if State.autoRightEnabled then startAutoRight() else stopAutoRight() end
		if MobileButtons.Buttons.autoRight then MobileButtons.Buttons.autoRight(State.autoRightEnabled) end
		autoSaveConfig()
	elseif kc == Keys.dropBrainrot then
		task.spawn(runDropBrainrot)
	elseif kc == Keys.tpDown then
		tpToGround()
	elseif kc == Keys.guiHide then
		toggleGuiVis()
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			if progressRadLbl then
				progressRadLbl.Text = "Radius: "..AutoSteal.Radius
			end
		end)
	end
end)

loadMainPosition()
loadMiniPosition()
refreshUIToggles()
loadConfig()
