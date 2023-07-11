local expect = require("cc.expect").expect
local util = require("modules.utilties")
local fm  = require("modules.fm")
local pretty = require("cc.pretty")
local argue = {...}
--the Path to package up
local LUA_PATH = expect(1,argue[1],"string")
-- the installer Path
local LUA_WRITE = expect(2,argue[2],"string") or ""
LUA_WRITE = util.file.withoutExtension(LUA_WRITE)..".LINS"
-- allows to specifi a installation Path when installing 
-- example "../build/OS" --> "../OS"
-- the 'build' directory  is left out because it's not a part of the program just where it's stored
-- set to true to make it a install anyWhere file 
local LUA_Install = expect(3,argue[3],"string","number","boolean","nil")
if LUA_Install and LUA_Install == "false"
then
    LUA_Install = false
elseif LUA_Install and LUA_Install == "true"
then
    LUA_Install = true
elseif LUA_Install
then
    LUA_Install = tonumber(LUA_Install)
    if type(LUA_Install) == "number"
    then
        LUA_Install = LUA_Install +1
    end
end
-- gets a list of programs and directorys to be packaged
local Dir = util.file.listsubs(LUA_PATH,false,true,true,false)
local files = util.file.listsubs(LUA_PATH,true,false,false,false)
local sDir,sFiles = {},{}
if LUA_Install and type(LUA_Install) == "number"
then
    for _,v in pairs(Dir) do
        table.insert(sDir,util.string.split(v,"%/"))
    end
    for _,v in pairs(files) do
        table.insert(sFiles,util.string.split(v,"%/"))
    end

    for i,v in pairs(sDir) do
        sDir[i] = table.concat(v,"/",LUA_Install)
    end
    for i,v in pairs(sFiles) do
        sFiles[i] = table.concat(v,"/",LUA_Install)
    end
else
    sDir = Dir
    sFiles = files
end

for i,v in pairs(sFiles) do
    local temp = {
        Path = v,
        func = fm.readFile(files[util.table.find(files,v)],"R")
    }
    sFiles[i] = temp
end
-- time to build the run handler
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
if LUA_Install and type(LUA_Install) == "boolean"
then
    runhanndle = runhanndle:format(true,"%s","%s",textutils.serialise(sFiles),textutils.serialise(sDir))
else
    runhanndle = runhanndle:format(false,"%s","%s",textutils.serialise(sFiles),textutils.serialise(sDir))
end
fm.OverWrite(LUA_WRITE,runhanndle,"R")