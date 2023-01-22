local _, T = ...;

function T.assert(flag, formatter, ...)
    if not flag then
        error(format(formatter, ...), 0);
    end
    return flag;
end

function T.ParseID(value)
    return type(value) == 'string' and tonumber(value:match(':(%d+)$')) or nil;
end

function T.ParseQuote(str)
    local major, quote = str:match('^([^()]+)%((.+)%)$')
    if major then
        return major, T.ParseID(quote) or quote;
    end
    return str, nil;
end