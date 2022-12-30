--!strict

local httpService = game:GetService('HttpService')

local Maid = {}

local prototype = {}
local meta = {}

prototype.ClassName = 'Maid'

function prototype.Give(self: Maid, task: any, taskName: string?): string
	local taskId: string = taskName or httpService:GenerateGUID()
	
	self.Tasks[taskId] = task
	
	if type(task) == 'table' and not (task.Destroy or task.destroy or task.Disconnect or task.disconnect) then
		warn(string.format('Task %q passed to Maid.GiveTask does not have a Destroy method\n\n%s', taskId, debug.traceback()))
	end
	
	return taskId
end

function prototype.Run(self: Maid, taskName: string)
	local task = self.Tasks[taskName]
	
	if task then
		local taskType = typeof(task)

		if taskType == 'function' then
			task()
		elseif taskType == 'RBXScriptConnection' then
			task:Disconnect()
		elseif taskType == 'table' or taskType == 'Instance' then
			if Maid.isMaid(task) then
				task:Clean()
			else
				local realTask = task.Destroy or task.destroy or task.Disconnect or task.disconnect

				if realTask then
					realTask(task)
				end
			end
		end
	end
end

function prototype.Clean(self: Maid, taskName: string?)
	if taskName then
		self:Run(taskName)
		
		self.Tasks[taskName] = nil
	else
		local tasks = self.Tasks

		for i, task in pairs(tasks) do
			if typeof(task) == 'RBXScriptConnection' then
				tasks[i] = nil

				task:Disconnect()
			end
		end

		local i, task = next(tasks)

		while task ~= nil do
			self:Run(i or '')

			tasks[i or ''] = nil

			i, task = next(tasks)
		end
	end
end

prototype.Destroy = prototype.Clean

meta.__index = prototype

meta.__tostring = function(self: Maid): string
	return 'Instance of Maid'
end

export type Maid = typeof(setmetatable({
	Tasks = {} :: { [string]: any }
	
}, meta))

function Maid.new(): Maid
	local this = setmetatable({
		Tasks = {}
		
	}, meta)

	return this
end

function Maid.isMaid(value: any): boolean
	return type(value) == 'table' and getmetatable(value) == meta
end

return Maid