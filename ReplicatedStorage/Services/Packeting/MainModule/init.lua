local Signal = require(script.Signal)
local Task = require(script.Task)
local Types = require(script.Types)

local ParametersToFunctions
local TableToFunctions
local ReadParameters
local WriteParameters
local Timeout
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Reads = Types.Reads
local Writes = Types.Writes
local Import = Types.Import
local Export = Types.Export
local Truncate = Types.Truncate
local Ended = Types.Ended
local NumberU8 = Reads.NumberU8
local numberU8 = Writes.NumberU8
local NumberU16 = Reads.NumberU16
local numberU16 = Writes.NumberU16
local class = {}
local v = {}
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local id = nil
local v6 = {
	Buffer = 0,
	BufferLength = 128,
	BufferOffset = 0,
	Instances = 0,
	InstancesOffset = 0
}
v6.Buffer = buffer.create(128)
v6.Instances = {}

local function Constructor(_, name: string, ...)
	local v7 = v[name]

	if v7 then
		return v7
	end

	local self = setmetatable({}, class)
	self.Name = name

	if RunService:IsServer() then
		self.Id = id
		self.OnServerEvent = Signal()
		v5:SetAttribute(name, id)
		v[id] = self
		id += 1
	else
		self.Id = v5:GetAttribute(name)
		self.OnClientEvent = Signal()

		if self.Id then
			v[self.Id] = self
		end
	end

	local reads, writes = ParametersToFunctions(table.pack(...))
	self.Reads = reads
	self.Writes = writes
	v[self.Name] = self
	return self
end

class.__index = class
class.Type = "Packet"

function class:Response(...)
	self.ResponseTimeout = self.ResponseTimeout or 10
	local responseReads, responseWrites = ParametersToFunctions(table.pack(...))
	self.ResponseReads = responseReads
	self.ResponseWrites = responseWrites
	return self
end

function class:Fire(...)
	if self.ResponseReads then
		if RunService:IsServer() then
			error("You must use FireClient(player)", 2)
		end

		local v7 = nil

		for _ = 1, 128 do
			v7 = v4[v4.Index]

			if not v7 then
				break
			end

			v4.Index = (v4.Index + 1) % 128
		end

		if v7 then
			error("Cannot have more than 128 yielded threads", 2)
		end

		Import(v6)
		numberU8(self.Id)
		numberU8(v4.Index)
		v4[v4.Index] = {
			Yielded = coroutine.running(),
			Timeout = Task:Delay(self.ResponseTimeout, Timeout, v4, v4.Index, self.ResponseTimeoutValue)
		}
		v4.Index = (v4.Index + 1) % 128
		WriteParameters(self.Writes, { ... })
		v6 = Export()
		return coroutine.yield()
	end

	Import(v6)
	numberU8(self.Id)
	WriteParameters(self.Writes, { ... })
	v6 = Export()
end

function class:FireClient(p, ...)
	if p.Parent == nil then
		return
	end

	if self.ResponseReads then
		local v7 = v3[p]

		if v7 == nil then
			v7 = { Index = 0 }
			v3[p] = v7
		end

		local v8 = nil

		for _ = 1, 128 do
			v8 = v7[v7.Index]

			if not v8 then
				break
			end

			v7.Index = (v7.Index + 1) % 128
		end

		if v8 then
			error("Cannot have more than 128 yielded threads", 2)
			return
		end

		Import(v2[p] or {
			Buffer = buffer.create(128),
			BufferLength = 128,
			BufferOffset = 0,
			Instances = {},
			InstancesOffset = 0
		})
		numberU8(self.Id)
		numberU8(v7.Index)
		v7[v7.Index] = {
			Yielded = coroutine.running(),
			Timeout = Task:Delay(self.ResponseTimeout, Timeout, v7, v7.Index, self.ResponseTimeoutValue)
		}
		v7.Index = (v7.Index + 1) % 128
		WriteParameters(self.Writes, { ... })
		v2[p] = Export()
		return coroutine.yield()
	end

	Import(v2[p] or {
		Buffer = buffer.create(128),
		BufferLength = 128,
		BufferOffset = 0,
		Instances = {},
		InstancesOffset = 0
	})
	numberU8(self.Id)
	WriteParameters(self.Writes, { ... })
	v2[p] = Export()
end

