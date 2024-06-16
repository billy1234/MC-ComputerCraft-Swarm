os.loadAPI("apis/data")
os.loadAPI("apis/base")

VERSION = "0.0.0"

local currentDepth = 0

function getFuel()
    turtle.select(base.COAL_SLOT)
    local amount = turtle.getItemSpace()
    if amount == 0 then
        print("INFO: FUEL FULL")
        return
    end
    if not turtle.suckDown(amount) then
        print("WARNING: NO FUEL FOUND")
    end
end

function dig2x1forward()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    currentDepth = currentDepth + 1
end


---@param block table
---@return boolean
local function isOre(block)
    return true
end

function mineVein()
    local blockExists,currentBlock = turtle.inspect()

    if blockExists and isOre(currentBlock) then
        print(textutils.serialise(currentBlock))
    end
end

function checkVeins()
    turtle.turnLeft()
    mineVein() 
    turtle.turnRight()
    
    turtle.turnRight()
    mineVein() 
    turtle.turnLeft()

    turtle.up()

    turtle.turnLeft()
    mineVein() 
    turtle.turnRight()
    
    turtle.turnRight()
    mineVein() 
    turtle.turnLeft()

    turtle.down()
end

function tunnel(amount)
    local i = 0
    while i < amount do
        dig2x1forward()
        checkVeins()
        i = i + 1
    end
    i = 0

    while i < amount do
        turtle.back()
    end
    base.unload()
end

getFuel()
tunnel(8)