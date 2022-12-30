--!strict

local Signal = require(script.Parent.Signal)

local Timer = {}

local prototype = {}
local meta = {}

function prototype.Restart(self: Timer, duration: number?)
	local epoch = tick()
	
	self.Epoch = epoch
	
	if duration then
		self.Duration = duration
	end
	
	if self._thread then
		task.cancel(self._thread)
	end
	
	self._thread = task.delay(self.Duration, function()
		if self.Epoch == epoch then
			self.Complete:Fire(tick()-epoch)
			
			self.Epoch = -1
		end
	end)
end

function prototype.IsComplete(self: Timer): boolean
	return self.Epoch == -1
end

meta.__index = prototype

meta.__tostring = function(self: Timer): string
	return 'Timer'
end

export type Timer = typeof(setmetatable({
	Duration = 0,
	Epoch = 0,
	Complete = Signal.new(),
	_thread = (nil :: any) :: thread?
	
}, meta))

function Timer.new(duration: number): Timer
	local this = setmetatable({
		Duration = duration,
		Epoch = -1,
		Complete = Signal.new(),
		_thread = nil
		
	}, meta)
	
	this:Restart()

	return this
end

return Timer