function class.Serialize(p, ...)
	Import({
		Buffer = buffer.create(128),
		BufferLength = 128,
		BufferOffset = 0,
		Instances = {},
		InstancesOffset = 0
	})
	WriteParameters(p.Writes, { ... })
	return Truncate()
end

function class.Deserialize(p, buf, options)
	Import({
		Buffer = buf,
		BufferLength = buffer.len(buf),
		BufferOffset = 0,
		Instances = options or {},
		InstancesOffset = 0
	})
	return ReadParameters(p.Reads)
end

ParametersToFunctions = function(list)
	local result = table.create(#list)
	local result2 = table.create(#list)

	for i, item in ipairs(list) do
		if type(item) == "table" then
			local v7, v8 = TableToFunctions(item)
			result[i] = v7
			result2[i] = v8
		else
			local read = Reads[item]
			local write = Writes[item]
			result[i] = read
			result2[i] = write
		end
	end

	return result, result2
end

TableToFunctions = function(list)
	if #list == 1 then
		local item = list[1]
		local v7, v8

		if type(item) == "table" then
			v7, v8 = TableToFunctions(item)
		else
			v7 = Reads[item]
			v8 = Writes[item]
		end

		return function()
			local numberU16_2 = NumberU16()
			local result = table.create(numberU16_2)

			for i = 1, numberU16_2 do
				result[i] = v7()
			end

			return result
		end, function(list2)
			numberU16(#list2)

			for _, item2 in list2 do
				v8(item2)
			end
		end
	else
		local v7 = {}

		for k, _ in list do
			table.insert(v7, k)
		end

		table.sort(v7)
		local v8 = table.create(#v7)
		local v9 = table.create(#v7)

		for k, v10 in v7 do
			local item = list[v10]

			if type(item) == "table" then
				local v11, v12 = TableToFunctions(item)
				v8[k] = v11
				v9[k] = v12
			else
				local read = Reads[item]
				local write = Writes[item]
				v8[k] = read
				v9[k] = write
			end
		end

		return function()
			local result = {}

			for k, v10 in v8 do
				result[v7[k]] = v10()
			end

			return result
		end, function(p)
			for k, v10 in v9 do
				v10(p[v7[k]])
			end
		end
	end
end

ReadParameters = function(list)
	local v7 = table.create(#list)

	for k, item in list do
		v7[k] = item()
	end

	return table.unpack(v7)
end

WriteParameters = function(items, p)
	for k, item in items do
		item(p[k])
	end
end

Timeout = function(p, p2: number, p3)
	local v7 = p[p2]
	task.defer(v7.Yielded, p3)
	p[p2] = nil
end

if RunService:IsServer() then
	v2 = {}
	v3 = {}
	id = 0
	v5 = Instance.new("RemoteEvent", script)

	local v7 = {}

	local thread = task.spawn(function()
		while true do
			coroutine.yield()

			if v6.BufferOffset > 0 then
				local buf = buffer.create(v6.BufferOffset)
				buffer.copy(buf, 0, v6.Buffer, 0, v6.BufferOffset)

				if v6.InstancesOffset == 0 then
					v5:FireAllClients(buf)
				else
					v5:FireAllClients(buf, v6.Instances)
					v6.InstancesOffset = 0
					table.clear(v6.Instances)
				end

				v6.BufferOffset = 0
			end

			for player, v8 in v2 do
				local buf = buffer.create(v8.BufferOffset)
				buffer.copy(buf, 0, v8.Buffer, 0, v8.BufferOffset)

				if v8.InstancesOffset == 0 then
					v5:FireClient(player, buf)
				else
					v5:FireClient(player, buf, v8.Instances)
				end
			end

			table.clear(v2)
			table.clear(v7)
		end
	end)

	local function fn(data, p, p2: number, ...)
		if data.OnServerInvoke == nil then
			if RunService:IsStudio() then
				warn("OnServerInvoke not found for packet:", data.Name, "discarding event:", ...)
			end
		else
			local v8 = { data.OnServerInvoke(p, ...) }

			if p.Parent == nil then
				return
			end

			Import(v2[p] or {
				Buffer = buffer.create(128),
				BufferLength = 128,
				BufferOffset = 0,
				Instances = {},
				InstancesOffset = 0
			})
			numberU8(data.Id)
			numberU8(p2 + 128)
			WriteParameters(data.ResponseWrites, v8)
			v2[p] = Export()
		end
	end

	local function fn2(p, buf: buffer, options)
		local v8 = (v7[p] or 0) + math.max(buffer.len(buf), 800)

		if v8 > 8000 then
			if RunService:IsStudio() then
				warn(p.Name, "is exceeding the data/rate limit; some events may be dropped")
			end
		else
			v7[p] = v8
			Import({
				Buffer = buf,
				BufferLength = buffer.len(buf),
				BufferOffset = 0,
				Instances = options or {},
				InstancesOffset = 0
			})

			while Ended() == false do
				local v9 = v[NumberU8()]

				if v9.ResponseReads then
					local numberU8_2 = NumberU8()

					if numberU8_2 < 128 then
						Task:Defer(fn, v9, p, numberU8_2, ReadParameters(v9.Reads))
					else
						numberU8_2 -= 128
						local v10 = v3[p][numberU8_2]

						if v10 then
							task.cancel(v10.Timeout)
							task.defer(v10.Yielded, ReadParameters(v9.ResponseReads))
							v3[p][numberU8_2] = nil
						elseif RunService:IsStudio() then
							warn(
								"Response thread not found for packet:",
								v9.Name,
								"discarding response:",
								ReadParameters(v9.ResponseReads)
							)
						else
							ReadParameters(v9.ResponseReads)
						end
					end
				else
					v9.OnServerEvent:Fire(p, ReadParameters(v9.Reads))
				end
			end
		end
	end

	v5.OnServerEvent:Connect(function(p, ...)
		local _, result = pcall(fn2, p, ...)

		if result and RunService:IsStudio() then
			warn(p.Name, result)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		v2[player] = nil
		v3[player] = nil
		v7[player] = nil
	end)

	RunService.Heartbeat:Connect(function(_)
		task.defer(thread)
	end)
else
	v4 = { Index = 0 }
	v5 = script:WaitForChild("RemoteEvent")
	local v7 = 0

	local thread = task.spawn(function()
		while true do
			coroutine.yield()

			if not (v6.BufferOffset > 0) then
				continue
			end

			local buf = buffer.create(v6.BufferOffset)
			buffer.copy(buf, 0, v6.Buffer, 0, v6.BufferOffset)

			if v6.InstancesOffset == 0 then
				v5:FireServer(buf)
			else
				v5:FireServer(buf, v6.Instances)
				v6.InstancesOffset = 0
				table.clear(v6.Instances)
			end

			v6.BufferOffset = 0
		end
	end)

	local function fn(data, p: number, ...)
		if data.OnClientInvoke == nil then
			warn("OnClientInvoke not found for packet:", data.Name, "discarding event:", ...)
			return
		end

		local v8 = { data.OnClientInvoke(...) }
		Import(v6)
		numberU8(data.Id)
		numberU8(p + 128)
		WriteParameters(data.ResponseWrites, v8)
		v6 = Export()
	end

	v5.OnClientEvent:Connect(function(buf: buffer, options)
		Import({
			Buffer = buf,
			BufferLength = buffer.len(buf),
			BufferOffset = 0,
			Instances = options or {},
			InstancesOffset = 0
		})

		while Ended() == false do
			local v8 = v[NumberU8()]

			if v8.ResponseReads then
				local numberU8_2 = NumberU8()

				if numberU8_2 < 128 then
					Task:Defer(fn, v8, numberU8_2, ReadParameters(v8.Reads))
				else
					numberU8_2 -= 128
					local v9 = v4[numberU8_2]

					if v9 then
						task.cancel(v9.Timeout)
						task.defer(v9.Yielded, ReadParameters(v8.ResponseReads))
						v4[numberU8_2] = nil
					else
						warn(
							"Response thread not found for packet:",
							v8.Name,
							"discarding response:",
							ReadParameters(v8.ResponseReads)
						)
					end
				end
			else
				v8.OnClientEvent:Fire(ReadParameters(v8.Reads))
			end
		end
	end)

	v5.AttributeChanged:Connect(function(attributeName)
		local v8 = v[attributeName]

		if v8 then
			if v8.Id then
				v[v8.Id] = nil
			end

			v8.Id = v5:GetAttribute(attributeName)

			if v8.Id then
				v[v8.Id] = v8
			end
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		v7 += dt

		if v7 > 1 / 60 then
			v7 %= 1 / 60
			task.defer(thread)
		end
	end)
end

return (setmetatable(Types.Types, { __call = Constructor }))