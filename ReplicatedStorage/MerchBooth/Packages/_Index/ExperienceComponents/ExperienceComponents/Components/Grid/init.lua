local Roact = require(script.Parent.Parent.Parent.Roact)

local extended = Roact.Component:extend("Grid")

extended.defaultProps = { items = {}, columns = 2, padding = UDim.new() }

function extended.render(p)
	local props = p.props
	local v = math.ceil(#props.items / props.columns)

	local children = {
		Layout = Roact.createElement("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
	}

	for i = 1, v do
		local children2 = {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal
			})
		}

		for j = 1, props.columns do
			local layoutOrder = (i - 1) * props.columns + j
			local item = props.items[layoutOrder]

			if item then
				children2["Item" .. layoutOrder] = Roact.createElement("Frame", {
					LayoutOrder = layoutOrder,
					Size = UDim2.fromScale(1 / props.columns, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1
				}, {
					Padding = props.padding and Roact.createElement("UIPadding", {
						PaddingTop = props.padding,
						PaddingRight = props.padding,
						PaddingLeft = props.padding,
						PaddingBottom = props.padding
					}),
					Item = item
				})
			end
		end

		children["Row" .. i] = Roact.createElement(
			"Frame",
			{
				LayoutOrder = i,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1
			},
			children2
		)
	end

	return Roact.createElement(
		"Frame",
		{
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1
		},
		children
	)
end

return extended