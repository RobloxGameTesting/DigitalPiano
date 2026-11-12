return function(value: string)
	local v = string.gsub(value, "(.)(%u)", "%1 %2")
	local v2 = string.gsub(v, "(.*) Accessory", "Accessory | %1")
	return (string.gsub(v2, "T Shirt", "T-Shirt"))
end