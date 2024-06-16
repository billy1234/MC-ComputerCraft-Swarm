os.loadAPI("apis/data")
os.loadAPI("apis/base")

VERSION = "0.0.0"

CHEST_SLOT = 14
BUILDABLE_SLOT = 15
COBBLE_SLOT = 13

BUILDABLE_NAME = ''

ROBOT_Y = -1

--Swarm variables
MineData = {
    SHAFT_HEIGHT = -1
}

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



    print('place block below')
    return 0
end

function PlaceStairs(stairPos)
    return true
end

function Dig3x3()

    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnLeft()
    turtle.back()

    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnRight()

    turtle.dig()
    turtle.forward()
    turtle.turnLeft()
    turtle.dig()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.turnRight()
    turtle.forward()


    return true
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
                or data.name == 'minecraft:lava' 
                or data.name == 'minecraft:water' 
            then
                print("hit " .. data.name)
                return true
            end
        end


        turtle.digDown()
        turtle.down()

        --dig 3x3
        Dig3x3()
        SortInventory(false,false)
        PlaceStairs(stairPos)
        

        depth = depth + 1
        stairPos = (stairPos + 1) % 8
    end

    MineData.SHAFT_HEIGHT = depth
end

--[[SortInventory(true,true)
FaceNorth()
if not SetupShaftCover() then
    return
end]]
DigShaft()
print(ROBOT_Y)
AssendShaft()
print(ROBOT_Y)

data.WriteMine(MineData)