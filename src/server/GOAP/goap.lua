-- GOAP (Goal Oriented Action Planner) implementation for Roblox
local GoalOrientedActionPlanner = {
    Goal = {},
    Action = {},
    Plan = {},
    Goap = {},
}

GoalOrientedActionPlanner.Action.new = function(name, cost, preconditions, effects)
    local new = {}
    new.name = name
    new.cost = cost
    new.preconditions = preconditions
    new.effects = effects

    new.Name = function(self) : string
        return self.name
    end

    new.GetCost = function(self, worldState, actor) : number
        return self.cost
    end

    new.Effects = function(self) : {[string]:boolean}
        return self.effects
    end

    new.Preconditions = function(self) : {[string]:boolean}
        return self.preconditions
    end

    new.Satisfies = function(self, preconditions) : boolean
        for key, value in preconditions do
            if self.effects[key] == nil or self.effects[key] ~= value then
                return false
            end
        end
        return true
    end

    new.Evaluate = function(self, worldState) : boolean
        if self:Preconditions() == nil then return true end
        for key, value in pairs(self.preconditions) do
            if worldState[key] == nil or worldState[key] ~= value then
                return false
            end
        end
        return true
    end

    new.Activate = function(self, worldState, actor) : boolean
        if self.OnActivated ~= nil then
            return self.OnActivated(worldState, actor)
        end
    end

    new.Deactivate = function(self, worldState, actor) : boolean
        if self.OnDeactivated ~= nil then
            return self.OnDeactivated(worldState, actor)
        end
    end

    new.Tick = function(self, worldState, actor) : boolean
        if self.OnTick ~= nil then
            return self.OnTick(worldState, actor)
        end
    end

    return new
end

