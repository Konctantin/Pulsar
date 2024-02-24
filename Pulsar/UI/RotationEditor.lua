local _, T = ...;

T.IconTexture = {
    ["DEATHKNIGHT"] = 135771,
    ["DEMONHUNTER"] = 236415,
    ["DRUID"]       = 625999,
    ["HUNTER"]      = 626000,
    ["MAGE"]        = 626001,
    ["MONK"]        = 626002,
    ["PALADIN"]     = 626003,
    ["PRIEST"]      = 626004,
    ["ROGUE"]       = 626005,
    ["SHAMAN"]      = 626006,
    ["WARLOCK"]     = 626007,
    ["WARRIOR"]     = 626008,
    ["EVOKER"]      = 4574311
}

local function GetColoredClass(class)
    local className, classFile, classID = GetClassInfo(class);
    local classColorStr = RAID_CLASS_COLORS[classFile].colorStr;
    local classNameColored = HEIRLOOMS_CLASS_FILTER_FORMAT:format(classColorStr, className);
    return classNameColored;
end

local function CreateSimpleButton(name, width, parent, title, tooltip)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate");
    button:SetSize(width, 25);
    button:SetText(title);
    button.Tooltip = tooltip;
    button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
        GameTooltip_AddNormalLine(GameTooltip, self.Tooltip or "");
        GameTooltip:Show();
    end);
    button:SetScript('OnLeave', function(self)
        GameTooltip_Hide();
    end);

    button:Show();
    return button;
end

local multilineInput do
	--local function onNavigate(self, _x,y, _w,h)
	--	local scroller = self.scroll
	--	local occH, occP, y = scroller:GetHeight(), scroller:GetVerticalScroll(), -y
	--	if occP > y then
	--		occP = y -- too far
	--	elseif (occP + occH) < (y+h) then
	--		occP = y+h-occH -- not far enough
	--	else
	--		return
	--	end
	--	scroller:SetVerticalScroll(occP)
	--	local _, mx = scroller.ScrollBar:GetMinMaxValues()
	--	scroller.ScrollBar:SetMinMaxValues(0, occP < mx and mx or occP)
	--	scroller.ScrollBar:SetValue(occP)
	--end
	function multilineInput(name, parent, width)
        local scroller = CreateFrame("ScrollFrame", name .. "Scroll", parent, "UIPanelScrollFrameTemplate");
        local input = CreateFrame("Editbox", name, scroller);
        input:SetWidth(width-12);
        input:SetMultiLine(true);
        input:SetAutoFocus(false);
        input:SetTextInsets(2,4,0,2);
        input:SetFontObject(GameFontHighlight);
        --input:SetScript("OnCursorChanged", onNavigate);
        input:SetScript("OnEscapePressed", input.ClearFocus);
        --input:SetScript("OnTabPressed", shiftInputFocus);
        scroller:EnableMouse(1);
        scroller:SetScript("OnMouseDown", function(self) self.input:SetFocus() end);
        scroller:SetScrollChild(input)
        input.scroll = scroller;
        scroller.input = input;

		return input, scroller
	end
end

