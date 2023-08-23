local _, T = ...;

T.SpellInfo = {
    Id       = 0,
    Name     = "",
    BookId   = 0,
    BookType = "spell",
    Cooldown = 0,
    Count    = 0,
    HotKey   = "",
    IsKnown  = false,
    IsUsable = false,
    LastCast = 0,
    LastGuid = nil,
};

function T.SpellInfo:New(id, name)
    local obj = {
        Id       = id;
        Name     = name;
        BookId   = 0;
        BookType = "spell";
        Cooldown = 0;
        Count    = 0;
        HotKey   = "";
        IsKnown  = false;
        IsUsable = false;
        LastCast = 0;
        LastGuid = nil;
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.SpellInfo:Update()
    self:UpdateKnownSpell();

    self.BookId = 0;
    if self.IsKnown then
        self:UpdateSpellBookId();
    end

    self.IsUsable = false;
    self.Cooldown = 0;
    if self.IsKnown and self.BookId > 0 then
        local start, duration = GetSpellCooldown(self.BookId, self.BookType);
        self.Cooldown = duration + start - GetTime();

        self.IsUsable = self.IsKnown and IsUsableSpell(self.BookId, self.BookType);
    end
end

function T.SpellInfo:UpdateKnownSpell()
    if IsPlayerSpell(self.Id)
        or IsSpellKnown(self.Id) or IsSpellKnown(self.Id, true)
        or IsTalentSpell(self.Name) then
        self.IsKnown = true;
    end

    -- check specialization spells
    if not self.IsKnown then
        local spec = GetSpecialization();
        if spec then
            local spellList = { GetSpecializationSpells(spec) };
            local lvl = UnitLevel("player");
            for i = 1, #spellList, 2 do
                if spellList[i] == self.Id and lvl > (spellList[i+1] or 0) then
                    self.IsKnown = true;
                    break;
                end
            end
        end
    end

    -- check spell on the spellbook
    if not self.IsKnown then
        local spellId = select(2, GetSpellBookItemInfo(self.Name));
        if spellId and self.Id ~= spellId then
            -- ability.SpellId = spellId;
            self.IsKnown = true;
        end
    end
end

function T.SpellInfo:UpdateSpellBookId()
    self.BookId = 0;
    self.Name = GetSpellInfo(self.Id);

    for _, bookType in ipairs({"spell", "pet"}) do
        --local bookType = "spell"
        for spellBookID = 1, 200 do
            local type, baseSpellID = GetSpellBookItemInfo(spellBookID, bookType);
            if not baseSpellID then
                break
            end

            local _, baseSpellID = GetSpellBookItemInfo(spellBookID, bookType);
            local currentSpellName = GetSpellBookItemName(spellBookID, bookType);

            local link = GetSpellLink(spellBookID, bookType);
            local currentSpellID = tonumber(link and link:gsub("|", "||"):match("spell:(%d+)"));

            if self.Id == currentSpellID
            or self.Id == baseSpellID
            or self.Name == currentSpellName
            then
                self.BookId = spellBookID;
                self.BookType = bookType;
                return;
            end
        end
    end
end
