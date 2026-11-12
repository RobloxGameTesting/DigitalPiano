local Players = game:GetService("Players")

local v = {}
local v2 = {}
local v3 = {}

task.spawn(function()
	while true do
		if #v3 > 0 then
			local v4 = table.remove(v3, 1)
			local success, result = pcall(function()
				return Players:GetNameFromUserIdAsync(v4)
			end)

			if success and result then
				v[v4] = result

				if v2[v4] then
					for _, v5 in ipairs(v2[v4]) do
						v5(result)
					end
				end
			else
				v[v4] = "User_" .. tostring(v4)

				if v2[v4] then
					for _, v5 in ipairs(v2[v4]) do
						v5(v[v4])
					end
				end
			end

			v2[v4] = nil

			task.wait(0.3)
		else
			task.wait(0.5)
		end
	end
end)
return {
	GetName = function(_, p, callback)
		local v4 = tonumber(p)

		if v4 then
			if v[v4] then
				if callback then
					callback(v[v4])
				end

				return v[v4]
			else
				local playerByUserId = Players:GetPlayerByUserId(v4)

				if playerByUserId then
					v[v4] = playerByUserId.Name

					if callback then
						callback(playerByUserId.Name)
					end

					return playerByUserId.Name
				else
					if callback then
						v2[v4] = v2[v4] or {}
						table.insert(v2[v4], callback)
					end

					local v5 = false

					for _, v6 in ipairs(v3) do
						if v6 == v4 then
							v5 = true
							break
						end
					end

					if not v5 then
						table.insert(v3, v4)
					end

					return "Loading..."
				end
			end
		else
			if callback then
				callback("Unknown")
			end

			return "Unknown"
		end
	end
}