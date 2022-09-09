local goap = require("goap")

local goals = {
    goap.Goal.new("keep feed", {hunger = true}, 0, nil),
    goap.Goal.new("wander", {wandering = false}, 0, nil),
    goap.Goal.new("idle", {idle = false}, 10, nil),
    goap.Goal.new("kill player", {enemyDead = true}, 0, nil),
    goap.Goal.new("stay warm", {cold = true}, 0, nil),
}

local actions = {
    goap.Action.new("gather tinder and wood", 1000, nil, {haveTinder = true, haveWood = true}),
    goap.Action.new("build camp fire", 1000, {haveWood = true}, {haveCampFire = true, haveWood = false}),
    goap.Action.new("keep fire alive", 0, {haveTinder = true, haveCampFire = true}, { haveTinder = false, cold = true}),
    goap.Action.new("walk", 0, nil, {wandering = false}),
    goap.Action.new("do nothing", 0, nil, {idle = false}),
    goap.Action.new("chase", 20, nil, {enemyInRange = true}),
    goap.Action.new("stun", 5, nil, {enemyDead = true}),
    goap.Action.new("ranged attack", 0, nil, {enemyDead = true}),
    goap.Action.new("melee attack", 0, {enemyInRange = true}, {enemyDead = true}),
    goap.Action.new("gather Meat", 1600, nil, {haveMeat = true}),
    goap.Action.new("kill Boar", 1000, nil, {haveMeat = true}),
    goap.Action.new("eat meat", 10, {haveMeat = true}, {haveMeat = false, hunger = true}),
    goap.Action.new("gather wood", 1000, nil, {haveWood = true}),
    goap.Action.new("gather gems", 1000, nil, {haveGems = true}),
    goap.Action.new("trade gems for meat", 50, {haveGems = true}, {haveMeat = true, haveGems = false}),
    goap.Action.new("trade wood for gold", 100, {haveWood = true}, {haveGold = true, haveWood = false}),
    goap.Action.new("trade gold for meat", 200, {haveGold = true}, {haveMeat = true, haveGold = false}),
    goap.Action.new("trade gold for gems", 200, {haveGold = true}, {haveGems = true, haveGold = false}),
}

local function Reverse(list: table): table
    local new, input = {} , list or {}
    for i = #input, 1, -1 do
        new[#new + 1] = input[i]
    end
    return new
end

local function Timed(func) : number | any
    local startTime, result = os.clock(), func()
    return (os.clock() - startTime) * 1000, result
end

local goap = goap.Goap.new()

local loadTime = Timed(function() return goap:DirectLoad(goals, actions) end)

print(("\nLoaded in %.2f us (%.2f ms)\n"):format(loadTime*1000, loadTime))
print("---------------------------------------------------------------------------------------------------------------\n")

local state = {
    --haveMeat = true,
    --haveWood = true,
    --haveGold = true
}

for _, goal in goap.goals do
    local str = ""
    local time, plans = Timed(function() return goal:GetPlans(state, {}) end)
    print(("Retreived plans for goal: %s in %.2f us (%.2f ms)\n"):format(goal.name, time*1000, time))

    for _, plan in plans do
        local effectStr = ""

        for key, value in plan.tempState do
            effectStr = effectStr .. "  " .. key .. " = " .. tostring(value)
        end

        for _, action in pairs(Reverse(plan.actions)) do
            str = str .. "[" .. action:Name() .. "] -> "
        end

        str = str .. goal.name

        print(("Cost: %5s  -  %s"):format(plan:GetCost(state, {}), str, effectStr))
        str = ""
    end

    print("\n---------------------------------------------------------------------------------------------------------------\n")
end

print("Done!")