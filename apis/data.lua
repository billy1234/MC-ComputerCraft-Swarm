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