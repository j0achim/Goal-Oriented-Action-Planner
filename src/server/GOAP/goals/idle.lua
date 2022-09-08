return {
    new = function()
        local common = require(script.Parent.Parent.common)
        local goap = require(script.Parent.Parent.goap)
        
        local module = goap.Goal.new("idle", {idle = true}, 10, nil)
        
        module.OnActivated = function(worldState, actor)
            if worldState.animation == nil then
                worldState.animation = {}
            end
        
            if worldState.animation["idle"] == nil then
                local animator = actor:FindFirstChild("Animator")     
                if not animator then
                    animator = Instance.new("Animator")
                    animator.Parent = actor
                end
        
                local animation = Instance.new("Animation")
                animation.AnimationId = "rbxassetid://507766666"
        
                worldState.animation["idle"] = animator:LoadAnimation(animation)
            end
        
            if not worldState.animation["idle"].IsPlaying then
                worldState.animation["idle"]:Play()
            end
        end
        
        module.OnDeactivated = function(worldState, actor)
            worldState.animation["idle"]:Stop()
        end
        
        return module
    end
}
