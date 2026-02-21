-- Database.lua - Handles saved variables and database initialization

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- Default settings
addon.defaults = {
    enabled = true,
    autoApply = true,
    showMinimapButton = true,
    dynamicPitch = true,
    headMovementStrength = 2,
    headMovementRange = 10,
    headMovementStandingStrength = 1,
    overShoulder = 1.2,
    targetFocusEnemy = true,
    targetFocusInteract = true,
    minimapPos = 220,
}

-- Initialize saved variables
function addon:InitializeDB()
    if not ExpCameraTweaksDB then
        ExpCameraTweaksDB = {}
    end
    for key, value in pairs(self.defaults) do
        if ExpCameraTweaksDB[key] == nil then
            ExpCameraTweaksDB[key] = value
        end
    end
    self.db = ExpCameraTweaksDB
end

-- Reset database to defaults
function addon:ResetDB()
    for key, value in pairs(self.defaults) do
        ExpCameraTweaksDB[key] = value
    end
    self.db = ExpCameraTweaksDB
end
