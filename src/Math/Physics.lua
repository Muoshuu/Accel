--!strict

local Vector = require(script.Parent.Vector)

local physicsService = game:GetService('PhysicsService')

local Physics = {}

function Physics.getConnectedParts(part: BasePart): { BasePart }
	local parts = part:GetConnectedParts(true)

	table.insert(parts, part)

	return parts :: any
end

function Physics.getMass(parts)
	local mass = 0

	for _, part in pairs(parts) do
		mass += part:GetMass()
	end

	return mass
end

function Physics.estimateBuoyancyContribution(parts: { BasePart }, density: number?): (number, number, number)
	local totalFloat, totalMass, totalVolumeApplicable = 0, 0, 0

	for _, part in pairs(parts) do
		local mass = part:GetMass()

		totalFloat -= mass * workspace.Gravity
		totalMass += mass

		if part.CanCollide then
			local volume = Vector.volume(part.Size)

			totalFloat += volume * (density or 1) * workspace.Gravity
			totalVolumeApplicable += volume
		end
	end

	return totalFloat, totalMass, totalVolumeApplicable
end

function Physics.getCenterOfMass(parts: { BasePart }): (Vector3, number)
	local weightedSum, mass = Vector3.new(0, 0, 0), 0

	for _, part in pairs(parts) do
		mass += part:GetMass()
		weightedSum += part:GetMass() * part.Position
	end

	return weightedSum/mass, mass
end

local function getGroup(group: string | number)
	if typeof(group) == 'string' then
		return 
	end
end

type PhysicsGroup = { id: number, name: string } -- mask is internal

function Physics.getGroup(group: string | number): PhysicsGroup
	if typeof(group) == 'string' then
		local ok, groupId = pcall(Physics.getGroupId, group)
		
		if not ok then
			groupId = Physics.createGroup(group)
		end
		
		return { name = group, id = Physics.getGroupId(group) }
	else
		return { id = group, name = Physics.getGroupName(group) }
	end
end

function Physics.createGroup(name: string): number
	return physicsService:CreateCollisionGroup(name)
end

function Physics.removeGroup(group: string | number): ()
	return physicsService:RemoveCollisionGroup(Physics.getGroup(group).name)
end

function Physics.renameGroup(group: string | number, name: string): ()
	physicsService:RenameCollisionGroup(Physics.getGroup(group).name, name)
end

function Physics.setGroupsCollidable(groupA: string | number, groupB: string | number, state: boolean): ()
	physicsService:CollisionGroupSetCollidable(Physics.getGroup(groupA).name, Physics.getGroup(groupB).name, state)
end

function Physics.getGroupsCollidable(groupA: string | number, groupB: string | number): boolean
	return physicsService:CollisionGroupsAreCollidable(Physics.getGroup(groupA).name, Physics.getGroup(groupB).name)
end

function Physics.groupContainsPart(group: string | number, part: BasePart): boolean
	return physicsService:CollisionGroupContainsPart(Physics.getGroup(group).name, part)
end

function Physics.getGroupId(groupName: string): number
	return physicsService:GetCollisionGroupId(groupName)
end

function Physics.getGroupName(groupId: number): string
	return physicsService:GetCollisionGroupName(groupId)
end

function Physics.getGroups(): { PhysicsGroup }
	return physicsService:GetCollisionGroups()
end

function Physics.getMaxGroups(): number
	return physicsService:GetMaxCollisionGroups()
end

function Physics.setCollisionGroup(part: BasePart, group: string | number)
	physicsService:SetPartCollisionGroup(part, Physics.getGroup(group).name)
end

return Physics