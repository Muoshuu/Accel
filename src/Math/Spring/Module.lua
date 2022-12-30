--!nonstrict

-- TODO: Rewrite to work better with the typechecker

local Spring = {}

local prototype = {}
local meta = {}

function prototype.Update(self, now: number)
	local pos: any = self._position
	local vel: any = self._velocity
	local tar: any = self._target

	local d = self._damper
	local d2 = d*d

	local s = self._speed
	local delta = s*(now-self._time)

	local h, sin, cos

	if d2 < 1 then
		h = math.sqrt(1-d2)

		local exp = math.exp(-d*delta)/h

		cos, sin = exp*math.cos(h*delta), exp*math.sin(h*delta)
	elseif d2 == 1 then
		h = 1

		local exp = math.exp(-d*delta)/h

		cos, sin = exp, exp*delta
	else
		h = math.sqrt(d2-1)

		local u = math.exp((-d+h)*delta)/(2*h)
		local v = math.exp((-d-h)*delta)/(2*h)

		cos, sin = u+v, u-v
	end

	return (h*cos+d*sin) * pos + (1-(h*cos+d*sin)) * tar + (sin/s) * vel, (-s*sin) * pos + (s*sin) * tar + (h*cos-d*sin) * vel
end

function prototype.Impulse(self, velocity)
	self:Set('Velocity', self:Get('Velocity') + velocity)
end

function prototype.TimeSkip(self, delta: number)
	local now = self._clock()
	local position, velocity = self:Update(now + delta)

	self._position = position
	self._velocity = velocity
	self._time = now
end

function prototype.Get(self, key: string)
	if key == 'Position' then
		return (self:Update(self._clock()))
	elseif key == 'Velocity' then
		return select(2, self:Update(self._clock()))
	elseif self[key] then
		return self[key]
	else
		error(string.format('%q is not a member of Spring', key), 2)
	end
end

function prototype.Set(self, key, value)
	local now = self._clock()

	local position, velocity = self:Update(now)

	if key == 'Position' then
		self._position = value
		self._velocity = velocity
	elseif key == 'Velocity' then
		self._position = position
		self._velocity = value
	else
		self._position = position
		self._velocity = velocity

		if key == 'Target' then
			self._target = value
		elseif key == 'Damper' then
			self._damper = value
		elseif key == 'Speed' then
			self._speed = value < 0 and 0 or value
		elseif key == 'Clock' then
			self._clock = value

			now = value()
		else
			error(string.format('%q is not a member of Spring', key), 2)
		end
	end

	self._time = now
end

meta.__index = prototype

meta.__tostring = function(self)
	return 'Instance of Spring'
end

function Spring.new(initial, clock)
	local target: any = initial or 0
	local clock = clock or os.clock

	local this = setmetatable({
		_clock = clock,
		_time = clock(),
		_position = target,
		_velocity = 0*target,
		_target = target,
		_damper = 1,
		_speed = 1
	}, meta)

	return this
end

function Spring.is(value: any): boolean
	return typeof(value) == 'table' and getmetatable(value) == meta
end

return Spring