local byte = string.byte
local format = string.format
local char = string.char
local sub = string.sub
local insert = table.insert

local ByteRealm = {}

function ByteRealm.ToHex(_, value: string)
	return (value:gsub(".", function(value2)
		return format("%02X", byte(value2))
	end))
end

function ByteRealm.FromHex(_, value: string)
	return (value:gsub("..", function(p)
		return (char((tonumber(p, 16))))
	end))
end

function ByteRealm:HexInTable(value: string)
	local result = {}

	for i = 1, #value, 2 do
		local v = #result + 1
		result[v] = sub(value, i, i + 1)
	end

	return result
end

function ByteRealm.HexToDecimalTwo(_, p: string)
	local hexInTable = ByteRealm:HexInTable(p)
	local result = {}

	for k, v in next, hexInTable do
		result[k] = tonumber(v, 16)
	end

	return result
end

function ByteRealm.HexToDecimal(_, p: string)
	return (tonumber(p, 16))
end

function ByteRealm.BufferToDecimal(_, value: string)
	return byte(value)
end

function ByteRealm.AddSpacesToHex(_, value: string)
	local v = ""

	for i = 1, #value, 2 do
		v ..= value:sub(i, i + 1) .. " "
	end

	return v:sub(1, -2)
end

function ByteRealm.DecimalToHexadecimal(_, items)
	if typeof(items) ~= "table" then
		return format("%X", items)
	end

	local v = ""

	for _, item in next, items do
		v ..= format("%X", item)
	end

	return v
end

function ByteRealm.BufferToBerInteger(_, value: string, p: number)
	local v = p
	local v2 = 0

	while true do
		local v3 = string.byte(value, v)
		local v4 = v2 + v3 % 128

		if v3 < 127.5 then
			return v4, v + 1
		end

		if #value <= v then
			warn("BufferToBerInteger: no end-of-integer found")
			return 0, p
		end

		v += 1
		v2 = v4 * 128
	end
end

function ByteRealm.GetHeader(_, value: string)
	return (sub(value, 1, 4))
end

return ByteRealm