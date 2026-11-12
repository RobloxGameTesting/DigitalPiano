local MerchBooth = script:FindFirstAncestor("MerchBooth")

require(MerchBooth.Reducers.reducer)

local UiStatesEvents = {
	["merchBoothOpened"] = Instance.new("BindableEvent"),
	merchBoothClosed = Instance.new("BindableEvent"),
	catalogViewOpened = Instance.new("BindableEvent"),
	catalogViewClosed = Instance.new("BindableEvent"),
	itemViewOpened = Instance.new("BindableEvent"),
	itemViewClosed = Instance.new("BindableEvent")
}

function UiStatesEvents:connect()
	return self.changed:connect(function(p, p2)
		local v = not p2.ui.merchBoothOpen
		local v2 = p2.ui.merchBoothOpen and p2.ui.viewedItemId == nil
		local v3 = p2.ui.merchBoothOpen and p2.ui.viewedItemId ~= nil

		local v4 = not p.ui.merchBoothOpen
		local v5 = p.ui.merchBoothOpen and p.ui.viewedItemId == nil
		local v6 = p.ui.merchBoothOpen and p.ui.viewedItemId ~= nil

		if not v and v4 then
			UiStatesEvents.merchBoothClosed:Fire()
		end

		if v and not v4 then
			UiStatesEvents.merchBoothOpened:Fire()
		end

		if not v2 and v5 then
			UiStatesEvents.catalogViewOpened:Fire()
		end

		if v2 and not v5 then
			UiStatesEvents.catalogViewClosed:Fire()
		end

		if not v3 and v6 then
			UiStatesEvents.itemViewOpened:Fire(p.ui.viewedItemId)
		end

		if v3 and not v6 then
			UiStatesEvents.itemViewClosed:Fire(p2.ui.viewedItemId)
		end
	end)
end

return UiStatesEvents