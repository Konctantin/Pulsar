local _, T = ...;

T.PlayerInfo = {
    Name     = "",
    Class    = "",
    Level    = 0,
    HP       = 0,
    HPP      = 0,
    IsReady  = false,
    IsDead   = false,
    IsMoving = false,
    Auras    = {},
};

function T.PlayerInfo:New()
    local obj = {
        Name     = "";
        Class    = "";
        Level    = 0;
        HP       = 0;
        HPP      = 0;
        IsReady  = false;
        IsDead   = false;
        IsMoving = false;
        Auras    = {};
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.PlayerInfo:Update()
    self.Name    = UnitName("player");
    self.Class   = select(2, UnitClass("player"));
    self.Level   = UnitLevel("player");
    self.HP      = UnitHealth("player");
    self.HPP     = (100 * (UnitHealth("player") or 1)) / (UnitHealthMax("player") or 1);
    self.IsReady = not (UnitIsDeadOrGhost("player") or UnitIsAFK("player"));
    self.IsDead  = UnitIsDeadOrGhost("player");

    self:UpdateAura();

    self.IsMoving = GetUnitSpeed("player") ~= 0 or IsFalling(); -- todo: check aura
end

function T.PlayerInfo:UpdateAura()
    table.wipe(self.Auras);
    for i = 1, 40 do
        local name, icon, count, debuffType, duration, expires, source, canStealOrPurge, _, spellId = UnitAura("player", i);
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