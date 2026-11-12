local v = nil

local function callFunction(callback, _, ...)
	callback(...)
end

local function acquireRunnerThreadAndCallEventHandler(p, p2, ...)
	local v2 = v
	v = nil
	callFunction(p, p2, ...)

	v = v2
end

local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)

	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local class = {}
class.__index = class

function class.new(signal, fn)
	return (setmetatable({ _connected = true, _signal = signal, _fn = fn, _next = false }, class))
end

function class:Disconnect()
	if not self._connected then
		return
	end

	self._connected = false

	if self._signal._handlerListHead == self then
		self._signal._handlerListHead = self._next
		return
	end

	local v2 = self._signal._handlerListHead

	while v2 and v2._next ~= self do
		v2 = v2._next
	end

	if v2 then
		v2._next = self._next
	end
end
class.Destroy = class.Disconnect

setmetatable(class, {
	__index = function(_, p)
		error(("Attempt to get Connection::%s (not a valid member)"):format((tostring(p))), 2)
	end,
	__newindex = function(_, p, _)
		error(("Attempt to set Connection::%s (not a valid member)"):format((tostring(p))), 2)
	end
})

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return (setmetatable({ _handlerListHead = false }, Signal))
end

function Signal:Connect(p)
	local handlerListHead = class.new(self, p)

	if not self._handlerListHead then
		self._handlerListHead = handlerListHead

		return handlerListHead
	end

	handlerListHead._next = self._handlerListHead
	self._handlerListHead = handlerListHead
	return handlerListHead
end

function Signal:ConnectOnce(callback)
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end)
	return connection
end

Signal.Once = Signal.ConnectOnce

function Signal:DisconnectAll()
	self._handlerListHead = false
end
Signal.Destroy = Signal.DisconnectAll
Signal.destroy = Signal.DisconnectAll

function Signal:_FireBehaviour(p, ...)
	local joined = table.concat({ debug.info(3, "sl") }, " ")
	local v2 = self._handlerListHead
	local v3 = p and Signal.new()
	local count = 0
	local count2 = 0

	if p then
		local v4 = v2

		while v4 do
			if v4._connected then
				count += 1
			end

			v4 = v4._next
		end
	end

	while v2 do
		if v2._connected then
			if not v then
				v = coroutine.create(runEventHandlerInFreeThread)
			end

			local function fn(...)
				callFunction(v2._fn, joined, ...)

				if p then
					count2 += 1

					if count2 == count then
						v3:Fire()
						v3:Destroy()
						v3 = false
					end
				end
			end
			task.spawn(v, fn, joined, ...)
		end

		v2 = v2._next
	end

	if p then
		return v3
	end
end

function Signal:Fire(...)
	self:_FireBehaviour(false, ...)
end

function Signal:SpecialFire(...)
	return self:_FireBehaviour(true, ...)
end

function Signal:Wait()
	local thread = coroutine.running()
	local connection = nil
	connection = self:Connect(function(...)
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	return coroutine.yield()
end

return Signal