local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)
local Cryo = require(MerchBooth.Packages.Cryo)
require(MerchBooth.types)
local setViewedItem = require(MerchBooth.Actions.setViewedItem)
local removeItemInfo = require(MerchBooth.Actions.removeItemInfo)
local setMerchBoothVisible = require(MerchBooth.Actions.setMerchBoothVisible)
local setMerchBoothFocused = require(MerchBooth.Actions.setMerchBoothFocused)
local setCatalogButtonVisible = require(MerchBooth.Actions.setCatalogButtonVisible)
local setCatalogFilter = require(MerchBooth.Actions.setCatalogFilter)
local setCatalogSortFunction = require(MerchBooth.Actions.setCatalogSortFunction)
local setEquipModalVisible = require(MerchBooth.Actions.setEquipModalVisible)
local setMerchBoothEnabled = require(MerchBooth.Actions.setMerchBoothEnabled)

return (Rodux.createReducer({
	merchBoothOpen = false,
	isMerchBoothFocused = false,
	catalogButtonVisible = true,
	catalogSortFunction = function(p, p2): boolean
		return p.title < p2.title
	end,
	isEquipModalShown = false,
	isMerchBoothEnabled = false
}, {
	[setMerchBoothEnabled.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { isMerchBoothEnabled = p2.isEnabled })
	end,
	[setViewedItem.name] = function(p, p2)
		return Cryo.Dictionary.join(p, {
			viewedItemId = p2.assetId or Cryo.None
		})
	end,
	[removeItemInfo.name] = function(p, p2)
		if p.viewedItemId == tonumber(p2.itemId) then
			return Cryo.Dictionary.join(p, { viewedItemId = Cryo.None })
		end

		return p
	end,
	[setMerchBoothVisible.name] = function(p, p2)
		if p2.visible then
			return Cryo.Dictionary.join(p, { merchBoothOpen = true, isMerchBoothFocused = true })
		end

		return Cryo.Dictionary.join(p, {
			merchBoothOpen = false,
			isMerchBoothFocused = false,
			catalogFilter = Cryo.None,
			viewedItemId = Cryo.None
		})
	end,
	[setMerchBoothFocused.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { isMerchBoothFocused = p2.isFocused })
	end,
	[setCatalogButtonVisible.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { catalogButtonVisible = p2.visible })
	end,
	[setEquipModalVisible.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { isEquipModalShown = p2.visible })
	end,
	[setCatalogFilter.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { catalogFilter = p2.filter })
	end,
	[setCatalogSortFunction.name] = function(p, p2)
		return Cryo.Dictionary.join(p, { catalogSortFunction = p2.sort })
	end
}))