repeat task.wait() until game:IsLoaded()  
  
local Players,RunService,UIS,TS,Lighting,HS = game:GetService("Players"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("TweenService"),game:GetService("Lighting"),game:GetService("HttpService")  
local LP = Players.LocalPlayer  

-- â”€â”€ Anti Kick Logic (message 27) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local ANTIKICK_BOXES = {
	left  = { position = Vector3.new(-474.108, 0.025, 113.668), size = Vector3.new(47.757, 17.695, 14.49) },
	right = { position = Vector3.new(-474.108, 0.341,   6.668), size = Vector3.new(47.757, 17.195, 14.49) },
}
local antiKickEnabled    = false
local antiKickSide       = "left"
local antiKickDuration   = 2.15
local antiKickRemaining  = 0
local antiKickRunning    = false
local antiKickBarriers   = {}
local antiKickAttrConn   = nil
local antiKickHBConn     = nil

local function akSpawnBarrier(side)
	for _, p in pairs(antiKickBarriers) do pcall(function() p:Destroy() end) end
	antiKickBarriers = {}
	local box = ANTIKICK_BOXES[side]
	local thickness = 2
	local walls = {
		{ size = Vector3.new(box.size.Z, box.size.Y, thickness), pos = Vector3.new(box.position.X, box.position.Y, box.position.Z - box.size.X/2 - thickness/2) },
		{ size = Vector3.new(box.size.Z, box.size.Y, thickness), pos = Vector3.new(box.position.X, box.position.Y, box.position.Z + box.size.X/2 + thickness/2) },
		{ size = Vector3.new(thickness, box.size.Y, box.size.X), pos = Vector3.new(box.position.X + box.size.Z/2 + thickness/2, box.position.Y, box.position.Z) },
		{ size = Vector3.new(thickness, box.size.Y, box.size.X), pos = Vector3.new(box.position.X - box.size.Z/2 - thickness/2, box.position.Y, box.position.Z) },
	}
	for _, w in pairs(walls) do
		local part = Instance.new("Part")
		part.Size = w.size; part.CFrame = CFrame.new(w.pos)
		part.Anchored = true; part.CanCollide = true; part.Transparency = 1
		part.Name = "AKBarrier"; part.Parent = workspace
		table.insert(antiKickBarriers, part)
	end
end

local function akRemoveBarrier()
	for _, p in pairs(antiKickBarriers) do pcall(function() p:Destroy() end) end
	antiKickBarriers = {}
end

local function startAntiKick()
	if antiKickAttrConn then antiKickAttrConn:Disconnect() end
	if antiKickHBConn   then antiKickHBConn:Disconnect() end
	antiKickAttrConn = LP.AttributeChanged:Connect(function(attr)
		if attr ~= "Stealing" then return end
		local val = LP:GetAttribute("Stealing")
		if val and val ~= false and val ~= 0 then
			if not antiKickRunning then
				antiKickRemaining = antiKickDuration
				antiKickRunning   = true
				akSpawnBarrier(antiKickSide)
			end
		else
			antiKickRunning   = false
			antiKickRemaining = 0
			akRemoveBarrier()
		end
	end)
	antiKickHBConn = RunService.Heartbeat:Connect(function(dt)
		if antiKickRunning then
			antiKickRemaining = math.max(0, antiKickRemaining - dt)
			if antiKickRemaining <= 0 then
				antiKickRunning = false
				akRemoveBarrier()
			end
		end
	end)
end

local function stopAntiKick()
	if antiKickAttrConn then antiKickAttrConn:Disconnect(); antiKickAttrConn = nil end
	if antiKickHBConn   then antiKickHBConn:Disconnect();   antiKickHBConn   = nil end
	antiKickRunning = false; antiKickRemaining = 0
	akRemoveBarrier()
end
-- â”€â”€ End Anti Kick Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

;(function()
  
local DAS,DAD = 150,0.2
-- Speed mode system: "normal" | "lagger" | "desync"
local activeSpeedMode = "normal"  -- current mode
local carryActive = false          -- whether carry is on within the current mode

-- Normal mode speeds
local NS  = 59   -- normal speed
local CS  = 29   -- carry speed

-- Lagger mode speeds
local LS  = 34   -- lagger normal speed
local LS2 = 17   -- lagger carry speed

-- Desync mode speeds

-- Legacy aliases kept so existing references still work
local speedMode   = false
local laggerMode  = false
local laggerPhase = 1
  
local antiRagdollEnabled,infJumpEnabled = false,false  
local medusaCounterEnabled = false  
local ragdollTimerEnabled = false
local medusaMode = false  
local unwalkEnabled = false  
local unwalkAnimations = {}  
local lastHealth,medusaDebounce,medusaLastUsed,dropActive = 100,false,0,false  
local autoTPEnabled = false
local autoTPHeight  = 20
local autoTPConn    = nil
local setAutoTPVisual = nil
local _setAutoTPHeightBox = nil  -- set by UI to allow loadConfig to update height box
local stretchRezEnabled = false  
local removeAccessoriesEnabled = false  
local removeAccessoriesConn = nil  
local nightModeEnabled = false  
local defLightBrightness = Lighting.Brightness  
local defClockTime = Lighting.ClockTime  
local defOutdoorAmbient = Lighting.OutdoorAmbient  
local defExposureComp = Lighting.ExposureCompensation  
local uiLocked = false  -- Lock UI: disables dragging of main menu and all panels
local setLockUIVisual = nil  -- set by buildGui so loadConfig can update the toggle visual
local autoLeftEnabled,autoRightEnabled = false,false  
local autoLeftSetVisual,autoRightSetVisual = nil,nil  
local speedLabel = nil  
local _guiSpeedLbl = nil  
local _guiSpeedSubLbl = nil  
local medusaConns = {}  
local autoBatEnabled = false  
local autoBatSpeed = 58  -- chase speed used by bat aimbot  
local autoBatSetVisual = nil  
-- â”€â”€ Body Lock â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local bodyLockEnabled   = false
local bodyLockRange     = 40      -- only face if target is within this distance
local _bodyLockConn     = nil
local bodyLockSetVisual = nil

local _anyKeyListening = false  
  
local KB = {  
	DropBrainrot={kb=Enum.KeyCode.X,gp=nil},  
	TPFloor     ={kb=Enum.KeyCode.F,gp=nil},  
	AutoLeft    ={kb=Enum.KeyCode.Z,gp=nil},  
	AutoRight   ={kb=Enum.KeyCode.C,gp=nil},  
	AutoBat     ={kb=Enum.KeyCode.E,gp=nil},  
	GuiHide     ={kb=Enum.KeyCode.LeftControl,gp=nil},  
	SpeedToggle  ={kb=Enum.KeyCode.Q,gp=nil},  -- carry toggle (same key works in all modes)
	ModeToggle   ={kb=Enum.KeyCode.N,gp=nil},  -- toggle Normal <-> Lagger mode
	STARReset ={kb=Enum.KeyCode.R,gp=nil},  -- insta reset
}  
  
local progressRadLbl, progressFill, progressPct
local modeValLbl

local Steal = {
	AutoStealEnabled=false, StealRadius=20, StealDuration=1.3,
	-- Separate grab radii for Normal mode and Lagger mode. StealRadius above
	-- is the ACTIVE radius (kept in sync with whichever mode is currently on).
	StealRadiusNormal=20, StealRadiusLagger=20,
	Data={}, plotCache={}, plotCacheTime={}, cachedPrompts={}, promptCacheTime=0,
}

-- Keep Steal.StealRadius in sync with the active speed mode's radius.
-- Call this whenever activeSpeedMode changes or a radius value is edited.
local function syncStealRadius()
	if activeSpeedMode == "lagger" then
		Steal.StealRadius = Steal.StealRadiusLagger
	else
		Steal.StealRadius = Steal.StealRadiusNormal
	end
	Steal.cachedPrompts = {}; Steal.promptCacheTime = 0
	if progressRadLbl then progressRadLbl.Text = "Radius: "..Steal.StealRadius end
end

-- â”€â”€ Auto Steal Logic (message 29) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local Conns = {autoSteal=nil, antiRag=nil, anchor={}, progress=nil}
local MEDUSA_COOLDOWN = 25

-- â”€â”€ STAR Reset Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local resetRemote = nil
local RESET_GUID  = "f888ee6e-c86d-46e1-93d7-0639d6635d42"

local o_hook; o_hook = hookfunction(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
	if not resetRemote and self.Name:sub(1,3) == "RE/" then
		resetRemote = self
	end
	return o_hook(self, ...)
end))

task.spawn(function()
	task.wait(2)
	if not resetRemote then
		for _, d in pairs(game:GetDescendants()) do
			if d:IsA("RemoteEvent") and d.Name:sub(1,3) == "RE/" then
				resetRemote = d; break
			end
		end
	end
end)

local function instaReset()
	if not resetRemote then return end
	local character = LP.Character
	if not character then
		pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
		return
	end
	if humanoid.Health <= 0 then
		pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
		return
	end
	local resetDetected = false
	local conns = {}
	table.insert(conns, humanoid.Died:Connect(function() resetDetected = true end))
	table.insert(conns, character.AncestryChanged:Connect(function(_, parent)
		if not parent then resetDetected = true end
	end))
	table.insert(conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health <= 0 then resetDetected = true end
	end))
	task.spawn(function()
		local attempts = 0
		while not resetDetected and attempts < 50 do
			attempts = attempts + 1
			pcall(function() resetRemote:FireServer(RESET_GUID, LP, "balloon") end)
			task.wait()
		end
		for _, c in pairs(conns) do c:Disconnect() end
	end)
