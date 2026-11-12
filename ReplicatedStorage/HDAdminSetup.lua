local HDAdminSetup = {}

function HDAdminSetup:GetClientFolder()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	return (ReplicatedStorage:WaitForChild("HDAdminHDClient", 30))
end

function HDAdminSetup.GetMain(_, p)
	local MainFramework = require(HDAdminSetup:GetClientFolder():WaitForChild("SharedModules", 30).MainFramework)

	if p ~= true then
		MainFramework = MainFramework:CheckInitialized()
	end

	return MainFramework
end

return HDAdminSetup