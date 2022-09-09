return {
    new = function()
        return require(script.Parent.Parent.goap).Action.new("wander action", 0, nil, {wander = true})
    end
}