local _, T = ...;
_G[_] = T;

-- Init storage
if not PULSAR_GLOBAL_STORAGE then
    PULSAR_GLOBAL_STORAGE = { };
end

for c = 1, GetNumClasses() do
    local _, classFile, classID = GetClassInfo(c);
    if classID then
        if not PULSAR_GLOBAL_STORAGE[classFile] then
            PULSAR_GLOBAL_STORAGE[classFile] = { };
        end

        local numSpecializations = GetNumSpecializationsForClassID(classID);
        --print(numSpecializations)
        for s = 1, numSpecializations do
            local specId, specName, _, _, role = GetSpecializationInfoForClassID(c, s);
            --print(specId, specName)
            if not PULSAR_GLOBAL_STORAGE[classFile][specId] then
                --print("ADD", classID, classFile, specId, specName, role)
                PULSAR_GLOBAL_STORAGE[classFile][specId] = {
                    Info = {
                        Id        = s,
                        SpecId    = specId,
                        ClassId   = c,
                        ClassFile = classFile,
                        SpecName  = specName,
                        Role      = role,
                    },
                    Code = "",
                };
            end
        end
    end
end

function T.LoadCurrentRotation()
    local classDisplayName, classFile = UnitClass("player");

    local classStorage = PULSAR_GLOBAL_STORAGE[classFile];
    if not classStorage then
        print("There is no any roatations for "..classDisplayName);
        return;
    end

    local specId, specName = GetSpecializationInfo(GetSpecialization());
    local rotationInfo = classStorage[specId];
    if not rotationInfo then
        print("There is no any roatations for "..classDisplayName.." - "..specName);
        return;
    end

    -- /dump PULSAR_GLOBAL_STORAGE["HUNTER"][1]

    T.ScriptIntance = nil;
    if tostring(rotationInfo.Code) ~= "" then
        T.ScriptIntance = T.Script:New(rotationInfo.Code);
        T.ScriptIntance:Parse();
        T.ScriptIntance:Test();

        --print(format("Rotation %s - %s has been loaded!", classDisplayName, specName));

        local classColorStr = RAID_CLASS_COLORS[classFile].colorStr;
        local classColoredText = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classDisplayName);

        T.Notify("|cff15bd05Rotation:|r "..classColoredText.." |cff6f0a9a"..specName.."|r|cff15bd05 is enabled.|r", true);

        -- /dump Pulsar.State.Spells
        -- /dump Pulsar.ScriptIntance.Actions
        T.StateInfo = T.State:New(T.ScriptIntance.Actions, T.ScriptIntance.Defines);
        T.StateInfo:Update();

        T.ScriptIntance:Run(T.StateInfo);
    end
end

local function SetTargetCastintInfo(spellId, guid, castTime)
    if type(T.StateInfo) == "table" and type(T.StateInfo.Spells) == "table" then
        local dstGuid = guid and guid or T.LastTarget;
        for _, spell in ipairs(T.StateInfo.Spells) do
            if type(spell) == "table" and spell.Target then
                if spellId == spell.Id and (not guid or (UnitGUID(spell.Target) == dstGuid)) then
                    spell.LastGuid = guid;
                    spell.LastTime = castTime;
                end
            end
        end
    end
end

local function pulsarFrame_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:Show();
        T.CreateControlPanel();
        T.ControlPanel:Show();
        T.LoadCurrentRotation();
    elseif event == "PLAYER_LEAVING_WORLD" then
        --if T.ControlPanel then
        --    T.ControlPanel:Hide();
        --end
    elseif event == "SPELLS_CHANGED" then
        --CheckAllSpells();
    elseif event == "LEARNED_SPELL_IN_TAB" then
        --CheckAllSpells();
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...;
        if UnitIsUnit(unit, "player") then
            T.LoadCurrentRotation();
        end
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _,subEvent,_,sourceGUID,_,_,_,destGUID,_,_,_,spellId = CombatLogGetCurrentEventInfo();
        if sourceGUID == UnitGUID("player") then
            if subEvent == "SPELL_CAST_SUCCESS" then
                SetTargetCastintInfo(spellId, destGUID, GetTime());
            elseif subEvent == "SPELL_CAST_FAILED" then
                SetTargetCastintInfo(spellId, nil, 0);
            elseif subEvent == "SPELL_CAST_START" then
                SetTargetCastintInfo(spellId, destGUID, GetTime()+0.002);
                T.SetColor(nil);
                T.SetCurrentIcon(nil);
            end
        end
        if T.COMBATLOG_MODS then
            local combatMod = T.COMBATLOG_MODS[subEvent];
            if combatMod then
                combatMod(...);
            end
        end
    end

    if T.EVENT_MODS then
        local eventMod = T.EVENT_MODS[event];
        if eventMod then
            eventMod(...);
        end
    end
