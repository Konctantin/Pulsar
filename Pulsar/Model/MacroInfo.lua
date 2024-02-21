local _, T = ...;

T.MacroInfo = {
    Id        = 0,
    Name      = "",
    Type      = nil,
    Icon      = nil,
    HotKey    = "",
    SpellInfo = {},
    ItemInfo  = {},
};

function T.MacroInfo:New(id, name)
    local obj = {
        Id        = id;
        Name      = name;
        Type      = nil;
        Icon      = nil;
        HotKey    = "";
        SpellInfo = T.SpellInfo:New(0);
        ItemInfo  = T.ItemInfo:New(0);
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.MacroInfo:Update()
    local spellId = GetMacroSpell(self.Id);
    local itemId = GetMacroItem(self.Id);

    if itemId then
        self.Type = "item";
        self.SpellInfo:Update(0);
        self.ItemInfo:Update(itemId);
        self.Icon = self.ItemInfo.Icon;
    elseif spellId then
        self.Type = "spell";
        self.SpellInfo:Update(spellId);
        self.ItemInfo:Update(0);
        self.Icon = self.SpellInfo.Icon;
    end
end

function T.MacroInfo:IsReady()
    local result = false;

    if self.Type == "spell" then
        result = self.SpellInfo:IsReady();
    elseif self.Type == "item" then
        result = self.ItemInfo:IsReady();
    end;

    return result;
end

function T.MacroInfo:GetHotKeyColor()
    return T.GetHotKeyColor("macro", self.Id);
end