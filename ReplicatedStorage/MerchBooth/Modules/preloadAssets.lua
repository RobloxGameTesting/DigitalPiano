local ContentProvider = game:GetService("ContentProvider")
local function flattenValues(items, options)
	local result = options or {}

	for _, item in pairs(items) do
		if typeof(item) == "table" then
			flattenValues(item, result)
		else
			table.insert(result, item)
		end
	end

	return result
end

return function(p)
	local v = p or ContentProvider

	local function preloadAssets(p2)
		local v2 = flattenValues(p2)

		task.spawn(function()
			v:PreloadAsync(v2)
		end)
	end

	return preloadAssets
end