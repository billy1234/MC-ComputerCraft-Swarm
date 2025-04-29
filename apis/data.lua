if not fs.exists("data") then
    fs.makeDir("data")
    print("made data/")
end

function WriteMine(mine)
    local f = io.open("data/mine","w")
    if f == nil then
        print("bad file")
        return false
    end
    print("SHAFT_HEIGHT="..mine.SHAFT_HEIGHT.."\n")
    f:write("SHAFT_HEIGHT="..mine.SHAFT_HEIGHT.."\n")
    f:close()
end

function WritePosition(position, quiet)
    local f = io.open("data/position","w")
    if f == nil then
        print("bad file")
        return false
    end

    if verbose then
        print("X="..position.x.."\n")
        print("Y="..position.y.."\n")
        print("Z="..position.z.."\n")
        print("ORIENTATION="..position.orientation .."\n")
    end

    f:write("X="..position.x.."\n")
    f:write("Y="..position.y.."\n")
    f:write("Z="..position.z.."\n")
    f:write("ORIENTATION="..position.orientation.."\n")
    f:close()
end

---@param fileName string
function ReadFile(fileName)
    local handle = fs.open("data/".. fileName, "r")
    if not handle then
        return false
    end

    local result = {}
    local line = handle.readLine()
    while line do
        k, v = string.match(line,"^(.*)=(.*)")
        result[k] = v
        line = handle.readLine()
    end
    handle.close()

    return result
end