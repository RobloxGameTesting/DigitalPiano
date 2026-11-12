local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExperienceComponents = script:FindFirstAncestor("ExperienceComponents")
local Otter = require(ExperienceComponents.Parent.Otter)

local HumanoidController = {}
HumanoidController.__index = HumanoidController

local _ = { Idle = 0, Animating = 1 }

function HumanoidController.new(player)
	local v = {
		player = player,
		characterParts = {},
		state = 0,
		animationCompleted = Instance.new("BindableEvent"),
		spring = Otter.spring
	}

	function v.setOriginalTransparencies()
		local character = v.player.Character

		if character and v.state == 0 then
			for _, descendant in ipairs(character:GetDescendants()) do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					v.characterParts[descendant] = descendant.Transparency
				end
			end
		end
	end

	v.motor = Otter.createSingleMotor(0)
	v.motor:onStep(function(p)
		for k, characterPart in pairs(v.characterParts) do
			k.Transparency = math.max(p, characterPart)
		end
	end)
	v.motor:onComplete(function(p: number)
		if p == 1 then
			local character = v.player.Character

			if not character then
				return
			end

			character.Parent = ReplicatedStorage
		end

		v.state = 0
		v.animationCompleted:Fire()
	end)

	setmetatable(v, HumanoidController)

	return v
end

function HumanoidController:show()
	local character = self.player.Character

	if not character then
		return
	end

	character.Parent = workspace

	self.state = 1
	self.motor:setGoal(self.spring(0))
end

function HumanoidController:hide()
	self.setOriginalTransparencies()

	self.state = 1
	self.motor:setGoal(self.spring(1))
end

function HumanoidController.isAnimating(p): boolean
	return p.state == 1
end

return HumanoidController