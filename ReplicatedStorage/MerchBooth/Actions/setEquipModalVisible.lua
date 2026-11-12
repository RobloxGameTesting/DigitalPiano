local MerchBooth = script:FindFirstAncestor("MerchBooth")

local Rodux = require(MerchBooth.Packages.Rodux)

local function setEquipModalVisible(visible: boolean)
	return { visible = visible }
end

return Rodux.makeActionCreator(script.Name, setEquipModalVisible)