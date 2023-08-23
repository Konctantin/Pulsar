local _, T = ...;

T.State = {
    Player = {},
    Target = {},
    Spells = {},
    Items  = {},
    Macros = {},
};

function T.State:New(actions)
    local obj = {
        Player = T.PlayerInfo:New(),
        Target = T.TargetInfo:New("target"),
        Focus  = T.TargetInfo:New("focus"),
        --MouseOver  = T.TargetInfo:New("mouseover"),
        Spells = {},
        Items  = {},
        Macros = {},
    };

    for i, action in ipairs(actions) do
        local id = tonumber(action.Params) or 0;
        if action.Name == "spell" and id > 0 then
            obj.Spells[id] = T.SpellInfo:New(id);
        elseif action.Name == "item" and id > 0 then
            obj.Spells[id] = T.ItemInfo:New(id);
        elseif action.Name == "macro" and id > 0 then
            obj.Spells[id] = T.MacroInfo:New(id);
        end
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
end