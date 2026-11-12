local MerchBooth = script:FindFirstAncestor("MerchBooth")

require(MerchBooth.Reducers.itemInfo)
require(MerchBooth.Reducers.reducer)

local ItemEvents = {}

ItemEvents.itemAdded = Instance.new("BindableEvent")

ItemEvents.itemRemoved = Instance.new("BindableEvent")

function ItemEvents:connect(callback)
	return self.changed:connect(function(p, p2)
		local v = callback(p2)
		local v2 = callback(p)

		if v == v2 then
			return
		end

		for k, v3 in pairs(v2) do
			if not v[k] then
				ItemEvents.itemAdded:Fire(tonumber(k), v3)
			end
		end

		for k, _ in pairs(v) do
			if not v2[k] then
				ItemEvents.itemRemoved:Fire((tonumber(k)))
			end
		end
	end)
end

return ItemEvents