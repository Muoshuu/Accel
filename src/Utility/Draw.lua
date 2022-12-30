--!strict

local workspace = game:GetService('Workspace')
local runService = game:GetService('RunService')
local textService = game:GetService('TextService')

local terrain = workspace.Terrain

local Create = require(script.Parent.Create)

local Draw = {}

Draw.defaultColor = Color3.new(1, 0, 0)
Draw.defaultContainer = (runService:IsRunning() and runService:IsServer() and workspace) or workspace.CurrentCamera

type DrawOptions = {
	name: string?,
	color: Color3?,
	container: Instance?,
	diameter: number?,
	foreground: Color3?,
	background: Color3?
}

function Draw.ray(ray: Ray, options: DrawOptions): Part
	local color = options.color or Draw.defaultColor
	local container = options.container or Draw.defaultContainer
	local diameter = options.diameter or 0.4

	local rayCenter = ray.Origin + ray.Direction/2

	return Create.new('Part') {
		Parent = container,
		Material = Enum.Material.SmoothPlastic,
		Color = color,
		Anchored = true,
		Archivable = false,
		CanCollide = false,
		CastShadow = false,
		CFrame = CFrame.new(rayCenter, ray.Origin + ray.Direction) * CFrame.Angles(math.pi/2, 0, 0),
		Name = options.name or 'DebugRay',
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(diameter, ray.Direction.Magnitude, diameter),
		TopSurface = Enum.SurfaceType.Smooth,

		Create.new('SpecialMesh') {
			Scale = Vector3.new(diameter, 1, diameter)
		}
	} :: Part
end

local function drawOnAdornee(adornee: Instance, text: string, options: DrawOptions)
	local TEXT_HEIGHT_STUDS = 2
	local PADDING_PERCENT_OF_LINE_HEIGHT = 0.5

	local background = options.background or Draw.defaultColor
	local foreground = options.foreground

	if not foreground then
		foreground = Color3.new(1-background.R, 1-background.G, 1-background.B)
	end

	local billboardGui = Create.new('BillboardGui') {
		Name = options.name or 'DebugBillboardGui',
		Parent = adornee,

		SizeOffset = Vector2.new(0, 0.5),
		ExtentsOffset = Vector3.new(0, 1, 0),
		AlwaysOnTop = true,
		Adornee = adornee,
		StudsOffset = Vector3.new(0, 0, 0.01),

		Create.new('Frame') {
			Name = 'Background',

			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0.5, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			BackgroundColor3 = background,

			Create.new('TextLabel') {
				Text = tostring(text),
				TextScaled = true,
				TextSize = 32,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				TextColor3 = foreground,
				Size = UDim2.new(1, 0, 1, 0)
			}
		}
	}

	local frame = billboardGui.Background
	local label = frame.TextLabel

	label.Font = if tonumber(text) then Enum.Font.Code else Enum.Font.GothamSemibold

	local textSize = textService:GetTextSize(label.Text, label.TextSize, label.Font, Vector2.new(1024, 1e6))
	local lines = textSize.Y/label.TextSize

	local paddingOffset = label.TextSize * PADDING_PERCENT_OF_LINE_HEIGHT

	local paddedWidth = textSize.X + 2*paddingOffset
	local paddedHeight = textSize.Y + 2*paddingOffset

	local aspectRatio = paddedWidth/paddedHeight

	Create.new('UIAspectRatioConstraint') { Parent = frame, AspectRatio = aspectRatio }

	Create.new('UIPadding') {
		Parent = frame,

		PaddingBottom = UDim.new(paddingOffset/paddedHeight, 0),
		PaddingTop = UDim.new(paddingOffset/paddedHeight, 0),
		PaddingLeft = UDim.new(paddingOffset/paddedWidth, 0),
		PaddingRight = UDim.new(paddingOffset/paddedWidth, 0)
	}

	Create.new('UICorner') { Parent = frame, CornerRadius = UDim.new(paddingOffset/paddedHeight/2, 0) }

	local height = lines * TEXT_HEIGHT_STUDS * TEXT_HEIGHT_STUDS * PADDING_PERCENT_OF_LINE_HEIGHT

	billboardGui.Size = UDim2.new(height * aspectRatio, 0, height, 0)

	return billboardGui
end

