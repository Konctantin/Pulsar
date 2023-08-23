local _, T = ...;

T.Condition = { apis = {} };

T.Condition.opts = setmetatable({
    __default = {
        owner = true,
        pet   = true,
        arg   = true,
        type  = 'compare',
    }
}, {
    __newindex = function(t, k, v)
        rawset(t, k, setmetatable(v, {__index = t.__default}))
    end,
    __index = function(t)
        return t.__default
    end,
})

local opTabler = {
    compare = {
        ['=']  = function(a, b) return a == b   end,
        ['=='] = function(a, b) return a == b   end,
        ['!='] = function(a, b) return a ~= b   end,
        ['>']  = function(a, b) return a >  b   end,
        ['<']  = function(a, b) return a <  b   end,
        ['>='] = function(a, b) return a >= b   end,
        ['<='] = function(a, b) return a <= b   end,
        ['~']  = function(a, v) return     v[a] end,
        ['!~'] = function(a, v) return not v[a] end,
    },
    boolean = {
        ['=']  = function(a) return     a end,
        ['!']  = function(a) return not a end,
    },
    equality = {
        ['=']  = function(a, b) return a == b   end,
        ['=='] = function(a, b) return a == b   end,
        ['!='] = function(a, b) return a ~= b   end,
        ['~']  = function(a, v) return     v[a] end,
        ['!~'] = function(a, v) return not v[a] end,
    }
}

local fieldTypes = {
    ["duration"] = true,
    ["exists"] = true,
    ["count"] = true,
};

local multiTabler = {
    ['~']  = true,
    ['!~'] = true,
}

local parses = {
    'valueParse',
    'argParse',
}

local function trynumber(value)
    return tonumber(value) or value
end

local function trynil(value)
    return value ~= '' and value or nil
end

