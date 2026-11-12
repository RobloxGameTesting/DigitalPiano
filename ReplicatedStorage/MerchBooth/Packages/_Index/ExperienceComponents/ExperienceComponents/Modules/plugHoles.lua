local function plugHoles(list)
	local result = {}

	for i = 1, #list do
		if list[i] ~= nil then
			table.insert(result, list[i])
		end
	end

	return result
end

return plugHoles