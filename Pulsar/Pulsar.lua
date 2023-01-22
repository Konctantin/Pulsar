local _, T = ...;
_G[_] = T;

local function CheckAllSpells()
end

local function LoadRotation()
    local classDisplayName, classMnkd = UnitClass("player");
    local rotationName = "BOMBER_"..classMnkd.."_"..tostring(GetSpecialization());
    T.AbilityList = _G[rotationName];

    BOMBER_AOE = false;
    BOMBER_COOLDOWN = true;
    BOMBER_PAUSE = false;
    T.RangeSpellBookId = nil;
    T.RangeSpellBookType = nil;

    if type(T.AbilityList) == "table" and #T.AbilityList > 0 and UnitLevel("player") >= 10 then
        --for _, ability in ipairs(BomberFrame.AbilityList) do
        --    setmetatable(ability, BOMBER_ABILITY);
        --end

        --if type(BomberFrame.AbilityList.OnLoad) == "function" then
        --    BomberFrame.AbilityList.OnLoad();
        --end

        local classColorStr = RAID_CLASS_COLORS[classMnkd].colorStr;
        local classColoredText = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, classDisplayName);

        local spec = select(2, GetSpecializationInfo(GetSpecialization()));
        --BomberFrameInfo.print("|cff15bd05Rotation:|r "..classColoredText.." |cff6f0a9a"..spec.."|r|cff15bd05 is enabled.|r", true);
        CheckAllSpells();
    end
end

local function SetTargetCastintInfo(spellId, guid, castTime)
    if type(T.AbilityList) == "table" then
        local dstGuid = guid and guid or T.LastTarget;
        for _, ability in ipairs(T.AbilityList) do
            if type(ability) == "table" and ability.Target then
                if spellId == ability.SpellId and (not guid or (UnitGUID(ability.Target) == dstGuid)) then
                    ability.Guid = guid;
                    ability.LastCastingTime = castTime;
                end
            end
        end
    end
end

local function AddonFrame_AbilityLoop()
    if type(T.AbilityList) == "table" then
        if not T.AbilityList.OnTackt or T.AbilityList.OnTackt() then
            for _, ability in ipairs(T.AbilityList) do
                if type(ability) == "table" and not ability.Failed then
                    if not ability.IsDisable then
                        --if ability.SpellId > 0 then
                        --    CheckKnownAbility(ability)
                        --end
                        --local trace = false--ability.SpellId == 162794;
                        --if CheckAndCastAbility(ability, trace) then
                        --    return;
                        --end
                    end
                end
            end
        end
    end
end

local function mainFrame_OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:Show();
        LoadRotation();
    elseif event == "SPELLS_CHANGED" then
        CheckAllSpells();
    elseif event == "LEARNED_SPELL_IN_TAB" then
        CheckAllSpells();
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...;
        if UnitIsUnit(unit, "player") then
            LoadRotation();
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

local function mainFrame_OnUpdate(self, elapsed)
    self.timer = (self.timer or 0) + elapsed;
    if self.timer > 0.15 then
        T.SetColor(nil);
        T.ping = select(4, GetNetStats()) / 1000;
        -- PlayerInfo:Init();
        -- TargetInfo:Init();

        -- local bookId, bookType = GetSpellBookId(BomberFrame.RangeSpellId);
        -- BomberFrame.RangeSpellBookId = bookId;
        -- BomberFrame.RangeSpellBookType = bookType;

        if not GetCurrentKeyBoardFocus() and not T.IsPause and not IsModKeyDown(mkLeftAlt) then
            if C_PetBattles.IsInBattle() then
                --if tdBattlePetScriptAutoButton and tdBattlePetScriptAutoButton:IsEnabled() then
                --    local hotKey = string.upper(tostring(tdBattlePetScriptAutoButton.HotKey:GetText()));
                --    local color = BOMBER_KEYMAP[hotKey]
                --    BomberFrame_SetColor(color);
                --end
            else
                AddonFrame_AbilityLoop();

                --if UltraSquirt
                --and UltraSquirt.db
                --and UltraSquirt.db.global
                --and UltraSquirt.db.global.KEYBIND
                --and UltraSquirt.USQFrame
                --and UltraSquirt.USQFrame:IsShown()
                --and UnitLevel("player") < 70
                --then
                --    local color = BOMBER_KEYMAP[UltraSquirt.db.global.KEYBIND]
                --    BomberFrame_SetColor(color);
                --end
            end
        end
        self.timer = 0;
    end
end

local mainFrame = CreateFrame("Frame");

mainFrame:SetFrameStrata("BACKGROUND");
mainFrame:SetWidth(5);
mainFrame:SetHeight(5);
mainFrame:SetPoint("BOTTOMLEFT", "UIParent");
mainFrame.texture = mainFrame:CreateTexture(nil, "BACKGROUND");
mainFrame.texture:SetAllPoints(true);
mainFrame.texture:SetColorTexture(1.0, 0.5, 0.0, 1);

mainFrame:SetScript("OnUpdate", mainFrame_OnUpdate);
mainFrame:SetScript("OnEvent",  mainFrame_OnEvent);
mainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
mainFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("MODIFIER_STATE_CHANGED");
mainFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
mainFrame:Show();

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
infoFrame.print = function(msg, toChat)
    infoFrame.Msg:SetText(msg);
    if toChat then print(msg) end
    infoFrame.Duration = GetTime() + 5;
end;
infoFrame:SetPoint("CENTER", 0, 200);
infoFrame:Show();

function T.SetColor(color)
    local cc = color or {};
    mainFrame.texture:SetColorTexture(cc.R or 0, cc.G or 0, cc.B or 0, 1);
end

T.MainFrame = mainFrame;
T.InfoFrame = infoFrame;