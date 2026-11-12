local NPSCounter = {}
NPSCounter.MAX_NPS = 100
NPSCounter.MAX_NPS_SERVER = 100
local nows = table.create(120, 0)
local v = 1
local count = 0

local v2 = nil
local v3 = nil
local v4 = 0

local nps = 0
local peakNPS = 0

local TweenService = game:GetService("TweenService")

local v5 = {}

function NPSCounter.Initialize(p, p2)
	v2 = p
	v3 = p2
	NPSCounter.Reset()

	if v2 then
		v2.Text = "NPS: 0\n(Peak: 0)"
	end

	if v3 then
		v3.Size = UDim2.new(0, 0, 1, 0)
		v3.Position = UDim2.new(0, 0, 0, 0)
		v3.AnchorPoint = Vector2.new(0, 0)
	end
end

function NPSCounter.RecordNote()
	local now = os.clock()

	nows[v] = now
	v = v % 120 + 1

	if count < 120 then
		count += 1
	end
end

function NPSCounter.Update()
	local now = os.clock()

	if now - v4 < 0.05 then
		return
	end

	v4 = now

	local v6 = now - 1
	local count2 = 0

	if count > 0 then
		local v7 = count == 120 and v or 1
		local count3 = 0

		while count3 < count do
			if v6 <= nows[(v7 + count3 - 1) % 120 + 1] then
				count2 += 1
			end

			count3 += 1
		end
	end

	nps = count2

	if peakNPS < nps then
		peakNPS = nps
	end

	if v2 then
		v2.Text = string.format("NPS: %d (Peak: %d)", nps, peakNPS)
	end

	if v3 then
		local v7 = math.clamp(nps / NPSCounter.MAX_NPS, 0, 1)

		local udim = UDim2.new(v7, 0, 1, 0)
		TweenService:Create(v3, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = udim
		}):Play()
	end
end

function NPSCounter.Reset()
	v = 1
	count = 0
	nps = 0

	v4 = 0

	if v2 then
		v2.Text = string.format("NPS: 0 (Peak: %d)", peakNPS)
	end

	if v3 then
		TweenService:Create(v3, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 1, 0)
		}):Play()
	end
end

function NPSCounter.GetNPS()
	return nps
end

function NPSCounter.GetPeakNPS()
	return peakNPS
end

function NPSCounter.CheckServerLimit(p): boolean
	local now = tick()
	local v6 = v5[p] or {}

	local v7 = {}

	for _, v8 in ipairs(v6) do
		if now - v8 < 1 then
			table.insert(v7, v8)
		end
	end

	table.insert(v7, now)
	v5[p] = v7

	return #v7 <= NPSCounter.MAX_NPS_SERVER
end

function NPSCounter.CleanupServer(p)
	v5[p] = nil
end

function NPSCounter.GetServerNPS(p)
	local now = tick()
	local v6 = v5[p] or {}
	local count2 = 0

	for _, v7 in ipairs(v6) do
		if now - v7 < 1 then
			count2 += 1
		end
	end

	return count2
end

function NPSCounter.GetMaxServerNPS()
	return NPSCounter.MAX_NPS_SERVER
end

return NPSCounter