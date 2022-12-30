--!nonstrict

--[[
	FastBitBuffer
    
	Author: howmanysmall
	URL: https://github.com/howmanysmall/FastBitBuffer

	Modified by Muoshuu
	- Removed deprecated readBrickColor/writeBrickColor
	- Made fromString, fromBase64, and fromBase128 static
	- Removed camelCase declarations
--]]

local BitBuffer = {
	ClassName = "BitBuffer";
	
	__tostring = function()
		return "BitBuffer"
	end
}

BitBuffer.__index = BitBuffer

local CHAR_0X10 = string.char(0x10)
local DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function ToBase(Number, Base)
	Number = math.floor(Number)
	if not Base or Base == 10 then
		return tostring(Number)
	end

	local Array = {}
	local Sign = ""
	if Number < 0 then
		Sign = "-"
		Number = 0 - Number
	end

	repeat
		local Index = (Number % Base) + 1
		Number = math.floor(Number / Base)
		table.insert(Array, 1, string.sub(DIGITS, Index, Index))
	until Number == 0

	return Sign .. table.concat(Array)
end

local function DetermineType(Value)
	local ActualType = typeof(Value)
	if ActualType == "number" then
		if Value % 1 == 0 then
			return Value < 0 and "negative integer" or "positive integer"
		else
			return Value < 0 and "negative number" or "positive number"
		end
	elseif ActualType == "table" then
		local Key = next(Value)
		if DetermineType(Key) == "positive integer" then
			return "array"
		else
			return "dictionary"
		end
	else
		return ActualType
	end
end

local NumberToBase64, Base64ToNumber = {}, {}

do
	local CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for Index = 1, 64 do
		local Character = string.sub(CHARACTERS, Index, Index)
		NumberToBase64[Index - 1] = Character
		Base64ToNumber[Character] = Index - 1
	end
end

-- Credit to Defaultio.
local NumberToBase128, Base128ToNumber = {}, {}

do
	local Base128Characters = ""
	for Index = 0, 127 do
		Base128Characters = Base128Characters .. string.char(Index)
	end

	for Index = 1, 128 do
		local Character = string.sub(Base128Characters, Index, Index)
		NumberToBase128[Index - 1] = Character
		Base128ToNumber[Character] = Index - 1
	end
end

local PowerOfTwo = setmetatable({}, {
	__index = function(self, Index)
		local Value = 2 ^ Index
		self[Index] = Value
		return Value
	end;
})

for Index = 0, 128 do
	local _ = PowerOfTwo[Index]
end

local BrickColorToNumber, NumberToBrickColor = {}, {}

do
	for Index = 0, 63 do
		local Color = BrickColor.palette(Index)
		BrickColorToNumber[Color.Number] = Index
		NumberToBrickColor[Index] = Color
	end
end

--[[**
	Creates a new BitBuffer.
	@returns [BitBuffer] The new BitBuffer.
**--]]
function BitBuffer.new()
	return setmetatable({
		BitPointer = 0;
		mBitBuffer = {};
	}, BitBuffer)
end

--[[**
	Resets the BitBuffer's BitPointer.
	@returns [void]
**--]]
function BitBuffer:ResetPointer()
	self.BitPointer = 0
end

--[[**
	Resets the BitBuffer's BitPointer and buffer table.
	@returns [void]
**--]]
function BitBuffer:Reset()
	self.mBitBuffer, self.BitPointer = {}, 0
end

--[[**
	Reads the given string and writes to the BitBuffer accordingly. Not really useful.
	@param [t:string] String The string.
	@returns [void]
**--]]
function BitBuffer.fromString(String)
	local self = BitBuffer.new()
	
	if type(String) ~= "string" then
		error(string.format("bad argument #1 in BitBuffer::FromString (string expected, instead got %s)", typeof(String)), 2)
	end

	self.mBitBuffer, self.BitPointer = {}, 0
	local BitPointerValue = 0

	for Index = 1, #String do
		local ByteCharacter = string.byte(String, Index, Index)
		for _ = 1, 8 do
			BitPointerValue = BitPointerValue + 1
			self.BitPointer = BitPointerValue
			self.mBitBuffer[BitPointerValue] = ByteCharacter % 2
			ByteCharacter = math.floor(ByteCharacter / 2)
		end
	end

	self.BitPointer = 0

	return self
