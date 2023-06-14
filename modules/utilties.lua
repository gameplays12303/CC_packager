
local expect =  (require and require "cc.expect") or dofile("OS/modules/main/cc/expect.lua",{["debug"] = debug})
local fs,string,table = fs,string,table
local setmetatable = setmetatable
local getmetatable = getmetatable
local utilties = {}
utilties.string = {}
utilties.table = {}
utilties.file = {}
-- strings addons 
function utilties.string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end
-- fs addons
function utilties.file.created(sPath)
      expect(1,sPath,"string")
      return fs.attributes(sPath).created
end
function utilties.file.modified(sPath)
      expect(1,sPath,"string")
      return fs.attributes(sPath).modified
end

function utilties.file.getExtension(file)
      expect(1,file,"string")
	local Table = utilties.string.split(file,"%.")
      return Table[2]
end
function utilties.file.withoutExtension(file)
      expect(1,file,"string")
      local Table = utilties.string.split(file,"%.")
      return Table[1]
end
function utilties.file.listsubs(sPath,showFiles,JustFiles,showRootDir,showRom)
      expect(1,sPath,"string")
      expect(2,showFiles,"boolean","nil")
      expect(4,JustFiles,"boolean","nil")
      expect(5,showRootDir,"boolean","nil")
      expect(6,showRom,"boolean","nil")
      if not fs.exists(sPath) then
            error("Could not find"..fs.getName(sPath))
      end
      if not fs.isDir(sPath) then
            error(fs.getName(sPath).."is not a directory")
      end
      local Table = fs.find(sPath.."/*")
      if not showRom
      then
            local ID = utilties.table.find(Table,"rom")
            if ID
            then
                  table.remove(Table,ID)
            end
      end
      local list = {}
      if showRootDir and not JustFiles
      then
            table.insert(list,sPath)
      end
      for _,v in pairs(Table) do
            if fs.isDir(v) then
                  if not JustFiles
                  then
                        table.insert(list,v)
                  end
                  local list2 = fs.find(fs.combine(v,"*"))
                  for _,b in pairs(list2) do
                        if fs.isDir(b)
                        then
                            table.insert(Table,b)
                        else
                              if showFiles or JustFiles
                              then
                                    table.insert(list,b)
                              end
                        end
                  end
            else
                  if showFiles or JustFiles
                  then
                        table.insert(list,v)
                  end
            end
      end
      return list
end
function utilties.file.list(_sPath,showFiles,showPath,JustFiles,showDirs,justDirs)
      expect(1,_sPath,"string")
      expect(2,showFiles,"boolean","nil")
      expect(3,showPath,"boolean","nil")
      expect(5,JustFiles,"boolean","nil")
      expect(4,showDirs,"boolean","nil")


      if not fs.exists(_sPath)
      then
            error(("%s : not found"):format(_sPath),3)
      end
      if not fs.isDir(_sPath)
      then
            error(("%s: is file expected directory"):format(_sPath),3)
      end
      local list = fs.find(fs.combine(_sPath,"*"))
      local list2 = {}
      for _,v in pairs(list) do
            if fs.isDir(v) and (not JustFiles) and (showDirs or justDirs)
            then
                  table.insert(list2,v)
            elseif not fs.isDir(v) and showFiles and not justDirs
            then
                  table.insert(list2,v)
            end
      end
      if not showPath
      then
            for i,v in pairs(list2) do
                  list2[i] = fs.getName(v)
            end
      end
      return list2
end
function utilties.file.getDir(path)
      expect(1,path,"string")
      if fs.getDir(path) == ".."
      then
            return ""
      else
            return fs.getDir(path)
      end
end
-- table addons
function utilties.table.find(base,ID)
      expect(1,base,"table")
      for i,v in pairs(base) do
            if type(ID) == "string" and type(v) == "string"
            then
                  if string.find(v,ID)
                  then
                        return i
                  end 
            else
                  if ID == v
                  then
                        return i
                  end
            end
      end
return false
end
function utilties.table.copy(Table,proxy)
      expect(1,Table,"table")
      expect(2,proxy,"table","nil")
      proxy = proxy or {}
      local metatable = getmetatable(Table)
      for k,v in pairs(Table) do
            if type(v) == "table" and not utilties.table.find(v,v)
            then
                  proxy[k] = utilties.table.copy(v)
            else
                  proxy[k] = v
            end
      end
      return setmetatable(proxy,metatable)
end

return utilties