function Draw.text(text: string, options: DrawOptions)
	local adornee = options.container

	if typeof(adornee) == 'Vector3' then
		adornee = Create.new('Attachment', terrain) { Name = 'DebugTextAttachment', WorldPosiiton = adornee }
	end

	return drawOnAdornee(adornee :: Instance, text, options)
end

function Draw.point(point: Vector3 | CFrame, options: DrawOptions)
	local point: Vector3 = if typeof(point) == 'CFrame' then point.Position else point
	local color = options.color or Draw.defaultColor
	local container = options.container or Draw.defaultContainer
	local diameter = options.diameter or 1

	return Create.new('Part', container) {
		Material = Enum.Material.ForceField,
		Anchored = true,
		Archivable = false,
		CanCollide = false,
		CastShadow = false,
		CFrame = CFrame.new(point),
		Color = color,
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(diameter, diameter, diameter),
		BottomSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,

		Name = 'DebugPoint',

		Create.new('SphereHandleAdornment') {
			Archivable = false,
			Radius = diameter/4,
			Color3 = color,
			AlwaysOnTop = true,
			ZIndex = 2
		},

		function(self)
			self.SphereHandleAdornment.Adornee = self
		end
	}
end

function Draw.labeledPoint(point: Vector3 | CFrame, text: string, options: DrawOptions)
	local part = Draw.point(point, options)

	options.container = part

	Draw.text(text, options)

	return part
end

function Draw.cframe(cframe: CFrame, options: DrawOptions, reverse: boolean?)
	local position = cframe.Position
	local diameter = options.diameter or 0.2

	local model = Create.new('Model') { Name = options.name or 'DebugCFrame' }

	Draw.ray(Ray.new(position, cframe.XVector*(diameter*10)), {
		name = 'XVector',
		color = Color3.new(0.75, 0.25, 0.25),
		diameter = diameter,
		container = model
	})

	Draw.ray(Ray.new(position, cframe.YVector*(diameter*10)), {
		name = 'YVector',
		color = Color3.new(0.25, 0.75, 0.25),
		diameter = diameter,
		container = model
	})

	-- Positive Z is back but it makes more sense to show front
	Draw.ray(Ray.new(position, -cframe.ZVector*(diameter*10)), {
		name = 'ZVector',
		color = Color3.new(0.25, 0.25, 0.75),
		diameter = diameter,
		container = model
	})

	Draw.point(position, {
		color = options.color,
		container = model,
		diameter = diameter
	})

	model.Parent = options.container or Draw.defaultContainer

	return model
end

function Draw.box(location: CFrame | Vector3, size: Vector3, options: DrawOptions)
	local color = options.color or Draw.defaultColor
	local cframe: CFrame = if typeof(location) == 'Vector3' then CFrame.new(location) else location

	return Create.new('Part', options.container or Draw.defaultContainer) {
		Color = color,
		Material = Enum.Material.ForceField,
		Anchored = true,
		CanCollide = false,
		CastShadow = false,
		Archivable = false,
		BottomSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		Transparency = 0.75,
		Size = size,
		CFrame = cframe,
		
		Name = options.name or 'DebugPart',

		Create.new('BoxHandleAdornment') {
			Size = size,
			Color3 = color,
			AlwaysOnTop = true,
			Transparency = 0.75,
			ZIndex = 1
		},

		function(self)
			self.BoxHandleAdornment.Adornee = self
		end
	}
end

function Draw.labeledBox(cframe: CFrame, size: Vector3, text: string, options: DrawOptions)
	local part = Draw.box(cframe, size, options)

	options.container = part

	Draw.text(text, options)

	return part
end

function Draw.region(region: Region3, options: DrawOptions)
	return Draw.box(region.CFrame, region.Size, options)
end

function Draw.labeledRegion(region: Region3, text: string, options: DrawOptions)
	local part = Draw.box(region.CFrame, region.Size, options)

	options.container = part

	Draw.text(text, options)

	return part
end

function Draw.terrainCell(position: Vector3, options: DrawOptions)
	local size = Vector3.new(4, 4, 4)

	local solidCell = terrain:WorldToCell(position)
	local terrainPosition = terrain:CellCenterToWorld(solidCell.X, solidCell.Y, solidCell.Z)

	local part = Draw.box(CFrame.new(terrainPosition), size, options)

	part.Name = options.name or 'DebugTerrainCell'

	return part
end

function Draw.vector(position: Vector3, direction: Vector3, options: DrawOptions)
	return Draw.ray(Ray.new(position, direction), options)
end

return Draw