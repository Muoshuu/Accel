local Class = {} do
    Class.list = {}

    local function find(array, value, key)
        for i, pair in pairs(array) do
            if pair[key] == value then
                return pair, i
            end
        end
    end

    local function guid(...)
        return game:GetService('HttpService'):GenerateGUID(...)
    end

    local meta = {
        weak = { __mode = 'v' },

        methods = {
            'add', 'sub', 'unm', 'mul', 'div', 'call', 'concat', 'mod', 'pow', 'eq', 'lt', 'le'
        },

        class = {
            __tostring = function(class)
                return 'Class: ' .. class.name
            end
        },

        __tostring = function(instance)
            if instance._class.meta.tostring then
                return instance._class.meta.tostring(instance)
            else
                return 'Instance of ' .. instance._class.name
            end
        end,

        __index = function(instance, key)
            if key:sub(1,3) ~= 'get' then
                local value = instance._class.prototype['get' .. key:gsub('^.', string.upper)]

                if type(value) == 'function' then
                    return value(instance)
                end
            end

            local pair = find(instance._properties, key, 'key')

            if pair then
                return pair.value
            else
                return instance._class.prototype[key]
            end
        end,

        __newindex = function(instance, key, value)
            local pair = find(instance._properties, key, 'key')
            local setter = instance._class.prototype['set' .. key:gsub('^.', string.upper)]

            if setter then
                value = setter(instance, value)
            end

            if pair then
                pair.value = value
            else
                table.insert(instance._properties, { key = key, value = value })
            end
        end
    }

    do -- // Custom metamethods
        local metaErrors = {
            ['add'] = 'arithmetic',
            ['sub'] = 'arithmetic',
            ['unm'] = 'arithmetic',
            ['mul'] = 'arithmetic',
            ['div'] = 'arithmetic',
            ['mod'] = 'arithmetic',
            ['pow'] = 'arithmetic',
            ['eq'] = 'comparison',
            ['lt'] = 'comparison',
            ['le'] = 'comparison'
        }

        for _, method in pairs(meta.methods) do
            meta['__' .. method] = function(self, ...)
                if self._class.meta[method] then
                    return self._class.meta[method](self, ...)
                else
                    local errType = metaErrors[method]

                    if errType == 'arithmetic' then
                        error(string.format('attempt to perform arithmetic (%s) on table and %s', method, type(...)))
                    elseif errType == 'comparison' then
                        error(string.format('attempt to compare table and %s', type(...)), 1)
                    elseif method == 'call' then
                        error('attempt to call a table value', 1)
                    elseif method == 'concat' then
                        error(string.format('attempt to concatenate table with %s', type(...)), 1)
                    end
                end
            end
        end
    end

    local function instantiate(class, ...)
        local instance = {
            _id = guid(),
            _class = class,
            _properties = {}
        }

        setmetatable(instance, meta)

        local init = class.init

        if init then
            local result, other = init(instance, ...)

            if result == 'nevermind' then
                instance:destroy()

                return other
            end
        end

        table.insert(class.instances, instance)

        return instance
    end

    local function delete(object, key)
        local _, index = find(object._properties, key, 'key')
        
        if index then
            table.remove(object._properties, index)
        end
    end

    local function iter(object)
        local index = 0

        return function()
            index += 1

            local property = object._properties[index]

            if property then
                return property.key, property.value
            end
        end
    end

    local function destroy(object)
        for key in object:iter() do
            object:delete(key)
        end

        for key in pairs(object) do
            rawset(object, key, nil)
        end
        
        setmetatable(object, nil)
    end

    local function toJSON(object)
        local tbl = {}

        for key, value in object:iter() do
            tbl[key] = value
        end

        return game:GetService('HttpService'):JSONEncode(tbl)
    end

    function Class.new(name)
        local this = {
            name = name,

            meta = {},

            instances = setmetatable({}, meta.weak),

            prototype = {
                iter = iter,
                delete = delete,
                destroy = destroy,
                toJSON = toJSON
            },

            iter = iter,
            destroy = destroy,
        }

        function this.new(...)
            return instantiate(this, ...)
        end

        Class.list[name] = this

        return setmetatable(this, meta.class)
    end

    function Class.get(name)
        return Class.list[name]
    end
end

return Class