local function CreateEditor(specButton, frame)
    local X_Offset = 200;
    local Y_Offset = 50;

    local editPanel = CreateFrame("Frame", "RotationEditorEditPanel", frame, "BackdropTemplate");

    editPanel:SetWidth(frame:GetWidth()-X_Offset-10);
    editPanel:SetHeight(frame:GetHeight()-Y_Offset-10);
    editPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", X_Offset, -Y_Offset);
    editPanel:SetBackdropColor(0, 0, 0);
    editPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
    });

    local editor = CreateFrame('EditBox', 'RotationEditorEditBox', editPanel);
    editor:SetMultiLine(true);
    editor:SetAutoFocus(false);
    editor:EnableMouse(true);
    editor:SetMaxLetters(99999);
    editor:SetTextInsets(2,4,0,2);
    editor:SetFontObject(GameFontHighlight);
    editor:SetPoint("TOPLEFT", editPanel, "TOPLEFT", 0, -30);
    editor:SetWidth(editPanel:GetWidth()-30);
    editor:SetHeight(editPanel:GetHeight()-30);
    editor:SetScript("OnEscapePressed", editor.ClearFocus);
    editor:SetScript('OnTextChanged', function(self)
        T.SaveButton:SetEnabled(true);
    end);

    local scroll = CreateFrame('ScrollFrame', 'RotationEditorEditBoxScroll', editPanel, 'UIPanelScrollFrameTemplate');
    scroll:SetPoint('TOPLEFT', editPanel, 'TOPLEFT', 8, -8);
    scroll:SetPoint('BOTTOMRIGHT', editPanel, 'BOTTOMRIGHT', -30, 8);
    scroll:SetScript("OnMouseDown", function(self) self.editor:SetFocus() end);
    scroll:EnableMouse(1);
    scroll:SetScrollChild(editor);
    scroll.editor = editor;
    editPanel:Hide();

    local name = "";
    local width = 400;

    --local scroller = CreateFrame("ScrollFrame", name .. "Scroll", frame, "UIPanelScrollFrameTemplate");
    --local input = CreateFrame("Editbox", name, scroller);
    --input:SetWidth(width-12);
    --input:SetMultiLine(true);
    --input:SetAutoFocus(false);
    --input:SetTextInsets(2,4,0,2);
    --input:SetFontObject(GameFontHighlight);
    ----input:SetScript("OnCursorChanged", onNavigate);
    --input:SetScript("OnEscapePressed", input.ClearFocus);
    ----input:SetScript("OnTabPressed", shiftInputFocus);
    --scroller:EnableMouse(1);
    --scroller:SetScript("OnMouseDown", function(self) self.input:SetFocus() end);
    --scroller:SetScrollChild(input);
    --scroller:SetPoint("TOPLEFT", 30, -200);
    --scroller:SetPoint("BOTTOMRIGHT", -170, 34)
    --input.scroll = scroller;
    --scroller.input = input;


    --local ebox, scr = multilineInput("M6EditBox", editPanel, mainPanel:GetWidth()-34) do
    --    scr:SetPoint("TOPLEFT", 6, -73)
    --    scr:SetPoint("BOTTOMRIGHT", -30, 34)
    --    local oc = CreateFrame("Frame", nil, scr)
    --    SetBackdrop(oc, {edgeFile="Interface/Tooltips/UI-Tooltip-Border", bgFile="Interface/DialogFrame/UI-DialogBox-Background-Dark", tile=true, edgeSize=16, tileSize=16, insets={left=4,right=4,bottom=4,top=4}})
    --    oc:SetPoint("TOPLEFT", -3, 5)
    --    oc:SetPoint("BOTTOMRIGHT", 26, -4)
    --    oc:SetFrameLevel(scr:GetFrameLevel()-1)
    --    editPanel.box = ebox
    --end

    specButton.Scroll = scroll;
    specButton.Editor = editor;
    specButton.EditPanel = editPanel;
end

local function CreateSpecButtons(classID, classButton, frame)
    classButton.SpecButtons = {};

    local ICON_SIZE = 25;
    local X_Offset = 210;
    for s = 1, GetNumSpecializationsForClassID(classID) do
        local specId, specName, description, specIcon, specRole = GetSpecializationInfoForClassID(classID, s);
        --print(specId, specName, specIcon, specRole)
        local button = CreateFrame("Button", classButton:GetName().."_"..tostring(specId), frame);
        button:SetSize(ICON_SIZE, ICON_SIZE);
        button:SetPoint("TOPLEFT", X_Offset, -ICON_SIZE);

        button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square");
        button:GetHighlightTexture():SetBlendMode("ADD");

        button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress");
        button:GetPushedTexture():SetDrawLayer("OVERLAY");

        button.IconSpec = button:CreateTexture("", "BACKGROUND");
        button.IconSpec:SetWidth(ICON_SIZE);
        button.IconSpec:SetHeight(ICON_SIZE);
        button.IconSpec:SetPoint("LEFT");
        button.IconSpec:SetTexture(specIcon);

        button.ToolTipHeader = CreateFrame("Frame", button:GetName().."_ToolTipHeader", button);
        button.ToolTipHeader:SetSize(ICON_SIZE, ICON_SIZE);
        button.ToolTipHeader.Icon = button.ToolTipHeader:CreateTexture("", "BACKGROUND");
        button.ToolTipHeader.Icon:SetSize(ICON_SIZE, ICON_SIZE);
        button.ToolTipHeader.Icon:SetPoint("LEFT");
        button.ToolTipHeader.Icon:SetAtlas(GetMicroIconForRole(specRole), TextureKitConstants.IgnoreAtlasSize);

        button.ToolTipHeader.Text = button.ToolTipHeader:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
        button.ToolTipHeader.Text:SetPoint("LEFT", ICON_SIZE, 0);
        button.ToolTipHeader.Text:SetText("|cff00ff00 "..specName.."|r");

        button.ClassButton = classButton;
        button.ClassId = classButton.ClassId;
        button.ClassFile = classButton.ClassFile;
        button.SpecId = specId;
        button.SpecName = specName;
        button.Description = description;
        button.SpecRole = specRole;

        button:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
            GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
            GameTooltip_InsertFrame(GameTooltip, self.ToolTipHeader);
            GameTooltip_AddNormalLine(GameTooltip, self.Description);
            GameTooltip:Show();
        end);

        button:SetScript('OnLeave', function (self)
            GameTooltip_Hide();
        end);

        button:SetScript('OnClick', function (self)
            T.SelectEditor(self.ClassId, self.SpecId);
            self.ClassButton.LastSpec = self.SpecId;
        end);

        CreateEditor(button, frame);

        button:Hide();

        classButton.SpecButtons[specId] = button;
        X_Offset = X_Offset + button:GetWidth() + 10;
    end