end

local function Tick()
    if GetCurrentKeyBoardFocus() then
        return;
    end
    if IsLeftAltKeyDown() then
        return;
    end
    if not T.GetToogle("Pulsar_ControlPanel_EnabledButton") then
        return;
    end

    T.StateInfo:Update();
    T.ScriptIntance:Run(T.StateInfo);
end

local function pulsarFrame_OnUpdate(self, elapsed)
    self.timer = (self.timer or 0) + elapsed;
    if self.timer > 0.15 then
        if type(T.ScriptIntance) == "table" and type(T.StateInfo) == "table" then
            T.SetColor(nil);
            T.SetCurrentIcon(nil);
            Tick();
        end
        self.timer = 0;
    end
end

-- /dump Pulsar:SetColor()
-- /dump Pulsar.PulsarFrame.Texture:SetColorTexture(0.5, 0.5, 0.5, 1)
function T.SetColor(color)
    local r = color and color.R or 0;
    local g = color and color.G or 0;
    local b = color and color.B or 0;
    T.PulsarFrame.Texture:SetColorTexture(r, g, b, 1);
end

function T.GetToogle(key)
    return PULSAR_GLOBAL_STORAGE
        and PULSAR_GLOBAL_STORAGE.BUTTON_STATE
        and PULSAR_GLOBAL_STORAGE.BUTTON_STATE[key];
end

function T.Notify(msg, toChat)
    T.InfoFrame.Msg:SetText(msg);
    if toChat then
        print(msg);
    end
    T.InfoFrame.Duration = GetTime() + 5;
end

local function InitMainFrame()
    local pulsarFrame = CreateFrame("Frame");

    pulsarFrame:SetFrameStrata("BACKGROUND");
    pulsarFrame:SetWidth(5);
    pulsarFrame:SetHeight(5);
    pulsarFrame:SetPoint("BOTTOMLEFT", "UIParent");
    pulsarFrame.Texture = pulsarFrame:CreateTexture(nil, "BACKGROUND");
    pulsarFrame.Texture:SetAllPoints(true);
    pulsarFrame.Texture:SetColorTexture(1.0, 0.5, 0.0, 1);

    pulsarFrame:SetScript("OnUpdate", pulsarFrame_OnUpdate);
    pulsarFrame:SetScript("OnEvent",  pulsarFrame_OnEvent);
    pulsarFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    pulsarFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
    pulsarFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
    pulsarFrame:RegisterEvent("MODIFIER_STATE_CHANGED");
    pulsarFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
    pulsarFrame:RegisterEvent("PLAYER_LEAVING_WORLD");
    pulsarFrame:Show();

    local infoFrame = CreateFrame("Frame");
    infoFrame:SetScript("OnUpdate", function (self, elapsed)
        if (infoFrame.Duration or 0) < GetTime() then
            infoFrame.Msg:SetText("");
        end
    end);
    infoFrame:SetHeight(300);
    infoFrame:SetWidth(600);
    infoFrame.Msg = infoFrame:CreateFontString(nil, "BACKGROUND", "PVPInfoTextFont");
    infoFrame.Msg:SetAllPoints();
    infoFrame:SetPoint("CENTER", 0, 200);
    infoFrame:Show();

    T.PulsarFrame = pulsarFrame;
    T.InfoFrame = infoFrame;

    return infoFrame;
end

InitMainFrame();