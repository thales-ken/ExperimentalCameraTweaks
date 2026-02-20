-- Settings.lua - Handles camera settings application

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- Apply ActionCam settings
function addon:ApplySettings()
    local db = self.db or ExpCameraTweaksDB
    if not db.enabled then return end
    
    -- Dynamic pitch
    SetCVar("test_cameraDynamicPitch", db.dynamicPitch and "1" or "0")
    
    -- Head movement
    SetCVar("test_cameraHeadMovementStrength", tostring(db.headMovementStrength))
    SetCVar("test_cameraHeadMovementRangeScale", tostring(db.headMovementRange))
    SetCVar("test_cameraHeadMovementMovingStrength", "1")
    SetCVar("test_cameraHeadMovementStandingStrength", "1")
    
    -- Over-shoulder
    SetCVar("test_cameraOverShoulder", tostring(db.overShoulder))
    
    -- Dynamic pitch FOV padding
    SetCVar("test_cameraDynamicPitchBaseFovPad", "0.4")
    SetCVar("test_cameraDynamicPitchBaseFovPadFlying", "0.75")
    SetCVar("test_cameraDynamicPitchBaseFovPadDownScale", "0.35")
    
    -- Target focus
    SetCVar("test_cameraTargetFocusEnemyEnable", db.targetFocusEnemy and "1" or "0")
    SetCVar("test_cameraTargetFocusInteractEnable", db.targetFocusInteract and "1" or "0")
    SetCVar("test_cameraTargetFocusEnemyStrengthYaw", "1")
    SetCVar("test_cameraTargetFocusEnemyStrengthPitch", "1")
end

-- Disable ActionCam settings (reset to default camera)
function addon:DisableSettings()
    -- Reset all ActionCam CVars to default (disabled) values
    SetCVar("test_cameraDynamicPitch", "0")
    SetCVar("test_cameraHeadMovementStrength", "0")
    SetCVar("test_cameraHeadMovementRangeScale", "5")
    SetCVar("test_cameraHeadMovementMovingStrength", "0")
    SetCVar("test_cameraHeadMovementStandingStrength", "0")
    SetCVar("test_cameraOverShoulder", "0")
    SetCVar("test_cameraDynamicPitchBaseFovPad", "0")
    SetCVar("test_cameraDynamicPitchBaseFovPadFlying", "0")
    SetCVar("test_cameraDynamicPitchBaseFovPadDownScale", "0")
    SetCVar("test_cameraTargetFocusEnemyEnable", "0")
    SetCVar("test_cameraTargetFocusInteractEnable", "0")
    SetCVar("test_cameraTargetFocusEnemyStrengthYaw", "0")
    SetCVar("test_cameraTargetFocusEnemyStrengthPitch", "0")
end