end
-- â”€â”€ End STAR Reset Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local CONFIG = {
	HOLD_MIN    = 1.3,
	HOLD_MAX    = 2.6,
	ENTRY_DELAY = 0.3,
	COOLDOWN    = 0.05,
	STEAL_RANGE = 8,
	PRIME_RANGE = 70,
}

local S_RS = game:GetService("ReplicatedStorage")
local Packages   = S_RS:WaitForChild("Packages")
local Datas      = S_RS:WaitForChild("Datas")
local AnimalsData = require(Datas:WaitForChild("Animals"))
local plots = workspace:WaitForChild("Plots")

local syncRemotes = (function()
	local folder = Packages:WaitForChild("Synchronizer")
	return {
		channelFolder = folder:WaitForChild("Channel"),
		routeRemote   = folder:WaitForChild("CommunicationRoute"),
		requestData   = folder:FindFirstChild("RequestData"),
	}
end)()

local plotAnimalSync = { caches = {}, connections = {} }

local function splitSyncPath(path)
	if typeof(path) == "table" then return path end
	local out = {}
	for part in string.gmatch(tostring(path), "[^%.]+") do
		table.insert(out, tonumber(part) or part)
	end
	return out
end

local function resolveSyncPath(path, root)
	local current = root
	local parent = nil
	local key = nil
	for _, part in ipairs(splitSyncPath(path)) do
		parent = current
		key = part
		current = current and current[part] or nil
	end
	return current, parent, key
end

local function applyPlotSyncDiff(channelName, packet)
	local cache = plotAnimalSync.caches[channelName]
	if typeof(cache) ~= "table" then return end
	local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
	local current, parent, key = resolveSyncPath(path, cache)
	if action == "Changed" then
		if parent ~= nil then parent[key] = a end
	elseif action == "ArrayInsert" then
		if current ~= nil then table.insert(current, b, a) end
	elseif action == "ArrayRemoved" then
		if current ~= nil then table.remove(current, b) end
	elseif action == "DictionaryInsert" then
		if current ~= nil then current[b] = a end
	elseif action == "DictionaryRemoved" then
		if current ~= nil then current[b] = nil end
	end
end

local function attachPlotChannel(remote)
	if plotAnimalSync.connections[remote] then return end
	local channelName = tostring(remote.Name)
	if not plots:FindFirstChild(channelName) then return end
	if syncRemotes.requestData and plotAnimalSync.caches[channelName] == nil then
		local ok, data = pcall(function()
			return syncRemotes.requestData:InvokeServer(channelName)
		end)
		if ok and typeof(data) == "table" then
			plotAnimalSync.caches[channelName] = data
		else
			plotAnimalSync.caches[channelName] = {}
		end
	elseif plotAnimalSync.caches[channelName] == nil then
		plotAnimalSync.caches[channelName] = {}
	end
	plotAnimalSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
		for _, packet in ipairs(queue) do
			applyPlotSyncDiff(channelName, packet)
		end
	end)
