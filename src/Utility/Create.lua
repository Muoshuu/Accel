--!strict

type Properties = { [number | string]: any }?

return {
	new = function(className: string, parent: Instance?)
		return function(properties: Properties): any
			local instance = Instance.new(className)

			if properties then
				local finalizers = {}
				
				local attributes = properties.Attributes
				
				if attributes then
					properties.Attributes = nil
				end

				for key, value in pairs(properties) do
					if typeof(key) == 'number' then
						local vType = typeof(value)

						if vType == 'Instance' then
							value.Parent = instance
						elseif vType == 'function' then
							table.insert(finalizers, value)
						end
					else
						if key:lower() == 'parent' then
							parent = value
						elseif typeof(instance[key]) == 'RBXScriptSignal' then
							warn('connected to signal ' .. key .. ' in', instance:GetFullName())
							instance[key]:Connect(value)
						else
							instance[key] = value
						end
					end
				end
				
				if attributes then
					for attributeKey, attributeValue in pairs(attributes) do
						instance:SetAttribute(attributeKey, attributeValue)
					end
				end

				if parent then
					instance.Parent = parent
				end

				for _, finalizer in pairs(finalizers) do
					finalizer(instance)
				end
			end

			return instance
		end
	end
}