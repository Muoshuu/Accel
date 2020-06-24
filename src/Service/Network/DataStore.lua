return function(import)
    local create = import 'Create'
    local class = import 'Class'
    local dataStoreService = import 'DataStoreService'
    
    local Promise = import 'Class/Promise'

    local DataStore = class.new('DataStore') do
        function DataStore:init(name, scope, isOrdered)
            self.name = name
            self.scope = scope
            self.isOrdered = isOrdered

            if (isOrdered) then
                self.store = dataStoreService:GetOrderedDataStore(name, scope)
            else
                self.store = dataStoreService:GetDataStore(name, scope)
            end
        end

        do -- // Prototype
            function DataStore.prototype:execute(key, ...)
                local data = {...}

                return Promise.async(function(resolve, reject)
                    local result = { pcall(self.store[key], self.store, table.unpack(data)) }

                    if (result[1]) then
                        resolve(table.unpack(result, 2))
                    else
                        reject(result[2])
                    end
                end)
            end

            function DataStore.prototype:get(...)
                return self:execute('GetAsync', ...)
            end

            function DataStore.prototype:increment(...)
                return self:execute('IncrementAsync', ...)
            end

            function DataStore.prototype:set(...)
                return self:execute('SetAsync', ...)
            end

            function DataStore.prototype:unset(...)
                return self:execute('RemoveAsync', ...)
            end

            function DataStore.prototype:update(...)
                return self:execute('UpdateAsync', ...)
            end

            function DataStore.prototype:getSorted(...)
                return self:execute('GetSortedAsync', ...)
            end
        end
    end

    return DataStore
end
