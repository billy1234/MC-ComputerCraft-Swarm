os.loadAPI("apis/data.lua")
os.loadAPI("apis/base.lua")

VERSION = "0.0.9"

BUILDABLE_SLOT = 15
CHEST_SLOT = 14
COBBLE_SLOT = 13

BUILDABLE_NAME = ''

ROBOT_Y = -1

--Swarm variables
MineData = {
    SHAFT_HEIGHT = -1
}

function PrintHelp()
    print("  Slots Info: ")
    print("  Fuel: 16")
    print("  Buildable: " .. BUILDABLE_SLOT)
    print("  Chest: " .. CHEST_SLOT)
    print("  The build material can be added to the equipted slot")
end

function SortInventory (refuel, setFirst)
    for i = 1, 12 do --12 as 13-16 are reserved
        local item = turtle.getItemDetail(i)
        if (item ~= nil)
        then
            if (i == 1 and setFirst) or (item.name == BUILDABLE_NAME) then --Used slot 1 to allow player to pass any buildable
                turtle.select(i)
                turtle.transferTo(BUILDABLE_SLOT)
                BUILDABLE_NAME = item.name
            end
            if item.name == 'minecraft:cobblestone' and i ~= BUILDABLE_SLOT then
                turtle.select(i)
                turtle.transferTo(COBBLE_SLOT)
            end
            if item.name == 'minecraft:chest' then
                turtle.select(i)
                turtle.transferTo(CHEST_SLOT)
            end
            if item.name == 'minecraft:coal' then
                turtle.select(i)
                turtle.transferTo(base.COAL_SLOT)
                if refuel then
                    print('refueling')
                    turtle.select(base.COAL_SLOT)
                    turtle.refuel()
                end
            end
        end
    end
    turtle.select(1)
end



function PlaceTwoForwardTurn(slotNum --[[int]])
    turtle.select(slotNum or 1)
    if turtle.forward() == false then
        print("Error block in the way")
        return false
    end
    if turtle.placeDown() == false then
        print("Error block in the way/ no buildable")
        return false
    end
    if turtle.forward() == false then
        print("Error block in the way")
        return false
    end
    if turtle.placeDown() == false then
        print("Error block in the way/ no buildable")
        return false
    end
    if turtle.turnRight() == false then
        print("Error turning")
        return false
    end
    return true
end

function Place3x3Hollow(slotNum --[[int]])
    turtle.select(slotNum)
    --Maybe check we have 8 items + chest

    if turtle.forward() == false then
        print("Error block in the way")
        return false
    end
    if turtle.placeDown() == false then
        print("Error block in the way/ no buildable")
        return false
    end

    if turtle.turnRight() == false then
        print("Error turning")
        return false
    end
    if turtle.forward() == false then
        print("Error block in the way")
        return false
    end
    if turtle.placeDown() == false then
        print("Error block in the way/ no buildable")
        return false
    end
    if turtle.turnRight() == false then
        print("Error turning")
        return false
    end

    if not ( PlaceTwoForwardTurn(BUILDABLE_SLOT)
        and PlaceTwoForwardTurn(BUILDABLE_SLOT)
        and PlaceTwoForwardTurn(BUILDABLE_SLOT)) then
        print("Error placing 3x3")
        return false
    end

    if not ( turtle.forward()
        and turtle.turnRight()
        and turtle.forward()
        and turtle.down()) then
        print("Failed to reset")
        return false
    end

    return true

end



function SetupShaftCover()
    if turtle.up() == false then
        print("Error block in the way")
        return -1
    end

    turtle.select(CHEST_SLOT)
    if turtle.placeUp() == false then
        print("Error block in the way/ no buildable")
        return -1
    end

   Place3x3Hollow(BUILDABLE_SLOT)

    return 0
end

function PlaceStairs(stairPos)
    local success = false
    if not turtle.select(COBBLE_SLOT) then
        return false
    end

    if stairPos == 0 then --forward
        success = turtle.place() and success
        return success

    elseif stairPos == 1  then
        success = turtle.forward() and success
        success = turtle.turnRight() and success
        success = turtle.place() and success
        success = turtle.turnLeft() and success
        success = turtle.back() and success
        return success

    elseif stairPos == 2  then --right
        success = turtle.turnRight() and success
        success = turtle.place() and success
        success = turtle.turnLeft() and success
        return success

    elseif stairPos == 3  then
        success = turtle.turnRight() and success
        success = turtle.forward() and success
        success = turtle.turnRight() and success
        success = turtle.place() and success
        success = turtle.turnLeft() and success
        success = turtle.back() and success
        success = turtle.turnLeft() and success
        return success

    elseif stairPos == 4  then --back
        success = turtle.turnRight() and success
        success = turtle.turnRight() and success
        success = turtle.place() and success
        success = turtle.turnLeft() and success
        success = turtle.turnLeft() and success
        return success

    elseif stairPos == 5  then 
        success = turtle.turnLeft() and success
        success = turtle.forward() and success
        success = turtle.turnLeft() and success
        success = turtle.place() and success
        success = turtle.turnRight() and success
        success = turtle.back() and success
        success = turtle.turnRight() and success

        return success
    elseif stairPos == 6  then --left
        success = turtle.turnLeft() and success
        success = turtle.place() and success
        success = turtle.turnRight() and success
        return success

    elseif stairPos == 7  then
        success = turtle.forward() and success
        success = turtle.turnLeft() and success
        success = turtle.place() and success
        success = turtle.turnRight() and success
        success = turtle.back() and success
        return success
    end

end

function Dig3x3()
    local success = true

    -- front face
    turtle.dig() 
    success = turtle.forward() and success
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnLeft()
    success = turtle.back() and success

    -- left/right parts
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnRight()

    -- back face
    turtle.dig()
    success = turtle.forward() and success
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnRight()
    success = turtle.forward() and success

    return success -- only movements can fail this, will ignore failues to dig, truns always success according to the wiki so will ignore 
end

function AssendShaft()

    while (true) do 
        local item, data =  turtle.inspectUp()
        if item then
            if data.name == 'minecraft:chest' then
                turtle.down()
                return true
            else
                print("no chest found")
                turtle.down()
                return false
            end
        end
        turtle.up()
        ROBOT_Y = ROBOT_Y + 1
    end

end

function DigShaft()
    local depth = 0
    local stairPos = 0
    while (true) do
        local item, data =  turtle.inspectDown()
        if item then
            if data.name == 'minecraft:bedrock'
            then
                print("hit " .. data.name)
                break
            end
        end

        turtle.digDown()

        if not turtle.down() then
            print("Step down failed")
            break
        end

        if not Dig3x3() then
            print("Dig 3x3 failed")
            break
        end

        SortInventory()

        if not PlaceStairs(stairPos) then
            print("Place staris failed, stair pos: " .. stairPos)
        end

        depth = depth + 1
        stairPos = (stairPos + 1) % 8
    end

    MineData.SHAFT_HEIGHT = depth
end

--Try face north ?

PrintHelp()
SortInventory(true,true)
SetupShaftCover()
SortInventory()
DigShaft()
print(ROBOT_Y)
AssendShaft()
print(ROBOT_Y)

data.WriteMine(MineData)

turtle.up()
base.Unload()
turtle.down()
