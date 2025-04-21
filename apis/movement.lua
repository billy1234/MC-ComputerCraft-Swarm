VERSION = "0.0.0"

---@alias movement 'forward'
---| 'back'
---| 'up'
---| 'down'
---| 'left'
---| 'right'
---| 'turnLeft'
---| 'turnRight'


---@alias orientation 0
---| 1
---| 2
---| 3
---| 4


ORIENTATIONS = {
    south=0,
    west=1,
    north=2,
    east=3,
    invalid=4,
}


---@type table<movement, movement>
MOVEMENTS = {
    forward='forward',
    back='back',
    left='left',
    right='right',
    up='up',
    down='down',
    turnLeft='turnLeft',
    turnRight='turnRight'
}

---@type table<movement, movement>
MOVEMENT_INVERSES = {
    [MOVEMENTS.forward] = MOVEMENTS.back,
    [MOVEMENTS.back] = MOVEMENTS.forward,
    [MOVEMENTS.up] = MOVEMENTS.down,
    [MOVEMENTS.down] = MOVEMENTS.up,
    [MOVEMENTS.left] = MOVEMENTS.right,
    [MOVEMENTS.right] = MOVEMENTS.left,
    [MOVEMENTS.turnLeft] = MOVEMENTS.turnRight,
    [MOVEMENTS.turnRight] = MOVEMENTS.turnLeft,
}

POSITION = {
    orientation = 2,
    x = 0,
    y = 0,
    z = 0
}

local function setupPosition()
    print("This program will ask for orientation info")
    print("enter Y corrdinate of turtle")
    POSITION.y = tonumber(read())
    --todo handle bad input

    print("enter X corrdinate of turtle")
    POSITION.x = tonumber(read())

    print("enter Z corrdinate of turtle")
    POSITION.z = tonumber(read())

    print("enter the facting direction of the turtle (n/s/e/w)")
    local char = read()

    if(char == "n") then
        POSITION.orientation = ORIENTATIONS.north
    elseif (char == "e") then
        POSITION.orientation = ORIENTATIONS.east
    elseif (char == "s") then
        POSITION.orientation = ORIENTATIONS.south
    elseif (char == "w") then
        POSITION.orientation = ORIENTATIONS.west
    end

end

setupPosition()
print(POSITION)

---@param move movement
local function doMove(turtle, move)
    if move == 'forward' then
        return turtle.forward()
    elseif move == 'back' then
        return turtle.back()
    elseif move == 'up' then
        return turtle.up()
    elseif move == 'down' then
        return turtle.down()
    elseif move == 'turnLeft' then
        return turtle.turnLeft()
    elseif move == 'turnRight' then
        return turtle.turnRight()
    end
    return false
end

---@generic T
---@param x T[]
---@return T[]
local function reverse(x)
    local copy = {}
    for i,e in ipairs(x) do
        copy[i] = x[#x-i+1]
    end
    return copy
end


---@param moves movement[]
local function undoMoves(turtle, moves)
    local reverse_moves = reverse(moves)
    for i,e in ipairs(reverse_moves) do
        if not doMove(turtle,MOVEMENT_INVERSES[e]) then
            return false 
        end
    end
    return true
end


MovementList = {moves = {}}

---@param moves movement[]
function MovementList:new(o, moves)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.moves = moves
    return o
end

---@param onFail fun(e : movement, i : integer)
---@param revert boolean
---@return boolean
function MovementList:doMoves(turtle, revert, onFail)
    onFail = onFail or function(e,i) print("Failed to execute ["..i.."] move: "..e) end
    local completedMoves = {}
    for i,e in ipairs(self.moves) do
        if doMove(turtle,e) then
            completedMoves[i] = e
        else
            if onFail ~= nil then
                if onFail(e,i) == true then
                else
                    if revert then undoMoves(turtle,completedMoves) end
                    return false
                end
            else
                if revert then undoMoves(turtle,completedMoves) end
                return false
            end
        end
    end
    return true
end

---@param m movement
---@return boolean
function MovementList:doMoveAdd(turtle, m)
        if doMove(turtle,m) then
            table.insert(self.moves,m)
        else
            print("Move: " .. m .. " Failed")
            return false
        end
    return true
end

---@param moves movement[]
function Of(moves)
    return MovementList:new(nil,moves)
end


---@return orientation
function GetOrientationGPS(turtle)
    local loc1 = vector.new(gps.locate(2, false))
    if loc1 == nil then
        return 0
    end

    if not turtle.forward() then
       return 0
    end
    local loc2 = vector.new(gps.locate(2, false))

    local heading = loc2 - loc1
    turtle.back()
    local res = ((heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3))
    --https://www.computercraft.info/forums2/index.php?/topic/1704-get-the-direction-the-turtle-face/

    if res == 1 then return ORIENTATIONS.west
        elseif res == 2 then return ORIENTATIONS.north
        elseif res == 3 then return ORIENTATIONS.east
        elseif res == 4 then return ORIENTATIONS.south
        else return ORIENTATIONS.invalid
    end

end

function FaceNorth()
    local orientation = GetOrientationGPS()
    if orientation == 0 then
        print("cant get location will use current facing dir as 'north'")
        return
    end
    print("Not impelmented")
end
