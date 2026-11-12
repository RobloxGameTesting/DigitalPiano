local function isMouse(p): boolean
	if p then
		return p.Name:match("^Mouse") ~= nil
	end

	return false
end

return isMouse