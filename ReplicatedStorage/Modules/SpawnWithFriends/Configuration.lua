local SpawnWithFriends = script:FindFirstAncestor("SpawnWithFriends")

local Cryo = require(SpawnWithFriends.Packages.Cryo)

return {
	new = function(p, p2)
		local joined = Cryo.Dictionary.join(p, {})

		local v = {
			initialValues = joined,
			values = joined,
			validate = p2 or function() end
		}

		v.changed = Instance.new("BindableEvent")

		function v.getValues()
			return v.values
		end

		function v.configure(p3)
			local v2, v3 = v.validate(p3)

			if not v2 then
				error(v3)
			end

			v.values = Cryo.Dictionary.join(v.values, p3)
			v.changed:Fire(v.values)
		end

		function v.reset()
			v.values = Cryo.Dictionary.join(v.initialValues, {})
			v.changed:Fire(v.values)
		end

		return v
	end
}