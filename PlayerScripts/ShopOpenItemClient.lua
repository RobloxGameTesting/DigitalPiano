local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MerchBooth = ReplicatedStorage:WaitForChild("MerchBooth")
local module = require(MerchBooth)
local clientStore = require(MerchBooth.Modules.clientStore)
local openShopItem = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes"):WaitForChild("OpenShopItem")

local OpenShopItemLocal = ReplicatedStorage:FindFirstChild("OpenShopItemLocal")

if not (OpenShopItemLocal and OpenShopItemLocal:IsA("BindableEvent")) then
	if OpenShopItemLocal then
		OpenShopItemLocal:Destroy()
	end

	OpenShopItemLocal = Instance.new("BindableEvent")
	OpenShopItemLocal.Name = "OpenShopItemLocal"
	OpenShopItemLocal.Parent = ReplicatedStorage
end

local function openShopItem2(p)
	local v = math.floor(tonumber(p) or 0)

	if v <= 0 then
		return
	end

	ReplicatedStorage:SetAttribute("PianoShopRequestedCategory", "Gamepasses")
	module.openItemView(v)
	clientStore:flush()
end

openShopItem.OnClientEvent:Connect(openShopItem2)
OpenShopItemLocal.Event:Connect(openShopItem2)