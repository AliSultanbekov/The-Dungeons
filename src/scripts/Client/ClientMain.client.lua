--[[
	@class ClientMain
]]
local loader = game:GetService("ReplicatedStorage"):WaitForChild("Game"):WaitForChild("loader")
local require = require(loader).bootstrapGame(loader.Parent) :: any

local serviceBag = require("ServiceBag").new()
serviceBag:GetService(require("InitServiceClient"))
serviceBag:GetService(require("BinderBagServiceClient"))
serviceBag:Init()
serviceBag:Start()