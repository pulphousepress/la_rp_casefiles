local MedicalClient = require("la_medical.client")
local cfg = require("config")

local result = MedicalClient.init(cfg)
if not result or not result.ok then
    print("[la_medical_standalone] failed to initialize: " .. (result and result.err or 'unknown'))
end
