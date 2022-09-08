local common = require(script.Parent.Parent.common)
local goap = require(script.Parent.Parent.goap)

local module = goap.Action.new("attack action", 10, {enemyInRange = true}, {enemyDead = true})

module.OnTick = function(worldState, actor)
    if worldState.Target == nil then
        return false
    end

    local diff = common.DiffVector(actor, worldState.Target)

    if diff.Magnitude > 10 then
        return false
    end

    if common.AngleBetween(actor.RootPart.CFrame.LookVector, diff) > 20 then
        actor.RootPart.CFrame = CFrame.lookAt(actor.RootPart.Position, Vector3.new(worldState.Target.RootPart.Position.X, actor.RootPart.Position.Y, worldState.Target.RootPart.Position.Z))
    end
end

return module