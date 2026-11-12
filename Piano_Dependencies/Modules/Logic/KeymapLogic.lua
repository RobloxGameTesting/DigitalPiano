local KeymapLogic = {}

KeymapLogic.CustomKeyBinds = {}

local v = {
	["!"] = true,
	["@"] = true,
	["$"] = true,
	["%"] = true,
	["^"] = true,
	["*"] = true,
	["("] = true
}

local function clampTarget(value) -- 6 equivalent calls inferred from this helper
	if type(value) ~= "number" then
		return nil
	end

	local v2 = math.floor(value)
	return if not (v2 < 1 or v2 > 61) then v2 else nil
end

local function isLegacyCompensatedShiftBind(p, p2): boolean -- 1 equivalent call inferred from this helper
	return v[("1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"):sub(p, p)] == true and p2 == p - 1
end

function KeymapLogic:SetKeyBind(value, value2)
	local v2 = clampTarget(value) -- inferred equivalent call
	local v3 = clampTarget(value2) -- inferred equivalent call

	if not v2 then
		return
	end

	if v3 and v3 ~= v2 then
		KeymapLogic.CustomKeyBinds[v2] = v3
	else
		KeymapLogic.CustomKeyBinds[v2] = nil
	end
end

function KeymapLogic.ApplySerializedKeyBinds(_, items)
	KeymapLogic.CustomKeyBinds = {}

	if type(items) ~= "table" then
		return
	end

	for k, item in pairs(items) do
		local v2 = clampTarget(tonumber(k)) -- inferred equivalent call
		local v3 = clampTarget(tonumber(item)) -- inferred equivalent call

		if not v2 or not v3 or isLegacyCompensatedShiftBind(v2, v3) then -- inferred equivalent call
			continue
		end

		KeymapLogic:SetKeyBind(v2, v3)
	end
end

function KeymapLogic.GetSerializedKeyBinds(_)
	local serializedKeyBinds = {}

	for k, customKeyBind in pairs(KeymapLogic.CustomKeyBinds) do
		local v2 = clampTarget(k) -- inferred equivalent call
		local v3 = clampTarget(customKeyBind) -- inferred equivalent call

		if v2 and v3 and v2 ~= v3 then
			serializedKeyBinds[tostring(v2)] = v3
		end
	end

	return serializedKeyBinds
end

function KeymapLogic.GetMappedNote(_, p)
	return KeymapLogic.CustomKeyBinds[p] or p
end

function KeymapLogic.ResetAllKeyBinds(_)
	KeymapLogic.CustomKeyBinds = {}
end

function KeymapLogic.HasCustomBind(_, p): boolean
	return KeymapLogic.CustomKeyBinds[p] ~= nil
end

function KeymapLogic.IsBlack(_, p): boolean
	local v2 = (p - 1) % 12 + 1
	return v2 == 2 or v2 == 4 or v2 == 7 or v2 == 9 or v2 == 11
end

function KeymapLogic.PianoKeyCodes(_)
	local v2 = {
		Enum.KeyCode.Zero,
		Enum.KeyCode.One,
		Enum.KeyCode.Two,
		Enum.KeyCode.Three,
		Enum.KeyCode.Four,
		Enum.KeyCode.Five,
		Enum.KeyCode.Six,
		Enum.KeyCode.Seven,
		Enum.KeyCode.Eight,
		Enum.KeyCode.Nine
	}

	for i = 97, 122 do
		table.insert(v2, Enum.KeyCode[string.upper((string.char(i)))])
	end

	return table.unpack(v2)
end

function KeymapLogic.VelocityKeyCodes(_)
	local result = {}

	for i = 0, 100, 3.2 do
		table.insert(result, (math.round(i)))
	end

	return result
end

KeymapLogic.Piano88KeyCodes = {
	0,
	-1,
	-2,
	-3,
	-4,
	-5,
	-6,
	-7,
	-8,
	-9,
	-10,
	-11,
	-12,
	-13,
	-14,
	62,
	63,
	64,
	65,
	66,
	67,
	68,
	69,
	70,
	71,
	72,
	73,
	74
}

return KeymapLogic