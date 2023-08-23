local _, T = ...;

T.ItemInfo = {
    Id       = 0,
    Name     = "",
    BagId    = 0,
    SlotId   = 0,
    Cooldown = 0,
    Count    = 0,
    HotKey   = "",
    IsEquip  = false,
};

function T.ItemInfo:New(id, name)
    local obj = {
        Id       = id;
        Name     = name;
        BagId    = 0;
        SlotId   = 0;
        Cooldown = 0;
        Count    = 0;
        HotKey   = "";
        IsEquip  = false;
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.ItemInfo:Update()

end