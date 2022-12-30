local Color = {}

Color.new = Color3.new

Color.fromRGB = Color3.fromRGB
Color.fromHSV = Color3.fromHSV
Color.fromHex = Color3.fromHex

local toHSV = Color3.new().ToHSV

function Color.fromInt(int: number): Color3
	return Color3.fromRGB(math.floor(int/0x10000), math.floor(int/0x100)%0x100, int%0x100)
end

function Color.setHue(color3: Color3, hue: number): Color3
	local _, s, v = toHSV(color3)
	
	return Color3.fromHSV(hue, s, v)
end

function Color.setSaturation(color3: Color3, saturation: number): Color3
	local h, _, v = toHSV(color3)
	
	return Color3.fromHSV(h, saturation, v)
end

function Color.setValue(color3: Color3, value: number): Color3
	local h, s, _ = toHSV(color3)
	
	return Color3.fromHSV(h, s, value)
end

function Color.scaleSaturation(color3: Color3, scale: number): Color3
	local h, s, v = toHSV(color3)
	
	return Color3.fromHSV(h, s*scale, v)
end

function Color.scaleValue(color3: Color3, scale: number): Color3
	local h, s, v = toHSV(color3)
	
	return Color3.fromHSV(h, s, v*scale)
end

function Color.toInt(color3: Color3)
	return math.floor((0xFF0000 * color3.R + 0xFF00 * color3.G + 0xFF * color3.B) + 0.5)
end

Color.toHSV = Color3.new().ToHSV
Color.toHex = Color3.new().ToHex
	
function Color.toRGB(color3: Color3)
	return color3.R*255, color3.G*255, color3.B*255
end

function Color.unpack(color3: Color3)
	return color3.R, color3.G, color3.B
end

function Color.getRelativeLuminance(color3: Color3)
	local components = { Color.unpack(color3) }
	local values = {}
	
	for i, val in pairs(components) do
		if val <= 0.03928 then
			values[i] = val/12.92
		else
			values[i] = ((val+0.055)/1.055)^2.4
		end
	end
	
	return 0.2126*values[1]+0.7152*values[2]+0.0722*values[3]
end

function Color.textShouldBeBlack(backgroundColor: Color3)
	return Color.getRelativeLuminance(backgroundColor) > 0.179
end

function Color.invert(color3: Color3): Color3
	return Color3.new(1-color3.R, 1-color3.G, 1-color3.B)
end

-- 2014 Material Design Palette

Color.RED = {
	[50] = Color.fromRGB(255, 235, 238),
	[100] = Color.fromRGB(255, 205, 210),
	[200] = Color.fromRGB(239, 154, 154),
	[300] = Color.fromRGB(229, 115, 115),
	[400] = Color.fromRGB(239, 83, 80),
	[500] = Color.fromRGB(244, 67, 54),
	[600] = Color.fromRGB(229, 57, 53),
	[700] = Color.fromRGB(211, 47, 47),
	[800] = Color.fromRGB(198, 40, 40),
	[900] = Color.fromRGB(183, 28, 28),

	Accent = {
		[100] = Color.fromRGB(255, 138, 128),
		[200] = Color.fromRGB(255, 82, 82),
		[400] = Color.fromRGB(255, 23, 68),
		[700] = Color.fromRGB(213, 0, 0)
	}
}

Color.PINK = {
	[50] = Color.fromRGB(252, 228, 236),
	[100] = Color.fromRGB(248, 187, 208),
	[200] = Color.fromRGB(244, 143, 177),
	[300] = Color.fromRGB(240, 98, 146),
	[400] = Color.fromRGB(236, 64, 122),
	[500] = Color.fromRGB(233, 30, 99),
	[600] = Color.fromRGB(216, 27, 96),
	[700] = Color.fromRGB(194, 24, 91),
	[800] = Color.fromRGB(173, 20, 87),
	[900] = Color.fromRGB(136, 14, 79),

	ACCENT = {
		[100] = Color.fromRGB(255, 128, 171),
		[200] = Color.fromRGB(255, 64, 129),
		[400] = Color.fromRGB(245, 0, 87),
		[700] = Color.fromRGB(197, 17, 98)
	}
}

