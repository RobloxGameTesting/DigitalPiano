local MonetizationConfig = require(script.Parent:WaitForChild("MonetizationConfig"))

local DailyRewardConfig = {}
DailyRewardConfig.COOLDOWN_SECONDS = 86400
DailyRewardConfig.MISS_GRACE_SECONDS = 172800
DailyRewardConfig.MAX_STORED_SKIP_CREDITS = 1
DailyRewardConfig.TOPBAR_LABEL = "Login Rewards"
DailyRewardConfig.TOPBAR_ICON_IMAGE_ID = 131085945035716
DailyRewardConfig.DAYS_PER_CYCLE = 7
DailyRewardConfig.MAX_CYCLES = 4
DailyRewardConfig.REWARDS = {}
local v = {
	"rbxassetid://99355613240837",
	"rbxassetid://98072113635742",
	"rbxassetid://131355883363329",
	"rbxassetid://77346597239372",
	"rbxassetid://127477240743790",
	"rbxassetid://119078178611349",
	"rbxassetid://134705466103551"
}

for i, list in ipairs({
	{ 25, 25, 30, 30, 40, 40, 50 },
	{ 50, 60, 60, 70, 70, 80, 80 },
	{ 90, 90, 100, 100, 110, 110, 120 },
	{ 120, 130, 130, 140, 140, 150, 160 }
}) do
	for j, item in ipairs(list) do
		local day = (i - 1) * DailyRewardConfig.DAYS_PER_CYCLE + j
		DailyRewardConfig.REWARDS[day] = {
			Day = day,
			Notes = item,
			Text = "+" .. tostring(item) .. " Notes",
			Image = v[j],
			Cycle = i
		}
	end
end

DailyRewardConfig.MAX_DAYS = #DailyRewardConfig.REWARDS

DailyRewardConfig.SKIP_PRODUCT_IDS_BY_CYCLE = {
	MonetizationConfig.DeveloperProductIds.DailyRewardSkip or 0,
	MonetizationConfig.DeveloperProductIds.DailyRewardSkipCycle2 or 0,
	MonetizationConfig.DeveloperProductIds.DailyRewardSkipCycle3 or 0,
	MonetizationConfig.DeveloperProductIds.DailyRewardSkipCycle4 or 0
}

function DailyRewardConfig.GetRewardCycle(p)
	return (math.clamp(
		math.ceil(math.clamp(math.floor(tonumber(p) or 1), 1, DailyRewardConfig.MAX_DAYS) / DailyRewardConfig.DAYS_PER_CYCLE),
		1,
		DailyRewardConfig.MAX_CYCLES
	))
end

function DailyRewardConfig.GetReward(p)
	local v2 = math.clamp(math.floor(tonumber(p) or 1), 1, DailyRewardConfig.MAX_DAYS)
	return DailyRewardConfig.REWARDS[v2]
end

function DailyRewardConfig.GetSkipProductId(p)
	local rewardCycle = DailyRewardConfig.GetRewardCycle(p)
	return DailyRewardConfig.SKIP_PRODUCT_IDS_BY_CYCLE[rewardCycle] or 0
end

function DailyRewardConfig.GetSkipProductCycle(p)
	local v2 = math.floor(tonumber(p) or 0)

	if v2 <= 0 then
		return nil
	end

	for k, v3 in pairs(DailyRewardConfig.SKIP_PRODUCT_IDS_BY_CYCLE) do
		if math.floor(tonumber(v3) or 0) == v2 then
			return k
		end
	end

	return nil
end

return DailyRewardConfig