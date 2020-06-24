local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local table = import 'Table'

    describe('Table.from', function()
        it('should return an array of the specified values', function()
            local array = table.from(1, 2, 3)

            expect(array).to.be.ok()
            expect(#array).to.equal(3)
        end)
    end)

    describe('Table.toJSON', function()
        it('should return a string from a dictionary or array', function()
            table.toJSON({ key = 'value', array = { 1, 2, 3, 4, 5 } })
        end)
    end)

    describe('Table.fromJSON', function()
        it('should return a dictionary or array from a JSON string', function()
            table.fromJSON('{"key":"value","array":[1,2,3,4,5]}')
        end)
    end)

    describe('Table.clone', function()
        local dictionary = {
            matrix = {
                { 1, 2, 3 },
                { 4, 5, 6 },
                { 7, 8, 9 }
            },

            value = 'hello world'
        }

        it('should correctly shallow clone of a dictionary or array', function()
            local clone = table.clone(dictionary, true)

            expect(clone).to.be.ok()
            expect(clone.matrix).to.equal(dictionary.matrix)
            expect(#clone.matrix).to.equal(3)
        end)

        it('should correctly deep clone of a dictionary or array', function()
            local clone = table.clone(dictionary)

            expect(clone).to.be.ok()
            expect(clone.matrix).never.to.equal(dictionary.matrix)
            expect(#clone.matrix).to.equal(3)
        end)
    end)

    describe('Table.wipe', function()
        it('should remove all keys and values from a table', function()
            local array = { 1, 2, 3, 4, 5 }

            table.wipe(array)

            expect(#array).to.equal(0)
        end)

        it('should remove the metatable as well when specified', function()
            local tbl = setmetatable({}, {})

            table.wipe(tbl, true)

            expect(getmetatable(tbl)).never.to.be.ok()
        end)
    end)

    describe('Table.push', function()
        it('should insert values at the end of an array', function()
            local array = { 'hey' }

            table.push(array, 'hello', 'world', '!')

            expect(array[1]).to.equal('hey')
            expect(array[2]).to.equal('hello')
            expect(array[3]).to.equal('world')
            expect(array[4]).to.equal('!')
            expect(#array).to.equal(4)
        end)
    end)

    describe('Table.pop', function()
        it('should remove and return the last element in an array', function()
            local array = { 'hello', 'world', '!' }
            local popped = table.pop(array)

            expect(popped).to.equal('!')
            expect(#array).to.equal(2)
        end)
    end)

    describe('Table.shift', function()
        it('should remove and return the first element in an array', function()
            local array = { 'hello', 'world', '!' }
            local shifted = table.shift(array)

            expect(shifted).to.equal('hello')
            expect(#array).to.equal(2)
        end)
    end)

    describe('Table.unshift', function()
        it('should insert values at the beginning of an array', function()
            local array = { '!' }

            table.unshift(array, 'world', 'hello', 'hey')

            expect(array[1]).to.equal('hey')
            expect(array[2]).to.equal('hello')
            expect(array[3]).to.equal('world')
            expect(array[4]).to.equal('!')
            expect(#array).to.equal(4)
        end)
    end)

    describe('Table.indexOf', function()
        it('should return the correct index of a value from an array', function()
            local array = { 'a', 'b', 'c', 'd', 'a' }
            local index = table.indexOf(array, 'c')
            
            expect(index).to.equal(3)
        end)
    end)

    describe('Table.indicesOf', function()
        it('should return the correct indices of a value from an array', function()
            local array = { 'a', 'b', 'c', 'd', 'a' }
            local indices = table.indicesOf(array, 'a')

            expect(indices).to.be.ok()
            expect(indices[1]).to.equal(1)
            expect(indices[2]).to.equal(5)
            expect(indices[3]).never.to.be.ok()
        end)
    end)

    describe('Table.find', function()
        it('should find the correct object in an array', function()
            local array = { { id = 1 }, { id = 2 }, { id = 3 }, { id = 4 } }
            
            expect(table.find(array, 'id', 2)).to.equal(array[2])
        end)
    end)

    describe('Table.findAll', function()
        it('should find the correct objects in an array', function()
            local array = { { type = 1 }, { type = 2 }, { type = 2 },  { type = 3 } }
            local objects = table.findAll(array, 'type', 2)

            expect(objects).to.be.ok()
            expect(objects[1]).to.equal(array[2])
            expect(objects[2]).to.equal(array[3])
            expect(objects[3]).never.to.be.ok()
        end)
    end)

    describe('Table.includes', function()
        it('should return whether a value is found in an array', function()
            local array = { 1, 3, 4, 5, 6, 7, 8 }

            expect(table.includes(array, 1)).to.equal(true)
            expect(table.includes(array, 2)).to.equal(false)
        end)
    end)

    describe('Table.keys', function()
        it('should return an array of keys from a dictionary', function()
            local dictionary = { key1 = 'value', key2 = 'value' }
            local keys = table.keys(dictionary)

            expect(keys[1]).to.equal('key1')
            expect(keys[2]).to.equal('key2')
            expect(#keys).to.equal(2)
        end)
    end)

    describe('Table.values', function()
        it('should return an array of values from a dictionary', function()
            local dictionary = { key1 = 1, key2 = 2 }
            local values = table.values(dictionary)

            expect(values[1]).to.equal(1)
            expect(values[2]).to.equal(2)
            expect(#values).to.equal(2)
        end)
    end)

    describe('Table.reverse', function()
        it('should reverse an array in-place', function()
            local array = { 1, 2, 3, 4, 5 }

            table.reverse(array)

            expect(array[1]).to.equal(5)
            expect(array[5]).to.equal(1)
        end)
    end)

    describe('Table.reversed', function()
        it('should return a reversed version of the passed array', function()
            local array = { 1, 2, 3, 4, 5 }
            local reversed = table.reversed(array)

            expect(reversed).to.be.ok()
            expect(reversed).never.to.equal(array)
            expect(reversed[1]).to.equal(5)
            expect(reversed[5]).to.equal(1)
        end)
    end)

    describe('Table.map', function()
        it('should return a new dictionary or array with re-mapped values', function()
            local values = { key = 5, 2, 10 }

            local mapped = table.map(values, function(value)
                return value * 10
            end)

            expect(mapped).to.be.ok()
            expect(mapped).never.to.equal(values)
            expect(mapped.key).to.equal(50)
            expect(mapped[1]).to.equal(20)
            expect(mapped[2]).to.equal(100)
        end)
    end)

    describe('Table.remap', function(self, fn)
        it('should re-map a dictionary or array in-place', function()
            local values = { key = 5, 2, 10 }

            table.remap(values, function(value)
                return value * 10
            end)

            expect(values.key).to.equal(50)
            expect(values[1]).to.equal(20)
            expect(values[2]).to.equal(100)
        end)
    end)

    describe('Table.filter', function()
        it('should return an array of values that matched the passed filter', function()
            local original = {
                { a = 1, b = 3 },
                { a = 4, b = 2 },
                { a = 4, b = 0 },
                { a = 0, b = 0 }
            }

            local filtered = table.filter(original, function(value)
                return value.a + value.b == 4
            end)

            expect(filtered).to.be.ok()
            expect(filtered[1]).to.equal(original[1])
            expect(filtered[2]).to.equal(original[3])
            expect(#filtered).to.equal(2)
        end)
    end)

    describe('Table.forEach', function()
        it('should iterate over every member of an array or dictionary', function()
            local array = { a = false, b = false }

            table.forEach(array, function(value, index)
                array[index] = not value
            end)

            expect(array.a).to.equal(true)
            expect(array.b).to.equal(true)
        end)
    end)

    describe('Table.expel', function()
        it('should remove all instances of the passed value', function()
            local array = { 9, 9, 1, 2, 9, 3, 4, 5, 6, 9, 9, 9, 9, 7, 8, 9 }

            table.expel(array, 9)

            expect(table.indexOf(array, 9)).never.to.be.ok()
        end)
    end)

    describe('Table.fromPages', function()
        it('should return an array of every item on every page from a Pages object', function()
            local fakePages = {
                IsFinished = false,

                index = 1,
                pages = {{{},{}},{{},{}},{{},{}},{{},{}}}
            }

            function fakePages:GetCurrentPage()
                return self.pages[self.index]
            end
            
            function fakePages:AdvanceToNextPageAsync()
                self.index += 1

                if (self.index >= #self.pages) then
                    self.IsFinished = true
                end
            end

            local array = table.fromPages(fakePages)

            expect(array[1]).to.equal(fakePages.pages[1][1])
            expect(array[2]).to.equal(fakePages.pages[1][2])
            expect(array[3]).to.equal(fakePages.pages[2][1])
            expect(array[4]).to.equal(fakePages.pages[2][2])
            expect(array[5]).to.equal(fakePages.pages[3][1])
            expect(array[6]).to.equal(fakePages.pages[3][2])
            expect(array[7]).to.equal(fakePages.pages[4][1])
            expect(array[8]).to.equal(fakePages.pages[4][2])
            expect(#array).to.equal(8)
        end)
    end)
end