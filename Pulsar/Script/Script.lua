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
        for _, condStr in ipairs(condList) do
            condStr = string.trim(condStr);
            if condStr ~= "" then
                local condition = T.Condition.Parse(condStr);
                action:AddCondition(condition);
            end
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
            if line:find('^%-%-') then
                --actionPart = line
            elseif line:find('^#') then
                local presetup = line;
            elseif line:find('[', nil, true) then
                local actionPart, conditionPart = string.match(line, '^/?(.+)%s*%[(.+)%]$');
                self:ParseCommand(lineNumber, line, actionPart, conditionPart);
            else
                local actionPart = string.match(line, '^/?(.+)$');
                self:ParseCommand(lineNumber, line, actionPart, nil);
            end
        end
        lineNumber = lineNumber + 1;
    end

    --print(#self.Actions);
end

function Script:Run(state)
    for _, action in ipairs(self.Actions) do
        local result, color, icon = action:Call(state);
        if result then
            T.SetColor(color);
            if icon then
                T.SetCurrentIcon(icon);
            end
            break;
        end
    end
end

function Script:Test()
end

T.Script = Script;
