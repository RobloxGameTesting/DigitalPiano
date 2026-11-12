local enums = require(script.enums)
local addItemAsync = require(script.Api.addItemAsync)
local removeItem = require(script.Api.removeItem)
local addProximityButton = require(script.Api.addProximityButton)
local removeProximityButton = require(script.Api.removeProximityButton)
local configure = require(script.Api.configure)
local resetConfiguration = require(script.Api.resetConfiguration)
local getItems = require(script.Api.getItems)
local setCatalogSort = require(script.Api.setCatalogSort)
local setEnabled = require(script.Api.setEnabled)
local setControlKeyCodes = require(script.Api.setControlKeyCodes)
local uiStatesFunctions = require(script.Api.uiStatesFunctions)
local uiStatesEvents = require(script.Api.uiStatesEvents)
local itemEvents = require(script.Api.itemEvents)
local serverStore = require(script.Modules.serverStore)
local clientStore = require(script.Modules.clientStore)

local MerchBooth = {
	addItemAsync = addItemAsync(serverStore),
	removeItem = removeItem(serverStore),
	addProximityButton = addProximityButton(serverStore),
	removeProximityButton = removeProximityButton(serverStore),
	configure = configure(clientStore),
	resetConfiguration = resetConfiguration(clientStore),
	setCatalogSort = setCatalogSort(clientStore),
	setEnabled = setEnabled(clientStore),
	setControlKeyCodes = setControlKeyCodes(clientStore),
	openMerchBooth = uiStatesFunctions.openMerchBooth(clientStore),
	openItemView = uiStatesFunctions.openItemView(clientStore),
	closeMerchBooth = uiStatesFunctions.closeMerchBooth(clientStore),
	toggleCatalogButton = uiStatesFunctions.toggleCatalogButton(clientStore),
	isMerchBoothOpen = uiStatesFunctions.isMerchBoothOpen(clientStore),
	isMerchBoothEnabled = uiStatesFunctions.isMerchBoothEnabled(clientStore),
	merchBoothOpened = uiStatesEvents.merchBoothOpened.Event,
	merchBoothClosed = uiStatesEvents.merchBoothClosed.Event,
	catalogViewOpened = uiStatesEvents.catalogViewOpened.Event,
	catalogViewClosed = uiStatesEvents.catalogViewClosed.Event,
	itemViewOpened = uiStatesEvents.itemViewOpened.Event,
	itemViewClosed = uiStatesEvents.itemViewClosed.Event,
	getItems = getItems(serverStore, clientStore),
	itemAdded = itemEvents.itemAdded.Event,
	itemRemoved = itemEvents.itemRemoved.Event,
	Controls = enums.Controls
}

MerchBooth.openCatalogView = MerchBooth.openMerchBooth

return MerchBooth