os.loadAPI("apis/data.lua")
os.loadAPI("apis/base.lua")
os.loadAPI("apis/movement.lua")


VERSION = "0.0.3"

--allow W/ N /S in test world
ALLOWED_DIRECTIONS = {
    [movement.ORIENTATIONS.west] = true,
    [movement.ORIENTATIONS.north] = true,
    [movement.ORIENTATIONS.south] = true,
}

EXISTING_TUNNELS = {

}

-- this function finds the first step alinged with the cardinal directions (n/s/e/w)
local function setupDesend()
    --assuming at same level as mine cover
    local moves = movement.CursorOf({
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.turnRight,
        movement.MOVEMENTS.turnRight,
        movement.MOVEMENTS.turnRight,
    })


    while (moves:doNext(turtle))
    do
        local success, data = turtle.inspect()

        if success and data.name == "minecraft:cobblestone" then
            return true
        end
    end
    return false

end

-- will undo on fail
local function downToNextStep()
    local moves = movement.Of({
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.turnRight,
    })

    return moves:doMoves(turtle, true)

end

--This function assumes you will start from inside the tunnel cover (0,0,0) in local cords
local function findTunnelEnterance()
    if not setupDesend() then
        return false
    end

    if not downToNextStep() then
        movement.doMove(turtle,  movement.MOVEMENTS.up)
        return false
    end

    --ignore 1st 2 steps

    local shaftDepth = 1

    while (true)
    do
        if not downToNextStep() then
            print("Cant step down")
            movement.FaceNorth()

            --maybe retun to surface
            return false
        end
        if EXISTING_TUNNELS[shaftDepth] == nil and ALLOWED_DIRECTIONS[movement.POSITION.orientation] then
            movement.doMove(turtle,  movement.MOVEMENTS.up)
            break
        end
        shaftDepth = shaftDepth + 1
    end
    return shaftDepth
end

local function digTunnelSegment()
    local x = movement.POSITION.x
    local y = movement.POSITION.y

    local orientationVector = movement.GetOrientationVector()

    local nextStepDepth = (((x + 16) * orientationVector.x) + ((y + 16) * orientationVector.y)) % 16
    if nextStepDepth == 0 then
        nextStepDepth = 16
    end

    print(nextStepDepth)
end

local function digTunnel()
    local moves = movement.Of({
            movement.MOVEMENTS.forward,
    })

    if not moves:doMoves(turtle, true) then
        return false
    end
    digTunnelSegment()

    --debug undo code

    local moves = movement.Of({
        movement.MOVEMENTS.backward,
    })
    
    if not moves:doMoves(turtle, true) then
        return false
    end

end

movement.FaceNorth()
print(findTunnelEnterance())
digTunnel()
