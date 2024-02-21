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

function T.ItemInfo:IsOnCooldown()
    -- startTime, duration, enable = GetItemCooldown(itemID)
    local start, duration = GetSpellCooldown(self.BookId, self.BookType);
    if (duration + start - GetTime()) > 0 then
        return true;
    end
    return false;
end

function T.ItemInfo:Update(itemId)

end

function T.ItemInfo:IsReady()
end

function T.ItemInfo:GetHotKeyColor()
    return T.GetHotKeyColor("item", self.Id);
end

local function GetItemCooldown(itemId)
    for invSlot = 1, 19 do
        local id = GetInventoryItemID("player", invSlot);
        if id == itemId then
            local start, duration, enable = GetInventoryItemCooldown("player", invSlot);
            if enable and (duration + start - GetTime()) > 0 then
                return true
            else
                return false;
            end
        end
    end
end

local function GetBagItemCooldown(itemId)
	local bagID = 1;
	local bagName = GetBagName(bagID);
	local searchItemName = GetItemInfo(itemId);
	if (searchItemName == nil) then return nil end
	while (bagName ~= nil) do
		local slots = GetContainerNumSlots(bagID);
		for slot = 1, slots, 1 do
			local _, _, _, _, _, _, itemLink = GetContainerItemInfo(bagID, slot);
			if (itemLink ~= nil) then
				local startTime, duration, isEnabled = GetContainerItemCooldown(bagID, slot);
				if (startTime ~= nil and startTime > 0 and itemLink ~= nil) then
					if (searchItemName == itemName) then
						return startTime, duration, isEnabled;
					end
				end
			end
		end
		-- Restart While Loop
		bagID = bagID + 1;
		bagName = GetBagName(bagID);
	end
	return nil;
end