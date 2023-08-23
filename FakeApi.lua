local api = { Name = "Fake Wow API" };

_G.UnitAura = function (...)
    return nil;
end

_G.GetTime = function() return os.time() end;

_G.tinsert = table.insert;
_G.string.trim = function(str) return string.gsub(str, "%s+", "") end
_G.table.wipe = function(t)
    for k in pairs (t) do
        t[k] = nil
    end
end;

_G.strsplit = function (sep, inputstr)
    sep = sep or "%s";
    local t = { };
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str);
    end
    return unpack(t);
end

_G.GetCurrentKeyBoardFocus = function() return false end;
_G.IsLeftAltKeyDown = function() return false end;
_G.UnitAffectingCombat = function(...) return true end;

_G.UnitName = function(unit) if unit == "player" then return "Anlin" else return "Target "..unit end end;
_G.UnitClass = function(...) return "DRUID", "DRUID" end;
_G.UnitCreatureFamily = function(...) return "ZOMBIE" end;
_G.UnitLevel = function(...) return 70 end;
_G.UnitHealth = function(...) return 7800 end;
_G.UnitHealthMax = function(...) return 10000 end;
_G.UnitIsDeadOrGhost = function(...) return false end;
_G.UnitIsAFK = function(...) return false end;
_G.GetUnitSpeed = function(...) return 0 end;
_G.IsFalling = function(...) return false end;

_G.GetSpellCooldown = function(...) return 5, 5 end;
_G.IsUsableSpell = function(...) return true end;
_G.IsPlayerSpell = function(...) return true end;
_G.IsSpellKnown = function(...) return true end;
_G.IsTalentSpell = function(...) return false end;
_G.GetSpecialization = function(...) return 1 end;
_G.GetSpecializationSpells = function(...) return 55, 10 end;
_G.GetSpellBookItemInfo = function(...) return 'Name', 2 end;
_G.GetSpellInfo = function(...) return "spell" end;
_G.GetSpellBookItemName = function(...) return "spell" end;
_G.GetSpellLink = function(...) return "" end;
--_G.IsFalling = function(...) return false end;
--_G.IsFalling = function(...) return false end;
--_G.IsFalling = function(...) return false end;

return api;