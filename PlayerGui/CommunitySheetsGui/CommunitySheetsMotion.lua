local v = {
	Beginner = Color3.fromRGB(52, 211, 153),
	Intermediate = Color3.fromRGB(238, 190, 47),
	Advanced = Color3.fromRGB(240, 117, 54),
	Expert = Color3.fromRGB(236, 72, 112),
	Default = Color3.fromRGB(98, 108, 132)
}

local v2 = {
	easy = "Beginner",
	beginner = "Beginner",
	medium = "Intermediate",
	intermediate = "Intermediate",
	normal = "Intermediate",
	hard = "Advanced",
	advanced = "Advanced",
	expert = "Expert"
}

local function getStroke(guiObject)
	if not guiObject then
		return nil
	end

	for _, uiStroke in ipairs(guiObject:GetChildren()) do
		if uiStroke:IsA("UIStroke") then
			return uiStroke
		end
	end

	return nil
end

local function getDifficultyColor(guiObject)
	if not guiObject then
		return v.Default
	end

	local v3 = tostring(guiObject:GetAttribute("CommunityDifficulty") or "")

	if v3 == "" then
		local difficultyBadge = guiObject:FindFirstChild("DifficultyBadge", true)

		if difficultyBadge and (difficultyBadge:IsA("TextLabel") or difficultyBadge:IsA("TextButton")) then
			v3 = difficultyBadge.Text
		end
	end

	return v[v2[v3:lower():gsub("%s+", "")] or "Default"] or v.Default
end

return {
	AttachCard = function(self, _, _)
		if not self or not self:IsA("GuiObject") or self:GetAttribute("CommunityMotionCardBound") == true then
			return
		end

		self:SetAttribute("CommunityMotionCardBound", true)

		local stroke = getStroke(self)
		local backgroundColor3 = self.BackgroundColor3
		local color

		if stroke then
			color = stroke.Color or nil
		else
			color = nil
		end

		local transparency

		if stroke then
			transparency = stroke.Transparency or nil
		else
			transparency = nil
		end

		local thickness

		if stroke then
			thickness = stroke.Thickness or nil
		else
			thickness = nil
		end

		local difficultyColor = getDifficultyColor(self)
		local lerped = backgroundColor3:Lerp(difficultyColor, 0.06)
		local transparency2

		if stroke then
			transparency2 = math.max(0.08, (transparency or 0.45) - 0.22) or nil
		else
			transparency2 = nil
		end

		local thickness2

		if stroke then
			thickness2 = math.min(2, (thickness or 1) + 0.35) or nil
		else
			thickness2 = nil
		end

		self.MouseEnter:Connect(function()
			if not self.Parent then
				return
			end

			self.BackgroundColor3 = lerped

			if stroke and stroke.Parent then
				stroke.Color = difficultyColor
				stroke.Transparency = transparency2
				stroke.Thickness = thickness2
			end
		end)

		self.MouseLeave:Connect(function()
			if not self.Parent then
				return
			end

			self.BackgroundColor3 = backgroundColor3

			if stroke and stroke.Parent then
				stroke.Color = color
				stroke.Transparency = transparency
				stroke.Thickness = thickness
			end
		end)
	end
}