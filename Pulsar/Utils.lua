local _, T = ...;

local COMPAT = select(4, GetBuildInfo());
local MODERN = COMPAT >= 10e4;
local CF_CLASSIC = COMPAT < 10e4;

local oldGetClassInfo = GetClassInfo;

if CF_CLASSIC then
    _G.GetNumSpecializationsForClassID = function(classId)
        return 1;
    end

    _G.GetSpecializationInfoForClassID = function(classId, specIndex)
        return 1, "NONE", nil, nil, "NONE";
    end

    _G.GetSpecialization = function() return 1 end
    _G.GetSpecializationInfo = function() return 1, "" end
    _G.GetMicroIconForRole = function() return nil end
    _G.GetSpecializationInfoByID = function(classId, specIndex)
        local classFile = select(2, UnitClass(classId));
        local icon = T.IconTexture[classFile]
        return 1, "NONE", nil, icon, "NONE";
    end

    _G.GetClassInfo = function(classindex)
        local newIdx = classindex;
        if newIdx == 6 then
            newIdx = 11;
        end
        return oldGetClassInfo(newIdx);
    end
end

function T.assert(flag, formatter, ...)
    if not flag then
        error(string.format(formatter, ...), 0);
    end
    return flag;
end
