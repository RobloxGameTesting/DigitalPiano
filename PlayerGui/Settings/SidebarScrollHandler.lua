local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
local sideBar = script.Parent:WaitForChild("Settings"):WaitForChild("Center"):WaitForChild("SideBar")

local v = {
	"General",
	"Audio",
	"Privacy",
	"Lighting",
	"Teams",
	"Keybinds",
	"Notebinds",
	"ChatTags",
	"Title"
}

local function findCategory(childName, instance) -- 2 equivalent calls inferred from this helper
	return sideBar:FindFirstChild(childName) or instance and instance:FindFirstChild(childName)
end

local function waitForRuntimeCategories()
	local categoryScroll = sideBar:FindFirstChild("CategoryScroll")

	for _, childName in ipairs(v) do
		if not findCategory(childName, categoryScroll) then -- inferred equivalent call
			sideBar:WaitForChild(childName, 5)
		end
	end
end

local function getOrCreateScroll()
	local categoryScroll = sideBar:FindFirstChild("CategoryScroll")

	if categoryScroll and categoryScroll:IsA("ScrollingFrame") then
		return categoryScroll
	end

	if categoryScroll then
		categoryScroll:Destroy()
	end

	local categoryScroll2 = Instance.new("ScrollingFrame")
	categoryScroll2.Name = "CategoryScroll"
	categoryScroll2.BackgroundTransparency = 1
	categoryScroll2.BorderSizePixel = 0
	categoryScroll2.Position = UDim2.fromOffset(0, 0)
	categoryScroll2.Size = UDim2.fromScale(1, 1)
	categoryScroll2.CanvasSize = UDim2.fromOffset(0, 0)
	categoryScroll2.AutomaticCanvasSize = Enum.AutomaticSize.Y
	categoryScroll2.ScrollBarThickness = 4
	categoryScroll2.ScrollBarImageColor3 = Color3.fromRGB(90, 105, 125)
	categoryScroll2.ScrollingDirection = Enum.ScrollingDirection.Y
	categoryScroll2.Active = true
	categoryScroll2.ClipsDescendants = true
	categoryScroll2.ZIndex = sideBar.ZIndex + 1
	categoryScroll2.Parent = sideBar
	return categoryScroll2
end

local function raiseCategoryZIndex(folder, zIndex)
	folder.ZIndex = zIndex

	for _, guiObject in ipairs(folder:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = math.max(guiObject.ZIndex, zIndex + 1)
		end
	end
end

local function setupScrollableSidebar()
	waitForRuntimeCategories()
	local scroll = getOrCreateScroll()

	local uiListLayout = scroll:FindFirstChildOfClass("UIListLayout")
		or sideBar:FindFirstChildOfClass("UIListLayout")
		or Instance.new("UIListLayout")
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.Parent = scroll

	local uiPadding = scroll:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 4)
	uiPadding.PaddingBottom = UDim.new(0, 4)
	uiPadding.Parent = scroll

	for _, v2 in ipairs(v) do
		local category = findCategory(v2, scroll) -- inferred equivalent call

		if not (category and category:IsA("GuiObject")) then
			continue
		end

		category.Parent = scroll
		category.Size = UDim2.new(1, -8, 0, 50)
		raiseCategoryZIndex(category, scroll.ZIndex + 1)
	end

	sideBar.ChildAdded:Connect(function(guiObject)
		if guiObject:IsA("GuiObject") and guiObject ~= scroll then
			guiObject.Parent = scroll
			guiObject.Size = UDim2.new(1, -8, 0, 50)
			raiseCategoryZIndex(guiObject, scroll.ZIndex + 1)
		end
	end)
end

task.defer(setupScrollableSidebar)

ClientDebugConfig.Print("[SettingsSidebarScroll] Initialized")