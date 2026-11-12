local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ContentProvider2 = game:GetService("ContentProvider")
ContentProvider = ContentProvider2

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera
local ProfileSystemConfig = require(ReplicatedStorage:WaitForChild("ProfileSystemConfig"))
local ClientDebugConfig = require(ReplicatedStorage:WaitForChild("ClientDebugConfig"))
ClientDebug = ClientDebugConfig

local Piano_Dependencies = Workspace:WaitForChild("Piano_Dependencies", 30)
local remotes = Piano_Dependencies and Piano_Dependencies:WaitForChild("Remotes", 30)

if not remotes then
	warn("[PlayerProfileClient] Missing Piano_Dependencies.Remotes")
	return
end

local v = nil

local Modules = Piano_Dependencies:FindFirstChild("Modules")
local logic = Modules and Modules:FindFirstChild("Logic")
local moduleScript = logic and logic:FindFirstChild("PianoLogic")

if moduleScript and moduleScript:IsA("ModuleScript") then
	local success, result = pcall(require, moduleScript)

	if success and type(result) == "table" then
		v = result
	else
		ClientDebug.Warn("[PlayerProfileClient] Failed to load PianoLogic for local piano mute cleanup")
	end
end

local getPlayerProfile = remotes:WaitForChild("GetPlayerProfile")
GetProfileCommentsPage = remotes:WaitForChild("GetProfileCommentsPage")
ProfileCommentsPageLoading = false
local saveProfileBio = remotes:WaitForChild("SaveProfileBio")
local saveProfileAppearance = remotes:WaitForChild("SaveProfileAppearance")
SearchProfileCatalogImages = remotes:WaitForChild("SearchProfileCatalogImages")
SharedCatalogImagePickerOpen = ReplicatedStorage:WaitForChild("OpenSharedCatalogImagePicker")
SharedCatalogImageSelected = ReplicatedStorage:WaitForChild("SharedCatalogImageSelected")
ImagePickerExternalRequestId = nil
ImagePickerExternalTargetText = nil
ImagePickerExternalCurrentValue = nil
ImagePickerExternalPreviousDisplayOrder = nil
ImagePickerExternalDefaultQuery = nil
ImagePickerExternalLayoutMode = nil
ImagePickerExternalAspectRatio = nil
ImagePickerExternalDefaultImage = nil
HideProfileComment = remotes:WaitForChild("HideProfileComment")
ToggleProfileThumbsUp = remotes:WaitForChild("ToggleProfileThumbsUp")
ToggleProfileCommentThumbsUp = remotes:WaitForChild("ToggleProfileCommentThumbsUp")
local submitProfileComment = remotes:WaitForChild("SubmitProfileComment")
local deleteProfileComment = remotes:WaitForChild("DeleteProfileComment")
moduleScript = remotes:WaitForChild("ProfileCommentAnnounce")

local Events = ReplicatedStorage:WaitForChild("Events", 30)

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local parent2 = PlayerGui:WaitForChild("PlayerProfileGui", 10)

if not parent2 then
	local playerProfileGui = StarterGui:FindFirstChild("PlayerProfileGui")

	if playerProfileGui then
		parent2 = playerProfileGui:Clone()
		parent2.Parent = PlayerGui
	end
end

if not parent2 then
	warn("[PlayerProfileClient] Missing PlayerProfileGui")
	return
end

for _, screenGui in ipairs(PlayerGui:GetChildren()) do
	if screenGui ~= parent2 and screenGui.Name == "PlayerProfileGui" and screenGui:IsA("ScreenGui") then
		screenGui:Destroy()
	end
end

local overlay = parent2:FindFirstChild("Overlay")

if not overlay then
	overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Text = ""
	overlay.AutoButtonColor = false
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Visible = false
	overlay.ZIndex = 0
	overlay.Parent = parent2
end

local tooltip = parent2:WaitForChild("Tooltip")
tooltip.AnchorPoint = Vector2.new(0, 0)
local profilePanel = parent2:WaitForChild("ProfilePanel")
local responsiveScale = profilePanel:FindFirstChild("ResponsiveScale")

if not responsiveScale then
	responsiveScale = Instance.new("UIScale")
	responsiveScale.Name = "ResponsiveScale"
	responsiveScale.Parent = profilePanel
end

local commentsPanel = parent2:WaitForChild("CommentsPanel")

local header = profilePanel:WaitForChild("Header")
local banner = header:WaitForChild("Banner")
local avatar = header:WaitForChild("Avatar")
local displayName = header:WaitForChild("DisplayName")
local username = header:WaitForChild("Username")
local close = header:WaitForChild("Close")
local reputationBadge = header:WaitForChild("ReputationBadge")
local timeBadge = header:WaitForChild("TimeBadge")
GameBadgeSection = header:FindFirstChild("GameBadgeSection")
BadgeTooltip = parent2:FindFirstChild("BadgeTooltip")
BadgeTooltipTouchToken = 0
ActionTooltip = parent2:FindFirstChild("ActionTooltip")
local bioBox = profilePanel:WaitForChild("BioBox")
local v2 = {
	Limit = math.max(20, (math.floor(tonumber(ProfileSystemConfig.MaxBioLength) or 1000))),
	IsUpdating = false,
	IsVisible = false
}

v2.Label = bioBox:FindFirstChild("CharacterCounter")

if not v2.Label then
	v2.Label = Instance.new("TextLabel")
	v2.Label.Name = "CharacterCounter"
	v2.Label.AnchorPoint = Vector2.new(1, 1)
	v2.Label.Position = UDim2.new(1, -12, 1, -8)
	v2.Label.Size = UDim2.new(0, 150, 0, 18)
	v2.Label.BackgroundTransparency = 1
	v2.Label.BorderSizePixel = 0
	v2.Label.Font = Enum.Font.GothamMedium
	v2.Label.TextSize = 12
	v2.Label.TextXAlignment = Enum.TextXAlignment.Right
	v2.Label.TextYAlignment = Enum.TextYAlignment.Center
	v2.Label.TextColor3 = Color3.fromRGB(151, 164, 181)
	v2.Label.TextTransparency = 0
	v2.Label.Text = tostring(v2.Limit)
	v2.Label.Visible = false
	v2.Label.ZIndex = bioBox.ZIndex + 1
	v2.Label.AutoLocalize = false
	v2.Label.Parent = bioBox
end

function v2:GetCharacterCount(value)
	local v3 = tostring(value or "")
	local success, result = pcall(utf8.len, v3)

	if success and result then
		return result
	end

	return #v3
end

function v2:TrimToLimit(value)
	local v3 = tostring(value or "")

	if self:GetCharacterCount(v3) <= self.Limit then
		return v3
	end

	local success, result = pcall(utf8.offset, v3, self.Limit + 1)

	if success and result then
		return (string.sub(v3, 1, result - 1))
	end

	return (string.sub(v3, 1, self.Limit))
end

function v2:Update()
	local v3 = math.max(0, self.Limit - self:GetCharacterCount(bioBox.Text or ""))
	self.Label.Text = tostring(v3)
	self.Label.Visible = self.IsVisible

	if v3 <= 0 then
		self.Label.TextColor3 = Color3.fromRGB(255, 119, 119)
	elseif v3 <= 50 then
		self.Label.TextColor3 = Color3.fromRGB(255, 197, 92)
	else
		self.Label.TextColor3 = Color3.fromRGB(151, 164, 181)
	end
end

function v2:SetVisible(p)
	self.IsVisible = p == true
	self:Update()
end

function v2:SetText(p)
	local trimToLimit = self:TrimToLimit(p)

	if bioBox.Text == trimToLimit then
		self:Update()
		return
	end

	self.IsUpdating = true
	bioBox.Text = trimToLimit
	self.IsUpdating = false
	self:Update()
end

bioBox:GetPropertyChangedSignal("Text"):Connect(function()
	if v2.IsUpdating then
		v2:Update()
		return
	end

	local text = bioBox.Text or ""
	local trimToLimit = v2:TrimToLimit(text)

	if trimToLimit ~= text then
		local cursorPosition = bioBox.CursorPosition
		v2.IsUpdating = true
		bioBox.Text = trimToLimit
		v2.IsUpdating = false

		if cursorPosition and cursorPosition > 0 then
			pcall(function()
				bioBox.CursorPosition = math.min(cursorPosition, v2:GetCharacterCount(trimToLimit) + 1)
			end)
		end
	end

	v2:Update()
end)
local actionRow = profilePanel:WaitForChild("ActionRow")
local donate = actionRow:WaitForChild("Donate")
local comments = actionRow:WaitForChild("Comments")
local saveBio = actionRow:WaitForChild("SaveBio")
ViewUploadsButton = actionRow:FindFirstChild("ViewUploads") or actionRow:FindFirstChild("SheetsCreated")

if not ViewUploadsButton then
	ViewUploadsButton = comments:Clone()
	ViewUploadsButton.Parent = actionRow
end

ViewUploadsButton.Name = "ViewUploads"
ViewUploadsButton.LayoutOrder = 3
ViewUploadsButton.Text = "View Uploads"
saveBio.LayoutOrder = 4
local more = actionRow:FindFirstChild("More") or header:WaitForChild("More")
ProfileActionBar = profilePanel:WaitForChild("ActionBar")
ActionBarFriendRequestButton = ProfileActionBar:WaitForChild("FriendRequest")
ActionBarExamineAvatarButton = ProfileActionBar:WaitForChild("ExamineAvatar")
ActionBarBlockButton = ProfileActionBar:WaitForChild("Block")
ActionBarHidePlayerChatButton = ProfileActionBar:WaitForChild("HidePlayerChat")
ActionBarMutePianoButton = ProfileActionBar:FindFirstChild("MutePiano")

if not ActionBarMutePianoButton and ActionBarHidePlayerChatButton then
	ActionBarMutePianoButton = ActionBarHidePlayerChatButton:Clone()
	ActionBarMutePianoButton.Name = "MutePiano"
	ActionBarMutePianoButton.LayoutOrder = ActionBarHidePlayerChatButton.LayoutOrder + 1
	ActionBarMutePianoButton.Parent = ProfileActionBar
end

local status = profilePanel:WaitForChild("Status")
local footer = profilePanel:WaitForChild("Footer")
local editProfilePanel = profilePanel:WaitForChild("EditProfilePanel")
local closeEdit = editProfilePanel:WaitForChild("CloseEdit")
local bannerPreview = editProfilePanel:WaitForChild("BannerPreview")
local avatarPreview = editProfilePanel:WaitForChild("AvatarPreview")
local bannerAssetIdBox = editProfilePanel:WaitForChild("BannerAssetIdBox")
local avatarAssetIdBox = editProfilePanel:WaitForChild("AvatarAssetIdBox")
local previewButton = editProfilePanel:WaitForChild("PreviewButton")
local resetButton = editProfilePanel:WaitForChild("ResetButton")
local saveButton = editProfilePanel:WaitForChild("SaveButton")
local avatarStrokeColorButton = editProfilePanel:WaitForChild("AvatarStrokeColorButton")
local avatarStrokeColorPanel = editProfilePanel:WaitForChild("AvatarStrokeColorPanel")
local miniColourWheel = avatarStrokeColorPanel:WaitForChild("MiniColourWheel")
local picker = miniColourWheel:WaitForChild("Picker")
local selectedColorSwatch = avatarStrokeColorPanel:WaitForChild("SelectedColorSwatch")
local applyPreview = avatarStrokeColorPanel:WaitForChild("ApplyPreview")
local closePanel = avatarStrokeColorPanel:WaitForChild("ClosePanel")
ImagePickerPanel = parent2:FindFirstChild("ImagePickerPanel") or profilePanel:FindFirstChild("ImagePickerPanel")

if ImagePickerPanel and ImagePickerPanel.Parent ~= parent2 then
	ImagePickerPanel.Parent = parent2
end

BannerAddImageButton = editProfilePanel:FindFirstChild("BannerAddImageButton")
AvatarAddImageButton = editProfilePanel:FindFirstChild("AvatarAddImageButton")
ImagePickerCloseButton = ImagePickerPanel and ImagePickerPanel:FindFirstChild("Close")
ImagePickerSearchBox = ImagePickerPanel and ImagePickerPanel:FindFirstChild("SearchBox")
ImagePickerSearchButton = ImagePickerPanel and ImagePickerPanel:FindFirstChild("SearchButton")
ImagePickerGrid = ImagePickerPanel and ImagePickerPanel:FindFirstChild("CatalogGrid")
ImagePickerLoadingLabel = ImagePickerPanel and ImagePickerPanel:FindFirstChild("LoadingLabel")
ImagePickerTarget = "Banner"
ImagePickerSelectedAssetId = nil
ImagePickerSelectedSource = nil
ImagePickerSearchToken = 0
ImagePickerLoadedOnce = false
ImagePickerItems = {}
ImagePickerCurrentQuery = ""
ImagePickerNextPageToken = ""
ImagePickerHasMore = false
ImagePickerLoadingPage = false
ImagePickerLastScrollLoadAt = 0
IMAGE_PICKER_MAX_ITEMS = 1000
IMAGE_PICKER_SCROLL_LOAD_MARGIN = 140
local image = banner.Image

HIDE_PLAYER_CHAT_VISIBLE_ICON = "rbxassetid://13863973385"
HIDE_PLAYER_CHAT_HIDDEN_ICON = "rbxassetid://13863977533"
MUTE_PLAYER_PIANO_NORMAL_ICON = "rbxassetid://14936970471"
MUTE_PLAYER_PIANO_MUTED_ICON = "rbxassetid://14936968016"
THUMB_LIKED_BACKGROUND = Color3.fromRGB(64, 196, 103)
PROFILE_APPEARANCE_PRELOAD_TIMEOUT = 1.5
ProfileAppearancePreloadCache = {}

local header2 = commentsPanel:WaitForChild("Header")
local title = header2:WaitForChild("Title")
local subtitle = header2:WaitForChild("Subtitle")
local close2 = header2:WaitForChild("Close")
local addComment = header2:WaitForChild("AddComment")
local search = commentsPanel:WaitForChild("Search")
local list = commentsPanel:WaitForChild("List")
local empty = list:WaitForChild("Empty")
local commentTemplate = list:WaitForChild("CommentTemplate")
local composer = commentsPanel:WaitForChild("Composer")
local commentBox = composer:WaitForChild("CommentBox")
local reactions = composer:WaitForChild("Reactions")
local selectedReaction = composer:WaitForChild("SelectedReaction")
local polarityToggle = composer:WaitForChild("PolarityToggle")
local submit = composer:WaitForChild("Submit")
local characterCount = composer:WaitForChild("CharacterCount")
local status2 = composer:WaitForChild("Status")
local replyContext = composer:WaitForChild("ReplyContext")
local label = replyContext:WaitForChild("Label")
local cancelReply = replyContext:WaitForChild("CancelReply")

local function ensureProfileChild(parent, name, className)
	local profileChild = parent:FindFirstChild(name)

	if profileChild and not profileChild:IsA(className) then
		profileChild:Destroy()
		profileChild = nil
	end

	if not profileChild then
		profileChild = Instance.new(className)
		profileChild.Name = name
		profileChild.Parent = parent
	end

	return profileChild
end

local function applyResponsiveText(viewUploadsButton, p, value)
	if not (viewUploadsButton and (viewUploadsButton:IsA("TextLabel") or viewUploadsButton:IsA("TextButton") or viewUploadsButton:IsA("TextBox"))) then
		return
	end

	viewUploadsButton.TextWrapped = true
	viewUploadsButton.TextScaled = true
	local v3 = viewUploadsButton:FindFirstChildOfClass("UITextSizeConstraint")

	if not v3 then
		v3 = Instance.new("UITextSizeConstraint")
		v3.Parent = viewUploadsButton
	end

	v3.MaxTextSize = p or math.max(8, viewUploadsButton.TextSize)
	v3.MinTextSize = value or 8
end

applyResponsiveText(ViewUploadsButton, 13, 9)

local openPlayerComments = parent2:FindFirstChild("SheetsPanel")

if openPlayerComments then
	openPlayerComments:Destroy()
end

editProfilePanel.Visible = false
avatarStrokeColorPanel.Visible = false

if ImagePickerPanel then
	ImagePickerPanel.Visible = false
end

local v3 = nil
local playerByUserId = nil
local id = nil
local v4 = nil
local v5 = true
local buttons = {}
local v6 = nil
local v7 = false
local avatarStrokeColor = "#E6EEFA"
local v8 = nil
local userId = nil
local v9 = {}
local clones = {}
local v10 = {}
local v11 = {}
local v12 = {}
expandedLongComments = {}
togglingCommentThumbIds = {}
local v13 = false
local v14 = false
isTogglingProfileThumb = false

local v15 = nil
local v16 = nil
local total = 0

local function createHoverHighlight(instance)
	local profileHoverHighlight = Instance.new("Highlight")
	profileHoverHighlight.Name = "ProfileHoverHighlight"
	profileHoverHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
	profileHoverHighlight.FillColor = Color3.fromRGB(63, 145, 255)
	profileHoverHighlight.FillTransparency = 0.82
	profileHoverHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	profileHoverHighlight.OutlineTransparency = 0
	profileHoverHighlight.Enabled = false
	profileHoverHighlight.Adornee = instance
	profileHoverHighlight.Parent = instance
	profileHoverHighlight.Enabled = true
	return profileHoverHighlight
end

local function getBindable(name) -- 2 equivalent calls inferred from this helper
	local v17 = ReplicatedStorage:FindFirstChild(name)

	if v17 and v17:IsA("BindableEvent") then
		return v17
	end

	if v17 then
		v17:Destroy()
	end

	v17 = Instance.new("BindableEvent")
	v17.Name = name
	v17.Parent = ReplicatedStorage

	return v17
end

openPlayerComments = ReplicatedStorage:FindFirstChild("OpenPlayerComments")

if not (openPlayerComments and openPlayerComments:IsA("BindableEvent")) then
	if openPlayerComments then
		openPlayerComments:Destroy()
	end

	openPlayerComments = Instance.new("BindableEvent")
	openPlayerComments.Name = "OpenPlayerComments"
	openPlayerComments.Parent = ReplicatedStorage
end

local bindable = getBindable("OpenPremium") -- inferred equivalent call
local setProfilePlayerHidden = getBindable("OpenCommunityProfile") -- inferred equivalent call
OpenCommunityProfileEvent = setProfilePlayerHidden
setProfilePlayerHidden = ReplicatedStorage:FindFirstChild("SetProfilePlayerHidden")

if not (setProfilePlayerHidden and setProfilePlayerHidden:IsA("BindableEvent")) then
	if setProfilePlayerHidden then
		setProfilePlayerHidden:Destroy()
	end

	setProfilePlayerHidden = Instance.new("BindableEvent")
	setProfilePlayerHidden.Name = "SetProfilePlayerHidden"
	setProfilePlayerHidden.Parent = ReplicatedStorage
end

SetProfilePlayerHiddenEvent = setProfilePlayerHidden