end

local function detachPlotChannel(channelName)
	for remote, conn in pairs(plotAnimalSync.connections) do
		if tostring(remote.Name) == tostring(channelName) then
			conn:Disconnect()
			plotAnimalSync.connections[remote] = nil
			plotAnimalSync.caches[tostring(channelName)] = nil
			break
		end
	end
end

task.spawn(function()
	for _, child in ipairs(syncRemotes.channelFolder:GetChildren()) do
		if child:IsA("RemoteEvent") then attachPlotChannel(child) end
	end
	syncRemotes.channelFolder.ChildAdded:Connect(function(child)
		if child:IsA("RemoteEvent") then attachPlotChannel(child) end
	end)
	syncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
		for _, action in ipairs(actions) do
			local kind, channelName = action[1], tostring(action[2])
			if not plots:FindFirstChild(channelName) then continue end
			if kind == "ListenerAdded" then
				local remote = syncRemotes.channelFolder:FindFirstChild(channelName)
				if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote) end
			elseif kind == "ListenerRemoved" then
				detachPlotChannel(channelName)
			end
		end
	end)
end)

local function getPlotChannelData(plotName)
	return plotAnimalSync.caches[plotName]
end

local allAnimalsCache = {}
local PromptMemoryCache = {}
local InternalStealCache = {}
local stealConnection = nil

local StealState = { active = false, statusText = "READY", startTime = 0 }

local function getPlotOwner(plot)
	local sign = plot:FindFirstChild("PlotSign")
	local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
	local label = frame and frame:FindFirstChild("TextLabel")
	if not label or label.Text == "Empty Base" then return nil end
	return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
end

local function isMyBaseAnimal(animalData)
	if not animalData or not animalData.plot then return false end
	local plot = plots:FindFirstChild(animalData.plot)
	if not plot then return false end
	return getPlotOwner(plot) == LP.DisplayName
end

local function findProximityPromptForAnimal(animalData)
	if not animalData then return nil end
	local cached = PromptMemoryCache[animalData.uid]
	if cached and cached.Parent then return cached end
	local plot = workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
	local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
	local podium = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
	local base = podium:FindFirstChild("Base"); if not base then return nil end
	local spawn = base:FindFirstChild("Spawn"); if not spawn then return nil end
	local attach = spawn:FindFirstChild("PromptAttachment"); if not attach then return nil end
	for _, p in ipairs(attach:GetChildren()) do
		if p:IsA("ProximityPrompt") then
			PromptMemoryCache[animalData.uid] = p
			return p
		end
	end
	return nil
end

local function getAnimalPosition(animalData)
	local plot = workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
	local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
	local podium = podiums:FindFirstChild(animalData.slot); if not podium then return nil end
	return podium:GetPivot().Position
end

local function distToAnimal(animalData)
	local character = LP.Character; if not character then return math.huge end
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
	if not hrp then return math.huge end
	local pos = getAnimalPosition(animalData)
	if not pos then return math.huge end
	return (hrp.Position - pos).Magnitude
end

local function pickClosest()
	local character = LP.Character; if not character then return nil end
	local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
	if not hrp then return nil end
	local best, bestDist = nil, math.huge
	for _, animalData in ipairs(allAnimalsCache) do
		if isMyBaseAnimal(animalData) then continue end
		local pos = getAnimalPosition(animalData)
		if not pos then continue end
		local dist = (hrp.Position - pos).Magnitude
		if dist > CONFIG.PRIME_RANGE then continue end
		if dist < bestDist then bestDist = dist; best = animalData end
	end
	return best
end

local function buildStealCallbacks(prompt)
	if InternalStealCache[prompt] then return end
	local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
	local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
	if ok1 and type(conns1) == "table" then
		for _, conn in ipairs(conns1) do
			if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
		end
	end
	local ok2, conns2 = pcall(getconnections, prompt.Triggered)
	if ok2 and type(conns2) == "table" then
		for _, conn in ipairs(conns2) do
			if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
		end
	end
	if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) then
		InternalStealCache[prompt] = data
	end
end

local function executeStealAsync(prompt, animalData)
	local data = InternalStealCache[prompt]
	if not data or not data.ready then return false end
	data.ready = false
	StealState.active = true
	StealState.startTime = tick()
	task.spawn(function()
		for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end
		task.wait(CONFIG.HOLD_MIN)
		local alreadyInRange = distToAnimal(animalData) <= CONFIG.STEAL_RANGE
		local fired = false
		while true do
			local elapsed = tick() - StealState.startTime
			if elapsed > CONFIG.HOLD_MAX then break end
			if not prompt.Parent then break end
			if distToAnimal(animalData) <= CONFIG.STEAL_RANGE then
				if not alreadyInRange then task.wait(CONFIG.ENTRY_DELAY) end
				for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
				fired = true
				break
			end
			task.wait()
		end
		StealState.active = false
		task.wait(CONFIG.COOLDOWN)
		data.ready = true
	end)
	return true
end

local function attemptSteal(prompt, animalData)
	if not prompt or not prompt.Parent then return false end
	buildStealCallbacks(prompt)
	if not InternalStealCache[prompt] then return false end
	return executeStealAsync(prompt, animalData)
end

local function scanAllPlots()
	local newCache = {}
	for _, plot in ipairs(plots:GetChildren()) do
		local cache = getPlotChannelData(plot.Name)
		if not cache then continue end
		local animalList = cache.AnimalList
		if typeof(animalList) ~= "table" then continue end
		for slot, animalData in pairs(animalList) do
			if type(animalData) == "table" then
				local animalName = animalData.Index
				local animalInfo = AnimalsData[animalName]
				if not animalInfo then continue end
				table.insert(newCache, {
					name = animalInfo.DisplayName or animalName,
					plot = plot.Name,
					slot = tostring(slot),
					uid  = plot.Name .. "_" .. tostring(slot),
				})
			end
		end
	end
	allAnimalsCache = newCache
	return #allAnimalsCache
end

