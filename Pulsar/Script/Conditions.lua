local _, T = ...;

T:RegisterCondition('combat', { type = 'boolean', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end)

T:RegisterCondition('dead',
{ type = 'boolean', arg = false },
function(owner, player, target)
    return false;
end)

T:RegisterCondition('target.hp', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end)

T:RegisterCondition('target.hpmax',
    { type = 'compare', arg = false },
    function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end)

T:RegisterCondition('target.aura',
    { type = 'compare', arg = false },
    function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end)