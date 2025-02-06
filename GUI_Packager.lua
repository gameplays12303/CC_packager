
local util = require("modules.utilties")
local GUI = require("modules.GUI")
local fm = require("modules.fm")
local fileselect = require("modules.fileselect")
local LUA_WRITE
local ChatWindow =  GUI:create(1,1,GUI:getSize())
ChatWindow:make_textBox(true)
ChatWindow:upDate(true)
local promptWindow = GUI:create(1,1,GUI:getSize())
promptWindow:upDate(true)

LUA_WRITE = util.file.withoutExtension(ChatWindow:Chat_Prompt("name of installer>")).."."..settings.get("package.installer.type","Lua_Installer")
local dir = fileselect(promptWindow,"","choose Dir to package",false,true)

if not dir
then
    return true,"no directory choosen"
end
local list_files = util.file.listsubs(dir,true)

local sFiles = {}
for _,v in pairs(list_files) do
    sFiles[v] = fm.readFile(v,"R")
end

if promptWindow:Prompt("do you need to adjust files")
then
    while true do
        local id = fileselect(promptWindow,dir,"choose what to move",true,true)
        if not id
        then
            break
        end
        local move_file_to = ChatWindow:Chat_Prompt("type_path>")
        if move_file_to ~= "" or move_file_to == "root"
        then
            if move_file_to == "root"
            then
                move_file_to = ""
            end
            local file_data = sFiles[id]
            sFiles[id] = nil
            sFiles[move_file_to.."/"..fs.getName(id)] = file_data
        end
    end
end
-- time to get directories 
local directories = util.file.listsubs(dir,false,true)


-- time to build the run handler
local installer = [[
local Argue = {...}
local programs = textutils.unserialise(%q)
local Dirs = %s
for _,v in pairs(Dirs) do
    fs.makeDir(v)
end
for path,program in pairs(programs) do
    file,mess = fs.open(path,"w")
    if not file
    then
        error(mess,0)
    end
    file.write(program)
    file.close()
end
]]
installer = installer:format(textutils.serialise(sFiles),textutils.serialise(directories))
fm.OverWrite(LUA_WRITE,installer,"R")
