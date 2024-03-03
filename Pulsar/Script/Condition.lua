local _, T = ...;

T.Condition = {
    func     = nil;
    params   = {};
    comparer = nil;
    value    = nil;
    apis     = {},
    opts     = setmetatable({
        __default = {
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
};

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

local multiTabler = {
    ['~']  = true,
    ['!~'] = true,
}

local parses = {
    'valueParse',
    'argParse',
}

local function trynumber(value)
    return tonumber(value) or value;
end

local function trynil(value)
    return value ~= '' and value or nil;
end

function T.Condition:New(func, params, comparer, value)
    local obj = {
        func     = func,
        params   = params,
        comparer = comparer,
        value    = value
    };

    self.__index = self;
    setmetatable(obj, self);

    return obj;
end

function T.Condition:Call(state)
    local apiResult = self.func(state, self.params);
    local result = self.comparer(apiResult, self.value);
    return result
end

function T:RegisterCondition(name, opts, api)
    if opts then
        if opts.type and not opTabler[opts.type] then
            error([[Bad argument opts.type (expect compare/boolean/equality)]], 2)
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

function T.Condition.ParseApi(str)
    if not str then
        return
    end

    local apif, param = string.match(str:trim(), '^([%a%.]+)%s*%((.+)%)$');
    if not apif then
        apif = string.match(str:trim(), '^([%a%.]+)%s*$');
    end
    local id = ParseID(param);

    return apif, param, id;
end

function T.Condition.Parse(condition)
    -- [ target.aura(SomeSpell:123,player) ]
    local non, args, operand, value = condition:match('^(!?)([^!=<>~]+)%s*([!=<>~]*)%s*(.*)$');
    T.assert(non, 'Invalid Condition: `%s` (Can`t parse)', condition);

    local funcName, paramText, paramId = T.Condition.ParseApi(args);
    T.assert(funcName, 'Invalid Condition API function: `%s` (Can`t parse)', args);

    local func = T.Condition.apis[funcName];
    T.assert(func, 'Invalid Condition: `%s` (Not found cmd: `%s`)', condition, funcName)

    operand = trynil(operand)
    value = trynil(value)
    non   = trynil(non)

    local opts = T.Condition.opts[funcName];

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

    local comparer = opTabler[opts.type][operand];

    T.assert(comparer, 'Invalid Condition: `%s` (Invalid op)', condition)

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

    if not opts.arg then
        T.assert(not (paramId or paramText), 'Invalid Condition: `%s` (Not need arg)', condition);
    end

    local funcArgs = paramId or paramText;
    local cond = T.Condition:New(func, funcArgs, comparer, value);
    return cond;
end

-- The player is in combat
T:RegisterCondition('combat', { type = 'boolean', arg = false }, function(state, args)
    return UnitAffectingCombat("player");
end);

-- The unit exists and is dead
T:RegisterCondition('dead', { type = 'boolean', arg = false }, function(state, args)
    return UnitIsDead("target");
end);

-- The player is dead
T:RegisterCondition('palyer.dead', { type = 'boolean', arg = false }, function(state, args)
    return UnitIsDeadOrGhost("player");
end);

-- The unit exists and can be targeted by harmful spells
T:RegisterCondition('harm', { type = 'boolean', arg = false }, function(state, args)
    return not UnitIsFriend("player", "target");
end);

-- The unit exists and can be targeted by helpful spells
T:RegisterCondition('help', { type = 'boolean', arg = false }, function(state, args)
    return UnitIsFriend("player", "target");
end);

-- Self-explanatory
T:RegisterCondition('stealth', { type = 'boolean', arg = false }, function(state, args)
    return IsStealthed();
end);

-- Unreliable in Wintergrasp
T:RegisterCondition('flyable', { type = 'boolean', arg = false }, function(state, args)
    return IsFlyableArea();
end);

-- Mounted or flight form, and in the air
T:RegisterCondition('flying', { type = 'boolean', arg = false }, function(state, args)
    return IsFlying();
end);

-- Self-explanatory
T:RegisterCondition('mounted', { type = 'boolean', arg = false }, function(state, args)
    return IsMounted();
end);

T:RegisterCondition('move', { type = 'boolean', arg = false }, function(state, args)
    return GetUnitSpeed("player") ~= 0 or IsFalling()
        and T.GetUnitBuff("player", 97128) ~= true;
end);

T:RegisterCondition('party', { type = 'boolean', arg = false }, function(state, args)
    return IsInGroup();
end);

T:RegisterCondition('raid', { type = 'boolean', arg = false }, function(state, args)
    return IsInRaid();
end);

T:RegisterCondition('kick', { type = 'boolean', arg = false }, function(state, args)
    return T.CheckInterrupt("target", 1);
end);

T:RegisterCondition('dispell', { type = 'boolean', arg = false }, function(state, args)
    return false;
end);

T:RegisterCondition('meele', { type = 'boolean', arg = false }, function(state, args)
    local spell = state.DefinedSpells['meele'];
    if not spell then
        return false;
    end
    return spell:IsInRange();
end);

T:RegisterCondition('range', { type = 'boolean', arg = false }, function(state, args)
    local spell = state.DefinedSpells['range'];
    if not spell then
        return false;
    end
    return spell:IsInRange();
end);

T:RegisterCondition('agro', { type = 'compare', arg = false }, function(state, args)
    return UnitThreatSituation("player", "target") or 0;
end);

T:RegisterCondition('combo', { type = 'compare', arg = false }, function(state, args)
    return GetComboPoints("player", "target") or 0;
end);

T:RegisterCondition('target.combo', { type = 'compare', arg = false }, function(state, args)
    return GetComboPoints("player", "target") or 0;
end);

-- Refer to GetShapeshiftForm for possible values
T:RegisterCondition('form', { type = 'compare', arg = false }, function(state, args)
    return GetShapeshiftForm();
end);

-- Refer to GetShapeshiftForm for possible values
T:RegisterCondition('stance', { type = 'compare', arg = false }, function(state, args)
    return GetShapeshiftForm();
end);

T:RegisterCondition('target.hp', { type = 'compare', arg = false }, function(state, args)
    return UnitHealth("target");
end);

T:RegisterCondition('target.hpp', { type = 'compare', arg = false }, function(state, args)
    return UnitHealth("target")*100/UnitHealthMax("target");
end);

T:RegisterCondition('player.hp', { type = 'compare', arg = false }, function(state, args)
    return UnitHealth("player");
end);

T:RegisterCondition('mana', { type = 'compare', arg = false }, function(state, args)
    return UnitPower("player", 0)*100/UnitPowerMax("player", 0);
end);

T:RegisterCondition('power', { type = 'compare', arg = false }, function(state, args)
    return UnitPower("player");
end);

T:RegisterCondition('player.hpp', { type = 'compare', arg = false }, function(state, args)
    return UnitHealth("player")*100/UnitHealthMax("player");
end);

T:RegisterCondition('target.hpmax', { type = 'compare', arg = false }, function(state, args)
    return UnitHealthMax("target");
end);

T:RegisterCondition('target.type', { type = 'equality', arg = false }, function(state, args)
    return UnitCreatureType("target");
end);


-- /dump Pulsar.GetUnitBuff("player", 14320, nil)
-- /dump Pulsar.Condition.apis["player.buff"](14320)
T:RegisterCondition('player.buff', { type = 'boolean', arg = true }, function(state, args)
    local result = T.GetUnitBuff("player", tonumber(args), nil);
    return result;
end);

T:RegisterCondition('player.buff.count', { type = 'compare', arg = true }, function(state, args)
    local result = select(2, T.GetUnitBuff("player", tonumber(args), nil));
    return result;
end);

T:RegisterCondition('player.buff.duration', { type = 'compare', arg = true }, function(state, args)
    local result = select(3, T.GetUnitBuff("player", tonumber(args), nil));
    return result;
end);

-- /dump UnitDebuff("target", 1, "player")
-- /dump Pulsar.GetUnitDebuff("target", 13552, "player")
T:RegisterCondition('target.debuff', { type = 'boolean', arg = true }, function(state, args)
    local result = T.GetUnitDebuff("target", tonumber(args), "player");
    return result;
end);

T:RegisterCondition('target.debuff.count', { type = 'compare', arg = true }, function(state, args)
    local result = select(2, T.GetUnitDebuff("target", tonumber(args), "player"));
    return result;
end);

T:RegisterCondition('target.debuff.duration', { type = 'compare', arg = true }, function(state, args)
    local result = select(3, T.GetUnitDebuff("target", tonumber(args), "player"));
    return result;
end);

T:RegisterCondition('haspet', { type = 'boolean', arg = false }, function(state, args)
    return UnitExists("pet") and UnitHealth("pet") > 0;
end);

-- /dump Pulsar.HasRune(415076)
T:RegisterCondition('hasrune', { type = 'boolean', arg = true }, function(state, args)
    return T.HasRune(args);
end);

T:RegisterCondition('target.isrange', { type = 'boolean', arg = true }, function(state, args)
    local spell = T.SpellInfo:New(tonumber(args) or 0, "");
    spell:Update();
    return spell:IsInRange();
end);

T:RegisterCondition('aoe', { type = 'boolean', arg = true }, function(state, args)
    return T.GetToogle("Pulsar_ControlPanel_AoeButton");
end);

T:RegisterCondition('cd', { type = 'boolean', arg = false }, function(state, args)
    return T.GetToogle("Pulsar_ControlPanel_CDButton");
end);
