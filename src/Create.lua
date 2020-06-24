return function(import)
    local create = {} do
        function create:__call(class, parent, name)
            return function(properties)
                local instance = Instance.new(class)

                instance.Name = name or instance.Name

                if (properties) then
                    for property, value in pairs(properties) do
                        local propertyType = type(property)

                        if (property == 'Parent') then
                            parent = value
                        elseif (propertyType == 'number' and typeof(value) == 'Instance') then
                            value.Parent = instance
                        elseif (propertyType == 'function' and not property:match('Invoke')) then
                            instance[property]:Connect(value)
                        else
                            instance[property] = value
                        end
                    end
                end

                instance.Parent = parent

                return instance
            end
        end

        function create.folder(parent, name)
            local folder = Instance.new('Folder')
                folder.Name = name
                folder.Parent = parent

            return folder
        end

        setmetatable(create, create)
    end

    return create
end