LuaTool = {}
function LuaTool.DupTable(t, o)
    if o == nil then
        o = {}
    end
    for k, v in pairs(t) do
        if type(v) == "table" then
            o[k] = LuaTool.DupTable(v)
        elseif type(v) == "userdata" then
            assert(false, "不支持userdata")
        else
            o[k] = v
        end
    end
    return o
end
-- 按key值顺序遍历
function LuaTool.pairsByKeys(t, sortf)
    local a = {}
    for n in pairs(t) do
        a[#a + 1] = n
    end
    table.sort(a, sortf)
    local i = 0
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end
-- 检查该方法是否存在
function LuaTool.IsFunctionOrVariableExist(tbl, name)
    if tbl ~= nil then
        if type(tbl) == "table" then
            return rawget(tbl, name) ~= nil
        elseif type(tbl) == "userdata" then
            local function foo()
                local x = tbl[name]
            end

            if pcall(foo) then
                return true
            else
                return false
            end
        end
    end
    return false
end

-- 输出Lua的DebugInfo
function LuaTool.PrintDebugInfoEx()
    local info = debug.getinfo(3, "S")
    print("文件名：" .. info.short_src)
    print("文件路径：" .. info.source)
    print("函数开始行：" .. info.linedefined .. ", 结束行：" .. info.lastlinedefined)
end

-- 重写元表的__index, __newindex 方法
local mtEx = {
    __index = function(tbl, key)
        if rawget(tbl, key) == nil then
            LuaTool.PrintDebugInfoEx()
            if tbl ~= nil then
                local fun = function()
                    print("没有找到名为 " .. key .. " 的方法，返回了一个空方法")
                end
                return fun
            end
        end

        return rawget(tbl, key)
    end,
    __newindex = function(tbl, key, value)
        if tbl ~= nil then
            return rawset(tbl, key, value)
        end
    end
}
local int64Ext = {}
function int64Ext.longtonum2(longNum)
    local l, h = int64.tonum2(longNum)
    if h > 2147483647 then
        l, h = int64.tonum2(-longNum)
        l = l == 0 and 0 or l * -1
        h = h == 0 and 0 or h * -1 
    end
    return l, h
end
int64Ext.__index = int64Ext
setmetatable(int64, int64Ext)
