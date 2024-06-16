os.loadAPI("apis/base")
os.loadAPI("apis/movement")


local r = movement.Of({
    movement.MOVEMENTS.turnLeft,
    movement.MOVEMENTS.turnLeft,
    }
)

r:doMoves(turtle,true)