wait(3.5)

local AvatarEditorService = game:GetService("AvatarEditorService")
AvatarEditorService:PromptSetFavorite(game.PlaceId, Enum.AvatarItemType.Asset, true)