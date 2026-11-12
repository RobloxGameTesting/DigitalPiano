local Handler = {}

local HttpService = game:GetService("HttpService")
game:GetService("MarketplaceService")
local GroupService = game:GetService("GroupService")

local v = 0
local lastTime = 0

local function sleep(duration) -- 1 equivalent call inferred from this helper
	if duration and duration > 0 then
		task.wait(duration)
	end
end

local function http_get(url, p)
	while v >= 10 do
		task.wait(0.01)
	end

	while os.clock() - lastTime < 0.05 do
		task.wait(0.01)
	end

	v += 1
	local count = 0
	local success, result

	repeat
		success, result = pcall(function()
			return HttpService:RequestAsync({
				Url = url,
				Method = "GET",
				Headers = p or nil
			})
		end)

		lastTime = os.clock()
		count += 1

		local v2 = not success

		if not v2 then
			if result then
				if result.StatusCode == 429 then
					v2 = true
				elseif result.StatusCode >= 500 then
					v2 = result.StatusCode < 600
				else
					v2 = false
				end
			else
				v2 = result
			end
		end

		if not (v2 and count < 5) then
			break
		end

		local v3 = (math.random() * 2 - 1) * 0.25
		sleep(math.clamp(2 ^ (count - 1) * 0.6 + v3, 0.15, 3)) -- inferred equivalent call
	until count >= 5

	v -= 1
	return success, result
end

local function dedup_list(options)
	local set = {}
	local result = {}

	for _, v2 in ipairs(options or {}) do
		if typeof(v2) ~= "number" or set[v2] then
			continue
		end

		set[v2] = true
		table.insert(result, v2)
	end

	return result
end

local v2 = {}
local nows = {}

local function is_regional_priced(p, p2)
	if not p2 then
		local v3 = nows[p]

		if v3 and os.time() - v3 < 3600 then
			return v2[p]
		end
	end

	local v3, v4 = http_get(
		string.format("https://regional-check.digitalpiano.workers.dev/?id=%d" .. (p2 and "&debug=1" or ""), p),
		{ ["X-App-Token"] = "eLldrWRqIgAI1WmdLZMb0TeUQg0Qy8cx" } or nil
	)

	if not v3 or not v4.Success or v4.StatusCode ~= 200 then
		return true
	end

	local jsonDecode = HttpService:JSONDecode(v4.Body)
	local selected = (jsonDecode and jsonDecode.regional) == true
	v2[p] = selected
	nows[p] = os.time()
	return selected
end

function Handler.IsRegionalFresh(p, p2)
	return is_regional_priced(p, p2)
end

local function fetch_user_games(userId)
	local v3 = ""
	local ids = {}
	local v4, v5

	while true do
		v4 = string.format(
			"https://games.roproxy.com/v2/users/%d/games?sortOrder=Asc&limit=50%s",
			userId,
			v3 ~= "" and "&cursor=" .. HttpService:UrlEncode(v3) or ""
		)
		local v6
		v6, v5 = http_get(v4)

		if not v6 or not v5.Success or v5.StatusCode ~= 200 then
			break
		end

		local jsonDecode = HttpService:JSONDecode(v5.Body)

		for _, v7 in ipairs(jsonDecode.data or {}) do
			if v7 and v7.id then
				table.insert(ids, v7.id)
			end
		end

		v3 = jsonDecode.nextPageCursor or ""

		if v3 == "" or v3 == nil then
			return ids
		end
	end

	warn("Get user games failed:", v4, v5 and v5.StatusCode)
	return ids
end

local function fetch_group_games(p)
	local v3 = ""
	local ids = {}
	local v4

	while true do
		local v5
		v5, v4 = http_get((string.format(
			"https://games.roproxy.com/v2/groups/%d/games?accessFilter=2&sortOrder=Asc&limit=50%s",
			p,
			v3 ~= "" and "&cursor=" .. HttpService:UrlEncode(v3) or ""
		)))

		if not v5 or not v4.Success or v4.StatusCode ~= 200 then
			break
		end

		local jsonDecode = HttpService:JSONDecode(v4.Body)

		for _, v6 in ipairs(jsonDecode.data or {}) do
			if v6 and v6.id then
				table.insert(ids, v6.id)
			end
		end

		v3 = jsonDecode.nextPageCursor or ""

		if v3 == "" or v3 == nil then
			return ids
		end
	end

	warn("Get group games failed:", p, v4 and v4.StatusCode)
	return ids
end

local function fetch_gamepasses_for_game(p)
	local v3 = ""
	local ids = {}
	local v4

	while true do
		local v5
		v5, v4 = http_get((string.format(
			"https://apis.roproxy.com/game-passes/v1/universes/%d/game-passes?passView=Full&pageSize=100%s",
			p,
			v3 ~= "" and "&pageToken=" .. HttpService:UrlEncode(v3) or ""
		)))

		if not v5 or not v4.Success or v4.StatusCode ~= 200 then
			break
		end

		local jsonDecode = HttpService:JSONDecode(v4.Body)

		for _, v6 in ipairs(jsonDecode.gamePasses or {}) do
			if v6 and v6.id then
				table.insert(ids, v6.id)
			end
		end

		v3 = jsonDecode.nextPageToken or ""

		if v3 == "" or v3 == nil then
			return ids
		end
	end

	warn("Get gamepasses (new API) failed:", p, v4 and v4.StatusCode, v4 and v4.StatusMessage)
	return ids
end

