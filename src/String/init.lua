--!strict

type Iterator<T...> = (...any) -> T...

local CANVAS, CACHE = Vector2.new(1/0, 1/0), {}
local DEFAULT_CHARACTER_SET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

local LINE_PATTERN = '(.-)[\n\r]+'

local String = {} do
	local httpService = game:GetService('HttpService')
	local textService = game:GetService('TextService')

	local random = Random.new()

	local base64 = require(script.Parent.Utility.Serialization.Base64)

	local filter = require(script.Filter)
	local utf8_ext = require(script.UTF8)

	local Promise = require(script.Parent.Utility.Promise)

	String.utf8 = utf8_ext
	String.filter = filter

	local function invert(str: string): string
		if str:match('^%l+$') ~= nil then
			return str:upper()
		end

		return str:lower()
	end

	local function iterator(thread: thread): any?
		local result = { coroutine.resume(thread) }

		if result[1] and #result > 1 then
			return table.unpack(result, 2)
		end

		return
	end

	function String.guid(wrapInCurlyBraces: boolean?): string
		return httpService:GenerateGUID(if wrapInCurlyBraces then true else false)
	end

	function String.random(length: number?, pool: string?): string
		local pool = pool or DEFAULT_CHARACTER_SET
		local output, max = {}, #pool

		for _ = 1, length or 16 do
			local n = random:NextInteger(1, max)

			table.insert(output, pool:sub(n, n))
		end

		return table.concat(output)
	end

	function String.trim(str: string): string
		local n = str:find('%S')

		return n and str:match('.*%S', n) or ''
	end

	function String.trimFront(str: string, pattern: string): string
		return str:gsub('^%s*(.-)%s*', '%1')
	end

	function String.count(str: string, pattern: string?): number
		if not pattern then
			return #str
		else
			local n = 0

			for _ in str:gmatch(pattern) do
				n += 1
			end

			return n
		end
	end

	function String.isEmpty(str: string?): boolean
		return type(str) ~= 'string' or str == '' or String.isWhitespace(str)
	end

	function String.isWhitespace(str: string): boolean
		return str:match('[%s]+') == str
	end

	function String.elipseLimit(str: string, limit: number): string
		if #str > limit then
			str = str:sub(1, limit-3) .. '...'
		end

		return str
	end

	function String.fromNumber(n: number | string): string
		local find: any = string.find

		local i, j, minus, int, fraction = find(tostring(n), '([-]?)(%d+)([.]?%d*)')

		int = int:reverse():gsub('(%d%d%d)', '%1,')

		return minus .. int:reverse():gsub('^,', '') .. fraction
	end

	function String.pad(str: string, character: string, length: number, atEnd: boolean?): string
		if atEnd then
			return str .. character:rep(#str-length)
		else
			return character:rep(#str-length) .. str
		end
	end

	function String.width(str: string, font: Font, fontSize: number): number
		local len = utf8.len(str)

		if len == 1 then
			local fontCache = CACHE[font]

			if not fontCache then
				fontCache = {}

				CACHE[font] = fontCache
			end

			local characterCache = fontCache[str]

			if not characterCache then
				characterCache = {}

				fontCache[str] = characterCache
			end

			local width = characterCache[fontSize]

			if not width then
				width = textService:GetTextSize(str, fontSize, font, CANVAS).X

				characterCache[fontSize] = width
			end

			return width
		else
			return textService:GetTextSize(str, fontSize, font, CANVAS).X
		end
	end

	function String.toPascalCase(str: string): string
		return (str:lower():gsub('[ _](%a)', string.upper):gsub('%a', string.upper):gsub('%p', ''))
	end

	function String.toCamelCase(str: string): string
		return (str:lower():gsub('[ _](%a)', string.upper):gsub('%a', string.lower):gsub('%p', ''))
	end

	function String.toPrivateCase(str: string): string
		return '_' .. str:sub(1,1):lower() .. str:sub(2, #str)
	end

	function String.lowerFirst(str: string): string
		return (str:gsub('^.', string.lower))
	end

	function String.upperFirst(str: string): string
		return (str:gsub('^%a', string.upper))
	end

	function String.insert(str: string, addition: string, index: number): string
		index = (index < 0 and index + 1 or index) % (#str + 1)

		if index == 1 then
			return addition .. str
		elseif index == 0 then
			return str .. addition
		else
			return str:sub(1, index-1) .. addition .. str:sub(index)
		end
	end

	function String.isLower(str: string): boolean
		return str:match('^%l+$') ~= nil
	end

	function String.isUpper(str: string): boolean
		return str:match('^%u$') ~= nil
	end

	function String.invert(str: string): string
		return (str:gsub('%a', invert))
	end

	function String.lines(str: string)
		return iterator :: Iterator<number, string>, coroutine.create(function()
			local index = 0

			for line in (str .. '\n'):gmatch(LINE_PATTERN) do
				index += 1

				coroutine.yield(index, line)
			end
		end)
	end

	function String.getLines(str: string): { string }
		local lines = {}

		for line in (str .. '\n'):gmatch(LINE_PATTERN) do
			table.insert(lines, line)
		end

		return lines
	end

	function String.characters(str: string)
		return iterator :: Iterator<number, string>, coroutine.create(function()
			for i = 1, #str do
				coroutine.yield(i, str:sub(i,i))
			end
		end)
	end

	function String.getCharacters(str: string): { string }
		return string.split(str, '')
	end

	function String.bytes(str: string)
		return iterator :: Iterator<number, string>, coroutine.create(function()
			for i = 1, #str do
				coroutine.yield(i, str:byte(i,i))
			end
		end)
	end

	function String.getBytes(str: string): { number }
		return { string.byte(str, 1, -1) }
	end
	
	function String.getOrdinalOf(n: number): string
		local r1 = n%10
		local r2 = n%100

		if r2 < 10 or r2 > 20 then
			if r1 == 1 then
				return 'st'
			elseif r1 == 2 then
				return 'nd'
			elseif r1 == 3 then
				return 'rd'
			end
		end

		return 'th'
	end
end

return table.freeze(String)