local function startAutoSteal()
	if stealConnection then return end
	stealConnection = RunService.Heartbeat:Connect(function()
		if not Steal.AutoStealEnabled then return end
		if StealState.active then return end
		local target = pickClosest()
		if not target then return end
		local prompt = PromptMemoryCache[target.uid]
		if not prompt or not prompt.Parent then
			prompt = findProximityPromptForAnimal(target)
		end
		if prompt then attemptSteal(prompt, target) end
	end)
end

local function stopAutoSteal()
	if stealConnection then stealConnection:Disconnect(); stealConnection = nil end
	StealState.active = false; StealState.startTime = 0
	Steal.plotCache = {}; Steal.plotCacheTime = {}; Steal.cachedPrompts = {}
	allAnimalsCache = {}; PromptMemoryCache = {}; InternalStealCache = {}
end

local function updateUI()
	while not progressFill or not progressPct do task.wait(0.5) end
	while true do
		local character = LP.Character
		local inPrimeRange = false
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("UpperTorso")
			if hrp then
				local closest = pickClosest()
				if closest then
					local dist = distToAnimal(closest)
					inPrimeRange = dist <= CONFIG.PRIME_RANGE
				end
			end
		end
		if StealState.active and StealState.startTime > 0 then
			local elapsed = tick() - StealState.startTime
			local percent = math.clamp(elapsed / CONFIG.HOLD_MAX, 0, 1)
			progressFill.Size = UDim2.new(percent, 0, 1, 0)
			if elapsed >= CONFIG.HOLD_MIN then
				progressPct.Text = "READY"
			else
				progressPct.Text = "NOT READY"
			end
		elseif not inPrimeRange then
			progressFill.Size = UDim2.new(0, 0, 1, 0)
			progressPct.Text = "NOT READY"
		else
			progressFill.Size = UDim2.new(0, 0, 1, 0)
			progressPct.Text = "READY"
		end
		task.wait()
	end
end

task.spawn(updateUI)
task.spawn(function()
	while task.wait(5) do scanAllPlots() end
end)
scanAllPlots()
-- â”€â”€ End Auto Steal Logic (message 29) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  
local _collideTick = 0  
RunService.Stepped:Connect(function()  
	local now = tick()  
	if now - _collideTick < 0.5 then return end  
	_collideTick = now  
	for _,p in ipairs(Players:GetPlayers()) do  
		if p~=LP and p.Character then  
			for _,part in ipairs(p.Character:GetDescendants()) do  
				if part:IsA("BasePart") then part.CanCollide=false end  
			end  
		end  
	end  
end)  
  
-- â”€â”€â”€ K7 Envy Speed Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  
local _lastMoveDir = Vector3.new(0,0,0)  
local _tpInProgress = false  
local MOVE_KEYS = {  
	[Enum.KeyCode.W]=true,[Enum.KeyCode.A]=true,[Enum.KeyCode.S]=true,[Enum.KeyCode.D]=true,  
	[Enum.KeyCode.Up]=true,[Enum.KeyCode.Left]=true,[Enum.KeyCode.Down]=true,[Enum.KeyCode.Right]=true,  
}  
RunService.RenderStepped:Connect(function()  
	local char=LP.Character; if not char then return end  
	local hum=char:FindFirstChildOfClass("Humanoid")  
	local hrp=char:FindFirstChild("HumanoidRootPart")  
	if not hum or not hrp then return end  
	if _tpInProgress then return end  
	if not autoBatEnabled and not autoLeftEnabled and not autoRightEnabled then  
		local md = hum.MoveDirection
		local spd = (activeSpeedMode == "lagger") and (carryActive and LS2 or LS) or (carryActive and CS or NS)
		if md.Magnitude > 0 then  
			_lastMoveDir = md  
			hrp.Velocity = Vector3.new(md.X*spd, hrp.Velocity.Y, md.Z*spd)  
		elseif antiRagdollEnabled and _lastMoveDir.Magnitude > 0 then  
			local anyHeld = false  
			for key in pairs(MOVE_KEYS) do if UIS:IsKeyDown(key) then anyHeld=true; break end end  
			if anyHeld then hrp.Velocity = Vector3.new(_lastMoveDir.X*spd, hrp.Velocity.Y, _lastMoveDir.Z*spd) end  
		end  
	end  
	pcall(function()  
		if speedLabel then  
			local hspd = Vector3.new(hrp.Velocity.X,0,hrp.Velocity.Z).Magnitude  
			speedLabel.Text = string.format("%.1f",hspd)  
			if _guiSpeedLbl then  
				_guiSpeedLbl.Text = string.format("%.1f",hspd)  
				if _guiSpeedSubLbl then  
					local _modeStr = activeSpeedMode:sub(1,1):upper()..activeSpeedMode:sub(2)
					_guiSpeedSubLbl.Text = "studs/s  آ·  "..(_modeStr)..(carryActive and " Carry" or "")  
				end  
			end  
		end  
	end)  
end)  
-- â”€â”€â”€ End K7 Envy Speed Logic â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  
  
local alConn,arConn = nil,nil  
local alPhase,arPhase = 1,1  
  
local AP_L1     = Vector3.new(-476.48, -6.28,  92.73)  
local AP_L2     = Vector3.new(-483.12, -4.95,  94.80)  
local AP_L_FACE = Vector3.new(-482.25, -4.96,  92.09)  
local AP_R1     = Vector3.new(-476.16, -6.52,  25.62)  
local AP_R2     = Vector3.new(-483.06, -5.03,  25.48)  
local AP_R_FACE = Vector3.new(-482.06, -6.93,  35.47)  
  
local function stopAutoLeft()  
	if alConn then alConn:Disconnect();alConn=nil end;alPhase=1  
	local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end  
end  
  
local function stopAutoRight()  
	if arConn then arConn:Disconnect();arConn=nil end;arPhase=1  
	local char=LP.Character;if char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:Move(Vector3.zero,false) end end  
end  
  
