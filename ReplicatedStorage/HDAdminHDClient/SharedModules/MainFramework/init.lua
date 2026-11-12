local script2 = script
local Reference = require(script2.Reference)
local object = Reference.getObject()
local value = object and object.Value

if value and value ~= script2 then
	warn("Two HD Admin applications attempted to initialize. Consider deleting one.")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	return (require(ReplicatedStorage:WaitForChild("HDAdminSetup")):GetMain())
else
	if not object then
		Reference.addToReplicatedStorage()
	end

	local object2 = setmetatable({}, {
		__index = function(services, value2)
			local success, service = pcall(game.GetService, game, value2:sub(1, 1):upper() .. value2:sub(2))

			if not success then
				return
			end

			services[value2] = service
			return service
		end
	})

	function object2.Initialize(_, value2, parent)
		if object2.alreadyInitialized then
			return
		end

		object2.alreadyInitialized = true

		object2.rs = game:GetService("ReplicatedStorage")
		object2.ss = game:GetService("ServerStorage")
		object2.sss = game:GetService("ServerScriptService")

		local function ConvertToCamelCase(value3)
			return string.lower((string.sub(value3, 1, 1))) .. string.sub(value3, 2)
		end

		if value2 == "Server" then
			object2.mainModule = script:FindFirstAncestor("MainModule")
			object2.server = object2.mainModule.HDServer
			object2.client = object2.mainModule.HDClient

			object2.workspaceFolder = Instance.new("Folder")
			object2.workspaceFolder.Name = "HDAdminWorkspaceFolder"
			object2.workspaceFolder.Parent = workspace

			local settingsCopy = object2.server.Assets:WaitForChild("SettingsCopy", 1000)

			if settingsCopy then
				object2.settings = require(settingsCopy)
			end

			local Settings = require(parent:FindFirstChild("Settings", true))

			if Settings then
				for k, setting in pairs(Settings) do
					local v = false

					if typeof(setting) == "table" then
						for k2, _ in pairs(setting) do
							v = tonumber(k2) == nil or v
							break
						end
					end

					if v then
						local v2 = object2.settings[k]

						if typeof(v2) ~= "table" then
							v2 = {}
							object2.settings[k] = v2
						end

						for k2, v3 in pairs(setting) do
							v2[k2] = v3
						end
					else
						object2.settings[k] = setting
					end
				end
			end

			local customFeatures = parent:FindFirstChild("CustomFeatures", true)
			local config = parent:FindFirstChild("Config")

			if config then
				if not customFeatures then
					customFeatures = Instance.new("Configuration")
					customFeatures.Name = "CustomFeatures"
					customFeatures.Parent = parent
				end

				local commands = config:FindFirstChild("Commands")

				if commands then
					for _, child in pairs(commands:GetChildren()) do
						local name = child.Name
						local parent2 = customFeatures:FindFirstChild(name)

						if not parent2 then
							parent2 = Instance.new("Folder")
							parent2.Name = name
							parent2.Parent = customFeatures
						end

						local modules = parent2:FindFirstChild("Modules")

						if not modules then
							modules = Instance.new("Folder")
							modules.Name = "Modules"
							modules.Parent = parent2
						end

						local name2 = name == "Client" and "ClientCommands" or "Commands"

						local clone = child:Clone()
						clone.Name = name2
						clone.Parent = modules
					end
				end
			end

			local function UpdateStorageWithContents(child, p)
				local v = string.lower(p == "Client" and p or "Server")
				local name = child.Name
				local child2 = object2[v]:FindFirstChild(name)

				if child2 and name ~= "client" and name ~= "server" then
					for _, customClientCommands in pairs(child:GetChildren()) do
						local moduleScript = child2:FindFirstChild(customClientCommands.Name)

						if moduleScript and not moduleScript:IsA("ModuleScript") then
							moduleScript:Destroy()
						end

						local name2 = customClientCommands.Name
						local v2 = name2 == "ClientCommands"

						if moduleScript and (name2 == "Commands" or v2) then
							local commandsToMerge = Instance.new("ObjectValue")
							commandsToMerge.Name = "CommandsToMerge"
							commandsToMerge.Value = customClientCommands
							commandsToMerge.Parent = moduleScript

							if v2 then
								customClientCommands.Name = "CustomClientCommands"
								customClientCommands.Parent = child2
							end
						else
							customClientCommands.Parent = child2
						end
					end
				end
			end
			local core = parent and parent:FindFirstChild("Core")

			if core then
				local packageLink = core:FindFirstChildOfClass("PackageLink")
				local mainModule = core:FindFirstChild("MainModule")

				if packageLink and mainModule and #mainModule:GetChildren() > 0 then
					workspace:GetAttribute("HD")
				end
			end

			if customFeatures then
				for _, child in pairs(customFeatures:GetChildren()) do
					UpdateStorageWithContents(child)
					local name = child.Name

					for _, child2 in pairs(child:GetChildren()) do
						UpdateStorageWithContents(child2, name)
					end
				end
			end

			local v = { ["HDClient"] = object2.rs, HDServer = object2.ss }

			local v2 = {
				["HDAdminStarterCharacter"] = object2.starterPlayer.StarterCharacterScripts,
				HDAdminInterface = object2.starterGui,
				Preload = object2.replicatedFirst
			}

			local function CheckToMove(child)
				local name = child.Name
				local parent2 = v[name] or v2[name]

				if parent2 and not parent2:FindFirstChild(name) then
					if v[name] then
						child.Name = "HDAdmin" .. name
						child.Parent = parent2
					elseif v2[name] then
						local clone = child:Clone()
						clone.Parent = parent2

						if clone:IsA("BaseScript") then
							clone.Disabled = false
						end
					end
				end
			end

			for _, child in pairs(object2.mainModule:GetChildren()) do
				CheckToMove(child)

				for _, child2 in pairs(child:GetChildren()) do
					CheckToMove(child2)

					for _, child3 in pairs(child2:GetChildren()) do
						CheckToMove(child3)
					end
				end
			end

			local setupQuickJoiners = object2.server.Assets.SetupQuickJoiners

			for _, child in pairs(object2.players:GetChildren()) do
				local clone = setupQuickJoiners:Clone()
				clone.Parent = child.PlayerGui
				clone.Disabled = false
			end

			task.defer(function()
				local hdAdminMapBackup = Instance.new("Folder")
				hdAdminMapBackup.Name = "HDAdminMapBackup"
				hdAdminMapBackup.Parent = object2.ss
				object2.client.Signals.Initialized.Event:Wait()

				if object2.settings.AutoSaveMap == true then
					object2:GetModule("cf"):SaveMap()
				end
			end)
		elseif value2 == "Client" then
			object2.client = object2.rs:WaitForChild("HDAdminHDClient")

			for _, _ in pairs(object2.client:GetChildren()) do

			end

			object2.workspaceFolder = workspace:WaitForChild("HDAdminWorkspaceFolder")

			local Players = game:GetService("Players")
			object2.player = Players.LocalPlayer
			object2.playerGui = object2.player:WaitForChild("PlayerGui")
			object2.gui = object2.playerGui:WaitForChild("HDAdminInterface", 1000)
			object2.mainFrame = object2.gui and object2.gui:WaitForChild("MainFrame", 1000)
			object2.templates = object2.gui:WaitForChild("Templates")
			object2.warnings = object2.gui.MainFrame:WaitForChild("Warnings")
			object2.camera = workspace.CurrentCamera
			task.wait()

			object2.tablet = false

			if object2.guiService:IsTenFootInterface() then
				object2.device = "Console"
			elseif object2.userInputService.TouchEnabled and not object2.userInputService.MouseEnabled then
				object2.device = "Mobile"
			else
				object2.device = "Computer"
			end

			if object2.gui.AbsoluteSize.Y < 1 then
				repeat
					wait()
				until object2.gui.AbsoluteSize.Y > 0
			end

			if
				object2.device == "Mobile"
				and math.min(object2.gui.AbsoluteSize.X, object2.gui.AbsoluteSize.Y) >= 650
			then
				object2.tablet = true
			end

			local result = nil

			for _ = 1, 50 do
				local success
				success, result = pcall(function()
					return object2.client.Signals.RetrieveData:InvokeServer()
				end)

				if success and result then
					break
				end

				wait(1)
			end

			for k, v in pairs(result) do
				object2[k] = v
			end
		end

		os.date("*t", os.time())
		object2.hdAdminCoreName = "System"
		object2.modules = {}
		object2.coreFolder = object2[string.lower(value2)]
		object2.moduleGroup = object2.coreFolder.Modules
		object2.sharedModules = object2.client.SharedModules
		object2.signals = object2.client.Signals
		object2.audio = object2.client.Audio

		local v = {}
		function object2:GetModule(name)
			if not object2.modules[name] then
				local v2 = { name = name, addedSignal = Instance.new("BindableEvent") }
				v[#v + 1] = v2
				v2.addedSignal.Event:Wait()
			end

			return object2.modules[name]
		end

		function object2.loadModule(name)
			if not object2.modules[name] then
				local v2 = { name = name, addedSignal = Instance.new("BindableEvent") }
				v[#v + 1] = v2
				v2.addedSignal.Event:Wait()
			end

			return object2.modules[name]
		end

		local v2 = {}

		for k, v3 in pairs({
			cf = { "ClientCoreFunctions", "SharedCoreFunctions", "ServerCoreFunctions" },
			API = { "ClientAPI", "ServerAPI", "SharedAPI" }
		}) do
			for _, v4 in pairs(v3) do
				v2[v4] = k
			end
		end

		local v3 = false
		local bindableEvent = Instance.new("BindableEvent")
		local function mergeComplete() -- 1 equivalent call inferred from this helper
			if not v3 then
				v3 = true
				bindableEvent:Fire()
				bindableEvent:Destroy()
			end
		end
		task.delay(10, mergeComplete)
		local v4 = 0
		local function SetupModules(folder, modules)
			for _, moduleScript in pairs(folder:GetDescendants()) do
				if not (moduleScript:IsA("ModuleScript") and moduleScript.Name ~= script.Name) then
					continue
				end

				v4 += 1
				task.defer(function()
					local name = moduleScript.Name
					local v5 = v2[name] or name

					local success, result = pcall(function()
						return require(moduleScript)
					end)

					if success then
						if modules[v5] then
							local v6 = modules[v5]

							for k, v7 in pairs(result) do
								if tonumber(k) then
									table.insert(v6, v7)
								else
									v6[k] = v7
								end
							end
						else
							local commandsToMerge = moduleScript:FindFirstChild("CommandsToMerge")

							if commandsToMerge then
								local v6 = moduleScript.Name == "Commands"

								local Value = require(commandsToMerge.Value)
								local v7 = {}

								for name2, v8 in result do
									name2 = v6 and v8.Name or name2
									local lower = tostring(name2):lower()
									local v9 = {}

									if typeof(v9) == "table" then
										for _, v10 in v9 do
											v7[tostring(v10):lower()] = v8
										end
									end

									v7[lower] = v8
								end

								for name2, v8 in Value do
									name2 = v6 and v8.Name or name2
									local v9 = v7[tostring(name2):lower()]

									if v9 then
										for k, v10 in pairs(v8) do
											v9[k] = v10
										end
									elseif v6 then
										table.insert(result, v8)
									else
										result[name2] = v8
									end
								end
							end

							modules[v5] = result

							for i = #v, 1, -1 do
								local v6 = v[i]

								if not (v6 and v6.name == v5) then
									continue
								end

								table.remove(v, i)
								v6.addedSignal:Fire()
							end
						end
					else
						warn("HD Admin Module Error | " .. moduleScript.Name .. " | " .. tostring(result))
					end

					v4 -= 1

					if v4 == 0 then
						mergeComplete() -- inferred equivalent call
					end
				end)
			end
		end
		local MainVariables = require(script.MainVariables)
		MainVariables:SetupMainVariables(value2)
		SetupModules(object2.moduleGroup, object2.modules)
		SetupModules(object2.sharedModules, object2.modules)

		if not v3 then
			bindableEvent.Event:Wait()
		end

		if value2 == "Server" then
			local hdAdminSetup = object2.server.Assets:WaitForChild("HDAdminSetup")
			hdAdminSetup.Parent = object2.rs

			if not object2.ownerName then
				object2.ownerName = object2:GetModule("cf"):GetName(object2.ownerId)
			end

			object2:GetModule("CommandHandler"):Setup()
			object2:GetModule("LoaderHandler"):Setup()
		end

		object2.initialized = true
		object2.client.Signals.Initialized:Fire()
	end

	function object2.CheckInitialized(_)
		if not object2.initialized then
			script.Parent.Parent:WaitForChild("Signals"):WaitForChild("Initialized").Event:Wait()
		end

		return object2
	end

	_G.HDAdminMain = object2

	return object2
end