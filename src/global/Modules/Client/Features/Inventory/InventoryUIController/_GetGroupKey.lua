--[=[
    @class GetGroupKey
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.Parent.loader).load(script)

-- [ Imports ] -- 
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GetGroupKey = function(itemData: ItemTypes.ItemData)
    local InfoArray = {}

    table.insert(InfoArray, string.format("Name:%s", itemData.Name))

    local GroupKey = ""

    for _, info in InfoArray do
        GroupKey = string.format("[%s%s]", GroupKey, info)
    end

    return GroupKey
end

-- [ Types ] --
export type Module = typeof(GetGroupKey)

-- [ Private Functions ] --

-- [ Public Functions ] --

return GetGroupKey :: Module