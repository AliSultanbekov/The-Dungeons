--[=[
    @class DefaultBasicAttackClient
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local HitboxClass = require("HitboxClass")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local DefaultBasicAttackClient = {}
DefaultBasicAttackClient.__index = DefaultBasicAttackClient

-- [ Types ] --
type WeaponItemData = ItemTypes.WeaponItemData
type Use_Params = {
    Attacker: Model,
    OnHit: (hitCharacter: Model) -> ()
}
type New_Params = {
    weaponData: WeaponItemData
}
export type ObjectData = {
    _WeaponData: WeaponItemData
}
export type Object = ObjectData & {
    
}
export type Module = {
    __index: Module,
    new: (params: New_Params) -> Object
}

-- [ Private Functions ] --

-- [ Public Functions ] --
function DefaultBasicAttackClient.new(params: New_Params): Object
    local self = setmetatable({} :: any, DefaultBasicAttackClient) :: Object

    self._WeaponData = params.weaponData

    return self
end

function DefaultBasicAttackClient.Use(self: Object, params: Use_Params)
    task.spawn(function()
        HitboxClass.new(
            {
                HitboxType = "Box",
                GetCFrame = function()
                    local BaseCF = params.Attacker:GetPivot()
                    local LookVec = BaseCF.LookVector
                    local FlatLooKVec = Vector3.new(LookVec.X, 0, LookVec.Z)

                    if FlatLooKVec.Magnitude < 1e-6 then
                        return CFrame.identity
                    end

                    return CFrame.lookAt(BaseCF.Position, BaseCF.Position + FlatLooKVec) * CFrame.new(0, 0, -5)
                end,
                Size = Vector3.new(3,3,3),
                Length = 2/60,
                Ignore = { params.Attacker },
                Visualise = true,
                Cb = function(hitCharacter: Model)
                    params.OnHit(hitCharacter)
                end
            }
        ):Trigger()
    end)
end

function DefaultBasicAttackClient.Apply(self: Object)
    
end

return DefaultBasicAttackClient :: Module