local ReplicatedStorage = game:GetService("ReplicatedStorage")
local main = require(ReplicatedStorage:WaitForChild("HDAdminSetup", 999)):GetMain(true)

local HDAdminStarterCharacter = script.Parent.HDAdminStarterCharacter
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

main:Initialize("Client")

main:GetModule("GUIs"):UpdateFont()
main:GetModule("PageAbout"):UpdateRankName()
main:GetModule("PageAbout"):UpdateProfileIcon()
main:GetModule("PageAbout"):CreateUpdates()
main:GetModule("PageAbout"):UpdateContributors()
main:GetModule("PageAbout"):CreateCredits()
main:GetModule("PageCommands"):CreateCommands()
main:GetModule("PageCommands"):CreateMorphs()
main:GetModule("PageCommands"):CreateDetails()
main:GetModule("PageModeration"):SetupRanks()