local function fetch_gamepasses_for_games_parallel(options)
	local result = {}
	local v3 = 0
	local bindableEvent = Instance.new("BindableEvent")

	local function doneOne() -- 1 equivalent call inferred from this helper
		v3 -= 1

		if v3 == 0 then
			bindableEvent:Fire()
		end
	end

	for _, v4 in ipairs(options or {}) do
		v3 += 1
		task.spawn(function()
			local v5 = fetch_gamepasses_for_game(v4)

			for _, v6 in ipairs(v5) do
				table.insert(result, v6)
			end

			doneOne() -- inferred equivalent call
		end)
		task.wait()
	end

	if v3 > 0 then
		bindableEvent.Event:Wait()
	end

	bindableEvent:Destroy()
	return result
end

local function fetch_creator_clothing_parallel(name)
	local ids = {}
	local v3 = 3
	local bindableEvent = Instance.new("BindableEvent")

	local function fetch_kind(p)
		local v4 = ""

		repeat
			local v5, v6 = http_get((string.format(
				"https://catalog.roproxy.com/v1/search/items/details?Category=3&Subcategory=%d&Limit=30&CreatorName=%s%s",
				p,
				HttpService:UrlEncode(name),
				v4 ~= "" and "&cursor=" .. HttpService:UrlEncode(v4) or ""
			)))

			if not v5 or not v6.Success or v6.StatusCode ~= 200 then
				warn("Fetch clothing failed:", p, v6 and v6.StatusCode)
				break
			end

			local jsonDecode = HttpService:JSONDecode(v6.Body)

			for _, v7 in ipairs(jsonDecode.data or {}) do
				if typeof(v7.id) == "number" then
					table.insert(ids, v7.id)
				end
			end

			v4 = jsonDecode.nextPageCursor or ""
		until v4 == "" or v4 == nil

		v3 -= 1

		if v3 == 0 then
			bindableEvent:Fire()
		end
	end

	task.spawn(function()
		fetch_kind(55)
	end)
	task.spawn(function()
		fetch_kind(56)
	end)
	task.spawn(function()
		fetch_kind(57)
	end)

	bindableEvent.Event:Wait()
	bindableEvent:Destroy()
	return ids
end

function Handler.GetAssets(_, p)
	local v3 = fetch_gamepasses_for_games_parallel(fetch_user_games(p.UserId))
	local v4 = {}

	for _, v5 in ipairs(v3) do
		table.insert(v4, v5)
	end

	local success, groupsAsync = pcall(GroupService.GetGroupsAsync, GroupService, p.UserId)

	if success and typeof(groupsAsync) == "table" then
		local ids = {}

		for _, v5 in ipairs(groupsAsync) do
			if v5 and v5.Rank == 255 and v5.Id then
				table.insert(ids, v5.Id)
			end
		end

		local v5 = {}
		local v6 = 0
		local bindableEvent = Instance.new("BindableEvent")
		local function done() -- 1 equivalent call inferred from this helper
			v6 -= 1

			if v6 == 0 then
				bindableEvent:Fire()
			end
		end

		for _, v7 in ipairs(ids) do
			v6 += 1
			task.spawn(function()
				local v8 = fetch_group_games(v7)

				for _, v9 in ipairs(v8) do
					table.insert(v5, v9)
				end

				done() -- inferred equivalent call
			end)
		end

		if v6 > 0 then
			bindableEvent.Event:Wait()
		end

		bindableEvent:Destroy()

		local v7 = fetch_gamepasses_for_games_parallel(v5)

		for _, v8 in ipairs(v7) do
			table.insert(v4, v8)
		end
	else
		warn("GetGroupsAsync failed:", groupsAsync)
	end

	local v5 = fetch_creator_clothing_parallel(p.Name)

	return dedup_list(v4), dedup_list(v5)
end

function Handler.GetAssetsQuick(_, p)
	local ids = {}
	local ids2 = {}

	local function quick_clothing(p2)
		local v3, v4 = http_get((string.format(
			"https://catalog.roproxy.com/v1/search/items/details?Category=3&Subcategory=%d&Limit=30&CreatorName=%s",
			p2,
			HttpService:UrlEncode(p.Name)
		)))

		if v3 and v4.Success and v4.StatusCode == 200 then
			local jsonDecode = HttpService:JSONDecode(v4.Body)

			for _, v5 in ipairs(jsonDecode.data or {}) do
				if typeof(v5.id) == "number" then
					table.insert(ids, v5.id)
				end
			end
		end
	end

	quick_clothing(56)
	quick_clothing(55)
	quick_clothing(57)

	local v3, v4 = http_get((string.format(
		"https://games.roproxy.com/v2/users/%d/games?sortOrder=Asc&limit=10",
		p.UserId
	)))

	if v3 and v4.Success and v4.StatusCode == 200 then
		local jsonDecode = HttpService:JSONDecode(v4.Body)

		local v5 = 0
		local bindableEvent = Instance.new("BindableEvent")
		local function done() -- 1 equivalent call inferred from this helper
			v5 -= 1

			if v5 == 0 then
				bindableEvent:Fire()
			end
		end

		for _, v6 in ipairs(jsonDecode.data or {}) do
			if not (v6 and v6.id) then
				continue
			end

			v5 += 1
			task.spawn(function()
				local v7, v8 = http_get((string.format(
					"https://games.roproxy.com/v1/games/%d/game-passes?limit=50&sortOrder=Asc",
					v6.id
				)))

				if v7 and v8.Success and v8.StatusCode == 200 then
					local jsonDecode2 = HttpService:JSONDecode(v8.Body)

					for _, v9 in ipairs(jsonDecode2.data or {}) do
						if v9 and v9.id then
							table.insert(ids2, v9.id)
						end
					end
				end

				done() -- inferred equivalent call
			end)
		end

		if v5 > 0 then
			bindableEvent.Event:Wait()
		end

		bindableEvent:Destroy()
	end

	return dedup_list(ids2), dedup_list(ids)
end

return Handler