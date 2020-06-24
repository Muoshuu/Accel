return function(import)
    local class = import 'Class'
    
    local HttpResponse = class.new('HttpRessponse') do
        function HttpResponse:init(robloxHttpResponse)
            self.success = robloxHttpResponse.Success
            self.statusCode = robloxHttpResponse.StatusCode
            self.statusMessage = robloxHttpResponse.StatusMessage
            self.headers = robloxHttpResponse.Headers
            self.body = robloxHttpResponse.Body
        end
    end

    return HttpResponse
end