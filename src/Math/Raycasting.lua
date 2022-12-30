local Raycasting = {} do
	-- https://gamedev.stackexchange.com/questions/96459/fast-ray-sphere-collision-code
	
	function Raycasting.getSphereIntersection(center: Vector3, radius: number, ray: Ray)
		local m = ray.Origin-center
		local b = m:Dot(ray.Unit.Direction)
		local c = m:Dot(m)-radius^2
		
		if c > 0 and b > 0 then
			return nil
		end
		
		local discr   = b*b-c
		
		if discr < 0 then
			return nil
		end
		
		local t = math.max(0, -b-math.sqrt(discr))
		
		return ray.Origin + ray.Unit.Direction * t, t
	end
	
	function Raycasting.sphereIntersectsRay(center: Vector3, radius: number, ray: Ray)
		local relOrigin = ray.Origin - center
		local rr = relOrigin:Dot(relOrigin)
		local dr = ray.Direction:Dot(relOrigin)
		local dd = ray.Direction:Dot(ray.Direction)

		local passTime = -dr/dd
		local passDist2 = rr - dr*dr/dd

		if passDist2 <= radius^2 then
			local offset = math.sqrt((radius^2 - passDist2)/dd)
			local t0 = passTime - offset
			local t1 = passTime + offset

			if t0 <= 1 and t1 >= 0 then
				return true
			end
		end

		return false
	end
	
	function Raycasting.getPlaneIntersection(origin: Vector3, normal: Vector3, ray: Ray)
		local dot = ray.Unit.Direction:Dot(normal)
		
		if dot == 0 then
			return nil
		end
		
		local t = -(ray.Origin-origin):Dot(normal)/dot
		
		return ray.Origin+t*ray.Unit.Direction, t
	end
end

return Raycasting