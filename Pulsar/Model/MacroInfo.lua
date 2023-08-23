local _, T = ...;

T.MacroInfo = {
    Id       = 0,
    Name     = "",
    BagId    = 0,
    SlotId   = 0,
    Cooldown = 0,
    Count    = 0,
    HotKey   = "",
};

function T.MacroInfo:New(id, name)
    local obj = {
        Id       = id;
        Name     = name;
        BagId    = 0;
        SlotId   = 0;
        Cooldown = 0;
        Count    = 0;
        HotKey   = "";
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.MacroInfo:Update()

end