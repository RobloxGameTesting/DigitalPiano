local ClientDebugConfig = {}
ClientDebugConfig.Enabled = false
ClientDebugConfig.WarnEnabled = false

function ClientDebugConfig.IsEnabled(): boolean
	return ClientDebugConfig.Enabled == true
end

function ClientDebugConfig.Print(...)
	if ClientDebugConfig.IsEnabled() then
		print(...)
	end
end

function ClientDebugConfig.Warn(...)
	if ClientDebugConfig.IsEnabled() or ClientDebugConfig.WarnEnabled == true then
		warn(...)
	end
end

return ClientDebugConfig