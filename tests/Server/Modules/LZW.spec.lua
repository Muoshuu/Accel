local import = require(game:GetService('ReplicatedStorage'):WaitForChild('Accel'))

return function()
    local lzw = import 'LZW'

    it('should correctly compress & decompress data', function()
        local source = 'Hello hello hello hello hello hello'

        local compressed = lzw.compress(source)
        expect(compressed).to.be.ok()

        local decompressed = lzw.decompress(compressed)
        expect(decompressed).to.equal(source)
    end)
end