local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Roact = require(MerchBooth.Packages.Roact)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local setViewedItem = require(MerchBooth.Actions.setViewedItem)
require(MerchBooth.Reducers.reducer)
local assets = require(MerchBooth.assets)

local extended = Roact.Component:extend("BackButton")

extended.defaultProps = { size = UDim2.fromOffset(0, 24) }

function extended.render(p)
	local props = p.props

	return Roact.createElement(
		"ImageButton",
		{
			Size = props.size,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			[Roact.Event.Activated] = props.onActivated
		},
		{
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Icon = Roact.createElement("ImageLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromOffset(24, 24),
				Image = assets.ChevronLeft,
				ImageColor3 = props.config.textColor,
				BackgroundTransparency = 1
			}),
			Label = Roact.createElement(ExperienceComponents.TextLabel, {
				LayoutOrder = 2,
				Text = props.text,
				TextColor3 = props.config.textColor,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.XY,
				TextYAlignment = Enum.TextYAlignment.Center,
				LineHeight = 1,
				TextSize = props.config.textSize,
				Font = props.config.textFont
			})
		}
	)
end

local function mapStateToProps(p)
	return { config = p.config }
end

local function mapDispatchToProps(callback)
	return {
		onActivated = function()
			callback(setViewedItem(nil))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)