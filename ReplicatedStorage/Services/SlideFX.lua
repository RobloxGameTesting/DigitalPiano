local TweenService = game:GetService("TweenService")

local v = {
	direction = "right",
	inTime = 0.25,
	outTime = 0.22,
	easeIn = Enum.EasingStyle.Quad,
	easeOut = Enum.EasingStyle.Quad,
	easeDirIn = Enum.EasingDirection.Out,
	easeDirOut = Enum.EasingDirection.In,
	offsetScale = 0.3,
	startHidden = true
}

local function tween(guiObject, tweenInfo, goal) -- 1 equivalent call inferred from this helper
	return TweenService:Create(guiObject, tweenInfo, goal)
end

local function computeOffPosition(guiObject, direction: string, offsetScale: number)
	guiObject.AnchorPoint = guiObject.AnchorPoint or Vector2.new(0.5, 0.5)
	local position = guiObject.Position
	local scale = position.X.Scale
	local offset = position.X.Offset
	local scale2 = position.Y.Scale
	local offset2 = position.Y.Offset

	if direction == "right" then
		return UDim2.new(offsetScale + 1, offset, scale2, offset2)
	elseif direction == "left" then
		return UDim2.new(0 - offsetScale, offset, scale2, offset2)
	elseif direction == "top" then
		return UDim2.new(scale, offset, 0 - offsetScale, offset2)
	elseif direction == "bottom" then
		return UDim2.new(scale, offset, offsetScale + 1, offset2)
	end

	return UDim2.new(offsetScale + 1, offset, scale2, offset2)
end

return {
	attach = function(self, options)
		assert(self and self:IsA("GuiObject"), "SlideFX.attach(panel, opts) requires a GuiObject")

		local clone = table.clone(options or {})

		for k, v2 in pairs(v) do
			if clone[k] == nil then
				clone[k] = v2
			end
		end

		local v2 = {
			panel = self,
			homePos = self.Position,
			offPos = computeOffPosition(self, clone.direction, clone.offsetScale),
			open = false,
			busy = false,
			tw = nil,
			reqId = 0
		}

		if clone.startHidden then
			self.Visible = false
			self.Position = v2.offPos
			v2.open = false
		else
			v2.open = true
		end

		local function stopTween() -- 1 equivalent call inferred from this helper
			if v2.tw then
				v2.tw:Cancel()
				v2.tw = nil
			end

			v2.busy = false
		end

		local function animateTo(position: UDim2, duration: number, p, p2, fn)
			stopTween() -- inferred equivalent call
			v2.busy = true
			v2.reqId += 1
			local reqId = v2.reqId

			v2.tw = tween(self, TweenInfo.new(duration, p, p2), { Position = position }) -- inferred equivalent call
			v2.tw.Completed:Once(function()
				if reqId ~= v2.reqId then
					return
				end

				v2.tw = nil
				v2.busy = false

				if fn then
					fn()
				end
			end)
			v2.tw:Play()
		end

		local function show() -- 2 equivalent calls inferred from this helper
			if v2.open and not v2.busy then
				return
			end

			self.Visible = true
			animateTo(v2.homePos, clone.inTime, clone.easeIn, clone.easeDirIn, function()
				v2.open = true
			end)
		end

		local function hide() -- 2 equivalent calls inferred from this helper
			if v2.open or v2.busy then
				animateTo(v2.offPos, clone.outTime, clone.easeOut, clone.easeDirOut, function()
					v2.open = false

					self.Visible = false
				end)
			else
				self.Visible = false
			end
		end

		return {
			Show = function(_)
				show() -- inferred equivalent call
			end,
			Hide = function(_)
				hide() -- inferred equivalent call
			end,
			Toggle = function(_)
				if v2.open then
					hide() -- inferred equivalent call
				else
					show() -- inferred equivalent call
				end
			end,
			IsOpen = function(_)
				return v2.open
			end,
			Recompute = function(_)
				v2.homePos = self.Position
				v2.offPos = computeOffPosition(self, clone.direction, clone.offsetScale)
			end
		}
	end
}