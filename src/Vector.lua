return {
    toSpherical = function(x, y, z)
        if typeof(x) == 'Vector3' then
            x, y, z = x.X, x.Y, x.Z
        end

        local rho = (x^2+y^2+z^2)^0.5

        return rho, math.acos(z/rho), math.atan2(y, x)
    end,

    fromSpherical = function(rho, theta, phi)
        return Vector3.new(
            rho*math.sin(theta)*math.cos(phi),
            rho*math.sin(theta)*math.sin(phi),
            rho*math.cos(theta)
        )
    end,

    new = function(x, y, z)
        return (z and Vector3.new(x, y, z)) or Vector2.new(x, y)
    end,

    from2 = Vector2.new,
    from3 = Vector3.new,

    fromNormal = Vector3.FromNormalId,
    fromAxis = Vector3.FromAxis,

    from2_16 = Vector2int16.new,
    from3_16 = Vector3int16.new,

    unpack = function(v)
        local ok, z = pcall(function()
            return v.Z
        end)

        return v.X, v.Y, ok and z or nil
    end
}