local PlayersService = game:GetService("Players")

local Params = {
    Humanoid = RaycastParams.new{ FilterType = Enum.RaycastFilterType.Blacklist, FilterDescendantsInstances = {}, IgnoreWater = true, CollissionGroup = "NPC" },
    Terrain = RaycastParams.new{ FilterType = Enum.RaycastFilterType.Whitelist, FilterDescendantsInstances = { workspace.Terrain } }
}

-- Provides a set of commonly used functions
local Common = {}

-- Reverse a **list**
function Common.Reverse(list)
    local new, input = {} , list or {}
    for i = #input, 1, -1 do
        new[#new + 1] = input[i]
    end
    return new
end

-- Checks if a **element** is in a **list**
function Common.Contains(list: {any}, element: any): boolean
    for _, v in list do
        if v == element then return true end
    end
    return false
end

-- Returns a **number** in the range of **mappedMin** to **mappedMax** based on the **inputValue** in the range of **min** to **max**
function Common.Map(inputValue: number, min: number, max: number, mappedMin: number, mappedMax: number): number
    return if inputValue < min then mappedMin elseif inputValue > max then mappedMax else (inputValue - min) / (max - min) * (mappedMax - mappedMin) + mappedMin
end

-- Checks if the **target** is within the view of the **actor**
function Common.HumanoidInLineOfSight(actor: Humanoid, target: Humanoid, distance: number, ignoreList: {}?): boolean
    local params = Params.Humanoid
    params.FilterDescendantsInstances = ignoreList or { actor:GetChildren() }

    local ray = workspace:Raycast(actor.RootPart.Position, (target.RootPart.Position - actor.RootPart.Position).Unit * distance, params)

    return (ray ~= nil and ray.Instance:IsDescendantOf(target.Parent)) and true or false
end

-- Returns table of ***Humanoid***'s (players) within the **radius** of the **actor**'s view
function Common.ListPlayersWithinView(actor: Humanoid, radius: number, sortByDistance: boolean?) : {Humanoid}
    local cframe, results = actor.RootPart.CFrame, {}

    for _, player in PlayersService:GetPlayers() do
        if not player.Character then
            continue
        end

        local diff = Common.DiffVector(actor, player.Character.Humanoid)

        if diff.Magnitude > radius then
            continue
        end

        if Common.AngleBetween(cframe.LookVector, diff.Unit) > Common.Map(diff.Magnitude, 10, 25, 180, 60) then
            continue
        end

        if not Common.HumanoidInLineOfSight(actor, player.Character.Humanoid, radius) then
            continue
        end

        results[#results + 1] = player.Character.Humanoid
    end

    if sortByDistance then
        table.sort(results, function(a, b)
            return (a.RootPart.Position - actor.RootPart.Position).Magnitude < (b.RootPart.Position - actor.RootPart.Position).Magnitude
        end)
    end

    return results
end

-- Returns the closest player within the **radius** of the **actor**'s view
function Common.ClosestPlayerWithinView(actor: Humanoid, radius: number)
    local cframe = actor.RootPart.CFrame

    local success, closestPlayer, closestDistance = false, nil, math.huge

    for _, player in PlayersService:GetPlayers() do
        if not player.Character then
            continue
        end

        local diff = Common.DiffVector(actor, player.Character.Humanoid)

        if diff.Magnitude > radius then
            continue
        end

        if Common.AngleBetween(cframe.LookVector, diff.Unit) > Common.Map(diff.Magnitude, 10, 30, 180, 45) then
            continue
        end

        if not Common.HumanoidInLineOfSight(actor, player.Character.Humanoid, radius) then
            continue
        end

        if diff.Magnitude < closestDistance then
            success, closestPlayer, closestDistance = true, player.Character.Humanoid, diff.Magnitude
        end
    end

    return success, closestPlayer, closestDistance
end

-- Returns a **number** representing the angle between the **lookVector** and the **targetUnitVector**
function Common.AngleBetween(lookVector: Vector3, targetUnitVector: Vector3): number
    return math.deg(math.acos(lookVector:Dot(targetUnitVector.Unit)))
end

-- Returns a **Vector3** representing the difference between the **actor** and the **target**
function Common.DiffVector(actor: Humanoid, target: Humanoid): Vector3
    return target.RootPart.Position - actor.RootPart.Position
end

-- Returns a **Vector3** representing a prediction of the **target**'s position in the future based on the **target**'s current velocity, speed and distance in relation to the **actor**
function Common.PredictPosition(actor: Humanoid, target: Humanoid): Vector3
    return target.RootPart.Velocity == Vector3.zero and target.RootPart.Position or target.RootPart.Position + target.RootPart.Velocity.Unit * Common.Map((actor.RootPart.Position - target.RootPart.Position).Magnitude, 10, target.WalkSpeed * 2, 3, target.WalkSpeed)
end

return Common