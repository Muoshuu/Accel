local httpService = game:GetService('HttpService')
local textService = game:GetService('TextService')

local INF_VECTOR_2, textCache = Vector2.new(math.huge, math.huge), {}

local original, string = string, {
    guid = function(...)
        return httpService:GenerateGUID(...)
    end,

    derivedId = function(length, ...)
        return httpService:GenerateGUID(...):gsub('-', ''):sub(-(length or 16))
    end,

    trim = function(self)
        return self:match('^()%s*$') and '' or self:match('^%s*(.*%S)')
    end,

    reverse = function(self)
        local char, result = utf8.char, ''

        for _, point in utf8.codes(self) do
            result = char(point) .. result
        end

        return result
    end,

    width = function(self, font, size)
        local len = utf8.len(self)

        if len == 1 then
            local key = tostring(font) .. tostring(size)
            local width = textCache[key]

            if not width then
                width = textService:GetTextSize(self, size, font, INF_VECTOR_2).X

                textCache[key] = width
            end

            return width
        else
            return textService:GetTextSize(self, size, font, INF_VECTOR_2).X
        end
    end
}

for k, v in pairs(original) do
    string[k] = string[k] or v
end

return string