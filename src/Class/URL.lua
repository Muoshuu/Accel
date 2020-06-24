return function(import)
    local class = import 'Class'
    local httpService = import 'HttpService'

    local legal = {
        ['-'] = true, ['_'] = true, ['.'] = true, ['!'] = true,
        ['~'] = true, ['*'] = true, ["'"] = true, ['('] = true,
        [')'] = true, [':'] = true, ['@'] = true, ['&'] = true,
        ['='] = true, ['+'] = true, ['$'] = true, [','] = true,
        [';'] = true
    }

    local function decode(str, isPath)
        if not isPath then
            str = str:gsub('+', ' ')
        end

        return str:gsub('%%(%x%x)', function(c)
            return string.char(tonumber(c, 16))
        end)
    end

    local function encode(str)
        return httpService:UrlEncode(str)
    end

    local function encodeSegment(str)
        return str:gsub('([^a-zA-Z0-9])', function(c)
            if legal[c] then
                return c
            end

            return encode(c)
        end)
    end

    local URL = class.new('URL') do
        function URL:init(url)
            if type(url) == 'string' then
                url = tostring(url or '')

                url = url:gsub('#(.*)$', function(v)
                    self.fragment = v

                    return ''

                end):gsub('^([%w][%w%+%-%.]*)%:', function(v)
                    self.scheme = v:lower();
                    
                    return ''

                end):gsub('%?(.*)', function(query) -- query
                    self.queryString = query

                    local values = {}

                    for k, v in query:gmatch(string.format('([^%q=]+)(=*[^%q=]*)', '&', '&')) do
                        local keys = {}

                        k = decode(k):gsub('%[([^%]]*)%]', function(val)
                            if string.find(val, '^-?%d+$') then
                                val = tonumber(val)
                            else
                                val = decode(val)
                            end

                            table.insert(keys, val)

                            return '='

                        end):gsub('=+.*$', ''):gsub('%s', '_')

                        v = v:gsub('^=+', '')

                        if not values[k] then
                            values[k] = {}
                        end

                        if #keys > 0 and type(values[k]) ~= 'table' then
                            values[k] = {}
                        elseif #keys == 0 and type(values[k]) == 'table' then
                            values[k] = decode(v)
                        end

                        local t = values[k]

                        for i, key in ipairs(keys) do
                            if type(t) ~= 'table' then
                                t = {}
                            end

                            if key == '' then
                                key = #t+1
                            end

                            if not t[key] then
                                t[key] = {}
                            end

                            if i == #keys then
                                t[key] = decode(v)
                            end

                            t = t[key]
                        end
                    end

                    self.query = values

                    return ''
                end):gsub('^//([^/]*)', function(authority) -- authority
                    self.authority = authority

                    authority = authority:gsub('^([^@]*)@', function(v)
                        self.userInfo = v
                        return ''
                    end):gsub('^%[[^%]]+%]', function(v)
                        self.host = v
                        return ''
                    end):gsub(':([^:]*)$', function(v)
                        self.port = tonumber(v)
                        return ''
                    end)

                    if authority ~= '' and not self.host then
                        self.host = authority:lower()
                    end

                    if self.userInfo then
                        self.user = self.userInfo:gsub(':([^:]*)$', function(v)
                            self.pass = v
                            return ''
                        end)
                    end

                    return ''
                end)

                self.path = decode(url, true)
            elseif type(url) == 'table' then
                for i, v in pairs(url) do
                    self[i] = v
                end
            end

            local urlString = '' do
                urlString = urlString .. self.path:gsub('([^/]+)', encodeSegment)

                if self.query then
                    urlString = urlString .. '?' .. self.queryString
                end

                if self.host then
                    local authority = self.host

                    if (self.port) and (self.port ~= 80) and (self.port ~= 443) then
                        authority = authority .. ':' .. self.port
                    end

                    local userInfo; do
                        if self.user and self.user ~= '' then
                            userInfo = self.user

                            if self.pass then
                                userInfo = userInfo .. ':' .. self.pass
                            end
                        end
                    end

                    if userInfo and userInfo ~= '' then
                        authority = userInfo .. '@' .. authority
                    end

                    if urlString == '' then
                        urlString = '//' .. authority
                    else
                        urlString = '//' .. authority .. '/' .. urlString:gsub('^/+', '')
                    end
                end

                if self.scheme then
                    urlString = self.scheme .. ':' .. urlString
                end

                if self.fragment then
                    urlString = urlString .. '#' .. self.fragment
                end
            end

            self.urlStr = urlString
        end

        do -- // Meta
            URL.meta.tostring = function(self)
                return self.urlStr
            end
        end
    end

    return URL
end