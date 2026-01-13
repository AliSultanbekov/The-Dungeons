-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local CombatTypes = require("CombatTypes")


local Controller = {}

function Controller.Init(self, serviceBag: ServiceBag.ServiceBag)
    print("Called")
    self._serviceBag = serviceBag
end


print("Ran")
return Controller