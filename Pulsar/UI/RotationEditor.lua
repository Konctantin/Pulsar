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
    button:SetScript('OnLeave', function (self)
        GameTooltip_Hide();
    end);

    button:Show();
    return button;
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
    editor:SetAutoFocus(true);
    editor:EnableMouse(true);
    editor:SetMaxLetters(99999);
    editor:SetFont('Fonts\\ARIALN.ttf', 15, 'THINOUTLINE');
    editor:SetPoint("TOPLEFT", editPanel, "TOPLEFT", 0, -30);
    editor:SetWidth(editPanel:GetWidth()-30);
    editor:SetHeight(editPanel:GetHeight()-30);
    editor:SetScript('OnTextChanged', function(self)
        T.SaveButton:SetEnabled(true);
    end);

    local scroll = CreateFrame('ScrollFrame', 'RotationEditorEditBoxScroll', editPanel, 'UIPanelScrollFrameTemplate');
    scroll:SetPoint('TOPLEFT', editPanel, 'TOPLEFT', 8, -8);
    scroll:SetPoint('BOTTOMRIGHT', editPanel, 'BOTTOMRIGHT', -30, 8);
    scroll:SetScrollChild(editor);

    editPanel:Hide();
    
    specButton.Scroll = scroll;
    specButton.Editor = editor;
    specButton.EditPanel = editPanel;
end

local function CreateSpecButtons(classID, classButton, frame)
    classButton.SpecButtons = {};

    --print(numSpecializations)
    local X_Offset = 210;
    for s = 1, GetNumSpecializationsForClassID(classID) do
        local specId, specName, description, icon, role = GetSpecializationInfoForClassID(classID, s);
        --print(specId, specName, icon, role)
        local button = CreateFrame("Button", classButton:GetName().."_"..tostring(specId), frame);
        button:SetSize(25, 25);
        button:SetPoint("TOPLEFT", X_Offset, -25);
        
        button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square");
        button:GetHighlightTexture():SetBlendMode("ADD");

        button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress");
        button:GetPushedTexture():SetDrawLayer("OVERLAY");
        
        button.icon = button:CreateTexture("", "BACKGROUND");
        button.icon:SetWidth(25);
        button.icon:SetHeight(25);
        button.icon:SetPoint("LEFT");
        button.icon:SetTexture(icon);
        
        button.ClassId = classButton.ClassId;
        button.ClassFile = classButton.ClassFile;
        button.SpecId = specId;
        button.SpecName = specName;
        button.Description = description;
        button.Role = role;

        button:SetScript('OnEnter', function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
            GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
            GameTooltip_AddNormalLine(GameTooltip, self.SpecName);
            GameTooltip_AddBlankLineToTooltip(GameTooltip);
            GameTooltip_AddNormalLine(GameTooltip, self.Role);
            GameTooltip_AddBlankLineToTooltip(GameTooltip);
            GameTooltip_AddNormalLine(GameTooltip, self.Description);
            GameTooltip:Show();
        end);
        
        button:SetScript('OnLeave', function (self)
            GameTooltip_Hide();
        end);
        
        button:SetScript('OnClick', function (self)
            T.SelectEditor(self.ClassId, self.SpecId);
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
    
    for c = 1, GetNumClasses() do
        local className, classFile, classID = GetClassInfo(c);
        
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
        
        button:SetScript("OnClick", function(self)
            T.SelectEditor(self.ClassId, nil);
        end);
        
        T.ClassButtons[classFile] = button;
        
        --print(className, classFile, classID)
        CreateSpecButtons(classID, button, frame);
        
        Y_Offset = Y_Offset + 26;
    end
end

--local 

local function CreateRotationEditor()
    local frame = CreateFrame("Frame", "RotationEditor", UIParent, "BasicFrameTemplateWithInset");
    frame:SetSize(650, 400);
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

    --local resizeButton = CreateFrame("Button", "RotationEditorResizeButton", frame);
    --resizeButton:SetSize(16, 16);
    --resizeButton:SetPoint("BOTTOMRIGHT");
    --resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");
    --resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight");
    --resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down");
    --resizeButton:SetScript("OnMouseDown", function(self, button)
    --    frame:StartSizing("BOTTOMRIGHT");
    --    frame:SetUserPlaced(true);
    --end);
    --resizeButton:SetScript("OnMouseUp", function(self, button)
    --    frame:StopMovingOrSizing();
    --end);
    --frame.ResizeButton = resizeButton;

    -- adding a scrollframe (includes basic scrollbar thumb/buttons and functionality)
    frame.scrollFrame = CreateFrame("ScrollFrame", "ClassListFrame", frame, "UIPanelScrollFrameTemplate");
    frame.scrollFrame:SetPoint("TOPLEFT", 12, -30);
    --frame.scrollFrame:SetSize()
    frame.scrollFrame:SetPoint("BOTTOMRIGHT", -470, 8);

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
    for _, c in pairs(T.ClassButtons) do
        for _, s in pairs(c.SpecButtons) do
            s:ClearNormalTexture();
            s.EditPanel:Hide();
            s:Hide();
        end
        c:ClearNormalTexture();
    end
    
    -- Select
    for _, c in pairs(T.ClassButtons) do
        if c.ClassId == classId then
            c:SetNormalTexture("Interface/Buttons/ButtonHilight-Square");
            c:GetNormalTexture():SetBlendMode("ADD");
            
            for _, s in pairs(c.SpecButtons) do
                s:Show();
                -- print(s.SpecId, specId)
                if s.SpecId == specId then
                    s:SetNormalTexture("Interface/Buttons/ButtonHilight-Square");
                    s:GetNormalTexture():SetBlendMode("ADD");
                    s.EditPanel:Show();
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
    end
    T.RotationEditor:Show();
    T.LoadEditors();
    T.SelectEditor(nil, nil);
    T.SaveButton:SetEnabled(false);
end
