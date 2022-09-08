return {
    new = function()
        local common = require(script.Parent.Parent.common)
        local goap = require(script.Parent.Parent.goap)
        
        
        
        local module = goap.Goal.new("wander", {wander = true}, 0, nil)
        
        module.Priority = function(self, worldState, actor) 
            return worldState.wanderPriority ~= nil and worldState.wanderPriority or 0
        end
        
        module.OnDeactivated = function(worldState, actor)
            worldState.wanderPriority = 0
        end
        
        module.OnTick = function(worldState, actor)
            if worldState.wanderPriority == nil then
                worldState.wanderPriority = 0
            end
        
            if worldState.Target == nil then
                worldState.wanderPriority = worldState.wanderPriority + .01
            end
        end
        
        return module
    end
}