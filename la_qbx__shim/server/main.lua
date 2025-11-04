-- server/main.lua
local Framework = require('server/framework/qbx') -- requires our local file

-- expose as global for legacy scripts that call getCharID()
_G.getCharID = function(src)
    return Framework.GetCharID(src)
end

-- also expose a shorter alias used by some scripts
_G.getCharIDLegacy = _G.getCharID

-- Register as an export for modern usage
AddEventHandler('onServerResourceStart', function(resName)
    if resName == GetCurrentResourceName() then
        exports('GetCharID', function(src) return Framework.GetCharID(src) end)
        exports('GetPlayer', function(src) return Framework.GetPlayer(src) end)
    end
end)

print('la_qbx_shim: compatibility shim loaded (global getCharID + exports).')
