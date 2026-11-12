local function separateThousands(p: number, _: string?)
	return (tostring(p):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", ""))
end

return separateThousands