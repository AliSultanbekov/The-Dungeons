--[[
	@class ClientMain
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loader = ReplicatedStorage:WaitForChild("Game"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent) :: any

-- Wait for Remotes folder before initializing services to prevent yield during Init
ReplicatedStorage:WaitForChild("Remotes")

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("InitManager"))
serviceBag:Init()
serviceBag:Start()