local function startAutoLeft()  
	if alConn then alConn:Disconnect() end;alPhase=1  
	alConn=RunService.Heartbeat:Connect(function()  
		if not autoLeftEnabled then return end  
		local char=LP.Character;if not char then return end  
		local hrp2=char:FindFirstChild("HumanoidRootPart")  
		local hum=char:FindFirstChildOfClass("Humanoid")  
		if not hrp2 or not hum then return end  
		local spd=(activeSpeedMode=="lagger") and LS or NS  
		if alPhase==1 then  
			local tgt=Vector3.new(AP_L1.X,hrp2.Position.Y,AP_L1.Z)  
			if (tgt-hrp2.Position).Magnitude<1 then  
				alPhase=2  
				local d=AP_L2-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
				hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd);return  
			end  
			local d=AP_L1-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
			hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd)  
		elseif alPhase==2 then  
			local tgt=Vector3.new(AP_L2.X,hrp2.Position.Y,AP_L2.Z)  
			if (tgt-hrp2.Position).Magnitude<1 then  
				hum:Move(Vector3.zero,false);hrp2.AssemblyLinearVelocity=Vector3.zero  
				autoLeftEnabled=false;if alConn then alConn:Disconnect();alConn=nil end  
				alPhase=1;if autoLeftSetVisual then autoLeftSetVisual(false) end  
				if (AP_L_FACE-hrp2.Position).Magnitude>0.01 then  
					hrp2.CFrame=CFrame.new(hrp2.Position,Vector3.new(AP_L_FACE.X,hrp2.Position.Y,AP_L_FACE.Z))  
				end  
				return  
			end  
			local d=AP_L2-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
			hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd)  
		end  
	end)  
end  
  
function startAutoRight()  
	if arConn then arConn:Disconnect() end;arPhase=1  
	arConn=RunService.Heartbeat:Connect(function()  
		if not autoRightEnabled then return end  
		local char=LP.Character;if not char then return end  
		local hrp2=char:FindFirstChild("HumanoidRootPart")  
		local hum=char:FindFirstChildOfClass("Humanoid")  
		if not hrp2 or not hum then return end  
		local spd=(activeSpeedMode=="lagger") and LS or NS  
		if arPhase==1 then  
			local tgt=Vector3.new(AP_R1.X,hrp2.Position.Y,AP_R1.Z)  
			if (tgt-hrp2.Position).Magnitude<1 then  
				arPhase=2  
				local d=AP_R2-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
				hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd);return  
			end  
			local d=AP_R1-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
			hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd)  
		elseif arPhase==2 then  
			local tgt=Vector3.new(AP_R2.X,hrp2.Position.Y,AP_R2.Z)  
			if (tgt-hrp2.Position).Magnitude<1 then  
				hum:Move(Vector3.zero,false);hrp2.AssemblyLinearVelocity=Vector3.zero  
				autoRightEnabled=false;if arConn then arConn:Disconnect();arConn=nil end  
				arPhase=1;if autoRightSetVisual then autoRightSetVisual(false) end  
				if (AP_R_FACE-hrp2.Position).Magnitude>0.01 then  
					hrp2.CFrame=CFrame.new(hrp2.Position,Vector3.new(AP_R_FACE.X,hrp2.Position.Y,AP_R_FACE.Z))  
				end  
				return  
			end  
			local d=AP_R2-hrp2.Position;local mv=Vector3.new(d.X,0,d.Z).Unit  
			hum:Move(mv,false);hrp2.AssemblyLinearVelocity=Vector3.new(mv.X*spd,hrp2.AssemblyLinearVelocity.Y,mv.Z*spd)  
		end  
	end)  
end  
  
-- K7-style speed billboard: shows raw speed number, color reflects current mode  
local function setupSpeedIndicator(char)  
	local head = char:WaitForChild("Head",5);if not head then return end  
	-- remove old billboard if respawning  
	local old=head:FindFirstChild("STARSpeedBB");if old then old:Destroy() end  
	local oldBB=head:FindFirstChild("STARSpeedBB"); if oldBB then oldBB:Destroy() end  
	local bb=Instance.new("BillboardGui",head); bb.Name="STARSpeedBB"  
	bb.Size=UDim2.new(0,180,0,62); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true  
	speedLabel=Instance.new("TextLabel",bb); speedLabel.Name="SpeedBillLbl"  
	speedLabel.Size=UDim2.new(1,0,0,24); speedLabel.Position=UDim2.new(0,0,0,0); speedLabel.BackgroundTransparency=1  
	speedLabel.Text="0.0"; speedLabel.TextColor3=Color3.fromRGB(255,182,215)  
	speedLabel.Font=Enum.Font.GothamBlack; speedLabel.TextScaled=true  
	speedLabel.TextStrokeTransparency=0; speedLabel.TextStrokeColor3=Color3.new(0,0,0)  
	local discordLbl=Instance.new("TextLabel",bb)  
	discordLbl.Size=UDim2.new(1,0,0,36); discordLbl.Position=UDim2.new(0,0,0,26)  
	discordLbl.BackgroundTransparency=1; discordLbl.Text="discord.gg/STARhubb"  
	discordLbl.TextColor3=Color3.fromRGB(255,182,215); discordLbl.Font=Enum.Font.GothamBold  
	discordLbl.TextScaled=true; discordLbl.TextStrokeTransparency=0.1  
	discordLbl.TextStrokeColor3=Color3.new(0,0,0)  
end  
  
-- Bat-hit detection connections (used by bat counter)  
local _batHitDetectConns = {}  
local _lastHealth = 100  
local _healthDropTime = 0  
local BAT_HIT_HEALTH_WINDOW = 0.35  -- seconds: if health drops then ragdoll fires within this window, it's a bat hit  
  
local function startAntiRagdoll()  
	if Conns.antiRag then return end  
	local _wasRagdolled = false  
	Conns.antiRag = RunService.Heartbeat:Connect(function()  
		local char = LP.Character;if not char then return end  
		local hum = char:FindFirstChildOfClass("Humanoid");local root=char:FindFirstChild("HumanoidRootPart")  
		if hum then  
			local st = hum:GetState()  
			local isRag = st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown  
			if isRag then  
				if not _wasRagdolled then _wasRagdolled = true end  
				hum:ChangeState(Enum.HumanoidStateType.Running)  
				workspace.CurrentCamera.CameraSubject=hum  
				pcall(function() local pm=LP.PlayerScripts:FindFirstChild("PlayerModule");if pm then require(pm:FindFirstChild("ControlModule")):Enable() end end)  
				if root then root.Velocity=Vector3.zero;root.RotVelocity=Vector3.zero end  
			else  
				if _wasRagdolled then _wasRagdolled = false end  
			end  
		end  
		for _,obj in ipairs(char:GetDescendants()) do if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end end  
	end)  