Color.PURPLE = {
	[50] = Color.fromRGB(243, 229, 245),
	[100] = Color.fromRGB(225, 190, 231),
	[200] = Color.fromRGB(206, 147, 216),
	[300] = Color.fromRGB(186, 104, 200),
	[400] = Color.fromRGB(171, 71, 188),
	[500] = Color.fromRGB(156, 39, 176),
	[600] = Color.fromRGB(142, 36, 170),
	[700] = Color.fromRGB(123, 31, 162),
	[800] = Color.fromRGB(106, 27, 154),
	[900] = Color.fromRGB(74, 20, 140),

	ACCENT = {
		[100] = Color.fromRGB(234, 128, 252),
		[200] = Color.fromRGB(224, 64, 251),
		[400] = Color.fromRGB(213, 0, 249),
		[700] = Color.fromRGB(170, 0, 255)
	}
}

Color.DEEP_PURPLE = {
	[50] = Color.fromRGB(237, 231, 246),
	[100] = Color.fromRGB(209, 196, 233),
	[200] = Color.fromRGB(179, 157, 219),
	[300] = Color.fromRGB(149, 117, 205),
	[400] = Color.fromRGB(126, 87, 194),
	[500] = Color.fromRGB(103, 58, 183),
	[600] = Color.fromRGB(94, 53, 177),
	[700] = Color.fromRGB(81, 45, 168),
	[800] = Color.fromRGB(69, 39, 160),
	[900] = Color.fromRGB(49, 27, 146),

	ACCENT = {
		[100] = Color.fromRGB(179, 136, 255),
		[200] = Color.fromRGB(124, 77, 255),
		[400] = Color.fromRGB(101, 31, 255),
		[700] = Color.fromRGB(98, 0, 234)
	}
}

Color.INDIGO = {
	[50] = Color.fromRGB(232, 234, 246),
	[100] = Color.fromRGB(197, 202, 233),
	[200] = Color.fromRGB(159, 168, 218),
	[300] = Color.fromRGB(121, 134, 203),
	[400] = Color.fromRGB(92, 107, 192),
	[500] = Color.fromRGB(63, 81, 181),
	[600] = Color.fromRGB(57, 73, 171),
	[700] = Color.fromRGB(48, 63, 159),
	[800] = Color.fromRGB(40, 53, 147),
	[900] = Color.fromRGB(26, 35, 126),

	ACCENT = {
		[100] = Color.fromRGB(140, 158, 255),
		[200] = Color.fromRGB(83, 109, 254),
		[400] = Color.fromRGB(61, 90, 254),
		[700] = Color.fromRGB(48, 79, 254)
	}
}

Color.BLUE = {
	[50] = Color.fromRGB(227, 242, 253),
	[100] = Color.fromRGB(187, 222, 251),
	[200] = Color.fromRGB(144, 202, 249),
	[300] = Color.fromRGB(100, 181, 246),
	[400] = Color.fromRGB(66, 165, 245),
	[500] = Color.fromRGB(33, 150, 243),
	[600] = Color.fromRGB(30, 136, 229),
	[700] = Color.fromRGB(25, 118, 210),
	[800] = Color.fromRGB(21, 101, 192),
	[900] = Color.fromRGB(13, 71, 161),

	ACCENT = {
		[100] = Color.fromRGB(130, 177, 255),
		[200] = Color.fromRGB(68, 138, 255),
		[400] = Color.fromRGB(41, 121, 255),
		[700] = Color.fromRGB(41, 98, 255)
	}
}

Color.LIGHT_BLUE = {
	[50] = Color.fromRGB(225, 245, 254),
	[100] = Color.fromRGB(179, 229, 252),
	[200] = Color.fromRGB(129, 212, 250),
	[300] = Color.fromRGB(79, 195, 247),
	[400] = Color.fromRGB(41, 182, 246),
	[500] = Color.fromRGB(3, 169, 244),
	[600] = Color.fromRGB(3, 155, 229),
	[700] = Color.fromRGB(2, 136, 209),
	[800] = Color.fromRGB(2, 119, 189),
	[900] = Color.fromRGB(1, 87, 155),

	ACCENT = {
		[100] = Color.fromRGB(128, 216, 255),
		[200] = Color.fromRGB(64, 196, 255),
		[400] = Color.fromRGB(0, 176, 255),
		[700] = Color.fromRGB(0, 145, 234)
	}
}

Color.CYAN = {
	[50] = Color.fromRGB(224, 247, 250),
	[100] = Color.fromRGB(178, 235, 242),
	[200] = Color.fromRGB(128, 222, 234),
	[300] = Color.fromRGB(77, 208, 225),
	[400] = Color.fromRGB(38, 198, 218),
	[500] = Color.fromRGB(0, 188, 212),
	[600] = Color.fromRGB(0, 172, 193),
	[700] = Color.fromRGB(0, 151, 167),
	[800] = Color.fromRGB(0, 131, 143),
	[900] = Color.fromRGB(0, 96, 100),

	ACCENT = {
		[100] = Color.fromRGB(132, 255, 255),
		[200] = Color.fromRGB(24, 255, 255),
		[400] = Color.fromRGB(0, 229, 255),
		[700] = Color.fromRGB(0, 184, 212)
	}
}

