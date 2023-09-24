local _, T = ...;

T.Action = { apis = {} };

function T.Action.RegisterAction(name, method)
    --print(format("add action |%s|", name))
    T.Action.apis[name] = method;
end

-- NEW

function T.Action:New(name, params)
    local command = T.Action.apis[name];
    --print(format("|%s|", name), params, "=", command)
    T.assert(command~=nil, "Unregistered action "..name);

    local obj = {
        Name    = name;
        Params  = params;
        Command = command;
        Conditions = {};
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.Action:AddCondition(condition)
    table.insert(self.Conditions, condition);
end

function T.Action:Call(state)
    local result = self.Command(state, self.Params);

    for i, condition in ipairs(self.Conditions) do
        local check = condition:Call(state);
        if not check then
            return false;
        end
    end

    return result;
end

-----------------------------------------------
--               REGISTRATION                --
-----------------------------------------------

-- Just test function
T.Action.RegisterAction('test', function(state, arg)
    print(state, arg)
    return false;
end);
    
-- Cast spell function
-- spell(Spell:123) [player.aura.exists(Aura:456988)]
-- spell(Spell:123) [target.aura.duration(Aura:4569) < 3]
-- spell(Spell:123) [target.aura.count(Aura:4569) < 3]
-- spell(Spell:123) [form=cat & target.aura(Aura:4569).duration < 3]
T.Action.RegisterAction('spell', function(state, arg)
    print("spell", state, arg);
    return true
end);

-- Use item function
-- item(Item:12334) [player.hpp < 30]
T.Action.RegisterAction('item', function(state, arg)
    print("item", state, arg);
    return true
end);

-- Use item function
-- macro(My Macro:12) [player.hpp < 30]
T.Action.RegisterAction('macro', function(state, arg)
    print("macro", state, arg);
    return true
end);

-- break abilities priority
-- exit [!combat]
-- exit [stealth]
T.Action.RegisterAction("return", function(state, arg)
    --print("return", state, arg);
    return true;
end);

T.Action.RegisterAction("quit", function(state, arg)
    --print("quit", state, arg);
    return true;
end);

T.Action.RegisterAction("exit", function(state, arg)
    --print("exit", state, arg);
    return true;
end);

-- just comment
T.Action.RegisterAction('--', function(state, arg)
    return false;
end);
