local _, T = ...;

local PING = 0.1;

function T.GetUnitBuff(unit, spellId, filter)
    local spell_table = { };
    if type(spellId) == "table" then
        spell_table = spellId;
    elseif type(spellId) == "number" then
        spell_table = { spellId };
    end

    for _,spell_id in ipairs(spell_table) do
        local spellName, spellRank = GetSpellInfo(spell_id);
        if spellName then
           for i = 1, 80 do
               --    name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId =
               local name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId = UnitBuff(unit, i, filter);
               if not name then
                   return nil, 0, 0
               end
               if name == spellName then
                   local rem = min(max((expires or 0) - (GetTime() - (PING or 0)), 0), 0xffff);
                   return name, count, rem;
               end
           end
        end
    end
    return nil, 0, 0;
end

function T.GetInitDebuff(unit, spellId, filter)
    local spell_table = { };
    if type(spellId) == "table" then
        spell_table = spellId;
    elseif type(spellId) == "number" then
        spell_table = { spellId };
    end

    for _,spell_id in ipairs(spell_table) do
        local spellName, spellRank = GetSpellInfo(spell_id);
        if spellName then
           for i = 1, 40 do
               local name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId, canApplyAura, isBossAura = UnitDebuff(unit, i, filter);
               if not name then
                   return nil, 0, 0, nil, 0, 0;
               end
               if name == spellName then
                   local rem = min(max((expires or 0) - (GetTime() - (PING or 0)), 0), 0xffff);
                   return name, count, rem;
               end
           end
        end
    end
    return nil, 0, 0;
end

local ACTION_BAR_TYPES = { 'Action', 'MultiBarBottomLeft', 'MultiBarBottomRight', 'MultiBarRight', 'MultiBarLeft' };

function T.GetHotKeyColor(type, id)
    for _, barName in pairs(ACTION_BAR_TYPES) do
        for i = 1, 12 do
            local button = _G[barName .. 'Button' .. i];
            if button and button.HotKey then
                local acttype, actid = GetActionInfo(button.action);
                if acttype == type and actid == id then
                    local hotKey = string.upper(tostring(button.HotKey:GetText()));
                    local color = T.KeyMap[hotKey];
                    if color then
                        return color;
                    end
                end
            end
        end
    end
end