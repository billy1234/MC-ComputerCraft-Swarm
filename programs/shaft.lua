os.loadAPI("apis/data.lua")
os.loadAPI("apis/base.lua")

VERSION = "0.0.5"

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
    print("Slots Info: ")
    print("Fuel: 16")
    print("Buildable: " .. BUILDABLE_SLOT)
    print("Chest: " .. CHEST_SLOT)
    print("Cobble (no need to provide): " .. COBBLE_SLOT)
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
    return true
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
                or data.name == 'minecraft:lava' 
                or data.name == 'minecraft:water' 
            then
                print("hit " .. data.name)
                break
            end
        end

        local stepDownSuccess = turtle.digDown()
        stepDownSuccess = turtle.down() and stepDownSuccess

        if not stepDownSuccess then
            print("Step down failed")
            break
        end


        --dig 3x3
        local digSuccess = Dig3x3()
        digSuccess = PlaceStairs(stairPos) and digSuccess
        SortInventory(false,false)

        if not digSuccess then
            print("Dig failed")
            break
        end
        

        depth = depth + 1
        stairPos = (stairPos + 1) % 8
    end

    MineData.SHAFT_HEIGHT = depth
end

--Try face north ?

--PrintHelp()
--SortInventory(true,true)
--SetupShaftCover()
--DigShaft()
--print(ROBOT_Y)
--AssendShaft()
--print(ROBOT_Y)

--data.WriteMine(MineData)

turtle.up()
Unload()
turtle.down()