local function disableAvatarContextMenu()
	for _ = 1, 10 do
		if pcall(function()
			StarterGui:SetCore("AvatarContextMenuEnabled", false)
		end) then
			break
		end

		task.wait(0.25)
	end
end

task.spawn(disableAvatarContextMenu)

local function comma(p)
	local v17 = tostring((math.floor(tonumber(p) or 0)))
	local v18

	if v17:sub(1, 1) == "-" then
		v17 = v17:sub(2)
		v18 = "-"
	else
		v18 = ""
	end

	repeat
		local v19
		v17, v19 = v17:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v19 == 0

	return v18 .. v17
end

local v17 = {
	{ 1000000000000, "T" },
	{ 1000000000, "B" },
	{ 1000000, "M" },
	{ 1000, "k" }
}

local function formatCompactCount(p)
	local v18 = math.max(0, (math.floor(tonumber(p) or 0)))

	if v18 < 1000 then
		return (tostring(v18))
	end

	for i, v19 in ipairs(v17) do
		local v20 = v19[1]
		local v21 = v19[2]

		if v20 <= v18 then
			local v22 = v18 / v20
			local v23 = (v22 < 100 and string.format("%.1f", v22) or string.format("%.0f", v22)):gsub("%.0$", "")

			if v23 == "1000" and i > 1 then
				return "1" .. v17[i - 1][2]
			end

			return v23 .. v21
		end
	end

	return comma(v18)
end

local function formatRep(p) -- 4 equivalent calls inferred from this helper
	local v18 = math.floor(tonumber(p) or 0)

	if v18 > 0 then
		return "+" .. comma(v18)
	end

	return comma(v18)
end

local function formatTime(timePlayed) -- 1 equivalent call inferred from this helper
	local v18 = math.floor(math.max(0, (math.floor(tonumber(timePlayed) or 0))) / 3600)

	if v18 >= 24 then
		return tostring((math.floor(v18 / 24))) .. " Days"
	end

	return tostring(v18) .. " Hours"
end

local function escapeRichText(value) -- 3 equivalent calls inferred from this helper
	return tostring(value or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function setStatus(status3, value, p) -- 5 equivalent calls inferred from this helper
	status3.Text = tostring(value or "")
	status3.TextColor3 = p and Color3.fromRGB(255, 106, 120) or Color3.fromRGB(147, 162, 184)
end

local function notify(value, value2) -- 13 equivalent calls inferred from this helper
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = tostring(value or "Profile"),
			Text = tostring(value2 or ""),
			Duration = 5
		})
	end)
end

local function playProfileErrorSound()
	local soundFX = ReplicatedStorage:FindFirstChild("SoundFX")
	local err = soundFX and soundFX:FindFirstChild("Error")
	local clone = err and err:IsA("Sound") and err:Clone() or Instance.new("Sound")

	if not err then
		clone.SoundId = "rbxassetid://2865228021"
		clone.Volume = 1
	end

	clone.Parent = SoundService
	SoundService:PlayLocalSound(clone)
	Debris:AddItem(clone, 4)
end

local function setBackpackVisible(p) -- 4 equivalent calls inferred from this helper
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, p == true)
	end)
end

