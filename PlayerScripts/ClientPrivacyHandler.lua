local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local SetProfilePlayerHidden = ReplicatedStorage:FindFirstChild("SetProfilePlayerHidden")

if not (SetProfilePlayerHidden and SetProfilePlayerHidden:IsA("BindableEvent")) then
	if SetProfilePlayerHidden then
		SetProfilePlayerHidden:Destroy()
	end

	SetProfilePlayerHidden = Instance.new("BindableEvent")
	SetProfilePlayerHidden.Name = "SetProfilePlayerHidden"
	SetProfilePlayerHidden.Parent = ReplicatedStorage
end

local v = {}
local object = setmetatable({}, { __mode = "k" })
local object2 = setmetatable({}, { __mode = "k" })
local v2 = {}
local object3 = setmetatable({}, { __mode = "k" })
local restoreOverhead

local function shouldHideOtherPlayers(): boolean -- 2 equivalent calls inferred from this helper
	return LocalPlayer:GetAttribute("HideOtherPlayers") == true
end

local function getHiddenPlayerAttributeName(p) -- 2 equivalent calls inferred from this helper
	return "HiddenPlayerChat_" .. tostring((math.floor(tonumber(p) or 0)))
end

local function getPlayerByUserId(p) -- 3 equivalent calls inferred from this helper
	local v3 = math.floor(tonumber(p) or 0)

	if v3 <= 0 then
		return nil
	end

	for _, v4 in ipairs(Players:GetPlayers()) do
		if v4.UserId == v3 then
			return v4
		end
	end

	return nil
end

local function isInvisibleUserId(ownerUserId) -- 2 equivalent calls inferred from this helper
	local v3
	v3 = getPlayerByUserId(ownerUserId) -- inferred equivalent call

	if not v3 then
		return false
	end

	if v3:GetAttribute("IsInvisible") == true then
		return true
	end

	local character = v3.Character
	return character and character:GetAttribute("IsInvisible") == true
end

local function shouldHideUserId(p): boolean -- 7 equivalent calls inferred from this helper
	local v3 = math.floor(tonumber(p) or 0)
	return v3 > 0 and (LocalPlayer:GetAttribute("HideOtherPlayers") == true or v[v3] == true)
end

local function shouldHideOverheadUserId(ownerUserId) -- 1 equivalent call inferred from this helper
	local v3 = math.floor(tonumber(ownerUserId) or 0)
	local v4

	if not (v3 > 0) then
		v4 = false
		return false
	end

	v4 = shouldHideUserId(v3) -- inferred equivalent call

	if v4 then
		return v4
	end

	local v5
	v5 = getPlayerByUserId(v3) -- inferred equivalent call

	if not v5 then
		return false
	end

	if v5:GetAttribute("IsInvisible") == true then
		return true
	end

	local character = v5.Character
	return character and character:GetAttribute("IsInvisible") == true
end

local function shouldHidePlayer(p) -- 1 equivalent call inferred from this helper
	if p then
		if p == LocalPlayer then
			p = false
		else
			p = shouldHideUserId(p.UserId) -- inferred equivalent call
		end
	end

	return p
end

local function capture(p, p2)
	local v3 = object[p]

	if not v3 then
		v3 = {}
		object[p] = v3
	end

	if v3[p2] == nil then
		local success, result = pcall(function()
			return p[p2]
		end)

		if success then
			v3[p2] = result
		end
	end
end

local function setProperty(p, k, p2) -- 10 equivalent calls inferred from this helper
	pcall(function()
		p[k] = p2
	end)
end

local function restoreInstance(p)
	local v3 = object[p]

	if not v3 then
		return
	end

	for k, v4 in pairs(v3) do
		setProperty(p, k, v4) -- inferred equivalent call
	end

	object[p] = nil
end

