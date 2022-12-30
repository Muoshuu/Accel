--[[

 	Style Guide:

	- PascalCase: Property, Method, Class, Paths
	- camelCase: Function, Variable, Instance, Module
	- UPPER_SNAKE_CASE: Constant
	- _privateCase: Internal

	- A property/method is any variable linked specifically to an instance of a class
	- A static value in a class is NOT a property/method, but rather a variable/function
	- A variable/function is any value not specifically linked to an instance of a class
	- A constant is a value that never changes, such as an error message or digits of pi
	- A variable using _privateCase should never be used and is hidden from intellisense
 
	Originally, this module was meant to require every descendant, but Luau's typechecker
	seems to have a hard limit on type descriptors and considers the module "too complex"

	As an alternative, I've decided to use it to guarantee every module has loaded until the
	typechecker is more robust

	--------------------------------------------------------------------------------------------

	LICENSE:
	
	Copyright ⓒ 2022 Muoshuu

	Permission is hereby granted, free of charge, to any persons obtaining a copy
	of this Software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	1. This copyright and permissions notice shall be included without
	   modification with all substantial portions of the Software.

	2. The Software shall not be sold by itself without reasonable modification.

	3. The Software shall not be infringed upon (e.g., redistribution under a
	   different name without reasonable modification).

	4. The Software shall not be included with or modified to contain hidden,
	   harmful content or any content that does not follow the terms of use of
	   the Roblox game platform set forth by Roblox Corporation and found here:

	https://en.help.roblox.com/hc/en-us/articles/115004647846-Roblox-Terms-of-Use

	5. All modifications to the Software shall be registered in an accessible way
	   distributed with the derivative version (e.g. on GitHub as a fork of the
	   original repository of the Software).

	6. If included with closed-source Software or content, attribution shall be
	   explicitly given in a way accessible to end-users (e.g. the credits
	   section of a video game). The attribution must include the name of the
	   Software as well as the name or pseudonym of the author(s) who created it.

	THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
]]

--[[
local Inspect = require(script.Debug.Inspect)

local Table: any = {}

local recurse; recurse = function(item, fn)
	fn(item)

	for _, child in pairs(item:GetChildren()) do
		recurse(child, fn)
	end
end

recurse(script, function(item: Instance)
	if item == script then
		Table.Accel = {}
	else
		local path = item:GetFullName():gsub('.+Accel', 'Accel'):split('.')
		local tbl = Table

		for _, key in pairs(path) do
			if not tbl[key] then
				tbl[key] = {}
			end

			tbl = tbl[key]
		end
	end
end)

print(Inspect(Table.Accel))
]]

local tree = {
	Color = {},
	Debug = {
		Inspect = {}
	},
	Math = {
		Physics = {},
		Quaternion = {},
		Raycasting = {},
		Spring = {
			Module = {}
		},
		Vector = {}
	},
	Service = {
		Data = {
			DataStore = {}
		},
		Game = {
			Common = {}
		},
		Interface = {
			Haptics = {},
			Input = {},
			Localization = {},
			Screen = {},
			VR = {}
		},
		Items = {
			Common = {}
		},
		Network = {
			Request = {
				Url = {}
			},
			Socket = {
				Client = {},
				Server = {}
			}
		},
		Players = {
			Common = {},
			Player = {}
		},
		Run = {},
		World = {
			Atmosphere = {},
			Clouds = {},
			Lighting = {},
			Sky = {},
			Sound = {
				Playlist = {},
				Track = {}
			},
			SpecialEffects = {},
			Terrain = {},
			Time = {}
		}
	},
	String = {
		Filter = {},
		UTF8 = {}
	},
	Table = {},
	Utility = {
		CameraShaker = {
			CameraShakeInstance = {},
			CameraShakePresets = {}
		},
		Compression = {
			LZW = {}
		},
		Create = {},
		Crypto = {
			Cipher = {
				AES128 = {},
				AES192 = {},
				AES256 = {},
				Mode = {
					CBC = {},
					CFB = {},
					CTR = {},
					IGE = {},
					OFB = {},
					PCBC = {}
				},
				Salsa20 = {}
			},
			Digest = {
				MD5 = {},
				SHA224 = {},
				SHA256 = {}
			},
			KDF = {
				HKDF = {},
				PBKDF2 = {}
			},
			MAC = {
				HMAC = {}
			},
			Padding = {
				ANSIX923 = {},
				ISOIEC7816 = {},
				PKCS7 = {},
				Zero = {}
			},
			Utility = {
				Array = {},
				Queue = {},
				Stream = {}
			}
		},
		Date = {},
		Draw = {},
		Maid = {},
		Promise = {
			["roblox-lua-promise"] = {}
		},
		Serialization = {
			Base64 = {},
			Base85 = {},
			BitBuffer = {
				FastBitBuffer = {}
			}
		},
		Signal = {
			Module = {}
		},
		Timer = {}
	}
}

local guaranteeChildren

guaranteeChildren = function(item, key, arg)
	arg = arg:WaitForChild(key)
	
	for key, child in pairs(item) do
		guaranteeChildren(child, key, arg)
	end
end

guaranteeChildren(tree, 'Accel', script.Parent)

return nil