return function(import, class)
    local httpService = import 'HttpService'

    local Promise = import 'Class/Promise'
    local URL = import 'Class/URL'

    local HttpResponse = import './HttpResponse'

    local function buildQuery(query)
        if (type(query) == 'table') then
            local str = ''

            for i,v  in pairs(query) do
                str = str .. '&' .. i .. '=' .. v
            end

            return (str:gsub('^&', '?'))
        elseif (type(query) == 'string') then
            return query
        end
    end

    local function buildURL(request)
        return URL.new(('%s://%s%s:%d%s%s'):format(
            request.protocol,
            (request.auth and request.auth .. '@') or '',
            request.host or 'localhost',
            request.port,
            request.path or '/',
            (request.query and buildQuery(request.query)) or '')
        )
    end

    local HttpRequest = class.new('HttpRequest') do
        function HttpRequest:init(options, body)
            self.auth = options.auth
            self.headers = options.headers or {}
            self.host = options.host or 'localhost'
            self.method = options.method or 'GET'
            self.path = options.path or '/'
            self.port = options.port or options.protocol == 'http' and 80 or options.protocol == 'https' and 443 or not options.protocol and 443
            self.protocol = options.protocol or self.port == 80 and 'http' or self.port == 443 and 'https'
            --self.timeout = options.timeout or 30
            self.query = options.query or {}
            self.body = body or options.body
        end

        do -- // Prototype
            function HttpRequest.prototype:getUrl()
                return buildURL(self)
            end

            function HttpRequest.prototype:execute()
                return Promise.async(function(resolve, reject)
                    local success, rbxResponse = pcall(httpService.RequestAsync, httpService, {
                        Url = tostring(self.url),
                        Method = self.method,
                        Headers = self.headers,
                        Body = self.body
                    })

                    if (success) then
                        resolve(HttpResponse.new(rbxResponse))
                    else
                        reject(rbxResponse)
                    end
                end)
            end
        end
    end

    return HttpRequest
end