local function restoreAll()
	local v3 = {}

	for k in pairs(object) do
		v3[#v3 + 1] = k
	end

	for _, v4 in ipairs(v3) do
		restoreInstance(v4)
	end
end

local function forceRestoreCharacter(folder)
	if not folder then
		return
	end

	for _, descendant in ipairs(folder:GetDescendants()) do
		restoreInstance(descendant)

		if descendant:IsA("BasePart") then
			setProperty(descendant, "LocalTransparencyModifier", 0) -- inferred equivalent call
		elseif descendant:IsA("BillboardGui") and descendant.Name == "OverheadBBGUI" then
			restoreOverhead(descendant)
		end
	end
end

local function getPlayerFromModel(model) -- 1 equivalent call inferred from this helper
	if not (model and model:IsA("Model")) then
		return nil
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(model)

	if playerFromCharacter then
		return playerFromCharacter
	end

	local child = Players:FindFirstChild(model.Name)

	if child and (child.Character == model or model.Parent == Workspace) then
		return child
	end

	return nil
end

local function getPlayerFromAncestry(p)
	while p and p ~= game do
		local playerFromModel = getPlayerFromModel(p) -- inferred equivalent call

		if playerFromModel then
			return playerFromModel
		end

		p = p.Parent
	end

	return nil
end

local function getOwnerUserId(instance) -- 7 equivalent calls inferred from this helper
	local ownerUserId = tonumber(instance:GetAttribute("OwnerUserId"))

	if ownerUserId then
		return ownerUserId
	end

	local model = instance
	local v3

	while true do
		if not model or model == game then
			v3 = nil
			break
		end

		if model and model:IsA("Model") then
			v3 = Players:GetPlayerFromCharacter(model)

			if not v3 then
				v3 = Players:FindFirstChild(model.Name)

				if not v3 or v3.Character ~= model and model.Parent ~= Workspace then
					v3 = nil
				end
			end
		else
			v3 = nil
		end

		if v3 then
			break
		end

		model = model.Parent
	end

	if v3 then
		return v3.UserId
	end

	if not instance.Adornee then
		return nil
	end

	local model2 = instance.Adornee
	local v4

	while true do
		if not model2 or model2 == game then
			v4 = nil
			break
		end

		if model2 and model2:IsA("Model") then
			v4 = Players:GetPlayerFromCharacter(model2)

			if not v4 then
				v4 = Players:FindFirstChild(model2.Name)

				if not v4 or v4.Character ~= model2 and model2.Parent ~= Workspace then
					v4 = nil
				end
			end
		else
			v4 = nil
		end

		if v4 then
			break
		end

		model2 = model2.Parent
	end

	return if v4 then v4.UserId else nil
end

local function isOtherPlayerOverhead(billboardGui): boolean
	if not billboardGui:IsA("BillboardGui") or billboardGui.Name ~= "OverheadBBGUI" then
		return false
	end

	local ownerUserId = getOwnerUserId(billboardGui) -- inferred equivalent call
	return ownerUserId ~= nil and ownerUserId ~= LocalPlayer.UserId
end

local function captureOverheadBaseline(folder)
	local v3 = object2[folder]

	if v3 then
		return v3
	end

	local v4 = {
		Enabled = folder.Enabled,
		Children = setmetatable({}, { __mode = "k" })
	}

	object2[folder] = v4

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("GuiObject") then
			v4.Children[descendant] = {
				ClassName = descendant.ClassName,
				Visible = descendant.Visible
			}
		elseif descendant:IsA("UIStroke") then
			v4.Children[descendant] = {
				ClassName = descendant.ClassName,
				Enabled = descendant.Enabled
			}
		end
	end

	return v4
end

restoreOverhead = function(folder)
	local ownerUserId = getOwnerUserId(folder) -- inferred equivalent call

	if ownerUserId and isInvisibleUserId(ownerUserId) then -- inferred equivalent call
		capture(folder, "Enabled")
		setProperty(folder, "Enabled", false) -- inferred equivalent call
		return
	end

	restoreInstance(folder)
	setProperty(folder, "Enabled", true) -- inferred equivalent call

	for _, descendant in ipairs(folder:GetDescendants()) do
		restoreInstance(descendant)
	end

	object2[folder] = nil
end

local function setOverheadHidden(instance, p)
	if not p then
		local ownerUserId = getOwnerUserId(instance) -- inferred equivalent call

		if ownerUserId and isInvisibleUserId(ownerUserId) then -- inferred equivalent call
			p = true
		end
	end

	if not p then
		restoreOverhead(instance)
		return
	end

	capture(instance, "Enabled")
	setProperty(instance, "Enabled", false) -- inferred equivalent call
end

local function watchOverhead(billboardGui)
	if object3[billboardGui] then
		return
	end

	local connections = {}
	local function disconnectAll() -- 1 equivalent call inferred from this helper
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		object3[billboardGui] = nil
	end

	local function enforce() -- 1 equivalent call inferred from this helper
		if billboardGui.Parent then
			local ownerUserId = getOwnerUserId(billboardGui) -- inferred equivalent call

			if ownerUserId and ownerUserId ~= LocalPlayer.UserId then
				local v3 = math.floor(tonumber(ownerUserId) or 0)
				local v4

				if v3 > 0 then
					v4 = shouldHideUserId(v3) -- inferred equivalent call

					if not v4 then
						local v5
						v5 = getPlayerByUserId(v3) -- inferred equivalent call

						if v5 then
							if v5:GetAttribute("IsInvisible") == true then
								v4 = true
							else
								v4 = v5.Character

								if v4 then
									if v4:GetAttribute("IsInvisible") == true then
										v4 = true
									else
										v4 = false
									end
								end
							end
						else
							v4 = false
						end
					end
				else
					v4 = false
				end

				setOverheadHidden(billboardGui, v4)
			end
		else
			disconnectAll() -- inferred equivalent call
		end
	end

	connections[#connections + 1] = billboardGui:GetPropertyChangedSignal("Enabled"):Connect(enforce)
	connections[#connections + 1] = billboardGui:GetPropertyChangedSignal("Adornee"):Connect(enforce)
	connections[#connections + 1] = billboardGui.AncestryChanged:Connect(function()
		task.defer(enforce)
	end)
	connections[#connections + 1] = billboardGui.DescendantAdded:Connect(function()
		local ownerUserId = getOwnerUserId(billboardGui) -- inferred equivalent call

		if ownerUserId and ownerUserId ~= LocalPlayer.UserId and shouldHideOverheadUserId(ownerUserId) then -- inferred equivalent call
			setProperty(billboardGui, "Enabled", false) -- inferred equivalent call
		end
	end)
	object3[billboardGui] = connections
	enforce() -- inferred equivalent call
end

local function setInstanceHidden(billboardGui, p)
	if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
		setOverheadHidden(billboardGui, p)
	elseif not p then
		restoreInstance(billboardGui)
	elseif billboardGui:IsA("BasePart") then
		capture(billboardGui, "LocalTransparencyModifier")
		setProperty(billboardGui, "LocalTransparencyModifier", 1) -- inferred equivalent call
	elseif billboardGui:IsA("Decal") or billboardGui:IsA("Texture") then
		capture(billboardGui, "Transparency")
		setProperty(billboardGui, "Transparency", 1) -- inferred equivalent call
	elseif billboardGui:IsA("BillboardGui") or billboardGui:IsA("SurfaceGui") then
		capture(billboardGui, "Enabled")
		setProperty(billboardGui, "Enabled", false) -- inferred equivalent call
	elseif
		billboardGui:IsA("ParticleEmitter")
		or billboardGui:IsA("Trail")
		or billboardGui:IsA("Beam")
		or billboardGui:IsA("Highlight")
	then
		capture(billboardGui, "Enabled")
		setProperty(billboardGui, "Enabled", false) -- inferred equivalent call
	end
end

local function applyToCharacter(p, folder)
	if p == LocalPlayer or not folder then
		return
	end

	local v3

	if p then
		if p == LocalPlayer then
			v3 = false
		else
			v3 = shouldHideUserId(p.UserId) -- inferred equivalent call
		end
	else
		v3 = p
	end

	for _, billboardGui in ipairs(folder:GetDescendants()) do
		setInstanceHidden(billboardGui, v3)

		if not (billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI") then
			continue
		end

		watchOverhead(billboardGui)
		setOverheadHidden(billboardGui, v3)
	end

	local connection = v2[p]

	if connection then
		connection:Disconnect()
	end

	v2[p] = folder.DescendantAdded:Connect(function(billboardGui)
		local v4 = shouldHidePlayer(p) -- inferred equivalent call
		setInstanceHidden(billboardGui, v4)

		if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
			watchOverhead(billboardGui)
			setOverheadHidden(billboardGui, v4)
		end
	end)
end

local function hookPlayer(player) -- 1 equivalent call inferred from this helper
	if player == LocalPlayer then
		return
	end

	if player.Character then
		applyToCharacter(player, player.Character)
	end

	player.CharacterAdded:Connect(function(character)
		applyToCharacter(player, character)
	end)
end

local function refreshOverheads()
	for _, billboardGui in ipairs(Workspace:GetDescendants()) do
		if not (billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI") then
			continue
		end

		watchOverhead(billboardGui)
		local ownerUserId = getOwnerUserId(billboardGui) -- inferred equivalent call

		if not (ownerUserId and ownerUserId ~= LocalPlayer.UserId) then
			continue
		end

		local v3 = math.floor(tonumber(ownerUserId) or 0)
		local v4

		if v3 > 0 then
			v4 = shouldHideUserId(v3) -- inferred equivalent call

			if not v4 then
				local v5 = math.floor(tonumber(v3) or 0)
				local v6

				if not (v5 <= 0) then
					for _, v7 in ipairs(Players:GetPlayers()) do
						if v7.UserId == v5 then
							v6 = v7
							break
						end
					end
				end

				if v6 then
					if v6:GetAttribute("IsInvisible") == true then
						v4 = true
					else
						v4 = v6.Character

						if v4 then
							v4 = v4:GetAttribute("IsInvisible") == true
						end
					end
				else
					v4 = false
				end
			end
		else
			v4 = false
		end

		setOverheadHidden(billboardGui, v4)
	end
end

local function refreshAllPlayers()
	if not shouldHideOtherPlayers() then -- inferred equivalent call
		restoreAll()
	end

	for _, v3 in ipairs(Players:GetPlayers()) do
		if not (v3 ~= LocalPlayer and v3.Character) then
			continue
		end

		local v4

		if v3 then
			if v3 == LocalPlayer then
				v4 = false
			else
				v4 = shouldHideUserId(v3.UserId) -- inferred equivalent call
			end
		else
			v4 = v3
		end

		if v4 then
			applyToCharacter(v3, v3.Character)
		else
			forceRestoreCharacter(v3.Character)
		end
	end

	refreshOverheads()
end

SetProfilePlayerHidden.Event:Connect(function(p, p2)
	local v3 = math.floor(tonumber(p) or 0)

	if v3 <= 0 or v3 == LocalPlayer.UserId then
		return
	end

	if p2 == true then
		v[v3] = true
		LocalPlayer:SetAttribute(getHiddenPlayerAttributeName(v3), true) -- inferred equivalent call
	else
		v[v3] = nil
		LocalPlayer:SetAttribute(getHiddenPlayerAttributeName(v3), nil) -- inferred equivalent call
	end

	refreshAllPlayers()
end)

Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(function(player)
	local connection = v2[player]

	if connection then
		connection:Disconnect()
		v2[player] = nil
	end
end)

for _, v3 in ipairs(Players:GetPlayers()) do
	hookPlayer(v3) -- inferred equivalent call
end

Workspace.DescendantAdded:Connect(function(billboardGui)
	if billboardGui:IsA("BillboardGui") and billboardGui.Name == "OverheadBBGUI" then
		task.defer(function()
			watchOverhead(billboardGui)
			local ownerUserId = getOwnerUserId(billboardGui) -- inferred equivalent call

			if ownerUserId and ownerUserId ~= LocalPlayer.UserId then
				setOverheadHidden(billboardGui, shouldHideUserId(ownerUserId)) -- inferred equivalent call
			end
		end)
	end
end)

LocalPlayer:GetAttributeChangedSignal("HideOtherPlayers"):Connect(function()
	refreshAllPlayers()

	if not shouldHideOtherPlayers() then -- inferred equivalent call
		task.defer(refreshAllPlayers)
		task.delay(0.25, refreshAllPlayers)
	end
end)
LocalPlayer.CharacterAdded:Connect(function()
	task.defer(refreshAllPlayers)
end)
refreshAllPlayers()