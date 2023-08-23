local _, T = ...;

local Script = {
    code = nil,
    Actions = {}
};

function Script:New(code)
    local obj = {
        code = code;
        Actions = {};
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function ParseID(value)
    if type(value) == 'string' then
        local t = string.match(value, ':(%d+)');
        return tonumber(t);
    end;
end

function ParseAction(str)
    if not str then
        return nil, nil;
    end
    -- exit
    -- cast(Moonfire:123)
    -- aura(Moonfire:369).duration
    --local command, params, field = string.match(str, '^([%a%.]+)%s*%((.+)%)[%.]?(%a*)$');
    local command, params = string.match(str, '^([%a%.]+)%s*%((.+)%)$');
    --print(format("[%s]", str));
    --print(format("ParseAction: [%s] [%s]", tostring(command), tostring(params)));
    if command then
        local argId = ParseID(params);
        return command, argId;
    end
    return str, nil;
end

function Script:ParseCommand(lineNumber, line, actionPart, conditionPart)
    if not actionPart then
        return nil, format('Invalid Line: [%d] `%s`', lineNumber, line)
    end

    actionPart = string.gsub(actionPart, '\n', '');
    local cmd, arg = ParseAction(string.trim(actionPart));

    local action = T.Action:New(string.trim(cmd), arg);

    if conditionPart then
        local condList = {strsplit('&', conditionPart)};
        for i, c in ipairs(condList) do
            local condition = T.Condition:New();

            local non, args, operand, value = string.match(c, '^(!?)([^!=<>~]+)%s*([!=<>~]*)%s*(.*)$');

            local conditionalMethod, conditionalParam, conditionalFiled = ParseAction(args)

            condition.non    = non;
            condition.opened = operand;
            condition.value  = value;
            condition.args   = args;
            condition.field =

            -- todo: parse args
            action:AddCondition(condition)
        end;
    end;

    table.insert(self.Actions, action);
end

function Script:Parse()
    if type(self.code) ~= 'string' then
        return nil, 'No code'
    end

    local lineNumber = 1;
    for line in string.gmatch(self.code, '[^\r\n]+') do
        line = string.trim(line);
        if line ~= '' then
            local actionPart, conditionPart = nil, nil;

            if line:find('^%-%-') then
                actionPart = line
            elseif line:find('[', nil, true) then
                actionPart, conditionPart = string.match(line, '^/?(.+)%s*%[(.+)%]$');
            else
                actionPart = string.match(line, '^/?(.+)$')
            end

            self:ParseCommand(lineNumber, line, actionPart, conditionPart);
        end
        lineNumber = lineNumber + 1;
    end

    --print(#self.Actions);
end

function Script:Run(state)
    for i, action in ipairs(self.Actions) do
        action:Call(state);
    end
end

function Script:Test()
end

T.Script = Script;
