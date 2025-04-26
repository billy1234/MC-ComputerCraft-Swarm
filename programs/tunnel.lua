os.loadAPI("apis/data.lua")
os.loadAPI("apis/base.lua")
os.loadAPI("apis/movement.lua")


VERSION = "0.0.2"

--allow W/ N /S in test world
ALLOWED_DIRECTIONS = {
    [movement.ORIENTATIONS.west] = true,
    [movement.ORIENTATIONS.north] = true,
    [movement.ORIENTATIONS.south] = true,
}

--This function assumes you will start from inside the tunnel cover (0,0,0) in local cords
local function findTunnelEnterance()
    local moves = movement.CursorOf({
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.up,
    })

    if(ALLOWED_DIRECTIONS[movement.ORIENTATIONS.east]) then
        print("East allowed")
    else
        print("East not allowed")
    end

    print(moves:doNext(turtle))
    print(moves:doNext(turtle))
end

findTunnelEnterance()