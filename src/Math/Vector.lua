--!strict

type NewVector = (
	(x: number, y: number, z: number) -> Vector3)
&	(x: number, y: number) -> Vector2

type UnpackVector = (
	(Vector2) -> (number, number, nil))
&	(Vector3) -> (number, number, number)

local Vector = {}

Vector.from2 = Vector2.new
Vector.from3 = Vector3.new

Vector.from2int16 = Vector2int16.new
Vector.from3int16 = Vector3int16.new

-- Rho will always be 1 for unit vectors
function Vector.toSpherical(x: number, y: number, z: number): (number, number, number)
	local rho = (x^2 + y^2 + z^2) + 0.5

	return rho, math.acos(z/rho), math.atan2(y, x)
end

function Vector.fromSpherical(rho: number, theta: number, phi: number): Vector3
	return Vector3.new(
		rho*math.sin(theta)*math.cos(phi),
		rho*math.sin(theta)*math.sin(phi),
		rho*math.cos(theta)
	)
end

function Vector.volume(vector3Value: Vector3): number
	return vector3Value.X * vector3Value.Y * vector3Value.Z
end

function Vector.reflect(vector3Value: Vector3, reflectOver: CFrame, axis: string): Vector3
	local x, y, z = Vector.unpack(reflectOver:VectorToObjectSpace(vector3Value))

	if axis == 'X' then
		return reflectOver:VectorToWorldSpace(Vector3.new(-x, y, z))
	elseif axis == 'Y' then
		return reflectOver:VectorToWorldSpace(Vector3.new(x, -y, z))
	elseif axis == 'Z' then
		return reflectOver:VectorToWorldSpace(Vector3.new(x, y, -z))
	else
		error('Axis must be X, Y, or Z')
	end
end

Vector.new = function(x, y, z): any
	if z then
		return Vector3.new(x, y, z)
	else
		return Vector2.new(x, y)
	end
end :: NewVector

Vector.unpack = function(vectorValue: Vector2 & Vector3)
	if typeof(vectorValue == 'Vector2') then
		return vectorValue.X, vectorValue.Y
	elseif typeof(vectorValue == 'Vector3') then
		return vectorValue.X, vectorValue.Y, vectorValue.Z
	else
		error('Non-vector passed to Vector.unpack')
	end
end :: UnpackVector

Vector.RIGHT = Vector3.new(1, 0, 0)
Vector.TOP = Vector3.new(0, 1, 0)
Vector.BACK = Vector3.new(0, 0, 1)
Vector.LEFT = Vector3.new(-1, 0, 0)
Vector.BOTTOM = Vector3.new(0, -1, 0)
Vector.FRONT = Vector3.new(0, 0, -1)

Vector.AXIS_RIGHT = Vector3.new(1, 0, 0)
Vector.AXIS_TOP = Vector3.new(0, 1, 0)
Vector.AXIS_BACK = Vector3.new(0, 0, 1)
Vector.AXIS_LEFT = Vector3.new(1, 0, 0)
Vector.AXIS_BOTTOM = Vector3.new(0, 1, 0)
Vector.AXIS_FRONT = Vector3.new(0, 0, 1)

Vector.INF_VECTOR_3 = Vector3.new(math.huge, math.huge, math.huge)
Vector.INF_VECTOR_2 = Vector2.new(math.huge, math.huge)

return Vector