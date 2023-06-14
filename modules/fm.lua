local expect = ((require and require "cc.expect") or dofile("OS/modules/main/cc/expect.lua")).expect
local fs = fs
local fm = {}
function fm.OverWrite(sPath,data,mode,Owner,hidden,Share)
    expect(1,sPath,"string")
    expect(3,mode,"string","nil")
    expect(4,Owner,"string","nil")
    expect(6,hidden,"boolean","nil")
    expect(7,Share,"boolean","nil")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    local file,mess = fs.open(sPath,"w",Owner,hidden,Share)
    if file == nil then
        return error(mess,0)
    end
    if mode == "R"
    then
        file.write(data)
    else
        file.write(textutils.serialise(data))
    end
    file.close()
    return true
end
function fm.WriteLine(sPath,data,mode,Owner,hidden,Share)
    expect(1,sPath,"string")
    expect(3,mode,"string","nil")
    expect(4,Owner,"string","nil")
    expect(6,hidden,"boolean","nil")
    expect(7,Share,"boolean","nil")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    local file,mess = fs.open(sPath,"a",Owner,hidden,Share)
    if file == nil then
        return error(mess,0)
    end
    if mode == "R"
    then
        file.write(data)
    else
        file.write(textutils.serialise(data))
    end
    file.close()
    return true
end
function fm.readFile(sPath,mode)
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",3)
    end
    if not fs.exists(sPath) then
        error("Invalid path "..sPath.." dose not exist",3)
    end
    local file,mess = fs.open(sPath,"r")
    if file == nil then
        return error(mess,0)
    end
    local data
    if mode == "R"
    then
        data = file.readAll()
    else
        data = textutils.unserialise(file.readAll())
    end
    file.close()
    return data
end
return fm