Color.TEAL = {
	[50] = Color.fromRGB(224, 242, 241),
	[100] = Color.fromRGB(178, 223, 219),
	[200] = Color.fromRGB(128, 203, 196),
	[300] = Color.fromRGB(77, 182, 172),
	[400] = Color.fromRGB(38, 166, 154),
	[500] = Color.fromRGB(0, 150, 136),
	[600] = Color.fromRGB(0, 137, 123),
	[700] = Color.fromRGB(0, 121, 107),
	[800] = Color.fromRGB(0, 105, 92),
	[900] = Color.fromRGB(0, 77, 64),

	ACCENT = {
		[100] = Color.fromRGB(167, 255, 235),
		[200] = Color.fromRGB(100, 255, 218),
		[400] = Color.fromRGB(29, 233, 182),
		[700] = Color.fromRGB(0, 191, 165)
	}
}

Color.GREEN = {
	[50] = Color.fromRGB(232, 245, 233),
	[100] = Color.fromRGB(200, 230, 201),
	[200] = Color.fromRGB(165, 214, 167),
	[300] = Color.fromRGB(129, 199, 132),
	[400] = Color.fromRGB(102, 187, 106),
	[500] = Color.fromRGB(76, 175, 80),
	[600] = Color.fromRGB(67, 160, 71),
	[700] = Color.fromRGB(56, 142, 60),
	[800] = Color.fromRGB(46, 125, 50),
	[900] = Color.fromRGB(27, 94, 32),

	ACCENT = {
		[100] = Color.fromRGB(185, 246, 202),
		[200] = Color.fromRGB(105, 240, 174),
		[400] = Color.fromRGB(0, 230, 118),
		[700] = Color.fromRGB(0, 200, 83)
	}
}

Color.LIGHT_GREEN = {
	[50] = Color.fromRGB(241, 248, 233),
	[100] = Color.fromRGB(220, 237, 200),
	[200] = Color.fromRGB(197, 225, 165),
	[300] = Color.fromRGB(174, 213, 129),
	[400] = Color.fromRGB(156, 204, 101),
	[500] = Color.fromRGB(139, 195, 74),
	[600] = Color.fromRGB(124, 179, 66),
	[700] = Color.fromRGB(104, 159, 56),
	[800] = Color.fromRGB(85, 139, 47),
	[900] = Color.fromRGB(51, 105, 30),

	ACCENT = {
		[100] = Color.fromRGB(204, 255, 144),
		[200] = Color.fromRGB(178, 255, 89),
		[400] = Color.fromRGB(118, 255, 3),
		[700] = Color.fromRGB(100, 221, 23)
	}
}

Color.LIME = {
	[50] = Color.fromRGB(249, 251, 231),
	[100] = Color.fromRGB(240, 244, 195),
	[200] = Color.fromRGB(230, 238, 156),
	[300] = Color.fromRGB(220, 231, 117),
	[400] = Color.fromRGB(212, 225, 87),
	[500] = Color.fromRGB(205, 220, 57),
	[600] = Color.fromRGB(192, 202, 51),
	[700] = Color.fromRGB(175, 180, 43),
	[800] = Color.fromRGB(158, 157, 36),
	[900] = Color.fromRGB(130, 119, 23),

	ACCENT = {
		[100] = Color.fromRGB(244, 255, 129),
		[200] = Color.fromRGB(238, 255, 65),
		[400] = Color.fromRGB(198, 255, 0),
		[700] = Color.fromRGB(174, 234, 0)
	}
}

Color.YELLOW = {
	[50] = Color.fromRGB(255, 253, 231),
	[100] = Color.fromRGB(255, 249, 196),
	[200] = Color.fromRGB(255, 245, 157),
	[300] = Color.fromRGB(255, 241, 118),
	[400] = Color.fromRGB(255, 238, 88),
	[500] = Color.fromRGB(255, 235, 59),
	[600] = Color.fromRGB(253, 216, 53),
	[700] = Color.fromRGB(251, 192, 45),
	[800] = Color.fromRGB(249, 168, 37),
	[900] = Color.fromRGB(245, 127, 23),

	ACCENT = {
		[100] = Color.fromRGB(255, 255, 141),
		[200] = Color.fromRGB(255, 255, 0),
		[400] = Color.fromRGB(255, 234, 0),
		[700] = Color.fromRGB(255, 214, 0)
	}
}

