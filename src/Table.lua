local httpService = game:GetService('HttpService')

local function safeIndex(object, key)
    local success, value = pcall(function()
        return object[key]
    end)

    if success then
        return value
    end
end

local original, table = table, nil; table = {
    from = function(...)
        return {...}
    end,

    toJSON = function(...)
        return httpService:JSONEncode(...)
    end,

    fromJSON = function(...)
        return httpService:JSONDecode(...)
    end,

    clone = function(self, isShallow)
        local t = {}

        if isShallow then
            for k, v in pairs(self) do
                t[k] = v
            end
        else
            for k, v in pairs(self) do
                k = type(k) == 'table' and table.clone(k) or k
                v = type(v) == 'table' and table.clone(v) or v

                t[k] = v
            end
        end

        return t
    end,

    wipe = function(self, metaAsWell)
        if metaAsWell then
            setmetatable(self, nil)
        end

        for k in pairs(self) do
            self[k] = nil
        end
    end,

    push = function(self, ...)
        for i = 1, select('#', ...) do
            self[#self+1] = select(i, ...)
        end

        return self
    end,

    pop = function(self)
        return table.remove(self, #self)
    end,

    shift = function(self)
        return table.remove(self, 1)
    end,

    unshift = function(self, ...)
        for i = 1, select('#', ...) do
            table.insert(self, 1, (select(i, ...)))
        end

        return #self
    end,

    indexOf = function(self, value)
        for i, v in pairs(self) do
            if v == value then
                return i
            end
        end
    end,

    indicesOf = function(self, value)
        local t = {}

        for i, v in pairs(self) do
            if v == value then
                t[#t+1] = i
            end
        end

        return t
    end,

    find = function(self, key, value)
        for k, v in pairs(self) do
            if safeIndex(v, key) == value then
                return v, k
            end
        end
    end,

    findAll = function(self, key, value, usePairs)
        local t = {}

        for k, v in pairs(self) do
            if safeIndex(v, key) == value then
                if usePairs then
                    t[#t+1] = { v, k }
                else
                    t[#t+1] = v
                end
            end
        end

        return t
    end,

    includes = function(self, value)
        return table.indexOf(self, value) ~= nil
    end,

    keys = function(self)
        local t = {}

        for k in pairs(self) do
            t[#t+1] = k
        end

        return t
    end,

    values = function(self)
        local t = {}

        for _, v in pairs(self) do
            t[#t+1] = v
        end

        return t
    end,

    reverse = function(self)
        for i = 1, math.floor(#self/2) do
            self[i], self[#self-i+1] = self[#self-i+1], self[i]
        end

        return self
    end,

    reversed = function(self)
        local t = {}

        for i = #self, 1, -1 do
            t[#t+1] = self[i]
        end

        return t
    end,

    map = function(self, fn)
        local t = {}

        for k, v in pairs(self) do
            t[k] = fn(v, k)
        end

        return t
    end,

    remap = function(self, fn)
        for k, v in pairs(self) do
            self[k] = fn(v, k)
        end
    end,

    filter = function(self, fn)
        local t = {}

        for i, v in pairs(self) do
            if fn(v, i) then
                t[#t+1] = v
            end
        end

        return t
    end,

    forEach = function(self, fn)
        for i, v in pairs(self) do
            fn(v, i)
        end
    end,

    expel = function(self, term)
        local index = 1

        while index <= #self do
            if self[index] == term then
                table.remove(self, index)
            else
                index += 1
            end
        end
    end,

    fromPages = function(pages, modifier)
        local list = {}

        while true do
            for i, object in pairs(pages:GetCurrentPage()) do
                if (modifier) then
                    table.insert(list, modifier(object, i))
                else
                    table.insert(list, object)
                end
            end

            if pages.IsFinished then
                break
            end

            pages:AdvanceToNextPageAsync()
        end

        return list
    end
}

for k, v in pairs(original) do
    table[k] = table[k] or v
end

return table