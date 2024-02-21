local _, T = ...;

T.Defines = { apis = {} };

function T.Defines.RegisterDefine(name, method)
    --print(format("add action |%s|", name))
    T.Defines.apis[name] = method;
end

-- Just test function
T.Defines.RegisterDefine('#rangespell', function(state, arg)
    --print(state, arg)
    return false;
end);

T.Defines.RegisterDefine('#meelespell', function(state, arg)
    --print(state, arg)
    return false;
end);