end  
  
local function stopAntiRagdoll()  
	if Conns.antiRag then Conns.antiRag:Disconnect();Conns.antiRag=nil end  
end  
  
-- â”€â”€ Infinite Jump (GreenDuels) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local _ijHoldPressed = false
local _ijHoldActive  = false
local _ijJumpConn    = nil
local _ijInputConn   = nil
local _ijInputEndConn = nil
local _ijHeartbeatConn = nil

local function applyInfJumpBoost()
	if not infJumpEnabled then return end
	local char = LP.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	root.Velocity = Vector3.new(root.Velocity.X, 50, root.Velocity.Z)
end

local function startInfiniteJump()
	if _ijJumpConn then return end
	-- JumpRequest: fires on mobile tap, controller A, and PC space press
	_ijJumpConn = UIS.JumpRequest:Connect(function()
		applyInfJumpBoost()
	end)
	-- Space hold detection (PC / keyboard)
	_ijInputConn = UIS.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.Space
		and not UIS:GetFocusedTextBox() then
			_ijHoldPressed = true
			task.delay(0.12, function()
				if _ijHoldPressed then
					_ijHoldActive = true
					applyInfJumpBoost()
				end
			end)
		end
	end)
	_ijInputEndConn = UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.Space then
			_ijHoldPressed = false
			_ijHoldActive  = false
		end
	end)
	-- Heartbeat: continuously boost while space is held
	_ijHeartbeatConn = RunService.Heartbeat:Connect(function()
		if _ijHoldActive then applyInfJumpBoost() end
	end)
end

local function stopInfiniteJump()
	_ijHoldPressed = false
	_ijHoldActive  = false
	if _ijJumpConn       then _ijJumpConn:Disconnect();       _ijJumpConn = nil       end
	if _ijInputConn      then _ijInputConn:Disconnect();      _ijInputConn = nil      end
	if _ijInputEndConn   then _ijInputEndConn:Disconnect();   _ijInputEndConn = nil   end
	if _ijHeartbeatConn  then _ijHeartbeatConn:Disconnect();  _ijHeartbeatConn = nil  end
end



  
local function disableAnimations()
	local char = LP.Character; if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("Humanoid") then
			pcall(function() obj.WalkSpeed = 0 end)
		end
		if obj:IsA("AnimationController") or obj:IsA("Animator") then
			for _, t in ipairs(obj:GetPlayingAnimationTracks()) do
				pcall(function() t:Stop(0) end)
			end
		end
	end
end

local function enableAnimations()
	local char = LP.Character; if not char then return end
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("Humanoid") then
			pcall(function()
				local anim = obj:FindFirstChildOfClass("Animator")
				if anim then anim:LoadAnimation(Instance.new("Animation")):Play() end
			end)
		end
	end
	unwalkAnimations = {}
end

RunService.Heartbeat:Connect(function()  
	if not unwalkEnabled then return end  
	disableAnimations()  
end)  
  
  
local DROP_ASCEND_DURATION = 0.22
local DROP_ASCEND_SPEED    = 160
local _dropConn            = nil
local _dropActive          = false

local function runDrop()
	if _dropActive then return end
	local char = LP.Character; if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
	_dropActive = true
	local t0 = tick()
	if _dropConn then _dropConn:Disconnect() end
	_dropConn = RunService.Heartbeat:Connect(function()
		local c = LP.Character
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if not r then
			if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
			_dropActive = false
			return
		end
		if not _dropActive then
			if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
			return
		end
		if tick() - t0 >= DROP_ASCEND_DURATION then
			if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
			pcall(function()
				local rp = RaycastParams.new()
				rp.FilterDescendantsInstances = {c}
				rp.FilterType = Enum.RaycastFilterType.Exclude
				local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
				if rr then
					local hum = c:FindFirstChildOfClass("Humanoid")
					local off = ((hum and hum.HipHeight) or 2) + (r.Size.Y / 2)
					r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
					r.AssemblyLinearVelocity = Vector3.zero
				end
			end)
			_dropActive = false
			return
		end
		local lv = r.AssemblyLinearVelocity
		r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
	end)
end

LP.CharacterRemoving:Connect(function()
	_dropActive = false
	if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
end)

function runTPDown()  
	local char=LP.Character; if not char then return end  
	local root=char:FindFirstChild("HumanoidRootPart")  
	local hum=char:FindFirstChildOfClass("Humanoid")  
	if not root or not hum then return end  
	local rp=RaycastParams.new()  
	rp.FilterDescendantsInstances={char}  
	rp.FilterType=Enum.RaycastFilterType.Exclude  
	local result=workspace:Raycast(root.Position,Vector3.new(0,-1000,0),rp)  
	if result then  
		local hipOffset=hum.HipHeight+(root.Size.Y/2)  
		root.CFrame=CFrame.new(result.Position+Vector3.new(0,hipOffset,0))*root.CFrame.Rotation  
	end  
end  
  
  
  

-- â”€â”€ Message 22 Auto TP Down â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
local function doAutoTPDown(force)
	local char=LP.Character; if not char then return end
	local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	local hum2=char:FindFirstChildOfClass("Humanoid"); if not hum2 then return end
	if not force then
		if hum2.FloorMaterial~=Enum.Material.Air then return end
		if hrp.Position.Y<autoTPHeight then return end
	end
	hrp.CFrame=CFrame.new(hrp.Position.X,-7.00,hrp.Position.Z)
		*CFrame.Angles(0,select(2,hrp.CFrame:ToEulerAnglesYXZ()),0)
	hrp.AssemblyLinearVelocity=Vector3.zero
end
local function startAutoTP()
	if autoTPConn then task.cancel(autoTPConn); autoTPConn=nil end
	autoTPConn=task.spawn(function()
		while autoTPEnabled do
			task.wait(0.1)
			pcall(function() doAutoTPDown(false) end)
		end
	end)
end
local function stopAutoTP()
	autoTPEnabled=false
	if autoTPConn then task.cancel(autoTPConn); autoTPConn=nil end
end
-- â”€â”€ End Message 22 Auto TP Down â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

