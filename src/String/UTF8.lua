--!strict

local UTF8 = {}

for key, value in pairs(utf8) do
	UTF8[key] = value
end

local LOWER_MAP, UPPER_MAP;

function UTF8.upper(str: string): string
	str = str:upper()

	local upperStr = ''

	for start, stop in utf8.graphemes(str) do
		local grapheme = str:sub(start, stop)

		if UPPER_MAP[grapheme] then
			grapheme = UPPER_MAP[grapheme]
		end

		upperStr ..= grapheme
	end

	return upperStr
end

function UTF8.lower(str: string): string
	str = str:upper()

	local lowerStr = ''

	for start, stop in utf8.graphemes(str) do
		local grapheme = str:sub(start, stop)

		if LOWER_MAP[grapheme] then
			grapheme = LOWER_MAP[grapheme]
		end

		lowerStr ..= grapheme
	end

	return lowerStr
end

function UTF8.reverse(str: string): string
	local result = ''

	for _, point in utf8.codes(str) do
		result = utf8.char(point) .. result
	end

	return result
end

LOWER_MAP, UPPER_MAP = {}, {
	['à'] = 'À',
	['á'] = 'Á',
	['â'] = 'Â',
	['ã'] = 'Ã',
	['ä'] = 'Ä',
	['å'] = 'Å',
	['æ'] = 'Æ',
	['ç'] = 'Ç',
	['è'] = 'È',
	['é'] = 'É',
	['ê'] = 'Ê',
	['ë'] = 'Ë',
	['ì'] = 'Ì',
	['í'] = 'Í',
	['î'] = 'Î',
	['ï'] = 'Ï',
	['ð'] = 'Ð',
	['ñ'] = 'Ñ',
	['ò'] = 'Ò',
	['ó'] = 'Ó',
	['ô'] = 'Ô',
	['õ'] = 'Õ',
	['ö'] = 'Ö',
	['ø'] = 'Ø',
	['ù'] = 'Ù',
	['ú'] = 'Ú',
	['û'] = 'Û',
	['ü'] = 'Ü',
	['ý'] = 'Ý',
	['þ'] = 'Þ',
	['ā'] = 'Ā',
	['ă'] = 'Ă',
	['ą'] = 'Ą',
	['ć'] = 'Ć',
	['ĉ'] = 'Ĉ',
	['ċ'] = 'Ċ',
	['č'] = 'Č',
	['ď'] = 'Ď',
	['đ'] = 'Đ',
	['ē'] = 'Ē',
	['ĕ'] = 'Ĕ',
	['ė'] = 'Ė',
	['ę'] = 'Ę',
	['ě'] = 'Ě',
	['ĝ'] = 'Ĝ',
	['ğ'] = 'Ğ',
	['ġ'] = 'Ġ',
	['ģ'] = 'Ģ',
	['ĥ'] = 'Ĥ',
	['ħ'] = 'Ħ',
	['ĩ'] = 'Ĩ',
	['ī'] = 'Ī',
	['ĭ'] = 'Ĭ',
	['į'] = 'Į',
	['ı'] = 'İ',
	['ĳ'] = 'Ĳ',
	['ĵ'] = 'Ĵ',
	['ķ'] = 'Ķ',
	['ĺ'] = 'Ĺ',
	['ļ'] = 'Ļ',
	['ľ'] = 'Ľ',
	['ŀ'] = 'Ŀ',
	['ł'] = 'Ł',
	['ń'] = 'Ń',
	['ņ'] = 'Ņ',
	['ň'] = 'Ň',
	['ŋ'] = 'Ŋ',
	['ō'] = 'Ō',
	['ŏ'] = 'Ŏ',
	['ő'] = 'Ő',
	['œ'] = 'Œ',
	['ŕ'] = 'Ŕ',
	['ŗ'] = 'Ŗ',
	['ř'] = 'Ř',
	['ś'] = 'Ś',
	['ŝ'] = 'Ŝ',
	['ş'] = 'Ş',
	['š'] = 'Š',
	['ţ'] = 'Ţ',
	['ť'] = 'Ť',
	['ŧ'] = 'Ŧ',
	['ũ'] = 'Ũ',
	['ū'] = 'Ū',
	['ŭ'] = 'Ŭ',
	['ů'] = 'Ů',
	['ű'] = 'Ű',
	['ų'] = 'Ų',
	['ŵ'] = 'Ŵ',
	['ŷ'] = 'Ŷ',
	['ÿ'] = 'Ÿ',
	['ź'] = 'Ź',
	['ż'] = 'Ż',
	['ž'] = 'Ž',
	['ſ'] = 'ſ',
	['ƀ'] = 'Ɓ',
	['ƃ'] = 'Ƃ',
	['ƅ'] = 'Ƅ',
	['ƈ'] = 'Ƈ',
	['ƌ'] = 'Ƌ',
	['ƒ'] = 'Ƒ',
	['ƙ'] = 'Ƙ',
	['ƣ'] = 'Ƣ',
	['ơ'] = 'Ơ'
}

for lower, upper in pairs(UPPER_MAP) do
	LOWER_MAP[upper] = lower
end

UTF8.CHAR_PATTERN = utf8.charpattern
UTF8.UPPER_MAP = UPPER_MAP
UTF8.LOWER_MAP = LOWER_MAP

return UTF8 :: typeof(UTF8) & typeof(utf8)