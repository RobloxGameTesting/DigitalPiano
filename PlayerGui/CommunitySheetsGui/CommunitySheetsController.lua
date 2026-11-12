local v = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v2 = v(ReplicatedStorage:WaitForChild("ClientDebugConfig"))

do
	local Players = game:GetService("Players")
	local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
	local GuiService = game:GetService("GuiService")
	local RunService = game:GetService("RunService")
	local StarterGui = game:GetService("StarterGui")
	local TextService = game:GetService("TextService")

	local LocalPlayer = Players.LocalPlayer
	local parent = script.Parent
	parent.IgnoreGuiInset = true
	pcall(function()
		parent.ScreenInsets = Enum.ScreenInsets.None
		parent.ClipToDeviceSafeArea = false
	end)
	parent.DisplayOrder = math.max(tonumber(parent.DisplayOrder) or 0, 1105)
	local root = parent:WaitForChild("Root")

	do
		local panel = root:WaitForChild("Panel")
		local mobileLandscapeFrame = root:WaitForChild("MobileLandscapeFrame")
		local topBar = panel:WaitForChild("TopBar")
		local nav = topBar:WaitForChild("Nav")
		v = nav:WaitForChild("Close")
		local publish = nav:WaitForChild("Publish")
		local content = panel:WaitForChild("Content")
		local pageTitle = content:WaitForChild("PageTitle")
		local pageSubtitle = content:WaitForChild("PageSubtitle")
		local toolbar = content:WaitForChild("Toolbar")
		local searchWrap = toolbar:WaitForChild("SearchWrap")
		local search = searchWrap:WaitForChild("Search")
		local difficultyBar = toolbar:WaitForChild("DifficultyBar")
		local sortButton = toolbar:WaitForChild("SortButton")
		local cardGrid = content:WaitForChild("CardGrid")
		local gridLayout = cardGrid:WaitForChild("GridLayout")
		local emptyLabel = cardGrid:WaitForChild("EmptyLabel")
		local cardTemplate = cardGrid:WaitForChild("CardTemplate")
		local pagination = content:WaitForChild("Pagination")
		local countLabel = pagination:WaitForChild("CountLabel")
		local openCommunitySheets = pagination:WaitForChild("Pager")
		local prev = openCommunitySheets:WaitForChild("Prev")
		local pageLabel = openCommunitySheets:WaitForChild("PageLabel")
		local nextNode = openCommunitySheets:WaitForChild("Next")
		local controls = {}
		controls.Rail = mobileLandscapeFrame:WaitForChild("Rail")
		controls.Main = mobileLandscapeFrame:WaitForChild("Main")
		controls.TopBar = controls.Main:WaitForChild("TopBar")
		controls.Title = controls.TopBar:WaitForChild("Title")
		controls.CountLabel = controls.TopBar:WaitForChild("CountLabel")
		controls.SearchRow = controls.Main:WaitForChild("SearchRow")
		controls.SearchWrap = controls.SearchRow:WaitForChild("SearchWrap")
		controls.SearchBox = controls.SearchWrap:WaitForChild("Search")
		controls.RefreshButton = controls.SearchRow:WaitForChild("RefreshButton")
		controls.SortButton = controls.SearchRow:WaitForChild("SortButton")
		controls.DifficultyBar = controls.Main:WaitForChild("DifficultyBar")
		controls.Body = controls.Main:WaitForChild("Body")
		controls.CardGrid = controls.Body:WaitForChild("CardGrid")
		controls.GridLayout = controls.CardGrid:WaitForChild("GridLayout")
		controls.EmptyLabel = controls.Body:WaitForChild("EmptyLabel")
		local flag = false

		emptyLabel.Parent = content
		cardTemplate.Parent = parent
		cardTemplate.Visible = false

		parent.Enabled = true
		root.Visible = false

		local remotes = workspace:WaitForChild("Piano_Dependencies"):WaitForChild("Remotes")
		local getCommunitySheets = remotes:WaitForChild("GetCommunitySheets")
		GetPersonalSheetsRemote = remotes:WaitForChild("GetPersonalSheets")
		local toggleCommunityFavorite = remotes:WaitForChild("ToggleCommunityFavorite")
		local resolveCommunityFavorite = remotes:WaitForChild("ResolveCommunityFavorite")
		local recordCommunitySheetPlay = remotes:WaitForChild("RecordCommunitySheetPlay")
		local reportCommunitySheet = remotes:WaitForChild("ReportCommunitySheet")
		local moderateCommunitySheet = remotes:WaitForChild("ModerateCommunitySheet")
		PublishCommunitySheetRemote = remotes:WaitForChild("PublishCommunitySheet")
		UnpublishCommunitySheetRemote = remotes:WaitForChild("UnpublishCommunitySheet")
		local publishCommunityMidi = remotes:WaitForChild("PublishCommunityMidi")
		local unpublishCommunityMidi = remotes:WaitForChild("UnpublishCommunityMidi")
		local republishCommunityMidi = remotes:WaitForChild("RepublishCommunityMidi")
		local getCommunityMidi = remotes:WaitForChild("GetCommunityMidi")
		local recordCommunityMidiPlay = remotes:WaitForChild("RecordCommunityMidiPlay")
		local reportCommunityMidi = remotes:WaitForChild("ReportCommunityMidi")
		local moderateCommunityMidi = remotes:WaitForChild("ModerateCommunityMidi")
		local repairCommunityMidi = remotes:WaitForChild("RepairCommunityMidi")

		openCommunitySheets = ReplicatedStorage2:FindFirstChild("OpenCommunitySheets")

		if not (openCommunitySheets and openCommunitySheets:IsA("BindableEvent")) then
			if openCommunitySheets then
				openCommunitySheets:Destroy()
			end

			openCommunitySheets = Instance.new("BindableEvent")
			openCommunitySheets.Name = "OpenCommunitySheets"
			openCommunitySheets.Parent = ReplicatedStorage2
		end

		openCommunityProfileEvent = ReplicatedStorage2:FindFirstChild("OpenCommunityProfile")

		if not (openCommunityProfileEvent and openCommunityProfileEvent:IsA("BindableEvent")) then
			if openCommunityProfileEvent then
				openCommunityProfileEvent:Destroy()
			end

			openCommunityProfileEvent = Instance.new("BindableEvent")
			openCommunityProfileEvent.Name = "OpenCommunityProfile"
			openCommunityProfileEvent.Parent = ReplicatedStorage2
		end

		local OpenCommunityMidiUrl = ReplicatedStorage2:FindFirstChild("OpenCommunityMidiUrl")

		if not (OpenCommunityMidiUrl and OpenCommunityMidiUrl:IsA("BindableEvent")) then
			if OpenCommunityMidiUrl then
				OpenCommunityMidiUrl:Destroy()
			end

			OpenCommunityMidiUrl = Instance.new("BindableEvent")
			OpenCommunityMidiUrl.Name = "OpenCommunityMidiUrl"
			OpenCommunityMidiUrl.Parent = ReplicatedStorage2
		end

		refreshCommunityMidiForLoadFunction = ReplicatedStorage2:FindFirstChild("RefreshCommunityMidiForLoad")

		if not (refreshCommunityMidiForLoadFunction and refreshCommunityMidiForLoadFunction:IsA("BindableFunction")) then
			if refreshCommunityMidiForLoadFunction then
				refreshCommunityMidiForLoadFunction:Destroy()
			end

			refreshCommunityMidiForLoadFunction = Instance.new("BindableFunction")
			refreshCommunityMidiForLoadFunction.Name = "RefreshCommunityMidiForLoad"
			refreshCommunityMidiForLoadFunction.Parent = ReplicatedStorage2
		end

		local modeConfigs = {
			Community = {
				Id = "Community",
				Button = "Community",
				Title = "Community Sheets",
				Subtitle = "Discover and play songs created by other players.",
				Empty = "No community sheets found.",
				Accent = Color3.fromRGB(20, 160, 255)
			},
			Profile = {
				Id = "Profile",
				Button = "Profile",
				Title = "Profile",
				Subtitle = "View creator sheets and community activity.",
				Empty = "No profile sheets yet.",
				Accent = Color3.fromRGB(66, 211, 198)
			},
			MIDI = {
				Id = "MIDI",
				Button = "MIDI",
				Title = "Community MIDI",
				Subtitle = "Browse shared MIDI links with server-side backups when files are small enough.",
				Empty = "No MIDI links yet.",
				Accent = Color3.fromRGB(142, 113, 230)
			},
			Reports = {
				Id = "Reports",
				Button = "Reports",
				Title = "Reported Uploads",
				Subtitle = "Review reported community sheets and MIDI uploads.",
				Empty = "No reported uploads need review.",
				Accent = Color3.fromRGB(255, 115, 92)
			},
			Hidden = {
				Id = "Hidden",
				Button = "Hidden",
				Title = "Hidden Uploads",
				Subtitle = "Restore or permanently remove uploads hidden by moderation.",
				Empty = "No hidden uploads can be restored right now.",
				Accent = Color3.fromRGB(255, 176, 84)
			},
			Blocked = {
				Id = "Blocked",
				Button = "Blocked",
				Title = "Blocked Uploaders",
				Subtitle = "Review and unblock players who cannot publish community uploads.",
				Empty = "No players are blocked from community publishing.",
				Accent = Color3.fromRGB(235, 93, 130)
			}
		}

		local v3 = { "Community", "MIDI", "Profile", "Reports", "Hidden", "Blocked" }
		local difficultyOrder = { "All", "Beginner", "Intermediate", "Advanced", "Expert" }
		local v4 = {
			Beginner = {
				Text = Color3.fromRGB(102, 255, 191),
				Background = Color3.fromRGB(20, 58, 48),
				Border = Color3.fromRGB(52, 211, 153)
			},
			Intermediate = {
				Text = Color3.fromRGB(255, 220, 92),
				Background = Color3.fromRGB(82, 61, 24),
				Border = Color3.fromRGB(238, 190, 47)
			},
			Advanced = {
				Text = Color3.fromRGB(255, 169, 102),
				Background = Color3.fromRGB(78, 43, 27),
				Border = Color3.fromRGB(240, 117, 54)
			},
			Expert = {
				Text = Color3.fromRGB(255, 126, 153),
				Background = Color3.fromRGB(73, 29, 45),
				Border = Color3.fromRGB(236, 72, 112)
			},
			Default = {
				Text = Color3.fromRGB(190, 198, 214),
				Background = Color3.fromRGB(43, 48, 62),
				Border = Color3.fromRGB(98, 108, 132)
			}
		}

		local v5 = {
			Newest = "rbxassetid://104240298148440",
			TopAllTime = "rbxassetid://78004495276250"
		}

		local function setTopNavButtonText(button, text) -- 5 equivalent calls inferred from this helper
			if not (button and button:IsA("TextButton")) then
				return
			end

			button.Text = ""
			button.TextTransparency = 1
			local buttonLabel = button:FindFirstChild("ButtonLabel")

			if buttonLabel and buttonLabel:IsA("TextLabel") then
				buttonLabel.Text = text
			end
		end

		local function setTopNavButtonColor(button, p)
			if not (button and button:IsA("TextButton")) then
				return
			end

			button.TextColor3 = p
			local buttonLabel = button:FindFirstChild("ButtonLabel")

			if buttonLabel and buttonLabel:IsA("TextLabel") then
				buttonLabel.TextColor3 = p
			end

			local navIcon = button:FindFirstChild("NavIcon")

			if navIcon and navIcon:IsA("ImageLabel") then
				navIcon.ImageColor3 = p
			end
		end

		local reports = nav:FindFirstChild("Reports")

		if not reports then
			local midi = nav:FindFirstChild("MIDI") or nav:FindFirstChild("Community")

			if midi and midi:IsA("TextButton") then
				reports = midi:Clone()
				reports.Name = "Reports"
				setTopNavButtonText(reports, "Reports") -- inferred equivalent call
				reports.Parent = nav
			end
		end

		if reports and reports:IsA("TextButton") then
			reports.LayoutOrder = 1
			reports.Size = UDim2.fromOffset(126, 40)
			setTopNavButtonText(reports, "Mod Panel") -- inferred equivalent call
			reports.Visible = false
		end

		do
			local hidden = nav:FindFirstChild("Hidden")

			if not hidden then
				local button = reports or nav:FindFirstChild("MIDI") or nav:FindFirstChild("Community")

				if button and button:IsA("TextButton") then
					hidden = button:Clone()
					hidden.Name = "Hidden"
					setTopNavButtonText(hidden, "Hidden") -- inferred equivalent call
					hidden.Parent = nav
				end
			end

			if hidden and hidden:IsA("TextButton") then
				hidden.LayoutOrder = 2
				hidden.Size = UDim2.fromOffset(104, 40)
				setTopNavButtonText(hidden, "Hidden") -- inferred equivalent call
				hidden.Visible = false
			end
		end

		publish.LayoutOrder = 8
		v.LayoutOrder = 9

		local v6 = {}
		local v7 = {}
		local v8 = {}
		local v9 = {}
		local v10 = {}
		local connections = {}
		local selectedMode = "Community"
		local selectedDifficulty = "All"
		local v11 = 1
		local v12 = 6
		local v13 = 3
		local v14 = 2
		local cardWidth = 318
		local v15 = 178
		local v16 = 22
		local v17 = false
		local v18 = false
		local v19 = nil
		local v20 = false
		local v21 = false
		local v22 = nil
		local v23 = 500
		local v24 = 160000
		local v25 = 60
		local v26 = 600
		local v27 = "Easy"
		local state2 = {
			moderationTabsEnabled = false,
			pendingPreviewSong = nil,
			pendingReportSong = nil,
			selectedReportReason = nil,
			sortMode = "Default",
			communitySheetPublishCost = 250,
			communitySheetPublicMaxTextLength = 10000,
			sheetPublishPending = false,
			sheetPublishSheetId = nil,
			sheetPublishPersonalSheets = {},
			sheetPublishPersonalLimit = 20,
			sheetPublishIsPublished = false,
			blockedUploaders = {},
			blockedLoading = false,
			blockedMessage = nil,
			refreshButton = toolbar:WaitForChild("RefreshButton")
		}
		state2.mobileSupport = require(parent:WaitForChild("CommunityMobileSupport"))
		state2.motion = require(parent:WaitForChild("CommunitySheetsMotion"))
		function state2.setProfileTarget(p, value, value2)
			local profileTargetUserId = math.max(0, (math.floor(tonumber(p) or 0)))

			if profileTargetUserId <= 0 then
				profileTargetUserId = LocalPlayer.UserId
			end

			local profileTargetName = tostring(value2 or "")

			if profileTargetName == "" then
				profileTargetName = profileTargetUserId == LocalPlayer.UserId and LocalPlayer.Name
					or "User" .. tostring(profileTargetUserId)
			end

			local profileTargetDisplayName = tostring(value or "")

			if profileTargetDisplayName == "" then
				profileTargetDisplayName = profileTargetName
			end

			local v28

			if state2.profileTargetUserId == nil then
				v28 = false
			else
				v28 = state2.profileTargetUserId ~= profileTargetUserId
			end

			state2.profileTargetUserId = profileTargetUserId
			state2.profileTargetName = profileTargetName
			state2.profileTargetDisplayName = profileTargetDisplayName

			if v28 then
				state2.profileData = nil
			end
		end
		state2.setProfileTarget(
			LocalPlayer.UserId,
			LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name,
			LocalPlayer.Name
		)
		state2.supportCreatorTarget = nil
		state2.supportCreatorPending = false
		state2.midiRepairTarget = nil
		state2.midiRepairPending = false
		state2.previewCreatorConnection = nil
		state2.sheetCatalogCursor = nil
		state2.sheetCatalogHasMore = false
		state2.sheetCatalogTotal = 0
		state2.sheetCatalogLoadingMore = false
		state2.midiCatalogCursor = nil
		state2.midiCatalogHasMore = false
		state2.midiCatalogTotal = 0
		state2.midiCatalogLoadingMore = false
		state2.lastCatalogScrollLoadAt = 0
		state2.mobileRenderLimits = {}
		state2.advancePageAfterCatalogLoad = false
		state2.catalogSearchToken = 0
		state2.searchRequestDelay = 0.45
		state2.sheetUploadQuota = {
			Mode = "Disabled",
			Enabled = false,
			Limit = 0,
			Used = 0,
			Remaining = 0
		}
		state2.midiUploadQuota = {
			Mode = "Disabled",
			Enabled = false,
			Limit = 0,
			Used = 0,
			Remaining = 0
		}

		function state2.getUploadQuotaText(p)
			local v28 = type(p) == "table" and p or {}

			if v28.Enabled ~= true then
				return ""
			end

			local function formatQuotaNumber(p2)
				local v29 = tostring((math.max(0, (math.floor(tonumber(p2) or 0)))))

				repeat
					local v30
					v29, v30 = v29:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
				until v30 == 0

				return v29
			end

			local mode = tostring(v28.Mode or "Weekly"):lower()
			return string.format(
				"%s/%s %s uploads used.",
				formatQuotaNumber(v28.Used),
				formatQuotaNumber(v28.Limit),
				mode
			)
		end

		state2.difficultyAliases = {
			easy = "Beginner",
			beginner = "Beginner",
			medium = "Intermediate",
			intermediate = "Intermediate",
			normal = "Intermediate",
			hard = "Advanced",
			advanced = "Advanced",
			expert = "Expert"
		}

		state2.legacyDifficultyValues = {
			Beginner = "Easy",
			Intermediate = "Medium",
			Advanced = "Hard",
			Expert = "Expert"
		}

		state2.difficultyButtonAliases = {
			Beginner = "Easy",
			Intermediate = "Medium",
			Advanced = "Hard"
		}

		state2.difficultyButtonWidths = {
			All = 48,
			Beginner = 86,
			Intermediate = 112,
			Advanced = 92,
			Expert = 72
		}

		state2.compactDifficultyButtonWidths = {
			All = 36,
			Beginner = 58,
			Intermediate = 80,
			Advanced = 64,
			Expert = 50
		}

		function state2.getDifficultyDisplayLabel(value)
			local v28 = tostring(value or "")

			if v28 == "" then
				return "Beginner"
			end

			return state2.difficultyAliases[v28:lower()] or v28
		end

		function state2.getDifficultyFilterKey(p)
			return state2.getDifficultyDisplayLabel(p):lower()
		end

		function state2.getDifficultyPublishValue(p)
			local difficultyDisplayLabel = state2.getDifficultyDisplayLabel(p)
			return state2.legacyDifficultyValues[difficultyDisplayLabel] or difficultyDisplayLabel
		end

		function state2.getDifficultyButton(childName)
			local child = difficultyBar:FindFirstChild(childName)

			if child then
				return child
			end

			local difficultyButtonAlias = state2.difficultyButtonAliases[childName]
			return difficultyButtonAlias and difficultyBar:FindFirstChild(difficultyButtonAlias) or nil
		end

		function state2.getDifficultyBarContentWidth(p)
			local compactDifficultyButtonWidths = p and state2.compactDifficultyButtonWidths
				or state2.difficultyButtonWidths
			local difficultyBarContentWidth = math.max(0, #difficultyOrder - 1) * 4 + 8

			for _, v28 in ipairs(difficultyOrder) do
				difficultyBarContentWidth += compactDifficultyButtonWidths[v28] or 72
			end

			return difficultyBarContentWidth
		end

		local function configureTextObject(instance, p, value)
			if not (instance and (instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox"))) then
				return
			end

			instance.TextWrapped = true
			instance.TextScaled = true
			local autoTextSizeConstraint = instance:FindFirstChild("AutoTextSizeConstraint")

			if not autoTextSizeConstraint then
				autoTextSizeConstraint = Instance.new("UITextSizeConstraint")
				autoTextSizeConstraint.Name = "AutoTextSizeConstraint"
				autoTextSizeConstraint.Parent = instance
			end

			autoTextSizeConstraint.MinTextSize = value or 8
			autoTextSizeConstraint.MaxTextSize = p or math.max(10, (math.floor(tonumber(instance.TextSize) or 14)))
		end

		configureTextObject(pageTitle, 30, 16)
		configureTextObject(pageSubtitle, 15, 9)
		configureTextObject(search, 14, 8)
		configureTextObject(sortButton, 14, 8)
		configureTextObject(emptyLabel, 16, 9)
		configureTextObject(countLabel, 12, 8)
		configureTextObject(prev, 14, 8)
		configureTextObject(pageLabel, 12, 8)
		configureTextObject(nextNode, 14, 8)
		local onActivated
		local v28 = false
		local v29 = false
		local v30 = false
		local v31 = false
		local v32 = nil
		local v40 = nil
		local v41 = nil
		local enableds = {}
		local childAddedConnection = nil
		local iconAddedConnection = nil
		local flag2 = false
		local v42 = {}
		local v43 = nil
		local v44 = false
		local v45 = 0

		for _, v46 in ipairs(v3) do
			configureTextObject(nav:FindFirstChild(modeConfigs[v46].Button), 13, 8)
		end

		function state2.applyDifficultyButtonSizing(p)
			local compactDifficultyButtonWidths = p and state2.compactDifficultyButtonWidths
				or state2.difficultyButtonWidths

			for i, v46 in ipairs(difficultyOrder) do
				local difficultyButton = state2.getDifficultyButton(v46)

				if not (difficultyButton and difficultyButton:IsA("TextButton")) then
					continue
				end

				difficultyButton.Name = v46
				difficultyButton.LayoutOrder = i
				difficultyButton.Size = UDim2.fromOffset(compactDifficultyButtonWidths[v46] or 72, 28)
				difficultyButton.Text = v46
				configureTextObject(difficultyButton, p and 11 or 12, 7)
			end
		end

		function state2.applyTopNavResponsiveSizing()
			local v46 = {
				Community = "Community Sheets",
				MIDI = "Community MIDI",
				Profile = "Profile",
				Reports = "Mod Panel",
				Hidden = "Hidden",
				Blocked = "Blocked",
				Publish = "Publish",
				Close = "x"
			}

			for childName, v47 in pairs({
				Community = 180,
				MIDI = 168,
				Profile = 108,
				Reports = 126,
				Hidden = 104,
				Blocked = 112,
				Publish = 118,
				Close = 38,
				ShieldToggle = 42
			}) do
				local guiObject = nav:FindFirstChild(childName)

				if not (guiObject and guiObject:IsA("GuiObject")) then
					continue
				end

				guiObject.Size = UDim2.fromOffset(v47, 40)

				if guiObject:IsA("TextButton") and v46[childName] then
					setTopNavButtonText(guiObject, v46[childName]) -- inferred equivalent call
					configureTextObject(guiObject, 13, 7)
				end

				local navIcon = guiObject:FindFirstChild("NavIcon")
				local buttonLabel = guiObject:FindFirstChild("ButtonLabel")

				if navIcon and navIcon:IsA("ImageLabel") then
					navIcon.Position = UDim2.fromOffset(12, 11)
					navIcon.Size = UDim2.fromOffset(16, 16)
				end

				if not (buttonLabel and buttonLabel:IsA("TextLabel")) then
					continue
				end

				if childName == "Close" then
					buttonLabel.Position = UDim2.fromScale(0.5, 0.5)
					buttonLabel.Size = UDim2.fromScale(1, 1)
				else
					buttonLabel.Position = UDim2.new(0, 34, 0.5, 0)
					buttonLabel.Size = UDim2.new(1, -44, 1, 0)
				end

				configureTextObject(buttonLabel, 13, 7)
			end

			local uiListLayout = nav:FindFirstChildOfClass("UIListLayout")

			if uiListLayout then
				uiListLayout.Padding = UDim.new(0, 8)
			end
		end
		function state2:applyModalScale(p, p2)
			if not (self and self:IsA("GuiObject")) then
				return
			end

			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(p, p2)
			local guiInset, v46 = GuiService:GetGuiInset()
			local v47 = math.max(220, viewportSize.X - 32)
			local v48 = math.max(260, viewportSize.Y - math.max(0, guiInset.Y) - math.max(0, v46.Y) - 32)
			local v49 = math.min(1, v47 / p, v48 / p2)
			self.AnchorPoint = Vector2.new(0.5, 0.5)
			self.Position = UDim2.fromScale(0.5, 0.5)
			self.Size = UDim2.fromOffset(p, p2)
			local responsiveScale = self:FindFirstChild("ResponsiveScale")

			if not responsiveScale then
				responsiveScale = Instance.new("UIScale")
				responsiveScale.Name = "ResponsiveScale"
				responsiveScale.Parent = self
			end

			responsiveScale.Scale = math.clamp(v49, 0.5, 1)
		end
		state2.applyDifficultyButtonSizing(false)
		configureTextObject(publish, 13, 8)
		configureTextObject(v, 13, 8)

		do
			local CommunitySheetsOverlayFactory2 = require(script.Parent:WaitForChild("CommunitySheetsOverlayFactory"))
			CommunitySheetsOverlayFactory = CommunitySheetsOverlayFactory2
		end

		CommunitySheetsOverlayRefs = CommunitySheetsOverlayFactory.Build(parent)

		moderationOverlay = CommunitySheetsOverlayRefs.ModerationOverlay
		moderationPanel = CommunitySheetsOverlayRefs.ModerationPanel
		moderationTitle = CommunitySheetsOverlayRefs.ModerationTitle
		moderationMessage = CommunitySheetsOverlayRefs.ModerationMessage
		moderationReasonBox = CommunitySheetsOverlayRefs.ModerationReasonBox
		moderationHideButton = CommunitySheetsOverlayRefs.ModerationHideButton
		moderationResolveButton = CommunitySheetsOverlayRefs.ModerationResolveButton
		moderationDeleteButton = CommunitySheetsOverlayRefs.ModerationDeleteButton
		moderationBlockButton = CommunitySheetsOverlayRefs.ModerationBlockButton
		moderationCancelButton = CommunitySheetsOverlayRefs.ModerationCancelButton

		midiPublishOverlay = CommunitySheetsOverlayRefs.MidiPublishOverlay
		midiPublishPanel = CommunitySheetsOverlayRefs.MidiPublishPanel
		midiPublishTitleBox = CommunitySheetsOverlayRefs.MidiPublishTitleBox
		midiPublishUrlBox = CommunitySheetsOverlayRefs.MidiPublishUrlBox
		midiPublishImageBox = CommunitySheetsOverlayRefs.MidiPublishImageIdBox
		midiPublishImagePreview = CommunitySheetsOverlayRefs.MidiPublishImagePreview
		midiPublishBrowseImageButton = CommunitySheetsOverlayRefs.MidiPublishBrowseImageButton
		midiPublishStatus = CommunitySheetsOverlayRefs.MidiPublishStatus
		midiPublishCostLabel = CommunitySheetsOverlayRefs.MidiPublishCostLabel
		midiPublishSubmitButton = CommunitySheetsOverlayRefs.MidiPublishSubmitButton
		midiPublishCancelButton = CommunitySheetsOverlayRefs.MidiPublishCancelButton
		midiPublishDifficultySelector = CommunitySheetsOverlayRefs.MidiPublishDifficultySelector
		midiPublishDifficultyIndicator = CommunitySheetsOverlayRefs.MidiPublishDifficultyIndicator
		midiPublishDifficultyButtons = CommunitySheetsOverlayRefs.MidiPublishDifficultyButtons
		midiRepairOverlay = CommunitySheetsOverlayRefs.MidiRepairOverlay
		midiRepairPanel = CommunitySheetsOverlayRefs.MidiRepairPanel
		midiRepairTargetLabel = CommunitySheetsOverlayRefs.MidiRepairTargetLabel
		midiRepairWarningPanel = CommunitySheetsOverlayRefs.MidiRepairWarningPanel
		midiRepairWarningText = CommunitySheetsOverlayRefs.MidiRepairWarningText
		midiRepairUrlBox = CommunitySheetsOverlayRefs.MidiRepairUrlBox
		midiRepairStatus = CommunitySheetsOverlayRefs.MidiRepairStatus
		midiRepairSubmitButton = CommunitySheetsOverlayRefs.MidiRepairSubmitButton
		midiRepairCancelButton = CommunitySheetsOverlayRefs.MidiRepairCancelButton
		midiRepairCloseButton = CommunitySheetsOverlayRefs.MidiRepairCloseButton

		do
			local function normalize(value) -- 13 equivalent calls inferred from this helper
				return tostring(value or ""):lower()
			end
		end

		do
			local function trimText(value) -- 20 equivalent calls inferred from this helper
				return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
			end
		end

		function state2.firstNonEmptyText(...)
			for i = 1, select("#", ...) do
				local v46 = trimText(select(i, ...)) -- inferred equivalent call

				if v46 ~= "" then
					return v46
				end
			end

			return ""
		end

		local function comma(p)
			local v46 = tostring((math.floor(tonumber(p) or 0)))

			repeat
				local v47
				v46, v47 = v46:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
			until v47 == 0

			return v46
		end

		do
			local function getDifficultyVisual(p) -- 6 equivalent calls inferred from this helper
				return v4[state2.getDifficultyDisplayLabel(p)] or v4.Default
			end
		end

		function state2:applyDifficultyBadgeStyle(p)
			if not (self and self:IsA("TextLabel")) then
				return
			end

			local difficultyVisual = getDifficultyVisual(p) -- inferred equivalent call
			self.Text = state2.getDifficultyDisplayLabel(p):upper()
			self.TextColor3 = difficultyVisual.Text
			self.BackgroundColor3 = difficultyVisual.Background
			self.BackgroundTransparency = 0.18
			self.BorderSizePixel = 0
			local uiCorner = self:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
			uiCorner.CornerRadius = UDim.new(0, 8)
			uiCorner.Parent = self
			local uiStroke = self:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uiStroke.Color = difficultyVisual.Border
			uiStroke.Thickness = 1
			uiStroke.Transparency = 0.08
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Enabled = true
			uiStroke.Parent = self
		end

		do
			local function shortSheetPreview(sheet) -- 1 equivalent call inferred from this helper
				local v46 = tostring(sheet or ""):gsub("%s+", " ")

				if v46 == "" then
					return "No preview available yet."
				end

				if #v46 > 92 then
					return v46:sub(1, 89) .. "..."
				end

				return v46
			end
		end

		do
			local function getSongSheet(p) -- 8 equivalent calls inferred from this helper
				return p and tostring(p.sheet or "") or ""
			end
		end

		function updateSheetPreviewScroll(scrollingFrame, textBox)
			if not (scrollingFrame and scrollingFrame:IsA("ScrollingFrame") and textBox and textBox:IsA("TextBox")) then
				return
			end

			scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			scrollingFrame.ScrollBarThickness = 6
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.AbsoluteSize.Y)
			scrollingFrame.CanvasPosition = Vector2.zero
			local uiPadding = scrollingFrame:FindFirstChildOfClass("UIPadding")

			if uiPadding then
				uiPadding.PaddingLeft = UDim.new(0, 0)
				uiPadding.PaddingRight = UDim.new(0, 0)
			end

			textBox.AutomaticSize = Enum.AutomaticSize.Y
			textBox.TextWrapped = true
			textBox.TextScaled = false
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.TextYAlignment = Enum.TextYAlignment.Top
			textBox.ClearTextOnFocus = false
			pcall(function()
				textBox.MultiLine = true
			end)

			local function resize()
				if not (scrollingFrame.Parent and textBox.Parent) then
					return
				end

				local v46 = math.max(160, scrollingFrame.AbsoluteSize.X - 20)
				local text = tostring(textBox.Text or "")
				local v47 = math.max(
					24,
					math.ceil(TextService:GetTextSize(
						(text == "" or not text) and " " or text,
						textBox.TextSize,
						textBox.Font,
						Vector2.new(v46, 1e999)
					).Y) + 8
				)
				textBox.Position = UDim2.fromOffset(8, 10)
				textBox.Size = UDim2.new(1, -20, 0, v47)
				scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame.AbsoluteSize.Y)
			end

			resize()
			task.defer(resize)
		end

		do
			local function getPianoUI() -- 4 equivalent calls inferred from this helper
				local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
				return playerGui and playerGui:FindFirstChild("PianoUI")
			end
		end

		local function getSheetsEditorBox()
			local pianoUI = getPianoUI() -- inferred equivalent call

			if not pianoUI then
				return nil
			end

			for _, frame in ipairs(pianoUI:GetDescendants()) do
				if not (frame.Name == "Sheets" and frame:IsA("Frame")) then
					continue
				end

				local card = frame:FindFirstChild("Card")
				local scroll = card and card:FindFirstChild("Scroll")
				local editor = scroll and scroll:FindFirstChild("Editor")

				if editor and editor:IsA("TextBox") then
					return editor
				end
			end

			return nil
		end

		local function getAutoPlayerControls()
			local pianoUI = getPianoUI() -- inferred equivalent call

			if not pianoUI then
				return nil
			end

			for _, frame in ipairs(pianoUI:GetDescendants()) do
				if not (frame.Name == "AutoPlayer" and frame:IsA("Frame")) then
					continue
				end

				local notes = frame:FindFirstChild("Notes", true)

				if notes and notes:IsA("TextBox") then
					return notes
				end
			end

			return nil
		end

		local function setInlineMessage(value, p) -- 25 equivalent calls inferred from this helper
			if state2.stopLoadingTextAnimation then
				state2.stopLoadingTextAnimation()
			end

			emptyLabel.Text = tostring(value or "")
			emptyLabel.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
		end

		local function applySheet(p): boolean
			if p then
				if
					getSongSheet(p) == "" -- inferred equivalent call
					and not (state2.ensureCommunitySheetLoaded and state2.ensureCommunitySheetLoaded(p))
				then
					return false
				end

				local songSheet = getSongSheet(p) -- inferred equivalent call

				if songSheet == "" then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("That sheet text is unavailable. Refresh and try again.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

					return false
				else
					local sheetsEditorBox = getSheetsEditorBox()
					local autoPlayerControls = getAutoPlayerControls()

					if sheetsEditorBox then
						sheetsEditorBox.Text = songSheet
					end

					if autoPlayerControls then
						autoPlayerControls.Text = songSheet
					end

					if sheetsEditorBox or autoPlayerControls then
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Loaded into Sheets and Autoplayer.")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

						return true
					end

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Open or sit at a piano first so Sheets can receive this.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

					return false
				end
			else
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Select a sheet first.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return false
			end
		end

		local function get2DHandler()
			local pianoUI = getPianoUI() -- inferred equivalent call
			local pianoMain = pianoUI and pianoUI:FindFirstChild("PianoMain")
			local pianoRoll2DHandler = pianoMain and pianoMain:FindFirstChild("PianoRoll2DHandler")

			if not pianoRoll2DHandler then
				return nil
			end

			local success, result = pcall(require, pianoRoll2DHandler)

			if success then
				return result
			end

			v2.Warn("[CommunitySheetsGui] Failed to load PianoRoll2DHandler:", result)
			return nil
		end

		do
			local function refresh2DOverlaySuppression()
				task.defer(function()
					local v46 = get2DHandler()

					if v46 and v46.EnsureExternalOverlaysSuppressed then
						v46.EnsureExternalOverlaysSuppressed()
					end
				end)
			end
		end

		do
			local function openIn2D(p)
				if p then
					if not applySheet(p) then
						return
					end

					local v46 = get2DHandler()

					if v46 then
						if v46.Open then
							v46.Open()
						end

						if v46.SetSheetSource then
							v46.SetSheetSource(tostring(p.name or "Sheet"), getSongSheet(p)) -- inferred equivalent call
						end

						if v46.ShowLoadedSourceModes then
							v46.ShowLoadedSourceModes()
						end

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Sent to 2D Mode.")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)
					else
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("2D Mode is not available yet.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					end
				else
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Select a sheet first.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end
			end
		end

		local function openCommunityMidi(pendingPreviewSong): boolean
			local v46 = ""

			if type(pendingPreviewSong) == "table" then
				for _, v48 in ipairs({ "publicId", "id", "uploadId", "backupId", "canonicalId" }) do
					local v49 = tostring(pendingPreviewSong[v48] or "")

					if v49 ~= "" then
						v46 = v49
						break
					end
				end
			end

			local url = tostring(pendingPreviewSong and pendingPreviewSong.url or "")

			if pendingPreviewSong and (url ~= "" or v46 ~= "") then
				if state2.isMidiUnavailableNoBackup(pendingPreviewSong) then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("This MIDI needs a new link before it can be loaded.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

					return false
				end

				OpenCommunityMidiUrl:Fire(url, pendingPreviewSong.name, v46, {
					BackupId = tostring(pendingPreviewSong.backupId or ""),
					CanonicalId = tostring(pendingPreviewSong.canonicalId or ""),
					PreferBackup = pendingPreviewSong.backupAvailable == true,
					UseBackup = pendingPreviewSong.backupAvailable == true
				})

				setInlineMessage( -- inferred equivalent call
					pendingPreviewSong.backupAvailable == true and "Opening saved MIDI backup." or "Opening MIDI player.",
					false
				)
				onActivated()
				return true
			end

			if state2.stopLoadingTextAnimation then
				state2.stopLoadingTextAnimation()
			end

			emptyLabel.Text = tostring("This MIDI is unavailable.")
			emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

			return false
		end

		local function normalizeReportDetails(reports2)
			local reportDetails = {}

			for _, v46 in ipairs(type(reports2) == "table" and reports2 or {}) do
				if type(v46) == "table" then
					table.insert(reportDetails, {
						reporterUserId = math.max(0, (math.floor(tonumber(v46.ReporterUserId or v46.UserId) or 0))),
						reporterName = tostring(v46.ReporterName or v46.Username or ""),
						reason = trimText(v46.Reason), -- inferred equivalent call
						reportedAt = math.max(0, (math.floor(tonumber(v46.ReportedAt) or 0)))
					})
				end
			end

			return reportDetails
		end

		do
			local function formatReportDate(reportedAt) -- 1 equivalent call inferred from this helper
				local v46 = math.max(0, (math.floor(tonumber(reportedAt) or 0)))

				if v46 <= 0 then
					return ""
				end

				local success, result = pcall(os.date, "%m/%d", v46)
				return success and tostring(result) or ""
			end
		end

		local function formatReportDetails(data, p)
			local reports2 = type(data) == "table" and type(data.reports) == "table" and data.reports or {}

			if #reports2 == 0 then
				return ""
			end

			local v46 = math.max(1, (math.floor(tonumber(p) or 3)))
			local v47 = {}

			for i = 1, math.min(#reports2, v46) do
				local report = reports2[i]
				local v48 = trimText(report.reporterName) -- inferred equivalent call

				if v48 == "" then
					v48 = "User " .. tostring(report.reporterUserId or 0)
				end

				local v49 = formatReportDate(report.reportedAt) -- inferred equivalent call
				local v50 = trimText(report.reason) -- inferred equivalent call
				local v51 = tostring(i) .. ". " .. v48

				if v49 ~= "" then
					v51 ..= " " .. v49
				end

				if v50 ~= "" then
					v51 ..= ": " .. v50
				end

				if #v51 > 112 then
					v51 = v51:sub(1, 109) .. "..."
				end

				table.insert(v47, v51)
			end

			if v46 < #reports2 then
				table.insert(v47, "+" .. tostring(#reports2 - v46) .. " more report(s)")
			end

			return table.concat(v47, "\n")
		end

		local function normalizeCommunitySong(p)
			local v46 = type(p) == "table" and p or {}
			local creatorDisplayName = tostring(v46.CreatorDisplayName or v46.CreatorName or "Player")
			local ownerUserId = tonumber(v46.OwnerUserId) or 0
			local firstNonEmptyText = state2.firstNonEmptyText(v46.Description)
			local preview = state2.firstNonEmptyText(firstNonEmptyText, v46.Preview, v46.SheetPreview)

			if preview == "" then
				preview = tostring(v46.Sheet or ""):gsub("%s+", " ")

				if preview == "" then
					preview = "No preview available yet."
				elseif #preview > 92 then
					preview = preview:sub(1, 89) .. "..."
				end
			end

			local communitySong = {}
			communitySong.id = tostring(v46.PublicId or v46.Id or "")
			communitySong.sheetId = tostring(v46.SheetId or "")
			communitySong.name = tostring(v46.Name or "Untitled Sheet")
			communitySong.category = tostring(v46.Category or "By " .. creatorDisplayName)
			communitySong.difficulty = tostring(v46.Difficulty or "Easy")
			communitySong.transpose = tonumber(v46.Transpose) or 0
			communitySong.sheet = tostring(v46.Sheet or "")
			communitySong.sheetLoaded = v46.SheetLoaded == true or tostring(v46.Sheet or "") ~= ""
			communitySong.hasSheetText = v46.HasSheetText == true or tostring(v46.Sheet or "") ~= ""
			communitySong.sheetTextLength = math.max(
				0,
				(math.floor(tonumber(v46.SheetTextLength) or #tostring(v46.Sheet or "")))
			)
			communitySong.catalogShard = math.max(0, (math.floor(tonumber(v46.CatalogShard or v46.Shard) or 0)))
			communitySong.catalogPage = math.max(0, (math.floor(tonumber(v46.CatalogPage or v46.Page) or 0)))
			communitySong.description = firstNonEmptyText
			communitySong.preview = preview
			communitySong.imageAssetId = tostring(v46.ImageAssetId or v46.ImageId or "")
			communitySong.source = "Community"
			communitySong.mode = "Community"
			communitySong.creatorName = tostring(v46.CreatorName or creatorDisplayName)
			communitySong.creatorDisplayName = creatorDisplayName
			communitySong.ownerUserId = ownerUserId
			communitySong.ownedByLocalPlayer = ownerUserId == LocalPlayer.UserId
			communitySong.likes = tonumber(v46.FavoriteCount or v46.Likes or v46.Favorites) or 0
			communitySong.plays = tonumber(v46.PlayCount or v46.Plays) or 0
			communitySong.reportCount = tonumber(v46.ReportCount) or 0
			communitySong.reports = normalizeReportDetails(v46.Reports)
			communitySong.isFavorited = v46.IsFavorited == true
			communitySong.publishedAt = tonumber(v46.PublishedAt) or 0
			communitySong.updatedAt = tonumber(v46.UpdatedAt) or 0
			communitySong.moderationAction = tostring(v46.ModerationAction or v46.IsDeleted and "delete" or v46.IsHidden and "hide" or "")
			communitySong.moderationReason = tostring(v46.ModerationReason or type(v46.Moderation) == "table" and v46.Moderation.Reason or "")
			local v48 = v46.ModeratedAt

			if not v48 then
				if type(v46.Moderation) == "table" then
					v48 = v46.Moderation.ModeratedAt
				else
					v48 = false
				end
			end

			communitySong.moderatedAt = tonumber(v48) or 0
			communitySong.moderatorName = tostring(v46.ModeratorName or type(v46.Moderation) == "table" and v46.Moderation.ModeratorName or "")
			local isHidden

			if v46.IsHidden == true then
				isHidden = true
			elseif type(v46.Moderation) == "table" then
				isHidden = v46.Moderation.Hidden == true
			else
				isHidden = false
			end

			communitySong.isHidden = isHidden
			local isDeleted

			if v46.IsDeleted == true then
				isDeleted = true
			elseif type(v46.Moderation) == "table" then
				isDeleted = v46.Moderation.Deleted == true
			else
				isDeleted = false
			end

			communitySong.isDeleted = isDeleted
			return communitySong
		end

		function state2:ensureCommunitySheetLoaded(): boolean
			if type(self) ~= "table" or tostring(self.mode or "") ~= "Community" then
				return false
			end

			if getSongSheet(self) ~= "" then -- inferred equivalent call
				self.sheetLoaded = true
				return true
			end

			local id = tostring(self.id or self.publicId or "")

			if id == "" then
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("That sheet was not found.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return false
			else
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Loading sheet text...")
				emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

				local success, result, v46, v47 = pcall(function()
					return getCommunitySheets:InvokeServer({
						Mode = "SheetDetails",
						PublicId = id,
						CatalogShard = math.max(0, (math.floor(tonumber(self.catalogShard) or 0))),
						CatalogPage = math.max(0, (math.floor(tonumber(self.catalogPage) or 0)))
					})
				end)

				if success and result and type(v47) == "table" then
					local communitySong = normalizeCommunitySong(v47)

					for k, v48 in pairs(communitySong) do
						self[k] = v48
					end

					if getSongSheet(self) == "" then -- inferred equivalent call
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("That sheet text is unavailable.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

						return false
					end

					self.sheetLoaded = true

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					return true
				end

				if success then
					setInlineMessage(v46 or "Could not load that sheet.", true) -- inferred equivalent call
				else
					v2.Warn("[CommunitySheetsGui] SheetDetails failed:", result)

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Could not reach Community Sheets.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end

				return false
			end
		end

		local function formatCommunityMidiBackupLabel(p)
			local v46 = type(p) == "table" and p or {}
			local ownerUserId = math.floor(tonumber(v46.OwnerUserId or v46.ownerUserId) or 0)
			local v47

			if ownerUserId > 0 then
				v47 = ownerUserId == LocalPlayer.UserId
			else
				v47 = false
			end

			local function stripBackupSize(value)
				return (tostring(value or ""):gsub("%s*%(%d+%s*KB%)$", ""))
			end

			local function withOwnerSize(p2, p3) -- 3 equivalent calls inferred from this helper
				local v48 = math.max(0, (math.floor(tonumber(p3) or 0)))

				if v47 and not (v48 <= 0) then
					return p2 .. " (" .. comma(math.max(1, (math.floor((v48 + 999) / 1000)))) .. " KB)"
				end

				return p2
			end

			local backupLabel = tostring(v46.BackupLabel or "")

			if backupLabel ~= "" then
				return v47 and backupLabel or ""
			end

			if not v47 then
				return ""
			end

			local backupStatus = tostring(v46.BackupStatus or "None")
			local urlStatus = tostring(v46.UrlStatus or "Unknown")
			local v48 = math.max(0, (math.floor(tonumber(v46.BackupSize) or 0)))

			if urlStatus == "Unavailable" and v46.BackupAvailable == true then
				return withOwnerSize("Backup available", v48) -- inferred equivalent call
			end

			if urlStatus == "Unavailable" then
				return "Original link unavailable"
			end

			if backupStatus == "TooLarge" then
				return withOwnerSize("Original link only", v48) -- inferred equivalent call
			end

			if v46.BackupAvailable ~= true then
				return "Original link"
			end

			return withOwnerSize("Backup saved", v48) -- inferred equivalent call
		end

		local function normalizeCommunityMidi(p)
			local v46 = type(p) == "table" and p or {}
			local creatorDisplayName = tostring(v46.CreatorDisplayName or v46.CreatorName or "Player")
			local backupStatus = tostring(v46.BackupStatus or "None")
			local urlStatus = tostring(v46.UrlStatus or "Unknown")
			local backupSize = tonumber(v46.BackupSize) or 0
			local backupLabel = formatCommunityMidiBackupLabel(v46)
			local v48 = (tonumber(v46.OwnerUserId) or 0) == LocalPlayer.UserId
			local firstNonEmptyText = state2.firstNonEmptyText(v46.Description, v46.Preview)
			local preview

			if firstNonEmptyText == "" then
				preview = (not v48 or backupLabel == "")
					and (urlStatus == "Unavailable" and v46.BackupAvailable ~= true and "MIDI unavailable" or "Ready to play")
					or backupLabel
			else
				preview = firstNonEmptyText
			end

			local publicId = tostring(v46.PublicId or v46.Id or v46.UploadId or "")
			local backupId = tostring(v46.BackupId or v46.BackupKey or v46.CanonicalId or v46.PublicId or v46.Id or v46.UploadId or "")
			local id

			if publicId == "" or not publicId then
				id = backupId
			else
				id = publicId
			end

			local communityMidi = {
				id = id,
				publicId = publicId,
				backupId = backupId,
				canonicalId = tostring(v46.CanonicalId or v46.BackupKey or v46.BackupId or publicId or backupId or ""),
				name = tostring(v46.Title or v46.Name or "Untitled MIDI"),
				category = tostring(v46.Category or "By " .. creatorDisplayName),
				difficulty = tostring(v46.Difficulty or "Easy"),
				transpose = 0,
				sheet = tostring(v46.Url or ""),
				description = firstNonEmptyText,
				preview = preview,
				backupLabel = backupLabel,
				imageAssetId = tostring(v46.ImageAssetId or v46.ImageId or ""),
				url = tostring(v46.Url or ""),
				source = "MIDI",
				mode = "MIDI",
				isPublished = v46.IsPublished ~= false,
				ownerUnpublished = v46.OwnerUnpublished == true or v46.OwnerHidden == true,
				creatorName = tostring(v46.CreatorName or creatorDisplayName),
				creatorDisplayName = creatorDisplayName,
				ownerUserId = tonumber(v46.OwnerUserId) or 0,
				ownedByLocalPlayer = (tonumber(v46.OwnerUserId) or 0) == LocalPlayer.UserId,
				likes = tonumber(v46.FavoriteCount or v46.Likes or v46.Favorites) or 0,
				plays = tonumber(v46.PlayCount or v46.Plays) or 0,
				reportCount = tonumber(v46.ReportCount) or 0,
				reports = normalizeReportDetails(v46.Reports),
				isFavorited = v46.IsFavorited == true,
				backupAvailable = v46.BackupAvailable == true,
				backupStatus = backupStatus,
				backupSize = backupSize,
				backupState = tostring(v46.BackupState or ""),
				urlStatus = urlStatus,
				publishedAt = tonumber(v46.PublishedAt) or 0,
				updatedAt = tonumber(v46.UpdatedAt) or 0,
				moderationAction = tostring(v46.ModerationAction or v46.IsDeleted and "delete" or v46.IsHidden and "hide" or ""),
				moderationReason = tostring(v46.ModerationReason or type(v46.Moderation) == "table" and v46.Moderation.Reason or "")
			}
			local v51 = v46.ModeratedAt

			if not v51 then
				if type(v46.Moderation) == "table" then
					v51 = v46.Moderation.ModeratedAt
				else
					v51 = false
				end
			end

			communityMidi.moderatedAt = tonumber(v51) or 0
			communityMidi.moderatorName = tostring(v46.ModeratorName or type(v46.Moderation) == "table" and v46.Moderation.ModeratorName or "")
			local isHidden

			if v46.IsHidden == true then
				isHidden = true
			elseif type(v46.Moderation) == "table" then
				isHidden = v46.Moderation.Hidden == true
			else
				isHidden = false
			end

			communityMidi.isHidden = isHidden
			local isDeleted

			if v46.IsDeleted == true then
				isDeleted = true
			elseif type(v46.Moderation) == "table" then
				isDeleted = v46.Moderation.Deleted == true
			else
				isDeleted = false
			end

			communityMidi.isDeleted = isDeleted
			return communityMidi
		end

		function state2.hasMidiBackup(data): boolean
			if type(data) == "table" then
				if data.backupAvailable == true or data.BackupAvailable == true or data.BackupStored == true then
					return true
				elseif type(data.BackupData) == "string" then
					return data.BackupData ~= ""
				else
					return false
				end
			else
				return false
			end
		end

		function state2.isMidiUnavailableNoBackup(data): boolean
			return type(data) == "table"
				and tostring(data.mode or data.Mode or "MIDI") == "MIDI"
				and tostring(data.urlStatus or data.UrlStatus or "") == "Unavailable"
				and not state2.hasMidiBackup(data)
		end

		function state2.isMidiOriginalLinkOnly(data): boolean
			return type(data) == "table"
				and tostring(data.mode or data.Mode or "MIDI") == "MIDI"
				and tostring(data.backupStatus or data.BackupStatus or "") == "TooLarge"
				and not state2.hasMidiBackup(data)
		end

		do
			local function getModeConfig() -- 5 equivalent calls inferred from this helper
				return modeConfigs[selectedMode] or modeConfigs.Community
			end
		end

		local function getCommunityMidiLookupId(p)
			if type(p) ~= "table" then
				return ""
			end

			for _, v46 in ipairs({ "publicId", "id", "uploadId", "backupId", "canonicalId" }) do
				local v47 = tostring(p[v46] or "")

				if v47 ~= "" then
					return v47
				end
			end

			return ""
		end

		do
			local function canViewReports(): boolean -- 6 equivalent calls inferred from this helper
				return v28 == true or v29 == true
			end
		end

		do
			local function canViewHiddenUploads(): boolean -- 6 equivalent calls inferred from this helper
				return v30 == true or v31 == true
			end
		end

		local function getReportedSongs()
			local reportedSongs = {}

			if v28 then
				for _, v46 in ipairs(v6) do
					if (tonumber(v46.reportCount) or 0) > 0 then
						table.insert(reportedSongs, v46)
					end
				end
			end

			if v29 then
				for _, v46 in ipairs(v7) do
					if (tonumber(v46.reportCount) or 0) > 0 then
						table.insert(reportedSongs, v46)
					end
				end
			end

			return reportedSongs
		end

		local function getHiddenSongs()
			local hiddenSongs = {}

			if v30 then
				for _, v46 in ipairs(v8) do
					table.insert(hiddenSongs, v46)
				end
			end

			if v31 then
				for _, v46 in ipairs(v9) do
					table.insert(hiddenSongs, v46)
				end
			end

			return hiddenSongs
		end

		local function getModeSongs()
			if selectedMode == "Community" then
				return v6
			elseif selectedMode == "MIDI" then
				return v7
			elseif selectedMode == "Profile" then
				return {}
			elseif selectedMode == "Reports" then
				return getReportedSongs()
			elseif selectedMode == "Hidden" then
				return getHiddenSongs()
			end

			return {}
		end

		local function matchesSong(data): boolean
			if
				selectedMode == "Reports" and (tonumber(data.reportCount) or 0) <= 0
				or selectedMode == "Hidden" and data.isHidden ~= true and data.isDeleted ~= true
			then
				return false
			end

			if
				selectedDifficulty ~= "All"
				and state2.getDifficultyFilterKey(data.difficulty) ~= state2.getDifficultyFilterKey(selectedDifficulty)
			then
				return false
			end

			local v46 = normalize(state2.searchText or search.Text) -- inferred equivalent call

			if v46 == "" then
				return true
			end

			return normalize(data.name):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.category):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.difficulty):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(state2.getDifficultyDisplayLabel(data.difficulty)):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.creatorName):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.creatorDisplayName):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.sheet):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.description):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.preview):find(v46, 1, true) ~= nil -- inferred equivalent call
				or normalize(data.url):find(v46, 1, true) ~= nil -- inferred equivalent call
		end

		local function clearCards()
			for _, connection in ipairs(connections) do
				connection:Disconnect()
			end

			table.clear(connections)

			for _, v46 in ipairs({ cardGrid, controls.CardGrid }) do
				for _, child in ipairs(v46:GetChildren()) do
					if
						child.Name == "SongCard"
						or child.Name == "CommunityHome"
						or child.Name == "BlockedUserCard"
						or child.Name == "ProfileMobileView"
					then
						child:Destroy()
					end
				end
			end
		end

		function state2.isCurrentCatalogLoading(): boolean
			if selectedMode == "Community" then
				return v18 == true and v19 == nil
			elseif selectedMode == "MIDI" then
				return v21 == true and v22 == nil
			else
				if selectedMode ~= "Reports" and selectedMode ~= "Hidden" then
					return false
				end

				return (v18 == true or v21 == true or not (v17 and v20)) and not (v19 and v22)
			end
		end

		local function styleButton(button, accent, enabled)
			local backgroundColor = Color3.fromRGB(34, 38, 50)
			backgroundColor = enabled and backgroundColor:Lerp(accent, 0.22) or backgroundColor
			button.BackgroundColor3 = backgroundColor
			button.BackgroundTransparency = enabled and 0 or 0.04
			setTopNavButtonColor(button, enabled and accent or Color3.fromRGB(174, 181, 195))
			local buttonLabel = button:FindFirstChild("ButtonLabel")

			if buttonLabel and buttonLabel:IsA("TextLabel") then
				buttonLabel.Font = enabled and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
			end

			local selectionStroke = button:FindFirstChild("SelectionStroke")

			if not selectionStroke then
				selectionStroke = Instance.new("UIStroke")
				selectionStroke.Name = "SelectionStroke"
				selectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				selectionStroke.LineJoinMode = Enum.LineJoinMode.Round
				selectionStroke.Parent = button
			end

			selectionStroke.Color = accent
			selectionStroke.Thickness = 1
			selectionStroke.Transparency = enabled and 0.32 or 1
			selectionStroke.Enabled = enabled
		end

		local function updateNavVisuals()
			local visible = canViewReports() or canViewHiddenUploads() -- inferred equivalent call

			if state2.moderationTabsEnabled and not visible then
				state2.moderationTabsEnabled = false
			end

			for _, v47 in ipairs(v3) do
				local v48 = modeConfigs[v47]
				local button = nav:FindFirstChild(v48.Button)

				if not (button and button:IsA("TextButton")) then
					continue
				end

				if v47 == "Reports" then
					button.Visible = state2.moderationTabsEnabled and canViewReports() -- inferred equivalent call
				elseif v47 == "Hidden" then
					button.Visible = state2.moderationTabsEnabled and canViewHiddenUploads() -- inferred equivalent call
				elseif v47 == "Blocked" then
					button.Visible = state2.moderationTabsEnabled and v30
				else
					button.Visible = not state2.moderationTabsEnabled
				end

				local enabled = v47 == selectedMode
				styleButton(button, v48.Accent, enabled)
			end

			local shieldToggle = nav:WaitForChild("ShieldToggle")
			shieldToggle.Visible = visible
			local color = state2.moderationTabsEnabled and Color3.fromRGB(255, 101, 132) or Color3.fromRGB(37, 174, 255)
			shieldToggle.BackgroundColor3 = Color3.fromRGB(34, 38, 50):Lerp(
				color,
				state2.moderationTabsEnabled and 0.2 or 0.1
			)
			local selectionStroke = shieldToggle:FindFirstChild("SelectionStroke") or Instance.new("UIStroke")
			selectionStroke.Name = "SelectionStroke"
			selectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			selectionStroke.Color = color
			selectionStroke.Thickness = 1
			selectionStroke.Transparency = 0.45
			selectionStroke.Parent = shieldToggle
			local shieldIcon = shieldToggle:FindFirstChild("ShieldIcon")

			if shieldIcon and shieldIcon:IsA("TextLabel") then
				shieldIcon.TextColor3 = color
			elseif shieldIcon and shieldIcon:IsA("ImageLabel") then
				shieldIcon.Image = "rbxassetid://139658992048194"
				shieldIcon.ImageColor3 = color
				shieldIcon.ScaleType = Enum.ScaleType.Fit
			end

			if state2.updateMobileNavVisuals then
				state2.updateMobileNavVisuals()
			end
		end

		function state2.getDifficultyFilterVisual(p)
			if p == "All" then
				return {
					Background = Color3.fromRGB(32, 40, 56),
					Border = Color3.fromRGB(72, 111, 164)
				}
			end

			local difficultyVisual = getDifficultyVisual(p) -- inferred equivalent call
			return {
				Background = Color3.fromRGB(34, 38, 50):Lerp(difficultyVisual.Background, 0.46),
				Border = difficultyVisual.Border
			}
		end

		function state2.ensureDifficultySelectionIndicator()
			local difficultyBarBackground = toolbar:FindFirstChild("DifficultyBarBackground")

			if difficultyBarBackground and not difficultyBarBackground:IsA("Frame") then
				difficultyBarBackground:Destroy()
				difficultyBarBackground = nil
			end

			if not difficultyBarBackground then
				difficultyBarBackground = Instance.new("Frame")
				difficultyBarBackground.Name = "DifficultyBarBackground"
				difficultyBarBackground.Active = false
				difficultyBarBackground.BorderSizePixel = 0
				difficultyBarBackground.Parent = toolbar
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 8)
				uiCorner.Parent = difficultyBarBackground
			end

			difficultyBarBackground.Position = difficultyBar.Position
			difficultyBarBackground.Size = difficultyBar.Size
			difficultyBarBackground.BackgroundColor3 = difficultyBar.BackgroundColor3
			difficultyBarBackground.BackgroundTransparency = 0
			difficultyBarBackground.Visible = difficultyBar.Visible
			difficultyBarBackground.ZIndex = math.max(1, toolbar.ZIndex + 1)

			local difficultySelectionIndicator = toolbar:FindFirstChild("DifficultySelectionIndicator")

			if difficultySelectionIndicator and not difficultySelectionIndicator:IsA("Frame") then
				difficultySelectionIndicator:Destroy()
				difficultySelectionIndicator = nil
			end

			if not difficultySelectionIndicator then
				difficultySelectionIndicator = Instance.new("Frame")
				difficultySelectionIndicator.Name = "DifficultySelectionIndicator"
				difficultySelectionIndicator.Active = false
				difficultySelectionIndicator.BorderSizePixel = 0
				difficultySelectionIndicator.BackgroundColor3 = Color3.fromRGB(32, 40, 56)
				difficultySelectionIndicator.Parent = toolbar

				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 8)
				uiCorner.Parent = difficultySelectionIndicator

				local selectionStroke = Instance.new("UIStroke")
				selectionStroke.Name = "SelectionStroke"
				selectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				selectionStroke.LineJoinMode = Enum.LineJoinMode.Round
				selectionStroke.Thickness = 1
				selectionStroke.Transparency = 0.42
				selectionStroke.Parent = difficultySelectionIndicator
			end

			difficultySelectionIndicator.ZIndex = difficultyBarBackground.ZIndex + 1
			difficultyBar.BackgroundTransparency = 1
			difficultyBar.ZIndex = difficultyBarBackground.ZIndex + 2
			return difficultySelectionIndicator
		end

		function state2.moveDifficultySelectionIndicator(p)
			local difficultyButton = state2.getDifficultyButton(selectedDifficulty)

			if not (difficultyButton and difficultyButton:IsA("TextButton")) then
				return
			end

			local difficultySelectionIndicator = state2.ensureDifficultySelectionIndicator()
			local difficultyFilterVisual = state2.getDifficultyFilterVisual(selectedDifficulty)
			local TweenService = game:GetService("TweenService")
			local udim = UDim2.fromOffset(
				math.round(difficultyButton.AbsolutePosition.X - toolbar.AbsolutePosition.X),
				(math.round(difficultyButton.AbsolutePosition.Y - toolbar.AbsolutePosition.Y))
			)

			local udim2 = UDim2.fromOffset(
				math.round(difficultyButton.AbsoluteSize.X),
				(math.round(difficultyButton.AbsoluteSize.Y))
			)

			difficultySelectionIndicator.Visible = difficultyBar.Visible and difficultyButton.Visible
			local difficultyBarBackground = toolbar:FindFirstChild("DifficultyBarBackground")

			if difficultyBarBackground and difficultyBarBackground:IsA("Frame") then
				difficultyBarBackground.Visible = difficultyBar.Visible
				difficultyBarBackground.Position = difficultyBar.Position
				difficultyBarBackground.Size = difficultyBar.Size
				difficultySelectionIndicator.ZIndex = difficultyBarBackground.ZIndex + 1
			end

			if state2.difficultyIndicatorTween then
				state2.difficultyIndicatorTween:Cancel()
				state2.difficultyIndicatorTween = nil
			end

			if state2.difficultyIndicatorStrokeTween then
				state2.difficultyIndicatorStrokeTween:Cancel()
				state2.difficultyIndicatorStrokeTween = nil
			end

			local selectionStroke = difficultySelectionIndicator:FindFirstChild("SelectionStroke")

			if p and difficultySelectionIndicator.Visible then
				local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				local tween = TweenService:Create(difficultySelectionIndicator, tweenInfo, {
					Position = udim,
					Size = udim2,
					BackgroundColor3 = difficultyFilterVisual.Background
				})

				state2.difficultyIndicatorTween = tween
				tween.Completed:Once(function()
					if state2.difficultyIndicatorTween == tween then
						state2.difficultyIndicatorTween = nil
					end
				end)
				tween:Play()

				if selectionStroke and selectionStroke:IsA("UIStroke") then
					local tween2 = TweenService:Create(selectionStroke, tweenInfo, {
						Color = difficultyFilterVisual.Border
					})
					state2.difficultyIndicatorStrokeTween = tween2
					tween2.Completed:Once(function()
						if state2.difficultyIndicatorStrokeTween == tween2 then
							state2.difficultyIndicatorStrokeTween = nil
						end
					end)
					tween2:Play()
				end
			else
				difficultySelectionIndicator.Position = udim
				difficultySelectionIndicator.Size = udim2
				difficultySelectionIndicator.BackgroundColor3 = difficultyFilterVisual.Background

				if selectionStroke and selectionStroke:IsA("UIStroke") then
					selectionStroke.Color = difficultyFilterVisual.Border
				end
			end
		end

		local function updateDifficultyVisuals(p)
			difficultyBar.ClipsDescendants = true
			local v46 = content.AbsoluteSize.X < 760
			state2.applyDifficultyButtonSizing(v46)

			for _, v47 in ipairs(difficultyOrder) do
				local difficultyButton = state2.getDifficultyButton(v47)

				if not (difficultyButton and difficultyButton:IsA("TextButton")) then
					continue
				end

				local v48 = selectedDifficulty == v47
				difficultyButton.AutoButtonColor = false
				difficultyButton.BorderSizePixel = 0
				difficultyButton.BackgroundTransparency = 1
				difficultyButton.TextColor3 = v48 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 166, 180)
				difficultyButton.Font = v48 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
				difficultyButton.ZIndex = difficultyBar.ZIndex + 1
				local v49 = difficultyButton:FindFirstChildOfClass("UICorner")

				if not v49 then
					v49 = Instance.new("UICorner")
					v49.Parent = difficultyButton
				end

				v49.CornerRadius = UDim.new(0, 8)
			end

			task.defer(function()
				state2.moveDifficultySelectionIndicator(p == true)
			end)
		end

		local function setPagerButton(instance, active)
			instance.Active = active
			instance.AutoButtonColor = false
			instance.Text = ""
			instance.TextTransparency = 1
			instance.BackgroundColor3 = active and Color3.fromRGB(43, 48, 62) or Color3.fromRGB(26, 29, 38)
			instance.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(96, 103, 118)
			local arrowIcon = instance:FindFirstChild("ArrowIcon")

			if arrowIcon and arrowIcon:IsA("ImageLabel") then
				arrowIcon.ImageColor3 = active and Color3.fromRGB(235, 239, 248) or Color3.fromRGB(96, 103, 118)
			end
		end

		do
			local function formatAbsoluteUploadDate(p) -- 1 equivalent call inferred from this helper
				local success, result = pcall(function()
					return DateTime.fromUnixTimestamp(p):FormatLocalTime("MMM D, YYYY", "en-us")
				end)

				return success and tostring(result) or "Date unavailable"
			end
		end

		local function formatUploadDate(publishedAt)
			local v46 = math.max(0, (math.floor(tonumber(publishedAt) or 0)))

			if v46 <= 0 then
				return "Date unavailable"
			end

			local v47 = os.time() - v46

			if v47 < 0 then
				return formatAbsoluteUploadDate(v46) -- inferred equivalent call
			end

			if v47 < 60 then
				return "just now"
			end

			if v47 < 3600 then
				return tostring((math.floor(v47 / 60))) .. "m ago"
			end

			if v47 < 86400 then
				return tostring((math.floor(v47 / 3600))) .. "h ago"
			end

			return tostring((math.floor(v47 / 86400))) .. "d ago"
		end

		do
			local function getSongSortTime(p) -- 12 equivalent calls inferred from this helper
				local publishedAt = tonumber(p.publishedAt) or 0
				return publishedAt > 0 and publishedAt or tonumber(p.updatedAt) or 0
			end
		end

		do
			local function compareByName(a, b): boolean -- 10 equivalent calls inferred from this helper
				return tostring(a.name):lower() < tostring(b.name):lower()
			end
		end

		local function sortFilteredSongs()
			if selectedMode == "Hidden" then
				table.sort(v10, function(a, b)
					local v46 = math.max(tonumber(a.moderatedAt) or 0, tonumber(a.updatedAt) or 0)
					local v47 = math.max(tonumber(b.moderatedAt) or 0, tonumber(b.updatedAt) or 0)

					if v46 == v47 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return v47 < v46
				end)
			elseif selectedMode == "Reports" then
				table.sort(v10, function(a, b)
					local reportCount = tonumber(a.reportCount) or 0
					local reportCount2 = tonumber(b.reportCount) or 0

					if reportCount ~= reportCount2 then
						return reportCount2 < reportCount
					end

					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime2 < songSortTime
				end)
			elseif state2.sortMode == "Newest" then
				table.sort(v10, function(a, b)
					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime2 < songSortTime
				end)
			elseif state2.sortMode == "Oldest" then
				table.sort(v10, function(a, b)
					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime < songSortTime2
				end)
			elseif state2.sortMode == "TopLiked" then
				table.sort(v10, function(a, b)
					local likes = tonumber(a.likes) or 0
					local likes2 = tonumber(b.likes) or 0

					if likes == likes2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return likes2 < likes
				end)
			elseif state2.sortMode == "MostPlayed" then
				table.sort(v10, function(a, b)
					local plays = tonumber(a.plays) or 0
					local plays2 = tonumber(b.plays) or 0

					if plays == plays2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return plays2 < plays
				end)
			else
				table.sort(v10, function(a, b)
					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime2 < songSortTime
				end)
			end
		end

		function state2.getTrendingScore(p)
			return (tonumber(p.likes) or 0) * 5 + (tonumber(p.plays) or 0)
		end

		function state2.copySongList(list)
			local result = {}

			for _, item in ipairs(list) do
				table.insert(result, item)
			end

			return result
		end

		function state2.getCommunitySectionSongs(p, p2)
			local copySongList = state2.copySongList(v10)

			if p == "Newest" then
				table.sort(copySongList, function(a, b)
					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime2 < songSortTime
				end)
			elseif p == "TopAllTime" then
				table.sort(copySongList, function(a, b)
					local likes = tonumber(a.likes) or 0
					local likes2 = tonumber(b.likes) or 0

					if likes ~= likes2 then
						return likes2 < likes
					end

					local plays = tonumber(a.plays) or 0
					local plays2 = tonumber(b.plays) or 0

					if plays == plays2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return plays2 < plays
				end)
			else
				table.sort(copySongList, function(a, b)
					local trendingScore = state2.getTrendingScore(a)
					local trendingScore2 = state2.getTrendingScore(b)

					if trendingScore ~= trendingScore2 then
						return trendingScore2 < trendingScore
					end

					local songSortTime = getSongSortTime(a) -- inferred equivalent call
					local songSortTime2 = getSongSortTime(b) -- inferred equivalent call

					if songSortTime == songSortTime2 then
						return compareByName(a, b) -- inferred equivalent call
					end

					return songSortTime2 < songSortTime
				end)
			end

			local communitySectionSongs = {}

			for i = 1, math.min(p2, #copySongList) do
				table.insert(communitySectionSongs, copySongList[i])
			end

			return communitySectionSongs
		end

		local function getEmptyText()
			if selectedMode == "Hidden" then
				if v18 or v21 or not (v17 and v20) then
					return "Loading hidden uploads..."
				end

				if not canViewHiddenUploads() then -- inferred equivalent call
					return "Only high-rank moderators can restore hidden uploads."
				end

				if v19 and v22 then
					return "Could not load hidden uploads."
				end
			elseif selectedMode == "Reports" then
				if v18 or v21 or not (v17 and v20) then
					return "Loading reported uploads..."
				end

				if not canViewReports() then -- inferred equivalent call
					return "Only moderators can view reported uploads."
				end

				if v19 and v22 then
					return "Could not load reported uploads."
				end
			else
				if v18 and selectedMode == "Community" then
					return "Loading community sheets..."
				end

				if v19 and selectedMode == "Community" then
					return v19
				end

				if v21 and selectedMode == "MIDI" then
					return "Loading community MIDI..."
				end

				if v22 and selectedMode == "MIDI" then
					return v22
				end
			end

			return getModeConfig().Empty -- inferred equivalent call
		end

		function state2.getLoadingTextWithDots()
			local v46 = tostring(getEmptyText() or ""):gsub("%.*$", "")
			local v47 = v46 == "" and "Loading" or v46

			local v48 = math.floor(os.clock() / 0.42) % 3 + 1
			return v47 .. string.rep(".", v48)
		end

		function state2.stopLoadingTextAnimation()
			state2.loadingTextAnimationToken = (state2.loadingTextAnimationToken or 0) + 1
			state2.loadingTextAnimationActive = false
		end

		function state2:startLoadingTextAnimation(p)
			if not (self and self:IsA("TextLabel")) then
				return
			end

			local loadingTextAnimationKey = tostring(selectedMode) .. "|" .. self:GetFullName()

			if
				state2.loadingTextAnimationActive == true
				and state2.loadingTextAnimationKey == loadingTextAnimationKey
			then
				self.Text = state2.getLoadingTextWithDots()
				self.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
			else
				state2.stopLoadingTextAnimation()
				local loadingTextAnimationToken = state2.loadingTextAnimationToken
				state2.loadingTextAnimationActive = true
				state2.loadingTextAnimationKey = loadingTextAnimationKey
				task.spawn(function()
					while
						state2.loadingTextAnimationToken == loadingTextAnimationToken
						and root.Visible
						and self.Parent
					do
						self.Text = state2.getLoadingTextWithDots()
						self.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						task.wait(0.42)
					end
				end)
			end
		end

		local fn
		local fn2
		local fn3
		local fn4
		local fn5
		local fn6

		local fn7
		local getDefaultSheetCardImage

		do
			local function setMidiPublishStatus(value, p) -- 2 equivalent calls inferred from this helper
				midiPublishStatus.Text = tostring(value or "")
				midiPublishStatus.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(160, 168, 184)
			end
		end

		function state2.updateMidiPublishImagePreview()
			if not (midiPublishImageBox and midiPublishImageBox:IsA("TextBox") and midiPublishImagePreview and midiPublishImagePreview:IsA("ImageLabel")) then
				return
			end

			local sheetImageValue = state2.normalizeSheetImageValue(midiPublishImageBox.Text)
			local v46 = sheetImageValue ~= nil and sheetImageValue ~= ""
			midiPublishImagePreview.Image = v46 and state2.profileAssetImage(sheetImageValue)
				or getDefaultSheetCardImage()
			midiPublishImagePreview.ImageTransparency = 0
			midiPublishImagePreview.Visible = true
		end

		local function updateMidiPublishDifficultyVisuals(p)
			local v46 = { "Easy", "Medium", "Hard", "Expert" }
			local v47 = 1

			for i, v48 in ipairs(v46) do
				local midiPublishDifficultyButton = midiPublishDifficultyButtons[v48]
				local v49 = v27 == v48
				local difficultyVisual = getDifficultyVisual(v48) -- inferred equivalent call
				midiPublishDifficultyButton.BackgroundTransparency = 1
				midiPublishDifficultyButton.TextColor3 = v49 and difficultyVisual.Text or Color3.fromRGB(190, 198, 214)
				midiPublishDifficultyButton.Font = v49 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium

				if v49 then
					v47 = i
				end
			end

			local difficultyVisual = getDifficultyVisual(v27) -- inferred equivalent call
			local udim = UDim2.new((v47 - 1) / #v46, 3, 0, 3)
			local udim2 = UDim2.new(1 / #v46, -6, 1, -6)
			local uiStroke = midiPublishDifficultyIndicator:FindFirstChildOfClass("UIStroke")

			if state2.midiPublishDifficultyIndicatorTween then
				state2.midiPublishDifficultyIndicatorTween:Cancel()
				state2.midiPublishDifficultyIndicatorTween = nil
			end

			if state2.midiPublishDifficultyStrokeTween then
				state2.midiPublishDifficultyStrokeTween:Cancel()
				state2.midiPublishDifficultyStrokeTween = nil
			end

			if p then
				local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				local TweenService = game:GetService("TweenService")
				local tween = TweenService:Create(midiPublishDifficultyIndicator, tweenInfo, {
					Position = udim,
					Size = udim2,
					BackgroundColor3 = difficultyVisual.Background
				})

				state2.midiPublishDifficultyIndicatorTween = tween
				tween.Completed:Once(function()
					if state2.midiPublishDifficultyIndicatorTween == tween then
						state2.midiPublishDifficultyIndicatorTween = nil
					end
				end)
				tween:Play()

				if uiStroke then
					local TweenService2 = game:GetService("TweenService")
					local tween2 = TweenService2:Create(uiStroke, tweenInfo, {
						Color = difficultyVisual.Border
					})
					state2.midiPublishDifficultyStrokeTween = tween2
					tween2.Completed:Once(function()
						if state2.midiPublishDifficultyStrokeTween == tween2 then
							state2.midiPublishDifficultyStrokeTween = nil
						end
					end)
					tween2:Play()
				end
			else
				midiPublishDifficultyIndicator.Position = udim
				midiPublishDifficultyIndicator.Size = udim2
				midiPublishDifficultyIndicator.BackgroundColor3 = difficultyVisual.Background

				if uiStroke then
					uiStroke.Color = difficultyVisual.Border
				end
			end
		end

		local function onActivated2()
			midiPublishOverlay.Visible = false
		end

		local function fn8()
			v27 = "Easy"
			state2.applyModalScale(midiPublishPanel, 544, 620)
			midiPublishTitleBox.Text = ""
			midiPublishUrlBox.Text = ""

			if midiPublishImageBox and midiPublishImageBox:IsA("TextBox") then
				midiPublishImageBox.Text = ""
			end

			state2.updateMidiPublishImagePreview()
			local uploadQuotaText = state2.getUploadQuotaText(state2.midiUploadQuota)
			midiPublishCostLabel.Text = uploadQuotaText ~= ""
				and string.format("Publishing costs %s Notes. %s", comma(v23), uploadQuotaText)
				or string.format("Publishing costs %s Notes.", comma(v23))
			midiPublishStatus.Text = tostring("")
			midiPublishStatus.TextColor3 = Color3.fromRGB(160, 168, 184)

			updateMidiPublishDifficultyVisuals(false)
			midiPublishOverlay.Visible = true
		end

		local function publishMidiFromOverlay()
			local title = trimText(midiPublishTitleBox.Text) -- inferred equivalent call
			local url = trimText(midiPublishUrlBox.Text) -- inferred equivalent call

			if title == "" then
				midiPublishStatus.Text = tostring("Enter a song title.")
				midiPublishStatus.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(160, 168, 184)
			else
				local v48 = #title

				if v25 < v48 then
					setMidiPublishStatus("MIDI title must be " .. tostring(v25) .. " characters or fewer.", true) -- inferred equivalent call
				elseif url == "" or not url:match("^https?://") then
					midiPublishStatus.Text = tostring("Enter a direct MIDI URL that starts with http:// or https://.")
					midiPublishStatus.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(160, 168, 184)
				else
					local v49 = #url

					if v26 < v49 then
						setMidiPublishStatus("MIDI URL must be " .. tostring(v26) .. " characters or fewer.", true) -- inferred equivalent call
					else
						local sheetImageValue = state2.normalizeSheetImageValue(midiPublishImageBox and midiPublishImageBox.Text or "")

						if sheetImageValue == nil then
							midiPublishStatus.Text = tostring("Enter a valid background asset ID or leave it blank.")
							midiPublishStatus.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(160, 168, 184)
						else
							midiPublishStatus.Text = tostring("Checking your MIDI link...")
							midiPublishStatus.TextColor3 = Color3.fromRGB(160, 168, 184)

							midiPublishSubmitButton.Active = false
							midiPublishSubmitButton.Text = "Publishing..."
							task.spawn(function()
								local success, result, v50, v51 = pcall(function()
									return publishCommunityMidi:InvokeServer({
										Title = title,
										Url = url,
										Difficulty = state2.getDifficultyPublishValue(v27),
										ImageAssetId = sheetImageValue
									})
								end)

								midiPublishSubmitButton.Active = true
								midiPublishSubmitButton.Text = "Publish"

								if success and result then
									if type(v51) == "table" and fn6 then
										fn6(v51)
									end

									onActivated2()
									selectedMode = "MIDI"
									v22 = nil
									fn7("MIDI")
									setInlineMessage(v50 or "MIDI published.", false) -- inferred equivalent call
								else
									if success then
										midiPublishStatus.Text = tostring(v50 or "Could not publish this MIDI." or "")
									else
										v2.Warn("[CommunitySheetsGui] PublishCommunityMidi failed:", result)
										midiPublishStatus.Text = tostring("Could not reach MIDI publish service.")
									end

									midiPublishStatus.TextColor3 = Color3.fromRGB(255, 190, 90)
										or Color3.fromRGB(160, 168, 184)
								end
							end)
						end
					end
				end
			end
		end

		function state2.setMidiRepairStatus(value, p)
			if midiRepairStatus and midiRepairStatus:IsA("TextLabel") then
				midiRepairStatus.Text = tostring(value or "")
				midiRepairStatus.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(160, 168, 184)
			end
		end

		function state2.closeMidiRepairOverlay()
			state2.midiRepairTarget = nil
			state2.midiRepairPending = false

			if midiRepairOverlay then
				midiRepairOverlay.Visible = false
			end

			if midiRepairSubmitButton and midiRepairSubmitButton:IsA("TextButton") then
				midiRepairSubmitButton.Active = true
				midiRepairSubmitButton.Text = "Update Link"
			end
		end

		function state2.openMidiRepairOverlay(midiRepairTarget)
			if not midiRepairTarget or tostring(midiRepairTarget.mode or "") ~= "MIDI" then
				return
			end

			state2.midiRepairTarget = midiRepairTarget
			state2.applyModalScale(midiRepairPanel, 520, 430)
			local midiUnavailableNoBackup = state2.isMidiUnavailableNoBackup(midiRepairTarget)

			if midiRepairTargetLabel and midiRepairTargetLabel:IsA("TextLabel") then
				midiRepairTargetLabel.Text = "Updating " .. tostring(midiRepairTarget.name or "Untitled MIDI")
			end

			if midiRepairWarningPanel and midiRepairWarningPanel:IsA("GuiObject") then
				midiRepairWarningPanel.BackgroundColor3 = midiUnavailableNoBackup and Color3.fromRGB(58, 30, 34)
					or Color3.fromRGB(50, 35, 28)
				local uiStroke = midiRepairWarningPanel:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Color = midiUnavailableNoBackup and Color3.fromRGB(255, 100, 120)
						or Color3.fromRGB(240, 117, 54)
				end
			end

			if midiRepairWarningText and midiRepairWarningText:IsA("TextLabel") then
				midiRepairWarningText.Text = midiUnavailableNoBackup
					and "This MIDI is hidden from public browsing until the link works again. Likes, plays, and favorites will stay."
					or "Use this if the original link is changing. The upload keeps the same likes, plays, and favorites."

				midiRepairWarningText.TextColor3 = midiUnavailableNoBackup and Color3.fromRGB(255, 170, 185)
					or Color3.fromRGB(255, 198, 150)
			end

			if midiRepairUrlBox and midiRepairUrlBox:IsA("TextBox") then
				midiRepairUrlBox.Text = tostring(midiRepairTarget.url or midiRepairTarget.sheet or "")
				midiRepairUrlBox.CursorPosition = #midiRepairUrlBox.Text + 1
			end

			state2.setMidiRepairStatus("Paste a working direct .mid or .midi link.", false)

			if midiRepairSubmitButton and midiRepairSubmitButton:IsA("TextButton") then
				midiRepairSubmitButton.Text = midiUnavailableNoBackup and "Repair Link" or "Update Link"
				midiRepairSubmitButton.BackgroundColor3 = midiUnavailableNoBackup and Color3.fromRGB(235, 93, 130)
					or Color3.fromRGB(20, 160, 255)
				midiRepairSubmitButton.Active = true
			end

			if midiRepairOverlay then
				midiRepairOverlay.Visible = true
			end
		end

		function state2.submitMidiRepair()
			if state2.midiRepairPending then
				return
			end

			local midiRepairTarget = state2.midiRepairTarget
			local publicId = midiRepairTarget and tostring(midiRepairTarget.publicId or midiRepairTarget.id or "") or ""
			local url = trimText(midiRepairUrlBox and midiRepairUrlBox.Text or "") -- inferred equivalent call

			if publicId == "" then
				state2.setMidiRepairStatus("That MIDI upload could not be found.", true)
				return
			end

			if url == "" or not url:match("^https?://") then
				state2.setMidiRepairStatus("Enter a direct MIDI URL that starts with http:// or https://.", true)
				return
			end

			local v47 = #url

			if v26 < v47 then
				state2.setMidiRepairStatus("MIDI URL must be " .. tostring(v26) .. " characters or fewer.", true)
				return
			end

			state2.midiRepairPending = true
			state2.setMidiRepairStatus("Checking the new MIDI link...", false)

			if midiRepairSubmitButton and midiRepairSubmitButton:IsA("TextButton") then
				midiRepairSubmitButton.Active = false
				midiRepairSubmitButton.Text = "Checking..."
			end

			task.spawn(function()
				local success, result, v48, v49 = pcall(function()
					return repairCommunityMidi:InvokeServer(publicId, { Url = url })
				end)

				state2.midiRepairPending = false

				if midiRepairSubmitButton and midiRepairSubmitButton:IsA("TextButton") then
					midiRepairSubmitButton.Active = true
					midiRepairSubmitButton.Text = state2.isMidiUnavailableNoBackup(midiRepairTarget)
						and "Repair Link"
						or "Update Link"
				end

				if success and result then
					if type(v49) == "table" and fn6 then
						fn6(v49)
					end

					state2.closeMidiRepairOverlay()
					state2.closePreviewOverlay()

					if state2.refreshProfile then
						state2.refreshProfile()
					end

					setInlineMessage(v48 or "MIDI link updated.", false) -- inferred equivalent call
				else
					if success then
						state2.setMidiRepairStatus(v48 or "Could not update this MIDI link.", true)
						return
					end

					v2.Warn("[CommunitySheetsGui] RepairCommunityMidi failed:", result)
					state2.setMidiRepairStatus("Could not reach MIDI repair service.", true)
				end
			end)
		end

		local function ensureCardActionButton(parent2, name, text, p, p2, backgroundColor)
			local parent3 = parent2:FindFirstChild(name)

			if text == "__more" then
				if parent3 and not parent3:IsA("GuiButton") then
					parent3:Destroy()
					parent3 = nil
				end

				if not parent3 then
					parent3 = Instance.new("ImageButton")
					parent3.Name = name
					parent3.Parent = parent2
					local uiCorner = Instance.new("UICorner")
					uiCorner.CornerRadius = UDim.new(0, 8)
					uiCorner.Parent = parent3
				end

				parent3.Visible = true
				parent3.Active = true
				parent3.AutoButtonColor = true
				parent3.BorderSizePixel = 0
				parent3.Size = UDim2.fromOffset(p, 36)
				parent3.Position = UDim2.new(1, -p2, 1, -50)
				parent3.BackgroundColor3 = backgroundColor
				parent3.BackgroundTransparency = 0
				parent3.ZIndex = 10
				pcall(function()
					parent3.Image = ""
					parent3.ImageTransparency = 1
					parent3.ScaleType = Enum.ScaleType.Fit
				end)
				local v47 = parent3:FindFirstChildOfClass("UICorner")

				if not v47 then
					v47 = Instance.new("UICorner")
					v47.Parent = parent3
				end

				v47.CornerRadius = UDim.new(0, 8)
				local icon = parent3:FindFirstChild("Icon")

				if not icon then
					icon = Instance.new("ImageLabel")
					icon.Name = "Icon"
					icon.Parent = parent3
				end

				icon.BackgroundTransparency = 1
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.Position = UDim2.fromScale(0.5, 0.5)
				icon.Size = UDim2.fromOffset(18, 18)
				icon.ZIndex = parent3.ZIndex + 1
				icon.ScaleType = Enum.ScaleType.Fit
				icon.ImageColor3 = Color3.fromRGB(188, 196, 212)
				local image = tostring(parent3:GetAttribute("IconImage") or "")

				if image == "" then
					image = tostring(icon.Image or "")
				end

				icon.Image = image
				icon.Visible = image ~= ""
				local fallbackDots = parent3:FindFirstChild("FallbackDots")

				if not fallbackDots then
					fallbackDots = Instance.new("TextLabel")
					fallbackDots.Name = "FallbackDots"
					fallbackDots.Parent = parent3
				end

				fallbackDots.BackgroundTransparency = 1
				fallbackDots.AnchorPoint = Vector2.new(0.5, 0.5)
				fallbackDots.Position = UDim2.fromScale(0.5, 0.43)
				fallbackDots.Size = UDim2.fromOffset(26, 20)
				fallbackDots.Font = Enum.Font.GothamBold
				fallbackDots.Text = "..."
				fallbackDots.TextSize = 18
				fallbackDots.TextColor3 = Color3.fromRGB(188, 196, 212)
				fallbackDots.ZIndex = parent3.ZIndex + 2
				fallbackDots.Visible = image == ""
				return parent3
			end

			if parent3 and not parent3:IsA("TextButton") then
				parent3:Destroy()
				parent3 = nil
			end

			if not parent3 then
				parent3 = Instance.new("TextButton")
				parent3.Name = name
				parent3.BorderSizePixel = 0
				parent3.AutoButtonColor = true
				parent3.Font = Enum.Font.GothamBold
				parent3.TextSize = 12
				parent3.ZIndex = 6
				parent3.Parent = parent2
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 8)
				uiCorner.Parent = parent3
			end

			parent3.Visible = true
			parent3.Text = text
			parent3.TextWrapped = true
			parent3.TextScaled = true
			parent3.Size = UDim2.fromOffset(p, 36)
			parent3.Position = UDim2.new(1, -p2, 1, -52)
			parent3.BackgroundColor3 = backgroundColor
			parent3.TextColor3 = Color3.fromRGB(255, 255, 255)
			configureTextObject(parent3, 12, 8)
			return parent3
		end

		local function updateFavoriteVisual(favoriteButton, data)
			favoriteButton.Visible = true
			favoriteButton.Image = ""
			favoriteButton.ImageTransparency = 1
			favoriteButton.ScaleType = Enum.ScaleType.Fit
			local glyph = favoriteButton:FindFirstChild("Glyph")

			if glyph then
				glyph:Destroy()
			end

			if not favoriteButton:FindFirstChild("Icon") then
				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.BackgroundTransparency = 1
				icon.AnchorPoint = Vector2.new(0.5, 0.5)
				icon.Position = UDim2.fromScale(0.5, 0.5)
				icon.Size = UDim2.fromOffset(20, 20)
				icon.ZIndex = favoriteButton.ZIndex + 1
				icon.Parent = favoriteButton
			end

			state2.updateFavoriteImage(favoriteButton, data.isFavorited == true)
		end

		local function recordCommunityPlay(pendingPreviewSong)
			if
				not pendingPreviewSong
				or tostring(pendingPreviewSong.mode or "") ~= "Community"
				or tostring(pendingPreviewSong.id or "") == ""
			then
				return
			end

			task.spawn(function()
				local success, result, _, v46 = pcall(function()
					return recordCommunitySheetPlay:InvokeServer(pendingPreviewSong.id)
				end)

				if success and result and type(v46) == "table" and fn4 then
					fn4(v46)

					if selectedMode == "Community" then
						fn2(false)
					end
				elseif not success then
					v2.Warn("[CommunitySheetsGui] RecordCommunitySheetPlay failed:", result)
				end
			end)
		end

		local function recordCommunityMidiPlay2(p)
			if not p or tostring(p.mode or "") ~= "MIDI" or tostring(p.id or "") == "" then
				return
			end

			task.spawn(function()
				local success, result, _, v46 = pcall(function()
					return recordCommunityMidiPlay:InvokeServer(p.id)
				end)

				if success and result and type(v46) == "table" and fn6 then
					fn6(v46)

					if selectedMode == "MIDI" then
						fn2(false)
					end
				elseif not success then
					v2.Warn("[CommunitySheetsGui] RecordCommunityMidiPlay failed:", result)
				end
			end)
		end

		do
			local function cloneOptimisticUploadState(items)
				if type(items) ~= "table" then
					return items
				end

				local result = {}

				for k, item in pairs(items) do
					result[k] = cloneOptimisticUploadState(item)
				end

				return result
			end

			do
				local function getUploadPublicId(data)
					if type(data) == "table" then
						return (tostring(data.id or data.PublicId or data.Id or ""))
					end

					return ""
				end
			end

			local function findUploadByPublicId(list, value)
				if type(list) ~= "table" then
					return nil, nil
				end

				local v46 = tostring(value or "")

				for i, item in ipairs(list) do
					if (type(item) ~= "table" and "" or tostring(item.id or item.PublicId or item.Id or "")) == v46 then
						return item, i
					end
				end

				return nil, nil
			end

			do
				local function removeUploadByPublicId(list, p) -- 2 equivalent calls inferred from this helper
					local uploadByPublicId, v46 = findUploadByPublicId(list, p)

					if uploadByPublicId and v46 then
						table.remove(list, v46)
					end

					return uploadByPublicId, v46
				end
			end

			do
				local function restoreUploadSnapshot(list, p, p2, p3)
					if type(list) ~= "table" or type(p2) ~= "table" then
						return
					end

					local _ = removeUploadByPublicId(list, p) -- inferred equivalent call
					table.insert(
						list,
						math.clamp(math.floor(tonumber(p3) or #list + 1), 1, #list + 1),
						(cloneOptimisticUploadState(p2))
					)
				end

				do
					local function findProfileMidiUpload(p) -- 3 equivalent calls inferred from this helper
						local profileData

						if type(state2.profileData) == "table" then
							profileData = state2.profileData or nil
						end

						local publicMidi

						if profileData and type(profileData.PublicMidi) == "table" then
							publicMidi = profileData.PublicMidi or nil
						end

						local uploadByPublicId, v46 = findUploadByPublicId(publicMidi, p)
						return uploadByPublicId, v46, publicMidi
					end
				end

				do
					local function redrawOptimisticMidiCatalog() -- 4 equivalent calls inferred from this helper
						if selectedMode == "MIDI" and fn2 then
							fn2(false)
						elseif selectedMode == "Community" and state2.sortMode == "Default" and fn then
							fn()
						end
					end
				end

				do
					local function redrawOptimisticProfile()
						if type(state2.profileData) ~= "table" or type(state2.renderProfileData) ~= "function" then
							return
						end

						state2.renderProfileData(state2.profileData)
					end
				end

				function state2.optimisticHideMidiUpload(value)
					local publicId = tostring(value or "")
					local v47 = { PublicId = publicId }
					local uploadByPublicId, catalogIndex = removeUploadByPublicId(v7, publicId) -- inferred equivalent call
					v47.CatalogUpload = cloneOptimisticUploadState(uploadByPublicId)
					v47.CatalogIndex = catalogIndex
					local profileMidiUpload, profileIndex = findProfileMidiUpload(publicId) -- inferred equivalent call
					v47.ProfileUpload = cloneOptimisticUploadState(profileMidiUpload)
					v47.ProfileIndex = profileIndex

					if type(profileMidiUpload) == "table" then
						profileMidiUpload.IsPublished = false
						profileMidiUpload.OwnerUnpublished = true
						profileMidiUpload.OwnerHidden = true
						profileMidiUpload.UpdatedAt = os.time()
					end

					redrawOptimisticMidiCatalog() -- inferred equivalent call

					if type(state2.profileData) == "table" then
						if type(state2.renderProfileData) ~= "function" then
							return v47
						end

						state2.renderProfileData(state2.profileData)
					end

					return v47
				end

				function state2.optimisticRepublishProfileMidiUpload(value)
					local publicId = tostring(value or "")
					local v47 = { PublicId = publicId }
					local profileMidiUpload, profileIndex = findProfileMidiUpload(publicId) -- inferred equivalent call
					v47.ProfileUpload = cloneOptimisticUploadState(profileMidiUpload)
					v47.ProfileIndex = profileIndex

					if type(profileMidiUpload) == "table" then
						profileMidiUpload.IsPublished = true
						profileMidiUpload.OwnerUnpublished = false
						profileMidiUpload.OwnerHidden = false
						profileMidiUpload.UpdatedAt = os.time()
					end

					if type(state2.profileData) == "table" then
						if type(state2.renderProfileData) ~= "function" then
							return v47
						end

						state2.renderProfileData(state2.profileData)
					end

					return v47
				end

				function state2.rollbackOptimisticMidiUpload(value, p)
					local v46 = tostring(value or "")
					local v47 = type(p) == "table" and p or {}
					restoreUploadSnapshot(v7, v46, v47.CatalogUpload, v47.CatalogIndex)
					local _, _, publicMidi = findProfileMidiUpload(v46) -- inferred equivalent call
					restoreUploadSnapshot(publicMidi, v46, v47.ProfileUpload, v47.ProfileIndex)
					redrawOptimisticMidiCatalog() -- inferred equivalent call

					if type(state2.profileData) == "table" then
						if type(state2.renderProfileData) ~= "function" then
							return
						end

						state2.renderProfileData(state2.profileData)
					end
				end
			end

			function state2.snapshotModerationLists()
				return {
					Community = cloneOptimisticUploadState(v6),
					Midi = cloneOptimisticUploadState(v7),
					ModeratedSheets = cloneOptimisticUploadState(v8),
					ModeratedMidi = cloneOptimisticUploadState(v9)
				}
			end

			function state2.restoreModerationLists(p)
				local v46 = type(p) == "table" and p or {}
				local function restoreList(list, p2)
					table.clear(list)

					for _, v47 in ipairs(type(p2) == "table" and p2 or {}) do
						table.insert(list, (cloneOptimisticUploadState(v47)))
					end
				end
				restoreList(v6, v46.Community)
				restoreList(v7, v46.Midi)
				restoreList(v8, v46.ModeratedSheets)
				restoreList(v9, v46.ModeratedMidi)

				if fn2 then
					fn2(false)
				end
			end

			function state2.applyLocalModerationResult(data, value, value2)
				if type(data) ~= "table" then
					return
				end

				local v46 = tostring(value or "")
				local v47 = trimText(value2) -- inferred equivalent call
				local v48 = tostring(data.mode or "") == "MIDI"
				local v49 = v48 and v7 or v6
				local v50 = v48 and v9 or v8
				local id = tostring(data.id or data.publicId or "")
				local ownerUserId = tonumber(data.ownerUserId) or 0
				local now = os.time()
				local displayName = tostring(LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name)

				local function matchesUpload(data2): boolean -- 2 equivalent calls inferred from this helper
					if type(data2) ~= "table" then
						return false
					end

					if id ~= "" and tostring(data2.id or data2.publicId or "") == id then
						return true
					end

					return ownerUserId > 0 and tonumber(data2.ownerUserId) == ownerUserId and v46 == "blockUser"
				end

				local function removeMatches(list)
					for i = #list, 1, -1 do
						if matchesUpload(list[i]) then -- inferred equivalent call
							table.remove(list, i)
						end
					end
				end

				local function applyStatus(optimisticUploadState, moderationAction)
					if type(optimisticUploadState) ~= "table" then
						return
					end

					if moderationAction == "clearReports" then
						optimisticUploadState.reportCount = 0
						optimisticUploadState.reports = {}
					elseif moderationAction == "restore" then
						optimisticUploadState.isHidden = false
						optimisticUploadState.isDeleted = false
						optimisticUploadState.moderationAction = ""
						optimisticUploadState.moderationReason = ""
						optimisticUploadState.moderatorName = ""
					else
						optimisticUploadState.isHidden = moderationAction == "hide" or moderationAction == "blockUser"
						optimisticUploadState.isDeleted = moderationAction == "delete"
						optimisticUploadState.moderationAction = moderationAction
						optimisticUploadState.moderationReason = v47 ~= "" and v47
							or moderationAction == "delete" and "Removed by staff."
							or "Hidden by staff."
						optimisticUploadState.moderatedAt = now
						optimisticUploadState.moderatorName = displayName
					end
				end

				if v46 == "clearReports" then
					for _, list in ipairs({ v49, v50 }) do
						for _, item in ipairs(list) do
							if not (matchesUpload(item) and type(item) == "table") then -- inferred equivalent call
								continue
							end

							item.reportCount = 0
							item.reports = {}
						end
					end
				elseif v46 == "restore" then
					removeMatches(v50)
					local optimisticUploadState = cloneOptimisticUploadState(data)

					if type(optimisticUploadState) == "table" then
						optimisticUploadState.isHidden = false
						optimisticUploadState.isDeleted = false
						optimisticUploadState.moderationAction = ""
						optimisticUploadState.moderationReason = ""
						optimisticUploadState.moderatorName = ""
					end

					if id ~= "" and not findUploadByPublicId(v49, id) then
						table.insert(v49, 1, optimisticUploadState)
					end
				elseif v46 == "hide" or v46 == "delete" or v46 == "blockUser" then
					removeMatches(v49)
					local optimisticUploadState = cloneOptimisticUploadState(data)
					applyStatus(optimisticUploadState, v46)

					if id ~= "" and not findUploadByPublicId(v50, id) then
						table.insert(v50, 1, optimisticUploadState)
					end
				end

				if fn2 then
					fn2(false)
				end
			end
		end

		function state2.applyOptimisticModeration(p, p2, p3)
			local snapshotModerationLists = state2.snapshotModerationLists()
			state2.applyLocalModerationResult(p, p2, p3)
			return snapshotModerationLists
		end

		local function unpublishOwnedMidi(data)
			local id = data and tostring(data.id or "") or ""

			if data and tostring(data.mode or "") == "MIDI" and id ~= "" then
				if data.ownedByLocalPlayer == true then
					local optimisticHideMidiUpload = state2.optimisticHideMidiUpload(id)

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Hiding MIDI upload...")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					task.spawn(function()
						local success, result, v46, v47 = pcall(function()
							return unpublishCommunityMidi:InvokeServer(id)
						end)

						if success and result then
							if type(v47) == "table" and fn6 then
								fn6(v47)
								redrawOptimisticMidiCatalog() -- inferred equivalent call
							elseif fn5 then
								fn5()
							end

							setInlineMessage(v46 or "MIDI hidden from Community MIDI.", false) -- inferred equivalent call
						elseif success then
							state2.rollbackOptimisticMidiUpload(id, optimisticHideMidiUpload)
							setInlineMessage(v46 or "Could not hide this MIDI.", true) -- inferred equivalent call
						else
							state2.rollbackOptimisticMidiUpload(id, optimisticHideMidiUpload)
							v2.Warn("[CommunitySheetsGui] UnpublishCommunityMidi failed:", result)

							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("Could not reach MIDI owner controls.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						end
					end)
				else
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Only the uploader can hide this MIDI.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end
			else
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Select one of your MIDI uploads first.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
			end
		end

		function state2.unpublishOwnedCommunitySheet(data)
			local sheetId = data and tostring(data.sheetId or "") or ""

			if data and tostring(data.mode or "") == "Community" and sheetId ~= "" then
				if data.ownedByLocalPlayer == true then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Unpublishing sheet...")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					task.spawn(function()
						local success, result, v46, v47, v48 = pcall(function()
							return UnpublishCommunitySheetRemote:InvokeServer({ SheetId = sheetId })
						end)

						if success and result then
							if type(v47) == "table" and fn4 then
								fn4(v47)
								fn2(false)
							elseif fn3 then
								fn3()
							end

							if type(v48) == "table" then
								state2.applySheetPublishPersonalPayload(v48)
							end

							setInlineMessage(v46 or "Sheet removed from Community Sheets.", false) -- inferred equivalent call
						elseif success then
							setInlineMessage(v46 or "Could not unpublish this sheet.", true) -- inferred equivalent call
						else
							v2.Warn("[CommunitySheetsGui] UnpublishCommunitySheet failed:", result)

							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("Could not reach sheet owner controls.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						end
					end)
				else
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Only the uploader can unpublish this sheet.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end
			else
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Select one of your sheet uploads first.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
			end
		end

		function state2.withCatalogScrollPreserved(callback)
			local cardGrid2 = state2.mobileLandscapeActive and controls.CardGrid or cardGrid
			local canvasPosition

			if cardGrid2 then
				canvasPosition = cardGrid2.CanvasPosition or nil
			else
				canvasPosition = nil
			end

			callback()

			if canvasPosition and cardGrid2 and cardGrid2.Parent then
				task.defer(function()
					if cardGrid2.Parent then
						cardGrid2.CanvasPosition = canvasPosition
					end
				end)
			end
		end

		local function toggleFavorite(state): boolean
			local mode = state and tostring(state.mode or "") or ""
			local v46 = mode == "MIDI"

			if state and (mode == "Community" or v46) and tostring(state.id or "") ~= "" then
				if state.ownedByLocalPlayer == true or (tonumber(state.ownerUserId) or 0) == LocalPlayer.UserId then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("You cannot favorite your own upload.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

					return false
				else
					local v47 = (v46 and "Midi:" or "Sheets:") .. tostring(state.id)
					state2.favoriteTogglePendingById = state2.favoriteTogglePendingById or {}

					if state2.favoriteTogglePendingById[v47] then
						return false
					end

					state2.favoriteTogglePendingById[v47] = true

					local function releaseFavoriteToggleLock() -- 1 equivalent call inferred from this helper
						task.delay(0.85, function()
							local favoriteTogglePendingById = state2.favoriteTogglePendingById

							if favoriteTogglePendingById then
								favoriteTogglePendingById[v47] = nil
							end
						end)
					end

					local v48 = v46 and v7 or v6
					local isFavorited = state.isFavorited == true
					local likes = math.max(0, (math.floor(tonumber(state.likes) or 0)))
					local isFavorited2 = not isFavorited
					local likes2 = math.max(0, likes + (isFavorited2 and 1 or -1))

					for _, v52 in ipairs(v48) do
						if tostring(v52.id or "") ~= tostring(state.id) then
							continue
						end

						v52.likes = likes2
						v52.isFavorited = isFavorited2
					end

					state.likes = likes2
					state.isFavorited = isFavorited2
					state2.withCatalogScrollPreserved(function()
						fn2(false)
					end)

					local success, result, v52, v53, v54, favorites = pcall(function()
						return toggleCommunityFavorite:InvokeServer({
							Kind = v46 and "Midi" or "Sheets",
							PublicId = state.id
						})
					end)
					releaseFavoriteToggleLock() -- inferred equivalent call

					if success and result then
						likes2 = type(v53) == "table"
							and math.max(0, (math.floor(tonumber(v53.FavoriteCount or v53.Favorites) or 0)))
							or likes2

						for _, v56 in ipairs(v48) do
							if tostring(v56.id or "") ~= tostring(state.id) then
								continue
							end

							v56.likes = likes2
							v56.isFavorited = v54 == true
						end

						state.likes = likes2
						state.isFavorited = v54 == true

						if
							type(state2.profileData) == "table"
							and state2.profileData.IsSelf == true
							and type(favorites) == "table"
						then
							state2.profileData.Favorites = favorites

							if selectedMode == "Profile" then
								state2.renderProfileData(state2.profileData)
							end
						end

						state2.withCatalogScrollPreserved(function()
							fn2(false)
						end)
						setInlineMessage(v52 or "Favorite updated.", false) -- inferred equivalent call
						return true
					end

					for _, v56 in ipairs(v48) do
						if tostring(v56.id or "") ~= tostring(state.id) then
							continue
						end

						v56.likes = likes
						v56.isFavorited = isFavorited
					end

					state.likes = likes
					state.isFavorited = isFavorited
					state2.withCatalogScrollPreserved(function()
						fn2(false)
					end)

					if success then
						setInlineMessage(v52 or "Could not update favorite.", true) -- inferred equivalent call
					else
						v2.Warn("[CommunitySheetsGui] ToggleCommunityFavorite failed:", result)

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Could not reach favorite service.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					end

					return false
				end
			else
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Only community Sheets and MIDI can be favorited.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return false
			end
		end

		do
			local function sendContentReport(pendingReportSong, value): boolean
				if pendingReportSong and tostring(pendingReportSong.id or "") ~= "" then
					local v46 = trimText(value) -- inferred equivalent call
					local v47 = v46 == ""
						and (tostring(pendingReportSong.mode or "") == "MIDI" and "Reported from community MIDI browser." or "Reported from community browser.")
						or v46

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Sending report...")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					local v48 = tostring(pendingReportSong.mode or "") == "MIDI"
					local success, result, v49, v50 = pcall(function()
						if v48 then
							return reportCommunityMidi:InvokeServer(pendingReportSong.id, v47)
						end

						return reportCommunitySheet:InvokeServer(pendingReportSong.id, v47)
					end)

					if success and result then
						if type(v50) == "table" then
							local updatedEntry

							if type(v50.UpdatedEntry) == "table" then
								updatedEntry = v50.UpdatedEntry or nil
							end

							if updatedEntry then
								local v51 = v48 and normalizeCommunityMidi(updatedEntry)
									or normalizeCommunitySong(updatedEntry)
								local v52 = v48 and v7 or v6
								local id = tostring(v51.id or v51.publicId or "")
								local v53 = false

								for i, v55 in ipairs(v52) do
									if tostring(v55.id or v55.publicId or "") == id then
										v51.isFavorited = v55.isFavorited == true
										v52[i] = v51
										v53 = true
										break
									end
								end

								if not v53 then
									table.insert(v52, 1, v51)
								end

								if state2.pendingReportSong then
									state2.pendingReportSong.reportCount = v51.reportCount
									state2.pendingReportSong.reports = v51.reports
								end

								fn2(false)
							elseif v48 and fn6 then
								fn6(v50)
								fn2(false)
							elseif fn4 then
								fn4(v50)
								fn2(false)
							end
						end

						setInlineMessage(v49 or "Report sent.", false) -- inferred equivalent call
						return true
					end

					if success then
						setInlineMessage(v49 or "Could not report this upload.", true) -- inferred equivalent call
					else
						v2.Warn("[CommunitySheetsGui] Report community upload failed:", result)

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Could not reach report service.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					end

					return false
				end

				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Select a community upload first.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return false
			end

			function state2:updateFavoriteImage(p)
				if not self then
					return
				end

				if self:IsA("ImageButton") then
					self.Image = ""
					self.ImageTransparency = 1
				end

				local icon = self:FindFirstChild("Icon")

				if icon and icon:IsA("ImageLabel") then
					icon.Image = p and "rbxassetid://127626968216725" or "rbxassetid://111699395355288"
					icon.ImageColor3 = p and Color3.fromRGB(255, 79, 96) or Color3.fromRGB(188, 196, 212)
					icon.ScaleType = Enum.ScaleType.Fit
				end

				self.BackgroundColor3 = p and Color3.fromRGB(55, 30, 40) or Color3.fromRGB(43, 48, 62)
			end

			function state2.ensureMidiPreviewPanel(parent2)
				local midiPlayerPanel = parent2 and parent2:FindFirstChild("MidiPlayerPanel")

				if midiPlayerPanel and not midiPlayerPanel:IsA("Frame") then
					midiPlayerPanel:Destroy()
					midiPlayerPanel = nil
				end

				if not midiPlayerPanel then
					midiPlayerPanel = Instance.new("Frame")
					midiPlayerPanel.Name = "MidiPlayerPanel"
					midiPlayerPanel.Parent = parent2
				end

				midiPlayerPanel.Position = UDim2.fromOffset(0, 72)
				midiPlayerPanel.Size = UDim2.new(1, 0, 1, -90)
				midiPlayerPanel.BackgroundColor3 = Color3.fromRGB(10, 14, 22)
				midiPlayerPanel.BackgroundTransparency = 1
				midiPlayerPanel.BorderSizePixel = 0
				midiPlayerPanel.Visible = false
				midiPlayerPanel.ZIndex = parent2.ZIndex + 1
				local uiCorner = midiPlayerPanel:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 10)
				uiCorner.Parent = midiPlayerPanel

				local function ensureLabel(name, position, size, p, color, value)
					local v46 = midiPlayerPanel:FindFirstChild(name)

					if v46 and not v46:IsA("TextLabel") then
						v46:Destroy()
						v46 = nil
					end

					if not v46 then
						v46 = Instance.new("TextLabel")
						v46.Name = name
						v46.Parent = midiPlayerPanel
					end

					v46.Position = position
					v46.Size = size
					v46.BackgroundTransparency = 1
					v46.Font = p or Enum.Font.Gotham
					v46.TextColor3 = color or Color3.fromRGB(163, 173, 196)
					v46.TextXAlignment = Enum.TextXAlignment.Left
					v46.TextWrapped = true
					v46.ZIndex = midiPlayerPanel.ZIndex + 1
					configureTextObject(v46, value or 13, 8)
					return v46
				end

				local function ensureButton(name, text, position, size, backgroundColor)
					local parent3 = midiPlayerPanel:FindFirstChild(name)

					if parent3 and not parent3:IsA("TextButton") then
						parent3:Destroy()
						parent3 = nil
					end

					if not parent3 then
						parent3 = Instance.new("TextButton")
						parent3.Name = name
						parent3.Parent = midiPlayerPanel
					end

					parent3.Position = position
					parent3.Size = size
					parent3.BackgroundColor3 = backgroundColor
					parent3.BorderSizePixel = 0
					parent3.AutoButtonColor = true
					parent3.Font = Enum.Font.GothamBold
					parent3.TextColor3 = Color3.fromRGB(255, 255, 255)
					parent3.Text = text
					parent3.ZIndex = midiPlayerPanel.ZIndex + 2
					parent3.Active = true
					configureTextObject(parent3, 13, 8)
					local uiCorner2 = parent3:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
					uiCorner2.CornerRadius = UDim.new(0, 10)
					uiCorner2.Parent = parent3
					return parent3
				end

				local label_2 = ensureLabel(
					"Title",
					UDim2.fromOffset(22, 20),
					UDim2.new(1, -44, 0, 32),
					Enum.Font.GothamBold,
					Color3.fromRGB(240, 244, 255),
					20
				)
				label_2.Text = "MIDI Player"
				local label = ensureLabel(
					"Status",
					UDim2.fromOffset(22, 58),
					UDim2.new(1, -44, 0, 48),
					Enum.Font.GothamMedium,
					Color3.fromRGB(163, 173, 196),
					13
				)
				label.TextYAlignment = Enum.TextYAlignment.Top
				label.Text = "Ready to preview this MIDI."
				local label_3 = ensureLabel(
					"Source",
					UDim2.fromOffset(22, 112),
					UDim2.new(1, -44, 0, 28),
					Enum.Font.GothamSemibold,
					Color3.fromRGB(20, 160, 255),
					12
				)
				label_3.Text = "Preview uses your current piano soundfont."

				ensureButton(
					"PreviewPlayButton",
					"Play Preview",
					UDim2.fromOffset(22, 158),
					UDim2.fromOffset(136, 42),
					Color3.fromRGB(20, 160, 255)
				)
				ensureButton(
					"PreviewStopButton",
					"Stop",
					UDim2.fromOffset(170, 158),
					UDim2.fromOffset(86, 42),
					Color3.fromRGB(54, 61, 76)
				)
				ensureButton(
					"PreviewLoad2DButton",
					"Load to 2D",
					UDim2.fromOffset(268, 158),
					UDim2.fromOffset(118, 42),
					Color3.fromRGB(54, 61, 76)
				)

				local progressTrack = midiPlayerPanel:FindFirstChild("ProgressTrack")

				if progressTrack and not progressTrack:IsA("Frame") then
					progressTrack:Destroy()
					progressTrack = nil
				end

				if not progressTrack then
					progressTrack = Instance.new("Frame")
					progressTrack.Name = "ProgressTrack"
					progressTrack.Parent = midiPlayerPanel
				end

				progressTrack.Position = UDim2.fromOffset(22, 222)
				progressTrack.Size = UDim2.new(1, -44, 0, 10)
				progressTrack.BackgroundColor3 = Color3.fromRGB(31, 38, 52)
				progressTrack.BorderSizePixel = 0
				progressTrack.ZIndex = midiPlayerPanel.ZIndex + 1
				progressTrack.Active = true
				local uiCorner2 = progressTrack:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
				uiCorner2.CornerRadius = UDim.new(1, 0)
				uiCorner2.Parent = progressTrack
				local fill = progressTrack:FindFirstChild("Fill")

				if fill and not fill:IsA("Frame") then
					fill:Destroy()
					fill = nil
				end

				if not fill then
					fill = Instance.new("Frame")
					fill.Name = "Fill"
					fill.Parent = progressTrack
				end

				fill.Position = UDim2.fromScale(0, 0)
				fill.Size = UDim2.fromScale(0, 1)
				fill.BackgroundColor3 = Color3.fromRGB(20, 160, 255)
				fill.BorderSizePixel = 0
				fill.ZIndex = progressTrack.ZIndex + 1
				local uiCorner3 = fill:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
				uiCorner3.CornerRadius = UDim.new(1, 0)
				uiCorner3.Parent = fill
				local knob = progressTrack:FindFirstChild("Knob")

				if knob and not knob:IsA("TextButton") then
					knob:Destroy()
					knob = nil
				end

				if not knob then
					knob = Instance.new("TextButton")
					knob.Name = "Knob"
					knob.Parent = progressTrack
				end

				knob.Size = UDim2.fromOffset(18, 18)
				knob.AnchorPoint = Vector2.new(0.5, 0.5)
				knob.Position = UDim2.fromScale(0, 0.5)
				knob.BackgroundColor3 = Color3.fromRGB(238, 246, 255)
				knob.BorderSizePixel = 0
				knob.AutoButtonColor = false
				knob.Text = ""
				knob.Active = true
				knob.ZIndex = progressTrack.ZIndex + 3
				local uiCorner4 = knob:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
				uiCorner4.CornerRadius = UDim.new(1, 0)
				uiCorner4.Parent = knob
				local uiStroke = knob:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
				uiStroke.Color = Color3.fromRGB(20, 160, 255)
				uiStroke.Thickness = 2
				uiStroke.Transparency = 0
				uiStroke.Parent = knob

				local label_4 = ensureLabel(
					"Time",
					UDim2.fromOffset(22, 240),
					UDim2.new(1, -44, 0, 24),
					Enum.Font.GothamMedium,
					Color3.fromRGB(190, 198, 214),
					12
				)
				label_4.Text = "0:00 / 0:00"
				local label2 = ensureLabel(
					"Hint",
					UDim2.new(0, 22, 1, -66),
					UDim2.new(1, -44, 0, 46),
					Enum.Font.Gotham,
					Color3.fromRGB(128, 138, 158),
					12
				)
				label2.TextYAlignment = Enum.TextYAlignment.Bottom
				label2.Text = "Preview uses your piano soundfont. Load MIDI opens the full player; Load to 2D opens 2D mode."

				return midiPlayerPanel
			end

			function state2.formatMidiPreviewTime(p)
				local v46 = math.max(0, tonumber(p) or 0)
				return string.format("%d:%02d", math.floor(v46 / 60), (math.floor(v46 % 60)))
			end

			function state2.getMidiPreviewSourceText(data, value)
				local v46 = tostring(value or "")
				local v47

				if data then
					local userId = tonumber(data.userId or data.UserId or data.creatorUserId or data.CreatorUserId or data.ownerUserId)

					if data.ownedByLocalPlayer == true then
						v47 = true
					elseif userId == nil then
						v47 = false
					else
						v47 = userId == LocalPlayer.UserId
					end
				else
					v47 = false
				end

				if v46 == "" then
					if data and data.backupAvailable == true then
						return "Backup available for reliable preview."
					end

					return "Preview uses your current piano soundfont."
				else
					if v47 then
						return v46 .. " used for preview."
					end

					local lower = v46:lower()

					if lower:find("backup", 1, true) then
						return "Backup available for reliable preview."
					end

					if lower:find("original", 1, true) or lower:find("live", 1, true) then
						return "Original link used for preview."
					end

					return "Preview source ready."
				end
			end

			function state2.getMidiPreviewHandler(p)
				local pianoUI = getPianoUI() -- inferred equivalent call
				local pianoMain = pianoUI and pianoUI:FindFirstChild("PianoMain")
				local midiPlayerHandler = pianoMain and pianoMain:FindFirstChild("MidiPlayerHandler")

				if midiPlayerHandler then
					local success, result = pcall(require, midiPlayerHandler)

					if success and type(result) == "table" then
						return result
					end

					v2.Warn("[CommunitySheetsGui] Failed to load MidiPlayerHandler:", result)

					if not p then
						return nil
					end

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("MIDI preview is not ready yet.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

					return nil
				end

				if not p then
					return nil
				end

				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Open or sit at a piano first to preview MIDI.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return nil
			end

			function state2.updateMidiPreviewPanel(frame, p, p2)
				if not (frame and frame:IsA("Frame")) then
					return
				end

				local v46 = type(p2) == "table" and p2 or {}
				local title = frame:FindFirstChild("Title")
				local status = frame:FindFirstChild("Status")
				local source = frame:FindFirstChild("Source")
				local previewPlayButton = frame:FindFirstChild("PreviewPlayButton")
				local previewStopButton = frame:FindFirstChild("PreviewStopButton")
				local previewLoad2DButton = frame:FindFirstChild("PreviewLoad2DButton")
				local progressTrack = frame:FindFirstChild("ProgressTrack")
				local fill = progressTrack and progressTrack:FindFirstChild("Fill")
				local knob = progressTrack and progressTrack:FindFirstChild("Knob")
				local time = frame:FindFirstChild("Time")
				local communityMidiLookupId = getCommunityMidiLookupId(p)
				local v47

				if tostring(v46.UploadId or "") == "" then
					v47 = false
				else
					v47 = tostring(v46.UploadId) == communityMidiLookupId
				end

				local duration = tonumber(v46.Duration) or 0
				local v48 = math.clamp(tonumber(v46.Position) or 0, 0, (math.max(duration, 0)))
				local v49 = v47 and v46.Loading == true
				local v50 = v47 and v46.Playing == true
				local v51 = v47 and v46.Paused == true
				local active = v47 and (v46.Active == true or (v50 or v51 or v49))

				if title and title:IsA("TextLabel") then
					title.Text = tostring(p and p.name or "Untitled MIDI")
				end

				if status and status:IsA("TextLabel") then
					if v49 then
						status.Text = "Loading preview..."
					elseif v50 then
						status.Text = "Playing preview locally."
					elseif v51 then
						status.Text = "Preview paused."
					elseif v47 and tostring(v46.Status or "") ~= "" then
						status.Text = tostring(v46.Status)
					else
						status.Text = "Ready to preview this MIDI."
					end

					status.TextColor3 = v47
						and tostring(v46.Status or ""):lower():find("could not", 1, true)
						and Color3.fromRGB(255, 126, 153)
						or Color3.fromRGB(163, 173, 196)
				end

				if source and source:IsA("TextLabel") then
					local sourceLabel = v47 and tostring(v46.SourceLabel or "") or ""
					source.Text = state2.getMidiPreviewSourceText(p, sourceLabel)
				end

				if previewPlayButton and previewPlayButton:IsA("TextButton") then
					if v49 then
						previewPlayButton.Text = "Loading..."
					elseif v50 then
						previewPlayButton.Text = "Pause"
					elseif v51 then
						previewPlayButton.Text = "Resume"
					else
						previewPlayButton.Text = "Play Preview"
					end

					previewPlayButton.Active = not v49
					previewPlayButton.BackgroundColor3 = v51 and Color3.fromRGB(60, 160, 255)
						or v50 and Color3.fromRGB(217, 145, 48)
						or Color3.fromRGB(20, 160, 255)
				end

				if previewStopButton and previewStopButton:IsA("TextButton") then
					previewStopButton.Active = active
					previewStopButton.BackgroundColor3 = active and Color3.fromRGB(54, 61, 76)
						or Color3.fromRGB(38, 43, 56)
				end

				if previewLoad2DButton and previewLoad2DButton:IsA("TextButton") then
					local active2 = p ~= nil
						and not state2.isMidiUnavailableNoBackup(p)
						and (communityMidiLookupId ~= "" or tostring(p.url or "") ~= "")
						and not v49

					previewLoad2DButton.Text = v49 and v47 and "Loading..." or "Load to 2D"
					previewLoad2DButton.Active = active2
					previewLoad2DButton.BackgroundColor3 = active2 and Color3.fromRGB(54, 61, 76)
						or Color3.fromRGB(38, 43, 56)
					previewLoad2DButton.TextColor3 = active2 and Color3.fromRGB(255, 255, 255)
						or Color3.fromRGB(150, 158, 176)
				end

				local v53 = duration > 0 and math.clamp(v48 / duration, 0, 1) or 0

				if fill and fill:IsA("Frame") then
					fill.Size = UDim2.fromScale(v53, 1)
				end

				if knob and knob:IsA("GuiObject") then
					knob.Visible = duration > 0
					knob.Position = UDim2.fromScale(v53, 0.5)
				end

				if time and time:IsA("TextLabel") then
					time.Text = state2.formatMidiPreviewTime(v48) .. " / " .. state2.formatMidiPreviewTime(duration)
				end
			end

			function state2.stopMidiPreview()
				if state2.midiPreviewConnection then
					state2.midiPreviewConnection:Disconnect()
					state2.midiPreviewConnection = nil
				end

				local midiPreviewHandler = state2.getMidiPreviewHandler(false)

				if midiPreviewHandler and midiPreviewHandler.StopPreview then
					midiPreviewHandler.StopPreview()
				end
			end

			function state2.ensureMidiPreviewUpdater(midiPreviewPanel, _)
				state2.midiPreviewPanel = midiPreviewPanel

				if state2.midiPreviewConnection then
					return
				end

				local RunService2 = game:GetService("RunService")
				state2.midiPreviewConnection = RunService2.Heartbeat:Connect(function()
					local pendingPreviewSong = state2.pendingPreviewSong
					local midiPreviewPanel2 = state2.midiPreviewPanel

					if
						not midiPreviewPanel2
						or not midiPreviewPanel2.Visible
						or not pendingPreviewSong
						or tostring(pendingPreviewSong.mode or "") ~= "MIDI"
					then
						return
					end

					local midiPreviewHandler = state2.getMidiPreviewHandler(false)
					local v46 = midiPreviewHandler
						and midiPreviewHandler.GetPreviewState
						and midiPreviewHandler.GetPreviewState()
						or nil
					state2.updateMidiPreviewPanel(midiPreviewPanel2, pendingPreviewSong, v46)
				end)
			end

			function state2.startMidiPreview(data, p): boolean
				local communityMidiLookupId = getCommunityMidiLookupId(data)
				local url = tostring(data and data.url or "")

				if data and (url ~= "" or communityMidiLookupId ~= "") then
					if state2.isMidiUnavailableNoBackup(data) then
						state2.updateMidiPreviewPanel(p, data, {
							UploadId = communityMidiLookupId,
							Status = "This MIDI needs a new link before it can be previewed."
						})
						return false
					end

					local midiPreviewHandler = state2.getMidiPreviewHandler(true)

					if not (midiPreviewHandler and midiPreviewHandler.PreviewUrl) then
						state2.updateMidiPreviewPanel(p, data, {
							UploadId = communityMidiLookupId,
							Status = "Open or sit at a piano first to preview MIDI."
						})
						return false
					end

					local previewUrl, v46 = midiPreviewHandler.PreviewUrl({
						Url = url,
						DisplayName = data.name,
						PublicId = communityMidiLookupId,
						BackupId = tostring(data.backupId or ""),
						CanonicalId = tostring(data.canonicalId or ""),
						PreferBackup = data.backupAvailable == true
					})

					if not previewUrl then
						state2.updateMidiPreviewPanel(p, data, {
							UploadId = communityMidiLookupId,
							Status = v46 or "Could not start preview."
						})
						return false
					end

					state2.ensureMidiPreviewUpdater(p, data)
					state2.updateMidiPreviewPanel(
						p,
						data,
						midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or {
							UploadId = communityMidiLookupId,
							Loading = true
						}
					)
					recordCommunityMidiPlay2(data)
					return true
				end

				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("This MIDI is unavailable.")
				emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)

				return false
			end

			function state2.bindMidiPreviewPanel(frame)
				if not frame or not frame:IsA("Frame") or frame:GetAttribute("PreviewControlsBound") == true then
					return
				end

				frame:SetAttribute("PreviewControlsBound", true)
				local previewPlayButton = frame:FindFirstChild("PreviewPlayButton")
				local previewStopButton = frame:FindFirstChild("PreviewStopButton")
				local previewLoad2DButton = frame:FindFirstChild("PreviewLoad2DButton")
				local progressTrack = frame:FindFirstChild("ProgressTrack")
				local knob = progressTrack and progressTrack:FindFirstChild("Knob")

				if previewPlayButton and previewPlayButton:IsA("GuiButton") then
					previewPlayButton.Activated:Connect(function()
						local pendingPreviewSong = state2.pendingPreviewSong

						if not pendingPreviewSong or tostring(pendingPreviewSong.mode or "") ~= "MIDI" then
							return
						end

						local midiPreviewHandler = state2.getMidiPreviewHandler(true)
						local v46

						if midiPreviewHandler and midiPreviewHandler.GetPreviewState then
							v46 = midiPreviewHandler.GetPreviewState() or nil
						end

						local v47

						if type(v46) == "table" then
							v47 = tostring(v46.UploadId or "") == getCommunityMidiLookupId(pendingPreviewSong)
						else
							v47 = false
						end

						if
							not v47
							or v46.Playing ~= true and v46.Paused ~= true
							or not midiPreviewHandler.TogglePreviewPause
						then
							state2.startMidiPreview(pendingPreviewSong, frame)
							return
						end

						midiPreviewHandler.TogglePreviewPause()
						local updateMidiPreviewPanel = state2.updateMidiPreviewPanel
						v46 = midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or v46
						updateMidiPreviewPanel(frame, pendingPreviewSong, v46)
					end)
				end

				if previewStopButton and previewStopButton:IsA("GuiButton") then
					previewStopButton.Activated:Connect(function()
						local midiPreviewHandler = state2.getMidiPreviewHandler(false)

						if midiPreviewHandler and midiPreviewHandler.StopPreview then
							midiPreviewHandler.StopPreview()
						end

						state2.updateMidiPreviewPanel(
							frame,
							state2.pendingPreviewSong,
							midiPreviewHandler and midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or nil
						)
					end)
				end

				if previewLoad2DButton and previewLoad2DButton:IsA("GuiButton") then
					previewLoad2DButton.Activated:Connect(function()
						local pendingPreviewSong = state2.pendingPreviewSong

						if not pendingPreviewSong or tostring(pendingPreviewSong.mode or "") ~= "MIDI" then
							return
						end

						local communityMidiLookupId = getCommunityMidiLookupId(pendingPreviewSong)
						local url = tostring(pendingPreviewSong.url or "")

						if url == "" and communityMidiLookupId == "" then
							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("This MIDI is unavailable.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						elseif state2.isMidiUnavailableNoBackup(pendingPreviewSong) then
							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("This MIDI needs a new link before it can be loaded.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						else
							local midiPreviewHandler = state2.getMidiPreviewHandler(true)

							if midiPreviewHandler then
								local v46

								if midiPreviewHandler.GetPreviewState then
									v46 = midiPreviewHandler.GetPreviewState() or nil
								end

								local v47

								if type(v46) == "table" then
									v47 = tostring(v46.UploadId or "") == communityMidiLookupId
								else
									v47 = false
								end

								if v47 and v46.Has2DSource == true and midiPreviewHandler.LoadPreviewTo2D then
									local previewTo2D, v48 = midiPreviewHandler.LoadPreviewTo2D()

									if previewTo2D then
										recordCommunityMidiPlay2(pendingPreviewSong)
										setInlineMessage(v48 or "Sent to 2D Mode.", false) -- inferred equivalent call
										state2.closePreviewOverlay()
										onActivated()
										task.defer(function()
											local v49 = get2DHandler()

											if v49 and v49.EnsureExternalOverlaysSuppressed then
												v49.EnsureExternalOverlaysSuppressed()
											end
										end)
									else
										setInlineMessage(v48 or "Preview is not ready for 2D Mode yet.", true) -- inferred equivalent call
										state2.updateMidiPreviewPanel(
											frame,
											pendingPreviewSong,
											midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or nil
										)
									end

									return
								elseif midiPreviewHandler.LoadUrlTo2D then
									if state2.stopLoadingTextAnimation then
										state2.stopLoadingTextAnimation()
									end

									emptyLabel.Text = tostring("Loading MIDI into 2D Mode...")
									emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

									state2.updateMidiPreviewPanel(frame, pendingPreviewSong, {
										UploadId = communityMidiLookupId,
										Loading = true,
										Status = "Loading MIDI for 2D...",
										Has2DSource = false
									})
									local urlTo2D, v48 = midiPreviewHandler.LoadUrlTo2D({
										Url = url,
										DisplayName = pendingPreviewSong.name,
										PublicId = communityMidiLookupId,
										BackupId = tostring(pendingPreviewSong.backupId or ""),
										CanonicalId = tostring(pendingPreviewSong.canonicalId or ""),
										PreferBackup = pendingPreviewSong.backupAvailable == true,
										UseBackup = pendingPreviewSong.backupAvailable == true
									}, function(p, value)
										if p then
											recordCommunityMidiPlay2(pendingPreviewSong)
											setInlineMessage(value or "Sent to 2D Mode.", false) -- inferred equivalent call
											state2.closePreviewOverlay()
											onActivated()
											task.defer(function()
												local v49 = get2DHandler()

												if v49 and v49.EnsureExternalOverlaysSuppressed then
													v49.EnsureExternalOverlaysSuppressed()
												end
											end)
										else
											setInlineMessage( -- inferred equivalent call
												value or startMessage or "Could not load this MIDI into 2D Mode.",
												true
											)
											state2.updateMidiPreviewPanel(
												frame,
												pendingPreviewSong,
												midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or nil
											)
										end
									end)

									if not urlTo2D then
										setInlineMessage(v48 or "Could not load this MIDI into 2D Mode.", true) -- inferred equivalent call
										state2.updateMidiPreviewPanel(
											frame,
											pendingPreviewSong,
											midiPreviewHandler.GetPreviewState and midiPreviewHandler.GetPreviewState() or nil
										)
									end

									return
								end
							end

							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("2D Mode is not available yet.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						end
					end)
				end

				local function seekPreviewFromInput(p): boolean
					if not (progressTrack and progressTrack:IsA("GuiObject")) then
						return false
					end

					local pendingPreviewSong = state2.pendingPreviewSong

					if not pendingPreviewSong or tostring(pendingPreviewSong.mode or "") ~= "MIDI" then
						return false
					end

					local midiPreviewHandler = state2.getMidiPreviewHandler(false)

					if not (midiPreviewHandler and midiPreviewHandler.GetPreviewState and midiPreviewHandler.SeekPreview) then
						return false
					end

					local previewState = midiPreviewHandler.GetPreviewState()
					local duration = type(previewState) == "table"
						and tostring(previewState.UploadId or "") == getCommunityMidiLookupId(pendingPreviewSong)
						and tonumber(previewState.Duration)
						or 0

					if duration <= 0 or progressTrack.AbsoluteSize.X <= 0 then
						return false
					end

					local v47 = math.clamp(
						(p.Position.X - progressTrack.AbsolutePosition.X) / progressTrack.AbsoluteSize.X,
						0,
						1
					)
					midiPreviewHandler.SeekPreview(duration * v47)
					state2.updateMidiPreviewPanel(frame, pendingPreviewSong, midiPreviewHandler.GetPreviewState())
					return true
				end

				local function beginPreviewScrub(p)
					if
						p.UserInputType ~= Enum.UserInputType.MouseButton1
						and p.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end

					state2.midiPreviewScrubbing = true
					seekPreviewFromInput(p)
				end

				if progressTrack and progressTrack:IsA("GuiObject") then
					progressTrack.InputBegan:Connect(beginPreviewScrub)
				end

				if knob and knob:IsA("GuiObject") then
					knob.InputBegan:Connect(beginPreviewScrub)
				end

				local UserInputService = game:GetService("UserInputService")
				UserInputService.InputChanged:Connect(function(input)
					if not state2.midiPreviewScrubbing then
						return
					end

					if
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					then
						seekPreviewFromInput(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					then
						state2.midiPreviewScrubbing = false
					end
				end)
			end

			function state2.closePreviewOverlay()
				state2.stopMidiPreview()
				state2.pendingPreviewSong = nil

				if state2.previewCreatorConnection then
					state2.previewCreatorConnection:Disconnect()
					state2.previewCreatorConnection = nil
				end

				local previewOverlay = parent:WaitForChild("PreviewOverlay")
				previewOverlay.Visible = false
			end

			function state2.openPreviewOverlay(pendingPreviewSong)
				if not pendingPreviewSong then
					return
				end

				state2.pendingPreviewSong = pendingPreviewSong
				local previewOverlay = parent:WaitForChild("PreviewOverlay")
				local panel2 = previewOverlay:FindFirstChild("Panel")
				state2.applyModalScale(panel2, 808, 540)
				local details = panel2 and panel2:FindFirstChild("Details")
				local preview = panel2 and panel2:FindFirstChild("Preview")

				if details then
					local title = details:FindFirstChild("Title")
					local creator = details:FindFirstChild("Creator")
					local difficultyBadge = details:FindFirstChild("DifficultyBadge")
					local stats = details:FindFirstChild("Stats")
					local description = details:FindFirstChild("Description")
					local playSheetButton = details:FindFirstChild("PlaySheetButton")
					local favoriteButton = details:FindFirstChild("FavoriteButton")
					local backgroundImage = details:FindFirstChild("BackgroundImage")

					if backgroundImage and backgroundImage:IsA("ImageLabel") then
						local defaultImage = tostring(backgroundImage:GetAttribute("DefaultImage") or backgroundImage.Image)
						local image = state2.profileAssetImage(pendingPreviewSong.imageAssetId)

						if image == "" or not image then
							image = defaultImage
						end

						backgroundImage.Image = image
						backgroundImage.Visible = true
					end

					if title then
						title.Text = tostring(pendingPreviewSong.name or "Untitled Sheet")
					end

					if creator then
						creator.Text = "by " .. tostring(pendingPreviewSong.creatorDisplayName or pendingPreviewSong.creatorName or "Player")
						creator.TextColor3 = Color3.fromRGB(75, 190, 255)
						configureTextObject(creator, 13, 8)
					end

					if state2.previewCreatorConnection then
						state2.previewCreatorConnection:Disconnect()
						state2.previewCreatorConnection = nil
					end

					local creatorLink = details:FindFirstChild("CreatorLink")

					if creatorLink and not creatorLink:IsA("TextButton") then
						creatorLink:Destroy()
						creatorLink = nil
					end

					if not creatorLink then
						creatorLink = Instance.new("TextButton")
						creatorLink.Name = "CreatorLink"
						creatorLink.BackgroundTransparency = 1
						creatorLink.BorderSizePixel = 0
						creatorLink.AutoButtonColor = false
						creatorLink.Text = ""
						creatorLink.Parent = details
					end

					local v46 = math.max(0, (math.floor(tonumber(pendingPreviewSong.ownerUserId) or 0)))
					creatorLink.Visible = v46 > 0
					creatorLink.Active = v46 > 0
					creatorLink.ZIndex = (creator and creator.ZIndex or details.ZIndex) + 3

					if creator and creator:IsA("GuiObject") then
						creatorLink.Position = creator.Position
						creatorLink.Size = creator.Size
					end

					if v46 > 0 then
						state2.previewCreatorConnection = creatorLink.Activated:Connect(function()
							state2.openCommunityProfile(
								v46,
								pendingPreviewSong.creatorDisplayName,
								pendingPreviewSong.creatorName
							)
						end)
					end

					state2.applyDifficultyBadgeStyle(difficultyBadge, pendingPreviewSong.difficulty)

					if stats then
						stats.Text = string.format(
							"%s Likes    %s Plays    Uploaded %s",
							comma(pendingPreviewSong.likes or 0),
							comma(pendingPreviewSong.plays or 0),
							(formatUploadDate(pendingPreviewSong.publishedAt))
						)
					end

					local midiUnavailableNoBackup = state2.isMidiUnavailableNoBackup(pendingPreviewSong)

					if description then
						if midiUnavailableNoBackup then
							description.Text = "This MIDI link is unavailable. The creator can repair it with a new direct link."
							description.TextColor3 = Color3.fromRGB(255, 170, 185)
						else
							local text = tostring(pendingPreviewSong.preview or "") ~= ""
								and "\"" .. tostring(pendingPreviewSong.preview) .. "\""

							if not text then
								text = "\"" .. shortSheetPreview(pendingPreviewSong.sheet) .. "\"" -- inferred equivalent call
							end

							description.Text = text
							description.TextColor3 = Color3.fromRGB(145, 151, 166)
						end
					end

					if playSheetButton then
						playSheetButton.Text = midiUnavailableNoBackup and "Unavailable"
							or tostring(pendingPreviewSong.mode or "") == "MIDI" and "Load MIDI"
							or "Load Sheet"
						playSheetButton.Active = not midiUnavailableNoBackup
						playSheetButton.BackgroundColor3 = midiUnavailableNoBackup and Color3.fromRGB(48, 52, 64)
							or Color3.fromRGB(20, 160, 255)
					end

					if favoriteButton then
						local mode = tostring(pendingPreviewSong.mode or "")
						local v47 = mode == "Community"
						local v48 = pendingPreviewSong.ownedByLocalPlayer == true
							or (tonumber(pendingPreviewSong.ownerUserId) or 0) == LocalPlayer.UserId
						local v49 = v47 and v48 and tostring(pendingPreviewSong.sheetId or "") ~= ""

						if mode ~= "MIDI" then
							v48 = false
						end

						favoriteButton.Visible = v49 or v48

						if favoriteButton:IsA("TextButton") then
							favoriteButton.Text = ""
							favoriteButton.TextTransparency = 1
						end

						local buttonLabel = favoriteButton:FindFirstChild("ButtonLabel")

						if buttonLabel and not buttonLabel:IsA("TextLabel") then
							buttonLabel:Destroy()
							buttonLabel = nil
						end

						if not buttonLabel then
							buttonLabel = Instance.new("TextLabel")
							buttonLabel.Name = "ButtonLabel"
							buttonLabel.Parent = favoriteButton
						end

						local icon = favoriteButton:FindFirstChild("Icon")

						if v49 or v48 then
							favoriteButton.BackgroundColor3 = v48
								and (midiUnavailableNoBackup and Color3.fromRGB(118, 45, 62) or Color3.fromRGB(48, 39, 96))
								or Color3.fromRGB(31, 85, 142)
							buttonLabel.BackgroundTransparency = 1
							buttonLabel.Position = UDim2.fromScale(0, 0)
							buttonLabel.Size = UDim2.fromScale(1, 1)
							buttonLabel.Font = Enum.Font.GothamBold
							buttonLabel.TextColor3 = v48
								and (midiUnavailableNoBackup and Color3.fromRGB(255, 170, 185) or Color3.fromRGB(232, 224, 255))
								or Color3.fromRGB(255, 255, 255)
							buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
							buttonLabel.TextYAlignment = Enum.TextYAlignment.Center
							buttonLabel.ZIndex = favoriteButton.ZIndex + 1
							buttonLabel.Text = v48 and (midiUnavailableNoBackup and "Repair Link" or "Update Link")
								or "Manage Upload"
							buttonLabel.TextWrapped = true
							buttonLabel.TextScaled = true
							configureTextObject(buttonLabel, 13, 8)

							if icon and icon:IsA("ImageLabel") then
								icon.Visible = false
							end
						end
					end
				end

				if preview then
					local visible = tostring(pendingPreviewSong.mode or "") == "MIDI"
					local header = preview:FindFirstChild("Header")
					local copyHint = preview:FindFirstChild("CopyHint")
					local sheetScroll = preview:FindFirstChild("SheetScroll")
					local sheetText = sheetScroll and sheetScroll:FindFirstChild("SheetText")
					local midiPreviewPanel = state2.ensureMidiPreviewPanel(preview)

					if header then
						header.Text = visible and "MIDI PREVIEW" or "SHEET PREVIEW"
					end

					if copyHint and copyHint:IsA("TextLabel") then
						copyHint.Text = visible and "Load this upload into the MIDI Player."
							or "Select the sheet text and press Ctrl+C to copy."
						copyHint.TextWrapped = true
						copyHint.TextScaled = true
						configureTextObject(copyHint, 11, 8)
					end

					if sheetScroll and sheetScroll:IsA("GuiObject") then
						sheetScroll.Visible = not visible
					end

					if midiPreviewPanel then
						midiPreviewPanel.Visible = visible

						if visible then
							state2.bindMidiPreviewPanel(midiPreviewPanel)
							state2.ensureMidiPreviewUpdater(midiPreviewPanel, pendingPreviewSong)
							state2.updateMidiPreviewPanel(midiPreviewPanel, pendingPreviewSong, nil)
						end
					end

					if sheetText then
						if
							not visible
							and getSongSheet(pendingPreviewSong) == "" -- inferred equivalent call
							and state2.ensureCommunitySheetLoaded
						then
							state2.ensureCommunitySheetLoaded(pendingPreviewSong)
						end

						sheetText.Text = visible and ""
							or getSongSheet(pendingPreviewSong) == "" -- inferred equivalent call
							and "Sheet text is not loaded. Click Load Sheet to try again."
							or getSongSheet(pendingPreviewSong) -- inferred equivalent call
							or "Sheet text is not loaded. Click Load Sheet to try again."

						if sheetText:IsA("TextBox") then
							sheetText.CursorPosition = 1
							sheetText.SelectionStart = -1
							updateSheetPreviewScroll(sheetScroll, sheetText)
						end
					end

					local transposeBadge = preview:FindFirstChild("TransposeBadge")

					if transposeBadge and transposeBadge:IsA("TextLabel") then
						transposeBadge.Visible = not visible
						transposeBadge.Text = "TRANSPOSE: " .. tostring((math.floor(tonumber(pendingPreviewSong.transpose) or 0)))
					end
				end

				previewOverlay.Visible = true
			end

			function state2.setReportReasonVisuals()
				local panel2 = parent:WaitForChild("ReportOverlay"):FindFirstChild("Panel")

				if not panel2 then
					return
				end

				for i = 1, 5 do
					local button = panel2:FindFirstChild("Reason" .. tostring(i))

					if not (button and button:IsA("TextButton")) then
						continue
					end

					local v46 = button.Text == state2.selectedReportReason
					button.BackgroundColor3 = v46 and Color3.fromRGB(58, 25, 35) or Color3.fromRGB(42, 45, 55)
					button.TextColor3 = v46 and Color3.fromRGB(255, 79, 96) or Color3.fromRGB(170, 178, 194)
				end

				local visible = state2.selectedReportReason == "Other"
				local otherBox = panel2:FindFirstChild("OtherBox")

				if otherBox and otherBox:IsA("TextBox") then
					otherBox.Visible = visible
					otherBox.TextWrapped = true
					otherBox.TextScaled = true
				end

				local prompt = panel2:FindFirstChild("Prompt")

				if prompt and prompt:IsA("TextLabel") then
					prompt.TextColor3 = Color3.fromRGB(195, 202, 216)
				end

				state2.applyModalScale(panel2, 410, visible and 560 or 490)
			end

			function state2.closeReportOverlay()
				state2.pendingReportSong = nil
				state2.selectedReportReason = nil
				local reportOverlay = parent:WaitForChild("ReportOverlay")
				reportOverlay.Visible = false
			end

			function state2.openReportOverlay(pendingReportSong)
				if not pendingReportSong then
					return
				end

				state2.pendingReportSong = pendingReportSong
				state2.selectedReportReason = nil
				local reportOverlay = parent:WaitForChild("ReportOverlay")
				local panel2 = reportOverlay:FindFirstChild("Panel")
				state2.applyModalScale(panel2, 410, 490)
				local v46 = tostring(pendingReportSong.mode or "") == "MIDI"
				local title = panel2 and panel2:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.Text = v46 and "Report MIDI" or "Report Sheet"
				end

				local prompt = panel2 and panel2:FindFirstChild("Prompt")

				if prompt and prompt:IsA("TextLabel") then
					prompt.Text = v46 and "Why are you reporting this MIDI?" or "Why are you reporting this sheet?"
				end

				local targetBox = panel2 and panel2:FindFirstChild("TargetBox")

				if targetBox then
					local targetTitle = targetBox:FindFirstChild("TargetTitle")
					local targetCreator = targetBox:FindFirstChild("TargetCreator")

					if targetTitle then
						targetTitle.Text = "Reporting: " .. tostring(pendingReportSong.name or "Untitled")
					end

					if targetCreator then
						targetCreator.Text = "by " .. tostring(pendingReportSong.creatorDisplayName or pendingReportSong.creatorName or "Player")
					end
				end

				local otherBox = panel2 and panel2:FindFirstChild("OtherBox")

				if otherBox and otherBox:IsA("TextBox") then
					otherBox.Text = ""
					otherBox.Visible = false
					otherBox.TextWrapped = true
					otherBox.TextScaled = true
				end

				state2.setReportReasonVisuals()
				reportOverlay.Visible = true
			end

			do
				local function findSheetPublishControl(instance, childName) -- 6 equivalent calls inferred from this helper
					return instance and instance:FindFirstChild(childName, true)
				end
			end

			function updateSheetPublishSheetBoxLayout(instance)
				local formScroll = instance and instance:FindFirstChild("FormScroll", true)
				local sheetBox = instance and instance:FindFirstChild("SheetBox", true)

				if not (formScroll and formScroll:IsA("ScrollingFrame") and sheetBox and sheetBox:IsA("TextBox")) then
					return
				end

				for _, guiObject in ipairs(formScroll:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject:GetAttribute("SheetPublishBaseY") == nil) then
						continue
					end

					guiObject:SetAttribute("SheetPublishBaseY", guiObject.Position.Y.Offset)
					guiObject:SetAttribute("SheetPublishBaseHeight", guiObject.Size.Y.Offset)
				end

				if formScroll:GetAttribute("SheetPublishBaseCanvasY") == nil then
					formScroll:SetAttribute("SheetPublishBaseCanvasY", formScroll.CanvasSize.Y.Offset)
				end

				sheetBox.TextWrapped = true
				sheetBox.TextScaled = false
				sheetBox.TextXAlignment = Enum.TextXAlignment.Left
				sheetBox.TextYAlignment = Enum.TextYAlignment.Top
				sheetBox.ClearTextOnFocus = false
				pcall(function()
					sheetBox.MultiLine = true
				end)

				local sheetPublishBaseY = sheetBox:GetAttribute("SheetPublishBaseY") or sheetBox.Position.Y.Offset
				local sheetPublishBaseHeight = sheetBox:GetAttribute("SheetPublishBaseHeight") or sheetBox.Size.Y.Offset
				local v46 = math.max(220, sheetBox.AbsoluteSize.X - 20)
				local text = tostring(sheetBox.Text or "")
				local v47 = math.max(
					150,
					(math.min(
						9000,
						math.ceil(TextService:GetTextSize(
							(text == "" or not text) and " " or text,
							sheetBox.TextSize,
							sheetBox.Font,
							Vector2.new(v46, 1e999)
						).Y) + 28
					))
				)
				local v48 = v47 - sheetPublishBaseHeight

				sheetBox.Size = UDim2.new(sheetBox.Size.X.Scale, sheetBox.Size.X.Offset, 0, v47)

				for _, guiObject in ipairs(formScroll:GetChildren()) do
					if not (guiObject:IsA("GuiObject") and guiObject ~= sheetBox) then
						continue
					end

					local sheetPublishBaseY2 = guiObject:GetAttribute("SheetPublishBaseY")

					if type(sheetPublishBaseY2) == "number" and sheetPublishBaseY < sheetPublishBaseY2 then
						guiObject.Position = UDim2.new(
							guiObject.Position.X.Scale,
							guiObject.Position.X.Offset,
							0,
							sheetPublishBaseY2 + v48
						)
					end
				end

				local maxValue = 0

				for _, guiObject in ipairs(formScroll:GetChildren()) do
					if guiObject:IsA("GuiObject") then
						maxValue = math.max(maxValue, guiObject.Position.Y.Offset + guiObject.Size.Y.Offset)
					end
				end

				local sheetPublishBaseCanvasY = formScroll:GetAttribute("SheetPublishBaseCanvasY")
					or formScroll.CanvasSize.Y.Offset
				formScroll.CanvasSize = UDim2.new(0, 0, 0, (math.max(sheetPublishBaseCanvasY + v48, maxValue + 20)))
			end

			getDefaultSheetCardImage = function()
				local iconHolder = cardTemplate:FindFirstChild("IconHolder")
				local musicIcon = iconHolder and iconHolder:FindFirstChild("MusicIcon")
				return musicIcon and musicIcon:IsA("ImageLabel") and musicIcon.Image or ""
			end

			function state2.closeSheetPublishOverlay()
				local sheetPublishOverlay = parent:WaitForChild("SheetPublishOverlay")
				local savedSheetPicker = sheetPublishOverlay:FindFirstChild("SavedSheetPicker")

				if savedSheetPicker then
					savedSheetPicker.Visible = false
				end

				sheetPublishOverlay.Visible = false
			end

			function state2.applySheetPublishPersonalPayload(p)
				local v46 = type(p) == "table" and p or {}
				state2.sheetPublishPersonalSheets = type(v46.Sheets) == "table" and v46.Sheets or {}
				state2.sheetPublishPersonalLimit = math.max(
					1,
					(math.floor(tonumber(v46.Limit) or state2.sheetPublishPersonalLimit or 20))
				)
			end

			function state2.findSheetPublishPersonalSheet(value)
				local v46 = tostring(value or "")

				for _, v47 in ipairs(state2.sheetPublishPersonalSheets or {}) do
					if tostring(v47.Id or "") == v46 then
						return v47
					end
				end

				return nil
			end

			function state2.refreshSheetPublishPersonalSheets(): boolean
				local success, result, v46, v47 = pcall(function()
					return GetPersonalSheetsRemote:InvokeServer()
				end)

				if success and result then
					state2.applySheetPublishPersonalPayload(v47)
					return true
				end

				state2.setSheetPublishStatus(
					success and (v46 or "Could not load Personal Sheets.") or "Could not reach the Personal Sheets service.",
					true
				)
				return false
			end

			function state2.applySheetPublishSource(data)
				local panel2 = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel")

				if not panel2 then
					return
				end

				local public = type(data) == "table" and type(data.Public) == "table" and data.Public or {}
				local isPublished = public.IsPublished == true
				local sheetPublishSheetId

				if type(data) == "table" then
					sheetPublishSheetId = tostring(data.Id or "") or nil
				end

				state2.sheetPublishSheetId = sheetPublishSheetId

				if state2.sheetPublishSheetId == "" then
					state2.sheetPublishSheetId = nil
				end

				state2.sheetPublishIsPublished = isPublished
				state2.sheetPublishDifficulty = state2.getDifficultyDisplayLabel(public.Difficulty or "Intermediate")

				local v47 = {
					TitleBox = type(data) == "table" and tostring(data.Name or "") or "",
					SheetBox = type(data) == "table" and tostring(data.Sheet or "") or "",
					DescriptionBox = tostring(public.Description or ""),
					ImageIdBox = tostring(public.ImageAssetId or ""),
					TransposeBox = tostring((math.floor(tonumber(public.Transpose) or 0)))
				}

				for k, text in pairs(v47) do
					local sheetPublishControl = findSheetPublishControl(panel2, k) -- inferred equivalent call

					if sheetPublishControl and sheetPublishControl:IsA("TextBox") then
						sheetPublishControl.Text = text
					end
				end

				updateSheetPublishSheetBoxLayout(panel2)
				local sheetPublishControl = findSheetPublishControl(panel2, "SourceButton") -- inferred equivalent call

				if sheetPublishControl and sheetPublishControl:IsA("TextButton") then
					sheetPublishControl.Text = type(data) == "table"
						and (isPublished and "[Published] " or "") .. tostring(data.Name or "Untitled Sheet")
						or "New community sheet"
				end

				local title = panel2:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.Text = isPublished and "Manage Sheet" or data and "Publish Saved Sheet" or "Publish Sheet"
				end

				local submitButton = panel2:FindFirstChild("SubmitButton")

				if submitButton and submitButton:IsA("TextButton") then
					submitButton.Text = isPublished and "Update" or "Publish"
				end

				local unpublishButton = panel2:FindFirstChild("UnpublishButton")

				if unpublishButton and unpublishButton:IsA("GuiButton") then
					unpublishButton.Visible = isPublished
				end

				state2.updateSheetPublishImagePreview()
				state2.updateSheetPublishDifficultyVisuals()
			end

			function state2.ensureSavedSheetStroke(parent2, color, transparency)
				local uiStroke = parent2:FindFirstChildOfClass("UIStroke")

				if not uiStroke then
					uiStroke = Instance.new("UIStroke")
					uiStroke.Name = "UIStroke"
					uiStroke.Parent = parent2
				end

				uiStroke.Color = color
				uiStroke.Transparency = transparency
				uiStroke.Thickness = 1
				return uiStroke
			end

			function state2:styleSavedSheetRow(p)
				self.BackgroundColor3 = p and Color3.fromRGB(35, 47, 64) or Color3.fromRGB(31, 36, 47)
				self.TextColor3 = p and Color3.fromRGB(244, 248, 255) or Color3.fromRGB(224, 229, 241)
				self.TextSize = 13
				self.TextXAlignment = Enum.TextXAlignment.Left
				self.TextWrapped = true
				self.TextScaled = false
				self.AutoButtonColor = true
				state2.ensureSavedSheetStroke(
					self,
					p and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(48, 55, 70),
					p and 0.25 or 0.55
				)
			end

			function state2.styleSavedSheetPicker()
				local savedSheetPicker = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("SavedSheetPicker")
				local panel2 = savedSheetPicker and savedSheetPicker:FindFirstChild("Panel")

				if not panel2 then
					return nil, nil
				end

				savedSheetPicker.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				savedSheetPicker.BackgroundTransparency = 0.32
				panel2.BackgroundColor3 = Color3.fromRGB(27, 29, 37)
				panel2.ClipsDescendants = true
				state2.ensureSavedSheetStroke(panel2, Color3.fromRGB(61, 70, 90), 0.35)
				local title = panel2:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.TextColor3 = Color3.fromRGB(245, 247, 252)
					configureTextObject(title, 20, 11)
				end

				local subtitle = panel2:FindFirstChild("Subtitle")

				if subtitle and subtitle:IsA("TextLabel") then
					subtitle.TextColor3 = Color3.fromRGB(150, 157, 174)
					configureTextObject(subtitle, 13, 8)
				end

				local closeButton = panel2:FindFirstChild("CloseButton")

				if closeButton and closeButton:IsA("TextButton") then
					closeButton.Text = "x"
					closeButton.FontFace = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json")
					closeButton.TextColor3 = Color3.fromRGB(170, 178, 194)
					closeButton.TextSize = 20
					closeButton.TextScaled = true
					closeButton.BackgroundColor3 = Color3.fromRGB(42, 45, 55)
					closeButton.Size = UDim2.fromOffset(40, 40)
					closeButton.Position = UDim2.new(1, -54, 0, 18)
					configureTextObject(closeButton, 20, 12)
				end

				local newSheetButton = panel2:FindFirstChild("NewSheetButton")

				if newSheetButton and newSheetButton:IsA("TextButton") then
					newSheetButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
					newSheetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					newSheetButton.TextSize = 13
					newSheetButton.TextScaled = true
					newSheetButton.TextWrapped = true
					configureTextObject(newSheetButton, 13, 9)
				end

				local sheetList = panel2:FindFirstChild("SheetList")

				if sheetList and sheetList:IsA("ScrollingFrame") then
					sheetList.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
					sheetList.ScrollBarImageColor3 = Color3.fromRGB(76, 86, 110)
					sheetList.ScrollBarThickness = 4
					state2.ensureSavedSheetStroke(sheetList, Color3.fromRGB(44, 50, 66), 0.35)
					local sheetButtonTemplate = sheetList:FindFirstChild("SheetButtonTemplate")

					if sheetButtonTemplate and sheetButtonTemplate:IsA("TextButton") then
						state2.styleSavedSheetRow(sheetButtonTemplate, false)
					end
				end

				return panel2, sheetList
			end

			function state2.renderSavedSheetPicker()
				local _, parent2 = state2.styleSavedSheetPicker()
				local savedSheetPicker = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("SavedSheetPicker")
				local sheetButtonTemplate = parent2 and parent2:FindFirstChild("SheetButtonTemplate")

				if not (parent2 and sheetButtonTemplate and sheetButtonTemplate:IsA("TextButton")) then
					return
				end

				for _, button in ipairs(parent2:GetChildren()) do
					if button:IsA("TextButton") and button ~= sheetButtonTemplate then
						button:Destroy()
					end
				end

				for i, v47 in ipairs(state2.sheetPublishPersonalSheets or {}) do
					local clone = sheetButtonTemplate:Clone()
					clone.Name = "Sheet_" .. tostring(i)
					clone.LayoutOrder = i
					clone.Visible = true
					clone.Text = ((type(v47.Public) == "table" and v47.Public or {}).IsPublished == true and "[Published] " or "") .. tostring(v47.Name or "Untitled Sheet")
					state2.styleSavedSheetRow(
						clone,
						tostring(v47.Id or "") == tostring(state2.sheetPublishSheetId or "")
					)
					clone.Parent = parent2
					clone.Activated:Connect(function()
						state2.applySheetPublishSource(v47)
						savedSheetPicker.Visible = false
					end)
				end
			end

			function state2.openSavedSheetPicker()
				state2.refreshSheetPublishPersonalSheets()
				state2.renderSavedSheetPicker()
				local savedSheetPicker = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("SavedSheetPicker")
				local panel2 = savedSheetPicker and savedSheetPicker:FindFirstChild("Panel")
				state2.styleSavedSheetPicker()
				state2.applyModalScale(panel2, 470, 520)

				if savedSheetPicker then
					savedSheetPicker.Visible = true
				end
			end

			function state2.setSheetPublishStatus(value, p)
				local sheetPublishControl = findSheetPublishControl( -- inferred equivalent call
					parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel"),
					"Status"
				)

				if sheetPublishControl and sheetPublishControl:IsA("TextLabel") then
					sheetPublishControl.Text = tostring(value or "")
					sheetPublishControl.TextColor3 = p and Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end
			end

			function state2.updateSortMenuVisuals()
				local sortMenu = toolbar:FindFirstChild("SortMenu")

				if not sortMenu then
					return
				end

				toolbar.ZIndex = 10
				sortMenu.ZIndex = 20
				sortMenu.ClipsDescendants = true
				sortMenu.Size = UDim2.fromOffset(172, 190)
				local v46 = {
					Default = "Default",
					Newest = "Newest",
					Oldest = "Oldest",
					TopLiked = "Top Liked",
					MostPlayed = "Most Played"
				}

				for i, childName in ipairs({
					"Default",
					"Newest",
					"Oldest",
					"TopLiked",
					"MostPlayed"
				}) do
					local button = sortMenu:FindFirstChild(childName)

					if not (button and button:IsA("TextButton")) then
						continue
					end

					local v47 = state2.sortMode == childName
					button.Text = v46[childName]
					button.LayoutOrder = i
					button.Size = UDim2.new(1, 0, 0, 38)
					button.BorderSizePixel = 0
					button.AutoButtonColor = false
					button.BackgroundColor3 = Color3.fromRGB(20, 58, 87)
					button.BackgroundTransparency = 1
					button.TextColor3 = v47 and Color3.fromRGB(20, 160, 255) or Color3.fromRGB(177, 184, 198)
					button.Font = v47 and Enum.Font.GothamBold or Enum.Font.GothamMedium
					button.ZIndex = sortMenu.ZIndex + 1
				end
			end

			function state2.setSortMode(p)
				local sortMode = p ~= "Default"
					and p ~= "Newest"
					and p ~= "Oldest"
					and p ~= "TopLiked"
					and p ~= "MostPlayed"
					and "Default"
					or p
				state2.sortMode = sortMode

				if sortMode ~= "Default" then
					state2.communitySectionView = nil
				end

				local sortMenu = toolbar:FindFirstChild("SortMenu")

				if sortMenu then
					sortMenu.Visible = false
				end

				state2.mobileSupport.HideSortMenu(controls)
				state2.updateSortMenuVisuals()
				state2.mobileSupport.UpdateSort({
					state = state2,
					controls = controls,
					selectedMode = selectedMode,
					configureTextObject = configureTextObject
				})
				fn2(true)
			end

			function state2.updateSheetPublishDifficultyVisuals(p)
				local panel2 = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel")
				local sheetPublishControl = findSheetPublishControl(panel2, "DifficultySelector") -- inferred equivalent call
				local difficultySelectionIndicator = sheetPublishControl
					and sheetPublishControl:FindFirstChild("DifficultySelectionIndicator")

				if not (panel2 and sheetPublishControl and sheetPublishControl:IsA("Frame") and difficultySelectionIndicator and difficultySelectionIndicator:IsA("Frame")) then
					return
				end

				local difficultyDisplayLabel = state2.getDifficultyDisplayLabel(state2.sheetPublishDifficulty or "Intermediate")
				local v46 = {
					{ Name = "DifficultyBeginner", Difficulty = "Beginner" },
					{ Name = "DifficultyIntermediate", Difficulty = "Intermediate" },
					{ Name = "DifficultyAdvanced", Difficulty = "Advanced" },
					{ Name = "DifficultyExpert", Difficulty = "Expert" }
				}
				local v47 = 2

				for i, v48 in ipairs(v46) do
					local sheetPublishControl2 = findSheetPublishControl(sheetPublishControl, v48.Name) -- inferred equivalent call

					if not (sheetPublishControl2 and sheetPublishControl2:IsA("TextButton")) then
						continue
					end

					local v49 = difficultyDisplayLabel == v48.Difficulty
					sheetPublishControl2.Text = v48.Difficulty
					sheetPublishControl2.BackgroundTransparency = 1
					local textColor

					if v49 then
						textColor = getDifficultyVisual(v48.Difficulty).Text or Color3.fromRGB(170, 178, 194) -- inferred equivalent call
					else
						textColor = Color3.fromRGB(170, 178, 194)
					end

					sheetPublishControl2.TextColor3 = textColor
					sheetPublishControl2.Font = v49 and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
					sheetPublishControl2.ZIndex = sheetPublishControl.ZIndex + 2

					if v49 then
						v47 = i
					end
				end

				local difficultyVisual = getDifficultyVisual(difficultyDisplayLabel) -- inferred equivalent call
				local udim = UDim2.new((v47 - 1) / #v46, 3, 0, 3)
				local udim2 = UDim2.new(1 / #v46, -6, 1, -6)
				local uiStroke = difficultySelectionIndicator:FindFirstChildOfClass("UIStroke")
				difficultySelectionIndicator.Visible = true
				difficultySelectionIndicator.ZIndex = sheetPublishControl.ZIndex + 1

				if state2.sheetPublishDifficultyIndicatorTween then
					state2.sheetPublishDifficultyIndicatorTween:Cancel()
					state2.sheetPublishDifficultyIndicatorTween = nil
				end

				if state2.sheetPublishDifficultyStrokeTween then
					state2.sheetPublishDifficultyStrokeTween:Cancel()
					state2.sheetPublishDifficultyStrokeTween = nil
				end

				if p then
					local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					local TweenService = game:GetService("TweenService")
					local tween = TweenService:Create(difficultySelectionIndicator, tweenInfo, {
						Position = udim,
						Size = udim2,
						BackgroundColor3 = difficultyVisual.Background
					})

					state2.sheetPublishDifficultyIndicatorTween = tween
					tween.Completed:Once(function()
						if state2.sheetPublishDifficultyIndicatorTween == tween then
							state2.sheetPublishDifficultyIndicatorTween = nil
						end
					end)
					tween:Play()

					if uiStroke then
						local TweenService2 = game:GetService("TweenService")
						local tween2 = TweenService2:Create(uiStroke, tweenInfo, {
							Color = difficultyVisual.Border
						})
						state2.sheetPublishDifficultyStrokeTween = tween2
						tween2.Completed:Once(function()
							if state2.sheetPublishDifficultyStrokeTween == tween2 then
								state2.sheetPublishDifficultyStrokeTween = nil
							end
						end)
						tween2:Play()
					end
				else
					difficultySelectionIndicator.Position = udim
					difficultySelectionIndicator.Size = udim2
					difficultySelectionIndicator.BackgroundColor3 = difficultyVisual.Background

					if uiStroke then
						uiStroke.Color = difficultyVisual.Border
					end
				end
			end

			function state2.setSheetPublishDifficulty(value)
				state2.sheetPublishDifficulty = state2.getDifficultyDisplayLabel(value or "Intermediate")
				state2.updateSheetPublishDifficultyVisuals(true)
			end

			function state2.normalizeSheetImageValue(value)
				local v46 = tostring(value or ""):gsub("%s+", "")

				if v46 == "" then
					return ""
				end

				local v47 = string.lower(v46)
				local v48 = v47:match("^catalog:(%d+)$")
					or v47:match("^thumb:(%d+)$")
					or v47:match("type=asset&id=(%d+)")

				if v48 and tonumber(v48) ~= 0 then
					return "catalog:" .. v48
				end

				local v49 = v46:match("^rbxassetid://(%d+)$") or v46:match("[?&]id=(%d+)") or v46:match("^(%d+)$")
				return if v49 and tonumber(v49) ~= 0 then v49 else nil
			end

			function state2.updateSheetPublishImagePreview()
				local panel2 = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel")

				if not panel2 then
					return
				end

				local imageIdBox = panel2 and panel2:FindFirstChild("ImageIdBox", true)
				local imagePreview = panel2 and panel2:FindFirstChild("ImagePreview", true)

				if not (imageIdBox and imageIdBox:IsA("TextBox") and imagePreview and imagePreview:IsA("ImageLabel")) then
					return
				end

				local sheetImageValue = state2.normalizeSheetImageValue(imageIdBox.Text)

				imagePreview.Image = sheetImageValue ~= nil
					and sheetImageValue ~= ""
					and state2.profileAssetImage(sheetImageValue)
					or getDefaultSheetCardImage()
				imagePreview.ImageTransparency = imagePreview.Image == "" and 1 or 0
				local uiStroke = imagePreview:FindFirstChildOfClass("UIStroke")

				if uiStroke then
					uiStroke.Color = sheetImageValue == nil and Color3.fromRGB(255, 106, 120)
						or Color3.fromRGB(66, 72, 88)
				end
			end

			function state2.buildSheetPublishPreviewSong()
				local panel2 = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel")

				if not panel2 then
					return nil
				end

				local titleBox = panel2 and panel2:FindFirstChild("TitleBox", true)
				local sheetBox = panel2 and panel2:FindFirstChild("SheetBox", true)
				local descriptionBox = panel2 and panel2:FindFirstChild("DescriptionBox", true)
				local transposeBox = panel2 and panel2:FindFirstChild("TransposeBox", true)
				local imageIdBox = panel2 and panel2:FindFirstChild("ImageIdBox", true)

				local name = trimText(titleBox and titleBox.Text or "") -- inferred equivalent call
				local sheet = trimText(sheetBox and sheetBox.Text or "") -- inferred equivalent call
				local v48 = trimText(descriptionBox and descriptionBox.Text or "") -- inferred equivalent call
				local v49 = trimText(transposeBox and transposeBox.Text or "") -- inferred equivalent call
				local v50 = trimText(imageIdBox and imageIdBox.Text or "") -- inferred equivalent call
				local sheetImageValue = state2.normalizeSheetImageValue(v50)
				local transpose = v49 == "" and 0 or tonumber(v49)

				if name == "" then
					state2.setSheetPublishStatus("Enter a song title before previewing.", true)
					return nil
				end

				if sheet == "" then
					state2.setSheetPublishStatus("Paste sheet notes before previewing.", true)
					return nil
				end

				local v52 = math.max(1, (math.floor(tonumber(state2.communitySheetPublicMaxTextLength) or 10000)))

				if v52 < #sheet then
					state2.setSheetPublishStatus(
						"Community sheet text must be " .. comma(v52) .. " characters or fewer. This sheet has " .. comma(#sheet) .. ".",
						true
					)
					return nil
				end

				if sheetImageValue == nil then
					state2.setSheetPublishStatus(
						"Enter a valid image asset ID, choose Browse, or leave it blank.",
						true
					)
					return nil
				end

				if not transpose or transpose ~= math.floor(transpose) or transpose < -24 or transpose > 24 then
					state2.setSheetPublishStatus("Transpose must be a whole number from -24 to 24.", true)
					return nil
				end

				local v53 = {
					id = "__draft_sheet_preview",
					sheetId = state2.sheetPublishSheetId,
					name = name,
					category = "Draft",
					difficulty = state2.getDifficultyDisplayLabel(state2.sheetPublishDifficulty or "Intermediate"),
					transpose = transpose,
					sheet = sheet,
					description = v48,
					preview = 0,
					imageAssetId = 0,
					mode = "Community",
					source = "Community",
					creatorName = 0,
					creatorDisplayName = 0,
					ownerUserId = 0,
					ownedByLocalPlayer = true,
					likes = 0,
					plays = 0,
					reportCount = 0,
					isFavorited = false
				}

				if v48 == "" or not v48 then
					v48 = tostring(sheet or ""):gsub("%s+", " ")

					if v48 == "" then
						v48 = "No preview available yet."
					elseif #v48 > 92 then
						v48 = v48:sub(1, 89) .. "..."
					end
				end

				v53.preview = v48
				v53.imageAssetId = sheetImageValue

				v53.creatorName = LocalPlayer.Name
				v53.creatorDisplayName = LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name
				v53.ownerUserId = LocalPlayer.UserId
				return v53
			end

			function state2.profileAssetImage(value)
				local v46 = tostring(value or ""):gsub("%s+", "")

				if v46 == "" then
					return ""
				end

				local v47 = string.lower(v46)
				local v48 = v47:match("^catalog:(%d+)$")
					or v47:match("^thumb:(%d+)$")
					or v47:match("type=asset&id=(%d+)")

				if v48 and tonumber(v48) ~= 0 then
					return "rbxthumb://type=Asset&id=" .. v48 .. "&w=420&h=420"
				end

				local v49 = v46:match("^rbxassetid://(%d+)$") or v46:match("[?&]id=(%d+)") or v46:match("^(%d+)$")

				if v49 and tonumber(v49) ~= 0 then
					return "rbxassetid://" .. v49
				end

				return ""
			end

			function state2.profileStrokeColor(value)
				local match = tostring(value or ""):match("^#?(%x%x%x%x%x%x)$")

				if match then
					return Color3.fromRGB(
						tonumber(match:sub(1, 2), 16),
						tonumber(match:sub(3, 4), 16),
						(tonumber(match:sub(5, 6), 16))
					)
				end

				return Color3.fromRGB(230, 238, 250)
			end

			function state2.clearProfileUploadCards(instance)
				if not instance then
					return
				end

				for _, child in ipairs(instance:GetChildren()) do
					if child.Name == "ProfileUploadCard" then
						child:Destroy()
					end
				end
			end

			function state2.buildProfilePreviewSong(data, p, player)
				local v46 = p == "MIDI" and "MIDI" or "Community"
				local ownerUserId = math.floor(tonumber(data.OwnerUserId or player.UserId) or LocalPlayer.UserId)
				return {
					id = tostring(data.PublicId or data.Id or ""),
					name = tostring(data.Name or data.Title or "Untitled Upload"),
					sheet = tostring(data.Sheet or data.sheet or ""),
					url = tostring(data.Url or data.URL or ""),
					difficulty = tostring(data.Difficulty or "Medium"),
					transpose = math.clamp(math.floor(tonumber(data.Transpose) or 0), -24, 24),
					preview = tostring(data.Description or data.Preview or ""),
					imageAssetId = tostring(data.ImageAssetId or data.ImageId or ""),
					mode = v46,
					source = v46,
					isPublished = data.IsPublished ~= false,
					ownerUnpublished = data.OwnerUnpublished == true or data.OwnerHidden == true,
					sheetId = tostring(data.SheetId or ""),
					creatorName = tostring(data.CreatorName or player.Name or LocalPlayer.Name),
					creatorDisplayName = tostring(data.CreatorDisplayName or data.CreatorName or player.DisplayName or player.Name or LocalPlayer.DisplayName),
					ownerUserId = ownerUserId,
					ownedByLocalPlayer = ownerUserId == LocalPlayer.UserId,
					likes = math.max(0, (math.floor(tonumber(data.FavoriteCount or data.Favorites) or 0))),
					plays = math.max(0, (math.floor(tonumber(data.PlayCount) or 0))),
					reportCount = math.max(0, (math.floor(tonumber(data.ReportCount) or 0))),
					isFavorited = data.IsFavorited == true or data.Kind ~= nil,
					backupLabel = tostring(data.BackupLabel or ""),
					backupAvailable = data.BackupAvailable == true,
					backupStatus = tostring(data.BackupStatus or ""),
					backupSize = tonumber(data.BackupSize) or 0,
					backupState = tostring(data.BackupState or ""),
					urlStatus = tostring(data.UrlStatus or ""),
					publishedAt = math.max(0, (math.floor(tonumber(data.PublishedAt) or 0))),
					updatedAt = math.max(0, (math.floor(tonumber(data.UpdatedAt) or 0)))
				}
			end

			function state2.updateProfileGridLayout()
				local profileSection = content:FindFirstChild("ProfileSection")
				local profileMain = profileSection and profileSection:FindFirstChild("ProfileMain")
				local profileUploads = profileMain and profileMain:FindFirstChild("ProfileUploads")
				local uiGridLayout = profileUploads and profileUploads:FindFirstChildOfClass("UIGridLayout")

				if not (profileUploads and uiGridLayout) then
					return
				end

				local x = profileUploads.AbsoluteSize.X

				if x <= 0 then
					task.defer(state2.updateProfileGridLayout)
					return
				end

				local v46 = x >= 650
				local v47 = v46 and 16 or 0
				local v48 = v46 and math.floor((x - v47 - 4) / 2) or math.max(260, x - 4)
				uiGridLayout.FillDirectionMaxCells = v46 and 2 or 1
				uiGridLayout.CellPadding = UDim2.fromOffset(v47, 16)
				uiGridLayout.CellSize = UDim2.fromOffset(v48, v46 and 272 or 258)
			end

			function state2.setProfileTab(p, p2)
				local profileSection = content:FindFirstChild("ProfileSection")
				local profileMain = profileSection and profileSection:FindFirstChild("ProfileMain")

				if not profileMain then
					return
				end

				local profileData = state2.profileData
				local visible

				if type(profileData) == "table" then
					visible = profileData.CanViewFavorites == true
				else
					visible = false
				end

				local profileTab = p == "Favorites" and not visible and "Sheets"
					or p ~= "Midi" and p ~= "Favorites" and p ~= "About" and "Sheets"
					or p
				state2.profileTab = profileTab
				local sheetsTab = profileMain:FindFirstChild("SheetsTab")
				local midiTab = profileMain:FindFirstChild("MidiTab")
				local favoritesTab = profileMain:FindFirstChild("FavoritesTab")
				local aboutTab = profileMain:FindFirstChild("AboutTab")
				local underline = profileMain:FindFirstChild("Underline")
				local profileUploads = profileMain:FindFirstChild("ProfileUploads")
				local aboutPanel = profileMain:FindFirstChild("AboutPanel")
				local emptyTitle = profileMain:FindFirstChild("EmptyTitle")
				local emptyText = profileMain:FindFirstChild("EmptyText")
				local publicSheets = type(profileData) == "table"
					and type(profileData.PublicSheets) == "table"
					and profileData.PublicSheets
					or {}
				local publicMidi = type(profileData) == "table"
					and type(profileData.PublicMidi) == "table"
					and profileData.PublicMidi
					or {}
				local favorites = visible and type(profileData.Favorites) == "table" and profileData.Favorites or {}
				local v48 = profileTab == "Midi" and #publicMidi
					or profileTab == "Favorites" and #favorites
					or #publicSheets
				local v49 = profileTab ~= "About"

				if sheetsTab and sheetsTab:IsA("TextButton") then
					sheetsTab.TextColor3 = profileTab == "Sheets" and Color3.fromRGB(246, 248, 252)
						or Color3.fromRGB(137, 144, 160)
				end

				if midiTab and midiTab:IsA("TextButton") then
					midiTab.TextColor3 = profileTab == "Midi" and Color3.fromRGB(246, 248, 252)
						or Color3.fromRGB(137, 144, 160)
				end

				if favoritesTab and favoritesTab:IsA("TextButton") then
					favoritesTab.Visible = visible
					favoritesTab.TextColor3 = profileTab == "Favorites" and Color3.fromRGB(246, 248, 252)
						or Color3.fromRGB(137, 144, 160)
				end

				if aboutTab and aboutTab:IsA("TextButton") then
					aboutTab.TextColor3 = profileTab == "About" and Color3.fromRGB(246, 248, 252)
						or Color3.fromRGB(137, 144, 160)
				end

				if profileUploads and profileUploads:IsA("GuiObject") then
					profileUploads.Visible = v49 and v48 > 0

					for _, guiObject in ipairs(profileUploads:GetChildren()) do
						if guiObject.Name == "ProfileUploadCard" and guiObject:IsA("GuiObject") then
							guiObject.Visible = guiObject:GetAttribute("ProfileUploadMode") == profileTab
						end
					end
				end

				if aboutPanel and aboutPanel:IsA("GuiObject") then
					aboutPanel.Visible = profileTab == "About"
				end

				if emptyTitle and emptyTitle:IsA("TextLabel") then
					emptyTitle.Visible = v49 and v48 == 0
					emptyTitle.Text = profileTab == "Midi" and "NO PUBLISHED MIDI"
						or profileTab == "Favorites" and "NO FAVORITES YET"
						or "NO PUBLISHED SHEETS"
				end

				if emptyText and emptyText:IsA("TextLabel") then
					emptyText.Visible = v49 and v48 == 0
					emptyText.Text = profileTab == "Midi" and "Publish a community MIDI to show it here."
						or profileTab == "Favorites"
						and "Use the heart button on a community Sheet or MIDI to save it here."
						or "Publish a community sheet to show it here."
				end

				local guiObject = profileTab == "About" and aboutTab
					or profileTab == "Favorites" and favoritesTab
					or profileTab == "Midi" and midiTab
					or sheetsTab

				if underline and guiObject and guiObject:IsA("GuiObject") then
					local udim = UDim2.fromOffset(guiObject.Position.X.Offset, 43)
					local udim2 = UDim2.fromOffset(math.max(42, guiObject.Size.X.Offset - 8), 2)

					if state2.profileTabTween then
						state2.profileTabTween:Cancel()
						state2.profileTabTween = nil
					end

					if p2 then
						local TweenService = game:GetService("TweenService")
						local tween = TweenService:Create(
							underline,
							TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
							{ Position = udim, Size = udim2 }
						)

						state2.profileTabTween = tween
						tween.Completed:Once(function()
							if state2.profileTabTween == tween then
								state2.profileTabTween = nil
							end
						end)
						tween:Play()
					else
						underline.Position = udim
						underline.Size = udim2
					end
				end

				task.defer(state2.updateProfileGridLayout)
			end

			function state2.openProfileFavorite(data)
				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("Loading favorite...")
				emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

				task.spawn(function()
					local v46 = tostring(data.Kind or "") == "Midi" and "Midi" or "Sheets"
					local success, result, v47, v48 = pcall(function()
						return resolveCommunityFavorite:InvokeServer(tostring(data.PublicId or data.Id or ""), v46)
					end)

					if success and result and type(v48) == "table" then
						local v49 = v46 == "Midi" and normalizeCommunityMidi(v48) or normalizeCommunitySong(v48)
						v49.isFavorited = true
						state2.openPreviewOverlay(v49)

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)
					elseif success then
						setInlineMessage(v47 or "That favorite is no longer available.", true) -- inferred equivalent call
						state2.refreshProfile()
					else
						v2.Warn("[CommunitySheetsGui] ResolveCommunityFavorite failed:", result)

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Could not load that favorite.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					end
				end)
			end

			function state2.republishProfileMidiUpload(p)
				if state2.profileRepublishPending then
					return
				end

				local publicId = tostring(p.PublicId or p.Id or "")

				if publicId == "" then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("That MIDI upload was not found.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				else
					state2.profileRepublishPending = true
					local optimisticRepublishProfileMidiUpload = state2.optimisticRepublishProfileMidiUpload(publicId)

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Republishing MIDI...")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					task.spawn(function()
						local success, result, v46, v47 = pcall(function()
							return republishCommunityMidi:InvokeServer(publicId)
						end)

						state2.profileRepublishPending = false

						if success and result then
							if type(v47) == "table" and fn6 then
								fn6(v47)
								redrawOptimisticMidiCatalog() -- inferred equivalent call
							end

							setInlineMessage(v46 or "MIDI republished.", false) -- inferred equivalent call
						elseif success then
							state2.rollbackOptimisticMidiUpload(publicId, optimisticRepublishProfileMidiUpload)
							setInlineMessage(v46 or "Could not republish this MIDI.", true) -- inferred equivalent call
						else
							state2.rollbackOptimisticMidiUpload(publicId, optimisticRepublishProfileMidiUpload)
							v2.Warn("[CommunitySheetsGui] RepublishCommunityMidi failed:", result)

							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("Could not reach MIDI publish service.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						end
					end)
				end
			end

			function state2.createProfileUploadCard(parent2, data, p, p2, layoutOrder, p3)
				local profileUploadCard = Instance.new("TextButton")
				profileUploadCard.Name = "ProfileUploadCard"
				profileUploadCard.LayoutOrder = layoutOrder
				profileUploadCard.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
				profileUploadCard.BorderSizePixel = 0
				profileUploadCard.AutoButtonColor = false
				profileUploadCard.ClipsDescendants = true
				profileUploadCard.Text = ""
				profileUploadCard.ZIndex = parent2.ZIndex + 1
				profileUploadCard:SetAttribute("ProfileUploadMode", p3 or p == "MIDI" and "Midi" or "Sheets")
				profileUploadCard.Parent = parent2
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 14)
				uiCorner.Parent = profileUploadCard
				local uiStroke = Instance.new("UIStroke")
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke.Color = Color3.fromRGB(57, 63, 78)
				uiStroke.Transparency = 0.48
				uiStroke.Thickness = 1
				uiStroke.Parent = profileUploadCard

				local hero = Instance.new("ImageLabel")
				hero.Name = "Hero"
				hero.Size = UDim2.new(1, 0, 0, 112)
				hero.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
				hero.BorderSizePixel = 0
				local profileAssetImage = state2.profileAssetImage(data.ImageAssetId or data.ImageId)
				hero.Image = (profileAssetImage == "" or not profileAssetImage) and "rbxassetid://129219137975212"
					or profileAssetImage
				hero.ImageColor3 = p == "MIDI" and Color3.fromRGB(210, 201, 255) or Color3.fromRGB(255, 255, 255)
				hero.ScaleType = Enum.ScaleType.Crop
				hero.ClipsDescendants = true
				hero.ZIndex = profileUploadCard.ZIndex + 1
				hero.Parent = profileUploadCard
				local uiCorner2 = Instance.new("UICorner")
				uiCorner2.CornerRadius = UDim.new(0, 14)
				uiCorner2.Parent = hero
				local shade = Instance.new("Frame")
				shade.Name = "Shade"
				shade.Size = UDim2.fromScale(1, 1)
				shade.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
				shade.BorderSizePixel = 0
				shade.ZIndex = hero.ZIndex + 1
				shade.Parent = hero
				local uiGradient = Instance.new("UIGradient")
				uiGradient.Rotation = 90
				uiGradient.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.72),
					NumberSequenceKeypoint.new(0.62, 0.45),
					NumberSequenceKeypoint.new(1, 0)
				})

				uiGradient.Parent = shade

				local difficultyBadge = Instance.new("TextLabel")
				difficultyBadge.Name = "DifficultyBadge"
				difficultyBadge.AnchorPoint = Vector2.new(1, 0)
				difficultyBadge.Position = UDim2.new(1, -12, 0, 12)
				difficultyBadge.Size = UDim2.fromOffset(104, 26)
				difficultyBadge.Font = Enum.Font.GothamBold
				difficultyBadge.ZIndex = shade.ZIndex + 1
				difficultyBadge.Parent = profileUploadCard
				state2.applyDifficultyBadgeStyle(difficultyBadge, data.Difficulty)
				configureTextObject(difficultyBadge, 10, 7)

				local v46 = math.floor(tonumber(p2.UserId) or 0) == LocalPlayer.UserId
				local v47

				if p == "MIDI" then
					v47 = v46
						and (data.IsPublished == false or data.OwnerUnpublished == true or data.OwnerHidden == true)
				else
					v47 = false
				end

				if p == "MIDI" then
					local modeBadge = Instance.new("TextLabel")
					modeBadge.Name = "ModeBadge"
					modeBadge.Position = UDim2.fromOffset(12, 12)
					modeBadge.Size = UDim2.fromOffset(64, 26)
					modeBadge.BackgroundColor3 = Color3.fromRGB(48, 39, 79)
					modeBadge.BorderSizePixel = 0
					modeBadge.Font = Enum.Font.GothamBold
					modeBadge.TextColor3 = Color3.fromRGB(196, 182, 255)
					modeBadge.Text = "MIDI"
					modeBadge.ZIndex = shade.ZIndex + 1
					modeBadge.Parent = profileUploadCard
					local uiCorner3 = Instance.new("UICorner")
					uiCorner3.CornerRadius = UDim.new(0, 7)
					uiCorner3.Parent = modeBadge
					configureTextObject(modeBadge, 10, 7)

					local midiUnavailableNoBackup = state2.isMidiUnavailableNoBackup({
						mode = "MIDI",
						UrlStatus = data.UrlStatus,
						BackupAvailable = data.BackupAvailable,
						BackupStored = data.BackupStored,
						BackupData = data.BackupData
					})

					local v48 = v46 and state2.isMidiOriginalLinkOnly({
						mode = "MIDI",
						BackupStatus = data.BackupStatus,
						BackupAvailable = data.BackupAvailable,
						BackupStored = data.BackupStored,
						BackupData = data.BackupData
					})

					if v47 or midiUnavailableNoBackup or v48 then
						local statusBadge = Instance.new("TextLabel")
						statusBadge.Name = "StatusBadge"
						statusBadge.Position = UDim2.fromOffset(84, 12)
						local text = "LINK ONLY"
						local v50 = 86
						local color = Color3.fromRGB(82, 61, 24)
						local color2 = Color3.fromRGB(255, 220, 92)

						if v47 then
							color = Color3.fromRGB(52, 56, 70)
							color2 = Color3.fromRGB(210, 218, 236)
							v50 = 112
							text = "UNPUBLISHED"
						elseif midiUnavailableNoBackup then
							color = Color3.fromRGB(88, 31, 45)
							color2 = Color3.fromRGB(255, 150, 170)
							v50 = 112
							text = "NEEDS REPAIR"
						end

						statusBadge.Size = UDim2.fromOffset(v50, 26)
						statusBadge.BackgroundColor3 = color
						statusBadge.BorderSizePixel = 0
						statusBadge.Font = Enum.Font.GothamBold
						statusBadge.TextColor3 = color2
						statusBadge.Text = text
						statusBadge.ZIndex = shade.ZIndex + 1
						statusBadge.Parent = profileUploadCard
						local uiCorner4 = Instance.new("UICorner")
						uiCorner4.CornerRadius = UDim.new(0, 7)
						uiCorner4.Parent = statusBadge
						configureTextObject(statusBadge, 10, 7)
					end
				end

				local title = Instance.new("TextLabel")
				title.Name = "Title"
				title.Position = UDim2.fromOffset(16, 120)
				title.Size = UDim2.new(1, -32, 0, 28)
				title.BackgroundTransparency = 1
				title.Font = Enum.Font.GothamBold
				title.TextColor3 = Color3.fromRGB(244, 246, 251)
				title.TextXAlignment = Enum.TextXAlignment.Left
				title.Text = tostring(data.Name or data.Title or "Untitled Upload")
				title.ZIndex = profileUploadCard.ZIndex + 1
				title.Parent = profileUploadCard
				configureTextObject(title, 17, 10)

				local creator = Instance.new("TextLabel")
				creator.Name = "Creator"
				creator.Position = UDim2.fromOffset(16, 150)
				creator.Size = UDim2.new(1, -32, 0, 20)
				creator.BackgroundTransparency = 1
				creator.Font = Enum.Font.GothamMedium
				creator.TextColor3 = Color3.fromRGB(30, 174, 255)
				creator.TextXAlignment = Enum.TextXAlignment.Left
				creator.Text = "by @" .. tostring(data.CreatorName or p2.Name or LocalPlayer.Name)
				creator.ZIndex = profileUploadCard.ZIndex + 1
				creator.Parent = profileUploadCard
				configureTextObject(creator, 11, 8)

				local description = Instance.new("TextLabel")
				description.Name = "Description"
				description.Position = UDim2.fromOffset(16, 177)
				description.Size = UDim2.new(1, -32, 0, 40)
				description.BackgroundTransparency = 1
				description.Font = Enum.Font.GothamMedium
				description.TextColor3 = Color3.fromRGB(145, 151, 166)
				description.TextXAlignment = Enum.TextXAlignment.Left
				description.TextYAlignment = Enum.TextYAlignment.Top
				description.TextWrapped = true
				local text = tostring(data.Description or data.Preview or "")

				if text == "" or not text then
					if p == "MIDI" then
						text = "Community MIDI upload"
					else
						text = tostring(data.Sheet or data.sheet or ""):gsub("%s+", " ")

						if text == "" then
							text = "No preview available yet."
						elseif #text > 92 then
							text = text:sub(1, 89) .. "..."
						end
					end
				end

				description.Text = text
				description.ZIndex = profileUploadCard.ZIndex + 1
				description.Parent = profileUploadCard
				configureTextObject(description, 11, 8)

				local stats = Instance.new("TextLabel")
				stats.Name = "Stats"
				stats.AnchorPoint = Vector2.new(0, 1)
				stats.Position = UDim2.new(0, 16, 1, -14)
				stats.Size = v47 and UDim2.new(1, -150, 0, 24) or UDim2.new(1, -32, 0, 24)
				stats.BackgroundTransparency = 1
				stats.Font = Enum.Font.GothamSemibold
				stats.TextColor3 = Color3.fromRGB(167, 173, 188)
				stats.TextXAlignment = Enum.TextXAlignment.Left
				stats.Text = v47
					and string.format(
						"Hidden from Community  •  %s likes  •  %s plays",
						comma(data.FavoriteCount or data.Favorites or 0),
						comma(data.PlayCount or 0)
					)
					or string.format(
						"%s  •  %s likes  •  %s plays",
						formatUploadDate(data.PublishedAt),
						comma(data.FavoriteCount or data.Favorites or 0),
						comma(data.PlayCount or 0)
					)
				stats.ZIndex = profileUploadCard.ZIndex + 1
				stats.Parent = profileUploadCard
				configureTextObject(stats, 11, 8)

				if v47 then
					local republishButton = Instance.new("TextButton")
					republishButton.Name = "RepublishButton"
					republishButton.AnchorPoint = Vector2.new(1, 1)
					republishButton.Position = UDim2.new(1, -16, 1, -12)
					republishButton.Size = UDim2.fromOffset(116, 30)
					republishButton.BackgroundColor3 = Color3.fromRGB(30, 160, 255)
					republishButton.BorderSizePixel = 0
					republishButton.AutoButtonColor = true
					republishButton.Font = Enum.Font.GothamBold
					republishButton.TextColor3 = Color3.fromRGB(255, 255, 255)
					republishButton.Text = "Republish"
					republishButton.ZIndex = profileUploadCard.ZIndex + 3
					republishButton.Parent = profileUploadCard
					local uiCorner3 = Instance.new("UICorner")
					uiCorner3.CornerRadius = UDim.new(0, 9)
					uiCorner3.Parent = republishButton
					configureTextObject(republishButton, 11, 8)
					republishButton.Activated:Connect(function()
						state2.republishProfileMidiUpload(data)
					end)
				end

				profileUploadCard.Activated:Connect(function()
					if v47 then
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("Republish this MIDI before previewing it.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					elseif p3 == "Favorites" then
						state2.openProfileFavorite(data)
					else
						state2.openPreviewOverlay(state2.buildProfilePreviewSong(data, p, p2))
					end
				end)
			end

			function state2.renderProfileData(profileData)
				local profileSection = content:FindFirstChild("ProfileSection")

				if not profileSection or type(profileData) ~= "table" then
					return
				end

				state2.profileData = profileData
				local appearance = type(profileData.Appearance) == "table" and profileData.Appearance or {}
				local banner = profileSection:FindFirstChild("Banner")
				local bannerImage = banner and banner:FindFirstChild("BannerImage")
				local profileCard = profileSection:FindFirstChild("ProfileCard")
				local avatar = profileCard and profileCard:FindFirstChild("Avatar")
				local avatarImage = avatar and avatar:FindFirstChild("AvatarImage")
				local uiStroke = avatar and avatar:FindFirstChildOfClass("UIStroke")
				local profileAssetImage = state2.profileAssetImage(appearance.BannerAssetId)

				if bannerImage and bannerImage:IsA("ImageLabel") then
					bannerImage.Image = profileAssetImage
					bannerImage.Visible = profileAssetImage ~= ""
				end

				if uiStroke then
					uiStroke.Color = state2.profileStrokeColor(appearance.AvatarStrokeColor)
				end

				if avatarImage and avatarImage:IsA("ImageLabel") then
					local image = state2.profileAssetImage(appearance.AvatarAssetId)

					if image == "" then
						local success, result = pcall(function()
							return Players:GetUserThumbnailAsync(
								profileData.UserId,
								Enum.ThumbnailType.HeadShot,
								Enum.ThumbnailSize.Size420x420
							)
						end)
						image = success and result or ""
					end

					avatarImage.Image = image
				end

				if profileCard then
					local username = profileCard:FindFirstChild("Username")
					local handle = profileCard:FindFirstChild("Handle")
					local creatorBadge = profileCard:FindFirstChild("CreatorBadge")
					local joined = profileCard:FindFirstChild("Joined")
					local followButton = profileCard:FindFirstChild("FollowButton")
					local repButton = profileCard:FindFirstChild("RepButton")
					local followers = profileCard:FindFirstChild("Followers")
					local rep = profileCard:FindFirstChild("Rep")

					if username and username:IsA("TextLabel") then
						username.Text = tostring(profileData.DisplayName or profileData.Name or "Player")
					end

					if handle and handle:IsA("TextLabel") then
						handle.Text = "@" .. tostring(profileData.Name or "Player")
					end

					if joined and joined:IsA("TextLabel") then
						if profileData.IsSelf == true then
							local v46 = os.time() - math.max(0, tonumber(LocalPlayer.AccountAge) or 0) * 86400
							joined.Text = "Joined " .. os.date("!%Y", v46)
						else
							joined.Text = "Community creator"
						end
					end

					if creatorBadge and creatorBadge:IsA("TextLabel") then
						local v46 = ""

						for _, v48 in pairs(type(profileData.Tags) == "table" and profileData.Tags or {}) do
							if type(v48) == "table" then
								v46 = tostring(v48.Name or v48.Tag or v48.Id or "")
							elseif type(v48) == "string" then
								v46 = v48
							end

							if v46 ~= "" then
								break
							end
						end

						creatorBadge.Text = v46 == "" and "PLAYER PROFILE" or v46:upper() or "PLAYER PROFILE"
					end

					if followButton and followButton:IsA("TextButton") then
						local userId = math.floor(tonumber(profileData.UserId) or 0)
						local v46

						if userId > 0 then
							v46 = userId ~= LocalPlayer.UserId
						else
							v46 = false
						end

						followButton.Text = "SUPPORT CREATOR"
						followButton.Visible = v46
						followButton.Active = v46
						followButton.TextWrapped = true
						followButton.TextScaled = true
						configureTextObject(followButton, 12, 8)
					end

					if repButton and repButton:IsA("GuiObject") then
						local canThumbProfile = profileData.CanThumbProfile == true
						repButton.Visible = canThumbProfile
						repButton.Active = canThumbProfile
						local thumbIcon = repButton:FindFirstChild("ThumbIcon")

						if thumbIcon and thumbIcon:IsA("ImageLabel") then
							thumbIcon.ImageColor3 = Color3.fromRGB(52, 211, 153)
						end
					end

					if followers and followers:IsA("TextLabel") then
						followers.Text = string.format(
							"%s\nTHUMBS UP",
							comma(profileData.ThumbsUpCount or profileData.ProfileThumbsUp or 0)
						)
					end

					if rep and rep:IsA("TextLabel") then
						local reputation = type(profileData.Reputation) == "table" and profileData.Reputation or {}
						rep.Text = string.format("%s\nREPUTATION", comma(reputation.Score or 0))
					end
				end

				local profileMain = profileSection:FindFirstChild("ProfileMain")

				if not profileMain then
					return
				end

				local publicSheets = type(profileData.PublicSheets) == "table" and profileData.PublicSheets or {}
				local publicMidi = type(profileData.PublicMidi) == "table" and profileData.PublicMidi or {}
				local favorites = profileData.CanViewFavorites == true
					and type(profileData.Favorites) == "table"
					and profileData.Favorites
					or {}
				local profileUploads = profileMain:FindFirstChild("ProfileUploads")
				local sheetsTab = profileMain:FindFirstChild("SheetsTab")
				local midiTab = profileMain:FindFirstChild("MidiTab")
				local favoritesTab = profileMain:FindFirstChild("FavoritesTab")
				local aboutTab = profileMain:FindFirstChild("AboutTab")
				local aboutPanel = profileMain:FindFirstChild("AboutPanel")
				local bioText = aboutPanel and aboutPanel:FindFirstChild("BioText")
				local emptyTitle = profileMain:FindFirstChild("EmptyTitle")
				local emptyText = profileMain:FindFirstChild("EmptyText")

				if sheetsTab and sheetsTab:IsA("TextButton") then
					sheetsTab.Text = string.format("SHEETS  %d", #publicSheets)
				end

				if midiTab and midiTab:IsA("TextButton") then
					midiTab.Text = string.format("MIDI  %d", #publicMidi)
				end

				if favoritesTab and favoritesTab:IsA("TextButton") then
					favoritesTab.Text = string.format("FAVORITES  %d", #favorites)
					favoritesTab.Visible = profileData.CanViewFavorites == true
				end

				if aboutTab and aboutTab:IsA("GuiObject") then
					aboutTab.Position = UDim2.fromOffset(profileData.CanViewFavorites == true and 348 or 224, 0)
				end

				if bioText and bioText:IsA("TextLabel") then
					local bio = tostring(profileData.Bio or "")
					bioText.Text = (bio == "" or not bio) and "No biography has been added yet." or bio
				end

				state2.clearProfileUploadCards(profileUploads)

				if profileUploads and profileUploads:IsA("ScrollingFrame") then
					local count = 0

					for _, publicSheet in ipairs(publicSheets) do
						count += 1
						state2.createProfileUploadCard(profileUploads, publicSheet, "SHEET", profileData, count)
					end

					for _, v46 in ipairs(publicMidi) do
						count += 1
						state2.createProfileUploadCard(profileUploads, v46, "MIDI", profileData, count)
					end

					for _, favorite in ipairs(favorites) do
						count += 1
						local v46 = tostring(favorite.Kind or "") == "Midi" and "MIDI" or "SHEET"
						state2.createProfileUploadCard(profileUploads, favorite, v46, profileData, count, "Favorites")
					end
				end

				if emptyTitle and emptyTitle:IsA("TextLabel") then
					emptyTitle.Text = "NO PUBLISHED UPLOADS"
				end

				if emptyText and emptyText:IsA("TextLabel") then
					emptyText.Text = "Publish a community sheet or MIDI to show it here."
					emptyText.TextColor3 = Color3.fromRGB(150, 158, 176)
				end

				state2.updateProfileGridLayout()
				state2.setProfileTab(state2.profileTab or "Sheets", false)

				if state2.mobileLandscapeActive and state2.renderMobileCards then
					state2.renderMobileCards()
				end
			end

			function state2.setProfileLoadState(value, p)
				local profileSection = content:FindFirstChild("ProfileSection")
				local profileMain = profileSection and profileSection:FindFirstChild("ProfileMain")
				local profileUploads = profileMain and profileMain:FindFirstChild("ProfileUploads")
				local emptyTitle = profileMain and profileMain:FindFirstChild("EmptyTitle")
				local emptyText = profileMain and profileMain:FindFirstChild("EmptyText")

				if profileUploads and profileUploads:IsA("GuiObject") then
					profileUploads.Visible = false
				end

				if emptyTitle and emptyTitle:IsA("TextLabel") then
					emptyTitle.Visible = true
					emptyTitle.Text = p and "PROFILE UNAVAILABLE" or "LOADING PROFILE"
				end

				if emptyText and emptyText:IsA("TextLabel") then
					emptyText.Visible = true
					emptyText.Text = tostring(value or "")
					emptyText.TextColor3 = p and Color3.fromRGB(255, 126, 153) or Color3.fromRGB(150, 158, 176)
				end
			end

			function state2.ensureSupportCreatorOverlay()
				return CommunitySheetsOverlayFactory.EnsureSupportCreatorOverlay(parent)
			end

			function state2.closeSupportCreatorOverlay()
				local supportCreatorOverlay = parent:FindFirstChild("SupportCreatorOverlay")

				if supportCreatorOverlay and supportCreatorOverlay:IsA("GuiObject") then
					supportCreatorOverlay.Visible = false
				end

				state2.supportCreatorPending = false
			end

			function state2.openSupportCreatorOverlay(p)
				local v46 = type(p) == "table" and p or state2.profileData
				local userId = math.max(0, (math.floor(tonumber(v46 and v46.UserId) or 0)))

				if userId <= 0 then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Open a creator profile first.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				elseif userId == LocalPlayer.UserId then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("You cannot support yourself.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				else
					local supportCreatorOverlay = state2.ensureSupportCreatorOverlay()
					local panel2 = supportCreatorOverlay:FindFirstChild("Panel")
					state2.applyModalScale(panel2, 430, 370)
					local name = tostring(v46.Name or state2.profileTargetName or "Player")
					local displayName = tostring(v46.DisplayName or state2.profileTargetDisplayName or name)
					state2.supportCreatorTarget = {
						UserId = userId,
						Name = name,
						DisplayName = displayName
					}

					local targetLabel = panel2 and panel2:FindFirstChild("TargetLabel")

					if targetLabel and targetLabel:IsA("TextLabel") then
						targetLabel.Text = string.format("Supporting %s (@%s)", displayName, name)
					end

					local amountBox = panel2 and panel2:FindFirstChild("AmountBox")

					if amountBox and amountBox:IsA("TextBox") then
						amountBox.Text = ""
					end

					local status = panel2 and panel2:FindFirstChild("Status")

					if status and status:IsA("TextLabel") then
						status.Text = "Minimum amount is 10 Robux. Roblox will confirm the transfer on the next screen."
						status.TextColor3 = Color3.fromRGB(160, 168, 184)
					end

					local submitButton = panel2 and panel2:FindFirstChild("SubmitButton")

					if submitButton and submitButton:IsA("TextButton") then
						submitButton.Text = "Send Robux"
						submitButton.Active = true
					end

					supportCreatorOverlay.Visible = true

					if amountBox and amountBox:IsA("TextBox") then
						task.defer(function()
							if supportCreatorOverlay.Visible then
								amountBox:CaptureFocus()
							end
						end)
					end
				end
			end

			function state2.submitSupportCreator()
				if state2.supportCreatorPending then
					return
				end

				local supportCreatorOverlay = parent:FindFirstChild("SupportCreatorOverlay")
				local panel2 = supportCreatorOverlay and supportCreatorOverlay:FindFirstChild("Panel")
				local amountBox = panel2 and panel2:FindFirstChild("AmountBox")
				local status = panel2 and panel2:FindFirstChild("Status")
				local submitButton = panel2 and panel2:FindFirstChild("SubmitButton")
				local supportCreatorTarget = state2.supportCreatorTarget

				if
					type(supportCreatorTarget) == "table"
					and not (math.floor(tonumber(supportCreatorTarget.UserId) or 0) <= 0)
				then
					local v46 = math.floor(tonumber(((amountBox and tostring(amountBox.Text or "") or ""):gsub(
						"[^%d]",
						""
					))) or 0)

					if v46 < 10 then
						if status and status:IsA("TextLabel") then
							status.Text = "Amount must be atleast 10 Robux."
							status.TextColor3 = Color3.fromRGB(255, 126, 153)
						end

						if amountBox and amountBox:IsA("TextBox") then
							amountBox:CaptureFocus()
						end
					else
						state2.supportCreatorPending = true

						if submitButton and submitButton:IsA("TextButton") then
							submitButton.Active = false
							submitButton.Text = "Opening..."
						end

						if status and status:IsA("TextLabel") then
							status.Text = "Opening Roblox transfer prompt..."
							status.TextColor3 = Color3.fromRGB(160, 168, 184)
						end

						local success, result, v47 = pcall(function()
							return remotes:WaitForChild("BeginDonationTransfer"):InvokeServer(
								supportCreatorTarget.UserId,
								v46
							)
						end)

						state2.supportCreatorPending = false

						if submitButton and submitButton:IsA("TextButton") then
							submitButton.Active = true
							submitButton.Text = "Send Robux"
						end

						local v48 = success and result == true
						local v49 = nil

						if success then
							if v48 then
								if type(v47) == "table" and type(v47.Message) == "string" then
									v49 = v47.Message
								end
							else
								v49 = type(v47) == "string" and v47
									or type(result) == "string" and result
									or "Roblox couldn't open the transfer prompt. Try again."
							end
						else
							v49 = "Roblox couldn't open the transfer prompt. Try again."
						end

						if status and status:IsA("TextLabel") then
							status.Text = v49 or "Roblox will confirm the transfer on the next screen."
							status.TextColor3 = v48 and Color3.fromRGB(102, 255, 191) or Color3.fromRGB(255, 126, 153)
						end
					end
				else
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Choose a creator first.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				end
			end

			function state2.openCommunityProfile(p, p2, p3)
				local v46 = math.max(0, (math.floor(tonumber(p) or 0)))

				if v46 <= 0 then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Creator profile is unavailable.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				else
					state2.setProfileTarget(v46, p2, p3)
					state2.profileTab = "Sheets"
					state2.keepProfileTarget = true
					state2.closePreviewOverlay()

					if fn7 then
						fn7("Profile")
					else
						selectedMode = "Profile"
						fn2(false)
					end

					state2.refreshProfile(v46)
				end
			end

			function state2.toggleProfileThumb()
				local profileData = type(state2.profileData) == "table" and state2.profileData or nil
				local v46 = profileData and math.max(0, (math.floor(tonumber(profileData.UserId) or 0))) or 0

				if v46 <= 0 or v46 == LocalPlayer.UserId or profileData.CanThumbProfile ~= true then
					if profileData and profileData.IsViewOnlyProfile == true then
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("This creator profile is view-only while the creator is in another server.")
						emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
					end
				else
					local success, result = pcall(function()
						return remotes:WaitForChild("ToggleProfileThumbsUp"):InvokeServer(v46)
					end)

					if
						success
						and type(result) == "table"
						and result.Ok == true
						and type(result.Profile) == "table"
					then
						state2.renderProfileData(result.Profile)
						return
					end

					setInlineMessage( -- inferred equivalent call
						success and type(result) == "table" and result.Error or "Could not update creator thumbs up.",
						true
					)
				end
			end

			function state2.refreshProfile(p)
				local v46 = math.max(
					0,
					(math.floor(tonumber(p or state2.profileTargetUserId or LocalPlayer.UserId) or 0))
				)

				if v46 <= 0 then
					v46 = LocalPlayer.UserId
				end

				if state2.profileLoading then
					return
				end

				state2.profileLoading = true
				local v47 = v46 == LocalPlayer.UserId
				state2.setProfileLoadState(v47 and "Loading your profile..." or "Loading creator profile...", false)

				task.spawn(function()
					local success, result = pcall(function()
						return remotes:WaitForChild("GetPlayerProfile"):InvokeServer(v46)
					end)

					state2.profileLoading = false

					if state2.profileTargetUserId ~= v46 then
						return
					end

					if
						success
						and type(result) == "table"
						and result.Ok == true
						and type(result.Profile) == "table"
					then
						state2.setProfileTarget(result.Profile.UserId, result.Profile.DisplayName, result.Profile.Name)
						state2.renderProfileData(result.Profile)
					else
						local err = type(result) == "table" and result.Error
							or v47 and "Could not load your profile."
							or "Could not load creator profile."
						state2.setProfileLoadState(err, true)
					end
				end)
			end

			function state2.setProfileVisible(visible)
				local profileSection = content:FindFirstChild("ProfileSection")

				if profileSection then
					profileSection.Visible = visible
					profileSection.Position = UDim2.fromOffset(0, 0)
					profileSection.Size = UDim2.fromScale(1, 1)
					local v46 = content.AbsoluteSize.X < 900
					local banner = profileSection:FindFirstChild("Banner")
					local profileCard = profileSection:FindFirstChild("ProfileCard")
					local profileMain = profileSection:FindFirstChild("ProfileMain")

					if banner and banner:IsA("GuiObject") then
						banner.Position = UDim2.fromOffset(0, 0)
						banner.Size = UDim2.new(1, 0, 0, v46 and 176 or 264)
					end

					if profileCard then
						profileCard.ClipsDescendants = false
						profileCard.AnchorPoint = v46 and Vector2.new(0.5, 0) or Vector2.new(0, 0)
						profileCard.Position = v46 and UDim2.new(0.5, 0, 0, 112) or UDim2.fromOffset(28, 132)
						profileCard.Size = v46
							and UDim2.fromOffset(math.min(330, (math.max(280, content.AbsoluteSize.X - 32))), 392)
							or UDim2.fromOffset(330, 442)
						local avatar = profileCard:FindFirstChild("Avatar")

						if avatar and avatar:IsA("GuiObject") then
							avatar.AnchorPoint = Vector2.new(0.5, 0)
							avatar.Position = UDim2.new(0.5, 0, 0, v46 and -54 or -72)
							avatar.Size = UDim2.fromOffset(v46 and 116 or 144, v46 and 116 or 144)
							avatar.ZIndex = profileCard.ZIndex + 2
						end

						local username = profileCard:FindFirstChild("Username")
						local handle = profileCard:FindFirstChild("Handle")
						local joined = profileCard:FindFirstChild("Joined")
						local creatorBadge = profileCard:FindFirstChild("CreatorBadge")
						local followButton = profileCard:FindFirstChild("FollowButton")
						local repButton = profileCard:FindFirstChild("RepButton")
						local statLine = profileCard:FindFirstChild("StatLine")
						local followers = profileCard:FindFirstChild("Followers")
						local rep = profileCard:FindFirstChild("Rep")
						local profileData

						if type(state2.profileData) == "table" then
							profileData = state2.profileData or nil
						end

						local name = tostring(profileData and profileData.Name or state2.profileTargetName or LocalPlayer.Name)
						local text = tostring(profileData and profileData.DisplayName or state2.profileTargetDisplayName or LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name)

						if username and username:IsA("TextLabel") then
							username.Position = UDim2.fromOffset(24, v46 and 76 or 94)
							username.Size = UDim2.new(1, -48, 0, 34)

							if text == "" or not text then
								text = name
							end

							username.Text = text
							configureTextObject(username, v46 and 22 or 25, 12)
						end

						if handle and handle:IsA("TextLabel") then
							handle.Position = UDim2.fromOffset(24, v46 and 111 or 130)
							handle.Size = UDim2.new(1, -48, 0, 20)
							handle.Text = "@" .. name
							configureTextObject(handle, 12, 8)
						end

						if joined and joined:IsA("TextLabel") then
							joined.Position = UDim2.fromOffset(24, v46 and 136 or 156)
							joined.Size = UDim2.new(1, -48, 0, 20)
							configureTextObject(joined, 12, 8)
						end

						if creatorBadge and creatorBadge:IsA("GuiObject") then
							creatorBadge.Position = UDim2.fromOffset(66, v46 and 169 or 193)
							creatorBadge.Size = UDim2.new(1, -132, 0, 27)
						end

						if followButton and followButton:IsA("GuiObject") then
							local userId = type(state2.profileData) == "table"
								and math.floor(tonumber(state2.profileData.UserId) or 0)
								or 0
							followButton.Visible = userId > 0 and userId ~= LocalPlayer.UserId
							followButton.Position = UDim2.fromOffset(24, v46 and 216 or 243)
							followButton.Size = UDim2.new(1, -100, 0, 44)
						end

						if repButton and repButton:IsA("GuiObject") then
							local v48

							if type(state2.profileData) == "table" then
								v48 = state2.profileData.CanThumbProfile == true
							else
								v48 = false
							end

							repButton.Visible = v48
							repButton.Active = v48
							repButton.Position = UDim2.new(1, -64, 0, v46 and 216 or 243)
							repButton.Size = UDim2.fromOffset(40, 44)
						end

						if statLine and statLine:IsA("GuiObject") then
							statLine.Position = UDim2.fromOffset(24, v46 and 282 or 310)
							statLine.Size = UDim2.new(1, -48, 0, 1)
						end

						if followers and followers:IsA("TextLabel") then
							followers.Position = UDim2.fromOffset(24, v46 and 300 or 330)
							followers.Size = UDim2.new(0.5, -28, 0, 62)
							configureTextObject(followers, v46 and 18 or 21, 9)
						end

						if rep and rep:IsA("TextLabel") then
							rep.Position = UDim2.new(0.5, 4, 0, v46 and 300 or 330)
							rep.Size = UDim2.new(0.5, -28, 0, 62)
							configureTextObject(rep, v46 and 18 or 21, 9)
						end
					end

					if profileMain then
						profileMain.Position = v46 and UDim2.fromOffset(0, 526) or UDim2.fromOffset(390, 212)
						profileMain.Size = v46 and UDim2.new(1, 0, 1, -532) or UDim2.new(1, -414, 1, -224)
						local sheetsTab = profileMain:FindFirstChild("SheetsTab")
						local midiTab = profileMain:FindFirstChild("MidiTab")
						local favoritesTab = profileMain:FindFirstChild("FavoritesTab")
						local aboutTab = profileMain:FindFirstChild("AboutTab")
						local underline = profileMain:FindFirstChild("Underline")
						local tabDivider = profileMain:FindFirstChild("TabDivider")
						local profileUploads = profileMain:FindFirstChild("ProfileUploads")
						local aboutPanel = profileMain:FindFirstChild("AboutPanel")
						local emptyTitle = profileMain:FindFirstChild("EmptyTitle")
						local emptyText = profileMain:FindFirstChild("EmptyText")

						if sheetsTab and sheetsTab:IsA("GuiObject") then
							sheetsTab.Position = UDim2.fromOffset(0, 0)
							sheetsTab.Size = UDim2.fromOffset(112, 42)
						end

						if midiTab and midiTab:IsA("GuiObject") then
							midiTab.Position = UDim2.fromOffset(124, 0)
							midiTab.Size = UDim2.fromOffset(88, 42)
						end

						if favoritesTab and favoritesTab:IsA("GuiObject") then
							favoritesTab.Position = UDim2.fromOffset(224, 0)
							favoritesTab.Size = UDim2.fromOffset(112, 42)
							favoritesTab.Visible = type(state2.profileData) == "table"
								and state2.profileData.CanViewFavorites == true
						end

						if aboutTab and aboutTab:IsA("GuiObject") then
							local v47

							if type(state2.profileData) == "table" then
								v47 = state2.profileData.CanViewFavorites == true
							else
								v47 = false
							end

							aboutTab.Position = UDim2.fromOffset(v47 and 348 or 224, 0)
							aboutTab.Size = UDim2.fromOffset(82, 42)
						end

						if underline and underline:IsA("GuiObject") then
							underline.Position = UDim2.fromOffset(0, 43)
						end

						if tabDivider and tabDivider:IsA("GuiObject") then
							tabDivider.Position = UDim2.fromOffset(0, 47)
							tabDivider.Size = UDim2.new(1, 0, 0, 1)
						end

						if profileUploads and profileUploads:IsA("GuiObject") then
							profileUploads.Position = UDim2.fromOffset(0, 64)
							profileUploads.Size = UDim2.new(1, 0, 1, -64)
						end

						if aboutPanel and aboutPanel:IsA("GuiObject") then
							aboutPanel.Position = UDim2.fromOffset(0, 80)
							aboutPanel.Size = UDim2.new(1, 0, 0, v46 and 190 or 176)
							local biographyTitle = aboutPanel:FindFirstChild("BiographyTitle")
							local bioText = aboutPanel:FindFirstChild("BioText")

							if biographyTitle and biographyTitle:IsA("GuiObject") then
								biographyTitle.Position = UDim2.fromOffset(30, 24)
								biographyTitle.Size = UDim2.new(1, -60, 0, 28)
							end

							if bioText and bioText:IsA("GuiObject") then
								bioText.Position = UDim2.fromOffset(30, 72)
								bioText.Size = UDim2.new(1, -60, 1, -94)
							end
						end

						if emptyTitle and emptyTitle:IsA("GuiObject") then
							emptyTitle.Position = UDim2.fromOffset(0, 178)
							emptyTitle.Size = UDim2.new(1, 0, 0, 30)
						end

						if emptyText and emptyText:IsA("GuiObject") then
							emptyText.Position = UDim2.fromOffset(0, 212)
							emptyText.Size = UDim2.new(1, 0, 0, 26)
						end

						task.defer(state2.updateProfileGridLayout)
						task.defer(function()
							state2.setProfileTab(state2.profileTab or "Sheets", false)
						end)
					end
				end

				local phoneLandscapeActive = state2.phoneLandscapeActive == true
				pageTitle.Visible = not (visible or phoneLandscapeActive)
				pageSubtitle.Visible = not (visible or phoneLandscapeActive)
				toolbar.Visible = not visible
				cardGrid.Visible = not visible
				pagination.Visible = not visible
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if sectionHeader and sectionHeader:IsA("GuiObject") then
					local v46 = (selectedMode == "Community" or selectedMode == "MIDI")
						and state2.communitySectionView == nil
					sectionHeader.Visible = not (visible or v46)
				end

				if visible then
					emptyLabel.Visible = false
					clearCards()

					if not (state2.profileData or state2.profileLoading) then
						state2.refreshProfile()
					end
				end
			end

			function state2.openSheetPublishOverlay(p)
				state2.sheetPublishDifficulty = "Intermediate"
				local sheetPublishOverlay = parent:WaitForChild("SheetPublishOverlay")
				local panel2 = sheetPublishOverlay:FindFirstChild("Panel")
				state2.applyModalScale(panel2, 576, 760)

				if panel2 then
					for _, descendant in ipairs(panel2:GetDescendants()) do
						if not (descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox")) then
							continue
						end

						configureTextObject(
							descendant,
							math.max(10, (math.floor(tonumber(descendant.TextSize) or 14))),
							8
						)
					end

					state2.refreshSheetPublishPersonalSheets()
					local v46 = p and state2.findSheetPublishPersonalSheet(p) or nil
					state2.applySheetPublishSource(v46)
					local v47 = #(state2.sheetPublishPersonalSheets or {})
					local v48 = math.max(1, (math.floor(tonumber(state2.sheetPublishPersonalLimit) or 20)))

					local v49 = v46 and "Editing a saved Personal Sheet."
						or v48 <= v47 and "Creating a community-only upload because your Personal Sheets are full."
						or "Creating a new Personal Sheet and community upload."
					local uploadQuotaText = state2.getUploadQuotaText(state2.sheetUploadQuota)
					local v50 = v49 .. " Publishing costs " .. tostring(state2.communitySheetPublishCost) .. " Notes the first time. Sheet text max is " .. comma(math.max(
						1,
						(math.floor(tonumber(state2.communitySheetPublicMaxTextLength) or 10000))
					)) .. " characters."

					if uploadQuotaText ~= "" then
						v50 ..= " " .. uploadQuotaText
					end

					state2.setSheetPublishStatus(v50, false)
					updateSheetPublishSheetBoxLayout(panel2)
				end

				sheetPublishOverlay.Visible = true
				local sheetPublishControl = findSheetPublishControl(panel2, "FormScroll") -- inferred equivalent call

				if sheetPublishControl and sheetPublishControl:IsA("ScrollingFrame") then
					sheetPublishControl.CanvasPosition = Vector2.zero
					task.defer(function()
						if sheetPublishOverlay.Visible and sheetPublishControl.Parent then
							sheetPublishControl.CanvasPosition = Vector2.zero
						end
					end)
				end
			end

			function state2.getServerSearchQuery()
				local serverSearchQuery = tostring(state2.searchText or search.Text or ""):gsub("[%c]", " "):gsub(
					"^%s+",
					""
				):gsub(
					"%s+$",
					""
				):gsub(
					"%s%s+",
					" "
				)

				if #serverSearchQuery > 80 then
					serverSearchQuery = serverSearchQuery:sub(1, 80)
				end

				return serverSearchQuery
			end

			function state2.isPublicCatalogSearchActive(): boolean
				return (selectedMode == "Community" or selectedMode == "MIDI") and state2.getServerSearchQuery() ~= ""
			end

			function state2.currentModeHasMore(): boolean
				if state2.isPublicCatalogSearchActive() then
					return false
				end

				if selectedMode == "MIDI" then
					return state2.midiCatalogHasMore == true and type(state2.midiCatalogCursor) == "string"
				end

				if selectedMode ~= "Community" then
					return false
				end

				return state2.sheetCatalogHasMore == true and type(state2.sheetCatalogCursor) == "string"
			end

			function state2.loadMoreCurrentCatalog()
				if state2.isPublicCatalogSearchActive() then
					return
				end

				if selectedMode == "MIDI" then
					fn5(true)
				elseif selectedMode == "Community" then
					fn3(true)
				end
			end

			function state2.maybeLoadMoreCatalog()
				if
					state2.isPublicCatalogSearchActive()
					or (not root.Visible or selectedMode ~= "Community" and selectedMode ~= "MIDI")
				then
					return
				end

				local cardGrid2 = state2.mobileLandscapeActive and controls.CardGrid or cardGrid

				if not cardGrid2 then
					return
				end

				local now = os.clock()

				if now - state2.lastCatalogScrollLoadAt < 0.35 then
					return
				end

				local y = cardGrid2.AbsoluteCanvasSize.Y

				if
					y <= 0
					or cardGrid2.CanvasPosition.Y + cardGrid2.AbsoluteSize.Y < y - math.max(260, cardGrid2.AbsoluteSize.Y * 0.45)
				then
					return
				end

				state2.lastCatalogScrollLoadAt = now

				if state2.mobileLandscapeActive then
					local mobileCardScrollKey = state2.mobileCardScrollKey
					local mobileRenderLimits = state2.mobileRenderLimits or {}
					local v46

					if mobileCardScrollKey then
						v46 = tonumber(mobileRenderLimits[mobileCardScrollKey]) or nil
					end

					if mobileCardScrollKey and v46 and v46 < #v10 then
						mobileRenderLimits[mobileCardScrollKey] = math.min(#v10, v46 + 24)
						state2.mobileRenderLimits = mobileRenderLimits
						fn()
						return
					end
				elseif state2.communitySectionView then
					local sectionDetailScrollKey = state2.sectionDetailScrollKey
					local sectionDetailRenderLimits = state2.sectionDetailRenderLimits or {}
					local v46

					if sectionDetailScrollKey then
						v46 = tonumber(sectionDetailRenderLimits[sectionDetailScrollKey]) or nil
					end

					local v47 = math.max(0, (math.floor(tonumber(state2.sectionDetailTotal) or 0)))

					if sectionDetailScrollKey and v46 and v46 < v47 then
						local canvasPosition = cardGrid2.CanvasPosition
						sectionDetailRenderLimits[sectionDetailScrollKey] = math.min(v47, v46 + 24)
						state2.sectionDetailRenderLimits = sectionDetailRenderLimits
						fn()
						task.defer(function()
							if cardGrid2.Parent then
								cardGrid2.CanvasPosition = canvasPosition
							end
						end)
						return
					elseif sectionDetailScrollKey and v46 and state2.currentModeHasMore() then
						state2.sectionDetailGrowAfterCatalogLoad = sectionDetailScrollKey
					end
				end

				state2.loadMoreCurrentCatalog()
			end

			cardGrid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				task.defer(state2.maybeLoadMoreCatalog)
			end)

			controls.CardGrid:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				task.defer(state2.maybeLoadMoreCatalog)
			end)

			function state2.bindNewControls()
				if state2.controlsBound then
					return
				end

				state2.controlsBound = true

				local sheetPublishOverlay = parent:WaitForChild("SheetPublishOverlay")
				local panel2 = sheetPublishOverlay:FindFirstChild("Panel")
				local imageIdBox = panel2 and panel2:FindFirstChild("ImageIdBox", true)
				local browseImageButton = panel2 and panel2:FindFirstChild("BrowseImageButton", true)
				local sourceButton = panel2 and panel2:FindFirstChild("SourceButton", true)

				local unpublishButton = panel2 and panel2:FindFirstChild("UnpublishButton")
				local savedSheetPicker = sheetPublishOverlay:FindFirstChild("SavedSheetPicker")
				local panel3 = savedSheetPicker and savedSheetPicker:FindFirstChild("Panel")
				local closeButton = panel3 and panel3:FindFirstChild("CloseButton")
				local newSheetButton = panel3 and panel3:FindFirstChild("NewSheetButton")

				if sourceButton and sourceButton:IsA("GuiButton") then
					sourceButton.Activated:Connect(state2.openSavedSheetPicker)
				end

				if closeButton and closeButton:IsA("GuiButton") then
					closeButton.Activated:Connect(function()
						savedSheetPicker.Visible = false
					end)
				end

				if newSheetButton and newSheetButton:IsA("GuiButton") then
					newSheetButton.Activated:Connect(function()
						state2.applySheetPublishSource(nil)
						savedSheetPicker.Visible = false
					end)
				end

				if unpublishButton and unpublishButton:IsA("GuiButton") then
					unpublishButton.Activated:Connect(function()
						if state2.sheetPublishPending then
							return
						end

						local sheetPublishSheetId = tostring(state2.sheetPublishSheetId or "")

						if sheetPublishSheetId == "" then
							state2.setSheetPublishStatus("Choose a published Personal Sheet first.", true)
							return
						end

						state2.sheetPublishPending = true
						unpublishButton.Active = false
						unpublishButton.Text = "Unpublishing..."
						local success, result, v46, v47, v48 = pcall(function()
							return UnpublishCommunitySheetRemote:InvokeServer({
								SheetId = sheetPublishSheetId
							})
						end)

						state2.sheetPublishPending = false
						unpublishButton.Active = true
						unpublishButton.Text = "Unpublish"

						if success and result then
							if type(v47) == "table" and fn4 then
								fn4(v47)
								fn2(false)
							end

							if type(v48) == "table" then
								state2.applySheetPublishPersonalPayload(v48)
							end

							state2.closeSheetPublishOverlay()
							setInlineMessage(v46 or "Sheet removed from Community Sheets.", false) -- inferred equivalent call
						else
							if success then
								state2.setSheetPublishStatus(v46 or "Could not unpublish this sheet.", true)
								return
							end

							v2.Warn("[CommunitySheetsGui] UnpublishCommunitySheet failed:", result)
							state2.setSheetPublishStatus("Could not reach the community sheet service.", true)
						end
					end)
				end

				local sheetBox = panel2 and panel2:FindFirstChild("SheetBox", true)

				if sheetBox and sheetBox:IsA("TextBox") then
					sheetBox:GetPropertyChangedSignal("Text"):Connect(function()
						updateSheetPublishSheetBoxLayout(panel2)
					end)
				end

				if imageIdBox and imageIdBox:IsA("TextBox") then
					imageIdBox:GetPropertyChangedSignal("Text"):Connect(state2.updateSheetPublishImagePreview)
				end

				if midiPublishImageBox and midiPublishImageBox:IsA("TextBox") then
					midiPublishImageBox:GetPropertyChangedSignal("Text"):Connect(state2.updateMidiPublishImagePreview)
				end

				if browseImageButton and browseImageButton:IsA("GuiButton") then
					browseImageButton.Activated:Connect(function()
						ReplicatedStorage2:WaitForChild("OpenSharedCatalogImagePicker"):Fire(
							"SheetPublishPreviewImage",
							imageIdBox and imageIdBox.Text or "",
							"Search Roblox 2D assets for your sheet card background.",
							{
								DefaultQuery = "background",
								LayoutMode = "CardBackground",
								AspectRatio = 177 / 53,
								DefaultImage = getDefaultSheetCardImage()
							}
						)
					end)
				end

				if midiPublishBrowseImageButton and midiPublishBrowseImageButton:IsA("GuiButton") then
					midiPublishBrowseImageButton.Activated:Connect(function()
						ReplicatedStorage2:WaitForChild("OpenSharedCatalogImagePicker"):Fire(
							"MidiPublishPreviewImage",
							midiPublishImageBox and midiPublishImageBox.Text or "",
							"Search Roblox 2D assets for your MIDI card background.",
							{
								DefaultQuery = "music background",
								LayoutMode = "CardBackground",
								AspectRatio = 177 / 53,
								DefaultImage = getDefaultSheetCardImage()
							}
						)
					end)
				end

				ReplicatedStorage2:WaitForChild("SharedCatalogImageSelected").Event:Connect(function(value, value2)
					local v46 = tostring(value or "")

					if v46 == "SheetPublishPreviewImage" then
						if imageIdBox and imageIdBox:IsA("TextBox") then
							imageIdBox.Text = tostring(value2 or "")
							state2.updateSheetPublishImagePreview()
						end
					elseif
						v46 == "MidiPublishPreviewImage"
						and midiPublishImageBox
						and midiPublishImageBox:IsA("TextBox")
					then
						midiPublishImageBox.Text = tostring(value2 or "")
						state2.updateMidiPublishImagePreview()
					end
				end)

				local profileSection = content:FindFirstChild("ProfileSection")
				local profileCard = profileSection and profileSection:FindFirstChild("ProfileCard")
				local followButton = profileCard and profileCard:FindFirstChild("FollowButton")
				local repButton = profileCard and profileCard:FindFirstChild("RepButton")
				local profileMain = profileSection and profileSection:FindFirstChild("ProfileMain")
				local sheetsTab = profileMain and profileMain:FindFirstChild("SheetsTab")
				local midiTab = profileMain and profileMain:FindFirstChild("MidiTab")
				local favoritesTab = profileMain and profileMain:FindFirstChild("FavoritesTab")
				local aboutTab = profileMain and profileMain:FindFirstChild("AboutTab")

				if followButton and followButton:IsA("GuiButton") then
					followButton.Activated:Connect(function()
						state2.openSupportCreatorOverlay(state2.profileData)
					end)
				end

				if repButton and repButton:IsA("GuiButton") then
					repButton.Activated:Connect(state2.toggleProfileThumb)
				end

				local supportCreatorOverlay = state2.ensureSupportCreatorOverlay()
				local panel4 = supportCreatorOverlay and supportCreatorOverlay:FindFirstChild("Panel")
				local closeButton2 = panel4 and panel4:FindFirstChild("CloseButton")
				local cancelButton = panel4 and panel4:FindFirstChild("CancelButton")
				local submitButton = panel4 and panel4:FindFirstChild("SubmitButton")

				if closeButton2 and closeButton2:IsA("GuiButton") then
					closeButton2.Activated:Connect(state2.closeSupportCreatorOverlay)
				end

				if cancelButton and cancelButton:IsA("GuiButton") then
					cancelButton.Activated:Connect(state2.closeSupportCreatorOverlay)
				end

				if submitButton and submitButton:IsA("GuiButton") then
					submitButton.Activated:Connect(state2.submitSupportCreator)
				end

				if midiRepairCloseButton and midiRepairCloseButton:IsA("GuiButton") then
					midiRepairCloseButton.Activated:Connect(state2.closeMidiRepairOverlay)
				end

				if midiRepairCancelButton and midiRepairCancelButton:IsA("GuiButton") then
					midiRepairCancelButton.Activated:Connect(state2.closeMidiRepairOverlay)
				end

				if midiRepairSubmitButton and midiRepairSubmitButton:IsA("GuiButton") then
					midiRepairSubmitButton.Activated:Connect(state2.submitMidiRepair)
				end

				if sheetsTab and sheetsTab:IsA("GuiButton") then
					sheetsTab.Activated:Connect(function()
						state2.setProfileTab("Sheets", true)
					end)
				end

				if midiTab and midiTab:IsA("GuiButton") then
					midiTab.Activated:Connect(function()
						state2.setProfileTab("Midi", true)
					end)
				end

				if favoritesTab and favoritesTab:IsA("GuiButton") then
					favoritesTab.Activated:Connect(function()
						state2.setProfileTab("Favorites", true)
					end)
				end

				if aboutTab and aboutTab:IsA("GuiButton") then
					aboutTab.Activated:Connect(function()
						state2.setProfileTab("About", true)
					end)
				end

				sortButton.Activated:Connect(function()
					local sortMenu = toolbar:FindFirstChild("SortMenu")

					if sortMenu then
						sortMenu.Visible = not sortMenu.Visible
						state2.updateSortMenuVisuals()
					end
				end)
				local sortMenu = toolbar:FindFirstChild("SortMenu")

				if sortMenu then
					for _, childName in ipairs({
						"Default",
						"Newest",
						"Oldest",
						"TopLiked",
						"MostPlayed"
					}) do
						local button = sortMenu:FindFirstChild(childName)

						if button and button:IsA("TextButton") then
							button.Activated:Connect(function()
								state2.setSortMode(childName)
							end)
						end
					end
				end

				local shieldToggle = nav:FindFirstChild("ShieldToggle")

				if shieldToggle and shieldToggle:IsA("TextButton") then
					shieldToggle.Activated:Connect(function()
						state2.moderationTabsEnabled = not state2.moderationTabsEnabled

						if state2.moderationTabsEnabled then
							if canViewReports() then -- inferred equivalent call
								fn7("Reports")
								return
							end

							if canViewHiddenUploads() then -- inferred equivalent call
								fn7("Hidden")
								return
							end

							state2.moderationTabsEnabled = false
							updateNavVisuals()
						elseif selectedMode == "Reports" or selectedMode == "Hidden" or selectedMode == "Blocked" then
							fn7("Community")
						else
							updateNavVisuals()
						end
					end)
				end

				local panel5 = parent:WaitForChild("PreviewOverlay"):FindFirstChild("Panel")
				local details = panel5 and panel5:FindFirstChild("Details")
				local preview = panel5 and panel5:FindFirstChild("Preview")
				local closeButton3 = preview and preview:FindFirstChild("CloseButton")

				if closeButton3 and closeButton3:IsA("GuiButton") then
					closeButton3.Activated:Connect(state2.closePreviewOverlay)
				end

				if details then
					local playSheetButton = details:FindFirstChild("PlaySheetButton")
					local favoriteButton = details:FindFirstChild("FavoriteButton")

					if playSheetButton and playSheetButton:IsA("GuiButton") then
						playSheetButton.Activated:Connect(function()
							local pendingPreviewSong = state2.pendingPreviewSong

							if not pendingPreviewSong then
								return
							end

							if tostring(pendingPreviewSong.mode or "") == "MIDI" then
								if openCommunityMidi(pendingPreviewSong) then
									recordCommunityMidiPlay2(pendingPreviewSong)
								end
							elseif applySheet(pendingPreviewSong) then
								recordCommunityPlay(pendingPreviewSong)
								state2.closePreviewOverlay()
							end
						end)
					end

					if favoriteButton and favoriteButton:IsA("GuiButton") then
						favoriteButton.Activated:Connect(function()
							local pendingPreviewSong = state2.pendingPreviewSong

							if not pendingPreviewSong then
								return
							end

							local v46 = pendingPreviewSong.ownedByLocalPlayer == true
								or (tonumber(pendingPreviewSong.ownerUserId) or 0) == LocalPlayer.UserId

							if
								tostring(pendingPreviewSong.mode or "") == "Community"
								and v46
								and tostring(pendingPreviewSong.sheetId or "") ~= ""
							then
								local sheetId = pendingPreviewSong.sheetId
								state2.closePreviewOverlay()
								state2.openSheetPublishOverlay(sheetId)
							elseif tostring(pendingPreviewSong.mode or "") == "MIDI" and v46 then
								state2.openMidiRepairOverlay(pendingPreviewSong)
							end
						end)
					end
				end

				local panel6 = parent:WaitForChild("ReportOverlay"):FindFirstChild("Panel")

				if panel6 then
					for i = 1, 5 do
						local button = panel6:FindFirstChild("Reason" .. tostring(i))

						if button and button:IsA("TextButton") then
							button.Activated:Connect(function()
								state2.selectedReportReason = button.Text
								state2.setReportReasonVisuals()
							end)
						end
					end

					local otherBox = panel6:FindFirstChild("OtherBox")

					if otherBox and otherBox:IsA("TextBox") then
						otherBox:GetPropertyChangedSignal("Text"):Connect(function()
							otherBox.BackgroundColor3 = Color3.fromRGB(42, 45, 55)
						end)
					end

					local closeButton4 = panel6:FindFirstChild("CloseButton")
					local cancelButton2 = panel6:FindFirstChild("CancelButton")
					local submitButton2 = panel6:FindFirstChild("SubmitButton")

					if closeButton4 and closeButton4:IsA("GuiButton") then
						closeButton4.Activated:Connect(state2.closeReportOverlay)
					end

					if cancelButton2 and cancelButton2:IsA("GuiButton") then
						cancelButton2.Activated:Connect(state2.closeReportOverlay)
					end

					if submitButton2 and submitButton2:IsA("GuiButton") then
						submitButton2.Activated:Connect(function()
							local otherBox2 = panel6:FindFirstChild("OtherBox")
							local v46 = trimText(otherBox2 and otherBox2.Text or "") -- inferred equivalent call
							local v47 = trimText(state2.selectedReportReason) -- inferred equivalent call

							if v47 == "" then
								local prompt = panel6:FindFirstChild("Prompt")

								if prompt and prompt:IsA("TextLabel") then
									prompt.TextColor3 = Color3.fromRGB(255, 105, 125)
								end
							else
								if v47 == "Other" then
									if v46 == "" then
										if otherBox2 and otherBox2:IsA("TextBox") then
											otherBox2.BackgroundColor3 = Color3.fromRGB(75, 31, 42)
											otherBox2:CaptureFocus()
										end

										return
									end
								else
									v46 = v47
								end

								if sendContentReport(state2.pendingReportSong, v46) then
									state2.closeReportOverlay()
								end
							end
						end)
					end
				end

				local panel7 = parent:WaitForChild("SheetPublishOverlay"):FindFirstChild("Panel")

				if panel7 then
					for childName, v46 in pairs({
						DifficultyBeginner = "Easy",
						DifficultyIntermediate = "Medium",
						DifficultyAdvanced = "Hard",
						DifficultyExpert = "Expert"
					}) do
						local button = panel7 and panel7:FindFirstChild(childName, true)

						if button and button:IsA("TextButton") then
							button.Activated:Connect(function()
								state2.setSheetPublishDifficulty(v46)
							end)
						end
					end

					local closeButton4 = panel7:FindFirstChild("CloseButton")
					local cancelButton2 = panel7:FindFirstChild("CancelButton")
					local previewButton = panel7:FindFirstChild("PreviewButton")
					local submitButton2 = panel7:FindFirstChild("SubmitButton")

					if closeButton4 and closeButton4:IsA("GuiButton") then
						closeButton4.Activated:Connect(state2.closeSheetPublishOverlay)
					end

					if cancelButton2 and cancelButton2:IsA("GuiButton") then
						cancelButton2.Activated:Connect(state2.closeSheetPublishOverlay)
					end

					if previewButton and previewButton:IsA("GuiButton") then
						previewButton.Activated:Connect(function()
							local sheetPublishPreviewSong = state2.buildSheetPublishPreviewSong()

							if sheetPublishPreviewSong then
								state2.closeSheetPublishOverlay()
								state2.openPreviewOverlay(sheetPublishPreviewSong)
							end
						end)
					end

					if submitButton2 and submitButton2:IsA("GuiButton") then
						submitButton2.Activated:Connect(function()
							if state2.sheetPublishPending then
								return
							end

							local sheetPublishPreviewSong = state2.buildSheetPublishPreviewSong()

							if not sheetPublishPreviewSong then
								return
							end

							local difficulty = ({
									Beginner = "Easy",
									Intermediate = "Medium",
									Advanced = "Hard",
									Expert = "Expert"
								})[state2.getDifficultyDisplayLabel(sheetPublishPreviewSong.difficulty)]
								or "Medium"
							state2.sheetPublishPending = true
							submitButton2.Active = false
							submitButton2.Text = state2.sheetPublishIsPublished and "Updating..." or "Publishing..."
							state2.setSheetPublishStatus("Checking and publishing your sheet...", false)
							local success, result, v47, v48, v49 = pcall(function()
								return PublishCommunitySheetRemote:InvokeServer({
									SheetId = state2.sheetPublishSheetId,
									Name = sheetPublishPreviewSong.name,
									Sheet = sheetPublishPreviewSong.sheet,
									Description = sheetPublishPreviewSong.description,
									Difficulty = difficulty,
									Transpose = sheetPublishPreviewSong.transpose,
									ImageAssetId = sheetPublishPreviewSong.imageAssetId
								})
							end)

							state2.sheetPublishPending = false
							submitButton2.Active = true
							submitButton2.Text = state2.sheetPublishIsPublished and "Update" or "Publish"

							if success and result then
								if type(v48) == "table" and fn4 then
									fn4(v48)
									fn2(false)
								end

								if type(v49) == "table" then
									state2.applySheetPublishPersonalPayload(v49)
								end

								state2.closeSheetPublishOverlay()
								setInlineMessage( -- inferred equivalent call
									v47 or state2.sheetPublishIsPublished and "Sheet updated." or "Sheet published.",
									false
								)
							else
								if success then
									state2.setSheetPublishStatus(v47 or "Could not publish this sheet.", true)
									return
								end

								v2.Warn("[CommunitySheetsGui] PublishCommunitySheet failed:", result)
								state2.setSheetPublishStatus("Could not reach the community sheet service.", true)
							end
						end)
					end
				end

				publish.Activated:Connect(function()
					if selectedMode == "MIDI" then
						fn8()
					else
						state2.openSheetPublishOverlay()
					end
				end)
				state2.updateSortMenuVisuals()
			end
		end

		local function closeModerationOverlay() -- 3 equivalent calls inferred from this helper
			v32 = nil
			moderationOverlay.Visible = false
		end

		local function openModerationOverlay(data)
			if not data then
				return
			end

			v32 = data
			local mobileLandscapeActive = state2.mobileLandscapeActive == true
			local v46 = mobileLandscapeActive and 620 or 560
			local v47 = mobileLandscapeActive and 388 or 376
			state2.applyModalScale(moderationPanel, v46, v47)

			if moderationTitle then
				moderationTitle.Position = UDim2.fromOffset(24, mobileLandscapeActive and 16 or 20)
				moderationTitle.Size = UDim2.new(1, -48, 0, 30)
			end

			if moderationMessage then
				moderationMessage.Position = UDim2.fromOffset(24, mobileLandscapeActive and 52 or 60)
				moderationMessage.Size = UDim2.new(1, -48, 0, mobileLandscapeActive and 106 or 124)
			end

			if moderationReasonBox then
				moderationReasonBox.Position = UDim2.fromOffset(24, mobileLandscapeActive and 174 or 204)
				moderationReasonBox.Size = UDim2.new(1, -48, 0, 42)
			end

			local v48 = {
				moderationHideButton,
				moderationResolveButton,
				moderationDeleteButton,
				moderationBlockButton,
				moderationCancelButton
			}

			if mobileLandscapeActive then
				local v49 = math.floor((v46 - 68) / 3)
				local v50 = math.floor((v46 - 58) / 2)
				local v51 = v47 - 104
				local v52 = v47 - 58

				for i, v53 in ipairs({ moderationHideButton, moderationResolveButton, moderationDeleteButton }) do
					if not v53 then
						continue
					end

					v53.Position = UDim2.fromOffset(24 + (i - 1) * (v49 + 10), v51)
					v53.Size = UDim2.fromOffset(v49, 38)
				end

				if moderationBlockButton then
					moderationBlockButton.Position = UDim2.fromOffset(24, v52)
					moderationBlockButton.Size = UDim2.fromOffset(v50, 38)
				end

				if moderationCancelButton then
					moderationCancelButton.Position = UDim2.fromOffset(v50 + 34, v52)
					moderationCancelButton.Size = UDim2.fromOffset(v50, 38)
				end
			else
				local v49 = math.floor((v46 - 88) / 5)

				for i, v50 in ipairs(v48) do
					if not v50 then
						continue
					end

					v50.Position = UDim2.fromOffset(24 + (i - 1) * (v49 + 10), v47 - 58)
					v50.Size = UDim2.fromOffset(v49, 38)
				end
			end

			for _, v49 in ipairs(v48) do
				if not v49 then
					continue
				end

				v49.Active = true
				v49.AutoButtonColor = true
				v49.TextTransparency = 0
			end

			local v49 = tostring(data.mode or "") == "MIDI"
			local v50 = data.isHidden == true or data.isDeleted == true
			local visible = v30
			local v52 = v28

			if v49 then
				visible = v31
				v52 = v29
			end

			local v53 = data.isDeleted and "Deleted" or data.isHidden and "Hidden" or "Public"
			local v54 = trimText(data.moderationReason) -- inferred equivalent call
			local v55 = trimText(data.moderatorName) -- inferred equivalent call
			local v56 = formatReportDetails(data, 4)
			local v57 = tostring(data.moderationAction or "") == "blockUser"
			moderationTitle.Text = v50 and (v49 and "Restore MIDI" or "Restore sheet")
				or v49 and "Moderate MIDI"
				or "Moderate sheet"
			moderationMessage.Text = string.format(
				"%s\nby %s\nStatus: %s\nReports: %s%s%s%s",
				tostring(data.name or v49 and "Untitled MIDI" or "Untitled Sheet"),
				tostring(data.creatorDisplayName or data.creatorName or "Player"),
				v53,
				comma(data.reportCount or 0),
				v56 == "" and "" or "\n" .. v56 or "",
				v54 == "" and "" or "\nReason: " .. v54 or "",
				v55 == "" and "" or "\nBy: " .. v55 or ""
			)

			configureTextObject(moderationTitle, 20, 12)
			configureTextObject(moderationMessage, 13, 8)
			moderationReasonBox.Text = ""
			moderationReasonBox.PlaceholderText = v50 and "Optional restore note" or "Reason for moderation"
			moderationHideButton.Text = v50 and "Restore" or "Hide"
			moderationResolveButton.Text = "Clear Reports"
			local moderationResolveButton2 = moderationResolveButton
			local visible2

			if v52 then
				if type(data.reports) == "table" then
					visible2 = #data.reports > 0
				else
					visible2 = false
				end
			else
				visible2 = v52
			end

			moderationResolveButton2.Visible = visible2
			moderationHideButton.Visible = v50 and visible or not v50 and v52
			moderationDeleteButton.Visible = visible and not (v50 and data.isDeleted)
			moderationBlockButton.Text = v57 and "Unblock" or "Block"
			moderationBlockButton.Visible = visible
			configureTextObject(moderationHideButton, 12, 8)
			configureTextObject(moderationResolveButton, 12, 8)
			configureTextObject(moderationDeleteButton, 12, 8)
			configureTextObject(moderationBlockButton, 12, 8)
			moderationOverlay.Visible = true
		end

		local function runModerationAction(p)
			local v46 = v32

			if v46 then
				if state2.moderationActionPending then
					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Moderation is already applying.")
					emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
				else
					local reason = trimText(moderationReasonBox.Text) -- inferred equivalent call
					local v48 = tostring(v46.mode or "") == "MIDI"
					local v49 = state2.applyOptimisticModeration(v46, p, reason)
					state2.moderationActionPending = true
					closeModerationOverlay() -- inferred equivalent call

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("Applying moderation...")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

					task.spawn(function()
						local success, result, v50, v51 = pcall(function()
							if v48 then
								return moderateCommunityMidi:InvokeServer(v46.id, p, {
									Reason = reason
								})
							end

							return moderateCommunitySheet:InvokeServer(v46.id, p, {
								Reason = reason
							})
						end)

						state2.moderationActionPending = false

						if success and result then
							if type(v51) == "table" then
								if v48 and fn6 then
									fn6(v51)
								elseif fn4 then
									fn4(v51)
								end

								fn2(false)
							elseif v48 and fn5 then
								fn5()
							elseif fn3 then
								fn3()
							end

							state2.applyLocalModerationResult(v46, p, reason)
							setInlineMessage(v50 or "Moderation applied.", false) -- inferred equivalent call
						elseif success then
							state2.restoreModerationLists(v49)
							setInlineMessage(v50 or "Could not moderate this upload.", true) -- inferred equivalent call
						else
							state2.restoreModerationLists(v49)
							v2.Warn("[CommunitySheetsGui] Moderate community upload failed:", result)

							if state2.stopLoadingTextAnimation then
								state2.stopLoadingTextAnimation()
							end

							emptyLabel.Text = tostring("Could not reach moderation service.")
							emptyLabel.TextColor3 = Color3.fromRGB(255, 190, 90) or Color3.fromRGB(145, 151, 164)
						end
					end)
				end
			else
				closeModerationOverlay() -- inferred equivalent call
			end
		end

		do
			local function fillCard(songCard, data, layoutOrder)
				songCard.LayoutOrder = layoutOrder
				songCard.Visible = true
				songCard.Size = UDim2.fromOffset(cardWidth, v15)
				local title = songCard:FindFirstChild("Title")
				local creator = songCard:FindFirstChild("Creator")
				local difficultyBadge = songCard:FindFirstChild("DifficultyBadge")
				local preview = songCard:FindFirstChild("Preview")
				local likes = songCard:FindFirstChild("Stats") and songCard.Stats:FindFirstChild("Likes")
				local plays = songCard:FindFirstChild("Stats") and songCard.Stats:FindFirstChild("Plays")
				local loadButton = songCard:FindFirstChild("LoadButton")
				local twoDButton = songCard:FindFirstChild("TwoDButton")
				local favoriteButton = songCard:FindFirstChild("FavoriteButton")
				local iconHolder = songCard:FindFirstChild("IconHolder")
				local musicIcon = iconHolder and iconHolder:FindFirstChild("MusicIcon")

				if musicIcon and musicIcon:IsA("ImageLabel") then
					local defaultImage = tostring(musicIcon:GetAttribute("DefaultImage") or musicIcon.Image)
					local image = state2.profileAssetImage(data.imageAssetId)

					if image == "" or not image then
						image = defaultImage
					end

					musicIcon.Image = image
				end

				local mode = tostring(data.mode or "")
				local v46 = selectedMode == "Hidden"
				local v47 = data.ownedByLocalPlayer == true or (tonumber(data.ownerUserId) or 0) == LocalPlayer.UserId
				local v48

				if state2.moderationTabsEnabled == true then
					v48 = mode == "MIDI" and v31

					if not v48 then
						v48 = mode == "Community" and v30
					end
				else
					v48 = false
				end

				if title then
					title.Text = tostring(data.name or "Untitled Sheet")
					configureTextObject(title, 16, 9)
				end

				if creator then
					creator.Text = "by " .. tostring(data.creatorDisplayName or data.creatorName or data.source or "Player")
					creator.Size = UDim2.new(1, -188, 0, 20)
					creator.TextColor3 = Color3.fromRGB(75, 190, 255)
					configureTextObject(creator, 12, 8)
				end

				local creatorLink = songCard:FindFirstChild("CreatorLink")

				if creatorLink and not creatorLink:IsA("TextButton") then
					creatorLink:Destroy()
					creatorLink = nil
				end

				if not creatorLink then
					creatorLink = Instance.new("TextButton")
					creatorLink.Name = "CreatorLink"
					creatorLink.BackgroundTransparency = 1
					creatorLink.BorderSizePixel = 0
					creatorLink.AutoButtonColor = false
					creatorLink.Text = ""
					creatorLink.Parent = songCard
				end

				local v49 = math.max(0, (math.floor(tonumber(data.ownerUserId) or 0)))
				creatorLink.Visible = v49 > 0
				creatorLink.Active = v49 > 0
				creatorLink.ZIndex = songCard.ZIndex + 20

				if creator and creator:IsA("GuiObject") then
					creatorLink.Position = creator.Position
					creatorLink.Size = creator.Size
				end

				if v49 > 0 then
					table.insert(connections, creatorLink.Activated:Connect(function()
						state2.openCommunityProfile(v49, data.creatorDisplayName, data.creatorName)
					end))
				end

				local uploadDate = songCard:FindFirstChild("UploadDate")

				if not uploadDate then
					uploadDate = Instance.new("TextLabel")
					uploadDate.Name = "UploadDate"
					uploadDate.BackgroundTransparency = 1
					uploadDate.Font = Enum.Font.GothamMedium
					uploadDate.TextColor3 = Color3.fromRGB(130, 138, 155)
					uploadDate.TextXAlignment = Enum.TextXAlignment.Right
					uploadDate.TextTruncate = Enum.TextTruncate.AtEnd
					uploadDate.Position = UDim2.new(1, -148, 0, 148)
					uploadDate.Size = UDim2.fromOffset(128, 20)
					uploadDate.ZIndex = songCard.ZIndex + 1
					uploadDate.Parent = songCard
				end

				uploadDate.Text = formatUploadDate(data.publishedAt)
				uploadDate.Visible = (tonumber(data.publishedAt) or 0) > 0
				configureTextObject(uploadDate, 10, 7)

				if difficultyBadge then
					state2.applyDifficultyBadgeStyle(difficultyBadge, data.difficulty)
					configureTextObject(difficultyBadge, 10, 7)
				end

				if preview then
					if selectedMode == "Reports" then
						local text = formatReportDetails(data, 2)

						if text == "" or not text then
							text = comma(data.reportCount or 0) .. " report(s)"
						end

						preview.Text = text
					elseif v46 then
						local v50 = data.isDeleted and "Deleted" or "Hidden"
						local v51 = trimText(data.moderationReason) -- inferred equivalent call
						preview.Text = v50 .. (v51 == "" and ": no reason saved" or ": " .. v51 or ": no reason saved")
					elseif mode == "MIDI" then
						local firstNonEmptyText = state2.firstNonEmptyText(data.preview)
						preview.Text = (firstNonEmptyText == "" or not firstNonEmptyText) and "Ready to play"
							or firstNonEmptyText
					else
						local v50 = state2.firstNonEmptyText(data.preview)

						if v50 == "" then
							v50 = tostring(data.sheet or ""):gsub("%s+", " ")

							if v50 == "" then
								v50 = "No preview available yet."
							elseif #v50 > 92 then
								v50 = v50:sub(1, 89) .. "..."
							end
						end

						preview.Text = "\"" .. v50 .. "\""
					end

					configureTextObject(preview, 12, 8)
				end

				if likes and likes:FindFirstChild("Value") then
					if v46 then
						likes.Value.Text = data.isDeleted and "Deleted" or "Hidden"
					elseif selectedMode == "Reports" then
						local reportCount = tonumber(data.reportCount) or 0
						likes.Size = UDim2.new(0, 84, 0, 24)
						likes.Value.Position = UDim2.new(0, 28, 0, 0)
						likes.Value.Size = UDim2.new(1, -32, 1, 0)
						likes.Value.Text = comma(reportCount) .. (reportCount == 1 and " report" or " reports")
						likes.Value.TextScaled = true
						likes.Value.TextWrapped = true

						if not likes.Value:FindFirstChild("ReportValueTextLimit") then
							local reportValueTextLimit = Instance.new("UITextSizeConstraint")
							reportValueTextLimit.Name = "ReportValueTextLimit"
							reportValueTextLimit.MinTextSize = 8
							reportValueTextLimit.MaxTextSize = 12
							reportValueTextLimit.Parent = likes.Value
						end

						local icon = likes:FindFirstChild("Icon")

						if icon and icon:IsA("ImageLabel") then
							icon.Visible = false
						end

						local reportFlag = likes:FindFirstChild("ReportFlag")

						if not reportFlag then
							reportFlag = Instance.new("TextLabel")
							reportFlag.Name = "ReportFlag"
							reportFlag.BackgroundTransparency = 1
							reportFlag.AnchorPoint = Vector2.new(0, 0.5)
							reportFlag.Position = UDim2.new(0, 8, 0.5, 0)
							reportFlag.Size = UDim2.new(0, 14, 0, 14)
							reportFlag.FontFace = Font.new(
								"rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json",
								Enum.FontWeight.Regular,
								Enum.FontStyle.Normal
							)
							reportFlag.TextScaled = true
							reportFlag.TextWrapped = true
							reportFlag.TextXAlignment = Enum.TextXAlignment.Center
							reportFlag.TextYAlignment = Enum.TextYAlignment.Center
							reportFlag.ZIndex = likes.Value.ZIndex
							reportFlag.Parent = likes
							local reportFlagTextLimit = Instance.new("UITextSizeConstraint")
							reportFlagTextLimit.Name = "ReportFlagTextLimit"
							reportFlagTextLimit.MinTextSize = 9
							reportFlagTextLimit.MaxTextSize = 14
							reportFlagTextLimit.Parent = reportFlag
						end

						reportFlag.Visible = true
						reportFlag.Text = "flag"
						reportFlag.TextColor3 = Color3.fromRGB(255, 85, 110)
					else
						likes.Value.Text = comma(data.likes or 0)
					end

					configureTextObject(likes.Value, (selectedMode == "Reports" or v46) and 11 or 12, 8)
				end

				if plays and plays:FindFirstChild("Value") then
					plays.Value.Text = comma(data.plays or 0)
					configureTextObject(plays.Value, 12, 8)
				end

				if loadButton and loadButton:IsA("TextButton") then
					loadButton.Visible = false
				end

				if twoDButton and twoDButton:IsA("TextButton") then
					twoDButton.Visible = false
				end

				local clickTarget = songCard:FindFirstChild("ClickTarget")

				if clickTarget and clickTarget:IsA("GuiButton") then
					clickTarget.Visible = true
					clickTarget.Active = true
					table.insert(connections, clickTarget.Activated:Connect(function()
						state2.openPreviewOverlay(data)
					end))
				end

				if favoriteButton and favoriteButton:IsA("GuiButton") then
					if v46 or mode ~= "Community" and mode ~= "MIDI" or v47 then
						favoriteButton.Visible = false
					else
						favoriteButton.Position = UDim2.new(1, -96, 1, -50)
						updateFavoriteVisual(favoriteButton, data)
						table.insert(connections, favoriteButton.Activated:Connect(function()
							toggleFavorite(data)
						end))
					end
				end

				local adminButton = songCard:FindFirstChild("AdminButton")

				if adminButton and adminButton:IsA("GuiObject") then
					adminButton.Visible = false
				end

				local restoreButton = songCard:FindFirstChild("RestoreButton")

				if restoreButton and restoreButton:IsA("GuiObject") then
					restoreButton.Visible = false
				end

				local ownerHideButton = songCard:FindFirstChild("OwnerHideButton")

				if ownerHideButton and ownerHideButton:IsA("GuiObject") then
					ownerHideButton.Visible = false
				end

				local moreMenu = songCard:FindFirstChild("MoreMenu")

				if moreMenu and moreMenu:IsA("GuiObject") then
					moreMenu.Visible = false
				end

				local function getMoreMenu(p)
					local mobileLandscapeActive = state2.mobileLandscapeActive == true

					local v50 = math.max(
						mobileLandscapeActive and 38 or 42,
						p * (mobileLandscapeActive and 30 or 34) + 8
					)
					local v51 = mobileLandscapeActive and 156 or 162
					local moreMenu2 = songCard:FindFirstChild("MoreMenu")

					if not moreMenu2 then
						moreMenu2 = Instance.new("Frame")
						moreMenu2.Name = "MoreMenu"
						moreMenu2.Parent = songCard
						local uiCorner = Instance.new("UICorner")
						uiCorner.CornerRadius = UDim.new(0, 10)
						uiCorner.Parent = moreMenu2
						local uiStroke = Instance.new("UIStroke")
						uiStroke.Color = Color3.fromRGB(68, 76, 96)
						uiStroke.Transparency = 0.2
						uiStroke.Parent = moreMenu2
					end

					moreMenu2.Visible = false
					moreMenu2.ClipsDescendants = true
					moreMenu2.BackgroundColor3 = Color3.fromRGB(30, 34, 45)
					moreMenu2.BorderSizePixel = 0
					moreMenu2.ZIndex = 20

					if mobileLandscapeActive then
						local v52 = math.max(8, v15 - (v50 + 58))
						moreMenu2.Position = UDim2.new(1, -(v51 + 10), 0, v52)
					else
						moreMenu2.Position = UDim2.new(1, -174, 1, -(v50 + 58))
					end

					moreMenu2.Size = UDim2.fromOffset(v51, v50)
					return moreMenu2
				end

				local function hideMenuOption(moreMenu2, childName) -- 8 equivalent calls inferred from this helper
					local guiObject = moreMenu2 and moreMenu2:FindFirstChild(childName)

					if guiObject and guiObject:IsA("GuiObject") then
						guiObject.Visible = false
					end
				end

				local function setMenuOption(moreMenu2, name, p, text, textColor)
					local parent2 = moreMenu2:FindFirstChild(name)

					if not parent2 then
						parent2 = Instance.new("TextButton")
						parent2.Name = name
						parent2.Parent = moreMenu2
						local uiCorner = Instance.new("UICorner")
						uiCorner.CornerRadius = UDim.new(0, 8)
						uiCorner.Parent = parent2
					end

					parent2.Visible = true
					parent2.Text = text
					parent2.Font = Enum.Font.GothamSemibold
					parent2.TextSize = 12
					parent2.TextColor3 = textColor
					parent2.BackgroundColor3 = Color3.fromRGB(42, 45, 55)
					parent2.BorderSizePixel = 0
					parent2.AutoButtonColor = true
					local mobileLandscapeActive = state2.mobileLandscapeActive == true

					parent2.Position = UDim2.fromOffset(6, 6 + (p - 1) * (mobileLandscapeActive and 30 or 34))
					parent2.Size = UDim2.new(1, -12, 0, mobileLandscapeActive and 27 or 30)
					parent2.ZIndex = 21
					configureTextObject(parent2, mobileLandscapeActive and 11 or 12, 8)
					return parent2
				end

				if v46 then
					if v48 then
						local cardActionButton = ensureCardActionButton(
							songCard,
							"MoreButton",
							"__more",
							36,
							48,
							Color3.fromRGB(42, 45, 55)
						)
						local moreMenu2 = getMoreMenu(2)
						hideMenuOption(moreMenu2, "ReportOption") -- inferred equivalent call
						hideMenuOption(moreMenu2, "OwnerHideOption") -- inferred equivalent call
						hideMenuOption(moreMenu2, "HideOption") -- inferred equivalent call
						local v50 = setMenuOption(
							moreMenu2,
							"RestoreOption",
							1,
							"Restore",
							Color3.fromRGB(92, 228, 150)
						)
						local v51 = setMenuOption(
							moreMenu2,
							"ModerateOption",
							2,
							"More Moderation",
							Color3.fromRGB(208, 190, 255)
						)
						table.insert(connections, cardActionButton.Activated:Connect(function()
							moreMenu2.Visible = not moreMenu2.Visible
						end))
						table.insert(connections, v50.Activated:Connect(function()
							moreMenu2.Visible = false
							v32 = data
							moderationReasonBox.Text = ""
							runModerationAction("restore")
						end))
						table.insert(connections, v51.Activated:Connect(function()
							moreMenu2.Visible = false
							openModerationOverlay(data)
						end))
					else
						local moreButton = songCard:FindFirstChild("MoreButton")

						if moreButton and moreButton:IsA("GuiObject") then
							moreButton.Visible = false
						end
					end
				elseif mode == "Community" or mode == "MIDI" then
					local reportButton = songCard:FindFirstChild("ReportButton")

					if reportButton then
						reportButton.Visible = false
					end

					local v50 = mode == "MIDI" and v29

					if not v50 then
						v50 = mode == "Community" and v28
					end

					local v51

					if mode == "MIDI" or mode == "Community" then
						v51 = v47
					else
						v51 = false
					end

					local v52 = not v47
					local v53 = (v52 and 1 or 0) + (v51 and 1 or 0) + (v50 and 2 or 0)

					if v53 <= 0 then
						local moreButton = songCard:FindFirstChild("MoreButton")

						if moreButton and moreButton:IsA("GuiObject") then
							moreButton.Visible = false
						end
					else
						local cardActionButton = ensureCardActionButton(
							songCard,
							"MoreButton",
							"__more",
							36,
							48,
							Color3.fromRGB(42, 45, 55)
						)
						local moreMenu2 = getMoreMenu(v53)
						hideMenuOption(moreMenu2, "RestoreOption") -- inferred equivalent call
						local v54 = 1
						local v55 = nil

						if v52 then
							v55 = setMenuOption(
								moreMenu2,
								"ReportOption",
								v54,
								mode == "MIDI" and "Report MIDI" or "Report Sheet",
								Color3.fromRGB(255, 114, 132)
							)
							v54 += 1
						else
							hideMenuOption(moreMenu2, "ReportOption") -- inferred equivalent call
						end

						local v56 = nil

						if v51 then
							v56 = setMenuOption(
								moreMenu2,
								"OwnerHideOption",
								v54,
								mode == "MIDI" and "Hide Upload" or "Unpublish Sheet",
								Color3.fromRGB(255, 164, 139)
							)
							v54 += 1
						else
							hideMenuOption(moreMenu2, "OwnerHideOption") -- inferred equivalent call
						end

						local v57 = nil
						local v58 = nil

						if v50 then
							v57 = setMenuOption(moreMenu2, "HideOption", v54, "Hide", Color3.fromRGB(255, 164, 139))
							v58 = setMenuOption(
								moreMenu2,
								"ModerateOption",
								v54 + 1,
								"More Moderation",
								Color3.fromRGB(208, 190, 255)
							)
						else
							hideMenuOption(moreMenu2, "HideOption") -- inferred equivalent call
							hideMenuOption(moreMenu2, "ModerateOption") -- inferred equivalent call
						end

						table.insert(connections, cardActionButton.Activated:Connect(function()
							moreMenu2.Visible = not moreMenu2.Visible
						end))

						if v55 then
							table.insert(connections, v55.Activated:Connect(function()
								moreMenu2.Visible = false
								state2.openReportOverlay(data)
							end))
						end

						if v56 then
							table.insert(connections, v56.Activated:Connect(function()
								moreMenu2.Visible = false

								if mode == "MIDI" then
									unpublishOwnedMidi(data)
								else
									state2.unpublishOwnedCommunitySheet(data)
								end
							end))
						end

						if v57 then
							table.insert(connections, v57.Activated:Connect(function()
								moreMenu2.Visible = false
								v32 = data
								moderationReasonBox.Text = ""
								runModerationAction("hide")
							end))
						end

						if v58 then
							table.insert(connections, v58.Activated:Connect(function()
								moreMenu2.Visible = false
								openModerationOverlay(data)
							end))
						end
					end
				else
					local moreButton = songCard:FindFirstChild("MoreButton")

					if moreButton and moreButton:IsA("GuiObject") then
						moreButton.Visible = false
					end
				end
			end

			function state2.addCommunityHomeHeader(parent2, text, id, p)
				local sectionHeader = content:FindFirstChild("SectionHeader")
				local communitySectionHeader = sectionHeader and sectionHeader:Clone() or Instance.new("Frame")
				communitySectionHeader.Name = "CommunitySectionHeader"
				communitySectionHeader.BackgroundTransparency = 1
				communitySectionHeader.BorderSizePixel = 0
				communitySectionHeader.Visible = true
				communitySectionHeader.Position = UDim2.fromOffset(0, p)
				communitySectionHeader.Size = UDim2.new(1, 0, 0, 38)
				communitySectionHeader.Parent = parent2
				communitySectionHeader.ZIndex = 3

				for _, guiObject in ipairs(communitySectionHeader:GetDescendants()) do
					if guiObject:IsA("GuiObject") then
						guiObject.ZIndex = math.max(guiObject.ZIndex, 4)
					end
				end

				local backButton = communitySectionHeader:FindFirstChild("BackButton")

				if backButton and backButton:IsA("GuiObject") then
					backButton.Visible = false
					backButton.Active = false
					backButton.Selectable = false
				end

				local sectionIcon = communitySectionHeader:FindFirstChild("SectionIcon")

				if sectionIcon and sectionIcon:IsA("GuiObject") then
					sectionIcon.Visible = true
					sectionIcon.Position = UDim2.fromOffset(0, 3)
					local image = (sectionIcon:IsA("ImageLabel") or sectionIcon:IsA("ImageButton")) and v5[id]

					if image then
						sectionIcon.Image = image
						sectionIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					end
				end

				local sectionTitle = communitySectionHeader:FindFirstChild("SectionTitle")

				if sectionTitle and sectionTitle:IsA("TextLabel") then
					sectionTitle.Position = UDim2.fromOffset(34, 0)
					sectionTitle.Size = UDim2.new(1, -150, 0, 30)
					sectionTitle.Text = text
					sectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
					configureTextObject(sectionTitle, 20, 10)
				end

				local viewAllButton = communitySectionHeader:FindFirstChild("ViewAllButton")

				if viewAllButton and viewAllButton:IsA("TextButton") then
					viewAllButton.Visible = true
					viewAllButton.Active = true
					viewAllButton.AutoButtonColor = true
					viewAllButton.BackgroundTransparency = 1
					viewAllButton.Position = UDim2.new(1, -72, 0, 1)
					viewAllButton.Size = UDim2.fromOffset(72, 28)
					viewAllButton.Text = "View All"
					viewAllButton.TextColor3 = Color3.fromRGB(150, 158, 174)
					viewAllButton.TextXAlignment = Enum.TextXAlignment.Left
					local arrowIcon = viewAllButton:FindFirstChild("ArrowIcon")

					if not (arrowIcon and arrowIcon:IsA("ImageLabel")) then
						if arrowIcon then
							arrowIcon:Destroy()
						end

						arrowIcon = Instance.new("ImageLabel")
						arrowIcon.Name = "ArrowIcon"
						arrowIcon.Parent = viewAllButton
					end

					arrowIcon.AnchorPoint = Vector2.new(0, 0.5)
					arrowIcon.Position = UDim2.fromOffset(56, 14)
					arrowIcon.Size = UDim2.fromOffset(12, 12)
					arrowIcon.BackgroundTransparency = 1
					arrowIcon.Image = "rbxassetid://13868199710"
					arrowIcon.ImageColor3 = Color3.fromRGB(150, 158, 174)
					arrowIcon.ScaleType = Enum.ScaleType.Fit
					arrowIcon.ZIndex = viewAllButton.ZIndex + 1
					configureTextObject(viewAllButton, 13, 8)
					table.insert(connections, viewAllButton.Activated:Connect(function()
						state2.communitySectionView = { Id = id, Title = text }
						v11 = 1
						cardGrid.CanvasPosition = Vector2.zero
						fn()
					end))
				end

				local thinSeparator = communitySectionHeader:FindFirstChild("ThinSeparator")

				if thinSeparator and thinSeparator:IsA("GuiObject") then
					thinSeparator.Position = UDim2.new(0, 0, 1, -1)
					thinSeparator.Size = UDim2.new(1, 0, 0, 1)
				end

				return communitySectionHeader
			end

			function state2.renderCommunityHomeSection(parent2, p, p2, p3, p4)
				local communitySectionSongs = state2.getCommunitySectionSongs(p2, p4)

				if #communitySectionSongs == 0 then
					return p3
				end

				state2.addCommunityHomeHeader(parent2, p, p2, p3)
				local v46 = p3 + 48

				for i, communitySectionSong in ipairs(communitySectionSongs) do
					local v47 = i - 1
					local songCard = cardTemplate:Clone()
					songCard.Name = "SongCard"
					songCard.Parent = parent2
					songCard.Position = UDim2.fromOffset(v47 * (cardWidth + v16), v46)
					fillCard(songCard, communitySectionSong, i)
					state2.motion.AttachCard(songCard, i, root)
				end

				return v46 + v15 + 42
			end

			function state2.configureCommunitySectionHeader(text)
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if not (sectionHeader and sectionHeader:IsA("GuiObject")) then
					return
				end

				sectionHeader.Visible = true
				local backButton = sectionHeader:FindFirstChild("BackButton")

				if not backButton then
					backButton = Instance.new("TextButton")
					backButton.Name = "BackButton"
					backButton.Parent = sectionHeader
				end

				backButton.Visible = true
				backButton.Active = true
				backButton.AutoButtonColor = true
				backButton.BackgroundTransparency = 1
				backButton.BorderSizePixel = 0
				backButton.Position = UDim2.fromOffset(0, 1)
				backButton.Size = UDim2.fromOffset(24, 28)
				backButton.Font = Enum.Font.GothamBold
				backButton.Text = "<"
				backButton.TextSize = 18
				backButton.TextColor3 = Color3.fromRGB(150, 158, 174)
				backButton.ZIndex = sectionHeader.ZIndex + 1
				local sectionIcon = sectionHeader:FindFirstChild("SectionIcon")

				if sectionIcon and sectionIcon:IsA("GuiObject") then
					sectionIcon.Position = UDim2.fromOffset(34, 3)
				end

				local sectionTitle = sectionHeader:FindFirstChild("SectionTitle")

				if sectionTitle and sectionTitle:IsA("TextLabel") then
					sectionTitle.Position = UDim2.fromOffset(68, 0)
					sectionTitle.Size = UDim2.new(1, -160, 0, 30)
					sectionTitle.Text = text
					configureTextObject(sectionTitle, 21, 10)
				end

				local viewAllButton = sectionHeader:FindFirstChild("ViewAllButton")

				if viewAllButton and viewAllButton:IsA("GuiObject") then
					viewAllButton.Visible = false
				end

				table.insert(connections, backButton.Activated:Connect(function()
					state2.communitySectionView = nil
					v11 = 1
					cardGrid.CanvasPosition = Vector2.zero
					fn()
				end))
			end

			function state2.configureStandardListHeader()
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if not (sectionHeader and sectionHeader:IsA("GuiObject")) then
					return false
				end

				local visible = selectedMode ~= "Favorites"
				sectionHeader.Visible = visible
				local backButton = sectionHeader:FindFirstChild("BackButton")

				if backButton and backButton:IsA("GuiObject") then
					backButton.Visible = false
					backButton.Active = false
				end

				local sectionIcon = sectionHeader:FindFirstChild("SectionIcon")

				if sectionIcon and sectionIcon:IsA("GuiObject") then
					sectionIcon.Visible = false
				end

				local sectionTitle = sectionHeader:FindFirstChild("SectionTitle")

				if sectionTitle and sectionTitle:IsA("TextLabel") then
					sectionTitle.Position = UDim2.fromOffset(0, 0)
					sectionTitle.Size = UDim2.new(1, -100, 0, 30)
					sectionTitle.Text = getModeConfig().Title -- inferred equivalent call
				end

				local viewAllButton = sectionHeader:FindFirstChild("ViewAllButton")

				if viewAllButton and viewAllButton:IsA("GuiObject") then
					viewAllButton.Visible = false
					viewAllButton.Active = false
				end

				return visible
			end

			function state2.renderCommunitySectionDetail()
				state2.setProfileVisible(false)
				clearCards()

				if gridLayout.Parent ~= cardGrid then
					gridLayout.Parent = cardGrid
				end

				pagination.Visible = false
				local communitySectionView = state2.communitySectionView or {
					Id = "Trending",
					Title = "Trending Now"
				}
				state2.configureCommunitySectionHeader(communitySectionView.Title)
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if sectionHeader and sectionHeader:IsA("GuiObject") then
					local v46 = toolbar.Size.Y.Offset > 50
					local v47 = sectionHeader.Position.Y.Offset + (v46 and 56 or 62)
					cardGrid.Position = UDim2.fromOffset(0, v47)
					cardGrid.Size = UDim2.new(1, 0, 1, -(v47 + 8))
					v14 = math.max(
						1,
						(math.floor((math.max(180, content.AbsoluteSize.Y - v47 - 8) + v16) / (v15 + v16)))
					)
					v12 = math.max(1, v13 * v14)
				end

				local communitySectionSongs = state2.getCommunitySectionSongs(communitySectionView.Id, #v10)
				local count = #communitySectionSongs
				local searchText = tostring(state2.searchText or search.Text or "")
				local joined = table.concat({
					tostring(selectedMode),
					tostring(selectedDifficulty),
					tostring(state2.sortMode or ""),
					searchText,
					(tostring(communitySectionView.Id or ""))
				}, "|")
				state2.sectionDetailRenderLimits = state2.sectionDetailRenderLimits or {}
				local v46 = math.max(24, v12)
				local v47 = tonumber(state2.sectionDetailRenderLimits[joined])

				if state2.sectionDetailScrollKey ~= joined or not v47 then
					if state2.sectionDetailScrollKey ~= joined then
						cardGrid.CanvasPosition = Vector2.zero
					end

					v47 = v46
				end

				if state2.sectionDetailGrowAfterCatalogLoad == joined then
					v47 = math.max(v47, (math.min(count, v47 + 24)))
					state2.sectionDetailGrowAfterCatalogLoad = nil
				end

				local v48 = count > 0 and math.clamp(math.floor(v47), 1, count) or 0
				state2.sectionDetailRenderLimits[joined] = v48 > 0 and v48 or v46
				state2.sectionDetailScrollKey = joined
				state2.sectionDetailTotal = count
				v11 = 1
				state2.currentTotalPages = 1

				if count == 0 and state2.isCurrentCatalogLoading() then
					emptyLabel.Position = cardGrid.Position
					emptyLabel.Size = cardGrid.Size
					emptyLabel.Visible = true
					state2.startLoadingTextAnimation(emptyLabel, false)
				else
					state2.stopLoadingTextAnimation()
					emptyLabel.Position = cardGrid.Position
					emptyLabel.Size = cardGrid.Size
					emptyLabel.Visible = count == 0

					if count == 0 then
						local v49

						if selectedMode == "MIDI" then
							v49 = v22 ~= nil
						else
							v49 = v19 ~= nil
						end

						setInlineMessage(getEmptyText(), v49)
					else
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)
					end

					for i = 1, v48 do
						local communitySectionSong = communitySectionSongs[i]
						local songCard = cardTemplate:Clone()
						songCard.Name = "SongCard"
						songCard.Parent = cardGrid
						fillCard(songCard, communitySectionSong, i)
						state2.motion.AttachCard(songCard, i, root)
					end

					pageLabel.Text = ""
					setPagerButton(prev, false)
					setPagerButton(nextNode, false)
					local midiCatalogTotal = selectedMode == "MIDI" and state2.midiCatalogTotal
						or state2.sheetCatalogTotal
					local v49

					if selectedMode == "MIDI" then
						v49 = count == 1 and "MIDI" or "MIDI files"
					else
						v49 = count == 1 and "sheet" or "sheets"
					end

					if v48 < count then
						countLabel.Text = string.format("%s of %s %s", comma(v48), comma(count), v49)
					elseif count < midiCatalogTotal then
						countLabel.Text = string.format(
							"%s of %s %s loaded",
							comma(count),
							comma(midiCatalogTotal),
							v49
						)
					else
						countLabel.Text = string.format("%s %s", comma(count), v49)
					end
				end
			end

			function state2.renderCommunityHome()
				state2.setProfileVisible(false)
				state2.currentTotalPages = 1
				local sectionHeader = content:FindFirstChild("SectionHeader")
				local offset = cardGrid.Position.Y.Offset

				if sectionHeader and sectionHeader:IsA("GuiObject") then
					sectionHeader.Visible = false
					offset = sectionHeader.Position.Y.Offset
				end

				cardGrid.Position = UDim2.fromOffset(0, offset)
				cardGrid.Size = UDim2.new(1, 0, 1, -(offset + 8))
				v14 = math.max(
					1,
					(math.floor((math.max(180, content.AbsoluteSize.Y - offset - 8) + v16) / (v15 + v16)))
				)
				v12 = math.max(1, v13 * v14)
				clearCards()
				gridLayout.Parent = nil
				pagination.Visible = false
				local count = #v10

				if count == 0 and state2.isCurrentCatalogLoading() then
					emptyLabel.Position = cardGrid.Position
					emptyLabel.Size = cardGrid.Size
					emptyLabel.Visible = true
					state2.startLoadingTextAnimation(emptyLabel, false)
				else
					state2.stopLoadingTextAnimation()
					emptyLabel.Position = cardGrid.Position
					emptyLabel.Size = cardGrid.Size
					emptyLabel.Visible = count == 0

					if count == 0 then
						local v46

						if selectedMode == "MIDI" then
							v46 = v22 ~= nil
						else
							v46 = v19 ~= nil
						end

						setInlineMessage(getEmptyText(), v46)
					else
						emptyLabel.Visible = false

						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

						cardGrid.CanvasPosition = Vector2.new(0, 0)
						local communityHome = Instance.new("Frame")
						communityHome.Name = "CommunityHome"
						communityHome.BackgroundTransparency = 1
						communityHome.BorderSizePixel = 0
						communityHome.Position = UDim2.fromOffset(0, 0)
						communityHome.Size = UDim2.new(1, 0, 0, 1)
						communityHome.Parent = cardGrid
						local v46 = math.max(1, (math.min(v13, 5, count)))

						local communityHomeSection = state2.renderCommunityHomeSection(
							communityHome,
							"Trending Now",
							"Trending",
							0,
							v46
						)
						local communityHomeSection2 = state2.renderCommunityHomeSection(
							communityHome,
							"Newly Uploaded",
							"Newest",
							communityHomeSection,
							v46
						)
						local communityHomeSection3 = state2.renderCommunityHomeSection(
							communityHome,
							"Top All Time",
							"TopAllTime",
							communityHomeSection2,
							v46
						)
						communityHome.Size = UDim2.new(1, 0, 0, (math.max(1, communityHomeSection3)))
						local v47

						if selectedMode == "MIDI" then
							v47 = count == 1 and "MIDI" or "MIDI files"
						else
							v47 = count == 1 and "sheet" or "sheets"
						end

						countLabel.Text = string.format("%s %s", comma(count), v47)
					end
				end
			end

			function state2.updateMobileDifficultyVisuals(p)
				state2.mobileSupport.UpdateDifficulty({
					state = state2,
					controls = controls,
					difficultyOrder = difficultyOrder,
					selectedDifficulty = selectedDifficulty,
					configureTextObject = configureTextObject,
					animated = p == true,
					getVisual = function(p2)
						return state2.getDifficultyFilterVisual(p2)
					end
				})
			end

			function state2.updateMobileNavVisuals()
				state2.mobileSupport.UpdateNav({
					state = state2,
					controls = controls,
					modeConfigs = modeConfigs,
					selectedMode = selectedMode,
					canViewReports = canViewReports(), -- inferred equivalent call
					canViewHiddenUploads = canViewHiddenUploads(), -- inferred equivalent call
					canBlockCommunityUploads = v30 == true,
					configureTextObject = configureTextObject
				})
			end

			function state2.applyMobileCardLayout(p)
				state2.mobileSupport.ApplyCardLayout({ cardWidth = cardWidth }, p)
			end

			function state2.renderMobileCards()
				local canvasPosition = controls.CardGrid.CanvasPosition
				state2.mobileScrollPositions = state2.mobileScrollPositions or {}

				if state2.mobileActiveScrollKey then
					state2.mobileScrollPositions[state2.mobileActiveScrollKey] = canvasPosition
				end

				state2.setProfileVisible(false)
				clearCards()
				state2.updateMobileNavVisuals()
				local modeConfig = getModeConfig() -- inferred equivalent call
				controls.Title.Text = modeConfig.Title
				controls.SearchBox.PlaceholderText = selectedMode == "Blocked" and "Search blocked players..."
					or selectedMode == "Profile" and "Search profile uploads..."
					or "Search songs or creators..."
				local difficultyBar2 = controls.DifficultyBar
				difficultyBar2.Visible = selectedMode ~= "Blocked" and selectedMode ~= "Profile"
				state2.updateMobileDifficultyVisuals()
				controls.CardGrid.Visible = true
				controls.EmptyLabel.Visible = false
				controls.GridLayout.Parent = controls.CardGrid
				v16 = controls.GridLayout.CellPadding.X.Offset
				cardWidth = controls.GridLayout.CellSize.X.Offset
				v15 = controls.GridLayout.CellSize.Y.Offset
				v13 = math.max(1, (math.floor((controls.CardGrid.AbsoluteSize.X + v16) / math.max(1, cardWidth + v16))))
				v14 = math.max(1, (math.floor((controls.CardGrid.AbsoluteSize.Y + v16) / math.max(1, v15 + v16))))
				v12 = math.max(1, v13 * v14)
				local v47 = v10
				local count = #v47
				local id = state2.communitySectionView and tostring(state2.communitySectionView.Id or "") or ""
				local searchText = tostring(state2.searchText or controls.SearchBox.Text or search.Text or "")
				local joined = table.concat({
					tostring(selectedMode),
					tostring(selectedDifficulty),
					tostring(state2.sortMode or ""),
					searchText,
					id
				}, "|")
				local mobileScrollPosition = state2.mobileScrollPositions[joined]
				local v48 = mobileScrollPosition or canvasPosition
				local v49

				if mobileScrollPosition == nil then
					v49 = state2.mobileCardScrollWasVisible ~= true or state2.mobileCardScrollKey ~= joined
				else
					v49 = false
				end

				if
					selectedMode == "Community"
					or selectedMode == "MIDI"
					or selectedMode == "Reports"
					or selectedMode == "Hidden"
				then
					state2.mobileRenderLimits = state2.mobileRenderLimits or {}
					local v50 = math.max(48, v12)
					local v51 = tonumber(state2.mobileRenderLimits[joined])

					if v49 or not v51 then
						v51 = v50
					end

					local v52 = math.clamp(math.floor(v51), 1, (math.max(1, count)))
					state2.mobileRenderLimits[joined] = v52

					if v52 < count then
						v47 = {}

						for i = 1, v52 do
							v47[i] = v10[i]
						end
					end
				end

				state2.mobileCardScrollWasVisible = true
				state2.mobileCardScrollKey = joined
				state2.mobileActiveScrollKey = joined
				local function restoreMobileCardScroll() -- 1 equivalent call inferred from this helper
					if state2.mobileCardScrollKey ~= joined then
						return
					end

					local v50 = math.max(0, controls.CardGrid.AbsoluteCanvasSize.Y - controls.CardGrid.AbsoluteSize.Y)
					local v51 = v49 and 0 or math.clamp(v48.Y, 0, v50)
					controls.CardGrid.CanvasPosition = Vector2.new(0, v51)
				end
				local function applyMobileCardScroll() -- 2 equivalent calls inferred from this helper
					restoreMobileCardScroll() -- inferred equivalent call
					task.defer(restoreMobileCardScroll)
				end
				state2.currentTotalPages = 1
				v11 = 1

				if selectedMode ~= "Profile" then
					state2.mobileProfileWasVisible = false
					state2.mobileProfileScrollKey = nil
				end

				if selectedMode == "Profile" then
					local profileData

					if type(state2.profileData) == "table" then
						profileData = state2.profileData or nil
					else
						profileData = nil
					end

					if profileData then
						local publicSheets = type(profileData.PublicSheets) == "table" and profileData.PublicSheets
							or {}
						local publicMidi = type(profileData.PublicMidi) == "table" and profileData.PublicMidi or {}
						local favorites = profileData.CanViewFavorites == true
							and type(profileData.Favorites) == "table"
							and profileData.Favorites
							or {}
						local profileTab = state2.profileTab or "Sheets"
						local v50 = profileTab == "Favorites" and profileData.CanViewFavorites ~= true and "Sheets"
							or profileTab ~= "Midi" and profileTab ~= "Favorites" and profileTab ~= "About" and "Sheets"
							or profileTab

						state2.profileTab = v50
						local joined2 = table.concat({
							"Profile",
							tostring(profileData.UserId or 0),
							v50,
							searchText
						}, "|")
						local mobileScrollPosition2 = state2.mobileScrollPositions[joined2]
						local resetScroll

						if mobileScrollPosition2 == nil then
							resetScroll = state2.mobileProfileWasVisible ~= true
								or state2.mobileProfileScrollKey ~= joined2
						else
							resetScroll = false
						end

						state2.mobileProfileWasVisible = true
						state2.mobileProfileScrollKey = joined2
						state2.mobileActiveScrollKey = joined2
						local entries = {}
						local function addProfileEntry(upload, mode, tab)
							local profilePreviewSong = state2.buildProfilePreviewSong(upload, mode, profileData)

							if matchesSong(profilePreviewSong) then
								table.insert(entries, {
									Upload = upload,
									Mode = mode,
									Tab = tab,
									Song = profilePreviewSong
								})
							end
						end

						if v50 == "Sheets" then
							for _, publicSheet in ipairs(publicSheets) do
								addProfileEntry(publicSheet, "SHEET", "Sheets")
							end
						elseif v50 == "Midi" then
							for _, v54 in ipairs(publicMidi) do
								addProfileEntry(v54, "MIDI", "Midi")
							end
						elseif v50 == "Favorites" then
							for _, favorite in ipairs(favorites) do
								addProfileEntry(
									favorite,
									tostring(favorite.Kind or "") == "Midi" and "MIDI" or "SHEET",
									"Favorites"
								)
							end
						end

						state2.mobileSupport.RenderProfile({
							state = state2,
							controls = controls,
							profileData = profileData,
							selectedTab = v50,
							entries = entries,
							previousCanvas = mobileScrollPosition2 or canvasPosition,
							resetScroll = resetScroll,
							counts = {
								Sheets = #publicSheets,
								Midi = #publicMidi,
								Favorites = #favorites
							},
							localUserId = LocalPlayer.UserId,
							configureTextObject = configureTextObject,
							profileAssetImage = function(p)
								return state2.profileAssetImage(p)
							end,
							profileStrokeColor = function(p)
								return state2.profileStrokeColor(p)
							end,
							comma = comma,
							formatUploadDate = formatUploadDate,
							buildPreviewSong = function(p, p2)
								return state2.buildProfilePreviewSong(p, p2, profileData)
							end,
							openPreview = function(p)
								state2.openPreviewOverlay(p)
							end,
							openFavorite = function(p)
								state2.openProfileFavorite(p)
							end,
							republish = function(p)
								state2.republishProfileMidiUpload(p)
							end,
							openSupport = function()
								state2.openSupportCreatorOverlay(profileData)
							end,
							toggleThumb = function()
								state2.toggleProfileThumb()
							end,
							setProfileTab = function(p)
								state2.setProfileTab(p, true)
								state2.renderMobileCards()
							end,
							setInlineMessage = setInlineMessage
						}, profileData)
					else
						state2.mobileSupport.ClearProfile(controls)
						controls.CardGrid.Visible = false
						controls.EmptyLabel.Text = "Loading profile..."
						controls.EmptyLabel.Visible = true
						controls.CountLabel.Text = ""
					end
				elseif selectedMode == "Blocked" then
					local filteredBlockedUploaders = state2.getFilteredBlockedUploaders()
					local count2 = #filteredBlockedUploaders
					controls.EmptyLabel.Text = state2.blockedLoading and "Loading blocked uploaders..."
						or state2.blockedMessage
						or modeConfig.Empty
					controls.EmptyLabel.Visible = count2 == 0
					controls.CardGrid.Visible = count2 > 0

					if count2 == 0 then
						controls.CountLabel.Text = state2.blockedLoading and "Loading" or "0 blocked"
						return
					end

					for i, filteredBlockedUploader in ipairs(filteredBlockedUploaders) do
						state2.mobileSupport.CreateBlockedCard({
							state = state2,
							controls = controls,
							configureTextObject = configureTextObject,
							cardConnections = connections,
							unblock = function(p)
								state2.unblockCommunityUploader(p)
							end
						}, filteredBlockedUploader, i)
					end

					applyMobileCardScroll() -- inferred equivalent call
					controls.CountLabel.Text = string.format("%s blocked", comma(count2))
				elseif count == 0 and state2.isCurrentCatalogLoading() then
					controls.CardGrid.Visible = false
					controls.EmptyLabel.Visible = true
					state2.startLoadingTextAnimation(controls.EmptyLabel, false)
					controls.CountLabel.Text = "Loading"
				else
					state2.stopLoadingTextAnimation()
					controls.EmptyLabel.Text = getEmptyText()
					controls.EmptyLabel.Visible = count == 0

					if count == 0 then
						local v50 = selectedMode == "MIDI" and v22 ~= nil or v19 ~= nil
						setInlineMessage(getEmptyText(), v50)
					else
						if state2.stopLoadingTextAnimation then
							state2.stopLoadingTextAnimation()
						end

						emptyLabel.Text = tostring("")
						emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)
					end

					for i, v50 in ipairs(v47) do
						local songCard = cardTemplate:Clone()
						songCard.Name = "SongCard"
						songCard.Parent = controls.CardGrid
						fillCard(songCard, v50, i)
						state2.motion.AttachCard(songCard, i, root)
						state2.applyMobileCardLayout(songCard)
					end

					applyMobileCardScroll() -- inferred equivalent call
					local v50

					if selectedMode == "Reports" then
						v50 = count == 1 and "report" or "reports"
					elseif selectedMode == "Hidden" then
						v50 = "hidden"
					elseif selectedMode == "MIDI" then
						v50 = count == 1 and "MIDI" or "MIDI files"
					else
						v50 = count == 1 and "sheet" or "sheets"
					end

					if #v47 < count then
						controls.CountLabel.Text = string.format("%s of %s %s", comma(#v47), comma(count), v50)
					else
						controls.CountLabel.Text = string.format("%s %s", comma(count), v50)
					end
				end
			end

			function state2.getFilteredBlockedUploaders()
				local v46 = normalize(state2.searchText or search.Text) -- inferred equivalent call
				local blockedUploaders = {}

				for _, blockedUploader in ipairs(state2.blockedUploaders) do
					local v47 = normalize(table.concat({ -- inferred equivalent call
						tostring(blockedUploader.Name or ""),
						tostring(blockedUploader.DisplayName or ""),
						tostring(blockedUploader.UserId or ""),
						(tostring(blockedUploader.Reason or ""))
					}, " "))

					if v46 == "" or v47:find(v46, 1, true) then
						table.insert(blockedUploaders, blockedUploader)
					end
				end

				table.sort(blockedUploaders, function(a, b): boolean
					return (tonumber(a.BlockedAt) or 0) > (tonumber(b.BlockedAt) or 0)
				end)

				return blockedUploaders
			end

			function state2.unblockCommunityUploader(player)
				local userId = math.floor(tonumber(player and player.UserId) or 0)

				if userId <= 0 then
					return
				end

				state2.unblockingUserIds = state2.unblockingUserIds or {}

				if state2.unblockingUserIds[userId] then
					return
				end

				state2.unblockingUserIds[userId] = true
				pageSubtitle.Text = "Unblocking " .. tostring(player.DisplayName ~= "" and player.DisplayName or player.Name or userId) .. "..."
				task.spawn(function()
					local success, result = pcall(function()
						return remotes:WaitForChild("UnblockCommunityUploader"):InvokeServer(userId)
					end)

					state2.unblockingUserIds[userId] = nil

					if success and type(result) == "table" and result.Ok == true then
						state2.blockedUploaders = type(result.BlockedUploaders) == "table"
							and result.BlockedUploaders
							or {}
						state2.blockedMessage = tostring(result.Message or "Uploader unblocked.")
					else
						state2.blockedMessage = type(result) == "table" and result.Error
							or "Could not unblock this uploader."
					end

					pageSubtitle.Text = state2.blockedMessage

					if selectedMode == "Blocked" then
						if state2.mobileLandscapeActive then
							state2.renderMobileCards()
						else
							state2.renderBlockedUploaders()
						end
					end
				end)
			end

			function state2.createBlockedUploaderCard(player, layoutOrder)
				local blockedUserCard = Instance.new("Frame")
				blockedUserCard.Name = "BlockedUserCard"
				blockedUserCard.LayoutOrder = layoutOrder
				blockedUserCard.BackgroundColor3 = Color3.fromRGB(27, 30, 39)
				blockedUserCard.BorderSizePixel = 0
				blockedUserCard.Parent = cardGrid
				local uiCorner = Instance.new("UICorner")
				uiCorner.CornerRadius = UDim.new(0, 12)
				uiCorner.Parent = blockedUserCard
				local uiStroke = Instance.new("UIStroke")
				uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke.Color = Color3.fromRGB(235, 93, 130)
				uiStroke.Transparency = 0.55
				uiStroke.Thickness = 1
				uiStroke.Parent = blockedUserCard

				local userId = math.floor(tonumber(player.UserId) or 0)
				local image = tostring(player.AvatarImage or "")

				if image == "" and userId > 0 then
					image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
				end

				local avatar = Instance.new("ImageLabel")
				avatar.Name = "Avatar"
				avatar.Position = UDim2.fromOffset(18, 16)
				avatar.Size = UDim2.fromOffset(52, 52)
				avatar.BackgroundColor3 = Color3.fromRGB(18, 21, 29)
				avatar.BorderSizePixel = 0
				avatar.Image = image
				avatar.ScaleType = Enum.ScaleType.Crop
				avatar.Parent = blockedUserCard
				local uiCorner2 = Instance.new("UICorner")
				uiCorner2.CornerRadius = UDim.new(1, 0)
				uiCorner2.Parent = avatar
				local uiStroke2 = Instance.new("UIStroke")
				uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke2.Color = Color3.fromRGB(57, 63, 78)
				uiStroke2.Transparency = 0.25
				uiStroke2.Parent = avatar

				local displayName = Instance.new("TextLabel")
				displayName.Name = "DisplayName"
				displayName.Position = UDim2.fromOffset(84, 16)
				displayName.Size = UDim2.new(1, -102, 0, 26)
				displayName.BackgroundTransparency = 1
				displayName.Font = Enum.Font.GothamSemibold
				displayName.TextColor3 = Color3.fromRGB(242, 244, 250)
				displayName.TextXAlignment = Enum.TextXAlignment.Left
				local text = tostring(player.DisplayName or "")

				if text == "" then
					text = tostring(player.Name or "")
				end

				if text == "" then
					text = "User " .. tostring(player.UserId or 0)
				end

				displayName.Text = text
				displayName.Parent = blockedUserCard
				configureTextObject(displayName, 17, 10)

				local handle = Instance.new("TextLabel")
				handle.Name = "Handle"
				handle.Position = UDim2.fromOffset(84, 44)
				handle.Size = UDim2.new(1, -102, 0, 20)
				handle.BackgroundTransparency = 1
				handle.Font = Enum.Font.Gotham
				handle.TextColor3 = Color3.fromRGB(145, 154, 174)
				handle.TextXAlignment = Enum.TextXAlignment.Left
				local name = tostring(player.Name or "")
				local v48 = name == "" and "Unknown" or name

				handle.Text = string.format("@%s  |  User ID %s", v48, (tostring(player.UserId or 0)))
				handle.Parent = blockedUserCard
				configureTextObject(handle, 11, 8)

				local reason = Instance.new("TextLabel")
				reason.Name = "Reason"
				reason.Position = UDim2.fromOffset(18, 82)
				reason.Size = UDim2.new(1, -36, 0, 44)
				reason.BackgroundTransparency = 1
				reason.Font = Enum.Font.Gotham
				reason.TextColor3 = Color3.fromRGB(190, 196, 210)
				reason.TextXAlignment = Enum.TextXAlignment.Left
				reason.TextYAlignment = Enum.TextYAlignment.Top
				reason.TextWrapped = true
				reason.Text = "Reason: " .. tostring(player.Reason == "" and "No reason saved." or player.Reason or "No reason saved.")
				reason.Parent = blockedUserCard
				configureTextObject(reason, 12, 8)

				local moderator = Instance.new("TextLabel")
				moderator.Name = "Moderator"
				moderator.Position = UDim2.new(0, 18, 1, -48)
				moderator.Size = UDim2.new(1, -150, 0, 30)
				moderator.BackgroundTransparency = 1
				moderator.Font = Enum.Font.Gotham
				moderator.TextColor3 = Color3.fromRGB(132, 141, 160)
				moderator.TextXAlignment = Enum.TextXAlignment.Left
				moderator.Text = "Blocked by @" .. tostring(player.BlockedByName == "" and "Staff" or player.BlockedByName or "Staff")
				moderator.Parent = blockedUserCard
				configureTextObject(moderator, 10, 7)

				local unblockButton = Instance.new("TextButton")
				unblockButton.Name = "UnblockButton"
				unblockButton.AnchorPoint = Vector2.new(1, 1)
				unblockButton.Position = UDim2.new(1, -16, 1, -14)
				unblockButton.Size = UDim2.fromOffset(112, 36)
				unblockButton.BackgroundColor3 = Color3.fromRGB(34, 91, 78)
				unblockButton.BorderSizePixel = 0
				unblockButton.AutoButtonColor = true
				unblockButton.Font = Enum.Font.GothamBold
				unblockButton.TextColor3 = Color3.fromRGB(121, 255, 207)
				unblockButton.Text = state2.unblockingUserIds
					and state2.unblockingUserIds[player.UserId]
					and "WORKING..."
					or "UNBLOCK"
				unblockButton.Parent = blockedUserCard
				local uiCorner3 = Instance.new("UICorner")
				uiCorner3.CornerRadius = UDim.new(0, 9)
				uiCorner3.Parent = unblockButton
				local uiStroke3 = Instance.new("UIStroke")
				uiStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				uiStroke3.Color = Color3.fromRGB(52, 211, 153)
				uiStroke3.Transparency = 0.35
				uiStroke3.Parent = unblockButton
				configureTextObject(unblockButton, 11, 8)
				unblockButton.Activated:Connect(function()
					state2.unblockCommunityUploader(player)
				end)
			end

			function state2.renderBlockedUploaders()
				state2.setProfileVisible(false)
				clearCards()

				if gridLayout.Parent ~= cardGrid then
					gridLayout.Parent = cardGrid
				end

				pagination.Visible = true
				state2.configureStandardListHeader()
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if sectionHeader and sectionHeader:IsA("GuiObject") then
					local v46 = toolbar.Size.Y.Offset > 50
					local v47 = sectionHeader.Position.Y.Offset + (v46 and 56 or 62)
					cardGrid.Position = UDim2.fromOffset(0, v47)
					cardGrid.Size = UDim2.new(1, 0, 1, -(v47 + 58))
				end

				local filteredBlockedUploaders = state2.getFilteredBlockedUploaders()
				local count = #filteredBlockedUploaders
				local currentTotalPages = math.max(1, (math.ceil(count / math.max(1, v12))))
				v11 = math.clamp(v11, 1, currentTotalPages)
				state2.currentTotalPages = currentTotalPages
				local v47 = (v11 - 1) * v12 + 1

				for i = v47, math.min(count, v47 + v12 - 1) do
					state2.createBlockedUploaderCard(filteredBlockedUploaders[i], i)
				end

				emptyLabel.Position = cardGrid.Position
				emptyLabel.Size = cardGrid.Size
				emptyLabel.Visible = count == 0

				if count == 0 then
					local text = state2.blockedLoading and "Loading blocked uploaders..."
						or state2.blockedMessage
						or modeConfigs.Blocked.Empty
					emptyLabel.Text = text
					setInlineMessage(text, state2.blockedMessage ~= nil and not state2.blockedLoading)
				else
					emptyLabel.Text = ""

					if state2.stopLoadingTextAnimation then
						state2.stopLoadingTextAnimation()
					end

					emptyLabel.Text = tostring("")
					emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)
				end

				countLabel.Text = string.format("%s blocked %s", comma(count), count == 1 and "player" or "players")
				pageLabel.Text = string.format("Page %d of %d", v11, currentTotalPages)
				setPagerButton(prev, v11 > 1)
				setPagerButton(nextNode, v11 < currentTotalPages)
			end

			function state2.refreshBlockedUploaders()
				if state2.blockedLoading then
					return
				end

				state2.blockedLoading = true
				state2.blockedMessage = nil
				local refreshController = state2.refreshController

				if refreshController and type(refreshController.Begin) == "function" then
					refreshController:Begin("Blocked")
				end

				if state2.mobileLandscapeActive then
					state2.renderMobileCards()
				else
					state2.renderBlockedUploaders()
				end

				task.spawn(function()
					local success, result = pcall(function()
						return remotes:WaitForChild("GetBlockedCommunityUploaders"):InvokeServer()
					end)

					state2.blockedLoading = false

					if success and type(result) == "table" and result.Ok == true then
						state2.blockedUploaders = type(result.BlockedUploaders) == "table"
							and result.BlockedUploaders
							or {}
						state2.blockedMessage = nil
						local refreshController2 = state2.refreshController

						if refreshController2 and type(refreshController2.MarkLoaded) == "function" then
							refreshController2:MarkLoaded("Blocked")
						end
					else
						state2.blockedUploaders = {}
						state2.blockedMessage = type(result) == "table" and result.Error
							or "Could not load blocked uploaders."
					end

					local refreshController2 = state2.refreshController

					if refreshController2 and type(refreshController2.Finish) == "function" then
						refreshController2:Finish("Blocked")
					end

					if selectedMode == "Blocked" then
						if state2.mobileLandscapeActive then
							state2.renderMobileCards()
						else
							state2.renderBlockedUploaders()
						end
					end
				end)
			end

			fn = function()
				if state2.mobileLandscapeActive then
					state2.renderMobileCards()
				elseif selectedMode == "Blocked" then
					state2.renderBlockedUploaders()
				elseif selectedMode == "Profile" then
					state2.setProfileVisible(true)
				elseif
					(selectedMode == "Community" or selectedMode == "MIDI")
					and state2.sortMode == "Default"
					and not state2.isPublicCatalogSearchActive()
				then
					if state2.communitySectionView then
						state2.renderCommunitySectionDetail()
					else
						state2.renderCommunityHome()
					end
				else
					state2.setProfileVisible(false)
					local sectionHeader = content:FindFirstChild("SectionHeader")

					if sectionHeader and sectionHeader:IsA("GuiObject") then
						local v46 = state2.configureStandardListHeader()
						local v47 = toolbar.Size.Y.Offset > 50
						local v48 = sectionHeader.Position.Y.Offset
						v48 = v46 and v48 + (v47 and 56 or 62) or v48
						cardGrid.Position = UDim2.fromOffset(0, v48)
						cardGrid.Size = UDim2.new(1, 0, 1, -(v48 + 58))
						v14 = math.max(
							1,
							(math.floor((math.max(180, content.AbsoluteSize.Y - v48 - 58) + v16) / (v15 + v16)))
						)
						v12 = math.max(1, v13 * v14)
					end

					clearCards()

					if gridLayout.Parent ~= cardGrid then
						gridLayout.Parent = cardGrid
					end

					pagination.Visible = true
					local count = #v10
					local currentTotalPages = math.max(1, (math.ceil(count / math.max(1, v12))))
					v11 = math.clamp(v11, 1, currentTotalPages)
					state2.currentTotalPages = currentTotalPages
					local v47 = (v11 - 1) * v12 + 1
					local v48 = math.min(count, v47 + v12 - 1)

					if count == 0 and state2.isCurrentCatalogLoading() then
						emptyLabel.Position = cardGrid.Position
						emptyLabel.Size = cardGrid.Size
						emptyLabel.Visible = true
						state2.startLoadingTextAnimation(emptyLabel, false)
					else
						state2.stopLoadingTextAnimation()

						emptyLabel.Position = cardGrid.Position
						emptyLabel.Size = cardGrid.Size
						emptyLabel.Visible = count == 0

						if count == 0 then
							setInlineMessage(getEmptyText(), v19 ~= nil or v22 ~= nil)
						end

						for i = v47, v48 do
							local v49 = v10[i]
							local songCard = cardTemplate:Clone()
							songCard.Name = "SongCard"
							songCard.Parent = cardGrid
							fillCard(songCard, v49, i - v47 + 1)
							state2.motion.AttachCard(songCard, i - v47 + 1, root)
						end

						pageLabel.Text = string.format("Page %d of %d", v11, currentTotalPages)
						local v49

						if selectedMode == "Reports" then
							v49 = count == 1 and "reported upload" or "reported uploads"
						elseif selectedMode == "Hidden" then
							v49 = count == 1 and "hidden upload" or "hidden uploads"
						elseif selectedMode == "MIDI" then
							v49 = count == 1 and "MIDI" or "MIDI files"
						else
							v49 = count == 1 and "sheet" or "sheets"
						end

						countLabel.Text = string.format("%s %s", comma(count), v49)
						setPagerButton(prev, v11 > 1)
						setPagerButton(nextNode, v11 < currentTotalPages or state2.currentModeHasMore())
					end
				end
			end
		end

		fn2 = function(p)
			if p then
				v11 = 1
			end

			if selectedMode == "Blocked" then
				state2.renderBlockedUploaders()
				return
			end

			table.clear(v10)

			for _, v46 in ipairs(getModeSongs()) do
				if matchesSong(v46) then
					table.insert(v10, v46)
				end
			end

			sortFilteredSongs()

			if state2.advancePageAfterCatalogLoad then
				state2.advancePageAfterCatalogLoad = false
				local v46 = math.max(1, (math.ceil(#v10 / math.max(1, v12))))

				if v11 < v46 then
					v11 += 1
				end
			end

			fn()
		end

		do
			local CommunityRefreshController = require(parent:WaitForChild("CommunityRefreshController"))
			state2.refreshController = CommunityRefreshController.new({
				Button = state2.refreshButton,
				CooldownSeconds = 5,
				StaleSeconds = 25,
				RefreshSheets = function()
					fn3()
				end,
				RefreshMidi = function()
					fn5()
				end,
				RefreshBlocked = function()
					state2.refreshBlockedUploaders()
				end
			})
		end

		function state2.runServerCatalogSearch(p, searchQuery, p2)
			if p2 ~= state2.catalogSearchToken or not root.Visible or p ~= "Community" and p ~= "MIDI" then
				return
			end

			if selectedMode ~= p or state2.getServerSearchQuery() ~= searchQuery then
				return
			end

			local v46 = p == "MIDI"

			if v46 then
				v21 = true
				v22 = nil
			else
				v18 = true
				v19 = nil
			end

			fn2(false)

			local v47 = { Reset = true, PageSize = 30, SearchQuery = searchQuery }
			local success, result, v48, v49 = pcall(function()
				if v46 then
					return getCommunityMidi:InvokeServer(v47)
				end

				return getCommunitySheets:InvokeServer(v47)
			end)

			if p2 == state2.catalogSearchToken then
				state2.catalogSearchLoadingToken = nil

				if v46 then
					v21 = false

					if success and result and type(v49) == "table" then
						fn6(v49, true)
						v22 = nil
					elseif success then
						v22 = tostring(v48 or "Could not search community MIDI.")
					else
						v22 = "Could not search community MIDI."
						v2.Warn("[CommunitySheetsGui] GetCommunityMidi search failed:", result)
					end
				else
					v18 = false

					if success and result and type(v49) == "table" then
						fn4(v49, true)
						v19 = nil
					elseif success then
						v19 = tostring(v48 or "Could not search community sheets.")
					else
						v19 = "Could not search community sheets."
						v2.Warn("[CommunitySheetsGui] GetCommunitySheets search failed:", result)
					end
				end

				if selectedMode == p then
					fn2(false)
				end
			elseif state2.catalogSearchLoadingToken == p2 then
				if v46 then
					v21 = false
				else
					v18 = false
				end
			end
		end

		function state2.scheduleServerCatalogSearch()
			state2.catalogSearchToken += 1
			local catalogSearchToken = state2.catalogSearchToken
			local v47 = selectedMode
			local serverSearchQuery = state2.getServerSearchQuery()

			if serverSearchQuery == "" or v47 ~= "Community" and v47 ~= "MIDI" then
				return
			end

			task.delay(state2.searchRequestDelay, function()
				if
					catalogSearchToken ~= state2.catalogSearchToken
					or selectedMode ~= v47
					or state2.getServerSearchQuery() ~= serverSearchQuery
				then
					return
				end

				state2.catalogSearchLoadingToken = catalogSearchToken
				state2.runServerCatalogSearch(v47, serverSearchQuery, catalogSearchToken)
			end)
		end

		function state2.stopMobileRefreshSpin()
			if state2.mobileRefreshSpinConnection then
				state2.mobileRefreshSpinConnection:Disconnect()
				state2.mobileRefreshSpinConnection = nil
			end

			local buttonIcon = controls.RefreshButton:FindFirstChild("ButtonIcon")

			if buttonIcon and buttonIcon:IsA("ImageLabel") then
				buttonIcon.Rotation = 0
			end
		end

		function state2.startMobileRefreshSpin()
			local iconButton = state2.mobileSupport.EnsureIconButton(controls.RefreshButton, "Refresh")

			if not iconButton then
				return
			end

			local lastTime = os.clock()

			if state2.mobileRefreshSpinConnection then
				return
			end

			state2.mobileRefreshSpinConnection = RunService.RenderStepped:Connect(function(dt)
				if not iconButton.Parent then
					state2.stopMobileRefreshSpin()
					return
				end

				iconButton.Rotation = (iconButton.Rotation + 720 * dt) % 360
				local refreshController = state2.refreshController
				local v46 = refreshController
					and refreshController.Active
					and (refreshController.Active.Sheets == true or refreshController.Active.Midi == true or refreshController.Active.Blocked == true)
					or state2.profileLoading == true

				if os.clock() - lastTime >= 0.45 and not v46 then
					state2.stopMobileRefreshSpin()
				end
			end)
		end

		function state2.applyCatalogEntries(list, p, callback, p2, callback2)
			if not p2 then
				table.clear(list)
			end

			local idSet = {}

			for _, item in ipairs(list) do
				idSet[tostring(item.id or "")] = true
			end

			for _, v46 in ipairs(type(p) == "table" and p or {}) do
				local v47 = callback(v46)
				local id = tostring(v47.id or "")

				if not (type(callback2) ~= "function" or callback2(v47)) or id == "" or idSet[id] then
					continue
				end

				idSet[id] = true
				table.insert(list, v47)
			end
		end

		do
			local function shouldShowInPublicCatalog(p): boolean
				return type(p) == "table" and p.isHidden ~= true and p.isDeleted ~= true
			end

			local function readUploadQuota(data)
				return {
					Mode = tostring(data.UploadQuotaMode or "Disabled"),
					Enabled = data.UploadQuotaEnabled == true,
					Limit = math.max(0, (math.floor(tonumber(data.UploadQuotaLimit) or 0))),
					Used = math.max(0, (math.floor(tonumber(data.UploadQuotaUsed) or 0))),
					Remaining = math.max(0, (math.floor(tonumber(data.UploadQuotaRemaining) or 0)))
				}
			end

			fn4 = function(p, p2)
				local v46 = type(p) == "table" and p or {}
				state2.applyCatalogEntries(
					v6,
					v46.Sheets,
					normalizeCommunitySong,
					p2 == true,
					shouldShowInPublicCatalog
				)

				if not p2 then
					table.clear(v8)

					for _, v47 in ipairs(type(v46.ModeratedSheets) == "table" and v46.ModeratedSheets or {}) do
						table.insert(v8, normalizeCommunitySong(v47))
					end
				end

				state2.sheetCatalogCursor = v46.NextCursor
				state2.sheetCatalogHasMore = v46.HasMore == true
					and type(v46.NextCursor) == "string"
					and v46.NextCursor ~= ""
				state2.sheetCatalogTotal = math.max(#v6, (math.floor(tonumber(v46.Count) or 0)))
				state2.sheetUploadQuota = readUploadQuota(v46)
				v17 = true
				state2.refreshController:MarkLoaded("Sheets")
				state2.communitySheetPublishCost = math.max(
					0,
					(math.floor(tonumber(v46.PublishCost) or state2.communitySheetPublishCost))
				)
				state2.communitySheetPublicMaxTextLength = math.max(
					1,
					(math.floor(tonumber(v46.PublicMaxTextLength) or state2.communitySheetPublicMaxTextLength or 10000))
				)
				v28 = v46.CanModerateCommunitySheets == true
				v30 = v46.CanBlockCommunityUploads == true
				updateNavVisuals()
			end

			fn6 = function(p, p2)
				local v46 = type(p) == "table" and p or {}
				state2.applyCatalogEntries(v7, v46.Midi, normalizeCommunityMidi, p2 == true, shouldShowInPublicCatalog)

				if not p2 then
					table.clear(v9)

					for _, v47 in ipairs(type(v46.ModeratedMidi) == "table" and v46.ModeratedMidi or {}) do
						table.insert(v9, normalizeCommunityMidi(v47))
					end
				end

				state2.midiCatalogCursor = v46.NextCursor
				state2.midiCatalogHasMore = v46.HasMore == true
					and type(v46.NextCursor) == "string"
					and v46.NextCursor ~= ""
				state2.midiCatalogTotal = math.max(#v7, (math.floor(tonumber(v46.Count) or 0)))
				state2.midiUploadQuota = readUploadQuota(v46)
				v20 = true
				state2.refreshController:MarkLoaded("Midi")
				v23 = math.max(0, (math.floor(tonumber(v46.PublishCost) or v23)))
				v24 = math.max(0, (math.floor(tonumber(v46.BackupMaxBytes) or v24)))
				v25 = math.max(1, (math.floor(tonumber(v46.TitleMaxLength) or v25)))
				v26 = math.max(1, (math.floor(tonumber(v46.UrlMaxLength) or v26)))
				v29 = v46.CanModerateCommunityMidi == true
				v31 = v46.CanBlockCommunityMidiUploads == true
				updateNavVisuals()
			end
		end

		fn3 = function(p)
			local v46 = p == true

			if
				v18
				or state2.sheetCatalogLoadingMore
				or v46 and (not state2.sheetCatalogHasMore or type(state2.sheetCatalogCursor) ~= "string")
			then
				return
			end

			if v46 then
				state2.sheetCatalogLoadingMore = true
			else
				v18 = true
				v19 = nil
				state2.sheetCatalogCursor = nil
				state2.sheetCatalogHasMore = false
				state2.refreshController:Begin("Sheets")

				if state2.refreshController:ModeUsesSheets(selectedMode) then
					fn2(false)
				end
			end

			local canvasPosition = cardGrid.CanvasPosition
			task.spawn(function()
				local v47 = v46 and { Cursor = state2.sheetCatalogCursor, PageSize = 24 }
					or { Reset = true, PageSize = 24 }

				if not v46 and selectedMode == "Community" then
					local serverSearchQuery = state2.getServerSearchQuery()

					if serverSearchQuery ~= "" then
						v47.SearchQuery = serverSearchQuery
						v47.PageSize = 30
					end
				end

				local success, result, v48, v49 = pcall(function()
					return getCommunitySheets:InvokeServer(v47)
				end)

				if v46 then
					state2.sheetCatalogLoadingMore = false
				else
					v18 = false
				end

				if success and result and type(v49) == "table" then
					fn4(v49, v46)
					v19 = nil
				elseif v46 or not success then
					if v46 then
						v2.Warn("[CommunitySheetsGui] Could not load more sheets:", v48 or result)
					else
						v19 = "Could not load community sheets."
						v2.Warn("[CommunitySheetsGui] GetCommunitySheets failed:", result)
					end
				else
					v19 = tostring(v48 or "Could not load community sheets.")
				end

				if not v46 then
					state2.refreshController:Finish("Sheets")
				end

				if state2.refreshController:ModeUsesSheets(selectedMode) then
					fn2(false)

					if v46 then
						task.defer(function()
							cardGrid.CanvasPosition = canvasPosition
						end)
					end
				end
			end)
		end

		fn5 = function(p)
			local v46 = p == true

			if
				v21
				or state2.midiCatalogLoadingMore
				or v46 and (not state2.midiCatalogHasMore or type(state2.midiCatalogCursor) ~= "string")
			then
				return
			end

			if v46 then
				state2.midiCatalogLoadingMore = true
			else
				v21 = true
				v22 = nil
				state2.midiCatalogCursor = nil
				state2.midiCatalogHasMore = false
				state2.refreshController:Begin("Midi")

				if state2.refreshController:ModeUsesMidi(selectedMode) then
					fn2(false)
				end
			end

			local canvasPosition = cardGrid.CanvasPosition
			task.spawn(function()
				local v47 = v46 and { Cursor = state2.midiCatalogCursor, PageSize = 24 }
					or { Reset = true, PageSize = 24 }

				if not v46 and selectedMode == "MIDI" then
					local serverSearchQuery = state2.getServerSearchQuery()

					if serverSearchQuery ~= "" then
						v47.SearchQuery = serverSearchQuery
						v47.PageSize = 30
					end
				end

				local success, result, v48, v49 = pcall(function()
					return getCommunityMidi:InvokeServer(v47)
				end)

				if v46 then
					state2.midiCatalogLoadingMore = false
				else
					v21 = false
				end

				if success and result and type(v49) == "table" then
					fn6(v49, v46)
					v22 = nil
				elseif v46 or not success then
					if v46 then
						v2.Warn("[CommunitySheetsGui] Could not load more MIDI:", v48 or result)
					else
						v22 = "Could not load community MIDI."
						v2.Warn("[CommunitySheetsGui] GetCommunityMidi failed:", result)
					end
				else
					v22 = tostring(v48 or "Could not load community MIDI.")
				end

				if not v46 then
					state2.refreshController:Finish("Midi")
				end

				if state2.refreshController:ModeUsesMidi(selectedMode) then
					fn2(false)

					if v46 then
						task.defer(function()
							cardGrid.CanvasPosition = canvasPosition
						end)
					end
				end
			end)
		end

		do
			local function OnInvoke(_)
				local lastTime = os.clock()

				while (v21 or state2.midiCatalogLoadingMore) and os.clock() - lastTime < 8 do
					task.wait(0.05)
				end

				if v21 or state2.midiCatalogLoadingMore then
					return false, "Community MIDI is still refreshing."
				end

				local success, result, v46, v47 = pcall(function()
					return getCommunityMidi:InvokeServer({ Reset = true, PageSize = 24 })
				end)

				if not success or not result or type(v47) ~= "table" then
					return false, (tostring(success and v46 or result or "Could not refresh Community MIDI."))
				end

				fn6(v47, false)
				v22 = nil

				if state2.refreshController:ModeUsesMidi(selectedMode) then
					fn2(false)
				end

				return true, "Community MIDI refreshed."
			end

			refreshCommunityMidiForLoadFunction.OnInvoke = OnInvoke
		end

		fn7 = function(p)
			local v46 = not modeConfigs[p] and "Community" or p

			selectedMode = v46
			state2.communitySectionView = nil
			state2.currentTotalPages = nil
			v11 = 1
			local modeConfig = getModeConfig() -- inferred equivalent call
			pageTitle.Text = modeConfig.Title
			pageSubtitle.Text = modeConfig.Subtitle
			local v47 = v46 == "Blocked"
			search.PlaceholderText = v47 and "Search blocked players..." or "Search songs or creators..."
			difficultyBar.Visible = not v47
			sortButton.Visible = not v47
			updateDifficultyVisuals(false)
			updateNavVisuals()
			state2.refreshController:SetMode(v46)
			state2.setProfileVisible(v46 == "Profile")

			if v46 == "Profile" then
				if state2.keepProfileTarget ~= true then
					state2.setProfileTarget(
						LocalPlayer.UserId,
						LocalPlayer.DisplayName ~= "" and LocalPlayer.DisplayName or LocalPlayer.Name,
						LocalPlayer.Name
					)
				end

				state2.keepProfileTarget = nil

				if state2.stopLoadingTextAnimation then
					state2.stopLoadingTextAnimation()
				end

				emptyLabel.Text = tostring("")
				emptyLabel.TextColor3 = Color3.fromRGB(145, 151, 164)

				state2.refreshProfile(state2.profileTargetUserId)
			else
				if v46 == "Blocked" then
					state2.refreshBlockedUploaders()
					return
				end

				local v48 = not v17 or state2.refreshController:IsStale("Sheets")
				local v49 = not v20 or state2.refreshController:IsStale("Midi")

				if (v46 == "Community" or v46 == "Trending") and v48 then
					fn3()
					return
				end

				if v46 == "MIDI" and v49 then
					fn5()
					return
				end

				if v46 ~= "Reports" and v46 ~= "Hidden" then
					fn2(true)

					return
				end

				if v48 then
					fn3()
				end

				if v49 then
					fn5()
				end

				fn2(true)
			end
		end

		local function setDifficultyFilter(childName)
			local v46 = childName == "All" and "All" or state2.getDifficultyDisplayLabel(childName)
			selectedDifficulty = table.find(difficultyOrder, v46) and v46 or "All"
			updateDifficultyVisuals(true)
			state2.updateMobileDifficultyVisuals(true)
			fn2(true)
		end

		do
			local function setBackpackHidden(p) -- 1 equivalent call inferred from this helper
				if p then
					if v40 == nil then
						local success, result = pcall(function()
							return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
						end)

						v40 = success and result == true
					end

					pcall(function()
						StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
					end)
				elseif v40 ~= nil then
					local v46 = v40
					v40 = nil
					pcall(function()
						StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, v46)
					end)
				end
			end
		end

		local function getTopbarPlusIcon()
			if v41 ~= nil then
				return v41
			end

			local services = ReplicatedStorage2:FindFirstChild("Services")
			local icon = services and services:FindFirstChild("Icon")

			if not icon then
				return nil
			end

			local success, result = pcall(require, icon)

			if not success or type(result) ~= "table" or type(result.setTopbarEnabled) ~= "function" then
				return nil
			end

			v41 = result
			return result
		end

		do
			local function isTopbarPlusScreenGui(screenGui): boolean -- 1 equivalent call inferred from this helper
				if screenGui and screenGui:IsA("ScreenGui") then
					return screenGui.Name == "TopbarStandard"
						or screenGui.Name == "TopbarStandardClipped"
						or screenGui.Name == "TopbarCentered"
						or screenGui.Name == "TopbarCenteredClipped"
				end

				return false
			end
		end

		do
			local function rememberAndHideTopbarPlusScreenGui(child) -- 2 equivalent calls inferred from this helper
				if not isTopbarPlusScreenGui(child) then -- inferred equivalent call
					return
				end

				if enableds[child] == nil then
					enableds[child] = child.Enabled
				end

				child.Enabled = false
			end
		end

		do
			local function disconnectTopbarPlusListeners() -- 1 equivalent call inferred from this helper
				if childAddedConnection then
					childAddedConnection:Disconnect()
					childAddedConnection = nil
				end

				if iconAddedConnection then
					iconAddedConnection:Disconnect()
					iconAddedConnection = nil
				end
			end
		end

		local function setTopbarPlusScreenGuisHidden(p)
			local playerGui = LocalPlayer:FindFirstChild("PlayerGui")

			if not playerGui then
				return
			end

			if p then
				for _, child in ipairs(playerGui:GetChildren()) do
					rememberAndHideTopbarPlusScreenGui(child) -- inferred equivalent call
				end

				if not childAddedConnection then
					childAddedConnection = playerGui.ChildAdded:Connect(function(child)
						if flag2 then
							rememberAndHideTopbarPlusScreenGui(child) -- inferred equivalent call
						end
					end)
				end
			else
				for k, v46 in pairs(enableds) do
					if k.Parent then
						k.Enabled = v46 == true
					end
				end

				table.clear(enableds)
			end
		end

		local function rememberAndDisableTopbarPlusIcon(object)
			if type(object) ~= "table" then
				return
			end

			if v42[object] == nil then
				v42[object] = object.isEnabled ~= false
			end

			if type(object.deselect) == "function" and object.isSelected then
				pcall(function()
					object:deselect("CommunitySheetsGui")
				end)
			end

			if type(object.setEnabled) == "function" then
				pcall(function()
					object:setEnabled(false)
				end)
			end
		end

		local function setTopbarPlusIconsEnabled(topbarPlusIcon, p) -- 2 equivalent calls inferred from this helper
			if not topbarPlusIcon then
				return
			end

			if p then
				for k, v46 in pairs(v42) do
					if not (type(k) == "table" and type(k.setEnabled) == "function") then
						continue
					end

					pcall(function()
						k:setEnabled(v46 == true)
					end)
				end

				table.clear(v42)
			else
				if type(topbarPlusIcon.getIcons) == "function" then
					for _, v46 in pairs(topbarPlusIcon.getIcons()) do
						rememberAndDisableTopbarPlusIcon(v46)
					end
				end

				if
					topbarPlusIcon.iconAdded
					and type(topbarPlusIcon.iconAdded.Connect) == "function"
					and not iconAddedConnection
				then
					iconAddedConnection = topbarPlusIcon.iconAdded:Connect(function(p2)
						if flag2 then
							rememberAndDisableTopbarPlusIcon(p2)
						end
					end)
				end
			end
		end

		local function setTopbarPlusHidden(p) -- 1 equivalent call inferred from this helper
			local topbarPlusIcon = getTopbarPlusIcon()

			if p then
				if flag2 then
					setTopbarPlusIconsEnabled(topbarPlusIcon, false) -- inferred equivalent call

					if topbarPlusIcon then
						pcall(function()
							topbarPlusIcon.setTopbarEnabled(false)
						end)
					end
				else
					flag2 = true

					if topbarPlusIcon and v43 == nil then
						v43 = topbarPlusIcon.topbarEnabled ~= false
					end

					setTopbarPlusIconsEnabled(topbarPlusIcon, false) -- inferred equivalent call

					if topbarPlusIcon then
						pcall(function()
							topbarPlusIcon.setTopbarEnabled(false)
						end)
					end
				end

				setTopbarPlusScreenGuisHidden(true)
			else
				if not flag2 then
					return
				end

				flag2 = false
				disconnectTopbarPlusListeners() -- inferred equivalent call
				setTopbarPlusIconsEnabled(topbarPlusIcon, true)

				if LocalPlayer:FindFirstChild("PlayerGui") then
					for k, v46 in pairs(enableds) do
						if k.Parent then
							k.Enabled = v46 == true
						end
					end

					table.clear(enableds)
				end

				if not topbarPlusIcon or v43 == nil then
					v43 = nil

					return
				end

				local v46 = v43
				v43 = nil
				pcall(function()
					topbarPlusIcon.setTopbarEnabled(v46)
				end)
			end
		end

		do
			local function shouldUseMobileLandscapeLayout(viewportSize): boolean -- 1 equivalent call inferred from this helper
				return viewportSize.X > viewportSize.Y and viewportSize.Y <= 520 and viewportSize.X <= 1100
			end
		end

		local function layoutMobileLandscapeFrame(viewportSize)
			mobileLandscapeFrame.AnchorPoint = Vector2.new(0, 0)
			mobileLandscapeFrame.Position = UDim2.fromScale(0, 0)
			mobileLandscapeFrame.Size = UDim2.fromScale(1, 1)
			GuiService:GetGuiInset()
			local v46 = math.max(6, (math.floor(viewportSize.Y * 0.018)))
			local v47 = math.max(10, (math.floor(viewportSize.X * 0.015)))
			local v48 = math.max(180, viewportSize.Y - v46 - 6)

			local rail = mobileLandscapeFrame:FindFirstChild("Rail")

			if rail and rail:IsA("GuiObject") then
				rail.Position = UDim2.fromOffset(v47, v46)
				rail.Size = UDim2.fromOffset(66, v48)
				local railLayout = rail:FindFirstChild("RailLayout")

				if railLayout and railLayout:IsA("UIListLayout") then
					railLayout.Padding = UDim.new(0, 5)
				end

				state2.mobileSupport.EnsureShell(state2, controls, configureTextObject)

				for _, button in ipairs(rail:GetChildren()) do
					if button:IsA("TextButton") then
						button.Size = UDim2.fromOffset(50, 40)
					end
				end
			end

			local main = mobileLandscapeFrame:FindFirstChild("Main")

			if not (main and main:IsA("GuiObject")) then
				return
			end

			local v49 = v47 + 66 + 12
			local v50 = math.max(280, viewportSize.X - v49 - v47)
			main.Position = UDim2.fromOffset(v49, v46)
			main.Size = UDim2.fromOffset(v50, v48)
			local modeConfig = getModeConfig() -- inferred equivalent call
			local visible

			if selectedMode == "Blocked" then
				visible = false
			else
				visible = selectedMode ~= "Profile"
			end

			local topBar2 = main:FindFirstChild("TopBar")

			if topBar2 and topBar2:IsA("GuiObject") then
				topBar2.Position = UDim2.fromOffset(0, 6)
				topBar2.Size = UDim2.new(1, 0, 0, 30)
				local title = topBar2:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.Text = modeConfig.Title
					title.Size = UDim2.new(1, -132, 1, 0)
				end
			end

			local searchRow = main:FindFirstChild("SearchRow")

			if searchRow and searchRow:IsA("GuiObject") then
				searchRow.Position = UDim2.fromOffset(0, 42)
				searchRow.Size = UDim2.new(1, 0, 0, 36)
				local searchWrap2 = searchRow:FindFirstChild("SearchWrap")
				local v52 = selectedMode == "Blocked" or selectedMode == "Profile"

				if searchWrap2 and searchWrap2:IsA("GuiObject") then
					searchWrap2.Size = UDim2.new(1, v52 and -46 or -88, 1, 0)
				end

				local refreshButton = searchRow:FindFirstChild("RefreshButton")

				if refreshButton and refreshButton:IsA("GuiObject") then
					refreshButton.Position = UDim2.new(1, v52 and -40 or -82, 0, 0)
					refreshButton.Size = UDim2.fromOffset(38, 36)
				end

				local sortButton2 = searchRow:FindFirstChild("SortButton")

				if sortButton2 and sortButton2:IsA("GuiObject") then
					sortButton2.Position = UDim2.new(1, -40, 0, 0)
					sortButton2.Size = UDim2.fromOffset(40, 36)
					sortButton2.Visible = not v52
				end
			end

			local mobileSortMenu = main:FindFirstChild("MobileSortMenu")

			if mobileSortMenu and mobileSortMenu:IsA("GuiObject") then
				mobileSortMenu.AnchorPoint = Vector2.new(1, 0)
				mobileSortMenu.Position = UDim2.new(1, 0, 0, visible and 114 or 82)
				mobileSortMenu.Size = UDim2.fromOffset(math.min(170, (math.max(142, v50 - 12))), 176)
			end

			local difficultyBar2 = main:FindFirstChild("DifficultyBar")

			if difficultyBar2 and difficultyBar2:IsA("GuiObject") then
				local v52 = math.min(v50, (math.max(332, v50 - 88)))

				local v53 = {
					All = 0.72,
					Beginner = 1.08,
					Intermediate = 1.34,
					Advanced = 1.12,
					Expert = 0.9
				}
				local total = 0

				for _, v54 in ipairs(difficultyOrder) do
					total += v53[v54] or 1
				end

				local v54 = math.max(0, v52 - math.max(0, #difficultyOrder - 1) * 2)
				local total2 = 0

				for i, childName in ipairs(difficultyOrder) do
					local button = difficultyBar2:FindFirstChild(childName)

					if not (button and button:IsA("TextButton")) then
						continue
					end

					local v55 = math.floor(v54 * ((v53[childName] or 1) / math.max(total, 1)) + 0.5)

					if i == #difficultyOrder then
						v55 = math.max(44, v52 - total2)
					end

					local v56 = math.max(44, v55)
					button.Position = UDim2.fromOffset(total2, 1)
					button.Size = UDim2.fromOffset(v56, 24)
					configureTextObject(button, 9, 6)
					total2 += v56 + 2
				end

				difficultyBar2.Position = UDim2.fromOffset(0, 82)
				difficultyBar2.Size = UDim2.fromOffset(v52, 26)
				difficultyBar2.Visible = visible
			end

			local body = main:FindFirstChild("Body")

			if body and body:IsA("GuiObject") then
				local v52 = visible and 116 or 84
				body.Position = UDim2.fromOffset(0, v52)
				body.Size = UDim2.new(1, 0, 1, -(v52 + 4))
				local cardGrid2 = body:FindFirstChild("CardGrid")
				local gridLayout2 = cardGrid2 and cardGrid2:FindFirstChild("GridLayout")

				if gridLayout2 and gridLayout2:IsA("UIGridLayout") then
					local v53 = v50 >= 640 and 2 or 1
					local v54 = math.max(240, (math.floor((v50 - 10 * (v53 - 1)) / v53)))
					gridLayout2.CellPadding = UDim2.fromOffset(10, 10)
					gridLayout2.CellSize = UDim2.fromOffset(v54, v53 > 1 and 112 or 118)
				end

				local emptyLabel2 = body:FindFirstChild("EmptyLabel")

				if emptyLabel2 and emptyLabel2:IsA("TextLabel") then
					emptyLabel2.Text = modeConfig.Empty
				end
			end
		end

		local function applyResponsiveLayout()
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1280, 720)
			local v46 = shouldUseMobileLandscapeLayout(viewportSize) -- inferred equivalent call
			state2.phoneLayoutActive = v46
			state2.phoneLandscapeActive = v46
			state2.mobileLandscapeActive = v46
			panel.Visible = not v46
			mobileLandscapeFrame.Visible = v46

			if v46 then
				root.AnchorPoint = Vector2.new(0, 0)
				root.Position = UDim2.fromScale(0, 0)
				root.Size = UDim2.fromScale(1, 1)
				layoutMobileLandscapeFrame(viewportSize)
				state2.applyModalScale(
					parent:FindFirstChild("PreviewOverlay") and parent.PreviewOverlay:FindFirstChild("Panel"),
					808,
					540
				)
				state2.applyModalScale(
					parent:FindFirstChild("ReportOverlay") and parent.ReportOverlay:FindFirstChild("Panel"),
					410,
					560
				)
				state2.applyModalScale(
					parent:FindFirstChild("SheetPublishOverlay") and parent.SheetPublishOverlay:FindFirstChild("Panel"),
					576,
					760
				)
				state2.applyModalScale(midiPublishPanel, 544, 420)
				state2.applyModalScale(moderationPanel, 520, 360)
			else
				state2.mobileCardScrollWasVisible = false
				state2.mobileCardScrollKey = nil
				state2.mobileProfileWasVisible = false
				state2.mobileProfileScrollKey = nil
				state2.mobileActiveScrollKey = nil
				state2.mobileScrollPositions = {}
				local v47 = viewportSize.X < 980
				local v48 = v47 and 16 or math.clamp(math.floor(viewportSize.X * 0.032), 40, 72)
				local v49 = math.max(260, viewportSize.X - v48 * 2)
				local v50 = v47 and v49 or math.max(760, v49)
				local v51 = v47 and 92 or 68
				local v52 = v51 + (v47 and 18 or 24)
				local v53 = math.max(180, viewportSize.Y - v52 - 24)

				root.AnchorPoint = Vector2.new(0, 0)
				root.Position = UDim2.fromScale(0, 0)
				root.Size = UDim2.fromScale(1, 1)
				panel.AnchorPoint = Vector2.new(0, 0)
				panel.Position = UDim2.fromScale(0, 0)
				panel.Size = UDim2.fromScale(1, 1)
				topBar.AnchorPoint = Vector2.new(0, 0)
				topBar.Position = UDim2.fromOffset(0, 0)
				topBar.Size = UDim2.new(1, 0, 0, v51)
				content.AnchorPoint = Vector2.new(0, 0)
				content.Position = UDim2.fromOffset(v48, v52)
				content.Size = UDim2.fromOffset(v50, v53)

				local brandIconHolder = topBar:FindFirstChild("BrandIconHolder")
				local brandTitle = topBar:FindFirstChild("BrandTitle")
				local v54 = v47 and math.clamp(math.floor(viewportSize.X * 0.18), 18, 132) or 172
				local v55 = v47 and 12 or 16

				if brandIconHolder then
					brandIconHolder.Visible = true
					brandIconHolder.Position = UDim2.fromOffset(v54, v55)
				end

				if brandTitle then
					brandTitle.Visible = true
					local v56 = v47 and math.max(140, (math.min(220, viewportSize.X - v54 - 72))) or 260
					brandTitle.Position = UDim2.fromOffset(v54 + 48, v55)
					brandTitle.Size = UDim2.fromOffset(v56, 36)
				end

				nav.Position = v47 and UDim2.fromOffset(18, 52) or UDim2.new(0, 260, 0, 14)
				nav.Size = v47 and UDim2.new(1, -36, 0, 36) or UDim2.new(1, -280, 0, 40)
				state2.applyTopNavResponsiveSizing()

				local pageIconHolder = content:FindFirstChild("PageIconHolder")
				local v56 = pageIconHolder and (v47 and 50 or 56) or 0

				if pageIconHolder then
					pageIconHolder.Visible = true
					pageIconHolder.Position = UDim2.fromOffset(0, v47 and 0 or 2)
					pageIconHolder.Size = UDim2.fromOffset(v47 and 38 or 42, v47 and 38 or 42)
				end

				pageTitle.Visible = true
				pageTitle.Position = UDim2.fromOffset(v56, 0)
				pageTitle.Size = UDim2.new(1, -v56, 0, v47 and 32 or 38)
				pageTitle.TextSize = v47 and 25 or 30
				pageSubtitle.Visible = true
				pageSubtitle.Position = UDim2.fromOffset(v56, v47 and 36 or 42)
				pageSubtitle.Size = UDim2.new(1, -v56, 0, 24)
				pageSubtitle.TextSize = v47 and 13 or 15
				local v57 = v47 and 82 or 88
				toolbar.Position = UDim2.fromOffset(0, v57)
				toolbar.Size = UDim2.new(1, 0, 0, v47 and 86 or 42)

				if v47 then
					searchWrap.Position = UDim2.fromOffset(0, 0)
					searchWrap.Size = UDim2.new(1, 0, 0, 36)
					difficultyBar.Position = UDim2.fromOffset(0, 50)
					difficultyBar.Size = UDim2.new(1, -90, 0, 36)
					state2.applyDifficultyButtonSizing(true)
					state2.refreshButton.Position = UDim2.new(1, -80, 0, 50)
					sortButton.Position = UDim2.new(1, -36, 0, 50)
				else
					searchWrap.Position = UDim2.fromOffset(0, 3)
					searchWrap.Size = UDim2.fromOffset(math.min(460, (math.floor(v50 * 0.34))), 36)
					local difficultyBarContentWidth = state2.getDifficultyBarContentWidth(false)
					difficultyBar.Size = UDim2.fromOffset(difficultyBarContentWidth, 36)
					difficultyBar.Position = UDim2.new(1, -(difficultyBarContentWidth + 92), 0, 3)
					state2.refreshButton.Position = UDim2.new(1, -80, 0, 3)
					sortButton.Position = UDim2.new(1, -36, 0, 3)
					state2.applyDifficultyButtonSizing(false)
				end

				updateDifficultyVisuals(false)

				local v58 = v57 + (v47 and 112 or 76)
				local v59 = selectedMode == "Profile"
				local v60

				if selectedMode == "Community" or selectedMode == "MIDI" then
					v60 = state2.communitySectionView == nil
				else
					v60 = false
				end

				local visible = not v59 and not v60 and true
				local visible2 = not (v59 or v60)
				local sectionHeader = content:FindFirstChild("SectionHeader")

				if sectionHeader and sectionHeader:IsA("GuiObject") then
					sectionHeader.Visible = visible
					sectionHeader.Position = UDim2.fromOffset(0, v58)
					sectionHeader.Size = UDim2.new(1, 0, 0, 38)
					sectionHeader.ZIndex = 5

					for _, guiObject in ipairs(sectionHeader:GetDescendants()) do
						if guiObject:IsA("GuiObject") then
							guiObject.ZIndex = math.max(guiObject.ZIndex, 6)
						end
					end
				end

				local v63 = v60 and v58 or v58 + (v47 and 56 or 62)

				cardGrid.Position = UDim2.fromOffset(0, v63)
				cardGrid.Size = UDim2.new(1, 0, 1, -(v63 + (visible2 and 50 or 0) + 8))
				pagination.Visible = visible2
				pagination.Position = UDim2.new(0, 0, 1, -44)
				pagination.Size = UDim2.new(1, 0, 0, 44)

				v16 = v47 and 14 or 22
				local v64 = v47 and math.min(318, v50) or 340

				if v47 then
					v13 = 1
				else
					v13 = math.clamp(math.floor((v50 + v16) / (v64 + v16)), 2, 5)
				end

				cardWidth = math.floor((v50 - v16 * (v13 - 1)) / v13)
				v15 = v47 and 246 or 254
				v14 = math.max(1, (math.floor((math.max(180, cardGrid.AbsoluteSize.Y) + v16) / (v15 + v16))))
				v12 = math.max(1, v13 * v14)
				gridLayout.CellPadding = UDim2.fromOffset(v16, v16)
				gridLayout.CellSize = UDim2.fromOffset(cardWidth, v15)

				state2.applyModalScale(
					parent:FindFirstChild("PreviewOverlay") and parent.PreviewOverlay:FindFirstChild("Panel"),
					808,
					540
				)
				state2.applyModalScale(
					parent:FindFirstChild("ReportOverlay") and parent.ReportOverlay:FindFirstChild("Panel"),
					410,
					560
				)
				state2.applyModalScale(
					parent:FindFirstChild("SheetPublishOverlay") and parent.SheetPublishOverlay:FindFirstChild("Panel"),
					576,
					760
				)
				state2.applyModalScale(midiPublishPanel, 544, 420)
				state2.applyModalScale(moderationPanel, 520, 360)

				if selectedMode == "Profile" then
					state2.setProfileVisible(true)
				else
					fn2(false)
				end
			end
		end

		do
			local function open(value)
				if typeof(value) == "string" and modeConfigs[value] then
					selectedMode = value
				end

				parent.Enabled = true
				root.Visible = true
				v44 = true

				if v40 == nil then
					local success, result = pcall(function()
						return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
					end)

					v40 = success and result == true
				end

				pcall(function()
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
				end)

				setTopbarPlusHidden(true)
				applyResponsiveLayout()
				fn7(selectedMode)
			end

			onActivated = function()
				if not (v44 or root.Visible) then
					return
				end

				v44 = false
				root.Visible = false
				closeModerationOverlay() -- inferred equivalent call
				onActivated2()
				state2.closeSupportCreatorOverlay()
				state2.closePreviewOverlay()
				state2.closeReportOverlay()
				state2.closeSheetPublishOverlay()
				local sortMenu = toolbar:FindFirstChild("SortMenu")

				if sortMenu then
					sortMenu.Visible = false
				end

				state2.mobileSupport.HideSortMenu(controls)
				setBackpackHidden(false) -- inferred equivalent call
				setTopbarPlusHidden(false) -- inferred equivalent call
			end

			for _, v46 in ipairs(v3) do
				local button = nav:FindFirstChild(modeConfigs[v46].Button)

				if button and button:IsA("TextButton") then
					button.Activated:Connect(function()
						fn7(v46)
					end)
				end
			end

			state2.mobileSupport.EnsureShell(state2, controls, configureTextObject)

			for _, v46 in ipairs(v3) do
				local v47 = modeConfigs[v46]
				local button = v47 and controls.Rail:FindFirstChild(v47.Button)

				if button and button:IsA("TextButton") then
					button.Activated:Connect(function()
						fn7(v46)
					end)
				end
			end

			for _, childName in ipairs(difficultyOrder) do
				local button = state2.getDifficultyButton(childName)

				if button and button:IsA("TextButton") then
					button.Activated:Connect(function()
						setDifficultyFilter(childName)
					end)
				end

				button = controls.DifficultyBar:FindFirstChild(childName)

				if button and button:IsA("TextButton") then
					button.Activated:Connect(function()
						setDifficultyFilter(childName)
					end)
				end
			end

			do
				local function syncSearchText(p) -- 2 equivalent calls inferred from this helper
					if flag then
						return
					end

					flag = true
					local text = tostring(p.Text or "")
					state2.searchText = text

					if p ~= search then
						search.Text = text
					end

					if p ~= controls.SearchBox then
						controls.SearchBox.Text = text
					end

					flag = false
					state2.scheduleServerCatalogSearch()
					fn2(true)
				end
			end

			search:GetPropertyChangedSignal("Text"):Connect(function()
				syncSearchText(search) -- inferred equivalent call
			end)
			controls.SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				syncSearchText(controls.SearchBox) -- inferred equivalent call
			end)
			controls.RefreshButton.Activated:Connect(function()
				state2.startMobileRefreshSpin()

				if selectedMode == "MIDI" then
					fn5()
				elseif selectedMode == "Profile" then
					state2.refreshProfile(state2.profileTargetUserId)
				else
					fn3()
				end
			end)
			controls.SortButton.Activated:Connect(function()
				state2.mobileSupport.ToggleSortMenu({
					state = state2,
					controls = controls,
					selectedMode = selectedMode,
					configureTextObject = configureTextObject
				})
			end)
			state2.mobileSupport.ConnectSortOptions({
				state = state2,
				controls = controls,
				configureTextObject = configureTextObject,
				setSortMode = function(p)
					state2.setSortMode(p)
				end
			})

			reports = controls.Rail:FindFirstChild("Publish")

			if reports and reports:IsA("TextButton") then
				reports.Activated:Connect(function()
					if selectedMode == "MIDI" then
						fn8()
					else
						state2.openSheetPublishOverlay()
					end
				end)
			end

			reports = controls.Rail:FindFirstChild("Close")

			if reports and reports:IsA("TextButton") then
				reports.Activated:Connect(onActivated)
			end

			reports = controls.Rail:FindFirstChild("ShieldToggle")

			if reports and reports:IsA("TextButton") then
				reports.Activated:Connect(function()
					state2.moderationTabsEnabled = not state2.moderationTabsEnabled

					if state2.moderationTabsEnabled then
						if canViewReports() then -- inferred equivalent call
							fn7("Reports")
							return
						end

						if canViewHiddenUploads() then -- inferred equivalent call
							fn7("Hidden")
							return
						end

						state2.moderationTabsEnabled = false
						updateNavVisuals()
					elseif selectedMode == "Reports" or selectedMode == "Hidden" or selectedMode == "Blocked" then
						fn7("Community")
					else
						updateNavVisuals()
					end
				end)
			end

			prev.Activated:Connect(function()
				local now = os.clock()

				if now - v45 < 0.2 then
					return
				end

				v45 = now

				if v11 > 1 then
					v11 -= 1
					fn()
				end
			end)

			nextNode.Activated:Connect(function()
				local now = os.clock()

				if now - v45 < 0.2 then
					return
				end

				v45 = now
				local currentTotalPages = state2.currentTotalPages or math.max(1, (math.ceil(#v10 / math.max(1, v12))))

				if v11 < currentTotalPages then
					v11 += 1
					fn()
				elseif state2.currentModeHasMore() then
					state2.advancePageAfterCatalogLoad = true
					state2.loadMoreCurrentCatalog()
				end
			end)

			state2.bindNewControls()

			for k in pairs(midiPublishDifficultyButtons) do
				midiPublishDifficultyButtons[k].Activated:Connect(function()
					v27 = k
					updateMidiPublishDifficultyVisuals(true)
				end)
			end

			midiPublishSubmitButton.Activated:Connect(publishMidiFromOverlay)
			midiPublishCancelButton.Activated:Connect(onActivated2)

			moderationHideButton.Activated:Connect(function()
				local v46 = v32

				if v46 and (v46.isHidden == true or v46.isDeleted == true) then
					runModerationAction("restore")
				else
					runModerationAction("hide")
				end
			end)

			moderationResolveButton.Activated:Connect(function()
				runModerationAction("clearReports")
			end)

			moderationDeleteButton.Activated:Connect(function()
				runModerationAction("delete")
			end)

			moderationBlockButton.Activated:Connect(function()
				local v46 = v32

				if v46 and tostring(v46.moderationAction or "") == "blockUser" then
					runModerationAction("unblockUser")
				else
					runModerationAction("blockUser")
				end
			end)

			moderationCancelButton.Activated:Connect(closeModerationOverlay)

			v.Activated:Connect(onActivated)
			openCommunitySheets.Event:Connect(open)
		end

		openCommunityProfileEvent.Event:Connect(function(p, p2, p3)
			parent.Enabled = true
			root.Visible = true
			v44 = true

			if v40 == nil then
				local success, result = pcall(function()
					return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
				end)

				v40 = success and result == true
			end

			pcall(function()
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
			end)

			setTopbarPlusHidden(true)
			applyResponsiveLayout()
			fn7(selectedMode)

			state2.openCommunityProfile(p, p2, p3)
		end)

		v = workspace.CurrentCamera

		if v then
			v:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				if root.Visible then
					applyResponsiveLayout()
				end
			end)
		end

		updateNavVisuals()
		updateDifficultyVisuals()
		applyResponsiveLayout()
	end

	root.Visible = false
end

v2.Print("[CommunitySheetsGui] Community Sheets controller initialized")