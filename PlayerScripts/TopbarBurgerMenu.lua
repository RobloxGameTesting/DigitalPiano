local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Icon = require(ReplicatedStorage:WaitForChild("Services"):WaitForChild("Icon"))

local function openShopIfNeeded()
	local success, result = pcall(function()
		return require(ReplicatedStorage:WaitForChild("MerchBooth"))
	end)

	if not success or type(result) ~= "table" then
		return
	end

	local success2, result2 = pcall(function()
		return result.isMerchBoothOpen()
	end)

	if success2 and result2 then
		return
	end

	ReplicatedStorage:SetAttribute("PianoShopRequestedCategory", "")
	pcall(function()
		result.openMerchBooth()
	end)
end

local function fireAction(childName, ...)
	local bindableEvent = ReplicatedStorage:FindFirstChild(childName) or ReplicatedStorage:WaitForChild(childName, 3)

	if bindableEvent and bindableEvent:IsA("BindableEvent") then
		bindableEvent:Fire(...)
	end

	if childName == "OpenShop" then
		task.delay(0.35, openShopIfNeeded)
	end
end

local oneClick = Icon.new():setName("TopbarDropdownShop"):setLabel("Shop"):bindEvent("selected", function()
	fireAction("OpenShop")
end):oneClick()

local oneClick2 = Icon.new():setName("TopbarDropdownSheets"):setLabel("Sheets"):bindEvent("selected", function()
	fireAction("OpenCommunitySheets")
end):oneClick()

Icon.new():setName("TopbarBurgerMenu"):setImage("rbxassetid://101017275839241"):setImageScale(0.85):align("Left"):setOrder(1):modifyTheme({
	{ "Widget", "MinimumWidth", 50 },
	{ "Dropdown", "MaxIcons", 3 }
}):modifyChildTheme({ "Widget", "MinimumWidth", 158 }):setDropdown({ oneClick, oneClick2 })