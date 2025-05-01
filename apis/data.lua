if not fs.exists("data") then
    fs.makeDir("data")
    print("made data/")
end

---@param fileName string
---@param obj table
---@param verbose boolean | nil
function WriteFile(fileName, obj, verbose)
    local f = io.open("data/" .. fileName,"w+")
    if f == nil then
        print("bad file")
        return false
    end

    for k,v in pairs(obj) do
        if verbose then
            print(k .. " : " .. v)
        end
        f:write(k .. "=" .. v .. "\n")
      end
    f:close()
    return true
end

---@param fileName string
function ReadFile(fileName, verbose)
    local handle = fs.open("data/".. fileName, "r")
    if not handle then
        return false
    end

    local result = {}
    local line = handle.readLine()
    while line do
        if verbose then
            print(line)
        end
        k, v = string.match(line,"^(.*)=(.*)")
        if verbose then
            print(k .. " : " ..v)
        end
        result[k] = v
        line = handle.readLine()
    end
    handle.close()

    if not _G["files"] then
        _G["files"] = {}
    end
    _G["files"][fileName] = result

    return result
end

---@param fileName string
function GetFile(fileName)
    return _G["files"][fileName]
end