function T.Condition:New()
    local obj = {

    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.Condition:Call(state)
    return true;
end

function T:RegisterCondition(name, opts, api)
    if opts then
        if opts.type and not opTabler[opts.type] then
            error([[Bad argument opts.type (expect compare/boolean/equality)]], 2)
        end

        if type(opts.fields) == "table" then
            for _, f in ipairs(opts.fields) do
                if not fieldTypes[f] then
                    error(format([[Bad field %s for %s]], f, name), 2);
                end
            end
        end

        for i, v in ipairs(parses) do
            if opts[v] and type(opts[v]) ~= 'function' then
                error(format([[Bad argument opts.%s (expect function)]], v), 2)
            end
        end
    end

    T.Condition.apis[name] = api
    T.Condition.opts[name] = opts
end

function T.Condition:Run(condition)
    if not condition then
        return true
    end
    if type(condition) == 'string' then
        return self:RunCondition(condition)
    elseif type(condition) == 'table' then
        for _, v in ipairs(condition) do
            if not self:Run(v) then
                return false
            end
        end
        return true
    else
        T.assert(false, 'Invalid Condition: `%s` (type error)', condition)
    end
end

function T.Condition:RunCondition(condition)
    local owner, pet, cmd, arg, op, value = self:ParseCondition(condition)

    local fn  = self.apis[cmd]
    local opts = self.opts[cmd]
    if not fn then
        error('Big Bang !!!!!!')
    end

    local res = fn(owner, pet, arg)
    return opTabler[opts.type][op](res, value)
end

function T.Condition:ParseTarget(str)
    if not str then
        return
    end

    local targer, pet = T.ParseQuote(str)
    --owner = T.ParsePetOwner(owner)
    if not (targer == "player" or targer == "target") then
        return
    end

    --local petInputed = not not pet
    --pet = T.ParsePetIndex(targer, pet)
    return targer--, pet, petInputed
end

function T.Condition:ParseCmd(major, minor)
    if not major then
        return
    end

    local cmd, arg = T.ParseQuote(major)
    return minor and format('%s.%s', cmd, minor) or cmd, arg, not not arg
end

function T.Condition:ParseApi(str)
    if not str then
        return
    end

    local inQuote = false
    local args = {''}

    for char in str:gmatch('.') do
        if char == '.' and not inQuote then
            tinsert(args, '')
        else
            args[#args] = args[#args] .. char
        end

        if char == '(' then
            inQuote = true
        elseif char == ')' then
            inQuote = false
        end
    end

    local target, pet, petInputed = self:ParseTarget(args[1])
    local cmd,   arg, argInputed = self:ParseCmd(unpack(args, target))

    return target or "player", pet, cmd, arg, petInputed, argInputed
end

function T.Condition:ParseCondition(condition)
    -- [ target.aura(SomeSpell:123,player) ]
    local non, args, operand, value = condition:match('^(!?)([^!=<>~]+)%s*([!=<>~]*)%s*(.*)$')

    T.assert(non, 'Invalid Condition: `%s` (Can`t parse)', condition)

    --
    local target, cmd, arg, petInputed, argInputed = self:ParseApi(args:trim())

    T.assert(cmd, 'Invalid Condition: `%s` (Can`t parse)', condition)
    T.assert(self.apis[cmd], 'Invalid Condition: `%s` (Not found cmd: `%s`)', condition, cmd)

    operand = trynil(operand)
    value = trynil(value)
    non   = trynil(non)

    local opts = self.opts[cmd]

    if opts.type == 'compare' or opts.type == 'equality' then
        T.assert(not non, 'Invalid Condition: `%s` (Not need non)',  condition)
        T.assert(operand, 'Invalid Condition: `%s` (Require op)',    condition)
        T.assert(value,   'Invalid Condition: `%s` (Require value)', condition)
    elseif opts.type == 'boolean' then
        T.assert(not operand, 'Invalid Condition: `%s` (Not need op)',    condition)
        T.assert(not value,   'Invalid Condition: `%s` (Not need value)', condition)

        value = nil
        operand = non or '='
    else
        T.assert(true)
    end

    T.assert(opTabler[opts.type][operand], 'Invalid Condition: `%s` (Invalid op)', condition)

    if value then
        if multiTabler[operand] then
            local values = {strsplit(',', value)}
            value = {}

            for i, v in ipairs(values) do
                v = trynumber(v:trim())
                if opts.valueParse then
                    v = T.assert(opts.valueParse(v), 'Invalid Condition: `%s` (Error value)', condition)
                end
                value[v] = true
            end
        else
            value = trynumber(value)
            if opts.valueParse then
                value = T.assert(opts.valueParse(value), 'Invalid Condition: `%s` (Error value)', condition)
            end
        end
    end

    if not opts.owner then
        T.assert(not owner, 'Invalid Condition: `%s` (Not need owner)', condition)
    end

    if not opts.pet then
        T.assert(not petInputed, 'Invalid Condition: `%s` (Not need pet)', condition)
    end

    if not opts.arg then
        T.assert(not argInputed, 'Invalid Condition: `%s` (Not need arg)', condition)
    else
        arg = trynumber(arg)
        if opts.argParse then
            arg = opts.argParse(owner, pet, arg)
        end
    end
    return owner, pet, cmd, arg, operand, value
end

-- The player is in combat
T:RegisterCondition('combat', { type = 'boolean', arg = false }, function(owner, player, target)
    return UnitAffectingCombat("player");
end);

-- The unit exists and is dead
T:RegisterCondition('dead', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

-- The player is dead
T:RegisterCondition('palyer.dead', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

-- The unit exists and can be targeted by harmful spells
T:RegisterCondition('harm', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

-- The unit exists and can be targeted by helpful spells
T:RegisterCondition('help', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

-- Self-explanatory
T:RegisterCondition('stealth', { type = 'boolean', arg = false }, function(owner, player, target)
    return IsStealthed()
end);

-- Unreliable in Wintergrasp
T:RegisterCondition('flyable', { type = 'boolean', arg = false }, function(owner, player, target)
    return IsFlyableArea();
end);

-- Mounted or flight form, and in the air
T:RegisterCondition('flying', { type = 'boolean', arg = false }, function(owner, player, target)
    return IsFlying();
end);


-- Self-explanatory
T:RegisterCondition('mounted', { type = 'boolean', arg = false }, function(owner, player, target)
    return IsMounted();
end);

T:RegisterCondition('move', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('party', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('party', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('interrupt', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('dispell', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('raid', { type = 'boolean', arg = false }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('pause', { type = 'boolean', arg = false }, function(owner, player, target)
    return not GetCurrentKeyBoardFocus() and IsLeftAltKeyDown();
end);

-- Refer to GetShapeshiftForm for possible values
T:RegisterCondition('form', { type = 'compare', arg = true }, function(owner, player, target)
    return false;
end);

-- Refer to GetShapeshiftForm for possible values
T:RegisterCondition('stance', { type = 'compare', arg = true }, function(owner, player, target)
    return false;
end);

T:RegisterCondition('target.hp', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);

T:RegisterCondition('target.hpp', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);

T:RegisterCondition('player.hp', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);

T:RegisterCondition('player.hpp', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);

T:RegisterCondition('target.hpmax', { type = 'compare', arg = false }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);

T:RegisterCondition('target.aura', { type = 'compare', arg = false, fields = {"duration","exists","count"} }, function(owner, player, target)
    --return C_PetBattles.GetHealth(owner, pet)
end);