local T = { Name = "Test" };

loadfile('FakeApi.lua')(T.Name, T);

function ParseID(value)
    if type(value) == 'string' then
        local t = string.match(value, ':(%d+)');
        return tonumber(t);
    end;
end
--print(string.gsub("123", "(|*)(|c%x%x%x%x%x%x%x%x)()"))

print(string.match("|c11111111123|r |c22222222789|r", "((|c%x%x%x%x%x%x%x%x)([^|]+)(|r))"))