end

local function CreateClassList(parent, frame)
    local Y_Offset = 0;
    T.ClassButtons = {};

    for classIndex = 1, GetNumClasses() do
        local className, classFile, classID = GetClassInfo(classIndex);
        if className then
            local button = CreateFrame("Button", classFile.."_ClassButton", parent);
            button:SetSize(parent:GetWidth()-20, 25);
            button:SetPoint("TOPLEFT", 0, -Y_Offset);

            button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square");
            button:GetHighlightTexture():SetBlendMode("ADD");
            button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress");
            button:GetPushedTexture():SetDrawLayer("OVERLAY");

            button.icon = button:CreateTexture("", "BACKGROUND");
            button.icon:SetWidth(25);
            button.icon:SetHeight(25);
            button.icon:SetPoint("LEFT");
            button.icon:SetTexture(T.IconTexture[classFile]);

            button.name = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
            button.name:SetPoint("LEFT", 35, 0);
            button.name:SetText(GetColoredClass(classID));

            button.ClassFile = classFile;
            button.ClassId = classID;
            button.LastSpec = nil;

            button:SetScript("OnClick", function(self)
                T.SelectEditor(self.ClassId, self.LastSpec);
            end);

            T.ClassButtons[classFile] = button;

            --print(className, classFile, classID)
            CreateSpecButtons(classID, button, frame);

            Y_Offset = Y_Offset + 26;
        end
    end
end

--local

local function CreateRotationEditor()
    local FRAME_WIDTH = 800;
    local frame = CreateFrame("Frame", "RotationEditor", UIParent, "BasicFrameTemplateWithInset");
    frame:SetSize(FRAME_WIDTH, 400);
    frame:SetPoint("CENTER");
    frame:SetMovable(true);
    frame:SetResizable(true);
    frame:SetScript("OnMouseDown", frame.StartMoving);
    frame:SetScript("OnMouseUp", frame.StopMovingOrSizing);

    frame.TitleText:SetPoint("LEFT", 10, 0);
    frame.TitleText:SetText("RotationEditor");

    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
    frame:SetScript("OnEvent", function (self, event, ...)
        if event == "PLAYER_SPECIALIZATION_CHANGED" then
            T.SelectEditor(nil, nil);
        end
    end);

    --[[
    local resizeButton = CreateFrame("Button", "RotationEditorResizeButton", frame);
    resizeButton:SetSize(16, 16);
    resizeButton:SetPoint("BOTTOMRIGHT");
    resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");
    resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");
    resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down");
    resizeButton:SetScript("OnMouseDown", function(self, button)
        frame:StartSizing("BOTTOMRIGHT");
        frame:SetUserPlaced(true);
    end);
    resizeButton:SetScript("OnMouseUp", function(self, button)
        frame:StopMovingOrSizing();
    end);
    frame.ResizeButton = resizeButton;
    ]]

    -- adding a scrollframe (includes basic scrollbar thumb/buttons and functionality)
    local CLASS_LIST_WIDTH = 200;
    frame.scrollFrame = CreateFrame("ScrollFrame", "ClassListFrame", frame, "UIPanelScrollFrameTemplate");
    frame.scrollFrame:SetPoint("TOPLEFT", 12, -30);
    --frame.scrollFrame:SetSize()
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -(FRAME_WIDTH-CLASS_LIST_WIDTH+22), 8);

    -- creating a scrollChild to contain the content
    frame.scrollFrame.scrollChild = CreateFrame("Frame", "ClassListContentFrame", frame.scrollFrame);
    frame.scrollFrame.scrollChild:SetSize(200, 100);
    frame.scrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5);
    frame.scrollFrame:SetScrollChild(frame.scrollFrame.scrollChild);

    CreateClassList(frame.scrollFrame.scrollChild, frame);

    X_Offset = 20;
    local WIDTH = 70;

    T.ImportButton = CreateSimpleButton("ImportButton", WIDTH, frame, "Import", "Import all rotations");
    T.ImportButton:SetPoint("TOPRIGHT", -X_Offset, -25);
    T.ImportButton:SetScript("OnClick", function(self)
        print("Show Import")
    end);
    X_Offset = X_Offset + WIDTH + 5;

    T.ExportButton = CreateSimpleButton("ExportButton", WIDTH, frame, "Export", "Export all rotations");
    T.ExportButton:SetPoint("TOPRIGHT", -X_Offset, -25);
    X_Offset = X_Offset + WIDTH + 5;
    T.ExportButton:SetScript("OnClick", function(self)
        print("Show Export")
    end);

    T.SaveButton = CreateSimpleButton("SaveButton", WIDTH, frame, "Save", "Save current rotation");
    T.SaveButton:SetPoint("TOPRIGHT", -X_Offset, -25);
    T.SaveButton:SetEnabled(false);
    T.SaveButton:SetScript("OnClick", function(self)
        -- todo:
        --if check_script then
        --    -- todo: show error
        --    return;
        --end
        T.SaveEditors();
        T.LoadCurrentRotation();
        self:SetEnabled(false);
    end);

    return frame;
