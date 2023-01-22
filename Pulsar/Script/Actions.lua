local _, T = ...;

-- Just test function
T:RegisterAction('test', function(arg, run)
    if run then
        print(arg)
    end
    --return T:GetSetting('testBreak')
end);

-- Cast spell function
-- cast(Spell:123) [player:aura(Aura:456988).exists]
-- cast(Spell:123) [target:aura(Aura:4569).duration < 3]
-- cast(Spell:123) [form=cat & target:aura(Aura:4569).duration < 3]
T:RegisterAction('cast', function(ability, run)
    return true
end);

-- Use item function
-- use(Item:12334) [hp < 30]
T:RegisterAction('use', function(item, run)
    return true
end);

-- break abilities priority
-- exit [nocombat]
-- exit [invisible]
T:RegisterAction("return", "quit", "exit", function(run)
    return true
end);

-- just comment
T:RegisterAction('--', function(run)
    return false
end);
