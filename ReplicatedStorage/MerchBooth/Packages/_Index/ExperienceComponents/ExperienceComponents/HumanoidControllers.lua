local HumanoidController = require(script.Parent.HumanoidController)

local HumanoidControllers = {}
HumanoidControllers.__index = HumanoidControllers

function HumanoidControllers.new(playerList, whitelist)
	local v = { playerList = playerList, whitelist = whitelist }

	v.isHiding = false

	v.humanoidControllers = {}

	for _, player in ipairs(v.playerList) do
		v.humanoidControllers[player.UserId] = HumanoidController.new(player)
	end

	v.whitelistedUserIds = {}

	if v.whitelist then
		for _, v2 in ipairs(v.whitelist) do
			v.whitelistedUserIds[v2.UserId] = true
		end
	end

	setmetatable(v, HumanoidControllers)

	return v
end

function HumanoidControllers:showHumanoids()
	self.isHiding = false

	for k, humanoidController in pairs(self.humanoidControllers) do
		if not self.whitelistedUserIds[k] then
			humanoidController:show()
		end
	end
end

function HumanoidControllers:hideHumanoids()
	self.isHiding = true

	for k, humanoidController in pairs(self.humanoidControllers) do
		if not self.whitelistedUserIds[k] then
			humanoidController:hide()
		end
	end
end

function HumanoidControllers.addHumanoidController(p, p2)
	if p.humanoidControllers[p2.UserId] then
		warn("Error: " .. p2.Name .. " already has a HumanoidController.")
	else
		p.humanoidControllers[p2.UserId] = HumanoidController.new(p2)

		if p.isHiding then
			p.humanoidControllers[p2.UserId]:hide()
		end
	end
end

function HumanoidControllers.removeHumanoidController(p, p2)
	if p.humanoidControllers[p2.UserId] then
		p.humanoidControllers[p2.UserId] = nil
	else
		warn("Error: " .. p2.Name .. " does not have a HumanoidController to remove.")
	end
end

function HumanoidControllers.addToWhitelist(p, p2)
	if p.whitelistedUserIds[p2.UserId] then
		warn("Error: " .. p2.Name .. " is already part of the whitelist for HumanoidControllers.")
	else
		p.whitelistedUserIds[p2.UserId] = p2
	end
end

function HumanoidControllers.removeFromWhitelist(p, p2)
	if p.whitelistedUserIds[p2.UserId] == nil then
		warn("Error: " .. p2.Name .. " is not part of the whitelist for HumanoidControllers.")
	else
		p.whitelistedUserIds[p2.UserId] = nil
	end
end

function HumanoidControllers.waitForHumanoidAnimations(p)
	for _, humanoidController in pairs(p.humanoidControllers) do
		if humanoidController:isAnimating() then
			humanoidController.animationCompleted.Event:Wait()
		end
	end
end

return HumanoidControllers