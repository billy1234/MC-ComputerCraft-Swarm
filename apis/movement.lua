os.loadAPI("apis/data.lua")

VERSION = "0.0.1"

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

-- vector is represented as x,z
---@type table<orientation,number[]>
ORIENTATION_VECTOR = {
    [ORIENTATIONS.south]={1,0},
    [ORIENTATIONS.west]={0,-1},
    [ORIENTATIONS.north]={-1,0},
    [ORIENTATIONS.east]={0,1},
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

POSITION = data.GetFile("position")

local function setupPosition()
    print("This program will ask for orientation info")
    print("Enter Y coordinate of turtle")
    POSITION.y = tonumber(read())
    --todo handle bad input

    print("Enter X coordinate of turtle")
    POSITION.x = tonumber(read())

    print("Enter Z coordinate of turtle")
    POSITION.z = tonumber(read())

    print("Enter the facting direction of the turtle (n/s/e/w)")
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
    print("Data updated")
    data.WriteFile("position",POSITION)

end

---@param move movement
---@return boolean
function doMove(turtle, move)
    ---@type boolean
    local success = false
    if move == 'forward' then
        success = turtle.forward()
        if success then
            local offset = ORIENTATION_VECTOR[POSITION.orientation]
            POSITION.x = offset[0]
            POSITION.y = offset[1]
        end
    elseif move == 'back' then
        success = turtle.back()
        if success then
            local offset = ORIENTATION_VECTOR[POSITION.orientation]
            POSITION.x = -offset[0]
            POSITION.y = -offset[1]
        end
    elseif move == 'up' then
        success =  turtle.up()
        if success then
            POSITION.y = POSITION.y + 1
        end
    elseif move == 'down' then
        success =  turtle.down()
        if success then
            POSITION.y = POSITION.y - 1
        end
    elseif move == 'turnLeft' then
        success = turtle.turnLeft()
        if success and POSITION.orientation ~= ORIENTATIONS.invalid then
            --add is clockwise
            -- minus is anti clockwise
            POSITION.orientation = (POSITION.orientation - 1) % 4

        end
    elseif move == 'turnRight' then
        success = turtle.turnRight()
        if success and POSITION.orientation ~= ORIENTATIONS.invalid then
            POSITION.orientation = (POSITION.orientation + 1) % 4

        end
    end
    data.WriteFile("position",POSITION)
    return success
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

---@class MovementList
---@field moves movement[]
MovementList = {moves = {}}

---@param moves movement[]
function MovementList:new(o, moves)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.moves = moves
    return o
end

---@param moves movement[]
---@returns MovementList
function Of(moves)
    return MovementList:new(nil,moves)
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


--[[
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
--]]

function FaceNorth(turtle)
    if POSITION.orientation == ORIENTATIONS.invalid then
        print("WARNING: No orientation stored, be sure to run setup")
        return false
    end

    if POSITION.orientation == ORIENTATIONS.north then
        return true
    end

    if POSITION.orientation == ORIENTATIONS.east then
        return turtle.turnLeft()
    end

    if POSITION.orientation == ORIENTATIONS.south then
        local result = turtle.turnLeft()
        result = turtle.turnLeft() and result
        return result
    end

    if POSITION.orientation == ORIENTATIONS.east then
        return turtle.turnRight()
    end

    print("No case for this orientation")

    return false
end

MovementCursor = { movementList = {}}

---@param moves movement[]
function MovementCursor:new(o, moves)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    o.currentMove = 1
    o.movementList = Of(moves)
    return o
end

---@param moves movement[]
function CursorOf(moves)
    return MovementCursor:new(nil,moves)
end


function MovementCursor:doNext(turtle)
    if (self.currentMove < 0 or self.currentMove > #self.movementList.moves) then
        print("Movement error, cursor index out of bounds")
        return false
    end
    local res = doMove(turtle, self.movementList.moves[self.currentMove])
    if res then
        self.currentMove = self.currentMove + 1
    end
    return res
end



--temp code for now, direct exec of this api alows interactive setup
local arg1 = ...

if arg1 == "i" then
    setupPosition()
end