end

--[[**
	Writes the BitBuffer to a string.
	@returns [t:string] The BitBuffer string.
**--]]
function BitBuffer:ToString()
	local String = ""
	local Accumulator = 0
	local Power = 0
	local mBitBuffer = self.mBitBuffer

	for Index = 1, math.ceil(#mBitBuffer / 8) * 8 do
		Accumulator = Accumulator + PowerOfTwo[Power] * (mBitBuffer[Index] or 0)
		Power = Power + 1
		if Power >= 8 then
			String = String .. string.char(Accumulator)
			Accumulator = 0
			Power = 0
		end
	end

	return String
end

--[[**
	Reads the given Base64 string and writes to the BitBuffer accordingly.
	@param [t:string] String The Base64 string.
	@returns [void]
**--]]
function BitBuffer.fromBase64(String)
	local self = BitBuffer.new()

	if type(String) ~= "string" then
		error(string.format("bad argument #1 in BitBuffer::FromBase64 (string expected, instead got %s)", typeof(String)), 2)
	end

	self.mBitBuffer, self.BitPointer = {}, 0
	local BitPointerValue = 0

	for Index = 1, #String do
		local Character = string.sub(String, Index, Index)
		local ByteCharacter = Base64ToNumber[Character]
		if not ByteCharacter then
			error("Bad character: 0x" .. ToBase(string.byte(Character), 16), 2)
		end

		for _ = 1, 6 do
			BitPointerValue = BitPointerValue + 1
			self.BitPointer = BitPointerValue
			self.mBitBuffer[BitPointerValue] = ByteCharacter % 2
			ByteCharacter = math.floor(ByteCharacter / 2)
		end

		if ByteCharacter ~= 0 then
			error("Character value 0x" .. ToBase(Base64ToNumber[Character], 16) .. " too large", 2)
		end
	end

	self.BitPointer = 0
	
	return self
end

--[[**
	Writes the BitBuffer to a Base64 string.
	@returns [t:string] The BitBuffer encoded in Base64.
**--]]
function BitBuffer:ToBase64()
	local Array = {}
	local Length = 0
	local Accumulator = 0
	local Power = 0
	local mBitBuffer = self.mBitBuffer

	for Index = 1, math.ceil(#mBitBuffer / 6) * 6 do
		Accumulator = Accumulator + PowerOfTwo[Power] * (mBitBuffer[Index] or 0)
		Power = Power + 1
		if Power >= 6 then
			Length = Length + 1
			Array[Length] = NumberToBase64[Accumulator]
			Accumulator = 0
			Power = 0
		end
	end

	return table.concat(Array)
end

--[[**
	Reads the given Base128 string and writes to the BitBuffer accordingly. Not recommended. Credit to Defaultio for the original functions.
	@param [t:string] String The Base128 string.
	@returns [void]
**--]]
function BitBuffer.fromBase128(String)
	local self = BitBuffer.new()

	if type(String) ~= "string" then
		error(string.format("bad argument #1 in BitBuffer::FromBase128 (string expected, instead got %s)", typeof(String)), 2)
	end

	self.mBitBuffer, self.BitPointer = {}, 0
	local BitPointerValue = 0

	for Index = 1, #String do
		local Character = string.sub(String, Index, Index)
		local ByteCharacter = Base128ToNumber[Character]
		if not ByteCharacter then
			error("Bad character: 0x" .. ToBase(string.byte(Character), 16), 2)
		end

		for _ = 1, 7 do
			BitPointerValue = BitPointerValue + 1
			self.BitPointer = BitPointerValue
			self.mBitBuffer[BitPointerValue] = ByteCharacter % 2
			ByteCharacter = math.floor(ByteCharacter / 2)
		end

		if ByteCharacter ~= 0 then
			error("Character value 0x" .. ToBase(Base128ToNumber[Character], 16) .. " too large", 2)
		end
	end

	self.BitPointer = 0

	return self
end

--[[**
	Writes the BitBuffer to Base128. Not recommended. Credit to Defaultio for the original functions.
	@returns [t:string] The BitBuffer encoded in Base128.
**--]]
function BitBuffer:ToBase128()
	local Array = {}
	local Length = 0
	local Accumulator = 0
	local Power = 0
	local mBitBuffer = self.mBitBuffer

	for Index = 1, math.ceil(#mBitBuffer / 7) * 7 do
		Accumulator = Accumulator + PowerOfTwo[Power] * (mBitBuffer[Index] or 0)
		Power = Power + 1
		if Power >= 7 then
			Length = Length + 1
			Array[Length] = NumberToBase128[Accumulator]
			Accumulator = 0
			Power = 0
		end
	end

	return table.concat(Array)
end

--[[**
	Dumps the BitBuffer data and prints it.
	@returns [void]
**--]]
function BitBuffer:Dump()
	local String = ""
	local String2 = ""
	local Accumulator = 0
	local Power = 0
	local mBitBuffer = self.mBitBuffer

	for Index = 1, math.ceil(#mBitBuffer / 8) * 8 do
		String2 = String2 .. (mBitBuffer[Index] or 0)
		Accumulator = Accumulator + PowerOfTwo[Power] * (mBitBuffer[Index] or 0)
		Power = Power + 1

		if Power >= 8 then
			String2 = String2 .. " "
			String = String .. "0x" .. ToBase(Accumulator, 16) .. " "
			Accumulator = 0
			Power = 0
		end
	end

	print("[Dump] Bytes:", String)
	print("[Dump] Bits:", String2)
end

function BitBuffer:_readBit()
	self.BitPointer = self.BitPointer + 1
	return self.mBitBuffer[self.BitPointer]
end

--[[**
	Writes an unsigned number to the BitBuffer.
	@param [t:integer] Width The bit width of the value.
	@param [t:integer] Value The unsigned integer.
	@returns [void]
**--]]
function BitBuffer:WriteUnsigned(Width, Value)
	if type(Width) ~= "number" then
		error(string.format("bad argument #1 in BitBuffer::writeUnsigned (number expected, instead got %s)", DetermineType(Width)), 2)
	end

	if not (Value or type(Value) == "number" or Value >= 0 or Value % 1 == 0) then
		error(string.format("bad argument #2 in BitBuffer::writeUnsigned (positive integer expected, instead got %s)", DetermineType(Value)), 2)
	end

	-- Store LSB first
	for _ = 1, Width do
		self.BitPointer = self.BitPointer + 1
		self.mBitBuffer[self.BitPointer] = Value % 2
		Value = math.floor(Value / 2)
	end

	if Value ~= 0 then
		error("Value " .. tostring(Value) .. " has width greater than " .. Width .. " bits", 2)
	end
end

--[[**
	Reads an unsigned integer from the BitBuffer.
	@param [t:integer] Width The bit width of the value.
	@returns [t:integer] The unsigned integer.
**--]]
function BitBuffer:ReadUnsigned(Width)
	local Value = 0
	for Index = 1, Width do
		Value = Value + self:_readBit() * PowerOfTwo[Index - 1]
	end

	return Value
end

--[[**
	Writes a signed integer to the BitBuffer.
	@param [t:integer] Width The bit width of the value.
	@param [t:integer] Value The signed integer.
	@returns [void]
**--]]
function BitBuffer:WriteSigned(Width, Value)
	if not (Width and Value) then
		error("bad arguments in BitBuffer::writeSigned (missing values)", 2)
	end

	if Value % 1 ~= 0 then
		error("Non-integer value to BitBuffer::writeSigned", 2)
	end

	-- Write sign
	if Value < 0 then
		self.BitPointer = self.BitPointer + 1
		self.mBitBuffer[self.BitPointer] = 1
		Value = 0 - Value
	else
		self.BitPointer = self.BitPointer + 1
		self.mBitBuffer[self.BitPointer] = 0
	end

	self:writeUnsigned(Width - 1, Value)
end

--[[**
	Reads a signed integer from the BitBuffer.
	@param [t:integer] Width The bit width of the value.
	@returns [t:integer] The signed integer.
**--]]
function BitBuffer:ReadSigned(Width)
	self.BitPointer = self.BitPointer + 1
	return ((-1) ^ self.mBitBuffer[self.BitPointer]) * self:readUnsigned(Width - 1)
end

--[[**
	Writes a string to the BitBuffer.
	@param [t:string] String The string you are writing to the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteString(String)
	if type(String) ~= "string" then
		error(string.format("bad argument #1 in BitBuffer::writeString (string expected, instead got %s)", typeof(String)), 2)
	end

	-- First check if it's a 7 or 8 bit width of string
	local StringLength = #String
	local BitWidth = 7
	for Index = 1, StringLength do
		if string.byte(String, Index, Index) > 127 then
			BitWidth = 8
			break
		end
	end

	-- Write the bit width flag
	self:writeUnsigned(1, BitWidth == 7 and 0 or 1) -- 1 for wide chars

	-- Now write out the string, terminated with "0x10, 0b0"
	-- 0x10 is encoded as "0x10, 0b1"
	for Index = 1, StringLength do
		local ByteCharacter = string.byte(String, Index, Index)
		if ByteCharacter == 0x10 then
			self:writeUnsigned(BitWidth, 0x10)
			self:writeUnsigned(1, 1)
		else
			self:writeUnsigned(BitWidth, ByteCharacter)
		end
	end

	-- Write terminator
	self:writeUnsigned(BitWidth, 0x10)
	self:writeUnsigned(1, 0)
end

--[[**
	Reads the BitBuffer for a string.
	@returns [t:string] The string written to the BitBuffer.
**--]]
function BitBuffer:ReadString()
	-- Get bit width
	local BitWidth = self:readUnsigned(1) == 1 and 8 or 7

	-- Loop
	local String = ""
	while true do
		local Character = self:readUnsigned(BitWidth)
		if Character == 0x10 then
			if self:readUnsigned(1) == 1 then
				String = String .. CHAR_0X10
			else
				break
			end
		else
			String = String .. string.char(Character)
		end
	end

	return String
end

--[[**
	Writes a boolean to the BitBuffer.
	@param [t:boolean] Boolean The value you are writing to the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteBool(Boolean)
	if type(Boolean) ~= "boolean" then
		error(string.format("bad argument #1 in BitBuffer::writeBool (boolean expected, instead got %s)", typeof(Boolean)), 2)
	end

	self:writeUnsigned(1, Boolean and 1 or 0)
end

--[[**
	Reads the BitBuffer for a boolean.
	@returns [t:boolean] The boolean.
**--]]
function BitBuffer:ReadBool()
	return self:readUnsigned(1) == 1
end

-- Read / Write a floating point number with |wfrac| fraction part
-- bits, |wexp| exponent part bits, and one sign bit.

--[[**
	Writes a float to the BitBuffer.
	@param [t:integer] Fraction The number of bits (probably).
	@param [t:integer] WriteExponent The number of bits for the decimal (probably).
	@param [t:number] Float The actual number you are writing.
	@returns [void]
**--]]
function BitBuffer:WriteFloat(Fraction, WriteExponent, Float)
	if not (Fraction and WriteExponent and Float) then
		error("missing argument(s)", 2)
	end

	-- Sign
	local Sign = 1
	if Float < 0 then
		Float = 0 - Float
		Sign = -1
	end

	-- Decompose
	local Mantissa, Exponent = math.frexp(Float)
	if Exponent == 0 and Mantissa == 0 then
		self:writeUnsigned(Fraction + WriteExponent + 1, 0)
		return
	else
		Mantissa = (Mantissa - 0.5) / 0.5 * PowerOfTwo[Fraction]
	end

	-- Write sign
	self:writeUnsigned(1, Sign == -1 and 1 or 0)

	-- Write mantissa
	Mantissa = Mantissa + 0.5
	Mantissa = math.floor(Mantissa) -- Not really correct, should round up/down based on the parity of |wexp|
	self:writeUnsigned(Fraction, Mantissa)

	-- Write exponent
	local MaxExp = PowerOfTwo[WriteExponent - 1] - 1
	self:writeSigned(WriteExponent, Exponent > MaxExp and MaxExp or Exponent < -MaxExp and -MaxExp or Exponent)
end

--[[**
	Reads a float from the BitBuffer.
	@param [t:integer] Fraction The number of bits (probably).
	@param [t:integer] WriteExponent The number of bits for the decimal (probably).
	@returns [t:number] The float.
**--]]
function BitBuffer:ReadFloat(Fraction, WriteExponent)
	if not (Fraction and WriteExponent) then
		error("missing argument(s)", 2)
	end

	local Sign = self:readUnsigned(1) == 1 and -1 or 1
	local Mantissa = self:readUnsigned(Fraction)
	local Exponent = self:readSigned(WriteExponent)
	if Exponent == 0 and Mantissa == 0 then
		return 0
	end

	Mantissa = Mantissa / PowerOfTwo[Fraction] / 2 + 0.5
	return Sign * math.ldexp(Mantissa, Exponent)
end

--[[**
	Writes a float8 (quarter precision) to the BitBuffer.
	@param [t:number] The float8.
	@returns [void]
**--]]
function BitBuffer:WriteFloat8(Float)
	self:writeFloat(3, 4, Float)
end

--[[**
	Reads a float8 (quarter precision) from the BitBuffer.
	@returns [t:number] The float8.
**--]]
function BitBuffer:ReadFloat8()
	local Sign = self:readUnsigned(1) == 1 and -1 or 1
	local Mantissa = self:readUnsigned(3)
	local Exponent = self:readSigned(4)
	if Exponent == 0 and Mantissa == 0 then
		return 0
	end

	Mantissa = Mantissa / PowerOfTwo[3] / 2 + 0.5
	return Sign * math.ldexp(Mantissa, Exponent)
end

--[[**
	Writes a float16 (half precision) to the BitBuffer.
	@param [t:number] The float16.
	@returns [void]
**--]]
function BitBuffer:WriteFloat16(Float)
	self:writeFloat(10, 5, Float)
end

--[[**
	Reads a float16 (half precision) from the BitBuffer.
	@returns [t:number] The float16.
**--]]
function BitBuffer:ReadFloat16()
	local Sign = self:readUnsigned(1) == 1 and -1 or 1
	local Mantissa = self:readUnsigned(10)
	local Exponent = self:readSigned(5)
	if Exponent == 0 and Mantissa == 0 then
		return 0
	end

	Mantissa = Mantissa / PowerOfTwo[10] / 2 + 0.5
	return Sign * math.ldexp(Mantissa, Exponent)
end

--[[**
	Writes a float32 (single precision) to the BitBuffer.
	@param [t:number] The float32.
	@returns [void]
**--]]
function BitBuffer:WriteFloat32(Float)
	self:writeFloat(23, 8, Float)
end

--[[**
	Reads a float32 (single precision) from the BitBuffer.
	@returns [t:number] The float32.
**--]]
function BitBuffer:ReadFloat32()
	local Sign = self:readUnsigned(1) == 1 and -1 or 1
	local Mantissa = self:readUnsigned(23)
	local Exponent = self:readSigned(8)
	if Exponent == 0 and Mantissa == 0 then
		return 0
	end

	Mantissa = Mantissa / PowerOfTwo[23] / 2 + 0.5
	return Sign * math.ldexp(Mantissa, Exponent)
end

--[[**
	Writes a float64 (double precision) to the BitBuffer.
	@param [t:number] The float64.
	@returns [void]
**--]]
function BitBuffer:WriteFloat64(Float)
	self:writeFloat(52, 11, Float)
end

--[[**
	Reads a float64 (double precision) from the BitBuffer.
	@returns [t:number] The float64.
**--]]
function BitBuffer:ReadFloat64()
	local Sign = self:readUnsigned(1) == 1 and -1 or 1
	local Mantissa = self:readUnsigned(52)
	local Exponent = self:readSigned(11)
	if Exponent == 0 and Mantissa == 0 then
		return 0
	end

	Mantissa = Mantissa / PowerOfTwo[52] / 2 + 0.5
	return Sign * math.ldexp(Mantissa, Exponent)
end

--[[**
	Writes the rotation part of a CFrame into the BitBuffer.
	@param [t:CFrame] CoordinateFrame The CFrame you wish to write.
	@returns [void]
**--]]
function BitBuffer:WriteRotation(CoordinateFrame)
	if typeof(CoordinateFrame) ~= "CFrame" then
		error(string.format("bad argument #1 in BitBuffer::writeRotation (CFrame expected, instead got %s)", typeof(CoordinateFrame)), 2)
	end

	local LookVector = CoordinateFrame.LookVector
	local Azumith = math.atan2(-LookVector.X, -LookVector.Z)
	local Elevation = math.atan2(LookVector.Y, math.sqrt(LookVector.X * LookVector.X + LookVector.Z * LookVector.Z))
	local WithoutRoll = CFrame.new(CoordinateFrame.Position) * CFrame.Angles(0, Azumith, 0) * CFrame.Angles(Elevation, 0, 0)
	local _, _, Roll = (WithoutRoll:Inverse() * CoordinateFrame):ToEulerAnglesXYZ()

	-- Atan2 -> in the range [-pi, pi]
	Azumith = math.floor(((Azumith / 3.1415926535898) * 2097151) + 0.5)
	Roll = math.floor(((Roll / 3.1415926535898) * 1048575) + 0.5)
	Elevation = math.floor(((Elevation / 1.5707963267949) * 1048575) + 0.5)

	self:writeSigned(22, Azumith)
	self:writeSigned(21, Roll)
	self:writeSigned(21, Elevation)
end

--[[**
	Reads the rotation part of a CFrame saved in the BitBuffer.
	@returns [t:CFrame] The rotation read from the BitBuffer.
**--]]
function BitBuffer:ReadRotation()
	local Azumith = self:readSigned(22)
	local Roll = self:readSigned(21)
	local Elevation = self:readSigned(21)

	Azumith = 3.1415926535898 * (Azumith / 2097151)
	Roll = 3.1415926535898 * (Roll / 1048575)
	Elevation = 3.1415926535898 * (Elevation / 1048575)

	local Rotation = CFrame.Angles(0, Azumith, 0)
	Rotation = Rotation * CFrame.Angles(Elevation, 0, 0)
	Rotation = Rotation * CFrame.Angles(0, 0, Roll)

	return Rotation
end

--[[**
	Writes a Color3 to the BitBuffer.
	@param [t:Color3] Color The color you want to write into the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteColor3(Color)
	if typeof(Color) ~= "Color3" then
		error(string.format("bad argument #1 in BitBuffer::writeColor3 (Color3 expected, instead got %s)", typeof(Color)), 2)
	end

	local R, G, B = Color.R * 255, Color.G * 255, Color.B * 255

	self:writeUnsigned(8, math.floor(R))
	self:writeUnsigned(8, math.floor(G))
	self:writeUnsigned(8, math.floor(B))
end

--[[**
	Reads a Color3 from the BitBuffer.
	@returns [t:Color3] The color read from the BitBuffer.
**--]]
function BitBuffer:ReadColor3()
	return Color3.fromRGB(self:readUnsigned(8), self:readUnsigned(8), self:readUnsigned(8))
end

--[[**
	Writes a Vector3 to the BitBuffer. Writes with Float32 precision.
	@param [t:Vector3] Vector The vector you want to write into the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteVector3(Vector)
	if typeof(Vector) ~= "Vector3" then
		error(string.format("bad argument #1 in BitBuffer::writeVector3 (Vector3 expected, instead got %s)", typeof(Vector)), 2)
	end

	self:writeFloat32(Vector.X)
	self:writeFloat32(Vector.Y)
	self:writeFloat32(Vector.Z)
end

--[[**
	Reads a Vector3 from the BitBuffer. Uses Float32 precision.
	@returns [t:Vector3] The vector read from the BitBuffer.
**--]]
function BitBuffer:ReadVector3()
	return Vector3.new(self:readFloat32(), self:readFloat32(), self:readFloat32())
end

--[[**
	Writes a full CFrame (position and rotation) to the BitBuffer. Uses Float64 precision.
	@param [t:CFrame] CoordinateFrame The CFrame you are writing to the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteCFrame(CoordinateFrame)
	if typeof(CoordinateFrame) ~= "CFrame" then
		error(string.format("bad argument #1 in BitBuffer::writeCFrame (CFrame expected, instead got %s)", typeof(CoordinateFrame)), 2)
	end

	self:writeVector3Float64(CoordinateFrame.Position)
	self:writeRotation(CoordinateFrame)
end

--[[**
	Reads a full CFrame (position and rotation) from the BitBuffer. Uses Float64 precision.
	@returns [t:CFrame] The CFrame you are reading from the BitBuffer.
**--]]
function BitBuffer:ReadCFrame()
	local Position = CFrame.new(self:readVector3Float64())

	local Azumith = self:readSigned(22)
	local Roll = self:readSigned(21)
	local Elevation = self:readSigned(21)

	Azumith = 3.1415926535898 * (Azumith / 2097151)
	Roll = 3.1415926535898 * (Roll / 1048575)
	Elevation = 3.1415926535898 * (Elevation / 1048575)

	local Rotation = CFrame.fromOrientation(Elevation, Azumith, Roll)

	return Position * Rotation
end

--[[**
	Writes a Vector2 to the BitBuffer. Writes with Float32 precision.
	@param [t:Vector2] Vector The vector you want to write into the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteVector2(Vector)
	if typeof(Vector) ~= "Vector2" then
		error(string.format("bad argument #1 in BitBuffer::writeVector2 (Vector2 expected, instead got %s)", typeof(Vector)), 2)
	end

	self:writeFloat32(Vector.X)
	self:writeFloat32(Vector.Y)
end

--[[**
	Reads a Vector2 from the BitBuffer. Uses Float32 precision.
	@returns [t:Vector2] The vector read from the BitBuffer.
**--]]
function BitBuffer:ReadVector2()
	return Vector2.new(self:readFloat32(), self:readFloat32())
end

--[[**
	Writes a UDim2 to the BitBuffer. Uses Float32 precision for the scale.
	@param [t:UDim2] Value The UDim2 you are writing to the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteUDim2(Value)
	if typeof(Value) ~= "UDim2" then
		error(string.format("bad argument #1 in BitBuffer::writeUDim2 (UDim2 expected, instead got %s)", typeof(Value)), 2)
	end

	self:writeFloat32(Value.X.Scale)
	self:writeSigned(17, Value.X.Offset)
	self:writeFloat32(Value.Y.Scale)
	self:writeSigned(17, Value.Y.Offset)
end

--[[**
	Reads a UDim2 from the BitBuffer. Uses Float32 precision for the scale.
	@returns [t:UDim2] The UDim2 read from the BitBuffer.
**--]]
function BitBuffer:ReadUDim2()
	return UDim2.new(self:readFloat32(), self:readSigned(17), self:readFloat32(), self:readSigned(17))
end

--[[**
	Writes a Vector3 to the BitBuffer. Writes with Float64 precision.
	@param [t:Vector3] Vector The vector you want to write into the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteVector3Float64(Vector)
	if typeof(Vector) ~= "Vector3" then
		error(string.format("bad argument #1 in BitBuffer::writeVector3Float64 (Vector3 expected, instead got %s)", typeof(Vector)), 2)
	end

	self:writeFloat64(Vector.X)
	self:writeFloat64(Vector.Y)
	self:writeFloat64(Vector.Z)
end

--[[**
	Reads a Vector3 from the BitBuffer. Reads with Float64 precision.
	@returns [t:Vector3] The vector read from the BitBuffer.
**--]]
function BitBuffer:ReadVector3Float64()
	return Vector3.new(self:readFloat64(), self:readFloat64(), self:readFloat64())
end

--[[**
	Writes a Vector2 to the BitBuffer. Writes with Float64 precision.
	@param [t:Vector2] Vector The vector you want to write into the BitBuffer.
	@returns [void]
**--]]
function BitBuffer:WriteVector2Float64(Vector)
	if typeof(Vector) ~= "Vector2" then
		error(string.format("bad argument #1 in BitBuffer::writeVector2Float64 (Vector2 expected, instead got %s)", typeof(Vector)), 2)
	end

	self:writeFloat64(Vector.X)
	self:writeFloat64(Vector.Y)
end

--[[**
	Reads a Vector2 from the BitBuffer. Reads with Float64 precision.
	@returns [t:Vector2] The vector read from the BitBuffer.
**--]]
function BitBuffer:ReadVector2Float64()
	return Vector2.new(self:readFloat64(), self:readFloat64())
end

--[[**
	Destroys the BitBuffer metatable.
	@returns [void]
**--]]
function BitBuffer:destroy()
	self.mBitBuffer = {}
	self.BitPointer = 0
	self.mBitBuffer = nil
	setmetatable(self, nil)
end

--[[**
	Calculates the amount of bits needed for a given number.
	@param [t:number] Number The number you want to use.
	@returns [t:number] The amount of bits needed.
**--]]
function BitBuffer.bitsNeeded(Number)
	if type(Number) ~= "number" then
		error(string.format("bad argument #1 in BitBuffer.bitsNeeded (number expected, instead got %s)", typeof(Number)), 2)
	end

	local Bits = math.log(Number + 1, 2)
	return math.ceil(Bits)
end

return BitBuffer