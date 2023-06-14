local expect = require("cc.expect").expect
local util = require("modules.utilties")
local fm  = require("modules.fm")
local argue = {...}
local LUA_PATH = expect(1,argue[1],"string")
local LUA_WRITE = expect(2,argue[2],"string")
LUA_WRITE = util.file.withoutExtension(LUA_WRITE)..".Lins"
local LUA_isRealitive = false
if argue[3] and (argue[3] == "true" or argue[3] == true)
then
    LUA_isRealitive = true
end
if not fs.exists(LUA_PATH)
then
    error(("%s : #1 directory is nonExistant"):format(LUA_PATH),0)
end
if not fs.isDir(LUA_PATH)
then
    error(("%s: #1 expected directory got File"):format(LUA_PATH),3)
 end
if fs.isDir(LUA_WRITE)
then
    error(("%s: #2 expected file type got directory type"):format(LUA_WRITE),3)
end
local list = util.file.listsubs(LUA_PATH,false,true)
local mainTable = {}
local Dirs = util.file.listsubs(LUA_PATH,false,false,true)
local DirsMainTable = {}
if LUA_isRealitive
then
    for a,v in pairs(list) do
        local Temp = util.string.split(v,"/")
        local Path = ""
        for i,b in pairs(Temp) do
            if b == fs.getName(LUA_PATH)
            then
                Path = table.concat(Temp,"/",i,#Temp)
            end
        end
        list[a] = Path
    end
    for a,v in pairs(Dirs) do
        local Temp = util.string.split(v,"/")
        local Path = ""
        for i,b in pairs(Temp) do
            if b == fs.getName(LUA_PATH)
            then
                Path = table.concat(Temp,"/",i,#Temp)
            end
        end
        Dirs[a] = Path
    end
end
for _,v in pairs(list) do
    textutils.slowPrint(v)
    local Path = ""
    local Table = {
        Path = v
    }
    if LUA_isRealitive
    then
        Table.func = fm.readFile(fs.combine(fs.getDir(LUA_PATH),v),"R")
    else
        Table.func = fm.readFile(v,"R")
    end
    table.insert(mainTable,Table)
end
for _,v in pairs(Dirs) do
    local Table = {}
    Table.Path = v
    table.insert(DirsMainTable,Table)
end

local runhanndle = [[
    local Argue = {...}
    local expect = require("cc.expect").expect
    local Path
    if %q
    then
        Path = expect(1,Argue[1],"string","nil") or ""
        if not fs.exists(Path) 
        then
            error(("%s not found"):format(Path),2)
        end
        if not fs.isDir(Path)
        then
            error(("%s is not directory"):format(Path),2)
        end
    end
    local programs = textutils.unserialise(%q)
    local Dirs = %s
    for _,v in pairs(Dirs) do
        if Path
        then
            fs.makeDir(fs.combine(Path,v.Path))
        else
            fs.makeDir(v.Path)
        end
    end
    for _,v in pairs(programs) do
        local file,mess
        if Path
        then
            file,mess = fs.open(fs.combine(Path,v.Path),"w")
        else
            file,mess = fs.open(v.Path,"w")
        end
        if not file
        then
            error(mess,0)
        end
        file.write(v.func)
        file.close()
    end
    
]]
fm.OverWrite(LUA_WRITE,runhanndle:format(LUA_isRealitive,"%s","%s",textutils.serialise(mainTable),textutils.serialise(DirsMainTable)),"R")