GoalOrientedActionPlanner.Goal.new = function(name, desiredState, priority, condition)
    local new = {}
    new.name = name
    new.desiredState = desiredState
    new.priority = priority or 0
    new.condition = condition
    new.plans = {}
    new.currentPlan = nil
    new.currentAction = nil

    local function Reverse(list)
        local new, input = {} , list or {}
        for i = #input, 1, -1 do
            new[#new + 1] = input[i]
        end
        return new
    end

    local function Contains(list, value)
        for _, v in list do
            if v == value then return true end
        end
        return false
    end

    new.Preconditions = function(self)
        return self.desiredState
    end

    new.CanRun = function(self, worldState, actor)
        return true
    end

    new.Priority = function(self, worldState, actor)
        return self:GetPriority(worldState, actor)
    end

    new.GetPriority = function(self, worldState, actor)
        return self.priority
    end

    new.Evaluate = function(self, worldState)
        if self.desiredState == nil then return true end
        for key, value in pairs(self.desiredState) do
            if worldState[key] == nil or worldState[key] ~= value then
                return false
            end
        end
        return true
    end

    new.Tick = function(self, worldState, actor)
        -- Find best plan
        local bestPlan = nil
        local action = nil

        local minCost = if self.currentPlan ~= nil then self.currentPlan:GetCost(worldState, actor) else math.huge

        for _, plan in self:GetPlans(worldState, actor) do
            local planCost = plan:GetCost(worldState, actor)
            if planCost < minCost then
                bestPlan = plan:Clone()
                minCost = planCost
            end
        end

        -- Found new plan
        if bestPlan ~= nil then
            if bestPlan ~= self.currentPlan then
                self.currentPlan = bestPlan
                bestPlan = nil
            end
    
            action = self.currentPlan:CurrentAction()
    
            -- No current action, activate new one
            if self.currentAction == nil and action ~= nil then
                self.currentAction = action
                self.currentAction:Activate(worldState, actor)
            end
    
            -- Current action changed, deactivate old one and activate new one
            if self.currentAction ~= nil and action ~= self.currentAction then
                self.currentAction:Deactivate(worldState, actor)
    
                if action ~= nil then
                    self.currentAction = action
                    self.currentAction:Activate(worldState, actor)
                end
            end 
        end

        if self.currentAction ~= nil then
            local actionResult = self.currentAction:Tick(worldState, actor)

            if actionResult == true then
                self.currentAction:Deactivate(worldState, actor)
                self.currentPlan:RemoveCurrentAction()
                self.currentAction = self.currentPlan:CurrentAction()
            elseif actionResult == false then
                self.currentAction:Deactivate(worldState, actor)
                self.currentAction = nil
                self.currentPlan = nil
            end

            actionResult = nil
        end
    end

    new.GetPlans = function(self, worldState, actor)
        local plans = {}
        local minCost = math.huge
        for _, plan in self.plans do
            for index,action in plan.actions do
                if action:Evaluate(worldState) then

                    local newPlan = plan:Clone()
                    for i = index +1, #newPlan.actions do
                        newPlan.actions[i] = nil
                    end

                    if not Contains(plans, newPlan) then
                        plans[#plans + 1] = newPlan
                        local cost = newPlan:GetCost(worldState, actor)
                        if cost < minCost then minCost = cost end
                    end
                end
            end
        end

        for _, plan in self.plans do
            if plan:GetCost(worldState, actor) < minCost then
                plans[#plans + 1] = plan:Clone()
            end
        end

        table.sort(plans, function(a, b)
            return a:GetCost(worldState, actor) < b:GetCost(worldState, actor)
        end)

        return #plans > 0 and plans or self.plans
    end

    new.GetActions = function(self, preconditions, actions, plan)
        local result = {}
        for _, action in actions do
            --if plan ~= nil and Contains(plan.actions, action) then continue end
            if plan ~= nil and action:Satisfies(self.desiredState) then continue end
            if action:Satisfies(preconditions) then table.insert(result, action) end
        end
        return result
    end

    new.BuildPlans = function(self, actionsAvailable)
        local preconditions = self:Preconditions()
        local actions = self:GetActions(preconditions, actionsAvailable)
        for _, action in actions do
            table.insert(self.plans, GoalOrientedActionPlanner.Plan.new({action}))
        end

        for i = 1, 10 do
            for _, plan in self.plans do
                local precon = plan:CurrentAction():Preconditions()
                if precon == nil then continue end
                local newActions = self:GetActions(precon, actionsAvailable, plan)
                if #newActions > 0 then
                    if #newActions > 1 then
                        for a = 2, #newActions do
                            self.plans[#self.plans + 1] = plan:Clone({newActions[a]})
                        end
                    end
                    plan:AddAction(newActions[1])
                end
            end
        end
    end

    new.RunOnTick = function(self, worldState, actor)
        if self.OnTick ~= nil then
            local result = self.OnTick(worldState, actor)

            if result ~= nil then
                --self.currentAction:Deactivate(worldState, actor)
                self:Deactivate(worldState, actor)
                self.currentAction = nil
                self.currentPlan = nil
            end
        end
    end

    new.Activate = function(self, worldState, actor)
        if self.OnActivated ~= nil then
            self.OnActivated(worldState, actor)
        end
    end

    new.Deactivate = function(self, worldState, actor)
        if self.OnDeactivated ~= nil then
            self.OnDeactivated(worldState, actor)
        end

        if self.currentAction ~= nil then
            self.currentAction:Deactivate(worldState, actor)
        end
    end

    return new
end

GoalOrientedActionPlanner.Plan.new = function(actions)
    local new = {}
    new.actions = actions
    new.tempState = {}

    for _, action in ipairs(actions) do
        for key, value in action:Effects() do
            new.tempState[key] = value
        end
    end

    new.AddAction = function(self, action)
        self.actions[#self.actions + 1] = action
        for key, value in pairs(action:Effects()) do
            self.tempState[key] = value
        end
    end

    new.CurrentAction = function(self)
        if #self.actions == 0 then return nil end

        for i = #self.actions, 1, -1 do
            if self.actions[i] ~= nil then
                return self.actions[i]
            end
        end

        return nil
    end

    new.RemoveCurrentAction = function(self)
        if #self.actions > 0 then
            self.actions[#self.actions] = nil
        end
    end

    new.GetCost = function(self, worldState, actor)
        local cost = 0
        for _, action in ipairs(self.actions) do
            cost = cost + action:GetCost(worldState, actor)
        end
        return cost
    end

    new.Clone = function(self, actions)
        local newActions = {}

        for _, action in ipairs(self.actions) do
            table.insert(newActions, action)
        end

        if actions ~= nil then
            for _, action in ipairs(actions) do
                table.insert(newActions, action)
            end
        end

        return GoalOrientedActionPlanner.Plan.new(newActions)
    end

    local function Equals(a,b)
        if a == nil or b == nil or #a.actions ~= #b.actions then return false end
        for i = 1, #a.actions do
            if a.actions[i] ~= b.actions[i] then return false end
        end
        return true
    end

    return setmetatable(new, {__eq = Equals})
end

GoalOrientedActionPlanner.Goap.new = function()
    local new = {}
    new.goals = {}
    new.currentGoal = nil

    new.Load = function(self, goals, actions)
        for _, goal in pairs(goals) do
            self.goals[#self.goals + 1] = require(goal).new()
        end

        local actionList = {}
        for _, action in pairs(actions) do
            actionList[#actionList + 1] = require(action)
        end

        for _, goal in self.goals do
            goal:BuildPlans(actionList)
        end
    end

    new.Tick = function(self, worldState, actor)
        local bestGoal = nil
        local bestPriority = 0
        for _, goal in self.goals do
            goal:RunOnTick(worldState, actor)

            if not goal:CanRun(worldState, actor) then continue end

            local priority = goal:Priority(worldState, actor)

            if priority > bestPriority then
                bestPriority = priority
                bestGoal = goal
            end
        end

        if bestGoal == nil then
            if self.currentGoal ~= nil then
                self.currentGoal:Deactivate(worldState, actor)
                self.currentGoal = nil
            end

            return
        end

        if bestGoal ~= self.currentGoal then
            if self.currentGoal ~= nil then
                self.currentGoal:Deactivate(worldState, actor)
            end
            self.currentGoal = bestGoal
            self.currentGoal:Activate(worldState, actor)
        end

        if self.currentGoal ~= nil then
            self.currentGoal:Tick(worldState, actor)
        end	
    end

    return new
end

return GoalOrientedActionPlanner