local Task = require(script.Parent.Task)

local class = {}
local class2 = {}

local function Constructor()
	local self = setmetatable({}, class)
	self.Previous = self
	self.Next = self
	return self
end

class.__index = class
class.Type = "Signal"

function class:Connect(p)
	local object = setmetatable({}, class2)
	object.Previous = self.Previous
	object.Next = self
	object.Once = false
	object.Function = p
	self.Previous.Next = object
	self.Previous = object
	return object
end

function class:Once(p)
	local object = setmetatable({}, class2)
	object.Previous = self.Previous
	object.Next = self
	object.Once = true
	object.Function = p
	self.Previous.Next = object
	self.Previous = object
	return object
end

function class:Wait()
	local object = setmetatable({}, class2)
	object.Previous = self.Previous
	object.Next = self
	object.Once = true
	object.Thread = coroutine.running()
	self.Previous.Next = object
	self.Previous = object
	return coroutine.yield()
end

function class.Fire(p, ...)
	local nextNode = p.Next

	while nextNode.Type == "Connection" do
		if nextNode.Function then
			Task:Defer(nextNode.Function, ...)
		else
			task.defer(nextNode.Thread, ...)
		end

		if nextNode.Once then
			nextNode.Previous.Next = nextNode.Next
			nextNode.Next.Previous = nextNode.Previous
		end

		nextNode = nextNode.Next
	end
end

class2.__index = class2
class2.Type = "Connection"

function class2.Disconnect(p)
	p.Previous.Next = p.Next
	p.Next.Previous = p.Previous
end

return Constructor