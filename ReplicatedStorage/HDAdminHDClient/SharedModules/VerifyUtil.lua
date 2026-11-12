local HDAdminMain = _G.HDAdminMain
local VerifyUtil = {}
VerifyUtil.KEY_MAX_CHARACTERS = 32

function VerifyUtil.isWithinMaxSize(p, p2): boolean
	local v = p2 or VerifyUtil.KEY_MAX_CHARACTERS
	return if VerifyUtil.processMaxSize(p, v) then true else false
end

function VerifyUtil.isDataStoreSafe(p): boolean
	local typeName = typeof(p)

	if typeName ~= "string" and typeName ~= "number" then
		return false
	end

	if utf8.len(p) then
		return HDAdminMain:GetModule("Demojify").process(p) == p
	end

	return false
end

function VerifyUtil.isStringSafe(value)
	if typeof(value) == "string" then
		return VerifyUtil.isDatastoreSafe(value)
	end

	return false
end

function VerifyUtil.processKey(p)
	local v = tostring(p)
	local typeName = typeof(p)

	if
		v == "nil"
		or typeName ~= "string" and typeName ~= "number"
		or not (#v <= VerifyUtil.KEY_MAX_CHARACTERS and VerifyUtil.isStringSafe(v))
	then
		return
	end

	return v
end

function VerifyUtil.processMaxSize(p, p2)
	local v = p2 or VerifyUtil.KEY_MAX_CHARACTERS * 2
	local success, result = pcall(function()
		return HDAdminMain.HttpService:JSONEncode(p)
	end)

	if success and result and #result <= v then
		return p
	end
end

function VerifyUtil.processBool(p): boolean
	return p == true
end

function VerifyUtil.processNumber(p)
	if not tonumber(p) then
		return
	end

	local v = tonumber(p)
	local rounded = HDAdminMain.modules.DataUtil.round(v, 4)

	return rounded > 10000000000 and 10000000000 or rounded
end

function VerifyUtil.processInstance(instance, p)
	if typeof(instance) ~= "Instance" then
		return
	end

	if instance.ClassName == p then
		return instance
	end

	instance:Destroy()
end

function VerifyUtil.processTable(p, p2)
	local function scan(items)
		if typeof(items) ~= "table" then
			return {}
		end

		for k, item in pairs(items) do
			local v = VerifyUtil.processKey(k)
			items[k] = nil

			if not (v and HDAdminMain.modules.Serializer.isValid(item)) then
				continue
			end

			items[v] = item

			if typeof(item) == "table" then
				scan(item)
			end
		end

		return items
	end

	local v = scan(p)

	if p2 and not VerifyUtil.isWithinMaxSize(v, p2) then
		return
	end

	return v
end

function VerifyUtil.processColorOnlyTable(p)
	local v = {}
	local function checkTable(items, p2)
		for k, item in pairs(items) do
			local v2 = VerifyUtil.processKey(k)
			local typeName = typeof(item)

			if v2 == nil then
				continue
			end

			local v3

			if typeName == "table" then
				v3 = {}
				checkTable(item, v3)
			elseif typeName == "Color3" then
				v3 = item
			else
				continue
			end

			p2[v2] = v3
		end
	end
	checkTable(p, v)
	return v
end

return VerifyUtil