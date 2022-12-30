--[[
    Absurdly fast Base64 encoding & decoding library.

    Note: Base64 efficiency is 75%, which means for every
    3 characters encoded, 1 additional character is added.
]]

local Base64 = {} do
	local MAP, ALPHABET = {}, {
		[0] =

		0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, -- A B C D E F G H
		0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50, -- I J K L M N O P
		0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, -- Q R S T U V W X
		0x59, 0x5A, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, -- Y Z a b c d e f
		0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, -- g h i j k l m n
		0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, -- o p q r s t u v
		0x77, 0x78, 0x79, 0x7A, 0x30, 0x31, 0x32, 0x33, -- w x y z 0 1 2 3
		0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x2B, 0x2F, -- 4 5 6 7 8 9 + /

		0x3D -- =
	}

	for i, byte in pairs(ALPHABET) do
		MAP[byte] = i
	end

	function Base64.encode(input)
		local length, output = #input, {}
		local paddingBytes = length%3

		for i = 1, length-paddingBytes, 3 do
			local byte1, byte2, byte3 = input:byte(i, i+2)
			local v = byte1 * 65536 + byte2 * 256 + byte3

			table.insert(output, string.char(
				ALPHABET[bit32.extract(v, 18, 6)],
				ALPHABET[bit32.extract(v, 12, 6)],
				ALPHABET[bit32.extract(v, 6, 6)],
				ALPHABET[bit32.extract(v, 0, 6)]
			))
		end

		if paddingBytes == 2 then
			local byte1, byte2 = input:byte(length-1, length)
			local v = byte1 * 65536 + byte2 * 256

			table.insert(output, string.char(
				ALPHABET[bit32.extract(v, 18, 6)],
				ALPHABET[bit32.extract(v, 12, 6)],
				ALPHABET[bit32.extract(v, 6, 6)],
				ALPHABET[64]
			))
		elseif paddingBytes == 1 then
			local v = input:byte(length) * 65536

			table.insert(output, string.char(
				ALPHABET[bit32.extract(v,18,6)],
				ALPHABET[bit32.extract(v,12,6)],
				ALPHABET[64], ALPHABET[64]
			))
		end

		return table.concat(output)
	end

	function Base64.decode(input)
		input = input:gsub('[^%w%+%/%=]', '')

		local length, output = #input, {}
		local padding = input:sub(-2) == '==' and 2 or input:sub(-1) == '=' and 1 or 0

		for i = 1, padding > 0 and length-4 or length, 4 do
			local byte1, byte2, byte3, byte4 = input:byte(i, i+3)
			local v = MAP[byte1] * 262144 + MAP[byte2] * 4096 + MAP[byte3] * 64 + MAP[byte4]

			table.insert(output, string.char(
				bit32.extract(v, 16, 8),
				bit32.extract(v, 8, 8),
				bit32.extract(v, 0, 8)
			))
		end

		if padding == 1 then
			local byte1, byte2, byte3 = input:byte(length-3, length-1)
			local v = MAP[byte1] * 262144 + MAP[byte2] * 4096 + MAP[byte3] * 64

			table.insert(output, string.char(
				bit32.extract(v, 16, 8),
				bit32.extract(v, 8, 8)
			))
		elseif padding == 2 then
			local byte1, byte2 = input:byte(length-3, length-2)
			local v = MAP[byte1] * 262144 + MAP[byte2] * 4096

			table.insert(output, string.char(
				bit32.extract(v, 16, 8)
			))
		end

		return table.concat(output)
	end
end

return table.freeze(Base64)