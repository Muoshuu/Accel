--!strict

local Promise = require(script.Parent.Parent.Utility.Promise)

local textService = game:GetService('TextService')

type TextFilterResultWrapper = {
	instance: TextFilterResult,

	forChat: (TextFilterResultWrapper, toUserId: number) -> Promise.Promise<string, (string)>,
	forBroadcast: (TextFilterResultWrapper) -> Promise.Promise<string, (string)>,
	forUser: (TextFilterResultWrapper, toUserId: number) -> Promise.Promise<string, (string)>
}

local function getChatForUser(self: TextFilterResultWrapper, toUserId: number): Promise.Promise<string, (string)>
	return Promise.defer(function(resolve, reject)
		local success, str = xpcall(function()
			return self.instance:GetChatForUserAsync(toUserId)
		end, function(err: string)
			reject(err)
		end)
		
		if success then
			resolve(str)
		end
	end)
end

local function getNonChatForUser(self: TextFilterResultWrapper, toUserId: number): Promise.Promise<string, (string)>
	return Promise.defer(function(resolve, reject)
		local success, str = xpcall(function()
			return self.instance:GetNonChatStringForUserAsync(toUserId)
		end, function(err: string)
			reject(err)
		end)

		if success then
			resolve(str)
		end
	end)
end

local function getNonChatForBroadcast(self: TextFilterResultWrapper): Promise.Promise<string, (string)>
	return Promise.defer(function(resolve, reject)
		local success, str = xpcall(function()
			return self.instance:GetNonChatStringForBroadcastAsync()
		end, function(err: string)
			reject(err)
		end)

		if success then
			resolve(str)
		end
	end)
end

local function getFilterWrapper(filterResult: TextFilterResult): TextFilterResultWrapper
	local this = {
		instance = filterResult,

		forChat = getChatForUser,
		forBroadcast = getNonChatForBroadcast,
		forUser = getNonChatForUser
	}

	return this
end

function filter(str: string, fromUserId: number, context: Enum.TextFilterContext?): Promise.Promise<(TextFilterResultWrapper), (string)>
	return Promise.defer(function(resolve, reject)
		local success, wrapper = xpcall(function()
			return getFilterWrapper(textService:FilterStringAsync(str, fromUserId, context))
		end, function(err: string)
			reject(err)
		end)

		if success then
			resolve(wrapper)
		end
	end)
end

return filter