local _, T = ...;

T.SpellInfo = {
    Id       = 0,
    Name     = "",
    Icon     = nil,
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
        Icon     = nil;
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

function T.SpellInfo:Update(spellId)

    if spellId then
        self.Id = spellId;
        self.Name = GetSpellInfo(spellId);
    end

    self.IsKnown = false;
    self.BookId = 0;

    if spellId == 0 then
        return;
    end

    self:UpdateSpellBookId();
    self:UpdateKnownSpell();

    self.IsUsable = false;
    self.Cooldown = 0;
    if self.IsKnown and self.BookId > 0 then
        local start, duration = GetSpellCooldown(self.BookId, self.BookType);
        self.Cooldown = duration + start - GetTime();

        self.IsUsable = self.IsKnown and IsUsableSpell(self.BookId, self.BookType);
    end
end

function T.SpellInfo:UpdateKnownSpell()
    self.IsKnown = false;

    if IsPlayerSpell(self.Id)
        or IsSpellKnown(self.Id) or IsSpellKnown(self.Id, true)
        or (IsTalentSpell and IsTalentSpell(self.Name)) then
        self.IsKnown = true;
    end


    if select(4, GetBuildInfo()) < 10e4 then
        self.IsKnown = self.BookId > 0;
    end

    -- check specialization spells
    if GetSpecialization and GetSpecializationSpells and not self.IsKnown then
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

-- /dump Pulsar.StateInfo.Spells[14264]
-- /run Pulsar.StateInfo.Spells[409552]:Update()
-- /dump Pulsar.StateInfo.Spells[409552]
-- /dump IsSpellInRange(63, "spell", "target")
-- /dump GetSpellLink(47, "spell")
-- /dump GetSpellBookItemInfo(47, "spell")
-- /dump GetSpellBookItemName(47, "spell")
function T.SpellInfo:UpdateSpellBookId()
    local name, _, icon = GetSpellInfo(self.Id);
    self.BookId = 0;
    self.Name = name;
    self.Icon = icon;

    for _, bookType in ipairs({"spell", "pet"}) do
        --local bookType = "spell"
        for spellBookID = 1, 200 do
            local type, baseSpellID = GetSpellBookItemInfo(spellBookID, bookType);
            --print(type, baseSpellID)
            if not baseSpellID then
                break
            end
            local currentSpellName, _, currentSpellID = GetSpellBookItemName(spellBookID, bookType);
			if not currentSpellID then
				local link = GetSpellLink(currentSpellName);
				currentSpellID = tonumber(link and link:gsub("|", "||"):match("spell:(%d+)"));
			end

            --print(currentSpellName, currentSpellID)
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

function T.SpellInfo:IsInRange()
    return IsSpellInRange(self.BookId, self.BookType, "target") == 1;
end

function T.SpellInfo:IsOnCooldown()
    local start, duration = GetSpellCooldown(self.BookId, self.BookType);
    if (duration + start - GetTime()) > 0 then
        return true;
    end
    return false;
end

function T.SpellInfo:IsReady()
    if UnitIsDeadOrGhost("player")
    or UnitIsAFK("player")
    or UnitHasVehicleUI("player")
    or not UnitExists("target") then
        return false;
    end

    if not self.IsKnown then
        return false;
    end

    if not IsUsableSpell(self.BookId, self.BookType) then
        return false;
    end

    if self:IsOnCooldown() then
        return false;
    end

    local endTime = select(5, UnitCastingInfo("player")) or 0;
    if (endTime - (GetTime() * 1000)) >= 0.2 then
        return false;
    end

    local endTime = select(5, UnitChannelInfo("player")) or 0;
    if (endTime - (GetTime() * 1000)) >= 0 then
        return false;
    end

    if IsHarmfulSpell(self.BookId, self.BookType) and UnitIsFriend("player", "target") then
        return false;
    end

    if IsHarmfulSpell(self.BookId, self.BookType) and not UnitIsFriend("player", "target") then
        if SpellHasRange(self.BookId, self.BookType) and IsSpellInRange(self.BookId, self.BookType, "target") == 0 then
            --print("SpellHasRange")
            return false;
        end
    end

    return true;
end

local ACTION_BAR_TYPES = { 'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft' };

function T.SpellInfo:GetHotKeyColor()
    local actionList = C_ActionBar.FindSpellActionButtons(self.Id);
    if actionList and #actionList > 0 then
        for _, actionID in ipairs(actionList) do
            for _, barName in pairs(ACTION_BAR_TYPES) do
                for i = 1, 12 do
                    local button = _G[barName .. 'Button' .. i];
                    if button and button.action == actionID and button.HotKey then
                        local hotKey = string.upper(tostring(button.HotKey:GetText()));
                        local color = T.KeyMap[hotKey];
                        if color then
                            --for k,v in pairs(color) do print(k,v) end
                            return color;
                        end
                    end
                end
            end
        end
    end
end
