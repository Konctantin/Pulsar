local api = { };

_G.UnitAura = function (...)
    print("call UnitAura", ...)
end

_G.tinsert = table.insert;
_G.string.trim = function(...) return ... end

_G.strsplit = function (sep, inputstr)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

return api;