--- this packager is made to handle root based programs
--- it is absolute and will not work with relative file systems 
local fm = require("modules.fm")
local util = require("modules.utilties")
local GUI = require("modules.GUI")
local fileselect = require("modules.fileselect")
local textPrompt
local centerX,centerY = GUI:getCenter()
textPrompt = GUI:create(centerX-10,centerY-5,20,10,true)
textPrompt:make_textBox(true)
local installerName = textPrompt:Chat_Prompt("installerName>").."."..settings.get("packager.installer_type","Lua_Installer")
if installerName == ""
then
    return
end
local files = {}
textPrompt:clear()
textPrompt:write("path dose not exits")
local Parent = GUI:create(1,1,GUI:getSize())
Parent:upDate(true)
while true do
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local path = fileselect(Parent,"","build",true,true)
    if not path
    then
        break
    end
    if fs.isDir(path)
    then
        local to_do = util.file.listsubs(path,true,false)
        while #to_do > 0  do
            local Current = table.remove(to_do)
            files[Current] = fm.readFile(Current,"R")
        end
    else
        files[path] = fm.readFile(path,"R")
    end
end
-- time to build the run handler
local installer = [[
local expect = require("cc.expect").expect
local programs = textutils.unserialise(%q)
for Path,v in pairs(programs) do
    local file,mess = fs.open(Path,"w")
    if not file
    then
        error(mess,0)
    end
    file.write(v)
    file.close()
end
]]

installer = installer:format(textutils.serialise(files))

fm.OverWrite(installerName,installer,"R")