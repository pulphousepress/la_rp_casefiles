-- 🐼 Berry Mason Head - Freemode Hybrid (Attachment Method)
-- Los Animales RP | v1.1 | Automatically attaches Berry's head to any ped.

local BERRY_MODEL = `head_001_r`
local ATTACH_BONE = 31086 -- SKEL_Head
local OFFSET = vector3(0.0, 0.01, 0.0)
local ROTATION = vector3(0.0, 0.0, 0.0)
local currentHead = nil

RegisterCommand("applyberryhead", function()
    local ped = PlayerPedId()
    print("[BerryHead] 🐼 Attempting to load Berry Mason head...")

    RequestModel(BERRY_MODEL)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(BERRY_MODEL) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(BERRY_MODEL) then
        print("[BerryHead] ❌ Failed to load model.")
        return
    end

    print("[BerryHead] ✅ Model loaded. Creating object...")

    local coords = GetEntityCoords(ped)
    local obj = CreateObject(BERRY_MODEL, coords.x, coords.y, coords.z, true, true, false)

    if not DoesEntityExist(obj) then
        print("[BerryHead] ❌ Failed to create Berry head object.")
        return
    end

    SetEntityCollision(obj, false, false)
    SetEntityCompletelyDisableCollision(obj, true, true)
    SetEntityVisible(obj, true, 0)
    SetEntityAsMissionEntity(obj, true, true)

    AttachEntityToEntity(obj, ped, GetPedBoneIndex(ped, ATTACH_BONE),
        OFFSET.x, OFFSET.y, OFFSET.z,
        ROTATION.x, ROTATION.y, ROTATION.z,
        false, false, false, false, 2, true)

    currentHead = obj
    print("[BerryHead] 🐼 Berry Mason head attached successfully!")
end, false)

RegisterCommand("removeberryhead", function()
    if currentHead and DoesEntityExist(currentHead) then
        DeleteEntity(currentHead)
        print("[BerryHead] 🧹 Removed Berry Mason head.")
    else
        print("[BerryHead] ⚠️ No head to remove.")
    end
end, false)
