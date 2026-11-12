local ProfileSystemConfig = {
	MaxBioLength = 1000,
	MaxCommentLength = 220,
	MaxStoredComments = 120,
	CommentPageSize = 40,
	CommentCooldownSeconds = 30,
	ProfileCommentAgeGroupLimitEnabled = false,
	Actions = {
		Donate = true,
		FriendRequest = true,
		ExamineAvatar = true,
		Block = true,
		HidePlayerChat = true,
		Report = false
	},
	MaxProfileBadges = 8,
	GameBadges = {},
	WeeklyReputationCaps = {
		GivePositive = 20000,
		ReceivePositive = 20000,
		GiveNegative = 20000,
		ReceiveNegative = 20000
	},
	Reactions = {
		{
			Id = "Kind",
			Label = "Kind",
			ShortLabel = "Kind",
			Rep = 25,
			Cost = 15,
			Color = Color3.fromRGB(82, 210, 118)
		},
		{
			Id = "Nice",
			Label = "Nice",
			ShortLabel = "Nice",
			Rep = 70,
			Cost = 45,
			Color = Color3.fromRGB(89, 157, 255)
		},
		{
			Id = "Amazing",
			Label = "Amazing",
			ShortLabel = "Amazing",
			Rep = 650,
			Cost = 400,
			Color = Color3.fromRGB(170, 120, 255)
		},
		{
			Id = "Rude",
			Label = "Rude",
			ShortLabel = "Rude",
			Rep = -25,
			Cost = 15,
			Color = Color3.fromRGB(255, 190, 75)
		},
		{
			Id = "Annoying",
			Label = "Annoying",
			ShortLabel = "Annoying",
			Rep = -70,
			Cost = 45,
			Color = Color3.fromRGB(255, 120, 85)
		},
		{
			Id = "Toxic",
			Label = "Toxic",
			ShortLabel = "Toxic",
			Rep = -650,
			Cost = 400,
			Color = Color3.fromRGB(255, 75, 105)
		}
	},
	ReactionById = {}
}

for _, reaction in ipairs(ProfileSystemConfig.Reactions) do
	ProfileSystemConfig.ReactionById[reaction.Id] = reaction
end

return ProfileSystemConfig