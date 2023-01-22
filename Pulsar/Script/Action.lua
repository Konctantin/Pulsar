local _, T = ...;

T.Action = { apis = {} };

function T:RegisterAction(...)
    local last = select('#', ...);
    local method = select(last, ...);

    if last < 2 or type(method) ~= 'function' then
        error('Usage: :RegisterAction(name, [name2, ...], method)');
    end

    for i = 1, last - 1 do
        T.Action.apis[select(i, ...)] = method;
    end
end

function T:CallAction(action, run)
    local cmd, value = self:ParseAction(action)

    local fn = self.apis[cmd]
    return fn and ((value ~= nil and fn(value, run)) or (value == nil and fn(run)))
end

function T:Run(action)
    return self:CallAction(action, true)
end

function T:Test(action)
    return self:CallAction(action, false)
end

function T:ParseAction(action)
    T.assert(type(action) == 'string', 'Invalid Action: `%s`', action)

    if action:find('^%-%-') then
        return '--', action
    end

    local cmd, value = T.ParseQuote(action)

    T.assert(cmd, 'Invalid Action: `%s`', action)
    T.assert(self.apis[cmd], 'Invalid Action: `%s` (Not found command)', action)

    return cmd, value ~= '' and value or nil
end