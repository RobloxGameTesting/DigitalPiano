local Thread
local Task = {}
local threads = {}

Task.Type = "Task"

function Task.Spawn(_, p, ...)
	return task.spawn(table.remove(threads) or task.spawn(Thread), p, ...)
end

function Task.Defer(_, p, ...)
	return task.defer(table.remove(threads) or task.spawn(Thread), p, ...)
end

function Task.Delay(_, duration, p, ...)
	return task.delay(duration, table.remove(threads) or task.spawn(Thread), p, ...)
end

local function Call(callback, ...)
	callback(...)
	table.insert(threads, coroutine.running())
end

Thread = function()
	while true do
		Call(coroutine.yield())
	end
end

return Task