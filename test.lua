local T = { Name = "Pulsar tester" };


loadfile('FakeApi.lua')(T.Name, T);
loadfile('FakeWowDB.lua')(T.Name, T);

loadfile('Pulsar/Utils.lua')(T.Name, T);
loadfile('Pulsar/Script/Defines.lua')(T.Name, T);
loadfile('Pulsar/Script/Action.lua')(T.Name, T);
loadfile('Pulsar/Script/Condition.lua')(T.Name, T);
loadfile('Pulsar/Script/Script.lua')(T.Name, T);

loadfile('Pulsar/Model/Common.lua')(T.Name, T);
loadfile('Pulsar/Model/SpellInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/ItemInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/MacroInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/PlayerInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/TargetInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/State.lua')(T.Name, T);

loadfile('Pulsar/KeyMap.lua')(T.Name, T);

local code = [[
#range(Range:12)
#meele(Meele:32)

exit [dead]
exit [!combat]
spell(Moonfire:8921) [target.aura.duration(Sunfire:321) < 2]
spell(Moonfire:8921) [!move]
spell(Sunfire:51723) [move]
]];

local script = T.Script:New(code)
script:Parse();
print(script);

--print(string.match('!p.aura(Aura:123)', '^(!?)([^!=<>~]+)%s*([!=<>~]*)%s*(.*)$'))
--[[
local script = T.Script:New(code);

script:Parse();

local state = T.State:New(script.Actions);
state:Update();

script:Run(state);

]]