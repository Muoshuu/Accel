--!strict

-- Minimally modified from https://gist.github.com/EgoMoose/7a8f4d7b00ffe45abce8ade72b173284
-- See https://devforum.roblox.com/t/how-to-think-about-quaternions/143295

local Quaternion = {}
local ref: { [Quaternion]: Vector3 } = {}

local prototype = {}
local meta = {}

function prototype.toCFrame(self: Quaternion): CFrame
	return CFrame.new(0, 0, 0, self.x, self.y, self.z, self.w)
end

function prototype.inverse(self: Quaternion): Quaternion
	local w = self.w
	local conjugate = w*w + ref[self]:Dot(ref[self])
	local nv = -ref[self] / conjugate

	return Quaternion.new(w / conjugate, nv.X, nv.Y, nv.Z)
end

function prototype.toAxisAngle(self: Quaternion): (Vector3, number)
	local axis = ref[self]
	local theta = math.acos(self.w) * 2

	if theta % (math.pi*2) == 0 and axis:Dot(axis) == 0 then
		axis = Vector3.new(1, 0, 0)
	end

	return axis.Unit, theta
end

function prototype.slerp(self: Quaternion, goal: Quaternion, theta: number): Quaternion
	return ((goal * self:inverse()) ^ theta) * self
end

function prototype.slerpClosest(self: Quaternion, goal: Quaternion, theta: number): Quaternion
	if self.w*goal.w + self.x*goal.x + self.y*goal.y + self.z*goal.z > 0 then
		return self:slerp(goal, theta)
	else
		return self:slerp(Quaternion.new(-goal.w, -goal.x, -goal.y, -goal.z), theta)
	end
end

function prototype.dot(self: Quaternion, other: Quaternion)
	return self.w*other.w+self.x*other.x+self.y*other.y+self.z*other.z
end

function prototype.unpack(self: Quaternion): (number, number, number, number)
	return self.x, self.y, self.z, self.w
end

meta.__index = prototype

meta.__unm = function(self: Quaternion): Quaternion
	return Quaternion.new(-self.w, -self.x, -self.y, -self.z)
end

meta.__mul = function(self: Quaternion, other: Quaternion): Quaternion
	local w0, w1 = self.w, other.w
	local v0, v1 = ref[self], ref[other]

	local nw = w0*w1 - v0:Dot(v1)
	local nv = v0*w1 + v1*w0 + v0:Cross(v1)

	return Quaternion.new(nw, nv.X, nv.Y, nv.Z)
end

meta.__pow = function(self: Quaternion, t: number): Quaternion
	local axis, theta = self:toAxisAngle()

	theta = theta * t * 0.5
	axis = math.sin(theta)*axis

	return Quaternion.new(math.cos(theta), axis.X, axis.Y, axis.Z)
end

meta.__tostring = function(self: Quaternion): string
	return string.format("%f, %f, %f, %f", self.w, self.x, self.y, self.z);
end

export type Quaternion = typeof(setmetatable({
	x = 0,
	y = 0,
	z = 0,
	w = 0

}, meta))

function Quaternion.new(w: number, x: number, y: number, z: number): Quaternion
	local this = setmetatable({ x = x, y = y, z = z, w = w }, meta)

	ref[this] = Vector3.new(x, y, z)

	return this
end

function Quaternion.fromCFrame(cframe: CFrame): Quaternion
	local axis, theta = cframe:ToAxisAngle()

	theta = theta * 0.5
	axis = math.sin(theta) * axis

	return Quaternion.new(math.cos(theta), axis.X, axis.Y, axis.Z)
end

return table.freeze(Quaternion)