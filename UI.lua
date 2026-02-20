-- UI.lua - Settings panel interface

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- Create settings panel
function addon:CreateSettingsPanel()
    local db = self.db or ExpCameraTweaksDB
    local panel = CreateFrame("Frame", "ExpCameraTweaksPanel", UIParent)
    panel.name = "Experimental Camera Tweaks"
    
    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Experimental Camera Tweaks")
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", 16, -50)
    enableCheck.Text:SetText("Enable ActionCam")
    enableCheck:SetChecked(db.enabled)
    enableCheck:SetScript("OnClick", function(self)
        db.enabled = self:GetChecked()
        if db.enabled then
            addon:ApplySettings()
        else
            addon:DisableSettings()
        end
    end)
    
    -- Auto-apply checkbox
    local autoApplyCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    autoApplyCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -8)
    autoApplyCheck.Text:SetText("Auto-apply on login")
    autoApplyCheck:SetChecked(db.autoApply)
    autoApplyCheck:SetScript("OnClick", function(self)
        db.autoApply = self:GetChecked()
    end)
    
    -- Dynamic Pitch checkbox
    local dynamicPitchCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    dynamicPitchCheck:SetPoint("TOPLEFT", autoApplyCheck, "BOTTOMLEFT", 0, -8)
    dynamicPitchCheck.Text:SetText("Dynamic Camera Pitch")
    dynamicPitchCheck:SetChecked(db.dynamicPitch)
    dynamicPitchCheck:SetScript("OnClick", function(self)
        db.dynamicPitch = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Head Movement Strength slider
    local headStrengthSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    headStrengthSlider:SetPoint("TOPLEFT", dynamicPitchCheck, "BOTTOMLEFT", 0, -40)
    headStrengthSlider:SetMinMaxValues(0, 5)
    headStrengthSlider:SetValue(db.headMovementStrength)
    headStrengthSlider:SetValueStep(0.5)
    headStrengthSlider:SetObeyStepOnDrag(true)
    headStrengthSlider:SetWidth(200)
    headStrengthSlider.Text:SetText("Head Movement Strength")
    headStrengthSlider.Low:SetText("0")
    headStrengthSlider.High:SetText("5")
    headStrengthSlider.Value = headStrengthSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    headStrengthSlider.Value:SetPoint("TOP", headStrengthSlider, "BOTTOM", 0, 0)
    headStrengthSlider.Value:SetText(db.headMovementStrength)
    headStrengthSlider:SetScript("OnValueChanged", function(self, value)
        db.headMovementStrength = value
        self.Value:SetText(string.format("%.1f", value))
        addon:ApplySettings()
    end)
    
    -- Head Movement Range slider
    local headRangeSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    headRangeSlider:SetPoint("TOPLEFT", headStrengthSlider, "BOTTOMLEFT", 0, -40)
    headRangeSlider:SetMinMaxValues(0, 20)
    headRangeSlider:SetValue(db.headMovementRange)
    headRangeSlider:SetValueStep(1)
    headRangeSlider:SetObeyStepOnDrag(true)
    headRangeSlider:SetWidth(200)
    headRangeSlider.Text:SetText("Head Movement Range")
    headRangeSlider.Low:SetText("0")
    headRangeSlider.High:SetText("20")
    headRangeSlider.Value = headRangeSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    headRangeSlider.Value:SetPoint("TOP", headRangeSlider, "BOTTOM", 0, 0)
    headRangeSlider.Value:SetText(db.headMovementRange)
    headRangeSlider:SetScript("OnValueChanged", function(self, value)
        db.headMovementRange = value
        self.Value:SetText(tostring(value))
        addon:ApplySettings()
    end)
    
    -- Over-Shoulder slider
    local shoulderSlider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
    shoulderSlider:SetPoint("TOPLEFT", headRangeSlider, "BOTTOMLEFT", 0, -40)
    shoulderSlider:SetMinMaxValues(0, 3)
    shoulderSlider:SetValue(db.overShoulder)
    shoulderSlider:SetValueStep(0.1)
    shoulderSlider:SetObeyStepOnDrag(true)
    shoulderSlider:SetWidth(200)
    shoulderSlider.Text:SetText("Over-Shoulder Offset")
    shoulderSlider.Low:SetText("0")
    shoulderSlider.High:SetText("3")
    shoulderSlider.Value = shoulderSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    shoulderSlider.Value:SetPoint("TOP", shoulderSlider, "BOTTOM", 0, 0)
    shoulderSlider.Value:SetText(string.format("%.1f", db.overShoulder))
    shoulderSlider:SetScript("OnValueChanged", function(self, value)
        db.overShoulder = value
        self.Value:SetText(string.format("%.1f", value))
        addon:ApplySettings()
    end)
    
    -- Target Focus Enemy checkbox
    local targetEnemyCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    targetEnemyCheck:SetPoint("TOPLEFT", shoulderSlider, "BOTTOMLEFT", 0, -40)
    targetEnemyCheck.Text:SetText("Target Focus: Enemies")
    targetEnemyCheck:SetChecked(db.targetFocusEnemy)
    targetEnemyCheck:SetScript("OnClick", function(self)
        db.targetFocusEnemy = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Target Focus Interact checkbox
    local targetInteractCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    targetInteractCheck:SetPoint("TOPLEFT", targetEnemyCheck, "BOTTOMLEFT", 0, -8)
    targetInteractCheck.Text:SetText("Target Focus: Interactables")
    targetInteractCheck:SetChecked(db.targetFocusInteract)
    targetInteractCheck:SetScript("OnClick", function(self)
        db.targetFocusInteract = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", targetInteractCheck, "BOTTOMLEFT", 0, -20)
    resetBtn:SetWidth(150)
    resetBtn:SetHeight(25)
    resetBtn:SetText("Reset to Defaults")
    resetBtn:SetScript("OnClick", function()
        addon:ResetDB()
        -- Refresh UI
        enableCheck:SetChecked(db.enabled)
        autoApplyCheck:SetChecked(db.autoApply)
        dynamicPitchCheck:SetChecked(db.dynamicPitch)
        headStrengthSlider:SetValue(db.headMovementStrength)
        headRangeSlider:SetValue(db.headMovementRange)
        shoulderSlider:SetValue(db.overShoulder)
        targetEnemyCheck:SetChecked(db.targetFocusEnemy)
        targetInteractCheck:SetChecked(db.targetFocusInteract)
        addon:ApplySettings()
    end)
    
    -- Register panel with Interface Options (supports both old and new systems)
    if Settings and Settings.RegisterCanvasLayoutCategory then
        -- Dragonflight (10.0+) style
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        -- Legacy style
        InterfaceOptions_AddCategory(panel)
    end
    
    return panel
end
