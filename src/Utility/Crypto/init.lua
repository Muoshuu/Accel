--[[
	lua-lockbox
	
	Author: James L. (somesocks)
	URL: https://github.com/somesocks/lua-lockbox
	
	Deviations:
	 - Modified style to be consistent with Accel
	 - Removed all insecure modules except MD5
	 - Added mrogaski/lua-salsa20
	 - Corrected PKCS7 padding to match openssl
	   - https://github.com/somesocks/lua-lockbox/issues/14
	 
	The MIT License (MIT)

	Copyright (c) 2015 James L.

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

]]

return table.freeze({
	Cipher = {
		Mode = {
			CBC = require(script.Cipher.Mode.CBC),
			CFB = require(script.Cipher.Mode.CFB),
			CTR = require(script.Cipher.Mode.CTR),
			IGE = require(script.Cipher.Mode.IGE),
			OFB = require(script.Cipher.Mode.OFB),
			PCBC = require(script.Cipher.Mode.PCBC)
		},

		AES128 = require(script.Cipher.AES128),
		AES192 = require(script.Cipher.AES192),
		AES256 = require(script.Cipher.AES256),
		Salsa20 = require(script.Cipher.Salsa20)
	},
	
	Digest = {
		MD5 = require(script.Digest.MD5),
		SHA224 = require(script.Digest.SHA224),
		SHA256 = require(script.Digest.SHA256)
	},
	
	KDF = {
		HKDF = require(script.KDF.HKDF),
		PBKDF2 = require(script.KDF.PBKDF2)
	},
	
	MAC = {
		HMAC = require(script.MAC.HMAC)
	},
	
	Padding = {
		ANSIX923 = require(script.Padding.ANSIX923),
		ISOIEC7816 = require(script.Padding.ISOIEC7816),
		PKCS7 = require(script.Padding.PKCS7),
		Zero = require(script.Padding.Zero)
	},
	
	Utility = {
		Array = require(script.Utility.Array),
		Stream = require(script.Utility.Stream),
		Queue = require(script.Utility.Queue)
	}
})