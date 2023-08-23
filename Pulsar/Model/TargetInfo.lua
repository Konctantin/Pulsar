local _, T = ...;

T.TargetInfo = {
    Unit     = "target";
    Name     = "",
    Class    = "",
    Family   = "",
    Level    = 0,
    HP       = 0,
    HPP      = 0,
    IsDead   = false,
    Auras    = {},
};

function T.TargetInfo:New(unit)
    local obj = {
        Unit     = unit,
        Name     = "";
        Class    = "";
        Family   = "";
        Level    = 0;
        HP       = 0;
        HPP      = 0;
        IsDead   = false;
        Auras    = {};
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.TargetInfo:Update()
    self.Name    = UnitName(self.Unit);
    self.Class   = select(2, UnitClass(self.Unit));
    self.Family  = UnitCreatureFamily(self.Unit);
    self.Level   = UnitLevel(self.Unit);
    self.HP      = UnitHealth(self.Unit);
    self.HPP     = (100 * (UnitHealth(self.Unit) or 1)) / (UnitHealthMax(self.Unit) or 1);
    self.IsDead  = UnitIsDeadOrGhost(self.Unit);

    self:UpdateAura();
end

function T.TargetInfo:UpdateAura()
    table.wipe(self.Auras);
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expires, source, canStealOrPurge, _, spellId = UnitAura(self.Unit, i);
        if not name then
            return;
        end

        local id = tostring(source).."_"..tostring(spellId);
        self.Auras[id] = {
            Name            = name,
            SpellId         = spellId,
            Icon            = icon,
            Count           = count,
            DebuffType      = debuffType,
            Duration        = duration,
            Expires         = expires,
            Source          = source,
            CanStealOrPurge = canStealOrPurge,
            Remains         = min(max((expires or 0) - (GetTime()), 0), 0xffff);
        };
    end
end