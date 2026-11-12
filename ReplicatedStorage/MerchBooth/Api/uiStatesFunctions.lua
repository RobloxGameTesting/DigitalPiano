local RunService = game:GetService("RunService")

local MerchBooth = script:FindFirstAncestor("MerchBooth")

local t = require(MerchBooth.Packages.t)
local setMerchBoothVisible = require(MerchBooth.Actions.setMerchBoothVisible)
local setViewedItem = require(MerchBooth.Actions.setViewedItem)
local setCatalogButtonVisible = require(MerchBooth.Actions.setCatalogButtonVisible)
require(MerchBooth.Reducers.reducer)
local UiStatesFunctions = {}

function UiStatesFunctions.openMerchBooth(object)
	local function openMerchBooth()
		assert(RunService:IsClient(), "MerchBooth.openMerchBooth must be called on the client")

		object:dispatch(setViewedItem(nil))
		object:dispatch(setMerchBoothVisible(true))
	end

	return openMerchBooth
end

function UiStatesFunctions.openItemView(object)
	local function openItemView(p: number)
		assert(RunService:IsClient(), "MerchBooth.openItemView must be called on the client")
		assert(t.number(p), "Bad argument #1 to MerchBooth.openItemView: expected a number")

		object:dispatch(setViewedItem(p))
		object:dispatch(setMerchBoothVisible(true))
	end

	return openItemView
end

function UiStatesFunctions.closeMerchBooth(object)
	local function closeMerchBooth()
		assert(RunService:IsClient(), "MerchBooth.closeMerchBooth must be called on the client")

		object:dispatch(setMerchBoothVisible(false))
	end

	return closeMerchBooth
end

function UiStatesFunctions.toggleCatalogButton(object)
	local function toggleCatalogButton(flag: boolean)
		assert(RunService:IsClient(), "MerchBooth.toggleCatalogButton must be called on the client")
		assert(t.boolean(flag), "Bad argument #1 to MerchBooth.toggleCatalogButton: expected a boolean")

		object:dispatch(setCatalogButtonVisible(flag))
	end

	return toggleCatalogButton
end

function UiStatesFunctions.isMerchBoothOpen(object)
	local function isMerchBoothOpen()
		assert(RunService:IsClient(), "MerchBooth.isMerchBoothOpen must be called on the client")

		local state = object:getState()
		return state.ui.merchBoothOpen, state.ui.viewedItemId
	end

	return isMerchBoothOpen
end

function UiStatesFunctions.isMerchBoothEnabled(object)
	local function isMerchBoothEnabled()
		assert(RunService:IsClient(), "MerchBooth.isMerchBoothEnabled must be called on the client")

		return object:getState().ui.isMerchBoothEnabled
	end

	return isMerchBoothEnabled
end

return UiStatesFunctions