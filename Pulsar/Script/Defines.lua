local _, T = ...;

T.Defines = { apis = {} };

function T.Defines:New(name, id)
    local obj = {
        Id   = id;
        Name = name;
        Spell = T.SpellInfo:New(id, name);
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.Defines.RegisterDefine(name, method)
    T.Defines.apis[name] = method;
end

T.Defines.RegisterDefine('range', function(state, arg)
    --print(state, arg)
    return false;
end);

T.Defines.RegisterDefine('meele', function(state, arg)
    --print(state, arg)
    return false;
end);