local function getThumbnail(p)
	local v18 = tonumber(p) or 0

	if v9[v18] then
		return v9[v18]
	end

	local success, result = pcall(function()
		return Players:GetUserThumbnailAsync(v18, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	if success and result then
		v9[v18] = result
		return result
	end

	return ""
end

local function color3ToHex(color) -- 1 equivalent call inferred from this helper
	return string.format(
		"#%02X%02X%02X",
		math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		(math.floor(color.B * 255 + 0.5))
	)
end

local function hexToColor3(value, p)
	local match = tostring(value or ""):match("^#?(%x%x%x%x%x%x)$")

	if match then
		return Color3.fromRGB(
			tonumber(match:sub(1, 2), 16),
			tonumber(match:sub(3, 4), 16),
			(tonumber(match:sub(5, 6), 16))
		)
	end

	return p or Color3.fromRGB(230, 238, 250)
end

local function catalogAssetIdToImage(value) -- 2 equivalent calls inferred from this helper
	local match = tostring(value or ""):match("(%d+)")

	if match and match ~= "" then
		return "rbxthumb://type=Asset&id=" .. match .. "&w=420&h=420"
	end

	return ""
end

local function normalizeAssetIdText(value)
	local v18 = tostring(value or ""):gsub("%s+", "")

	if v18 == "" then
		return ""
	end

	local v19 = string.lower(v18)
	local v20 = v19:match("^catalog:(%d+)$") or v19:match("^thumb:(%d+)$") or v19:match("type=asset&id=(%d+)")

	if v20 then
		return "catalog:" .. v20
	end

	return v18:match("^rbxassetid://(%d+)$") or v18:match("[?&]id=(%d+)") or v18:match("^(%d+)$") or ""
end

local function assetIdToImage(p, value) -- 4 equivalent calls inferred from this helper
	local assetIdText = normalizeAssetIdText(p)
	local match = assetIdText:match("^catalog:(%d+)$")

	if match then
		return catalogAssetIdToImage(match) -- inferred equivalent call
	elseif assetIdText == "" then
		return value or ""
	else
		return "rbxassetid://" .. assetIdText
	end
end

local function getProfileAppearance(p)
	local appearance = type(p and p.Appearance) == "table" and p.Appearance or {}
	return {
		BannerAssetId = normalizeAssetIdText(appearance.BannerAssetId),
		AvatarAssetId = normalizeAssetIdText(appearance.AvatarAssetId),
		AvatarStrokeColor = tostring(appearance.AvatarStrokeColor or "#E6EEFA")
	}
end

function getProfileAppearanceImages(p)
	local profileAppearance = getProfileAppearance(p)
	local userId2 = tonumber(p.UserId) or 0
	local result

	if v9[userId2] then
		result = v9[userId2]
	else
		local success
		success, result = pcall(function()
			return Players:GetUserThumbnailAsync(userId2, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)

		if success and result then
			v9[userId2] = result
		else
			result = ""
		end
	end

	return
		profileAppearance,
		assetIdToImage(profileAppearance.BannerAssetId, image), -- inferred equivalent call
		assetIdToImage(profileAppearance.AvatarAssetId, result) -- inferred equivalent call
end

function shouldPreloadProfileImage(value): boolean
	return type(value) == "string"
		and value ~= ""
		and value ~= "rbxassetid://0"
		and ProfileAppearancePreloadCache[value] ~= true
end

function preloadProfileAppearanceImages(p, p2)
	local v18 = {}

	if shouldPreloadProfileImage(p) then
		table.insert(v18, p)
	end

	if shouldPreloadProfileImage(p2) then
		table.insert(v18, p2)
	end

	if #v18 == 0 then
		return
	end

	local v19 = false
	task.spawn(function()
		if pcall(function()
			ContentProvider:PreloadAsync(v18)
		end) then
			for _, v20 in ipairs(v18) do
				ProfileAppearancePreloadCache[v20] = true
			end
		end

		v19 = true
	end)

	local lastTime = os.clock()

	while not v19 and os.clock() - lastTime < PROFILE_APPEARANCE_PRELOAD_TIMEOUT do
		RunService.Heartbeat:Wait()
	end
end

local function getOrCreateStroke(parent) -- 2 equivalent calls inferred from this helper
	local v18 = parent and parent:FindFirstChildOfClass("UIStroke")

	if not v18 and parent then
		v18 = Instance.new("UIStroke")
		v18.Thickness = 2
		v18.Parent = parent
	end

	return v18
end

local function syncAvatarStrokePicker(p)
	local absoluteSize = miniColourWheel.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		task.defer(function()
			syncAvatarStrokePicker(p)
		end)
		return
	end

	local v18 = math.max(1, math.min(absoluteSize.X, absoluteSize.Y) / 2)
	local hsv, v19 = p:ToHSV()
	local v20 = (0.5 - hsv) * 3.141592653589793 * 2
	local v21 = Vector2.new(math.cos(v20), (math.sin(v20))) * v19 * v18
	picker.Position = UDim2.fromScale(
		math.clamp((v21.X + v18) / (v18 * 2), 0, 1),
		(math.clamp((v21.Y + v18) / (v18 * 2), 0, 1))
	)
end

local function setAvatarStrokeHex(value)
	avatarStrokeColor = "#" .. (tostring(value or "#E6EEFA"):match("#?(%x%x%x%x%x%x)") or ("#E6EEFA"):sub(2)):upper()
	local v18 = hexToColor3(avatarStrokeColor)
	local stroke = getOrCreateStroke(avatar) -- inferred equivalent call

	if stroke then
		stroke.Color = v18
	end

	local stroke2 = getOrCreateStroke(avatarPreview) -- inferred equivalent call

	if stroke2 then
		stroke2.Color = v18
	end

	selectedColorSwatch.BackgroundColor3 = v18
	syncAvatarStrokePicker(v18)
end

local function applyAppearancePreview()
	local v18 = v3
	local v19

	if v18 then
		local userId2 = tonumber(v18.UserId) or 0
		local result

		if v9[userId2] then
			result = v9[userId2]
		else
			local success
			success, result = pcall(function()
				return Players:GetUserThumbnailAsync(
					userId2,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size150x150
				)
			end)

			if success and result then
				v9[userId2] = result
			else
				result = ""
			end
		end

		v19 = result or ""
	else
		v19 = ""
	end

	local image2 = assetIdToImage(bannerAssetIdBox.Text, image) -- inferred equivalent call
	local image3 = assetIdToImage(avatarAssetIdBox.Text, v19) -- inferred equivalent call
	banner.Image = image2
	banner.ImageTransparency = 0
	banner.ImageColor3 = Color3.fromRGB(255, 255, 255)
	bannerPreview.Image = image2
	bannerPreview.ImageTransparency = 0
	bannerPreview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	avatar.Image = image3
	avatar.ImageTransparency = 0
	avatar.ImageColor3 = Color3.fromRGB(255, 255, 255)
	avatarPreview.Image = image3
	avatarPreview.ImageTransparency = 0
	avatarPreview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	setAvatarStrokeHex(avatarStrokeColor)
end

local function syncEditProfileFields(p) -- 1 equivalent call inferred from this helper
	local profileAppearance = getProfileAppearance(p)
	bannerAssetIdBox.Text = profileAppearance.BannerAssetId
	avatarAssetIdBox.Text = profileAppearance.AvatarAssetId
	avatarStrokeColor = profileAppearance.AvatarStrokeColor
	applyAppearancePreview()
end

local function applyProfileAppearance(player)
	local profileAppearanceImages, image2, image3 = getProfileAppearanceImages(player)
	preloadProfileAppearanceImages(image2, image3)
	banner.Image = image2
	banner.ImageTransparency = 0
	banner.ImageColor3 = Color3.fromRGB(255, 255, 255)
	avatar.Image = image3
	avatar.ImageTransparency = 0
	avatar.ImageColor3 = Color3.fromRGB(255, 255, 255)
	bannerPreview.Image = image2
	bannerPreview.ImageTransparency = 0
	bannerPreview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	avatarPreview.Image = image3
	avatarPreview.ImageTransparency = 0
	avatarPreview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	setAvatarStrokeHex(profileAppearanceImages.AvatarStrokeColor)

	if editProfilePanel.Visible and player.IsSelf == true then
		bannerAssetIdBox.Text = profileAppearanceImages.BannerAssetId
		avatarAssetIdBox.Text = profileAppearanceImages.AvatarAssetId
	end
end

local function updateAvatarStrokeFromInput(input)
	local position = input and input.Position

	if not position then
		return
	end

	local absoluteSize = miniColourWheel.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local v18 = miniColourWheel.AbsolutePosition + absoluteSize / 2
	local v19 = Vector2.new(position.X, position.Y) - v18
	local v20 = math.max(1, math.min(absoluteSize.X, absoluteSize.Y) / 2)

	if v20 < v19.Magnitude then
		v19 = v19.Unit * v20
	end

	local v21 = (0.5 - math.atan2(v19.Y, v19.X) / 6.283185307179586) % 1
	local v22 = math.clamp(v19.Magnitude / v20, 0, 1)
	local color = Color3.fromHSV(v21, v22, 1)
	avatarStrokeColor = color3ToHex(color) -- inferred equivalent call
	selectedColorSwatch.BackgroundColor3 = color
	picker.Position = UDim2.fromScale(
		math.clamp((v19.X + v20) / (v20 * 2), 0, 1),
		(math.clamp((v19.Y + v20) / (v20 * 2), 0, 1))
	)

	setAvatarStrokeHex(avatarStrokeColor)
end

function setImagePickerMessage(value, p)
	if ImagePickerLoadingLabel and ImagePickerLoadingLabel:IsA("TextLabel") then
		ImagePickerLoadingLabel.Text = tostring(value or "")
		ImagePickerLoadingLabel.TextColor3 = p and Color3.fromRGB(255, 106, 120) or Color3.fromRGB(151, 166, 186)
		ImagePickerLoadingLabel.Visible = tostring(value or "") ~= ""
	end
end

function updateImagePickerTileSelection()
	if not ImagePickerGrid then
		return
	end

	for _, button in ipairs(ImagePickerGrid:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		local uiStroke = button:FindFirstChildOfClass("UIStroke")

		if not uiStroke then
			continue
		end

		local v18

		if tostring(button:GetAttribute("CatalogAssetId") or "") == tostring(ImagePickerSelectedAssetId or "") then
			v18 = ImagePickerSelectedSource == "Catalog"
		else
			v18 = false
		end

		uiStroke.Color = v18 and Color3.fromRGB(60, 196, 106) or Color3.fromRGB(199, 205, 214)
		uiStroke.Transparency = v18 and 0 or 0.08
		uiStroke.Thickness = v18 and 2 or 1
	end
end

function selectImagePickerCatalogAsset(value)
	local match = tostring(value or ""):match("(%d+)")

	if not match then
		return
	end

	ImagePickerSelectedAssetId = match
	ImagePickerSelectedSource = "Catalog"
	applyImagePickerCatalogAsset(match)
end

function connectImagePickerTile(button)
	if not button or not button:IsA("ImageButton") or button:GetAttribute("ImagePickerConnected") == true then
		return
	end

	button:SetAttribute("ImagePickerConnected", true)
	button.MouseButton1Click:Connect(function()
		local catalogAssetId = button:GetAttribute("CatalogAssetId")

		if catalogAssetId then
			selectImagePickerCatalogAsset(catalogAssetId)
		end
	end)
end

function connectImagePickerNoneTile(button)
	if not button or not button:IsA("GuiButton") or button:GetAttribute("ImagePickerNoneConnected") == true then
		return
	end

	button:SetAttribute("ImagePickerNoneConnected", true)
	button.MouseButton1Click:Connect(function()
		if ImagePickerTarget == "External" then
			SharedCatalogImageSelected:Fire(tostring(ImagePickerExternalRequestId or ""), "")
		else
			if ImagePickerTarget == "Avatar" then
				avatarAssetIdBox.Text = ""
			else
				bannerAssetIdBox.Text = ""
			end

			applyAppearancePreview()
		end

		setImagePickerVisible(false)
	end)
end

function getCatalogItemId(data)
	if type(data) == "table" then
		return (math.floor(tonumber(data.Id or data.id or data.AssetId or data.assetId or data.ItemId or data.itemId or type(data.Item) == "table" and (data.Item.Id or data.Item.id) or 0) or 0))
	end

	return 0
end

function isCardBackgroundImagePicker(): boolean
	return ImagePickerTarget == "External" and ImagePickerExternalLayoutMode == "CardBackground"
end

function getImagePickerCardAspectRatio()
	return (math.clamp(tonumber(ImagePickerExternalAspectRatio) or 177 / 53, 2, 6))
end

function ensureImagePickerTileTemplate()
	if not ImagePickerGrid then
		return nil
	end

	local cardBackgroundImagePicker = isCardBackgroundImagePicker()
	local noneTile = ImagePickerGrid:FindFirstChild("NoneTile")

	if not (noneTile and noneTile:IsA("ImageButton")) then
		noneTile = Instance.new("ImageButton")
		noneTile.Name = "NoneTile"
		noneTile.AutoButtonColor = true
		noneTile.BorderSizePixel = 0
		noneTile.Parent = ImagePickerGrid
		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = noneTile
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Parent = noneTile
		local preview = Instance.new("ImageLabel")
		preview.Name = "Preview"
		preview.Parent = noneTile
		local label2 = Instance.new("TextLabel")
		label2.Name = "Label"
		label2.Parent = noneTile
	end

	local zIndex = ImagePickerGrid.ZIndex + 1
	noneTile.LayoutOrder = 1
	noneTile.Visible = true
	noneTile.BackgroundTransparency = 0
	noneTile.BackgroundColor3 = cardBackgroundImagePicker and Color3.fromRGB(27, 30, 38)
		or Color3.fromRGB(246, 246, 248)
	noneTile.Image = ""
	noneTile.ImageTransparency = 1
	noneTile.ZIndex = zIndex
	noneTile.ClipsDescendants = true
	noneTile:SetAttribute("CatalogAssetId", nil)

	local uiCorner = noneTile:FindFirstChildOfClass("UICorner") or Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = noneTile

	local uiStroke = noneTile:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(199, 205, 214)
	uiStroke.Transparency = 0.08
	uiStroke.Thickness = 1
	uiStroke.Parent = noneTile

	local preview = noneTile:FindFirstChild("Preview")

	if not (preview and preview:IsA("ImageLabel")) then
		if preview then
			preview:Destroy()
		end

		preview = Instance.new("ImageLabel")
		preview.Name = "Preview"
		preview.Parent = noneTile
	end

	preview.Visible = cardBackgroundImagePicker
	preview.BackgroundTransparency = 1
	preview.Position = cardBackgroundImagePicker and UDim2.fromScale(0, 0) or UDim2.fromOffset(5, 5)
	preview.Size = cardBackgroundImagePicker and UDim2.fromScale(1, 1) or UDim2.new(1, -10, 1, -10)
	preview.ScaleType = cardBackgroundImagePicker and Enum.ScaleType.Crop or Enum.ScaleType.Fit
	preview.Image = cardBackgroundImagePicker and tostring(ImagePickerExternalDefaultImage or "") or ""
	preview.ImageTransparency = 0
	preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	preview.ZIndex = zIndex + 1
	local previewCorner = preview:FindFirstChild("PreviewCorner") or Instance.new("UICorner")
	previewCorner.Name = "PreviewCorner"
	previewCorner.CornerRadius = UDim.new(0, 8)
	previewCorner.Parent = preview

	local label2 = noneTile:FindFirstChild("Label")

	if not (label2 and label2:IsA("TextLabel")) then
		if label2 then
			label2:Destroy()
		end

		label2 = Instance.new("TextLabel")
		label2.Name = "Label"
		label2.Parent = noneTile
	end

	label2.Visible = true
	label2.BackgroundTransparency = cardBackgroundImagePicker and 0.28 or 1
	label2.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
	label2.Position = cardBackgroundImagePicker and UDim2.new(0, 0, 1, -22) or UDim2.fromScale(0, 0)
	label2.Size = cardBackgroundImagePicker and UDim2.new(1, 0, 0, 22) or UDim2.fromScale(1, 1)
	label2.Font = Enum.Font.GothamBold
	label2.Text = cardBackgroundImagePicker and "Default" or "None"
	label2.TextColor3 = cardBackgroundImagePicker and Color3.fromRGB(245, 247, 252) or Color3.fromRGB(154, 154, 160)
	label2.TextSize = cardBackgroundImagePicker and 12 or 16
	label2.TextWrapped = true
	label2.ZIndex = zIndex + 2

	local favorite = noneTile:FindFirstChild("Favorite")

	if favorite then
		favorite:Destroy()
	end

	connectImagePickerNoneTile(noneTile)
	return noneTile
end

local function prepareImagePickerGrid(p)
	if not ImagePickerGrid then
		return nil
	end

	if ImagePickerGrid:IsA("ScrollingFrame") then
		ImagePickerGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ImagePickerGrid.CanvasSize = UDim2.fromOffset(0, 0)

		if p == true then
			ImagePickerGrid.CanvasPosition = Vector2.new(0, 0)
		end
	end

	return ensureImagePickerTileTemplate()
end

local function clearImagePickerResultTiles()
	if not ImagePickerGrid then
		return
	end

	for _, button in ipairs(ImagePickerGrid:GetChildren()) do
		if button:IsA("ImageButton") and button.Name ~= "NoneTile" then
			button:Destroy()
		end
	end
end

local function createImagePickerResultTile(p, p2)
	local imagePickerTileTemplate = ensureImagePickerTileTemplate()
	local catalogItemId = getCatalogItemId(p)

	if catalogItemId <= 0 or not (imagePickerTileTemplate and imagePickerTileTemplate:IsA("ImageButton")) then
		return nil
	end

	local clone = imagePickerTileTemplate:Clone()
	clone.Name = "CatalogTile" .. tostring(p2)
	clone.LayoutOrder = p2 + 1
	clone.Visible = true
	clone.BackgroundTransparency = 0
	clone.BackgroundColor3 = Color3.fromRGB(246, 246, 248)
	clone.Image = ""
	clone.ImageTransparency = 1
	clone.ZIndex = ImagePickerGrid.ZIndex + 1
	clone.ClipsDescendants = true
	clone:SetAttribute("ImagePickerConnected", nil)
	clone:SetAttribute("ImagePickerNoneConnected", nil)
	clone:SetAttribute("CatalogAssetId", catalogItemId)

	local preview = clone:FindFirstChild("Preview") or Instance.new("ImageLabel")
	preview.Name = "Preview"
	preview.BackgroundTransparency = 1
	local cardBackgroundImagePicker = isCardBackgroundImagePicker()
	preview.Position = cardBackgroundImagePicker and UDim2.fromScale(0, 0) or UDim2.fromOffset(5, 5)
	preview.Size = cardBackgroundImagePicker and UDim2.fromScale(1, 1) or UDim2.new(1, -10, 1, -10)
	preview.ScaleType = cardBackgroundImagePicker and Enum.ScaleType.Crop or Enum.ScaleType.Fit
	preview.Visible = true
	preview.ImageTransparency = 0
	preview.ImageColor3 = Color3.fromRGB(255, 255, 255)
	preview.Image = tostring(p.Image or p.image or "") ~= "" and tostring(p.Image or p.image)
		or catalogAssetIdToImage(catalogItemId) -- inferred equivalent call
	preview.ZIndex = clone.ZIndex + 1
	preview.Parent = clone
	local previewCorner = preview:FindFirstChild("PreviewCorner") or Instance.new("UICorner")
	previewCorner.Name = "PreviewCorner"
	previewCorner.CornerRadius = UDim.new(0, 8)
	previewCorner.Parent = preview

	local label2 = clone:FindFirstChild("Label")

	if label2 and label2:IsA("TextLabel") then
		label2.Visible = false
	end

	local favorite = clone:FindFirstChild("Favorite")

	if favorite then
		favorite:Destroy()
	end

	local uiStroke = clone:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Color = Color3.fromRGB(199, 205, 214)
		uiStroke.Transparency = 0.08
		uiStroke.Thickness = 1
	end

	clone.Parent = ImagePickerGrid
	connectImagePickerTile(clone)
	return clone
end

function appendImagePickerResultTiles(p, p2)
	if not ImagePickerGrid then
		return
	end

	if ImagePickerGrid then
		if ImagePickerGrid:IsA("ScrollingFrame") then
			ImagePickerGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
			ImagePickerGrid.CanvasSize = UDim2.fromOffset(0, 0)
		end

		ensureImagePickerTileTemplate()
	end

	local v18 = math.max(0, (math.floor(tonumber(p2) or 0)))

	for _, v19 in ipairs(type(p) == "table" and p or {}) do
		if IMAGE_PICKER_MAX_ITEMS <= v18 then
			break
		end

		v18 += 1
		createImagePickerResultTile(v19, v18)
	end

	updateImagePickerTileSelection()
end

function renderImagePickerResults(p, p2)
	if not ImagePickerGrid then
		return
	end

	prepareImagePickerGrid(p2)
	clearImagePickerResultTiles()
	appendImagePickerResultTiles(p, 0)
end

local function normalizeImagePickerQuery(value) -- 2 equivalent calls inferred from this helper
	return tostring(value or ""):gsub("[%c]", " "):gsub("%s+", " "):match("^%s*(.-)%s*$") or ""
end

local function appendImagePickerItems(items)
	local catalogItemIdSet = {}

	for _, v18 in ipairs(ImagePickerItems) do
		local catalogItemId = getCatalogItemId(v18)

		if catalogItemId > 0 then
			catalogItemIdSet[catalogItemId] = true
		end
	end

	local result = {}

	for _, v18 in ipairs(type(items) == "table" and items or {}) do
		local catalogItemId = getCatalogItemId(v18)

		if
			not (catalogItemId > 0)
			or catalogItemIdSet[catalogItemId]
			or not (#ImagePickerItems < IMAGE_PICKER_MAX_ITEMS)
		then
			continue
		end

		catalogItemIdSet[catalogItemId] = true
		table.insert(ImagePickerItems, v18)
		table.insert(result, v18)
	end

	return result
end

function maybeLoadMoreImagePickerResults()
	if not (ImagePickerPanel and ImagePickerPanel.Visible and ImagePickerGrid and ImagePickerGrid:IsA("ScrollingFrame")) then
		return
	end

	if ImagePickerLoadingPage or not ImagePickerHasMore or #ImagePickerItems >= IMAGE_PICKER_MAX_ITEMS then
		return
	end

	local uiGridLayout = ImagePickerGrid:FindFirstChildOfClass("UIGridLayout")
	local y = uiGridLayout and uiGridLayout.AbsoluteContentSize.Y or 0

	if
		y <= 0
		or ImagePickerGrid.CanvasPosition.Y + ImagePickerGrid.AbsoluteSize.Y < y - IMAGE_PICKER_SCROLL_LOAD_MARGIN
	then
		return
	end

	local now = os.clock()

	if now - ImagePickerLastScrollLoadAt < 0.25 then
		return
	end

	ImagePickerLastScrollLoadAt = now
	loadImagePickerCatalogPage(false)
end

function loadImagePickerCatalogPage(p)
	if not ImagePickerPanel or ImagePickerLoadingPage and p ~= true or p ~= true and not ImagePickerHasMore then
		return
	end

	local v18 = p == true and normalizeImagePickerQuery(ImagePickerSearchBox and ImagePickerSearchBox.Text or "") -- inferred equivalent call
		or ImagePickerCurrentQuery
	local v19 = p == true and "" or tostring(ImagePickerNextPageToken or "")
	ImagePickerLoadingPage = true

	if p == true then
		ImagePickerSearchToken += 1
		ImagePickerCurrentQuery = v18
		ImagePickerItems = {}
		ImagePickerNextPageToken = ""
		ImagePickerHasMore = false
		ImagePickerSelectedAssetId = nil
		ImagePickerSelectedSource = nil
		renderImagePickerResults(ImagePickerItems, true)
		setImagePickerMessage("Searching 2D assets...", false)
	else
		setImagePickerMessage("Loading more images...", false)
	end

	local imagePickerSearchToken = ImagePickerSearchToken
	task.spawn(function()
		local success, result = pcall(function()
			return SearchProfileCatalogImages:InvokeServer(v18, v19)
		end)

		if imagePickerSearchToken ~= ImagePickerSearchToken then
			return
		end

		ImagePickerLoadedOnce = true
		ImagePickerLoadingPage = false

		if success and type(result) == "table" and result.Ok == true then
			local v20 = #ImagePickerItems
			local v21 = appendImagePickerItems(result.Items or {})
			ImagePickerNextPageToken = tostring(result.NextPageToken or "")
			ImagePickerHasMore = result.HasMore == true
				and ImagePickerNextPageToken ~= ""
				and #ImagePickerItems < IMAGE_PICKER_MAX_ITEMS

			if p == true then
				renderImagePickerResults(ImagePickerItems, true)
			else
				appendImagePickerResultTiles(v21, v20)
			end

			if #ImagePickerItems <= 0 then
				setImagePickerMessage("No 2D assets found.", true)
			elseif #v21 <= 0 and p ~= true and ImagePickerHasMore then
				setImagePickerMessage("No new images on this page. Scroll again for more.", false)
			else
				setImagePickerMessage("", false)
			end

			task.defer(maybeLoadMoreImagePickerResults)
		else
			if p == true then
				renderImagePickerResults(ImagePickerItems, true)
			end

			local err = success and type(result) == "table" and result.Error
				or "Catalog search is unavailable. Use the Edit Profile asset ID box instead."
			setImagePickerMessage(err, true)
		end
	end)
end

function searchImagePickerCatalog(value)
	if ImagePickerSearchBox and ImagePickerSearchBox:IsA("TextBox") then
		ImagePickerSearchBox.Text = normalizeImagePickerQuery(value) -- inferred equivalent call
	end

	loadImagePickerCatalogPage(true)
end

function applyImagePickerCatalogAsset(value)
	local match = tostring(value or ""):match("(%d+)")

	if not match then
		return
	end

	ImagePickerSelectedAssetId = match
	ImagePickerSelectedSource = "Catalog"
	local text = "catalog:" .. match

	if ImagePickerTarget == "External" then
		SharedCatalogImageSelected:Fire(tostring(ImagePickerExternalRequestId or ""), text)
	else
		if ImagePickerTarget == "Avatar" then
			avatarAssetIdBox.Text = text
		else
			bannerAssetIdBox.Text = text
		end

		applyAppearancePreview()
	end

	updateImagePickerTileSelection()
	setImagePickerVisible(false)
end

function setImagePickerVisible(p, p2)
	if not ImagePickerPanel then
		return
	end

	ImagePickerTarget = p2 or ImagePickerTarget or "Banner"
	ImagePickerPanel.Visible = p == true

	if ImagePickerPanel.Visible then
		avatarStrokeColorPanel.Visible = false
		ImagePickerSelectedAssetId = nil
		ImagePickerSelectedSource = nil

		if ImagePickerTarget == "External" then
			if ImagePickerExternalPreviousDisplayOrder == nil then
				ImagePickerExternalPreviousDisplayOrder = parent2.DisplayOrder
			end

			parent2.DisplayOrder = math.max(parent2.DisplayOrder, 1205)
			local match = tostring(ImagePickerExternalCurrentValue or ""):match("^catalog:(%d+)$")

			if match then
				ImagePickerSelectedAssetId = match
				ImagePickerSelectedSource = "Catalog"
			end
		end

		local targetLabel = ImagePickerPanel:FindFirstChild("TargetLabel")

		if targetLabel and targetLabel:IsA("TextLabel") then
			if ImagePickerTarget == "External" then
				targetLabel.Text = tostring(ImagePickerExternalTargetText or "Search Roblox 2D assets for this image.")
			else
				targetLabel.Text = ImagePickerTarget == "Avatar"
					and "Search Roblox 2D assets for your profile image."
					or "Search Roblox 2D assets for your banner."
			end

			targetLabel.TextWrapped = true
			targetLabel.TextScaled = true
		end

		updateImagePickerLayout()
		updateImagePickerTileSelection()
		local v18 = ImagePickerSearchBox and ImagePickerSearchBox.Text or ""

		if ImagePickerTarget == "External" and tostring(ImagePickerExternalDefaultQuery or "") ~= "" then
			v18 = ImagePickerExternalDefaultQuery
		end

		searchImagePickerCatalog(v18)
	else
		if ImagePickerExternalPreviousDisplayOrder ~= nil then
			parent2.DisplayOrder = ImagePickerExternalPreviousDisplayOrder
			ImagePickerExternalPreviousDisplayOrder = nil
		end

		ImagePickerExternalRequestId = nil
		ImagePickerExternalTargetText = nil
		ImagePickerExternalCurrentValue = nil
		ImagePickerExternalDefaultQuery = nil
		ImagePickerExternalLayoutMode = nil
		ImagePickerExternalAspectRatio = nil
		ImagePickerExternalDefaultImage = nil
	end
end

local function getViewportSize() -- 4 equivalent calls inferred from this helper
	if parent2.AbsoluteSize.X > 0 and parent2.AbsoluteSize.Y > 0 then
		return parent2.AbsoluteSize
	end

	CurrentCamera = Workspace.CurrentCamera
	return CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1280, 720)
end

function updateImagePickerLayout()
	if not ImagePickerPanel then
		return
	end

	local viewportSize = getViewportSize() -- inferred equivalent call
	local v18 = viewportSize.X < 620 or viewportSize.Y < 470
	local v19 = v18 and 14 or 28
	local v20 = math.min(v18 and 500 or 540, (math.max(300, viewportSize.X - v19 * 2)))
	local v21 = math.min(v18 and 390 or 410, (math.max(300, viewportSize.Y - v19 * 2)))
	local v22 = v18 and 14 or 18
	local v23 = v18 and 12 or 16
	local v24 = v18 and 32 or 36
	ImagePickerPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	ImagePickerPanel.Position = UDim2.fromScale(0.5, 0.5)
	ImagePickerPanel.Size = UDim2.fromOffset(v20, v21)
	ImagePickerPanel.BackgroundColor3 = Color3.fromRGB(30, 37, 45)
	ImagePickerPanel.BackgroundTransparency = 0
	local title2 = ImagePickerPanel:FindFirstChild("Title")

	if title2 and title2:IsA("TextLabel") then
		title2.Position = UDim2.fromOffset(v22, v23)
		title2.Size = UDim2.new(1, -(v22 * 2 + v24 + 12), 0, v18 and 24 or 28)
		title2.TextSize = v18 and 18 or 20
	end

	local targetLabel = ImagePickerPanel:FindFirstChild("TargetLabel")

	if targetLabel and targetLabel:IsA("TextLabel") then
		targetLabel.Position = UDim2.fromOffset(v22, v23 + (v18 and 25 or 28))
		targetLabel.Size = UDim2.new(1, -(v22 * 2 + v24 + 12), 0, 18)
		targetLabel.TextSize = 12
	end

	local close3 = ImagePickerPanel:FindFirstChild("Close")

	if close3 and close3:IsA("GuiButton") then
		close3.AnchorPoint = Vector2.new(1, 0)
		close3.Position = UDim2.new(1, -v22, 0, v23 - 2)
		close3.Size = UDim2.fromOffset(v24, v24)
	end

	local v25 = v23 + (v18 and 58 or 62)
	local v26 = v18 and 36 or 40
	local v27 = v18 and 92 or 110

	if ImagePickerSearchBox and ImagePickerSearchBox:IsA("TextBox") then
		ImagePickerSearchBox.Position = UDim2.fromOffset(v22, v25)
		ImagePickerSearchBox.Size = UDim2.new(1, -(v22 * 2 + v27 + 10), 0, v26)
		ImagePickerSearchBox.BackgroundColor3 = Color3.fromRGB(244, 244, 246)
		ImagePickerSearchBox.TextColor3 = Color3.fromRGB(38, 44, 52)
		ImagePickerSearchBox.PlaceholderColor3 = Color3.fromRGB(143, 143, 148)
		ImagePickerSearchBox.TextSize = v18 and 14 or 15
	end

	if ImagePickerSearchButton and ImagePickerSearchButton:IsA("TextButton") then
		ImagePickerSearchButton.AnchorPoint = Vector2.new(1, 0)
		ImagePickerSearchButton.Position = UDim2.new(1, -v22, 0, v25)
		ImagePickerSearchButton.Size = UDim2.fromOffset(v27, v26)
		ImagePickerSearchButton.TextSize = v18 and 12 or 13
	end

	local v28 = v25 + v26 + 34

	if ImagePickerLoadingLabel and ImagePickerLoadingLabel:IsA("TextLabel") then
		ImagePickerLoadingLabel.Position = UDim2.fromOffset(v22, v25 + v26 + 9)
		ImagePickerLoadingLabel.Size = UDim2.new(1, -v22 * 2, 0, 20)
	end

	if ImagePickerGrid and ImagePickerGrid:IsA("ScrollingFrame") then
		ImagePickerGrid.Position = UDim2.fromOffset(v22, v28)
		ImagePickerGrid.Size = UDim2.new(1, -v22 * 2, 1, -(v28 + v22))
		local uiGridLayout = ImagePickerGrid:FindFirstChildOfClass("UIGridLayout")

		if uiGridLayout then
			uiGridLayout.CellPadding = UDim2.fromOffset(8, 8)

			if isCardBackgroundImagePicker() then
				local v29 = math.max(220, v20 - v22 * 2 - 16)
				local v30 = v20 < 420 and 1 or 2
				local v31 = math.floor((v29 - 8 * (v30 - 1)) / v30)
				local v32 = math.max(52, (math.round(v31 / getImagePickerCardAspectRatio())))
				uiGridLayout.CellSize = UDim2.fromOffset(v31, v32)
			else
				uiGridLayout.CellSize = UDim2.fromOffset(v18 and 78 or 90, v18 and 78 or 90)
			end
		end
	end
end

local function fitPanelToViewport(commentsPanel2, vector2, vector2_2, p, p2)
	local viewportSize = getViewportSize() -- inferred equivalent call
	local v18 = viewportSize.X < 520 and 10 or 28
	local v19 = math.max(260, viewportSize.X - v18 * 2)
	local v20 = math.max(300, viewportSize.Y - v18 * 2)
	local v21 = math.min(vector2.X, math.floor(viewportSize.X * p), v19)
	local v22 = math.min(vector2.Y, math.floor(viewportSize.Y * p2), v20)
	local v23 = math.max(v21, (math.min(vector2_2.X, v19)))
	local v24 = math.max(v22, (math.min(vector2_2.Y, v20)))
	commentsPanel2.AnchorPoint = Vector2.new(0.5, 0.5)
	commentsPanel2.Position = UDim2.fromScale(0.5, 0.5)
	commentsPanel2.Size = UDim2.fromOffset(v23, v24)
	return v23, v24
end

local vector2 = Vector2.new(560, 520)
PROFILE_PANEL_MAX_SCALE = 1.18
local function updateProfilePanelScale() -- 1 equivalent call inferred from this helper
	local viewportSize = getViewportSize() -- inferred equivalent call
	local v18 = viewportSize.X < 520 and 14 or 32
	local v19 = math.max(1, viewportSize.X - v18 * 2)
	local v20 = math.max(1, viewportSize.Y - v18 * 2)
	local v21 = math.min(PROFILE_PANEL_MAX_SCALE, v19 / vector2.X, v20 / vector2.Y)
	responsiveScale.Scale = math.max(0.45, v21)
end

local function updateResponsiveLayout(_)
	local v18 = fitPanelToViewport(commentsPanel, Vector2.new(700, 620), Vector2.new(300, 360), 0.92, 0.9)
	local v19 = v18 < 500
	local v20 = v19 and 12 or 18
	local v21 = v19 and 56 or 62
	local v22 = v19 and 36 or 40
	local v23 = composer.Visible and (v19 and 188 or 154) or 0

	header2.Size = UDim2.new(1, 0, 0, v21)
	title.Position = UDim2.fromOffset(v20, v19 and 8 or 10)
	title.Size = UDim2.new(1, -(v19 and 174 or 250), 0, 24)
	subtitle.Position = UDim2.fromOffset(v20, v19 and 31 or 34)
	subtitle.Size = UDim2.new(1, -(v19 and 174 or 250), 0, 18)
	addComment.Position = UDim2.new(1, -(v19 and 54 or 62), 0, v19 and 10 or 12)
	addComment.Size = UDim2.fromOffset(v19 and 112 or 122, v19 and 32 or 34)
	close2.Position = UDim2.new(1, -(v19 and 12 or 16), 0, v19 and 10 or 12)
	close2.Size = UDim2.fromOffset(v19 and 32 or 34, v19 and 32 or 34)

	search.Position = UDim2.fromOffset(v20, v21 + 10)
	search.Size = UDim2.new(1, -v20 * 2, 0, v22)

	composer.AnchorPoint = Vector2.new(0, 1)
	composer.Position = UDim2.new(0, v20, 1, -v20)
	composer.Size = UDim2.new(1, -v20 * 2, 0, (math.max(1, v23)))

	local v24 = v21 + 10 + v22 + 12
	local v25

	if composer.Visible then
		v25 = v23 + v20 * 2 + 10 or v20
	else
		v25 = v20
	end

	list.Position = UDim2.fromOffset(v20, v24)
	list.Size = UDim2.new(1, -v20 * 2, 1, -(v24 + v25))

	updateProfileActionRowLayout()
	local v26 = v19 and 12 or 14
	local v27 = v19 and 30 or 32
	commentBox.Position = UDim2.fromOffset(v26, 12)
	commentBox.Size = UDim2.new(1, -v26 * 2, 0, v19 and 66 or 72)
	characterCount.Position = UDim2.new(1, -(v26 + 10), 0, 17)

	if v19 then
		selectedReaction.Position = UDim2.fromOffset(v26, 88)
		selectedReaction.Size = UDim2.new(1, -v26 * 2, 0, v27)
		polarityToggle.Position = UDim2.fromOffset(v26, 126)
		polarityToggle.Size = UDim2.fromOffset(94, v27)
		submit.Position = UDim2.new(1, -v26, 0, 126)
		submit.Size = UDim2.fromOffset(math.min(158, (math.max(128, v18 - v20 * 2 - v26 * 2 - 108))), v27)
		reactions.Position = UDim2.fromOffset(v26, 14)
		reactions.Size = UDim2.new(1, -v26 * 2, 0, 70)
	else
		selectedReaction.Position = UDim2.fromOffset(20, 104)
		selectedReaction.Size = UDim2.fromOffset(196, v27)
		polarityToggle.Position = UDim2.fromOffset(226, 104)
		polarityToggle.Size = UDim2.fromOffset(94, v27)
		submit.Position = UDim2.new(1, -20, 0, 104)
		submit.Size = UDim2.fromOffset(158, v27)
		reactions.Position = UDim2.fromOffset(20, 28)
		reactions.Size = UDim2.fromOffset(196, 70)
	end

	for _, v28 in ipairs(buttons) do
		v28.Size = v19 and UDim2.new(1, 0, 0, v27) or UDim2.fromOffset(196, v27)
	end

	updateProfilePanelScale() -- inferred equivalent call
	updateImagePickerLayout()
end

local function isInvisiblePlayer(player, p)
	if not player then
		return false
	end

	if
		LocalPlayer:GetAttribute("HideOtherPlayers") == true and player ~= LocalPlayer
		or player ~= LocalPlayer and LocalPlayer:GetAttribute("HiddenPlayerChat_" .. tostring(player.UserId)) == true
	then
		return true
	end

	if player:GetAttribute("IsInvisible") == true then
		return true
	end

	local v18 = p or player.Character
	return v18 and v18:GetAttribute("IsInvisible") == true
end

local function getCharacterTargetFromPart(instance)
	while instance and instance ~= Workspace do
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter and playerFromCharacter ~= LocalPlayer then
			if isInvisiblePlayer(playerFromCharacter, instance) then
				return nil, nil
			end

			return playerFromCharacter, instance
		end

		instance = instance.Parent
	end

	return nil, nil
end

local function getPianoZoneAncestor(instance)
	local pianos = Workspace:FindFirstChild("Pianos")

	while instance and instance ~= Workspace do
		if instance.Name == "Zone" and pianos and instance:IsDescendantOf(pianos) then
			return instance
		end

		instance = instance.Parent
	end

	return nil
end

local function getProfileRaycastTarget()
	CurrentCamera = Workspace.CurrentCamera

	if not CurrentCamera then
		return nil, nil
	end

	local viewportPointToRay = CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
	local filterDescendantsInstances = {}

	if LocalPlayer.Character then
		table.insert(filterDescendantsInstances, LocalPlayer.Character)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.IgnoreWater = true

	for _ = 1, 12 do
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local raycastResult = Workspace:Raycast(
			viewportPointToRay.Origin,
			viewportPointToRay.Direction * 500,
			raycastParams
		)

		if not raycastResult then
			return nil, nil
		end

		local characterTargetFromPart, v18 = getCharacterTargetFromPart(raycastResult.Instance)

		if characterTargetFromPart then
			return characterTargetFromPart, v18
		end

		local pianoZoneAncestor = getPianoZoneAncestor(raycastResult.Instance)

		if not pianoZoneAncestor then
			return nil, nil
		end

		table.insert(filterDescendantsInstances, pianoZoneAncestor)
	end

	return nil, nil
end

local function setHoverHighlight(instance)
	local playerFromCharacter = instance and Players:GetPlayerFromCharacter(instance)

	if
		not playerFromCharacter
		or playerFromCharacter == LocalPlayer
		or not instance:IsDescendantOf(Workspace)
		or isInvisiblePlayer(playerFromCharacter, instance)
	then
		instance = nil
	end

	if v16 == instance and v15 and v15.Parent and v15.Adornee == instance and v15.Enabled == (instance ~= nil) then
		return
	end

	if v15 then
		v15:Destroy()
		v15 = nil
	end

	v16 = nil

	if instance then
		v16 = instance
		v15 = createHoverHighlight(instance)
	end
end

local function getMouseTargetPlayer() -- 1 equivalent call inferred from this helper
	return getProfileRaycastTarget()
end

local function positionTooltip(p, p2)
	if not p or isInvisiblePlayer(p, p2) then
		tooltip.Visible = false
		return
	end

	CurrentCamera = Workspace.CurrentCamera
	local viewportSize = CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local mouseLocation = UserInputService:GetMouseLocation()
	local v18 = tooltip.AbsoluteSize

	if v18.X <= 0 or v18.Y <= 0 then
		v18 = Vector2.new(230, 62)
	end

	local vector2_2 = Vector2.new(18, 18)
	local v19 = mouseLocation.X + vector2_2.X
	local v20 = mouseLocation.Y + vector2_2.Y

	if v19 + v18.X > viewportSize.X - 10 then
		v19 = mouseLocation.X - v18.X - vector2_2.X
	end

	if v20 + v18.Y > viewportSize.Y - 10 then
		v20 = mouseLocation.Y - v18.Y - vector2_2.Y
	end

	tooltip.Position = UDim2.fromOffset(math.max(10, v19), (math.max(10, v20)))
	tooltip.Visible = true
end

local function setTooltipPlayer(mouseTargetPlayer)
	if mouseTargetPlayer and not isInvisiblePlayer(mouseTargetPlayer) then
		if userId ~= mouseTargetPlayer.UserId then
			userId = mouseTargetPlayer.UserId
			local avatar2 = tooltip.Avatar
			local userId2 = tonumber(mouseTargetPlayer.UserId) or 0
			local result

			if v9[userId2] then
				result = v9[userId2]
			else
				local success
				success, result = pcall(function()
					return Players:GetUserThumbnailAsync(
						userId2,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size150x150
					)
				end)

				if success and result then
					v9[userId2] = result
				else
					result = ""
				end
			end

			avatar2.Image = result
			tooltip.DisplayName.Text = mouseTargetPlayer.DisplayName
			tooltip.Username.Text = "@" .. mouseTargetPlayer.Name
		end

		positionTooltip(mouseTargetPlayer, mouseTargetPlayer.Character)
	else
		tooltip.Visible = false
		userId = nil
		setHoverHighlight(nil)
	end
end

function ensureActionTooltip()
	if ActionTooltip and ActionTooltip.Parent then
		return ActionTooltip
	end

	ActionTooltip = parent2:FindFirstChild("ActionTooltip")

	if not ActionTooltip then
		warn("[PlayerProfileClient] Missing PlayerProfileGui.ActionTooltip")
	end

	return ActionTooltip
end

function resolveActionTooltipText(value)
	if type(value) == "function" then
		local success, result = pcall(value)

		if success and type(result) == "string" and result ~= "" then
			return result
		end
	elseif type(value) == "string" and value ~= "" then
		return value
	end

	return "Action"
end

function positionActionTooltip(guiObject)
	local actionTooltip = ensureActionTooltip()

	if not actionTooltip then
		return
	end

	CurrentCamera = Workspace.CurrentCamera
	local viewportSize = CurrentCamera and CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local v18 = actionTooltip.AbsoluteSize

	if v18.X <= 0 or v18.Y <= 0 then
		v18 = Vector2.new(176, 34)
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local vector2_2 = Vector2.new(16, 18)
	local v19 = mouseLocation.X + vector2_2.X
	local v20 = mouseLocation.Y + vector2_2.Y

	if v19 + v18.X > viewportSize.X - 10 then
		v19 = mouseLocation.X - v18.X - vector2_2.X
	end

	if v20 + v18.Y > viewportSize.Y - 10 then
		v20 = mouseLocation.Y - v18.Y - vector2_2.Y
	end

	if
		(not mouseLocation or mouseLocation.X <= 0 and mouseLocation.Y <= 0)
		and guiObject
		and guiObject:IsA("GuiObject")
	then
		local absolutePosition = guiObject.AbsolutePosition
		local absoluteSize = guiObject.AbsoluteSize
		v19 = absolutePosition.X + absoluteSize.X + 8
		v20 = absolutePosition.Y + absoluteSize.Y * 0.5 - v18.Y * 0.5
	end

	local v21 = math.clamp(v19, 10, (math.max(10, viewportSize.X - v18.X - 10)))
	local v22 = math.clamp(v20, 10, (math.max(10, viewportSize.Y - v18.Y - 10)))
	actionTooltip.Position = UDim2.fromOffset(v21, v22)
end

function showActionTooltip(p, p2)
	local actionTooltip = ensureActionTooltip()

	if not actionTooltip then
		return
	end

	local text = actionTooltip:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.Text = resolveActionTooltipText(p2)
	end

	positionActionTooltip(p)
	actionTooltip.Visible = true
end

function hideActionTooltip()
	if ActionTooltip then
		ActionTooltip.Visible = false
	end
end

function getHiddenProfileAttributeName(p)
	return "HiddenPlayerChat_" .. tostring((math.floor(tonumber(p) or 0)))
end

function isProfileUserHidden(p): boolean
	return LocalPlayer:GetAttribute(getHiddenProfileAttributeName(p)) == true
end

function updateHidePlayerChatButton()
	local v18 = v3 and isProfileUserHidden(v3.UserId)
	local v19 = v18 and "Unhide Player & Chat" or "Hide Player & Chat"

	if ActionBarHidePlayerChatButton and ActionBarHidePlayerChatButton:IsA("GuiObject") then
		ActionBarHidePlayerChatButton:SetAttribute("TooltipText", v19)
		ActionBarHidePlayerChatButton:SetAttribute("VisibleIcon", HIDE_PLAYER_CHAT_VISIBLE_ICON)
		ActionBarHidePlayerChatButton:SetAttribute("HiddenIcon", HIDE_PLAYER_CHAT_HIDDEN_ICON)
		ActionBarHidePlayerChatButton.BackgroundColor3 = Color3.fromRGB(56, 63, 70)
		local uiStroke = ActionBarHidePlayerChatButton:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Color = Color3.fromRGB(94, 106, 122)
		end

		local HIDE_PLAYER_CHAT_HIDDEN_ICON = v18 and HIDE_PLAYER_CHAT_HIDDEN_ICON or HIDE_PLAYER_CHAT_VISIBLE_ICON
		local icon = ActionBarHidePlayerChatButton:FindFirstChild("Icon")

		if icon and icon:IsA("ImageLabel") then
			icon.Image = HIDE_PLAYER_CHAT_HIDDEN_ICON
			icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		elseif ActionBarHidePlayerChatButton:IsA("ImageButton") or ActionBarHidePlayerChatButton:IsA("ImageLabel") then
			ActionBarHidePlayerChatButton.Image = HIDE_PLAYER_CHAT_HIDDEN_ICON
			ActionBarHidePlayerChatButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end

function getMutedPianoAttributeName(p)
	return "MutedPianoUser_" .. tostring((math.floor(tonumber(p) or 0)))
end

function isProfileUserPianoMuted(p): boolean
	return LocalPlayer:GetAttribute(getMutedPianoAttributeName(p)) == true
end

function stopProfileUserPianoAudio(p)
	local v18 = math.floor(tonumber(p) or 0)

	if v18 <= 0 or type(v) ~= "table" then
		return
	end

	if v.ServerStopNotesByPrefix then
		v.ServerStopNotesByPrefix("remote:" .. tostring(v18) .. ":", 0.08)
	end

	if v.ResetPianoSoundGroup then
		v.ResetPianoSoundGroup(v18)
	end
end

function updateMutePianoButton()
	local v18 = v3 and isProfileUserPianoMuted(v3.UserId)
	local v19 = v18 and "Unmute Piano Sounds" or "Mute Piano Sounds"

	if ActionBarMutePianoButton and ActionBarMutePianoButton:IsA("GuiObject") then
		ActionBarMutePianoButton:SetAttribute("TooltipText", v19)
		ActionBarMutePianoButton:SetAttribute("UnmutedIcon", MUTE_PLAYER_PIANO_NORMAL_ICON)
		ActionBarMutePianoButton:SetAttribute("MutedIcon", MUTE_PLAYER_PIANO_MUTED_ICON)
		ActionBarMutePianoButton.BackgroundColor3 = v18 and Color3.fromRGB(87, 57, 47) or Color3.fromRGB(56, 63, 70)
		local uiStroke = ActionBarMutePianoButton:FindFirstChildOfClass("UIStroke")

		if uiStroke then
			uiStroke.Color = v18 and Color3.fromRGB(255, 142, 88) or Color3.fromRGB(94, 106, 122)
		end

		local MUTE_PLAYER_PIANO_MUTED_ICON = v18 and MUTE_PLAYER_PIANO_MUTED_ICON or MUTE_PLAYER_PIANO_NORMAL_ICON
		local icon = ActionBarMutePianoButton:FindFirstChild("Icon")

		if icon and icon:IsA("ImageLabel") then
			icon.Image = MUTE_PLAYER_PIANO_MUTED_ICON
			icon.ImageColor3 = v18 and Color3.fromRGB(255, 220, 205) or Color3.fromRGB(255, 255, 255)
		elseif ActionBarMutePianoButton:IsA("ImageButton") or ActionBarMutePianoButton:IsA("ImageLabel") then
			ActionBarMutePianoButton.Image = MUTE_PLAYER_PIANO_MUTED_ICON
			ActionBarMutePianoButton.ImageColor3 = v18 and Color3.fromRGB(255, 220, 205)
				or Color3.fromRGB(255, 255, 255)
		end
	end
end

function setProfileActionButtonVisible(guiObject, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.Visible = p == true
	guiObject.Active = p == true

	if guiObject:IsA("GuiButton") then
		guiObject.AutoButtonColor = p == true
	end
end

function isProfileActionButtonVisible(guiObject)
	return guiObject and guiObject:IsA("GuiObject") and guiObject.Visible == true
end

function updateProfileActionBarVisible()
	if ProfileActionBar and ProfileActionBar:IsA("GuiObject") then
		ProfileActionBar.Visible = isProfileActionButtonVisible(ActionBarFriendRequestButton)
			or isProfileActionButtonVisible(ActionBarExamineAvatarButton)
			or isProfileActionButtonVisible(ActionBarBlockButton)
			or isProfileActionButtonVisible(ActionBarHidePlayerChatButton)
			or isProfileActionButtonVisible(ActionBarMutePianoButton)
	end
end

function updateProfileActionRowLayout()
	local guiObjects = {}

	for _, guiObject in ipairs({ donate, comments, ViewUploadsButton, saveBio }) do
		if guiObject and guiObject:IsA("GuiObject") and guiObject.Visible == true then
			table.insert(guiObjects, guiObject)
		end
	end

	local count = #guiObjects

	if count <= 0 then
		return
	end

	local v18 = math.clamp(
		math.floor((math.max(320, actionRow.AbsoluteSize.X > 0 and actionRow.AbsoluteSize.X or 420) - (count - 1) * 8) / count),
		76,
		116
	)

	for _, v19 in ipairs(guiObjects) do
		v19.Size = UDim2.fromOffset(v18, 34)
	end
end

function connectProfileActionButton(guiObject, onMouseButton1Click, p)
	if not (guiObject and guiObject:IsA("GuiObject")) then
		return
	end

	guiObject.Active = true
	guiObject:SetAttribute("TooltipText", resolveActionTooltipText(guiObject:GetAttribute("TooltipText") or p))

	if guiObject:IsA("GuiButton") then
		guiObject.Selectable = true
	end

	guiObject.MouseEnter:Connect(function()
		showActionTooltip(guiObject, function()
			return guiObject:GetAttribute("TooltipText") or resolveActionTooltipText(p)
		end)
	end)
	guiObject.MouseMoved:Connect(function()
		positionActionTooltip(guiObject)
	end)
	guiObject.MouseLeave:Connect(hideActionTooltip)
	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			showActionTooltip(guiObject, function()
				return guiObject:GetAttribute("TooltipText") or resolveActionTooltipText(p)
			end)

			task.delay(1.6, hideActionTooltip)
		end
	end)

	if guiObject:IsA("GuiButton") then
		guiObject.MouseButton1Click:Connect(onMouseButton1Click)
	else
		guiObject.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				onMouseButton1Click()
			end
		end)
	end
end

local function setReputationVisual(score)
	local v18 = math.floor(tonumber(score) or 0)
	reputationBadge.Text = formatRep(v18) -- inferred equivalent call

	if v18 < 0 then
		reputationBadge.BackgroundColor3 = Color3.fromRGB(214, 48, 48)
	elseif v18 > 0 then
		reputationBadge.BackgroundColor3 = Color3.fromRGB(60, 196, 106)
	else
		reputationBadge.BackgroundColor3 = Color3.fromRGB(30, 37, 45)
	end
end

function setThumbButtonVisual(guiObject, p, p2, p3)
	if not guiObject then
		return
	end

	local count = guiObject:FindFirstChild("Count") or guiObject:FindFirstChild("ThumbsCount")

	if count and count:IsA("TextLabel") then
		count.Text = formatCompactCount(p)
	end

	if guiObject:IsA("GuiObject") then
		local backgroundColor = guiObject:GetAttribute("DefaultThumbBackgroundColor")

		if typeof(backgroundColor) ~= "Color3" then
			backgroundColor = guiObject.BackgroundColor3
			guiObject:SetAttribute("DefaultThumbBackgroundColor", backgroundColor)
		end

		backgroundColor = p2 and THUMB_LIKED_BACKGROUND or backgroundColor
		guiObject.BackgroundColor3 = backgroundColor
	end

	local thumbsUp = guiObject:FindFirstChild("ThumbsUp")

	if thumbsUp and thumbsUp:IsA("GuiObject") then
		thumbsUp.BackgroundColor3 = p2 and THUMB_LIKED_BACKGROUND or guiObject.BackgroundColor3

		if thumbsUp:IsA("ImageLabel") or thumbsUp:IsA("ImageButton") then
			thumbsUp.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	if guiObject:IsA("GuiButton") then
		guiObject.Active = p3 == true
		guiObject.AutoButtonColor = p3 == true
	end
end

function ensureBadgeTooltip()
	if BadgeTooltip and BadgeTooltip.Parent then
		return BadgeTooltip
	end

	BadgeTooltip = parent2:FindFirstChild("BadgeTooltip")

	if BadgeTooltip then
		return BadgeTooltip
	end

	BadgeTooltip = Instance.new("Frame")
	BadgeTooltip.Name = "BadgeTooltip"
	BadgeTooltip.AnchorPoint = Vector2.new(0, 0)
	BadgeTooltip.BackgroundColor3 = Color3.fromRGB(28, 34, 42)
	BadgeTooltip.BorderSizePixel = 0
	BadgeTooltip.Size = UDim2.fromOffset(260, 82)
	BadgeTooltip.Visible = false
	BadgeTooltip.ZIndex = 80
	BadgeTooltip.Parent = parent2

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = BadgeTooltip

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(76, 91, 110)
	uiStroke.Thickness = 1
	uiStroke.Parent = BadgeTooltip

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.BackgroundColor3 = Color3.fromRGB(36, 45, 56)
	icon.BorderSizePixel = 0
	icon.Position = UDim2.fromOffset(10, 10)
	icon.Size = UDim2.fromOffset(44, 44)
	icon.ZIndex = 81
	icon.Parent = BadgeTooltip

	local uiCorner2 = Instance.new("UICorner")
	uiCorner2.CornerRadius = UDim.new(0, 8)
	uiCorner2.Parent = icon

	local title2 = Instance.new("TextLabel")
	title2.Name = "Title"
	title2.BackgroundTransparency = 1
	title2.Font = Enum.Font.GothamBold
	title2.Position = UDim2.fromOffset(64, 9)
	title2.Size = UDim2.new(1, -76, 0, 20)
	title2.TextColor3 = Color3.fromRGB(238, 244, 255)
	title2.TextSize = 14
	title2.TextXAlignment = Enum.TextXAlignment.Left
	title2.ZIndex = 81
	title2.Parent = BadgeTooltip

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.Gotham
	description.Position = UDim2.fromOffset(64, 31)
	description.Size = UDim2.new(1, -76, 0, 38)
	description.TextColor3 = Color3.fromRGB(174, 187, 204)
	description.TextSize = 12
	description.TextWrapped = true
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.ZIndex = 81
	description.Parent = BadgeTooltip

	local badgeId = Instance.new("TextLabel")
	badgeId.Name = "BadgeId"
	badgeId.BackgroundTransparency = 1
	badgeId.Font = Enum.Font.GothamMedium
	badgeId.Position = UDim2.fromOffset(10, 58)
	badgeId.Size = UDim2.fromOffset(44, 14)
	badgeId.TextColor3 = Color3.fromRGB(120, 135, 154)
	badgeId.TextSize = 9
	badgeId.TextXAlignment = Enum.TextXAlignment.Center
	badgeId.ZIndex = 81
	badgeId.Parent = BadgeTooltip

	return BadgeTooltip
end

function hideBadgeTooltip()
	if BadgeTooltip then
		BadgeTooltip.Visible = false
	end
end

function positionBadgeTooltip()
	local badgeTooltip = ensureBadgeTooltip()

	if not badgeTooltip then
		return
	end

	local viewportSize = getViewportSize() -- inferred equivalent call
	local v18 = viewportSize.X < 520
	badgeTooltip.Size = v18 and UDim2.fromOffset(220, 86) or UDim2.fromOffset(260, 82)

	local mouseLocation = UserInputService:GetMouseLocation()
	local v19 = badgeTooltip.AbsoluteSize

	if v19.X <= 0 or v19.Y <= 0 then
		v19 = v18 and Vector2.new(220, 86) or Vector2.new(260, 82)
	end

	local v20 = mouseLocation.X + 16
	local v21 = mouseLocation.Y + 16

	if v20 + v19.X > viewportSize.X - 10 then
		v20 = mouseLocation.X - v19.X - 16
	end

	if v21 + v19.Y > viewportSize.Y - 10 then
		v21 = mouseLocation.Y - v19.Y - 16
	end

	badgeTooltip.Position = UDim2.fromOffset(math.max(10, v20), (math.max(10, v21)))
end

function showBadgeTooltip(instance)
	if not (instance and instance.Visible) then
		return
	end

	local badgeTooltip = ensureBadgeTooltip()

	if not badgeTooltip then
		return
	end

	local title2 = badgeTooltip:FindFirstChild("Title")
	local description = badgeTooltip:FindFirstChild("Description")
	local icon = badgeTooltip:FindFirstChild("Icon")
	local badgeId = badgeTooltip:FindFirstChild("BadgeId")
	local badgeId2 = math.floor(tonumber(instance:GetAttribute("BadgeId")) or 0)

	if icon and icon:IsA("ImageLabel") then
		icon.Image = instance.Image or ""
	end

	if title2 and title2:IsA("TextLabel") then
		title2.Text = tostring(instance:GetAttribute("BadgeName") or "Game Badge")
	end

	if description and description:IsA("TextLabel") then
		description.Text = tostring(instance:GetAttribute("BadgeDescription") or "")
	end

	if badgeId and badgeId:IsA("TextLabel") then
		badgeId.Text = badgeId2 > 0 and "#" .. tostring(badgeId2) or ""
	end

	positionBadgeTooltip()
	badgeTooltip.Visible = true
end

function connectBadgeSlot(instance)
	if not instance or instance:GetAttribute("BadgeHoverConnected") == true then
		return
	end

	instance:SetAttribute("BadgeHoverConnected", true)
	instance.Active = true
	instance.MouseEnter:Connect(function()
		showBadgeTooltip(instance)
	end)
	instance.MouseMoved:Connect(function()
		if BadgeTooltip and BadgeTooltip.Visible then
			positionBadgeTooltip()
		end
	end)
	instance.MouseLeave:Connect(hideBadgeTooltip)
	instance.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			BadgeTooltipTouchToken += 1
			local badgeTooltipTouchToken = BadgeTooltipTouchToken
			showBadgeTooltip(instance)
			task.delay(2.5, function()
				if badgeTooltipTouchToken == BadgeTooltipTouchToken then
					hideBadgeTooltip()
				end
			end)
		end
	end)
end

function renderGameBadges(p)
	if not GameBadgeSection then
		return
	end

	local gameBadges = type(p and p.GameBadges) == "table" and p.GameBadges or {}
	local v18 = math.max(0, (math.floor(tonumber(ProfileSystemConfig.MaxProfileBadges) or 8)))

	for _, guiObject in ipairs(GameBadgeSection:GetChildren()) do
		if not (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) then
			continue
		end

		guiObject.Visible = false

		if guiObject.Name == "BadgeTemplate" then
			continue
		end

		guiObject.Image = ""
		guiObject:SetAttribute("BadgeId", nil)
		guiObject:SetAttribute("BadgeName", nil)
		guiObject:SetAttribute("BadgeDescription", nil)
	end

	local count = 0

	for _, gameBadge in ipairs(gameBadges) do
		if v18 <= count then
			break
		end

		local badgeId = math.floor(tonumber(gameBadge.BadgeId or gameBadge.Id) or 0)
		local iconImage = tostring(gameBadge.IconImage or gameBadge.Image or "")

		if not (badgeId > 0 and iconImage ~= "") then
			continue
		end

		count += 1
		local guiObject = GameBadgeSection:FindFirstChild("BadgeSlot" .. tostring(count))

		if not guiObject then
			local badgeTemplate = GameBadgeSection:FindFirstChild("BadgeTemplate")

			if badgeTemplate and (badgeTemplate:IsA("ImageLabel") or badgeTemplate:IsA("ImageButton")) then
				guiObject = badgeTemplate:Clone()
				guiObject.Name = "BadgeSlot" .. tostring(count)
				guiObject.Parent = GameBadgeSection
			end
		end

		if not (guiObject and (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton"))) then
			continue
		end

		guiObject.Image = iconImage
		guiObject:SetAttribute("BadgeId", badgeId)
		guiObject:SetAttribute("BadgeName", (tostring(gameBadge.Name or "Game Badge")))
		guiObject:SetAttribute("BadgeDescription", (tostring(gameBadge.Description or "")))
		guiObject.Visible = true
		connectBadgeSlot(guiObject)
	end

	GameBadgeSection.Visible = count > 0

	if count <= 0 then
		hideBadgeTooltip()
	end
end

local function getReactionByMagnitude(p, p2)
	local v18 = math.abs((math.floor(tonumber(p) or 0)))

	for _, v19 in ipairs(ProfileSystemConfig.Reactions or {}) do
		local rep = math.floor(tonumber(v19.Rep) or 0)

		if math.abs(rep) == v18 and (rep >= 0) == (p2 == true) then
			return v19
		end
	end

	return nil
end

local function getSelectedReactionConfig() -- 1 equivalent call inferred from this helper
	if v4 then
		return getReactionByMagnitude(v4, v5)
	end

	if id then
		return ProfileSystemConfig.ReactionById and ProfileSystemConfig.ReactionById[id] or nil
	end

	return nil
end

local function updateSubmitCostText() -- 14 equivalent calls inferred from this helper
	if v7 then
		submit.Text = "Submitting..."
		return
	end

	local selectedReactionConfig = getSelectedReactionConfig() -- inferred equivalent call
	local v18 = selectedReactionConfig and math.max(0, (math.floor(tonumber(selectedReactionConfig.Cost) or 0))) or 0
	submit.Text = v18 > 0 and "Submit (" .. tostring(v18) .. " Notes)" or "Submit"
end

local function setCommentSubmitting(p)
	v7 = p == true
	submit.Active = not v7
	submit.AutoButtonColor = not v7
	submit.BackgroundTransparency = v7 and 0.35 or 0
	updateSubmitCostText() -- inferred equivalent call
end

local function formatReactionButtonText(data) -- 2 equivalent calls inferred from this helper
	if data then
		return string.format(
			"%s (%+d) %d Notes",
			data.ShortLabel or data.Label or data.Id,
			tonumber(data.Rep) or 0,
			tonumber(data.Cost) or 0
		)
	end

	return "Choose Reaction"
end

local function updateReactionDropdown()
	local visible = reactions.Visible == true
	local count = 0

	for _, parent in ipairs(buttons) do
		local reactionMagnitude = parent:GetAttribute("ReactionMagnitude")
		local reactionByMagnitude = getReactionByMagnitude(reactionMagnitude, v5)

		if reactionByMagnitude then
			local v18 = math.abs(tonumber(reactionMagnitude) or 0) == math.abs(tonumber(v4) or 0)
			local visible2 = visible and not v18

			if visible2 then
				count += 1
				parent.LayoutOrder = count
			end

			parent.Visible = visible2
			parent.Text = formatReactionButtonText(reactionByMagnitude) -- inferred equivalent call
			parent.BackgroundColor3 = reactionByMagnitude.Color or Color3.fromRGB(52, 60, 72)
			parent.TextWrapped = false
			parent:SetAttribute("ReactionId", reactionByMagnitude.Id)
			parent.BackgroundTransparency = 0
			parent.TextTransparency = 0
			local selectedStroke = parent:FindFirstChild("SelectedStroke")

			if not selectedStroke then
				selectedStroke = Instance.new("UIStroke")
				selectedStroke.Name = "SelectedStroke"
				selectedStroke.Thickness = 1
				selectedStroke.Color = Color3.fromRGB(255, 255, 255)
				selectedStroke.Parent = parent
			end

			selectedStroke.Transparency = 0.75
			selectedStroke.Enabled = true
		else
			parent.Visible = false
		end
	end
end

local function applyReactionSelection(p)
	local v18 = ProfileSystemConfig.ReactionById and ProfileSystemConfig.ReactionById[p]

	if not v18 then
		return
	end

	local rep = math.floor(tonumber(v18.Rep) or 0)
	v4 = math.abs(rep)
	v5 = rep >= 0
	id = v18.Id
	selectedReaction.Text = formatReactionButtonText(v18) -- inferred equivalent call
	selectedReaction.BackgroundColor3 = v18.Color or Color3.fromRGB(52, 60, 72)
	polarityToggle.Text = v5 and "+ Rep" or "- Rep"
	polarityToggle.BackgroundColor3 = v5 and Color3.fromRGB(64, 168, 96) or Color3.fromRGB(202, 73, 86)
	reactions.Visible = false
	updateReactionDropdown()
	updateSubmitCostText() -- inferred equivalent call
end

local function setupReactionButtons()
	buttons = {}
	local set = {}
	local v18 = nil

	for _, button in ipairs(reactions:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local reactionId = button:GetAttribute("ReactionId") or button.Name
		local v19 = ProfileSystemConfig.ReactionById and ProfileSystemConfig.ReactionById[reactionId]
		local rep = v19 and math.floor(tonumber(v19.Rep) or 0) or 0
		local v20 = math.abs(rep)

		if v19 and rep >= 0 and not set[v20] then
			set[v20] = true
			button.Visible = false
			button.Size = UDim2.fromOffset(196, 32)
			button.TextSize = 12
			button.TextWrapped = false
			button:SetAttribute("ReactionMagnitude", v20)
			table.insert(buttons, button)
			v18 = v18 or v19.Id
			button.MouseButton1Click:Connect(function()
				local reactionByMagnitude = getReactionByMagnitude(button:GetAttribute("ReactionMagnitude"), v5)

				if reactionByMagnitude then
					applyReactionSelection(reactionByMagnitude.Id)
					reactions.Visible = false
				end
			end)
		else
			button.Visible = false
		end
	end

	table.sort(buttons, function(a, b): boolean
		return (tonumber(a:GetAttribute("ReactionMagnitude")) or 0) < (tonumber(b:GetAttribute("ReactionMagnitude")) or 0)
	end)

	applyReactionSelection(v18)
	reactions.Visible = false
end

local function clearCommentRows()
	for _, v18 in ipairs(clones) do
		if v18 and v18.Parent then
			v18:Destroy()
		end
	end

	clones = {}
end

local function getRelativeTime(createdAt)
	local v18 = math.floor(tonumber(createdAt) or 0)

	if v18 <= 0 then
		return ""
	end

	local v19 = math.max(0, os.time() - v18)

	if v19 < 60 then
		return "just now"
	end

	if v19 < 3600 then
		return tostring((math.floor(v19 / 60))) .. "m ago"
	end

	if v19 < 86400 then
		return tostring((math.floor(v19 / 3600))) .. "h ago"
	end

	return tostring((math.floor(v19 / 86400))) .. "d ago"
end

local function getCommentReaction(p)
	local v18 = ProfileSystemConfig.ReactionById
		and p
		and p.ReactionId
		and ProfileSystemConfig.ReactionById[p.ReactionId]

	if v18 then
		return v18
	end

	local rep = math.floor(tonumber(p and p.Rep) or 0)

	for _, v19 in ipairs(ProfileSystemConfig.Reactions or {}) do
		if math.floor(tonumber(v19.Rep) or 0) == rep then
			return v19
		end
	end

	return nil
end

local function applyCommentRowTone(clone, data)
	local rep = math.floor(tonumber(data and data.Rep) or 0)
	local commentReaction = getCommentReaction(data)
	local color = commentReaction and commentReaction.Color
		or rep < 0 and Color3.fromRGB(255, 106, 120)
		or Color3.fromRGB(94, 255, 130)
	local v18 = rep < 0 and 0.24 or 0.18
	clone.BackgroundColor3 = Color3.fromRGB(45, 53, 61):Lerp(color, v18)
	local uiStroke = clone:FindFirstChildOfClass("UIStroke")

	if uiStroke then
		uiStroke.Color = color
		uiStroke.Transparency = 0.38
	end
end

local function getReplyName(p)
	return (tostring(p and (p.AuthorDisplayName or p.AuthorName) or "Player"))
end

local function getCommentAuthorLine(data)
	local v18 = "@" .. tostring(data and data.AuthorName or data and data.AuthorDisplayName or "Player")
	local authorGroupRankTag

	if type(data and data.AuthorGroupRankTag) == "table" then
		authorGroupRankTag = data.AuthorGroupRankTag or nil
	end

	if not authorGroupRankTag or type(authorGroupRankTag.Tag) ~= "string" or authorGroupRankTag.Tag == "" then
		return escapeRichText(v18)
	end

	local colorHex = type(authorGroupRankTag.ColorHex) == "string"
		and authorGroupRankTag.ColorHex:match("^#%x%x%x%x%x%x$")
		and authorGroupRankTag.ColorHex
		or "#FFE94F"
	return string.format("<font color=\"%s\"><b>[%s]</b></font>", colorHex, escapeRichText(authorGroupRankTag.Tag)) .. " " .. escapeRichText(v18) -- inferred equivalent call
end

local function setMutedCommentText(instance, text)
	if not (instance and instance:FindFirstChild("Text")) then
		return
	end

	instance.Text.Text = text
	instance.Text.TextColor3 = Color3.fromRGB(199, 208, 224)
	instance.Text.TextTransparency = 0
	instance.Text.TextWrapped = false

	if instance:FindFirstChild("ReplyContext") then
		instance.ReplyContext.Visible = false
	end
end

local function applyHiddenCommentContent(clone, p) -- 1 equivalent call inferred from this helper
	if p then
		setMutedCommentText(clone, "This comment has been hidden by the User")
	end
end

local function applyDeletedCommentContent(clone, data): boolean -- 1 equivalent call inferred from this helper
	if type(data) ~= "table" or data.DeletedByAuthor ~= true then
		return false
	end

	setMutedCommentText(clone, "This comment was deleted by the author")
	return true
end

local function isOwnComment(p): boolean -- 4 equivalent calls inferred from this helper
	return type(p) == "table" and tonumber(p.AuthorUserId) == LocalPlayer.UserId
end

local function setReplyTarget(data) -- 11 equivalent calls inferred from this helper
	v6 = data

	if not v6 then
		replyContext.Visible = false

		return
	end

	local v18 = v6
	label.Text = "Replying to " .. tostring(v18 and (v18.AuthorDisplayName or v18.AuthorName or "Player") or "Player")
	replyContext.Visible = true
end

local function setComposerVisible(p)
	local visible

	if p == true and v3 ~= nil then
		visible = v3.CanComment == true
	else
		visible = false
	end

	composer.Visible = visible
	reactions.Visible = false
	addComment.Text = visible and "Close Comment" or "Add Comment"

	if visible then
		replyContext.Visible = v6 ~= nil
	else
		setReplyTarget(nil) -- inferred equivalent call
		v7 = false
		submit.Active = not v7
		submit.AutoButtonColor = not v7
		submit.BackgroundTransparency = v7 and 0.35 or 0
	end

	updateSubmitCostText() -- inferred equivalent call
	updateResponsiveLayout(true)
end

local function commentMatchesQuery(data, text): boolean
	if text == "" then
		return true
	end

	local replyToDisplayName = data.ReplyToDisplayName or data.ReplyToName or ""
	return string.lower(table.concat({
		data.AuthorDisplayName or "",
		data.AuthorName or "",
		data.Text or "",
		data.ReactionLabel or "",
		replyToDisplayName
	}, " ")):find(text, 1, true) ~= nil
end

local renderComments
toggleCommentThumb = nil

function setProfileCommentHiddenState(p, button, p2)
	if not v3 or v3.IsSelf ~= true then
		return
	end

	if type(p) ~= "table" or type(p.Id) ~= "string" or p.Id == "" or v12[p.Id] then
		return
	end

	v12[p.Id] = true

	if button and button:IsA("GuiButton") then
		button.Active = false
		button.AutoButtonColor = false
	end

	local success, result = pcall(function()
		return HideProfileComment:InvokeServer(v3.UserId, p.Id, p2 == true)
	end)

	v12[p.Id] = nil

	if button and button:IsA("GuiButton") then
		button.Active = true
		button.AutoButtonColor = true
	end

	if success and type(result) == "table" and result.Ok then
		v3 = result.Profile
		renderComments(true)
	else
		notify( -- inferred equivalent call
			"Profile",
			type(result) == "table" and result.Error or p2 and "Failed to hide comment." or "Failed to unhide comment."
		)

		playProfileErrorSound()
	end
end

function setProfileCommentDeletedByAuthor(p, button)
	if type(p) ~= "table" or type(p.Id) ~= "string" or p.Id == "" then
		return
	end

	if not (isOwnComment(p) and v3) or v12[p.Id] then -- inferred equivalent call
		return
	end

	v12[p.Id] = true

	if button and button:IsA("GuiButton") then
		button.Active = false
		button.AutoButtonColor = false
	end

	local success, result = pcall(function()
		return deleteProfileComment:InvokeServer(v3.UserId, p.Id)
	end)

	v12[p.Id] = nil

	if button and button:IsA("GuiButton") then
		button.Active = true
		button.AutoButtonColor = true
	end

	if success and type(result) == "table" and result.Ok then
		v3 = result.Profile
		renderComments(true)
	else
		local err = type(result) == "table" and result.Error or "Failed to delete comment."
		notify("Profile", err) -- inferred equivalent call
		playProfileErrorSound()
	end
end

function configureCommentActionPrompt(instance, data, button)
	local commentActionPrompt = instance:FindFirstChild("CommentActionPrompt")

	if not (commentActionPrompt and commentActionPrompt:IsA("Frame")) then
		return
	end

	local title2 = commentActionPrompt:FindFirstChild("Title")
	local message = commentActionPrompt:FindFirstChild("Message")
	local confirm = commentActionPrompt:FindFirstChild("Confirm")
	local cancel = commentActionPrompt:FindFirstChild("Cancel")

	if not (button and button:IsA("ImageButton") and confirm and confirm:IsA("TextButton") and cancel and cancel:IsA("TextButton")) then
		commentActionPrompt.Visible = false
		return
	end

	local id2 = type(data.Id) == "string" and data.Id or ""
	local hiddenByProfileOwner = data.HiddenByProfileOwner == true
	local deletedByAuthor = data.DeletedByAuthor == true
	local v18 = isOwnComment(data) -- inferred equivalent call

	if v18 then
		if id2 == "" then
			v18 = false
		else
			v18 = not deletedByAuthor
		end
	end

	local v19 = v3

	if v19 then
		if v3.IsSelf == true then
			v19 = not v18

			if v19 then
				if id2 == "" then
					v19 = false
				else
					v19 = not deletedByAuthor
				end
			end
		else
			v19 = false
		end
	end

	local text2 = v18 and "Delete" or hiddenByProfileOwner and "Unhide" or "Hide"
	button.Visible = v18 or v19
	commentActionPrompt.Visible = false

	if not (v18 or v19) then
		return
	end

	local hideImage = tostring(button:GetAttribute("HideImage") or "rbxassetid://115339156116924")
	local unhideImage = tostring(button:GetAttribute("UnhideImage") or "rbxassetid://13863973385")
	button.Image = text2 == "Unhide" and unhideImage or hideImage
	button:SetAttribute("Action", text2)

	commentActionPrompt.AnchorPoint = Vector2.new(0.5, 0.5)
	commentActionPrompt.Position = UDim2.fromScale(0.5, 0.5)
	commentActionPrompt.Size = UDim2.new(1, -72, 0, 72)
	commentActionPrompt.ZIndex = math.max(commentActionPrompt.ZIndex, instance.ZIndex + 20)

	for _, guiObject in ipairs(commentActionPrompt:GetDescendants()) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex = math.max(guiObject.ZIndex, commentActionPrompt.ZIndex + 1)
		end
	end

	if title2 and title2:IsA("TextLabel") then
		title2.Text = text2 == "Delete" and "Delete comment?"
			or text2 == "Unhide" and "Unhide comment?"
			or "Hide comment?"
	end

	if message and message:IsA("TextLabel") then
		if text2 == "Delete" then
			message.Text = "This will delete your comment. This action cannot be undone."
		else
			message.Text = text2 == "Unhide" and "This will show the original comment again on your profile."
				or "The row stays, but the comment text will be hidden from your profile."
		end
	end

	confirm.Text = text2
	confirm.BackgroundColor3 = text2 == "Delete" and Color3.fromRGB(224, 50, 58)
		or text2 == "Unhide" and Color3.fromRGB(64, 168, 96)
		or Color3.fromRGB(63, 145, 255)

	button.MouseButton1Click:Connect(function()
		commentActionPrompt:SetAttribute("OpenedAt", os.clock())
		commentActionPrompt.Visible = true
	end)
	cancel.MouseButton1Click:Connect(function()
		commentActionPrompt.Visible = false
	end)
	confirm.MouseButton1Click:Connect(function()
		if os.clock() - (tonumber(commentActionPrompt:GetAttribute("OpenedAt")) or 0) < 0.2 then
			return
		end

		local text = confirm.Text
		commentActionPrompt.Visible = false
		confirm.Text = "..."

		if text2 == "Delete" then
			setProfileCommentDeletedByAuthor(data, button)
		else
			setProfileCommentHiddenState(data, button, text2 ~= "Unhide")
		end

		if confirm.Parent then
			confirm.Text = text
		end
	end)
end

local function createCommentRow(data, layoutOrder, p, p2, p3)
	local v18 = math.clamp(math.floor(tonumber(p) or 0), 0, 2)
	local v19 = math.max(0, (math.floor(tonumber(p2) or 0)))
	local v20 = p3 == true
	local id2 = type(data.Id) == "string" and data.Id or ""
	local v21

	if data.HiddenByProfileOwner == true then
		v21 = true
	elseif id2 == "" then
		v21 = false
	else
		v21 = v11[id2] == true
	end

	local v22

	if type(data) == "table" then
		v22 = data.DeletedByAuthor == true
	else
		v22 = false
	end

	local text = tostring(data.Text or "")
	local text2 = v22 and "This comment was deleted by the author"
		or v21 and "This comment has been hidden by the User"
		or text
	local visible = v18 > 0
	local visible2 = not visible and v19 > 0
	local clone = commentTemplate:Clone()
	local x = list.AbsoluteSize.X > 0 and list.AbsoluteSize.X or 640
	local v23 = x < 430
	local v24 = visible and 46 + (v18 - 1) * 26 or 0
	local v25 = visible and 36 or 46
	local v26 = visible and v24 + 12 or 10

	local v27 = v26 + v25 + 10
	local v28 = visible and 45 or 32
	local textSize2 = visible and 14 or 15
	local v29 = v3 and v3.CanComment == true and (v23 and 184 or 238) or v23 and 126 or 154
	local v30 = math.max(v23 and 116 or 220, x - v27 - v29)
	local v31 = visible and 24 or 34
	local v32 = visible and 46 or 72
	local v40 = v31
	pcall(function()
		local TextService = game:GetService("TextService")
		local textSize = TextService:GetTextSize(text2, textSize2, clone.Text.Font, Vector2.new(v30, 1000))
		v40 = math.max(v31, (math.ceil(textSize.Y)))
	end)
	local visible3

	if id2 == "" then
		visible3 = false
	else
		visible3 = not v21 and not v22 and v32 < v40
	end

	local v42 = visible3 and expandedLongComments[id2] == true
	local v43

	if visible3 then
		v43 = v42 and v40

		if not v43 then
			if v32 then
				v43 = v32
			else
				v43 = math.min(v40, v32)
			end
		end
	else
		v43 = math.min(v40, v32)
	end

	local v44 = math.max(
		visible and (v18 > 1 and 84 or 92) or visible2 and 128 or 104,
		v28 + v43 + (visible3 and 24 or 0) + (visible and 54 or 60)
	)
	local v45 = visible and v44 - 30 or (visible2 or visible3) and v44 - 58 or v44 - 33

	clone.Name = "Comment_" .. tostring(data.Id or layoutOrder)
	clone.Visible = true
	clone.LayoutOrder = layoutOrder
	clone.ClipsDescendants = false
	clone.Size = UDim2.new(1, -6, 0, v44)
	clone:SetAttribute("ProfileCommentRow", true)
	clone:SetAttribute("ThreadDepth", v18)

	local bubble = clone:FindFirstChild("Bubble")

	if bubble and bubble:IsA("Frame") then
		bubble.Visible = visible
		bubble.Position = UDim2.fromOffset(v24, 4)
		bubble.Size = UDim2.new(1, -(v24 + 8), 0, v44 - 8)
		bubble.ZIndex = clone.ZIndex + 1
		bubble.ClipsDescendants = false
	end

	clone.Avatar.Position = UDim2.fromOffset(v26, 12)
	clone.Avatar.Size = UDim2.fromOffset(v25, v25)
	local avatar2 = clone.Avatar
	local authorUserId = tonumber(data.AuthorUserId) or 0
	local result

	if v9[authorUserId] then
		result = v9[authorUserId]
	else
		local success
		success, result = pcall(function()
			return Players:GetUserThumbnailAsync(
				authorUserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)

		if success and result then
			v9[authorUserId] = result
		else
			result = ""
		end
	end

	avatar2.Image = result
	clone.Author.Position = UDim2.fromOffset(v27, visible and 9 or 10)
	clone.Author.Size = UDim2.new(1, -(v27 + 142), 0, 20)
	clone.Author.TextSize = visible and 14 or 15
	clone.Author.RichText = true
	clone.Author.TextTruncate = Enum.TextTruncate.AtEnd
	clone.Author.Text = getCommentAuthorLine(data)
	clone.Date.Position = UDim2.new(1, -92, 0, visible and 9 or 10)
	clone.Date.Text = getRelativeTime(data.CreatedAt)
	local hideComment = clone:FindFirstChild("HideComment") or clone:FindFirstChild("UnhideComment")

	if hideComment and hideComment:IsA("ImageButton") then
		configureCommentActionPrompt(clone, data, hideComment)
	end

	local unhideComment = clone:FindFirstChild("UnhideComment")

	if unhideComment and unhideComment ~= hideComment then
		unhideComment.Visible = false
	end

	clone.Text.Position = UDim2.fromOffset(v27, v28)
	clone.Text.Size = UDim2.fromOffset(v30, v43)
	clone.Text.TextSize = textSize2
	clone.Text.TextWrapped = true
	clone.Text.TextTruncate = visible3 and not v42 and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None
	clone.Text.Text = text2

	local readMoreToggle = clone:FindFirstChild("ReadMoreToggle")

	if not readMoreToggle then
		local threadToggle = clone:FindFirstChild("ThreadToggle")

		if threadToggle and threadToggle:IsA("TextButton") then
			readMoreToggle = threadToggle:Clone()
			readMoreToggle.Name = "ReadMoreToggle"
			readMoreToggle.Parent = clone
		end
	end

	if readMoreToggle and readMoreToggle:IsA("TextButton") then
		readMoreToggle.Visible = visible3
		readMoreToggle.Position = UDim2.fromOffset(v27, v28 + v43 + 3)
		readMoreToggle.Size = UDim2.fromOffset(math.min(v23 and 112 or 132, v30), 20)
		readMoreToggle.Text = v42 and "Show less" or "View more"
		readMoreToggle.TextSize = v23 and 11 or 12
		readMoreToggle.BackgroundTransparency = 1
		readMoreToggle.TextColor3 = Color3.fromRGB(176, 204, 255)

		if visible3 then
			readMoreToggle.MouseButton1Click:Connect(function()
				expandedLongComments[id2] = not v42
				renderComments(true)
			end)
		end
	end

	local replyToDisplayName = data.ReplyToDisplayName or data.ReplyToName or ""

	if clone:FindFirstChild("ReplyContext") then
		clone.ReplyContext.Position = UDim2.fromOffset(v27, 29)
		clone.ReplyContext.Size = UDim2.fromOffset(v30, 16)
		clone.ReplyContext.TextSize = 12
		clone.ReplyContext.TextColor3 = Color3.fromRGB(114, 190, 255)
		clone.ReplyContext.Visible = visible
		clone.ReplyContext.Text = visible
			and "Replying to " .. tostring((replyToDisplayName == "" or not replyToDisplayName) and "comment" or replyToDisplayName)
			or ""
	end

	if not applyDeletedCommentContent(clone, data) then -- inferred equivalent call
		local v46

		if data.HiddenByProfileOwner == true then
			v46 = true
		elseif type(data.Id) == "string" then
			v46 = v11[data.Id] == true
		else
			v46 = false
		end

		applyHiddenCommentContent(clone, v46) -- inferred equivalent call
	end

	local rep = math.floor(tonumber(data.Rep) or 0)
	clone.Rep.Position = UDim2.fromOffset(visible and v24 + 14 or 12, v45)
	clone.Rep.TextSize = visible and 13 or 14
	local rep2 = clone.Rep
	rep2.Text = formatRep(rep) -- inferred equivalent call
	clone.Rep.TextColor3 = rep < 0 and Color3.fromRGB(255, 106, 120) or Color3.fromRGB(94, 255, 130)
	clone.Reaction.Position = UDim2.fromOffset(visible and v24 + 88 or 86, v45)
	clone.Reaction.Size = UDim2.new(1, -(visible and v24 + 170 or 172), 0, 20)
	clone.Reaction.TextSize = visible and 13 or 14
	clone.Reaction.Text = tostring(data.ReactionLabel or "Comment")

	local commentThumb = clone:FindFirstChild("CommentThumb") or clone:FindFirstChild("ProfileThumbs")
	local thumbsUp = commentThumb and commentThumb:FindFirstChild("ThumbsUp")
	local count = commentThumb and commentThumb:FindFirstChild("Count") or clone:FindFirstChild("ThumbsCount")
	local v46 = math.max(0, (math.floor(tonumber(data.ThumbsUpCount or data.ThumbsUp or data.Likes or 0) or 0)))
	local v47 = v23 and 62 or 76
	local v48 = v3 and v3.CanComment == true and (v23 and 104 or 142) or 18

	if commentThumb and commentThumb:IsA("GuiObject") then
		commentThumb.Visible = true
		commentThumb.AnchorPoint = Vector2.new(1, 1)
		commentThumb.Size = UDim2.fromOffset(v47, v23 and 30 or 34)
		commentThumb.Position = UDim2.new(1, -v48, 1, -18)
		local setThumbButtonVisual = setThumbButtonVisual
		local likedByViewer = data.LikedByViewer == true
		setThumbButtonVisual(commentThumb, v46, likedByViewer, not isOwnComment(data) and data.DeletedByAuthor ~= true) -- inferred equivalent call
	end

	if commentThumb and commentThumb:IsA("GuiButton") then
		commentThumb:SetAttribute("CommentId", data.Id)
		commentThumb.MouseButton1Click:Connect(function()
			if toggleCommentThumb then
				toggleCommentThumb(data)
			end
		end)
	end

	if thumbsUp and thumbsUp:IsA("GuiObject") then
		thumbsUp.Visible = true
		thumbsUp.Position = UDim2.fromOffset(v23 and 6 or 8, v23 and 4 or 5)
		thumbsUp.Size = UDim2.fromOffset(v23 and 22 or 24, v23 and 22 or 24)
	end

	if count and count:IsA("TextLabel") then
		count.Visible = true
		count.Position = UDim2.new(1, -(v23 and 8 or 10), 0, v23 and 0 or 2)
		count.Size = UDim2.fromOffset(v23 and 28 or 34, 30)
		count.Text = comma(v46)
	end

	local reply = clone:FindFirstChild("Reply")

	if reply and reply:IsA("TextButton") then
		reply.Visible = v3 and v3.CanComment == true
		reply.AnchorPoint = Vector2.new(1, 1)
		reply.Size = UDim2.fromOffset(visible and 70 or 72, 24)
		reply.Position = UDim2.new(1, -32, 1, -18)
		reply.MouseButton1Click:Connect(function()
			setReplyTarget(data) -- inferred equivalent call
			setComposerVisible(true)
			commentBox:CaptureFocus()
			local v49 = status2
			v49.Text = tostring("")
			v49.TextColor3 = Color3.fromRGB(147, 162, 184)
		end)
	end

	local threadToggle = clone:FindFirstChild("ThreadToggle")

	if threadToggle and threadToggle:IsA("TextButton") then
		threadToggle.Visible = visible2
		threadToggle.Position = UDim2.fromOffset(66, v44 - 31)
		threadToggle.Size = UDim2.new(1, -154, 0, 22)

		if visible2 then
			local v49 = v19 == 1 and "reply" or "replies"
			threadToggle.Text = v20 and "Hide replies" or "View all " .. tostring(v19) .. " " .. v49
			threadToggle.MouseButton1Click:Connect(function()
				if type(data.Id) == "string" then
					v10[data.Id] = not v20
					renderComments(true)
				end
			end)
		end
	end

	applyCommentRowTone(clone, data)
	local uiStroke = clone:FindFirstChildOfClass("UIStroke")

	if visible then
		if bubble and bubble:IsA("Frame") then
			bubble.BackgroundColor3 = clone.BackgroundColor3
			bubble.BackgroundTransparency = 0.08
			local uiStroke2 = bubble:FindFirstChildOfClass("UIStroke")

			if uiStroke2 then
				uiStroke2.Color = uiStroke and uiStroke.Color or Color3.fromRGB(91, 111, 132)
				uiStroke2.Transparency = 0.34
			end
		end

		clone.BackgroundTransparency = 1

		if uiStroke then
			uiStroke.Transparency = 1
		end
	else
		if bubble and bubble:IsA("Frame") then
			bubble.Visible = false
		end

		clone.BackgroundTransparency = 0
	end

	clone.Parent = list
	table.insert(clones, clone)
end

function getProfileCommentTotal(p)
	if type(p) == "table" then
		return (math.max(#(p.Comments or {}), (math.floor(tonumber(p.CommentCount) or #(p.Comments or {}) or 0))))
	end

	return 0
end

function mergeProfileCommentPage(p, list2)
	if type(p) ~= "table" or type(list2) ~= "table" then
		return
	end

	p.Comments = type(p.Comments) == "table" and p.Comments or {}
	local idSet = {}

	for _, comment in ipairs(p.Comments) do
		if not (type(comment) == "table" and type(comment.Id) == "string") then
			continue
		end

		idSet[comment.Id] = true
	end

	for _, item in ipairs(list2) do
		if type(item) ~= "table" then
			continue
		end

		local id2 = type(item.Id) == "string" and item.Id or ""

		if not (id2 == "" or not idSet[id2]) then
			continue
		end

		table.insert(p.Comments, item)

		if id2 ~= "" then
			idSet[id2] = true
		end
	end
end

function normalizeProfileCommentPaging(state)
	if type(state) ~= "table" then
		return
	end

	state.Comments = type(state.Comments) == "table" and state.Comments or {}
	state.CommentCount = getProfileCommentTotal(state)
	state.CommentsLoadedCount = math.max(
		#state.Comments,
		(math.floor(tonumber(state.CommentsLoadedCount) or #state.Comments))
	)
	state.CommentsHasMore = state.CommentsHasMore == true
	state.CommentsNextCursor = tonumber(state.CommentsNextCursor)
end

function maybeLoadMoreProfileComments()
	if ProfileCommentsPageLoading or not v3 or v3.CommentsHasMore ~= true then
		return
	end

	if not (commentsPanel and commentsPanel.Visible and list and list:IsA("ScrollingFrame")) then
		return
	end

	local commentsNextCursor = tonumber(v3.CommentsNextCursor)

	if
		not commentsNextCursor
		or list.AbsoluteCanvasSize.Y - (list.CanvasPosition.Y + list.AbsoluteWindowSize.Y) > 180
		and list.AbsoluteCanvasSize.Y > list.AbsoluteWindowSize.Y
	then
		return
	end

	ProfileCommentsPageLoading = true
	local userId2 = v3.UserId
	local success, result = pcall(function()
		return GetProfileCommentsPage:InvokeServer(userId2, commentsNextCursor)
	end)

	ProfileCommentsPageLoading = false

	if not success or type(result) ~= "table" or result.Ok ~= true then
		return
	end

	if not v3 or v3.UserId ~= userId2 then
		return
	end

	mergeProfileCommentPage(v3, result.Comments)
	v3.CommentCount = math.max(#(v3.Comments or {}), (math.floor(tonumber(result.CommentCount) or 0)))
	v3.CommentsLoadedCount = #(v3.Comments or {})
	v3.CommentsNextCursor = tonumber(result.NextCursor)
	v3.CommentsHasMore = result.HasMore == true
	renderComments(true)
	task.defer(maybeLoadMoreProfileComments)
end

renderComments = function(p)
	local canvasPosition

	if p == true and list:IsA("ScrollingFrame") then
		canvasPosition = list.CanvasPosition
	else
		canvasPosition = nil
	end

	clearCommentRows()

	local comments2 = v3 and v3.Comments or {}
	local text = string.lower(search.Text or "")

	local commentsById = {}

	local comments3 = {}
	local comments4 = {}
	local v18 = {}
	local count = 0

	for _, comment in ipairs(comments2) do
		if not (type(comment) == "table" and type(comment.Id) == "string") then
			continue
		end

		commentsById[comment.Id] = comment
	end

	for _, comment in ipairs(comments2) do
		local parentCommentId = type(comment.ParentCommentId) == "string" and comment.ParentCommentId or ""

		if parentCommentId == "" or not commentsById[parentCommentId] then
			if parentCommentId == "" then
				table.insert(comments3, comment)
			else
				table.insert(comments4, comment)
			end
		else
			v18[parentCommentId] = v18[parentCommentId] or {}
			table.insert(v18[parentCommentId], comment)
		end
	end

	local function fn(id2, options)
		if type(id2) ~= "string" or id2 == "" then
			return 0
		end

		options = options or {}

		if options[id2] then
			return 0
		end

		options[id2] = true
		local total2 = 0

		for _, v19 in ipairs(v18[id2] or {}) do
			total2 += 1

			if type(v19.Id) == "string" then
				total2 += fn(v19.Id, options)
			end
		end

		return total2
	end

	local function fn2(p2, options): boolean
		if type(p2) ~= "table" then
			return false
		end

		local id2 = type(p2.Id) == "string" and p2.Id or ""
		options = options or {}

		if id2 ~= "" and options[id2] then
			return false
		end

		if id2 ~= "" then
			options[id2] = true
		end

		if commentMatchesQuery(p2, text) then
			return true
		end

		for _, v19 in ipairs(v18[p2.Id] or {}) do
			if fn2(v19, options) then
				return true
			end
		end

		return false
	end

	local function renderThread(p2, p3)
		if text ~= "" and p3 > 0 and not fn2(p2) then
			return
		end

		count += 1
		createCommentRow(p2, count + 1, p3, 0, false)
		local v19 = v18[p2.Id] or {}

		for i = #v19, 1, -1 do
			renderThread(v19[i], ((math.min)(p3 + 1, 2)))
		end
	end

	for _, v19 in ipairs(comments3) do
		if not fn2(v19) then
			continue
		end

		local v20 = v18[v19.Id] or {}
		local v21 = fn(v19.Id)
		local v22

		if v10[v19.Id] == true then
			v22 = true
		elseif text == "" then
			v22 = false
		else
			v22 = not commentMatchesQuery(v19, text)
		end

		count += 1
		createCommentRow(v19, count + 1, 0, v21, v22)

		if not v22 then
			continue
		end

		for i = #v20, 1, -1 do
			renderThread(v20[i], 1)
		end
	end

	for _, v19 in ipairs(comments4) do
		if not commentMatchesQuery(v19, text) then
			continue
		end

		count += 1
		createCommentRow(v19, count + 1, 0, 0, false)
	end

	empty.Visible = count == 0

	if count == 0 then
		empty.Text = v3 and v3.CanComment == true and "No comments found. Maybe you can be the first?"
			or "No comments to show."
	end

	footer.Text = tostring(#comments2) .. " Comments"

	if canvasPosition then
		task.defer(function()
			for _ = 1, 3 do
				if list.Parent and list:IsA("ScrollingFrame") then
					list.CanvasPosition = canvasPosition
					task.wait()
				else
					break
				end
			end
		end)
	end
end

function toggleCommentThumb(p)
	if type(p) ~= "table" or type(p.Id) ~= "string" or p.Id == "" then
		return
	end

	if v3 and not isOwnComment(p) then -- inferred equivalent call
		if togglingCommentThumbIds[p.Id] then
			return
		end

		togglingCommentThumbIds[p.Id] = true
		local success, result = pcall(function()
			return ToggleProfileCommentThumbsUp:InvokeServer(v3.UserId, p.Id)
		end)

		togglingCommentThumbIds[p.Id] = nil

		if success and type(result) == "table" and result.Ok then
			v3 = result.Profile
			renderComments(true)
		else
			local err = type(result) == "table" and result.Error or "Failed to update comment thumbs up."
			notify("Profile", err) -- inferred equivalent call
			playProfileErrorSound()
		end
	end
end

local function showCommentsPanel()
	if not v3 then
		return
	end

	hideBadgeTooltip()
	title.Text = (v3.DisplayName or v3.Name or "Player") .. "'s Comments"
	subtitle.Text = "Reputation " .. formatRep(v3.Reputation and v3.Reputation.Score or 0) -- inferred equivalent call
	composer.Visible = false
	reactions.Visible = false
	addComment.Text = "Add Comment"
	setReplyTarget(nil) -- inferred equivalent call
	v7 = false
	submit.Active = not v7
	submit.AutoButtonColor = not v7
	submit.BackgroundTransparency = v7 and 0.35 or 0
	updateSubmitCostText() -- inferred equivalent call
	updateResponsiveLayout(true)

	profilePanel.Visible = false
	addComment.Visible = v3.CanComment == true
	search.Text = ""
	commentBox.Text = ""
	local v18 = status2
	v18.Text = tostring("")
	v18.TextColor3 = Color3.fromRGB(147, 162, 184)

	v7 = false
	submit.Active = not v7
	submit.AutoButtonColor = not v7
	submit.BackgroundTransparency = v7 and 0.35 or 0
	updateSubmitCostText() -- inferred equivalent call
	commentsPanel.Visible = true
	overlay.Visible = true
	setBackpackVisible(false) -- inferred equivalent call
	updateResponsiveLayout(true)
	renderComments()
	task.defer(maybeLoadMoreProfileComments)
end

local function hideAll() -- 2 equivalent calls inferred from this helper
	tooltip.Visible = false
	hideBadgeTooltip()
	hideActionTooltip()
	profilePanel.Visible = false
	commentsPanel.Visible = false
	editProfilePanel.Visible = false
	avatarStrokeColorPanel.Visible = false
	setImagePickerVisible(false)
	composer.Visible = false
	reactions.Visible = false
	addComment.Text = "Add Comment"
	setReplyTarget(nil) -- inferred equivalent call
	v7 = false
	submit.Active = not v7
	submit.AutoButtonColor = not v7
	submit.BackgroundTransparency = v7 and 0.35 or 0
	updateSubmitCostText() -- inferred equivalent call
	updateResponsiveLayout(true)

	overlay.Visible = false
	setBackpackVisible(true) -- inferred equivalent call
end

function openCommunityProfileForSelected()
	if not v3 then
		return
	end

	local userId2 = math.floor(tonumber(v3.UserId) or 0)

	if userId2 <= 0 then
		return
	end

	local displayName2 = tostring(v3.DisplayName or v3.Name or "Player")
	local name = tostring(v3.Name or "")
	hideAll() -- inferred equivalent call
	OpenCommunityProfileEvent:Fire(userId2, displayName2, name)
end

local function applyProfile(profile)
	normalizeProfileCommentPaging(profile)
	v3 = profile
	playerByUserId = Players:GetPlayerByUserId(profile.UserId)
	applyProfileAppearance(profile)
	displayName.Text = profile.DisplayName or profile.Name or "Player"
	username.Text = "@" .. tostring(profile.Name or "Player")
	v2:SetText(profile.Bio or "")
	timeBadge.Text = formatTime(profile.Stats and profile.Stats.TimePlayed or 0) -- inferred equivalent call
	setReputationVisual(profile.Reputation and profile.Reputation.Score or 0)
	local profileThumbs = header:FindFirstChild("ProfileThumbs")

	if profileThumbs then
		local v18 = math.max(
			0,
			(math.floor(tonumber(profile.ThumbsUpCount or profile.ProfileThumbsUp or profile.Reputation and profile.Reputation.ThumbsUp or 0) or 0))
		)
		profileThumbs:SetAttribute("TargetUserId", profile.UserId)
		setThumbButtonVisual(profileThumbs, v18, profile.ViewerThumbedProfile == true, profile.CanThumbProfile == true)
	end

	renderGameBadges(profile)
	footer.Text = tostring(getProfileCommentTotal(profile)) .. " Comments"
	local actions = ProfileSystemConfig.Actions or {}
	donate.Visible = profile.CanDonate == true and actions.Donate ~= false
	ViewUploadsButton.Visible = true
	ViewUploadsButton.Text = "View Uploads"
	saveBio.Visible = profile.IsSelf == true
	updateProfileActionRowLayout()
	task.defer(updateProfileActionRowLayout)
	local v18

	if profile.IsSelf == true then
		v18 = false
	else
		v18 = actions.FriendRequest ~= false
	end

	local examineAvatar = actions.ExamineAvatar ~= false
	local v19

	if profile.IsSelf == true then
		v19 = false
	else
		v19 = actions.Block ~= false
	end

	local v20

	if profile.IsSelf == true then
		v20 = false
	else
		v20 = actions.HidePlayerChat ~= false
	end

	local v21

	if profile.IsSelf == true then
		v21 = false
	else
		v21 = actions.MutePiano ~= false
	end

	setProfileActionButtonVisible(ActionBarFriendRequestButton, v18)
	setProfileActionButtonVisible(ActionBarExamineAvatarButton, examineAvatar)
	setProfileActionButtonVisible(ActionBarBlockButton, v19)
	setProfileActionButtonVisible(ActionBarHidePlayerChatButton, v20)
	setProfileActionButtonVisible(ActionBarMutePianoButton, v21)
	updateHidePlayerChatButton()
	updateMutePianoButton()
	updateProfileActionBarVisible()
	more.Visible = profile.IsSelf == true

	if profile.IsSelf ~= true then
		editProfilePanel.Visible = false
		avatarStrokeColorPanel.Visible = false
	end

	local isSelf = profile.IsSelf == true
	pcall(function()
		bioBox.TextEditable = isSelf
		bioBox.Active = isSelf
		bioBox.Selectable = isSelf
		bioBox.ClearTextOnFocus = false
		bioBox.Interactable = isSelf

		if not isSelf then
			bioBox:ReleaseFocus()
			bioBox.CursorPosition = -1
			bioBox.SelectionStart = -1
		end
	end)
	bioBox.PlaceholderText = isSelf and "Write about yourself..." or "No bio yet."
	v2:SetVisible(isSelf)
	setStatus(status, isSelf and "Editing your profile bio is saved to the system." or "", false) -- inferred equivalent call
	profilePanel.Visible = true
	overlay.Visible = true
	setBackpackVisible(false) -- inferred equivalent call
	updateResponsiveLayout(true)
end

local function requestProfile(userId2, p)
	local v18 = status
	v18.Text = tostring("Loading profile...")
	v18.TextColor3 = Color3.fromRGB(147, 162, 184)

	local success, result = pcall(function()
		return getPlayerProfile:InvokeServer(userId2)
	end)

	if success and type(result) == "table" and result.Ok then
		applyProfile(result.Profile)

		if p then
			showCommentsPanel()
		end
	else
		setStatus(status, type(result) == "table" and result.Error or "Failed to load profile.", true) -- inferred equivalent call
		local err = type(result) == "table" and result.Error or "Failed to load profile."
		notify("Profile", err) -- inferred equivalent call
	end
end

local function openHoveredProfile() -- 1 equivalent call inferred from this helper
	if v8 and not isInvisiblePlayer(v8) then
		requestProfile(v8.UserId, false)
	end
end

local function postSystemMessage(value)
	local textChannels = TextChatService:FindFirstChild("TextChannels")
	local rbxSystem = textChannels
		and (textChannels:FindFirstChild("RBXSystem") or textChannels:FindFirstChild("RBXGeneral"))

	if rbxSystem and rbxSystem.DisplaySystemMessage and pcall(function()
		rbxSystem:DisplaySystemMessage(value, "ProfileSystem")
	end) then
		return
	end

	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = value:gsub("<[^>]->", ""),
			Color = Color3.fromRGB(90, 255, 125),
			Font = Enum.Font.GothamBold
		})
	end)
end

local function submitComment()
	if v7 or (not v3 or v3.CanComment ~= true) then
		return
	end

	local v18 = id

	if v18 then
		local text = commentBox.Text or ""

		if text:gsub("%s+", "") == "" then
			local v19 = status2
			v19.Text = tostring("Enter a comment first.")
			v19.TextColor3 = Color3.fromRGB(255, 106, 120) or Color3.fromRGB(147, 162, 184)
		else
			local v19 = status2
			v19.Text = tostring("Submitting...")
			v19.TextColor3 = Color3.fromRGB(147, 162, 184)

			v7 = true
			submit.Active = not v7
			submit.AutoButtonColor = not v7
			submit.BackgroundTransparency = v7 and 0.35 or 0
			updateSubmitCostText() -- inferred equivalent call
			local id2 = v6 and v6.Id or nil
			local success, result = pcall(function()
				return submitProfileComment:InvokeServer(v3.UserId, v18, text, id2)
			end)

			if success and type(result) == "table" and result.Ok then
				commentBox.Text = ""

				if id2 then
					v10[id2] = true
				end

				setReplyTarget(nil) -- inferred equivalent call
				v7 = false
				submit.Active = not v7
				submit.AutoButtonColor = not v7
				submit.BackgroundTransparency = v7 and 0.35 or 0
				updateSubmitCostText() -- inferred equivalent call
				applyProfile(result.Profile)
				showCommentsPanel()
				local v20 = status2
				v20.Text = tostring("Comment added.")
				v20.TextColor3 = Color3.fromRGB(147, 162, 184)
			else
				v7 = false
				submit.Active = not v7
				submit.AutoButtonColor = not v7
				submit.BackgroundTransparency = v7 and 0.35 or 0
				updateSubmitCostText() -- inferred equivalent call
				local err = type(result) == "table" and result.Error or "Failed to submit."
				setStatus(status2, err, true) -- inferred equivalent call

				if type(result) == "table" and result.ErrorCode == "FilteredComment" then
					notify("Comment blocked", err) -- inferred equivalent call
					playProfileErrorSound()
				end
			end
		end
	else
		local v19 = status2
		v19.Text = tostring("Choose a rep type.")
		v19.TextColor3 = Color3.fromRGB(255, 106, 120) or Color3.fromRGB(147, 162, 184)
	end
end

local function saveBio2()
	if not (v3 and v3.IsSelf) then
		return
	end

	local v18 = status
	v18.Text = tostring("Saving bio...")
	v18.TextColor3 = Color3.fromRGB(147, 162, 184)

	local trimToLimit = v2:TrimToLimit(bioBox.Text or "")
	v2:SetText(trimToLimit)
	local success, result = pcall(function()
		return saveProfileBio:InvokeServer(trimToLimit)
	end)

	if success and type(result) == "table" and result.Ok then
		applyProfile(result.Profile)
		local v19 = status
		v19.Text = tostring("Bio saved.")
		v19.TextColor3 = Color3.fromRGB(147, 162, 184)
	else
		setStatus(status, type(result) == "table" and result.Error or "Failed to save bio.", true) -- inferred equivalent call
	end
end

local function setEditProfileVisible(p)
	if v3 and v3.IsSelf == true then
		editProfilePanel.Visible = p == true
		avatarStrokeColorPanel.Visible = false

		if not editProfilePanel.Visible then
			setImagePickerVisible(false)
		end

		if editProfilePanel.Visible then
			syncEditProfileFields(v3) -- inferred equivalent call
		end

		updateResponsiveLayout(true)
	else
		editProfilePanel.Visible = false
		avatarStrokeColorPanel.Visible = false
		setImagePickerVisible(false)
	end
end

local function saveProfileAppearance2()
	if v13 or not v3 or v3.IsSelf ~= true then
		return
	end

	v13 = true
	applyAppearancePreview()
	local text = saveButton.Text
	saveButton.Text = "Saving..."
	saveButton.Active = false
	saveButton.AutoButtonColor = false
	local v18 = status
	v18.Text = tostring("Saving profile appearance...")
	v18.TextColor3 = Color3.fromRGB(147, 162, 184)

	local success, result = pcall(function()
		return saveProfileAppearance:InvokeServer({
			BannerAssetId = bannerAssetIdBox.Text,
			AvatarAssetId = avatarAssetIdBox.Text,
			AvatarStrokeColor = avatarStrokeColor
		})
	end)

	v13 = false
	saveButton.Text = text
	saveButton.Active = true
	saveButton.AutoButtonColor = true

	if success and type(result) == "table" and result.Ok then
		applyProfile(result.Profile)
		setEditProfileVisible(true)
		local v19 = status
		v19.Text = tostring("Profile appearance saved.")
		v19.TextColor3 = Color3.fromRGB(147, 162, 184)
	else
		local err = type(result) == "table" and result.Error or "Failed to save profile appearance."
		setStatus(status, err, true) -- inferred equivalent call
		notify("Profile", err) -- inferred equivalent call
		playProfileErrorSound()
	end
end

local function toggleProfileThumb()
	if isTogglingProfileThumb or not v3 or v3.CanThumbProfile ~= true then
		return
	end

	isTogglingProfileThumb = true
	local profileThumbs = header:FindFirstChild("ProfileThumbs")

	if profileThumbs and profileThumbs:IsA("GuiButton") then
		profileThumbs.Active = false
		profileThumbs.AutoButtonColor = false
	end

	local success, result = pcall(function()
		return ToggleProfileThumbsUp:InvokeServer(v3.UserId)
	end)

	isTogglingProfileThumb = false

	if success and type(result) == "table" and result.Ok then
		applyProfile(result.Profile)
		return
	end

	local err = type(result) == "table" and result.Error or "Failed to update profile thumbs up."
	notify("Profile", err) -- inferred equivalent call
	playProfileErrorSound()

	if profileThumbs and v3 then
		setThumbButtonVisual(
			profileThumbs,
			v3.ThumbsUpCount or v3.ProfileThumbsUp or 0,
			v3.ViewerThumbedProfile == true,
			v3.CanThumbProfile == true
		)
	end
end

local function promptFriendRequest()
	if not playerByUserId then
		return
	end

	if not pcall(function()
		StarterGui:SetCore("PromptSendFriendRequest", playerByUserId)
	end) then
		notify("Profile", "Friend request is unavailable right now.") -- inferred equivalent call
	end
end

local function examineAvatar()
	if not v3 then
		return
	end

	if not pcall(function()
		GuiService:InspectPlayerFromUserId(v3.UserId)
	end) then
		notify("Profile", "Avatar inspect is unavailable right now.") -- inferred equivalent call
	end
end

local function promptBlock()
	if not playerByUserId then
		return
	end

	if not pcall(function()
		StarterGui:SetCore("PromptBlockPlayer", playerByUserId)
	end) then
		notify("Profile", "Block prompt is unavailable right now.") -- inferred equivalent call
	end
end

function toggleProfilePlayerHidden()
	if not v3 or v3.IsSelf == true then
		return
	end

	local userId2 = math.floor(tonumber(v3.UserId) or 0)

	if userId2 <= 0 then
		return
	end

	local v18 = not isProfileUserHidden(userId2)
	LocalPlayer:SetAttribute(getHiddenProfileAttributeName(userId2), v18 and true or nil)
	SetProfilePlayerHiddenEvent:Fire(userId2, v18)
	updateHidePlayerChatButton()
	notify( -- inferred equivalent call
		"Profile",
		(v18 and "Hidden " or "Unhidden ") .. tostring(v3.DisplayName or v3.Name or "player") .. " for this session."
	)
end

function toggleProfilePianoMuted()
	if not v3 or v3.IsSelf == true then
		return
	end

	local userId2 = math.floor(tonumber(v3.UserId) or 0)

	if userId2 <= 0 then
		return
	end

	local v18 = not isProfileUserPianoMuted(userId2)
	LocalPlayer:SetAttribute(getMutedPianoAttributeName(userId2), v18 and true or nil)

	if v18 then
		stopProfileUserPianoAudio(userId2)
	end

	updateMutePianoButton()
	notify( -- inferred equivalent call
		"Profile",
		(v18 and "Muted " or "Unmuted ") .. tostring(v3.DisplayName or v3.Name or "player") .. "'s piano for this session."
	)
end

local v18 = {
	GetJarOverlay = function(self)
		local donationJarGui = PlayerGui:FindFirstChild("DonationJarGui")
		return donationJarGui and donationJarGui:FindFirstChild("Overlay")
	end,
	IsJarOpen = function(self)
		local jarOverlay = self:GetJarOverlay()
		return jarOverlay and jarOverlay.Visible == true
	end,
	GetOpenRequest = function(self)
		return remotes:FindFirstChild("OpenDonationRequest")
	end,
	GetLegacyOpenRequest = function(self)
		local v18 = Events or ReplicatedStorage:FindFirstChild("Events")
		return v18 and v18:FindFirstChild("OpenDonateReq")
	end,
	OpenForSelectedProfile = function(self)
		if not v3 or v3.IsSelf then
			return
		end

		local userId2 = v3.UserId

		local openRequest = self:GetOpenRequest()
		local v18

		if openRequest and openRequest:IsA("RemoteEvent") then
			openRequest:FireServer(userId2)
			v18 = true
		else
			v18 = false
		end

		task.delay(0.4, function()
			if self:IsJarOpen() then
				return
			end

			local legacyOpenRequest = self:GetLegacyOpenRequest()

			if legacyOpenRequest and legacyOpenRequest:IsA("RemoteEvent") then
				legacyOpenRequest:FireServer(userId2)
			elseif not v18 then
				notify("Donate", "Donation system is unavailable right now.") -- inferred equivalent call
			end
		end)
		hideAll() -- inferred equivalent call
	end
}

donate.MouseButton1Click:Connect(function()
	v18:OpenForSelectedProfile()
end)

comments.MouseButton1Click:Connect(showCommentsPanel)
ViewUploadsButton.MouseButton1Click:Connect(openCommunityProfileForSelected)
addComment.MouseButton1Click:Connect(function()
	if composer.Visible then
		commentBox:ReleaseFocus()
		setReplyTarget(nil) -- inferred equivalent call
		composer.Visible = false
		reactions.Visible = false
		addComment.Text = "Add Comment"
		setReplyTarget(nil) -- inferred equivalent call
		v7 = false
		submit.Active = not v7
		submit.AutoButtonColor = not v7
		submit.BackgroundTransparency = v7 and 0.35 or 0
		updateSubmitCostText() -- inferred equivalent call
		updateResponsiveLayout(true)

		local v19 = status2
		v19.Text = tostring("")
		v19.TextColor3 = Color3.fromRGB(147, 162, 184)
	else
		setReplyTarget(nil) -- inferred equivalent call
		local visible

		if v3 == nil then
			visible = false
		else
			visible = v3.CanComment == true
		end

		composer.Visible = visible
		reactions.Visible = false
		addComment.Text = visible and "Close Comment" or "Add Comment"

		if visible then
			replyContext.Visible = v6 ~= nil
		else
			setReplyTarget(nil) -- inferred equivalent call
			v7 = false
			submit.Active = not v7
			submit.AutoButtonColor = not v7
			submit.BackgroundTransparency = v7 and 0.35 or 0
		end

		updateSubmitCostText() -- inferred equivalent call
		updateResponsiveLayout(true)

		if composer.Visible then
			commentBox:CaptureFocus()
			v7 = false
			submit.Active = not v7
			submit.AutoButtonColor = not v7
			submit.BackgroundTransparency = v7 and 0.35 or 0
			updateSubmitCostText() -- inferred equivalent call
			updateSubmitCostText() -- inferred equivalent call
		end
	end
end)
selectedReaction.MouseButton1Click:Connect(function()
	if not composer.Visible then
		return
	end

	reactions.Visible = not reactions.Visible
	updateReactionDropdown()
end)
polarityToggle.MouseButton1Click:Connect(function()
	if not composer.Visible then
		return
	end

	local reactionByMagnitude = getReactionByMagnitude(v4 or 25, not v5)

	if reactionByMagnitude then
		applyReactionSelection(reactionByMagnitude.Id)
	end
end)
cancelReply.MouseButton1Click:Connect(function()
	setReplyTarget(nil) -- inferred equivalent call
end)
submit.MouseButton1Click:Connect(submitComment)
saveBio.MouseButton1Click:Connect(saveBio2)
profileThumbButton = header:FindFirstChild("ProfileThumbs")

if profileThumbButton and profileThumbButton:IsA("GuiButton") then
	profileThumbButton.MouseButton1Click:Connect(toggleProfileThumb)
end

profileThumbButton = nil
close.MouseButton1Click:Connect(hideAll)
close2.MouseButton1Click:Connect(function()
	commentsPanel.Visible = false
	composer.Visible = false
	reactions.Visible = false
	addComment.Text = "Add Comment"
	setReplyTarget(nil) -- inferred equivalent call
	v7 = false
	submit.Active = not v7
	submit.AutoButtonColor = not v7
	submit.BackgroundTransparency = v7 and 0.35 or 0
	updateSubmitCostText() -- inferred equivalent call
	updateResponsiveLayout(true)

	overlay.Visible = profilePanel.Visible
	setBackpackVisible(profilePanel.Visible ~= true) -- inferred equivalent call
end)
overlay.MouseButton1Click:Connect(function()
	hideActionTooltip()
end)
more.MouseButton1Click:Connect(function()
	if v3 and v3.IsSelf == true then
		setEditProfileVisible(not editProfilePanel.Visible)
	end
end)
closeEdit.MouseButton1Click:Connect(function()
	setEditProfileVisible(false)
end)

if BannerAddImageButton and BannerAddImageButton:IsA("TextButton") then
	BannerAddImageButton.MouseButton1Click:Connect(function()
		setImagePickerVisible(true, "Banner")
	end)
end

if AvatarAddImageButton and AvatarAddImageButton:IsA("TextButton") then
	AvatarAddImageButton.MouseButton1Click:Connect(function()
		setImagePickerVisible(true, "Avatar")
	end)
end

if ImagePickerCloseButton and ImagePickerCloseButton:IsA("GuiButton") then
	ImagePickerCloseButton.MouseButton1Click:Connect(function()
		setImagePickerVisible(false)
	end)
end

if ImagePickerSearchButton and ImagePickerSearchButton:IsA("TextButton") then
	ImagePickerSearchButton.MouseButton1Click:Connect(function()
		searchImagePickerCatalog(ImagePickerSearchBox and ImagePickerSearchBox.Text or "")
	end)
end

if ImagePickerSearchBox and ImagePickerSearchBox:IsA("TextBox") then
	ImagePickerSearchBox.FocusLost:Connect(function(p)
		if p then
			searchImagePickerCatalog(ImagePickerSearchBox.Text)
		end
	end)
end

if ImagePickerPanel then
	ensureImagePickerTileTemplate()
end

SharedCatalogImagePickerOpen.Event:Connect(function(value, value2, value3, p)
	local v19 = type(p) == "table" and p or {}
	ImagePickerExternalRequestId = tostring(value or "")
	ImagePickerExternalCurrentValue = tostring(value2 or "")
	ImagePickerExternalTargetText = tostring(value3 or "Search Roblox 2D assets for this image.")
	ImagePickerExternalDefaultQuery = tostring(v19.DefaultQuery or "")
	ImagePickerExternalLayoutMode = tostring(v19.LayoutMode or "")
	ImagePickerExternalAspectRatio = tonumber(v19.AspectRatio)
	ImagePickerExternalDefaultImage = tostring(v19.DefaultImage or "")
	setImagePickerVisible(true, "External")
end)

if ImagePickerGrid and ImagePickerGrid:IsA("ScrollingFrame") then
	ImagePickerGrid:GetPropertyChangedSignal("CanvasPosition"):Connect(maybeLoadMoreImagePickerResults)
	ImagePickerGrid:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		task.defer(maybeLoadMoreImagePickerResults)
	end)
end

previewButton.MouseButton1Click:Connect(applyAppearancePreview)
resetButton.MouseButton1Click:Connect(function()
	bannerAssetIdBox.Text = ""
	avatarAssetIdBox.Text = ""
	avatarStrokeColor = "#E6EEFA"
	applyAppearancePreview()
end)
saveButton.MouseButton1Click:Connect(saveProfileAppearance2)
avatarStrokeColorButton.MouseButton1Click:Connect(function()
	avatarStrokeColorPanel.Visible = not avatarStrokeColorPanel.Visible
end)
closePanel.MouseButton1Click:Connect(function()
	avatarStrokeColorPanel.Visible = false
end)
applyPreview.MouseButton1Click:Connect(function()
	setAvatarStrokeHex(avatarStrokeColor)
	applyAppearancePreview()
	avatarStrokeColorPanel.Visible = false
end)
miniColourWheel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v14 = true
		updateAvatarStrokeFromInput(input)
	end
end)
miniColourWheel.InputChanged:Connect(function(input)
	if
		v14
		and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch)
	then
		updateAvatarStrokeFromInput(input)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		v14 = false
	end
end)
connectProfileActionButton(ActionBarFriendRequestButton, promptFriendRequest, "Send Friend Request")
connectProfileActionButton(ActionBarExamineAvatarButton, examineAvatar, "Examine Avatar")
connectProfileActionButton(ActionBarBlockButton, promptBlock, "Block Player")
connectProfileActionButton(ActionBarHidePlayerChatButton, toggleProfilePlayerHidden, function(): string
	if v3 and isProfileUserHidden(v3.UserId) then
		return "Unhide Player & Chat"
	end

	return "Hide Player & Chat"
end)

connectProfileActionButton(ActionBarMutePianoButton, toggleProfilePianoMuted, function(): string
	if v3 and isProfileUserPianoMuted(v3.UserId) then
		return "Unmute Piano Sounds"
	end

	return "Mute Piano Sounds"
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
	renderComments()
	task.defer(maybeLoadMoreProfileComments)
end)

if list:IsA("ScrollingFrame") then
	list:GetPropertyChangedSignal("CanvasPosition"):Connect(maybeLoadMoreProfileComments)
	list:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
		task.defer(maybeLoadMoreProfileComments)
	end)
	list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		task.defer(maybeLoadMoreProfileComments)
	end)
end

commentBox:GetPropertyChangedSignal("Text"):Connect(function()
	local maxCommentLength = tonumber(ProfileSystemConfig.MaxCommentLength) or 220

	if maxCommentLength < #commentBox.Text then
		commentBox.Text = string.sub(commentBox.Text, 1, maxCommentLength)
	end

	characterCount.Text = tostring(#commentBox.Text) .. "/" .. tostring(maxCommentLength)
end)

openPlayerComments.Event:Connect(function()
	requestProfile(LocalPlayer.UserId, true)
end)
bindable.Event:Connect(function()
	requestProfile(LocalPlayer.UserId, false)
end)

moduleScript.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local rep = math.floor(tonumber(data.Rep) or 0)
	local v19 = rep < 0 and "negative" or "positive"
	local v20 = rep < 0 and "#FF6A78" or "#5AFF7D"
	postSystemMessage(string.format(
		"<font color='#5AFF7D'><b>[SYSTEM]</b></font> <b>%s</b> added a %s comment to <b>%s</b>! <font color='%s'><b>(%s)</b></font> &quot;%s&quot;",
		escapeRichText(data.AuthorDisplayName or data.AuthorName or "Someone"), -- inferred equivalent call
		v19,
		escapeRichText(data.TargetDisplayName or data.TargetName or "Someone"), -- inferred equivalent call
		v20,
		formatRep(rep), -- inferred equivalent call
		escapeRichText(data.Text or "")
	))
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if
		(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
		and not profilePanel.Visible
		and not commentsPanel.Visible
	then
		openHoveredProfile() -- inferred equivalent call
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if profilePanel.Visible or commentsPanel.Visible then
		tooltip.Visible = false
		v8 = nil
		total = 0
		setHoverHighlight(nil)
	else
		total += dt

		if total < 0.05 then
			if v8 and v16 then
				positionTooltip(v8, v16)
			end
		else
			total = 0
			local mouseTargetPlayer, v19 = getMouseTargetPlayer() -- inferred equivalent call

			v8 = mouseTargetPlayer
			setHoverHighlight(v19)
			setTooltipPlayer(mouseTargetPlayer)
		end
	end
end)

setupReactionButtons()
renderGameBadges(nil)
updateResponsiveLayout(true)
viewportConnection = nil
local function bindViewportResize()
	if viewportConnection then
		viewportConnection:Disconnect()
		viewportConnection = nil
	end

	CurrentCamera = Workspace.CurrentCamera

	if CurrentCamera then
		viewportConnection = CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updateResponsiveLayout(true)
		end)
	end
end
bindViewportResize()
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	bindViewportResize()
	updateResponsiveLayout(true)
end)
ClientDebug.Print("[PlayerProfileClient] Initialized")