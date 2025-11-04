-- resources/la_syntax_check/server/main.lua
-- Safe syntax checker for a target resource file using LoadResourceFile + load

local targetResource = 'evidences'
local targetFilePath = 'client/evidences/utils.lua' -- relative to the evidences resource root

local function checkSyntax(resName, relPath)
    -- read file contents
    local content = LoadResourceFile(resName, relPath)
    if not content then
        print(("[la_syntax_check] ERROR: Could not read %s from resource %s (LoadResourceFile returned nil)."):format(relPath, resName))
        return false, "file-not-found"
    end

    -- attempt to compile the chunk (load returns compiled chunk or error message)
    local chunk, err = load(content, ("@%s/%s"):format(resName, relPath))
    if not chunk then
        print(("[la_syntax_check] SYNTAX ERROR in %s/%s -> %s"):format(resName, relPath, tostring(err)))
        -- err usually contains "attempt to ... near '<eof>'" with line info
        return false, err
    end

    print(("[la_syntax_check] OK: %s/%s parsed without syntax errors."):format(resName, relPath))
    return true, nil
end

Citizen.CreateThread(function()
    Citizen.Wait(1500) -- let resources initialize a bit
    local ok, err = checkSyntax(targetResource, targetFilePath)
    if not ok then
        print('--- la_syntax_check: copy the above error and open the file; common fixes: missing ")" or "end", unterminated string, or truncated file. ---')
    else
        print('--- la_syntax_check: file parsed okay. If evidences still fails, re-run this check for other files listed in the stack trace. ---')
    end
end)
