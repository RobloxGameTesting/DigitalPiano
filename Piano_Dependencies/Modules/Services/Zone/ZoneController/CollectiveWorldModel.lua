local zonePlusWorldModel = nil
local RunService = game:GetService("RunService")
local CollectiveWorldModel = {}

function CollectiveWorldModel.setupWorldModel(_)
	if zonePlusWorldModel then
		return zonePlusWorldModel
	end

	local v = RunService:IsClient() and "ReplicatedStorage" or "ServerStorage"
	zonePlusWorldModel = Instance.new("WorldModel")
	zonePlusWorldModel.Name = "ZonePlusWorldModel"
	zonePlusWorldModel.Parent = game:GetService(v)
	return zonePlusWorldModel
end

function CollectiveWorldModel:_getCombinedResults(p, ...)
	local combinedResults = workspace[p](workspace, ...)

	if zonePlusWorldModel then
		local v = zonePlusWorldModel[p](zonePlusWorldModel, ...)

		for _, v2 in pairs(v) do
			table.insert(combinedResults, v2)
		end
	end

	return combinedResults
end

function CollectiveWorldModel:GetPartBoundsInBox(p, p2, p3)
	return self:_getCombinedResults("GetPartBoundsInBox", p, p2, p3)
end

function CollectiveWorldModel:GetPartBoundsInRadius(p, p2, p3)
	return self:_getCombinedResults("GetPartBoundsInRadius", p, p2, p3)
end

function CollectiveWorldModel:GetPartsInPart(p, p2)
	return self:_getCombinedResults("GetPartsInPart", p, p2)
end

return CollectiveWorldModel