local stretchRezConn = nil  
local function enableStretchRez()  
	stretchRezEnabled=true  
	workspace.CurrentCamera.FieldOfView=120  
	if stretchRezConn then stretchRezConn:Disconnect() end  
	stretchRezConn=RunService.RenderStepped:Connect(function()  
		if not stretchRezEnabled then stretchRezConn:Disconnect();stretchRezConn=nil;return end  
		workspace.CurrentCamera.FieldOfView=120  
	end)  
end  
  
local function disableStretchRez()  
	stretchRezEnabled=false  
	if stretchRezConn then stretchRezConn:Disconnect();stretchRezConn=nil end  
	workspace.CurrentCamera.FieldOfView=70  
end  
  
local function enableRemoveAccessories()  
	removeAccessoriesEnabled=true  
	for _,p in pairs(Players:GetPlayers()) do  
		if p.Character then  
			for _,obj in ipairs(p.Character:GetDescendants()) do  
				if obj:IsA("Accessory") or obj:IsA("Hat") then pcall(function() obj:Destroy() end) end  
			end  
		end  
	end  
	if not removeAccessoriesConn then  
		removeAccessoriesConn=Players.PlayerAdded:Connect(function(pl)  
			pl.CharacterAdded:Connect(function(char)  
				task.wait(0.5)  
				if not removeAccessoriesEnabled then return end  
				for _,obj in ipairs(char:GetDescendants()) do  
					if obj:IsA("Accessory") or obj:IsA("Hat") then pcall(function() obj:Destroy() end) end  
				end  
			end)  
		end)  
	end  
end  
  
local function disableRemoveAccessories()  
	removeAccessoriesEnabled=false  
	if removeAccessoriesConn then removeAccessoriesConn:Disconnect();removeAccessoriesConn=nil end  
end  
  
-- â”€â”€â”€ Cursed Hub Anti Lag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  
local antiLagEnabled = false  
local antiLagDescConn = nil  
local antiLagDefBrightness, antiLagDefFog, antiLagDefDiffuse, antiLagDefSpecular  
  
local function _applyAntiLagObj(obj)  
	pcall(function()  
		if obj:IsA("BasePart") then  
			obj.Material=Enum.Material.Plastic; obj.Reflectance=0; obj.CastShadow=false  
		elseif obj:IsA("Decal") or obj:IsA("Texture") then  
			obj.Transparency=1  
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")  
		or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then  
			obj.Enabled=false  
		elseif obj:IsA("AnimationController") or obj:IsA("Animator") then  
			for _,t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end  
		end  
	end)  
end  
local function enableAntiLag()  
	antiLagEnabled=true  
	-- Save lighting state  
	antiLagDefBrightness = antiLagDefBrightness or Lighting.Brightness  
	antiLagDefFog = antiLagDefFog or Lighting.FogEnd  
	antiLagDefDiffuse = antiLagDefDiffuse or Lighting.EnvironmentDiffuseScale  
	antiLagDefSpecular = antiLagDefSpecular or Lighting.EnvironmentSpecularScale  
	-- Lighting tweaks (no dark mode â€” keep brightness/sky as is)  
	Lighting.GlobalShadows=false  
	Lighting.FogEnd=1e10  
	Lighting.EnvironmentDiffuseScale=0  
	Lighting.EnvironmentSpecularScale=0  
	for _,e in pairs(Lighting:GetChildren()) do  
		pcall(function()  
			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")  
			or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=false end  
		end)  
	end  
	-- Derender workspace objects  
	for _,obj in ipairs(workspace:GetDescendants()) do _applyAntiLagObj(obj) end  
	if antiLagDescConn then antiLagDescConn:Disconnect() end  
	antiLagDescConn=workspace.DescendantAdded:Connect(function(obj)  
		if antiLagEnabled then _applyAntiLagObj(obj) end  
	end)  
end  
local function disableAntiLag()  
	antiLagEnabled=false  
	if antiLagDescConn then antiLagDescConn:Disconnect(); antiLagDescConn=nil end  
	pcall(function()  
		Lighting.GlobalShadows=true  
		if antiLagDefBrightness then Lighting.Brightness=antiLagDefBrightness end  
		if antiLagDefFog then Lighting.FogEnd=antiLagDefFog end  
		if antiLagDefDiffuse then Lighting.EnvironmentDiffuseScale=antiLagDefDiffuse end  
		if antiLagDefSpecular then Lighting.EnvironmentSpecularScale=antiLagDefSpecular end  
		for _,e in pairs(Lighting:GetChildren()) do  
			pcall(function()  
				if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")  
				or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled=true end  
			end)  
		end  
	end)  
end  
-- â”€â”€â”€ End Cursed Hub Anti Lag â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  
  
local nightSkyName = "STARfySky"  
local function applyNightMode(on)  
	nightModeEnabled=on  
	if on then  
		local sky=Lighting:FindFirstChild(nightSkyName) or Instance.new("Sky")  
		sky.Name=nightSkyName  
		-- pink sky: use solid pink color via atmosphere + tint  
		sky.SkyboxBk="rbxassetid://159454299"  
		sky.SkyboxDn="rbxassetid://159454296"  
		sky.SkyboxFt="rbxassetid://159454293"  
		sky.SkyboxLf="rbxassetid://159454286"  
		sky.SkyboxRt="rbxassetid://159454289"  
		sky.SkyboxUp="rbxassetid://159454291"  
		sky.Parent=Lighting  
		Lighting.Brightness=1.8  
		Lighting.ClockTime=14  
		Lighting.ExposureCompensation=0  
		Lighting.OutdoorAmbient=Color3.fromRGB(255,160,195)  
		-- pink atmosphere  
		local atmo=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",Lighting)  
		atmo.Name="STARAtmo"  
		atmo.Color=Color3.fromRGB(255,155,190)  
		atmo.Density=0.55  
		atmo.Offset=0.2  
		atmo.Glare=0.35  
		atmo.Haze=2  
		-- pink color correction  
		local cc=Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect",Lighting)  
		cc.Name="STARCC"  
		cc.TintColor=Color3.fromRGB(255,195,220)  
		cc.Brightness=0.03  
		cc.Contrast=0.03  
		cc.Saturation=0.25  
	else  
		local s=Lighting:FindFirstChild(nightSkyName);if s then s:Destroy() end  
		local a=Lighting:FindFirstChild("STARAtmo");if a then a:Destroy() end  
		local c=Lighting:FindFirstChild("STARCC");if c then c:Destroy() end  
		Lighting.Brightness=defLightBrightness  
		Lighting.ClockTime=defClockTime  
		Lighting.ExposureCompensation=defExposureComp  
		Lighting.OutdoorAmbient=defOutdoorAmbient  
	end  