end

function T.SelectEditor(classId, specId)
    if not classId and not specId then
        classId = select(3, UnitClass("player"));
        specId = GetSpecializationInfo(GetSpecialization());
    end

    if not specId then
        if select(3, UnitClass("player")) == classId then
            specId = GetSpecializationInfo(GetSpecialization());
        else
            specId = GetSpecializationInfoForClassID(classId, 1);
        end
    end

    -- Hide all
    for _, classButton in pairs(T.ClassButtons) do
        classButton:ClearNormalTexture();
        for _, specButton in pairs(classButton.SpecButtons) do
            specButton:ClearNormalTexture();
            specButton.EditPanel:Hide();
            specButton:Hide();
        end
    end

    -- Select
    for _, classButton in pairs(T.ClassButtons) do
        if classButton.ClassId == classId then
            classButton:SetNormalTexture("Interface/Buttons/ButtonHilight-Square");
            classButton:GetNormalTexture():SetBlendMode("ADD");

            for _, specButton in pairs(classButton.SpecButtons) do
                specButton:Show();
                -- print(specButton.SpecId, specId)
                if specButton.SpecId == specId then
                    specButton:SetNormalTexture("Interface/Buttons/ButtonHilight-Square");
                    specButton:GetNormalTexture():SetBlendMode("ADD");
                    specButton.EditPanel:Show();
                end
            end
            break;
        end
    end

    local specName, description, icon, role = select(2, GetSpecializationInfoByID(specId));
    --print(classId, specId, specName, description, icon, role);

    T.RotationEditor.TitleText:SetText("Rotation Editor: "..GetColoredClass(classId).." "..specName.." "..role);
end

function T.LoadEditors()
    for _, classButton in pairs(T.ClassButtons) do
        local classStorage = PULSAR_GLOBAL_STORAGE[classButton.ClassFile];
        for _, specButton in pairs(classButton.SpecButtons) do
            local specStorage = classStorage and classStorage[specButton.SpecId];
            specButton.Editor:SetText(specStorage.Code or "");
        end
    end
    T.SaveButton:SetEnabled(false);
end

function T.SaveEditors()
    for _, classButton in pairs(T.ClassButtons) do
        local classStorage = PULSAR_GLOBAL_STORAGE[classButton.ClassFile];
        for _, specButton in pairs(classButton.SpecButtons) do
            classStorage[specButton.SpecId].Code = specButton.Editor:GetText();
        end
    end
    T.SaveButton:SetEnabled(false);
end


function T.ShowRotationEditor()
    if not T.RotationEditor then
       T.RotationEditor = CreateRotationEditor();
       T.RotationEditor:Hide();
    end

    if not T.RotationEditor:IsVisible() then
        T.RotationEditor:Show();
        T.LoadEditors();
        T.SelectEditor(nil, nil);
        T.SaveButton:SetEnabled(false);
    else
        T.RotationEditor:Hide();
    end
end
