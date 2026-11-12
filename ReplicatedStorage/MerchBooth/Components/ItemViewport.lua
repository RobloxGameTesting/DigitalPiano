local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Otter = require(MerchBooth.Packages.Otter)
local Roact = require(MerchBooth.Packages.Roact)
local ExternalEventConnection = require(MerchBooth.Packages.ExternalEventConnection)
local getInstanceCenter = require(MerchBooth.Modules.getInstanceCenter)
local constants = require(MerchBooth.constants)
local enums = require(MerchBooth.enums)
require(MerchBooth.types)

local function getDepthToFitObject(fieldOfView: number, viewportObject)
	local v

	if viewportObject:IsA("Model") then
		local boundingBox
		boundingBox, v = viewportObject:GetBoundingBox()
	elseif viewportObject:IsA("BasePart") then
		v = viewportObject.Size
	else
		v = viewportObject:FindFirstChildWhichIsA("BasePart").Size
	end

	local y = math.abs(v.Y)
	local z = math.abs(v.Z)

	return y / (math.tan((math.rad(fieldOfView / 2))) * 2) + z / 2
end

local defaultProps = {
	size = UDim2.fromScale(1, 1),
	previewRotationSpeed = 15,
	rotation = 120,
	zoomRange = NumberRange.new(-2, 5),
	zoomIncrement = 2.5,
	spring = Otter.spring,
	UserInputService = UserInputService,
	RunService = RunService
}

local extended = Roact.Component:extend("ItemViewport")

extended.defaultProps = defaultProps

function extended:init()
	self.isUserRotating = false
	self.isUserPinching = false

	self.zoomOffset = 0
	self.zoomMotor = Otter.createSingleMotor(self.zoomOffset)
	self.zoomMotor:onStep(function(zoomOffset: number)
		self.zoomOffset = zoomOffset
	end)

	self.rotation = self.props.rotation

	self.viewportCamera = Instance.new("Camera")
	self.lastViewportInputPosition = Vector3.new()
	self.viewportRef = Roact.createRef()

	function self.heartbeatFunction(p: number)
		local viewportCamera = self.viewportCamera
		local viewportObject = self.viewportObject

		if not (viewportObject and viewportObject.Parent) then
			return
		end

		local now = os.clock()

		if self.nextParticleEmitAt and self.nextParticleEmitAt <= now then
			for _, emitter in ipairs(viewportObject:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit((math.max(1, (math.floor(tonumber(emitter:GetAttribute("EmitCount")) or 40)))))
				end
			end

			self.nextParticleEmitAt = now + 0.16
		end

		local previewRotationSpeed = self.props.previewRotationSpeed

		if not self.isUserRotating then
			local v = previewRotationSpeed * 0.95 + previewRotationSpeed * 0.05
			self.rotation = (self.rotation + p * v) % 360
		end

		local props = self.props
		local cframe = CFrame.Angles(0, math.rad(self.rotation), 0)
		local instanceCenter = getInstanceCenter(viewportObject)
		local v = math.clamp(
			getDepthToFitObject(viewportCamera.FieldOfView, viewportObject),
			props.zoomRange.Min,
			props.zoomRange.Max
		)

		viewportCamera.CFrame = CFrame.new(instanceCenter) * cframe * CFrame.new(0, 0, v + 2 + self.zoomOffset)
	end

	function self.zoom(p: number)
		local props = self.props

		local v = math.clamp(self.zoomOffset - props.zoomIncrement * p, props.zoomRange.Min, props.zoomRange.Max)

		self.zoomMotor:setGoal(props.spring(v, constants.Springs.Zippy))
	end

	function self.inputBegan(_, p)
		if p.UserInputType == Enum.UserInputType.MouseWheel then
			self.zoom(p.Position.Z)
		end

		if self.isUserPinching then
			return
		end

		if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
			self.isUserRotating = true

			self:setState({ viewportInput = true })
			self.lastViewportInputPosition = p.Position
		end
	end

	function self.inputEnded(_, p)
		if self.isUserRotating then
			self.isUserRotating = false

			if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
				self:setState({ viewportInput = false })
			end
		end
	end

	function self.inputChanged(_, p)
		if p.UserInputType == Enum.UserInputType.MouseWheel then
			self.zoom(p.Position.Z)
		end

		if
			self.isUserRotating
			and not self.isUserPinching
			and (p.UserInputType == Enum.UserInputType.MouseMovement or p.UserInputType == Enum.UserInputType.Touch)
		then
			local v = p.Position - self.lastViewportInputPosition
			self.lastViewportInputPosition = p.Position
			self.rotation -= v.X
		end
	end

	local v = nil
	function self.touchPinch(_, list, _, _, p)
		if not list[2] or p == Enum.UserInputState.End then
			self.isUserPinching = false
			return
		end

		self.isUserPinching = true

		local magnitude = (list[1] - list[2]).Magnitude

		if p == Enum.UserInputState.Change then
			local props = self.props
			local v2 = magnitude - v
			local v3 = self.zoomOffset - props.zoomIncrement * v2 * 0.1

			self.zoomOffset = math.clamp(v3, props.zoomRange.Min, props.zoomRange.Max)
		end

		v = magnitude
	end

	function self.updateViewportItem()
		local props = self.props
		local parent = self.viewportRef:getValue()

		if not parent then
			return
		end

		parent:ClearAllChildren()
		self.viewportObject = nil
		self.nextParticleEmitAt = nil

		if not props.itemInfo then
			return
		end

		local previewWorld = Instance.new("WorldModel")
		previewWorld.Name = "PreviewWorld"
		previewWorld.Parent = parent

		local clone = nil

		if props.previewMode == enums.PreviewModes.Object then
			if props.itemInfo.viewportObject then
				clone = props.itemInfo.viewportObject:Clone()
			else
				warn("Merch booth item preview: could not find item viewport object")
			end
		elseif props.previewAvatar then
			clone = props.previewAvatar:Clone()
		else
			warn("Merch booth item preview: could not find preview avatar")
		end

		if clone then
			clone.Parent = previewWorld
			self.viewportObject = clone

			for _, emitter in ipairs(clone:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Enabled = true
				emitter:Emit((math.max(1, (math.floor(tonumber(emitter:GetAttribute("EmitCount")) or 40)))))
			end

			self.nextParticleEmitAt = os.clock() + 0.25
		end
	end
end

function extended.render(props)
	return Roact.createElement("ViewportFrame", {
		Active = true,
		LayoutOrder = props.props.LayoutOrder,
		Size = props.props.size,
		BackgroundTransparency = 1,
		CurrentCamera = props.viewportCamera,
		[Roact.Event.InputBegan] = props.inputBegan,
		[Roact.Event.InputEnded] = props.inputEnded,
		[Roact.Event.InputChanged] = props.inputChanged,
		[Roact.Event.TouchPinch] = props.touchPinch,
		[Roact.Ref] = props.viewportRef
	}, {
		HeartbeatEventConnection = Roact.createElement(ExternalEventConnection, {
			event = props.props.RunService.Heartbeat,
			callback = props.heartbeatFunction
		})
	})
end

function extended.didMount(p)
	p.updateViewportItem()
end

function extended.didUpdate(p, data)
	local props = p.props

	if
		data.itemInfo ~= props.itemInfo
		or data.previewMode ~= props.previewMode
		or props.previewAvatar ~= data.previewAvatar
	then
		p.updateViewportItem()
	end
end

return extended