end  
  
local function findMedusa()  
	local char = LP.Character;if not char then return nil end  
	for _,t in ipairs(char:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("medusa") then return t end end  
	local bp = LP:FindFirstChild("Backpack")  
	if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name:lower():find("medusa") then return t end end end  
end  
  
local function useMedusa()  
	if medusaDebounce or tick()-medusaLastUsed<MEDUSA_COOLDOWN then return end  
	local char = LP.Character;if not char then return end  
	medusaDebounce=true  
	local med = findMedusa()  
	if med then  
		if med.Parent~=char then local h=char:FindFirstChildOfClass("Humanoid");if h then h:EquipTool(med) end end  
		pcall(function() med:Activate() end);medusaLastUsed=tick()  
	end  
	medusaDebounce=false  
end  
  
local function onAnchorChanged(part)  
	return part:GetPropertyChangedSignal("Anchored"):Connect(function()  
		if part.Anchored and part.Transparency==1 and medusaCounterEnabled then useMedusa() end  
	end)  
end  
  
local function setupMedusa(char)  
	for _,c in pairs(medusaConns) do pcall(function() c:Disconnect() end) end;medusaConns={}  
	if not char then return end  
	for _,part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then table.insert(medusaConns,onAnchorChanged(part)) end end  
	table.insert(medusaConns,char.DescendantAdded:Connect(function(part)  
		if part:IsA("BasePart") then table.insert(medusaConns,onAnchorChanged(part)) end  
	end))  
end  
  
local function getClosestPlayer()  
	local char = LP.Character;if not char then return nil,math.huge end  
	local hrp = char:FindFirstChild("HumanoidRootPart");if not hrp then return nil,math.huge end  
	local cp,cd = nil,math.huge  
	for _,p in pairs(Players:GetPlayers()) do  
		if p~=LP and p.Character then  
			local tr = p.Character:FindFirstChild("HumanoidRootPart")  
			if tr then local d=(hrp.Position-tr.Position).Magnitude;if d<cd then cd=d;cp=p end end  
		end  
	end  
	return cp,cd  
end  
  
  
-- â”€â”€â”€ Envy Bat Aimbot â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€  
local _aimbotTarget = nil  
  
local function findBat()  
	local char = LP.Character; if not char then return nil end  
	for _, tool in ipairs(char:GetChildren()) do  
		if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end  
	end  
	local bp = LP:FindFirstChild("Backpack")  
	if bp then  
		for _, tool in ipairs(bp:GetChildren()) do  
			if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end  
		end  
	end  
	return nil  
end  
  
local function getClosestTarget()  
	local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")  
	if not root then return nil end  
	local closest, minDist = nil, math.huge  
	for _, plr in ipairs(Players:GetPlayers()) do  
		if plr ~= LP and plr.Character then  
			local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")  
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")  
			if tRoot and hum and hum.Health > 0 then  
				local dist = (tRoot.Position - root.Position).Magnitude  
				if dist < minDist then minDist = dist; closest = tRoot end  
			end  
		end  
	end  
	return closest  
end  
  
local _batAimbotConn = nil  
  
startBatAimbot = function()  
	if _batAimbotConn then _batAimbotConn:Disconnect() end  
	if autoLeftEnabled  then autoLeftEnabled=false;  if autoLeftSetVisual  then autoLeftSetVisual(false)  end; stopAutoLeft()  end  
	if autoRightEnabled then autoRightEnabled=false; if autoRightSetVisual then autoRightSetVisual(false) end; stopAutoRight() end  
	local hum0 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")  
	if hum0 then hum0.AutoRotate = false end  
	_batAimbotConn = RunService.RenderStepped:Connect(function()  
		if not autoBatEnabled then return end  
		local char = LP.Character; if not char then return end  
		local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end  
		local hum  = char:FindFirstChildOfClass("Humanoid");  if not hum  then return end  
		if not char:FindFirstChildOfClass("Tool") then  
			local bat = findBat()  
			if bat then pcall(function() hum:EquipTool(bat) end) end  
		end  
		local target = getClosestTarget()  
		if not target then return end  
		_aimbotTarget = target  
		local targetVel = target.AssemblyLinearVelocity  
		local myPos     = root.Position  
		local targetPos = target.Position  
		local predictPos = targetPos + targetVel * 0.14  
		predictPos = predictPos + target.CFrame.LookVector * 0.3  
		local direction = predictPos - myPos  
		local flatDir = Vector3.new(direction.X, 0, direction.Z).Unit  
		local chaseSpeed = autoBatSpeed  
		local desiredHeight = targetPos.Y + 3.7  
		local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8  
		if hum.FloorMaterial ~= Enum.Material.Air then yVel = math.max(yVel, 13) end  
		yVel = math.clamp(yVel, -70, 110)  
		local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)  
		root.AssemblyLinearVelocity = root.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)  
		local speed3 = targetVel.Magnitude  
		local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)  
		local predictedPos = targetPos + targetVel * predictTime  
		local toPredict = predictedPos - myPos  
		if toPredict.Magnitude > 0.1 then  
			local goalCF = CFrame.lookAt(myPos, predictedPos)  
			local diffCF = root.CFrame:Inverse() * goalCF  
			local rx, ry, rz = diffCF:ToEulerAnglesXYZ()  
			rx = math.clamp(rx,-2.5,2.5); ry = math.clamp(ry,-2.5,2.5); rz = math.clamp(rz,-2.5,2.5)  
			root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx*42, ry*42, rz*42))  
		end  
	end)  
end  
  
stopBatAimbot = function()  
	if _batAimbotConn then _batAimbotConn:Disconnect(); _batAimbotConn = nil end  
	_aimbotTarget = nil  
	local c    = LP.Character  
	local root = c and c:FindFi
