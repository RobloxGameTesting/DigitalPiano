local PianoModelKeyHighlight = {}

local color = Color3.fromRGB(255, 255, 255)

local function hexToColor3(value, p)
	if typeof(value) ~= "string" then
		return p
	end

	local v = value:gsub("#", "")

	if #v ~= 6 then
		return p
	end

	local v2 = tonumber(v:sub(1, 2), 16)
	local v3 = tonumber(v:sub(3, 4), 16)
	local v4 = tonumber(v:sub(5, 6), 16)

	if v2 and v3 and v4 then
		return Color3.fromRGB(v2, v3, v4)
	end

	return p
end

function PianoModelKeyHighlight.GetPlayerSynthesiaColors(instance)
	if not instance then
		return color, color
	end

	local currentColourHex = instance:GetAttribute("CurrentColourHex") or "#FFFFFF"
	local v = hexToColor3(instance:GetAttribute("WhiteSynthesiaHex") or currentColourHex, color)
	return v, (hexToColor3(instance:GetAttribute("BlackSynthesiaHex") or currentColourHex, v))
end

function PianoModelKeyHighlight.ApplySynthesiaColors(instance, vizColor, p)
	if not instance then
		return
	end

	if typeof(vizColor) ~= "Color3" then
		vizColor = color
	end

	local _ = typeof(p) == "Color3"

	instance:SetAttribute("VizColor", vizColor)
end

local function keyLooksBlack(part)
	if not (part and part:IsA("BasePart")) then
		return false
	end

	local isBlack = part:GetAttribute("IsBlack")

	if typeof(isBlack) == "boolean" then
		return isBlack
	end

	local color2 = part.Color
	return color2.R < 0.16 and color2.G < 0.16 and color2.B < 0.16
end

function PianoModelKeyHighlight.IsBlackModelKey(instance, p, part)
	if part and part:IsA("BasePart") then
		local isBlack = part:GetAttribute("IsBlack")

		if typeof(isBlack) == "boolean" then
			return isBlack
		end
	end

	local v = (math.floor(tonumber(p) or 1) - 1) % 12 + 1

	if instance and instance:GetAttribute("UseA0PhysicalKeyNumbers") == true then
		return v == 2 or v == 5 or v == 7 or v == 10 or v == 12
	end

	if not (part and part:IsA("BasePart")) then
		return v == 2 or v == 4 or v == 7 or v == 9 or v == 11
	end

	if not (part and part:IsA("BasePart")) then
		return false
	end

	local isBlack = part:GetAttribute("IsBlack")

	if typeof(isBlack) == "boolean" then
		return isBlack
	end

	local color2 = part.Color
	return color2.R < 0.16 and color2.G < 0.16 and color2.B < 0.16
end

function PianoModelKeyHighlight.FindKeyPart(instance, p)
	local keys = instance and instance:FindFirstChild("Keys")
	local v = tonumber(p)

	if not (keys and v) then
		return nil
	end

	local keys2 = keys:FindFirstChild("Keys")
	local v2

	if keys2 then
		v2 = { keys2, keys } or { keys }
	else
		v2 = { keys }
	end

	local useA0PhysicalKeyNumbers = instance:GetAttribute("UseA0PhysicalKeyNumbers") == true
	local v3

	if keys2 and useA0PhysicalKeyNumbers then
		v3 = { v }
	elseif keys2 then
		v3 = { v - 15, v, v + 15 }
	else
		v3 = { v, v - 15, v + 15 }
	end

	local set = {}

	for _, v4 in ipairs(v3) do
		local v5 = tostring((math.floor(v4 + 0.5)))

		if set[v5] then
			continue
		end

		set[v5] = true

		for _, v6 in ipairs(v2) do
			local part = v6:FindFirstChild(v5)

			if part and part:IsA("BasePart") then
				return part
			end
		end
	end

	return nil
end

function PianoModelKeyHighlight.GetHighlightColor(p, p2, p3, p4)
	local playerSynthesiaColors, v = PianoModelKeyHighlight.GetPlayerSynthesiaColors(p4)

	if p then
		PianoModelKeyHighlight.ApplySynthesiaColors(p, playerSynthesiaColors, v)
	end

	if PianoModelKeyHighlight.IsBlackModelKey(p, p2, p3) then
		return v
	end

	return playerSynthesiaColors
end

function PianoModelKeyHighlight.PrepareKeyHighlight(instance, p, p2)
	local keyPart = PianoModelKeyHighlight.FindKeyPart(instance, p)

	if not keyPart then
		return nil
	end

	local rainbowOwnerUserId = tonumber(instance:GetAttribute("RainbowOwnerUserId")) or 0

	if
		instance:GetAttribute("RainbowActive") == true
		and (rainbowOwnerUserId <= 0 or p2 and p2.UserId == rainbowOwnerUserId)
	then
		keyPart:SetAttribute("HighlightColor", nil)
		return keyPart
	end

	keyPart:SetAttribute("HighlightColor", PianoModelKeyHighlight.GetHighlightColor(instance, p, keyPart, p2))
	return keyPart
end

return PianoModelKeyHighlight