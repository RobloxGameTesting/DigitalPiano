local MerchBooth = script:FindFirstAncestor("MerchBooth")

local ExperienceComponents = require(MerchBooth.Packages.ExperienceComponents)
local Cryo = require(MerchBooth.Packages.Cryo)
local RoactRodux = require(MerchBooth.Packages.RoactRodux)
local Roact = require(MerchBooth.Packages.Roact)
local styles = require(MerchBooth.styles)
local setCatalogFilter = require(MerchBooth.Actions.setCatalogFilter)
require(MerchBooth.Reducers.reducer)
require(MerchBooth.types)

local extended = Roact.Component:extend("CatalogFilters")

extended.defaultProps = { filters = {}, applyButtonHeight = 48 }

local v = { text = "All Items", value = Roact.None }

function extended:init()
	function self.createOptions()
		local props = self.props

		local sorted = Cryo.List.sort(props.filters, function(p, p2): boolean
			return p.text < p2.text
		end)

		table.insert(sorted, 1, v)

		return sorted
	end

	function self.onSubmit(p)
		local props = self.props

		props.setCatalogFilter(p.value)

		if props.onFilterSelected then
			props.onFilterSelected(p)
		end
	end
end

function extended.render(props)
	local props2 = props.props
	local options = props.createOptions()
	local default

	if props2.catalogFilter then
		default = Cryo.List.filter(options, function(p): boolean
			return p.value == props2.catalogFilter
		end)[1]
	else
		default = options[1]
	end

	return Roact.createElement("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, {
		Layout = Roact.createElement("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.Padding,
			PaddingRight = styles.Padding,
			PaddingBottom = styles.Padding,
			PaddingLeft = styles.Padding
		}),
		Title = Roact.createElement(ExperienceComponents.TextLabel, {
			LayoutOrder = 1,
			Text = "Filter By",
			Font = props2.config.headerFont,
			TextSize = props2.config.headerTextSize,
			TextColor3 = props2.config.textColor,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Size = UDim2.new(1, 0, 0, props2.applyButtonHeight)
		}),
		Form = Roact.createElement(ExperienceComponents.MultiSelectForm, {
			layoutOrder = 2,
			options = options,
			default = default,
			submitText = "Apply",
			applyButtonHeight = props2.applyButtonHeight,
			size = UDim2.new(1, 0, 1, -props2.applyButtonHeight),
			onSubmit = props.onSubmit,
			buttonColor = props2.config.buttonColor,
			inactiveButtonColor = props2.config.inactiveButtonColor,
			buttonTextColor = props2.config.buttonTextColor,
			textSize = props2.config.textSize,
			font = props2.config.textFont,
			buttonFont = props2.config.headerFont,
			cornerRadius = props2.config.cornerRadiusSmall
		})
	})
end

local function mapStateToProps(p)
	return { catalogFilter = p.ui.catalogFilter, config = p.config }
end

local function mapDispatchToProps(callback)
	return {
		setCatalogFilter = function(p)
			callback(setCatalogFilter(p))
		end
	}
end

return RoactRodux.connect(mapStateToProps, mapDispatchToProps)(extended)