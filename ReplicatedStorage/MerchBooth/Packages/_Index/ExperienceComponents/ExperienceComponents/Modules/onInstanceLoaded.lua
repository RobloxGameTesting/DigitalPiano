local function onInstanceLoaded(instance, callback)
	task.spawn(function()
		while not instance:IsDescendantOf(game) do
			instance.AncestryChanged:Wait()
		end

		callback()
	end)
end

return onInstanceLoaded