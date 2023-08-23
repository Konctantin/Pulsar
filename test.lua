local T = { Name = "Pulsar tester" };

loadfile('FakeApi.lua')(T.Name, T);
loadfile('FakeWowDB.lua')(T.Name, T);

loadfile('Pulsar/Script/Utils.lua')(T.Name, T);
loadfile('Pulsar/Script/Action.lua')(T.Name, T);
loadfile('Pulsar/Script/Condition.lua')(T.Name, T);
loadfile('Pulsar/Script/Script.lua')(T.Name, T);

loadfile('Pulsar/Model/SpellInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/ItemInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/MacroInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/PlayerInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/TargetInfo.lua')(T.Name, T);
loadfile('Pulsar/Model/State.lua')(T.Name, T);

loadfile('Pulsar/KeyMap.lua')(T.Name, T);

function Create()
    local obj = { Name = "46" };

    obj.Test = function(self)
        print(self.Name)
    end

    return obj;
end

local s = Create();
s:Test();

local code = [[
exit [dead]
exit [!combat]
spell(Moonfire:8921) [target.aura.duration(Sunfire:321) < 2]
macro(My Macro:1) [move]
item(My Item:321) [move]
spell(Moonfire:8921) [move & !aoe]
spell(Sunfire:51723) [move]
]];

local script = T.Script:New(code);

script:Parse();

local state = T.State:New(script.Actions);
state:Update();

script:Test(state);

