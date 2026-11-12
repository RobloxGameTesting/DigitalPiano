local function isGamepad(p): boolean
	if p then
		return p.Name:match("^Gamepad*") ~= nil
	end

	return false
end

return isGamepad