local Roact = require(script.Parent.Parent.Parent.Parent.Roact)

local v = {
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 255, 0),
	Color3.fromRGB(0, 0, 255),
	Color3.fromRGB(255, 255, 0),
	Color3.fromRGB(255, 0, 255),
	Color3.fromRGB(0, 255, 255)
}

local function getNextColor(p: number)
	while #v < p do
		p -= #v
	end

	return v[p]
end

local function createGridItems(p: number)
	local gridItems = {}

	for i = 1, p do
		local createElement = Roact.createElement
		local v2 = { Size = UDim2.new(1, 0, 0, 100), BackgroundColor3 = 0 }
		local children = gridItems
		local v3 = i

		while #v < v3 do
			v3 -= #v
		end

		v2.BackgroundColor3 = v[v3]
		table.insert(children, createElement("Frame", v2))
	end

	return gridItems
end

return createGridItems