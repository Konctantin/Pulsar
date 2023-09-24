local _, T = ...;

local SIZE = 32;

local function CreateIconButton(name, parent, size, texture, tooltip)

    local function OnEnter(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
        GameTooltip_AddNormalLine(GameTooltip, tooltip or "");
        GameTooltip:Show();
    end

    local function OnLeave()
        GameTooltip_Hide();
    end

    if parent then
        name = parent:GetName().."_"..name;
    end

    local button = CreateFrame("Button", name, parent);
    button:SetSize(size, size);
    button:SetNormalTexture(texture or "Interface/Icons/Temp");
    button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square");
    button:GetHighlightTexture():SetBlendMode("ADD");
    button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress");
    button:GetPushedTexture():SetDrawLayer("OVERLAY");

    local icon = button:CreateTexture(nil, "ARTWORK");
    icon:SetAllPoints();
    icon:SetTexture(texture or "Interface/Icons/Temp");
    button.Icon = icon;

    --button.tooltipText = tooltip;

    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)

    return button;
end

local function CreateIconToogledButton(name, parent, size, texture, tooltip)
    local button = CreateIconButton(name, parent, size, texture, tooltip);

    local textureName = button:GetName().."AutoCastable";
    button.AutoCastableTexture = button:CreateTexture(textureName, "OVERLAY");
    button.AutoCastableTexture:SetTexture("Interface\\Buttons\\UI-AutoCastableOverlay");
    button.AutoCastableTexture:SetPoint("CENTER", button, "CENTER", 0, 0);
    button.AutoCastableTexture:SetWidth(size);
    button.AutoCastableTexture:SetHeight(size);
    button.AutoCastableTexture:Show();

    local shineName = button:GetName().."AutoCastShine";
    button.Shine = CreateFrame("Frame", shineName, button, "AutoCastShineTemplate");
    button.Shine:SetPoint("CENTER", button, "CENTER", 0, 0);
    button.Shine:SetWidth(size);
    button.Shine:SetHeight(size);
    button.Shine:Show();

    button.Toogled = false;

    button.Refresh = function(self)
        local p = self:GetParent();
        if p and p:IsVisible() then
            if self.Toogled then
                AutoCastShine_AutoCastStart(self.Shine);
                ActionButton_ShowOverlayGlow(self);
            else
                AutoCastShine_AutoCastStop(self.Shine);
                ActionButton_HideOverlayGlow(self);
            end;
        end;
    end;

    button.Toogle = function(self)
        self.Toogled = not self.Toogled;
        self:Refresh();
    end;

    button.SetToogle = function(self, state)
        self.Toogled = state;
        self:Refresh();
    end;

    button:SetScript("OnClick", function(self)
        self:Toogle();
        if not PULSAR_GLOBAL_STORAGE.BUTTON_STATE then
            PULSAR_GLOBAL_STORAGE.BUTTON_STATE = {};
        end
        local name = self:GetName();
        PULSAR_GLOBAL_STORAGE.BUTTON_STATE[name] = self.Toogled;
    end);

    button.LoadState = function(self)
        local name = self:GetName();
        self.Toogled = PULSAR_GLOBAL_STORAGE
            and PULSAR_GLOBAL_STORAGE.BUTTON_STATE
            and PULSAR_GLOBAL_STORAGE.BUTTON_STATE[name];
        self:Refresh();
    end;

    button:LoadState();

    return button;
end

function T.CreateControlPanel()
    local frame = CreateFrame("Frame", "Pulsar_ControlPanel", QuickJoinToastButton, "BackdropTemplate");
    frame:RegisterEvent("MODIFIER_STATE_CHANGED");
    frame:SetScript("OnEvent", function (self, event, modifier, state)
        if state == 0 then return end;
        if T.AoeButton and modifier == "LCTRL" then
            T.AoeButton:Toogle();
        elseif T.EnabledButton and modifier == "RALT" then
            T.EnabledButton:Toogle();
        end
    end);
    frame:SetWidth(1);
    frame:SetHeight(SIZE);

    --frame:SetBackdrop({
    --    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    --    --edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    --    tile = true,
    --    --tileSize = 32,
    --    --edgeSize = 32,
    --    --insets = {left = 8, right = 8, top = 10, bottom = 10}
    --});

    --frame:SetBackdropColor(0, 0, 0);
    frame:SetPoint("TOPLEFT", QuickJoinToastButton, "TOPRIGHT", 3, 0);
    frame:SetToplevel(true);
    frame:EnableMouse(true);
    frame:SetMovable(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", frame.StartMoving);
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
    --frame:SetUserPlaced(true);

    local icon = frame:CreateTexture("", "BACKGROUND") do
        icon = frame:CreateTexture("", "BACKGROUND");
        icon:SetWidth(SIZE+10);
        icon:SetHeight(SIZE+10);
        icon:SetPoint("BOTTOMLEFT");
        icon:SetTexture(461114);
        frame.icon = icon;
    end

    local leftPos = SIZE + 16;

    T.EnabledButton = CreateIconToogledButton("EnabledButton", frame, SIZE, 132376, "Enable/Disable Rotation");
    T.EnabledButton:SetPoint("LEFT", leftPos, 0);
    leftPos = leftPos + SIZE + 6;

    T.AoeButton = CreateIconToogledButton("AoeButton", frame, SIZE, 132369, "Enable/Disable AOE Mode");
    T.AoeButton:SetPoint("LEFT", leftPos, 0);
    leftPos = leftPos + SIZE + 4;

    T.KickButton = CreateIconToogledButton("KickButton", frame, SIZE, 132938, "Enable/Disable Auto Kick");
    T.KickButton:SetPoint("LEFT", leftPos, 0);
    leftPos = leftPos + SIZE + 4;

    T.CDButton = CreateIconToogledButton("CDButton", frame, SIZE, 458224, "Enable/Disable Cooldowns");
    T.CDButton:SetPoint("LEFT", leftPos, 0);
    leftPos = leftPos + SIZE;

    leftPos = leftPos + 6;

    frame.EditorButton = CreateIconButton("EditorButton", frame, SIZE, 4548873, "Open rotation editor");
    frame.EditorButton:SetPoint("LEFT", leftPos, 0);
    --frame.EditorButton:SetScript("OnClick", function() T.ShowRotationEditor(); end);
    frame.EditorButton:SetScript("OnClick", T.ShowRotationEditor);
    leftPos = leftPos + SIZE + 4;

    frame.MonitorButton = CreateIconButton("MonitorButton", frame, SIZE, 3717417, "Open ability monitor");
    SetBindingClick("SHIFT-T", frame.MonitorButton:GetName(), "");
    frame.MonitorButton:SetPoint("LEFT", leftPos, 0);
    frame.MonitorButton:SetScript("OnClick", function() print("MonitorButton"); end);
    leftPos = leftPos + SIZE;

    T.ControlPanel = frame;
    return frame;
end;

function T.SetCurrentIcon(icon)
    if T.ControlPanel and T.ControlPanel.icon and T.ControlPanel:IsVisible() then
        T.ControlPanel.icon:SetTexture(icon);
    end
end
