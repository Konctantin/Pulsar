local _, T = ...;

local Stack = { stack = {} };

function Stack:New()
    local obj = {
        stack = {}
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function Stack:Push(item)
    if item ~= nil then
        table.insert(self.stack, 1, item)
    end
end

function Stack:Pop()
    return table.remove(self.stack, 1)
end

function Stack:Top()
    return self.stack[1]
end

T.Stack = Stack;