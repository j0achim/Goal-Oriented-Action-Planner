# Goal Oriented Action Planner

What problem does GOAP actually solve? GOAP's intended use it to provide real-time control of autonomous character behavior in games, over traditional approaches such as FSM, BT or plain If structure. By intelligently linking goals and actions together by having a goal state, and actions having effects and preconditions that will be tested to build rich plans.

 - FSM, BT's and If structures all suffer from being hard to manage once you reach a certain level of complexity where you want to avoid repeating yourself.

 This GOAP implementation is based loosely on Jeff Orkin's work on Goal Oriented Action Planning
 - Jeff Orkin's website can be found here [https://alumni.media.mit.edu/](https://alumni.media.mit.edu/~jorkin/goap.html)


### Short low level explanation.
 1. **Goal**: Defines a desired world state.
 2. **Plan**: Contains list of actions.
 3. **Action**: Action that fulfill a precondition to resolve a goal.

 - GOAP planner will evaluate goals based on their current priority, priority ***can*** be static or calculated at runtime.
 - If a goal that is evaluated have a higher priority than the current goal, the planner will switch to a higher priority goal, and find the best plan to execute, a goal can have multiple plans to achieve a given goal.
 - Actions behave in a similar way as goals, actions however have cost of execution, lower cost means that a action has a higher priority to run. 
 - Every time the planner ticks it will evaluate if a plan-and-or-action have a lower cost and will contribute to fulfill the goal and switch between plans and actions.

Goals and Actions both share a similar design pattern with some key differences.
 - Goals 
    - Ticked **every** time we tick the GOAP module.
    - Have priority function/attribute, higher = better.
    - Have a function to specify if the goal can be ran, which is not implemented for actions. This could maybe be useful for actions but I have not seen a use for this at the current time.

 - Actions
    - **Only** ticked when they are active.
    - Have cost function/attribute instead of priority, lower = better.



## Getting Started

This serves as documentation being overly explicit.

This example is a goal where we want to kill a player, the goal will scan for a target on every tick. If we have a target it check the distance between the NPC and player and clears target if the range is above 50 studs.
```lua
-- Description: A goal to kill a player
return {
    -- Why are we using a function here? We need to create new instances of this module for every planner that loads this file, otherwise bad things will happen.
    new = function()
        local common = require(script.Parent.Parent.common)
        local goap = require(script.Parent.Parent.goap)
        
        --[[
            Create a new goal, "kill player", with a desired world state of {enemyDead = true}
        
                The desired state is what we want to achieve when we run this goal, this is only used to link goals and actions together when
                the planner is building possible plans to achieve the desired state.
        
                The planner will only evaluate actions that have effects matching desired state, enabling us to build rich trees (plans) of actions and goals.
        
                Goals can have multiple desired states if you want to have "similar" goals with totally different outcome.
        --]]
        local module = goap.Goal.new("kill player", {enemyDead = true})
        
        -- Priority determines the order in which goals are evaluated, the planner will pick the goal having the highest priority
        -- If we have a target, we want to kill it, so return a high priority
        module.Priority = function(_, worldState: table, actor: Humanoid) : number
            return worldState.Target and 99 or 0
        end
        
        -- CanRun is called every time we tick the planner to see if we can run this goal
        module.CanRun = function(_, worldState: table, actor: Humanoid) : boolean
            -- If we have a target, we can run this goal, 
            -- when false this will ensure that planner not evaluate any actions further down the tree if cant run this goal
            -- this would save us from computing the cost of actions, this can quickly become an expensive operation if we have many actions and tick is ran on every frame
            return worldState.Target ~= nil
        end
        
        -- Gets called once when the goal is activated
        module.OnActivated = function(worldState: table, actor: Humanoid) : boolean?
            -- Do we need to set worldstate, e.g start animations?
            -- Set a flag to indicate that we are attacking?
        end
        
        -- Gets called once when the goal is deactivated, either because we are done or because we are interrupted by another goal having a higher priority
        module.OnDeactivated = function(worldState: table, actor: Humanoid) : boolean?
            -- Do we need to set worldstate, e.g stop animations?
            -- Set a flag to indicate that we are not attacking?
        end
        
        -- OnTick gets called **every** time we tick the planner, regardless if goal is active or not
        module.OnTick = function(worldState: table, actor: Humanoid) : boolean?
            if worldState.Target == nil then
                local result, target = common.ClosestPlayerWithinView(actor, 50)
                worldState.Target = result and target or nil
            else
                if worldState.Target.Health <= 0 then
                    worldState.Target = nil
                    return true -- By returning true we notify the planner that we have completed the goal and need to replan if we are already working on a plan to kill the target
                end
        
                if common.DiffVector(actor, worldState.Target).Magnitude > 50 then
                    worldState.Target = nil
                    return false -- By returning false we notify the planner that we need to replan if we are already working on a plan to kill the target
                end
            end
        
            -- By returning nil we are telling the planner that nothing has changed and we dont need to replan
            return nil -- (not actually neeeded but here for clarity)
        end

        return module -- Return the goal
    end
}
```