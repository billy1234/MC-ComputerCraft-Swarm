local reactor
reactor = peripheral.wrap("back")

local monitor = peripheral.find("monitor")


local function renderInfo(batteryRatio)
    if monitor == nil then
        return
    end
    monitor.setCursorPos(1, 1)
    monitor.write("Battery:")
    monitor.setCursorPos(1, 2)  
    monitor.write(string.format("%.3f", batteryRatio * 100) .. "%")
end

while true do

    local battery = reactor.battery()

    local batteryRatio = battery.stored() /  battery.capacity()

    if (batteryRatio < 0.3 & reactor.getConnected()) then
        reactor.setActive(true)
    elseif (batteryRatio > 0.7 & !reactor.getConnected()) then
        reactor.setActive(false)
    end


    renderInfo(
        batteryRatio
    )

    os.sleep(10)
end