Color.AMBER = {
	[50] = Color.fromRGB(255, 248, 225),
	[100] = Color.fromRGB(255, 236, 179),
	[200] = Color.fromRGB(255, 224, 130),
	[300] = Color.fromRGB(255, 213, 79),
	[400] = Color.fromRGB(255, 202, 40),
	[500] = Color.fromRGB(255, 193, 7),
	[600] = Color.fromRGB(255, 179, 0),
	[700] = Color.fromRGB(255, 160, 0),
	[800] = Color.fromRGB(255, 143, 0),
	[900] = Color.fromRGB(255, 111, 0),

	ACCENT = {
		[100] = Color.fromRGB(255, 229, 127),
		[200] = Color.fromRGB(255, 215, 64),
		[400] = Color.fromRGB(255, 196, 0),
		[700] = Color.fromRGB(255, 171, 0)
	}
}

Color.ORANGE = {
	[50] = Color.fromRGB(255, 243, 224),
	[100] = Color.fromRGB(255, 224, 178),
	[200] = Color.fromRGB(255, 204, 128),
	[300] = Color.fromRGB(255, 183, 77),
	[400] = Color.fromRGB(255, 167, 38),
	[500] = Color.fromRGB(255, 152, 0),
	[600] = Color.fromRGB(251, 140, 0),
	[700] = Color.fromRGB(245, 124, 0),
	[800] = Color.fromRGB(239, 108, 0),
	[900] = Color.fromRGB(230, 81, 0),

	ACCENT = {
		[100] = Color.fromRGB(255, 209, 128),
		[200] = Color.fromRGB(255, 171, 64),
		[400] = Color.fromRGB(255, 145, 0),
		[700] = Color.fromRGB(255, 109, 0)
	}
}

Color.DEEP_ORANGE = {
	[50] = Color.fromRGB(251, 233, 231),
	[100] = Color.fromRGB(255, 204, 188),
	[200] = Color.fromRGB(255, 171, 145),
	[300] = Color.fromRGB(255, 138, 101),
	[400] = Color.fromRGB(255, 112, 67),
	[500] = Color.fromRGB(255, 87, 34),
	[600] = Color.fromRGB(244, 81, 30),
	[700] = Color.fromRGB(230, 74, 25),
	[800] = Color.fromRGB(216, 67, 21),
	[900] = Color.fromRGB(191, 54, 12),

	ACCENT = {
		[100] = Color.fromRGB(255, 158, 128),
		[200] = Color.fromRGB(255, 110, 64),
		[400] = Color.fromRGB(255, 61, 0),
		[700] = Color.fromRGB(221, 44, 0)
	}
}

Color.BROWN = {
	[50] = Color.fromRGB(239, 235, 233),
	[100] = Color.fromRGB(215, 204, 200),
	[200] = Color.fromRGB(188, 170, 164),
	[300] = Color.fromRGB(161, 136, 127),
	[400] = Color.fromRGB(141, 110, 99),
	[500] = Color.fromRGB(121, 85, 72),
	[600] = Color.fromRGB(109, 76, 65),
	[700] = Color.fromRGB(93, 64, 55),
	[800] = Color.fromRGB(78, 52, 46),
	[900] = Color.fromRGB(62, 39, 35),
}

Color.GREY = {
	[50] = Color.fromRGB(250, 250, 250),
	[100] = Color.fromRGB(245, 245, 245),
	[200] = Color.fromRGB(238, 238, 238),
	[300] = Color.fromRGB(224, 224, 224),
	[400] = Color.fromRGB(189, 189, 189),
	[500] = Color.fromRGB(158, 158, 158),
	[600] = Color.fromRGB(117, 117, 117),
	[700] = Color.fromRGB(97, 97, 97),
	[800] = Color.fromRGB(66, 66, 66),
	[900] = Color.fromRGB(33, 33, 33),
}

Color.BLUE_GREY = {
	[50] = Color.fromRGB(236, 239, 241),
	[100] = Color.fromRGB(207, 216, 220),
	[200] = Color.fromRGB(176, 190, 197),
	[300] = Color.fromRGB(144, 164, 174),
	[400] = Color.fromRGB(120, 144, 156),
	[500] = Color.fromRGB(96, 125, 139),
	[600] = Color.fromRGB(84, 110, 122),
	[700] = Color.fromRGB(69, 90, 100),
	[800] = Color.fromRGB(55, 71, 79),
	[900] = Color.fromRGB(38, 50, 56),
}

Color.BLACK = Color.new(0, 0, 0)
Color.WHITE = Color.new(1, 1, 1)

return Color