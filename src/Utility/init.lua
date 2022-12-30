--!strict

--[[
    Debris
    CollectionService
    TextService
    TweenService
    PhysicsService
    PathfindingService
    Stats
]]

local runService = game:GetService('RunService')
local starterGui = game:GetService('StarterGui')

local Utility = {}

local Promise = require(script.Promise)
local Signal = require(script.Signal)

Utility.Compression = require(script.Compression)
Utility.Crypto = require(script.Crypto)
Utility.Draw = require(script.Draw)
Utility.Maid = require(script.Maid)

Utility.Promise = Promise
Utility.Signal = Signal

Utility.Serialization = require(script.Serialization)
Utility.Timer = require(script.Timer)
Utility.Create = require(script.Create)

local symbols = {}

Utility.Symbol = function(name: string): { 'Symbol' }
	if symbols[name] then
		return symbols[name]
	else
		local this = newproxy(true)

		symbols[name] = this

		name = ('Symbol: %s'):format(name)

		getmetatable(this).__tostring = function()
			return name
		end

		-- This doesn't work yet but might eventually
		-- https://github.com/Roblox/luau/issues/351
		getmetatable(this).__type = 'Symbol'

		return this
	end
end

Utility.readPages = function<T>(pages: Pages, modifier: ((any, number) -> T)?): Promise.Promise<{ T }, (string)>
	return Promise.defer(function(resolve, reject)
		local list = {}

		while true do
			local ok, page = pcall(pages.GetCurrentPage, pages)

			if not ok then
				return resolve(list)
			end

			for i, object in pairs(page) do
				if modifier then
					object = modifier(object, i)
				end

				table.insert(list, object)
			end

			if pages.IsFinished then
				break
			end

			local ok = pcall(pages.AdvanceToNextPageAsync, pages)

			if not ok then
				return resolve(list)
			end
		end

		resolve(list)
	end)
end

Utility.bind = function<O, T..., R...>(fn: (O, T...) -> R..., object: O)
	return function(...: T...)
		return fn(object, ...)
	end
end

Utility.getterSetterMeta = {
	__index = function(self: any, key: string)
		local fn = rawget(self, 'get' .. key:gsub('^.', string.upper))

		if fn then
			return fn()
		else
			key = (self._proxy[key] or key):gsub('^*', 'Get')
			
			local val = self.Instance[key]
			
			if typeof(val) == 'function' then
				return val(self.Instance)
			else
				return val
			end
		end
	end,

	__newindex = function(self: any, key: string, value: any)
		local fn = rawget(self, 'set' .. key:gsub('^.', string.upper))

		if fn then
			return fn(value)
		else
			key = (self._proxy[key] or key):gsub('^*', 'Set')
			
			local val = self.Instance[key]
			
			if typeof(val) == 'function' then
				val(self.Instance, value)
			else
				self.Instance[key] = value
			end
		end
	end
}

local InvertSymbol = Utility.Symbol('Invert')

function Utility.attemptCoreMethod(mode: 'Get' | 'Set', key: string, value: any?, maxAttempts: number?): Promise<boolean, any, (nil)>
	local maxAttempts = maxAttempts or 10
	
	return Promise.defer(function(resolve, reject)
		local ok, val = pcall(function()
			if value == InvertSymbol then
				value = not starterGui:GetCore(key)
			end
			
			return starterGui[mode .. 'Core'](starterGui, key, value)
		end)
		
		if ok then
			resolve(true, val)
		else
			if maxAttempts > 1 then
				task.wait()

				return Utility.attemptCoreMethod(mode, key, value, maxAttempts-1):Then(resolve)
			else
				resolve(false, val)
			end
		end
	end)
end

export type Promise<T..., R...> = Promise.Promise<T..., (R...)>
export type Signal<T...> = Signal.Signal<T...>
export type Connection<T...> = Signal.Connection<T...>

return Utility