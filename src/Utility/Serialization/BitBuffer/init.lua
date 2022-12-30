--!strict

export type BitBuffer = {
	ResetPointer: (BitBuffer) -> (),
	Reset: (BitBuffer) -> (),
	
	ToString: (BitBuffer) -> string,
	ToBase64: (BitBuffer) -> string,
	ToBase128: (BitBuffer) -> string,
	
	WriteUnsigned: (BitBuffer, width: number, value: number) -> (),
	ReadUnsigned: (BitBuffer, width: number) -> number,
	
	WriteSigned: (BitBuffer, width: number, value: number) -> (),
	ReadSigned: (BitBuffer, width: number) -> number,
	
	WriteString: (BitBuffer, string) -> (),
	ReadString: (BitBuffer) -> string,
	
	WriteBool: (BitBuffer, boolean) -> (),
	ReadBool: (BitBuffer) -> boolean,
	
	WriteFloat: (BitBuffer, number) -> (),
	ReadFloat: (BitBuffer) -> number,
	
	WriteFloat8: (BitBuffer, number) -> (),
	ReadFloat8: (BitBuffer) -> number,
	
	WriteFloat16: (BitBuffer, number) -> (),
	ReadFloat16: (BitBuffer) -> number,
	
	WriteFloat32: (BitBuffer, number) -> (),
	ReadFloat32: (BitBuffer) -> number,
	
	WriteFloat64: (BitBuffer, number) -> (),
	ReadFloat64: (BitBuffer) -> number,
	
	WriteRotation: (BitBuffer, CFrame) -> (),
	ReadRotation: (BitBuffer) -> CFrame,
	
	WriteColor3: (BitBuffer, Color3) -> (),
	ReadColor3: (BitBuffer) -> Color3,
	
	WriteVector3: (BitBuffer, Vector3) -> (),
	ReadVector3: (BitBuffer) -> Vector3,
	
	WriteCFrame: (BitBuffer, CFrame) -> (),
	ReadCFrame: (BitBuffer) -> CFrame,
	
	WriteVector2: (BitBuffer, Vector2) -> (),
	ReadVector2: (BitBuffer) -> Vector2,
	
	WriteUDim2: (BitBuffer, UDim2) -> (),
	ReadUDim2: (BitBuffer) -> UDim2,
	
	WriteVector3Float64: (BitBuffer, Vector3) -> (),
	ReadVector3Float64: (BitBuffer) -> Vector3,
	
	WriteVector2Float64: (BitBuffer, Vector2) -> (),
	ReadVector2Float64: (BitBuffer) -> Vector3,

	Dump: (BitBuffer) -> (),
	Destroy: (BitBuffer) -> (),
}

return table.freeze(require(script.FastBitBuffer)) :: {
	bitsNeeded: (number: number) -> number,
	new: () -> BitBuffer,

	fromString: (BitBuffer, string) -> BitBuffer,
	fromBase64: (BitBuffer, string) -> BitBuffer,
	fromBase128: (BitBuffer, string) -> BitBuffer
}