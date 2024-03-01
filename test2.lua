local T = { Name = "Test" };

loadfile('FakeApi.lua')(T.Name, T);

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

local test = [[
@@@@@@@@@@@@@@@@@
## Class: 1
## Spec: 1
## Code
#range(Range:12)
#meele(Meele:32)

exit [dead]
exit [!combat]
spell(Moonfire:8921) [target.aura.duration(Sunfire:321) < 2]
spell(Moonfire:8921) [!move]
spell(Sunfire:51723) [move]
@@@@@@@@@@@@@@@@@
## Class: 2
## Spec: 2
## Code
#range(Range:12)
#meele(Meele:32)

exit [dead]
exit [!combat]
spell(Moonfire:8921) [target.aura.duration(Sunfire:321) < 2]
spell(Moonfire:8921) [!move]
spell(Sunfire:51723) [move]
@@@@@@@@@@@@@@@@@
## Class: 3
## Spec: 3
## Code
#range(Range:12)
#meele(Meele:32)

exit [dead]
exit [!combat]
spell(Moonfire:8921) [target.aura.duration(Sunfire:321) < 2]
spell(Moonfire:8921) [!move]
spell(Sunfire:51723) [move]
]];

local begin = "## Code";

local blocks = {strsplit('@@@@@@@@@@@@@@@@@', test)};
for _, block in ipairs(blocks) do
    local class = string.match(block, "## Class: (%d+)");
    local spec = string.match(block, "## Spec: (%d+)")

    local index = string.find(block, begin);
    local code = string.sub(block, index + string.len(begin));

    print(class, spec, code)
end

--local actionPart = string.match('#meele(Rend:123)', '^/?(.+)$');
--print(actionPart)

--print(string.gsub("123", "(|*)(|c%x%x%x%x%x%x%x%x)()"))

-- print(string.match("|c11111111123|r |c22222222789|r", "((|c%x%x%x%x%x%x%x%x)([^|]+)(|r))"))