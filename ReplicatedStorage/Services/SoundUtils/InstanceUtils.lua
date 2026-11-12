local RunService = game:GetService("RunService")
local InstanceUtils = {}

function InstanceUtils.set(instance, value: string, p, flag: boolean?)
	assert(typeof(instance) == "Instance", `Expected an Instance, got {instance}`)
	assert(type(value) == "string", `Expected a string, got {value}`)

	if flag then
		instance[value] = p
	else
		local success, result = pcall(function()
			instance[value] = p
		end)

		if not success then
			warn(`Failed to set property {value} to {p} for Instance {instance}: {result}`)
		end
	end
end

function InstanceUtils.configure(instance, items, flag: boolean?)
	assert(typeof(instance) == "Instance", `Expected an Instance, got {instance}`)
	assert(type(items) == "table", `Expected a table, got {items}`)

	for k, item in pairs(items) do
		InstanceUtils.set(instance, k, item, flag)
	end
end

function InstanceUtils.construct(className: string, p, flag: boolean?)
	assert(type(className) == "string", `Expected a string, got '{className}'`)
	local v = nil

	if flag then
		local instance = Instance.new(className)
		InstanceUtils.configure(instance, p, flag)

		return instance
	else
		local success, result = pcall(Instance.new, className)

		if success then
			InstanceUtils.configure(result, p, flag)
			return result
		end

		warn(`Failed to create Instance of ClassName: '{className}' - '{result}'`)
		return v
	end
end

function InstanceUtils.nestedConfigure(instance, p)
	assert(typeof(instance) == "Instance", `Expected an Instance, got {instance}`)
	assert(type(p) == "table", `Expected a table, got {p}`)

	local className = instance.ClassName

	if p[className] then
		InstanceUtils.configure(instance, p[className])
	end

	local children = instance:GetChildren()

	if #children > 0 then
		for _, child in ipairs(children) do
			InstanceUtils.nestedConfigure(child, p)

			RunService.Heartbeat:Wait()
		end
	end
end

function InstanceUtils.acquirePropertiesFromArray(instance, items)
	assert(typeof(instance) == "Instance", `Expected an Instance, got {instance}`)
	assert(type(items) == "table", `Expected a table, got {items}`)
	local propertiesFromArray = {}

	for _, item in pairs(items) do
		local success, result = pcall(function()
			propertiesFromArray[item] = instance[item]
		end)

		if not success then
			warn(`Failed to store property '{item}' on Instance '{instance}': '{result}'`)
		end
	end

	return propertiesFromArray
end

return InstanceUtils