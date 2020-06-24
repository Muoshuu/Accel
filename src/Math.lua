local original, math = math, {
    e = 2.718281828459045,

    round = function(n, precision)
        precision = 10^(precision or 0)

        return math.floor(n * precision + 0.5)/precision
    end
}

for k, v in pairs(original) do
    math[k] = math[k] or v
end

return math