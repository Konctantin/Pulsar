local _, T = ...;

function T.assert(flag, formatter, ...)
    if not flag then
        error(string.format(formatter, ...), 0);
    end
    return flag;
end
