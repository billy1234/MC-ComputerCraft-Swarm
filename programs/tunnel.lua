os.loadAPI("apis/data.lua")
os.loadAPI("apis/base.lua")
os.loadAPI("apis/movement.lua")


VERSION = "0.0.1"

--This function assumes you will start from inside the tunnel cover (0,0,0) in local cords
local function findTunnelEnterance()
    local moves = movement.CursorOf({
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.up,
    })

    print(moves:doNext(turtle))
    print(moves:doNext(turtle))
end

findTunnelEnterance()