--!strict

type Table<kT, vT> = { [kT]: vT }
type Iterator<T...> = (...any) -> T...

local Table = {} do
	local httpService = game:GetService('HttpService')

	local random = Random.new()

	local function safeCompare(object: any, key: any, value: any): boolean
		local ok, val = pcall(function()
			return object[key]
		end)

		return ok and (val == value)
	end

	local function iterator(thread: thread): any?
		local result = { coroutine.resume(thread) }

		if result[1] and #result > 1 then
			return table.unpack(result, 2)
		end

		return
	end
	
	for key, value in pairs(table) do
		Table[key] = value
	end

	function Table.toJSON<kT, vT>(tbl: Table<kT, vT>): string
		return httpService:JSONEncode(tbl)
	end

	function Table.fromJSON(str: string): Table<any, any>
		return httpService:JSONDecode(str)
	end

	function Table.push<T>(tbl: { T }, ...: T): number
		for i = 1, select('#', ...) do
			table.insert(tbl, select(i, ...))
		end

		return #tbl
	end

	function Table.pop<T>(tbl: { T }): T?
		return table.remove(tbl, #tbl)
	end

	function Table.shift<T>(tbl: { T }): T?
		return table.remove(tbl, 1)
	end

	function Table.unshift<T>(tbl: { T }, ...: T): number
		for i = 1, select('#', ...) do
			table.insert(tbl, 1, (select(i, ...)))
		end

		return #tbl
	end

	function Table.findAll<T>(tbl: { T }, value: T, init: number?): { number }
		local init: number = init or 1
		local indices = {}

		for index = (1 or init), #tbl do
			if tbl[index] == value then
				table.insert(indices, index)
			end
		end

		return indices
	end

	function Table.findWhere<oT, kT, vT>(tbl: { oT }, key: kT, value: vT): (oT?, number)
		for index, object in pairs(tbl) do
			if safeCompare(object, key, value) then
				return object, index
			end
		end

		return nil, 0/0 -- NaN
	end

	function Table.findAllWhere<oT, kT, vT>(tbl: { oT }, key: kT, value: vT): { { index: number, object: oT } }
		local objects = {}

		for index, object in pairs(tbl) do
			if safeCompare(object, key, value) then
				table.insert(objects, { index = index, object = object })
			end
		end

		return objects
	end

	function Table.includes<kT, vT>(tbl: Table<kT, vT>, value: vT): (boolean, number)
		local n = 0

		for key, val in pairs(tbl) do
			if val == value then
				n += 1
			end
		end

		return n > 0, n
	end

	function Table.keys<kT>(tbl: Table<kT, any>): { kT }
		local keys = {}

		for key in pairs(tbl) do
			table.insert(keys, key)
		end

		return keys
	end

	function Table.values<vT>(tbl: Table<any, vT>): { vT }
		local values = {}

		for _, value in pairs(tbl) do
			table.insert(values, value)
		end

		return values
	end

	function Table.reverse<T>(tbl: { T })
		for i = 1, math.floor(#tbl/2) do
			tbl[i], tbl[#tbl-i+1] = tbl[#tbl-i+1], tbl[i]
		end
	end

	function Table.reversed<T>(tbl: { T }): { T }
		local reversed = {}

		for index = #tbl, 1, -1 do
			table.insert(reversed, tbl[index])
		end

		return reversed
	end

	function Table.map<kT, vT, rT>(tbl: Table<kT, vT>, fn: (vT, kT) -> rT): Table<kT, rT>
		local map = {}

		for key, value in pairs(tbl) do
			map[key] = fn(value, key)
		end

		return map
	end

	function Table.remap<kT, vT>(tbl: Table<kT, vT>, fn: (vT, kT) -> vT)
		for key, value in pairs(tbl) do
			tbl[key] = fn(value, key)
		end
	end

	function Table.filter<kT, vT>(tbl: Table<kT, vT>, fn: (vT, kT) -> boolean): { vT }
		local filtered = {}

		for key, value in pairs(tbl) do
			if fn(value, key) == true then
				table.insert(filtered, value)
			end
		end

		return filtered
	end

	function Table.filterWithIndex<kT, vT>(tbl: Table<kT, vT>, fn: (vT, kT) -> boolean): { { index: kT, value: vT } }
		local filtered = {}

		for key, value in pairs(tbl) do
			if fn(value, key) == true then
				table.insert(filtered, { index = key, value = value })
			end
		end

		return filtered
	end

	function Table.expel<T>(tbl: { T }, value: T)
		for i = #tbl, 1, -1 do
			if tbl[i] == value then
				table.remove(tbl, i)
			end
		end
	end

	function Table.merge<kT, vT>(...: Table<kT, vT>)
		local host = select(1, ...)

		for _, tbl in pairs({ select(2, ...) }) do
			for key, value in pairs(tbl) do
				host[key] = value
			end
		end
	end

	function Table.merged<kT, vT>(...: Table<any, any>): Table<kT, vT>
		local host = {}

		for _, tbl in pairs({...}) do
			for key, value in pairs(tbl) do
				host[key] = value
			end
		end

		return host
	end
end

return table.freeze(Table)