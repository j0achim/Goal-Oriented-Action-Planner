return {
    new = function()
        local common = require(script.Parent.Parent.common)
        local goap = require(script.Parent.Parent.goap)
        
        local module = goap.Action.new("chase player", 100, nil, {enemyInRange = true})
        
        module.OnDeactivated = function(worldState, actor)
            actor:Move(Vector3.new(0, 0, 0))
            if worldState.animation ~= nil then
                worldState.animation["Walk"]:Stop()
            end
        end
        
        module.OnTick = function(worldState, actor)
            if worldState.animation == nil then
                worldState.animation = {}
            end
            if worldState.animation["Walk"] == nil then
                local animator = actor:FindFirstChild("Animator")     
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = actor
                end
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://507777826"
                worldState.animation["Walk"] = animator:LoadAnimation(animation)
            end
        
            if worldState.Target == nil then    
                print("no target")
                return false
            end
        
            local diff = common.DiffVector(worldState.Target, actor)
        
            if diff.Magnitude < 10 and actor.RootPart.Velocity ~= Vector3.zero then
                actor:Move(Vector3.new(0, 0, 0))
                worldState.animation["Walk"]:Stop()
                return true
            end
        
            if diff.Magnitude > 10 then
                if actor.RootPart.Velocity ~= Vector3.zero and not worldState.animation["Walk"].IsPlaying then
                    worldState.animation["Walk"]:Play()
                    worldState.animation["Walk"]:AdjustSpeed(common.Map(actor.WalkSpeed, 0, 32, 0, 2))
                end
        
                actor:Move((common.PredictPosition(actor, worldState.Target) - actor.RootPart.Position).Unit * actor.WalkSpeed)
            end
        
            if diff.Magnitude > 50 then
                actor:Move(Vector3.new(0, 0, 0))
                worldState.animation["Walk"]:Stop()
                return false
            end
        end
        
        return module
    end
}