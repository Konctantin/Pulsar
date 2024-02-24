local _, T = ...;

local PING = 0.1;

function T.GetUnitBuff(unit, spellId, filter)
    local spellName, spellRank = GetSpellInfo(spellId);
    if spellName then
        for i = 1, 80 do
            --    name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId =
            local name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId = UnitBuff(unit, i, filter);
            if not name then
                return false, 0, 0
            end
            if name == spellName then
                local rem = min(max((expires or 0) - (GetTime() - (PING or 0)), 0), 0xffff);
                return true, count, rem;
            end
        end
    end
    return false, 0, 0;
end

function T.GetUnitDebuff(unit, spellId, filter)
    local spellName, spellRank = GetSpellInfo(spellId);
    if spellName then
        for i = 1, 80 do
            local name, icon, count, debuffType, duration, expires, unitCaster, canStealOrPurge, _, spellId = UnitDebuff(unit, i, filter);
            if not name then
                return false, 0, 0;
            end
            if name == spellName then
                local rem = min(max((expires or 0) - (GetTime() - (PING or 0)), 0), 0xffff);
                return true, count, rem;
            end
        end
    end
    return false, 0, 0;
end

function T.CheckInterrupt(unit, sec)
    if not T.GetToogle("Pulsar_ControlPanel_KickButton") then
        return false;
    end

    local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(unit);
    if name and not (notInterruptible or isTradeSkill) then
        if (((endTime / 1000) - GetTime()) - PING) <= (sec or 1) then
            return true;
        end
    end

    local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(unit);
    if name and not (notInterruptible or isTradeSkill) then
        return true;
    end
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