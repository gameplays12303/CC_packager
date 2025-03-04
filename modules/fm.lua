-- Modified from original GeneralModules, licensed under MIT
-- These modifications were made by [Your Name or Organization] for the project
-- For full license information, see LICENSE file in the modules directory.


-- this is just a module to lower the ammount of code to be written
-- if you need specific handling or are going to be writing to the file
-- multipule times this is not the handle you want to use

local expect = require("modules.expect2")
local util = require("modules.utilties")
local blacklist = expect.blacklist
---@diagnostic disable-next-line: cast-local-type
expect = expect.expect
local open = fs.open
local exists = fs.exists
local fm = {}
---wrapped file writer
---@param sPath string
---@param data any
---@param mode string|nil
---@return boolean|string
---@return string|nil
function fm.OverWrite(sPath,data,mode)
    expect(false,1,sPath,"string")
    blacklist(false,2,data,"thread","userdata")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    local file,mess = open(sPath,"w")
    if file == nil then
        return false,mess
    end
    if mode == "R"
    then
        file.write(data)
    else
        file.write(util.string.Serialise(data))
    end
    file.close()
    return true
end
---wrapped file reader
---@param sPath string
---@param mode string|nil
---@return string|boolean
---@return string|nil
function fm.readFile(sPath,mode)
    expect(false,1,sPath,"string")
    expect(false,3,mode,"string","nil")
    mode = mode or "S"
    if mode ~= "S" and mode ~= "R"
    then
        error("Invalid mode",2)
    end
    if not exists(sPath) then
        error("Invalid path "..sPath.." dose not exist",0)
    end
    local file,mess = open(sPath,"r")
    if file == nil then
        return false,mess
    end
    local data
    if mode == "R"
    then
        data = file.readAll()
    else
        data = textutils.Unserialise(file.readAll())
    end
    file.close()
    return data
end

return fm
