
local handle = {}
local function listerror(tbl)
    local list = "{"
    if #tbl > 1
    then
        for _,v in pairs(tbl) do
            list = list..v..",\t"
        end
        list = string.sub(list,1,#list-2)
        list = list.."}"
    else
        list = tbl[1]
    end
    return list
end
local function getType(var,isNamed)
    if type(var) == "table" and isNamed
    then
        return (getmetatable(var) or {}).type or "table"
    elseif type(var) == "table"
    then
        return "table"
    end
    return type(var)
end
local function get_caller(n)
    local name
    if debug and debug.getinfo then -- if we can get the name of the called function then lets include index else put the file in it's place
        local ok,info = pcall(debug.getinfo,4,"nS")
        if not ok
        then
            return
        end
        name = info.name and info.name ~= "" and info.what ~= "C" and info.name
    end
    return name
end
local function get_internal_caller(n)
    local name
    if debug and debug.getinfo then -- if we can get the name of the called function then lets include index else put the file in it's place
        local ok,info = pcall(debug.getinfo,n or 3,"nS")
        if not ok
        then
            return error(info,n or 3)
        end
        name = info.name and info.name ~= "" and info.what ~= "C" and info.name
    end
    return name
end
local function checkArguments()
    local name = get_internal_caller()
    error(("check arguments %s:"):format(name and name or ""),3)
end
handle.internal_apis = {
    Warning = "these apis have no argument checking because of stock overflow reasons",
    listerror = listerror,
    getType = getType,
    get_caller = get_caller,
    get_internal_caller = get_internal_caller,
    checkArguments = checkArguments
}
local protected_table = "protected table expect must be done manually"
---@param _bClasses boolean
---@param index number
---@param var any
---@param ... string
---@return any
function handle.expect(_bClasses,index,var,...)
    if #{...} == 0 or type(_bClasses) ~= "boolean"
    then
        checkArguments()
    end
    if type(var) == "table" and _bClasses
    then
        local bool,info = pcall(getType,var,true)
        if bool == false
        then
            error(protected_table,2)
        end
        for _,v in pairs({...}) do
            if v == (info or "table")
            then
                return var
            end
        end
    else
        for _,v in pairs({...}) do
            if type(var) == v
            then
                return var
            end
        end
    end
    local name  = get_caller()
    error(("argument #%s%s expected %s: got %s"):format(index,name and (" from %s"):format(name) or "",listerror({...}),getType(var,_bClasses)),3)
end 
---@param index number
---@param var any
---@param ... string
---@return any
---@diagnostic disable-next-line: lowercase-global
function handle.blacklist(_bClasses,index,var,...)
    handle.expect(false,1,_bClasses,"boolean")
    handle.expect(false,2,index,"number")
    if #{...}  == 0
    then
        checkArguments()
    end
    local info
    if type(var) == "table"
    then
        local bool
        bool,info = pcall(getType,var,true)
        if bool == false
        then
            info = nil
        else
            info = (info or {}).type
        end
    end
    local faild = false
    for _,v in pairs({...}) do
        if info
        then
            for _,b in pairs({...}) do
                if b == info
                then
                    faild = true
                end
            end
        elseif type(var) == v
        then
            faild = true
        end
    end
    if faild
    then
        local name  = get_caller()
        error(("argument #%s%s banned %s: got %s"):format(index,name and (" from %s"):format(name) or "",listerror({...}),getType(var,_bClasses)),3)
    end
    return var
end

---@param index number
---@param var any
---@return any
---@diagnostic disable-next-line: lowercase-global
function handle.expectValue(index,var)
    handle.expect(false,1,index,"number")
    if type(var) == "nil"
    then
        local name = get_caller()
        error(("argument #%s%s:expected value got nil"):format(index,name and (" from %s"):format(name) or ""),3)
    end
    return var
end

---@param tbl table
---@param index number|string
---@param ... string
---@diagnostic disable-next-line: lowercase-global
function handle.field(loc,tbl,index,...)
    handle.expect(false,1,loc,"number")
    handle.expect(false,2,tbl,"table")
    handle.expect(false,3,index,"string","number")
    local bool,message
    if #{...} == 0
    then
        bool = pcall(handle.expectValue,0,tbl[index])
        if not bool
        then
            error("expectValue got nil",3)
        end
        return tbl[index]
    end
    for i,v in pairs({...}) do
        handle.expect(false,i+4,v,"string")
    end
    bool,message = pcall(handle.expect,true,0,tbl[index],...)
    if not bool
    then
        if message == protected_table
        then
            error(protected_table,2)
        end
        local name = get_caller()
        error(("argument #%s %s: %s is expected to be %s: got %s"):format(loc,index,name and (" from %s"):format(name) or "",listerror({...}),type(tbl[index])),3)
    end
    return tbl[index]
end

---@param index number|string
---@param num number
---@param min number|nil
---@param max number|nil
---@return number
---@diagnostic disable-next-line: lowercase-global
function handle.range(index,num,min,max)
    handle.expect(false,1,index,"number","string")
    handle.expect(false,2,num,"number")
    min = handle.expect(false,3,min,"number","nil") or -math.huge
    max = handle.expect(false,4,max,"number","nil") or math.huge
    if max < min
    then
        error(("min is greator then max got %s/%s"):format(min,max),2)
    elseif num > max or num < min
    then
        local name = get_caller()
        error(("expected argument #%s%s: to be between %s and %s got %s"):format(index,name and (" from %s"):format(name) or "",min,max,num),3)
    end
    return num
end
return setmetatable(handle,{__call = expect})