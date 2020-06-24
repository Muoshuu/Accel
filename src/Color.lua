local color; color = {
    fromRGB = Color3.fromRGB,

    toRGB = function(value)
        return math.floor(value.r), math.floor(value.g), math.floor(value.b)
    end,

    fromHSV = Color3.fromHSV,
    toHSV = Color3.toHSV,

    fromHex = function(value)
        return color.fromInt(tonumber(value, 16))
    end,

    toHex = function(value)
        return string.format('%x', color.toInt(value))
    end,

    fromInt = function(value)
        return Color3.fromRGB(math.floor(value/65536), math.floor(value/256)%256, value%256)
    end,

    toInt = function(value)
        return math.floor((16711680 * value.r + 65280 * value.g + 255 * value.b) + 0.5)
    end,

    unpack = function(value)
        return value.r, value.g, value.b
    end
}

return color