local HDAdminMain = _G.HDAdminMain

local CustomClientCommands = {
	example2 = {
		Function = function(_, _)
			print("HELLO (Client)")
		end,
		UnFunction = function(_, _)
			print("GOODBYE (Client)")
		end
	}
}

for k, v in pairs(CustomClientCommands) do
	v.Name = k
end

return CustomClientCommands