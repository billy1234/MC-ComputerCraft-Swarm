os.loadAPI("apis/data")
os.loadAPI("apis/base")
os.loadAPI("apis/movement")


VERSION = "0.0.0"

--This function assumes you will start from inside the tunnel cover (0,0,0) in local cords
local function findTunnelEnterance()
    local moves = movement.MovementCursor:new({
        movement.MOVEMENTS.down,
        movement.MOVEMENTS.up,
    })

    print(moves.doNext(turtle))
    print(moves.doNext(turtle))
end

findTunnelEnterance()