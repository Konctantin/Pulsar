local T = { Name = "Pulsar tester" };

loadfile('FakeApi.lua')(T.Name, T);

loadfile('Pulsar/Script/Util.lua')(T.Name, T);
loadfile('Pulsar/Script/Stack.lua')(T.Name, T);

loadfile('Pulsar/Script/Action.lua')(T.Name, T);
loadfile('Pulsar/Script/Condition.lua')(T.Name, T);
loadfile('Pulsar/Script/Director.lua')(T.Name, T);

loadfile('Pulsar/Script/Actions.lua')(T.Name, T);
loadfile('Pulsar/Script/Conditions.lua')(T.Name, T);

local action, condition = string.match("cast(Lol:123) [!dead & duration>2]", '^/?(.+)%s+%[(.+)%]$')

local non, args, op, value = string.match("!duration", '^(!?)([^!=<>~]+)%s*([!=<>~]*)%s*(.*)$');
print(non, args, op, value)

local dir = T.Director:New();

dir:BuildScript("cast(Lol:123) [!dead]");

T.assert(1, 'sd')