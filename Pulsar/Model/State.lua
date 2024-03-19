local _, T = ...;

T.State = {
    Player  = {},
    Target  = {},
    Spells  = {},
    Items   = {},
    Macros  = {},
    DefinedSpells = {},
};

function T.State:New(actions, defines)
    local obj = {
        Player = T.PlayerInfo:New(),
        Target = T.TargetInfo:New("target"),
        Focus  = T.TargetInfo:New("focus"),
        --MouseOver  = T.TargetInfo:New("mouseover"),
        Spells = {},
        Items  = {},
        Macros = {},
        DefinedSpells = {},
    };

    -- /dump Pulsar.StateInfo.Spells[14284]
    for i, action in ipairs(actions) do
        local id = tonumber(action.Params) or 0;
        if action.Name == "spell" and id > 0 then
            --print("spell", id)
            obj.Spells[id] = T.SpellInfo:New(id);
        elseif action.Name == "item" and id > 0 then
            obj.Items[id] = T.ItemInfo:New(id);
        elseif action.Name == "macro" and id > 0 then
            obj.Macros[id] = T.MacroInfo:New(id);
        end
    end

    for k,v in pairs(defines) do
        obj.DefinedSpells[k] = T.SpellInfo:New(tonumber(v), k);
    end

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.State:Update()
    self.Player:Update();
    self.Target:Update();
    self.Focus:Update();

    for _, spell in pairs(self.Spells) do
        spell:Update();
    end

    for _, item in pairs(self.Items) do
        item:Update();
    end

    for _, macro in pairs(self.Macros) do
        macro:Update();
    end

    for _, def in pairs(self.DefinedSpells) do
        def:Update();
    end
end

function T.State:CheckSpell(id)
    local info = self.Spells[id];
    local result, color, icon = false, nil, nil;
    if not info then
        return result, color, icon;
    end

    result = info:IsReady();
    if result then
        color = info:GetHotKeyColor();
        icon = info.Icon;
    end
    return result, color, icon;
end

function T.State:CheckItem(id)
    local info = self.Items[id];
    local result, color, icon = false, nil, nil;
    if not info then
        return result, color, icon;
    end

    result = info:IsReady();
    if result then
        color = info:GetHotKeyColor();
        icon = info.Icon;
    end
    return result, color, icon;
end

function T.State:CheckMacro(id)
    local info = self.Macros[id];
    local result, color, icon = false, nil, nil;
    if not info then
        return result, color, icon;
    end

    result = info:IsReady();
    if result then
        color = info:GetHotKeyColor();
        icon = info.Icon;
    end
    return result, color, icon;
end

