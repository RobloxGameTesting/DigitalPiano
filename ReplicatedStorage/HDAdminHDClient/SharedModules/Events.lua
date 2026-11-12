local HDAdminMain = _G.HDAdminMain

local Events = {
	DoubleJumped = function(object, instance, ...)
		local v = 0
		local flag = true
		instance:GetPropertyChangedSignal("Jump"):Connect(function()
			if flag then
				flag = false
				v += 1

				if v == 4 then
					object:Fire()
				end

				wait()
				flag = true
				wait(0.2)
				v -= 1
			end
		end)
	end,
	EventName = function(_, _, ...) end
}

function Events.New(_, p, parent, ...)
	local bindableEvent = Instance.new("BindableEvent")
	Events[p](bindableEvent, parent, ...)
	bindableEvent.Parent = parent
	return bindableEvent
end

return Events