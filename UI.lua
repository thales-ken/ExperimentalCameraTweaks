-- UI.lua - Settings panel interface

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- Create settings panel
function addon:CreateSettingsPanel()
    local db = self.db or ExpCameraTweaksDB
    local panel = CreateFrame("Frame", "ExpCameraTweaksPanel", UIParent)
    panel.name = "Experimental Camera Tweaks"
    
    -- Create ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 3, -4)
    scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)
    
    -- Create content frame (scroll child)
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(scrollFrame:GetWidth() - 20)
    scrollFrame:SetScrollChild(content)
    
    -- Title
    local title = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Experimental Camera Tweaks")
    
    -- Separator line before General
    local separatorTitle = content:CreateTexture(nil, "ARTWORK")
    separatorTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
    separatorTitle:SetSize(600, 1)
    separatorTitle:SetColorTexture(0.25, 0.25, 0.25, 1)
    
    -- General category header
    local generalHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    generalHeader:SetPoint("TOPLEFT", separatorTitle, "BOTTOMLEFT", 0, -10)
    generalHeader:SetText("General")
    
    -- Enable checkbox
    local enableCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    enableCheck:SetPoint("TOPLEFT", generalHeader, "BOTTOMLEFT", 10, -20)
    enableCheck.Text:SetText("Enable ActionCam")
    enableCheck:SetChecked(db.enabled)
    enableCheck:SetScript("OnClick", function(self)
        db.enabled = self:GetChecked()
        if db.enabled then
            addon:ApplySettings()
        else
            addon:DisableSettings()
        end
        addon:UpdateMinimapButton()
    end)
    
    -- Auto-apply checkbox
    local autoApplyCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    autoApplyCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -8)
    autoApplyCheck.Text:SetText("Auto-apply on login")
    autoApplyCheck:SetChecked(db.autoApply)
    autoApplyCheck:SetScript("OnClick", function(self)
        db.autoApply = self:GetChecked()
    end)
    
    -- Show minimap button checkbox
    local showMinimapCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    showMinimapCheck:SetPoint("TOPLEFT", autoApplyCheck, "BOTTOMLEFT", 0, -8)
    showMinimapCheck.Text:SetText("Show minimap icon")
    showMinimapCheck:SetChecked(db.showMinimapButton)
    showMinimapCheck:SetScript("OnClick", function(self)
        db.showMinimapButton = self:GetChecked()
        addon:UpdateMinimapButtonVisibility()
    end)
    
    -- Separator line after General
    local separator0 = content:CreateTexture(nil, "ARTWORK")
    separator0:SetPoint("TOPLEFT", showMinimapCheck, "BOTTOMLEFT", -10, -15)
    separator0:SetSize(600, 1)
    separator0:SetColorTexture(0.25, 0.25, 0.25, 1)
    
    -- Head Movement category header
    local headMovementHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    headMovementHeader:SetPoint("TOPLEFT", separator0, "BOTTOMLEFT", 0, -10)
    headMovementHeader:SetText("Head Movement")
    
    -- Head Movement Strength slider
    local headStrengthSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    headStrengthSlider:SetPoint("TOPLEFT", headMovementHeader, "BOTTOMLEFT", 10, -30)
    headStrengthSlider:SetMinMaxValues(0, 5)
    headStrengthSlider:SetValue(db.headMovementStrength)
    headStrengthSlider:SetValueStep(0.5)
    headStrengthSlider:SetObeyStepOnDrag(true)
    headStrengthSlider:SetWidth(200)
    headStrengthSlider.Text:SetText("Strength")
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
    local headRangeSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    headRangeSlider:SetPoint("TOPLEFT", headStrengthSlider, "BOTTOMLEFT", 0, -40)
    headRangeSlider:SetMinMaxValues(0, 20)
    headRangeSlider:SetValue(db.headMovementRange)
    headRangeSlider:SetValueStep(1)
    headRangeSlider:SetObeyStepOnDrag(true)
    headRangeSlider:SetWidth(200)
    headRangeSlider.Text:SetText("Range")
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
    
    -- Separator line before Head Movement - Standing
    local separator2 = content:CreateTexture(nil, "ARTWORK")
    separator2:SetPoint("TOPLEFT", headRangeSlider, "BOTTOMLEFT", -10, -20)
    separator2:SetSize(600, 1)
    separator2:SetColorTexture(0.25, 0.25, 0.25, 1)
    
    -- Head Movement - Standing category header
    local headStandingHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    headStandingHeader:SetPoint("TOPLEFT", separator2, "BOTTOMLEFT", 0, -10)
    headStandingHeader:SetText("Head Movement - Standing")
    
    -- Head Movement Standing Strength slider
    local headStandingSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    headStandingSlider:SetPoint("TOPLEFT", headStandingHeader, "BOTTOMLEFT", 10, -30)
    headStandingSlider:SetMinMaxValues(0, 2)
    headStandingSlider:SetValue(db.headMovementStandingStrength)
    headStandingSlider:SetValueStep(0.1)
    headStandingSlider:SetObeyStepOnDrag(true)
    headStandingSlider:SetWidth(200)
    headStandingSlider.Text:SetText("Strength")
    headStandingSlider.Low:SetText("0")
    headStandingSlider.High:SetText("2")
    headStandingSlider.Value = headStandingSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    headStandingSlider.Value:SetPoint("TOP", headStandingSlider, "BOTTOM", 0, 0)
    headStandingSlider.Value:SetText(string.format("%.1f", db.headMovementStandingStrength))
    headStandingSlider:SetScript("OnValueChanged", function(self, value)
        db.headMovementStandingStrength = value
        self.Value:SetText(string.format("%.1f", value))
        addon:ApplySettings()
    end)
    
    -- Separator line before Camera Offset
    local separator3 = content:CreateTexture(nil, "ARTWORK")
    separator3:SetPoint("TOPLEFT", headStandingSlider, "BOTTOMLEFT", -10, -20)
    separator3:SetSize(600, 1)
    separator3:SetColorTexture(0.25, 0.25, 0.25, 1)
    
    -- Camera Offset category header
    local cameraOffsetHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cameraOffsetHeader:SetPoint("TOPLEFT", separator3, "BOTTOMLEFT", 0, -10)
    cameraOffsetHeader:SetText("Camera Offset")
    
    -- Dynamic Pitch checkbox
    local dynamicPitchCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    dynamicPitchCheck:SetPoint("TOPLEFT", cameraOffsetHeader, "BOTTOMLEFT", 10, -20)
    dynamicPitchCheck.Text:SetText("Dynamic Camera Pitch")
    dynamicPitchCheck:SetChecked(db.dynamicPitch)
    dynamicPitchCheck:SetScript("OnClick", function(self)
        db.dynamicPitch = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Vertical Pitch Strength slider
    local pitchStrengthSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    pitchStrengthSlider:SetPoint("TOPLEFT", dynamicPitchCheck, "BOTTOMLEFT", 0, -20)
    pitchStrengthSlider:SetMinMaxValues(0, 0.6)
    pitchStrengthSlider:SetValue(db.dynamicPitchStrength)
    pitchStrengthSlider:SetValueStep(0.05)
    pitchStrengthSlider:SetObeyStepOnDrag(true)
    pitchStrengthSlider:SetWidth(200)
    pitchStrengthSlider.Text:SetText("Vertical Pitch Strength")
    pitchStrengthSlider.Low:SetText("0")
    pitchStrengthSlider.High:SetText("0.6")
    pitchStrengthSlider.Value = pitchStrengthSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    pitchStrengthSlider.Value:SetPoint("TOP", pitchStrengthSlider, "BOTTOM", 0, 0)
    pitchStrengthSlider.Value:SetText(string.format("%.2f", db.dynamicPitchStrength))
    pitchStrengthSlider:SetScript("OnValueChanged", function(self, value)
        db.dynamicPitchStrength = value
        self.Value:SetText(string.format("%.2f", value))
        addon:ApplySettings()
    end)
    
    -- Over-Shoulder slider
    local shoulderSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    shoulderSlider:SetPoint("TOPLEFT", pitchStrengthSlider, "BOTTOMLEFT", 0, -40)
    shoulderSlider:SetMinMaxValues(-3, 3)
    shoulderSlider:SetValue(db.overShoulder)
    shoulderSlider:SetValueStep(0.1)
    shoulderSlider:SetObeyStepOnDrag(true)
    shoulderSlider:SetWidth(200)
    shoulderSlider.Text:SetText("Over-Shoulder")
    shoulderSlider.Low:SetText("-3")
    shoulderSlider.High:SetText("3")
    shoulderSlider.Value = shoulderSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    shoulderSlider.Value:SetPoint("TOP", shoulderSlider, "BOTTOM", 0, 0)
    shoulderSlider.Value:SetText(string.format("%.1f", db.overShoulder))
    shoulderSlider:SetScript("OnValueChanged", function(self, value)
        db.overShoulder = value
        self.Value:SetText(string.format("%.1f", value))
        addon:ApplySettings()
    end)
    
    -- Separator line before Target Focus
    local separator4 = content:CreateTexture(nil, "ARTWORK")
    separator4:SetPoint("TOPLEFT", shoulderSlider, "BOTTOMLEFT", -10, -20)
    separator4:SetSize(600, 1)
    separator4:SetColorTexture(0.25, 0.25, 0.25, 1)
    
    -- Target Focus category header
    local targetFocusHeader = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    targetFocusHeader:SetPoint("TOPLEFT", separator4, "BOTTOMLEFT", 0, -10)
    targetFocusHeader:SetText("Target Focus")
    
    -- Target Focus Enemy checkbox
    local targetEnemyCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    targetEnemyCheck:SetPoint("TOPLEFT", targetFocusHeader, "BOTTOMLEFT", 10, -20)
    targetEnemyCheck.Text:SetText("Enemies")
    targetEnemyCheck:SetChecked(db.targetFocusEnemy)
    targetEnemyCheck:SetScript("OnClick", function(self)
        db.targetFocusEnemy = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Target Focus Interact checkbox
    local targetInteractCheck = CreateFrame("CheckButton", nil, content, "InterfaceOptionsCheckButtonTemplate")
    targetInteractCheck:SetPoint("TOPLEFT", targetEnemyCheck, "BOTTOMLEFT", 0, -8)
    targetInteractCheck.Text:SetText("Interactables")
    targetInteractCheck:SetChecked(db.targetFocusInteract)
    targetInteractCheck:SetScript("OnClick", function(self)
        db.targetFocusInteract = self:GetChecked()
        addon:ApplySettings()
    end)
    
    -- Reset button
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", targetInteractCheck, "BOTTOMLEFT", 0, -20)
    resetBtn:SetWidth(150)
    resetBtn:SetHeight(25)
    resetBtn:SetText("Reset to Defaults")
    resetBtn:SetScript("OnClick", function()
        addon:ResetDB()
        -- Refresh UI
        enableCheck:SetChecked(db.enabled)
        autoApplyCheck:SetChecked(db.autoApply)
        showMinimapCheck:SetChecked(db.showMinimapButton)
        dynamicPitchCheck:SetChecked(db.dynamicPitch)
        pitchStrengthSlider:SetValue(db.dynamicPitchStrength)
        headStrengthSlider:SetValue(db.headMovementStrength)
        headRangeSlider:SetValue(db.headMovementRange)
        headStandingSlider:SetValue(db.headMovementStandingStrength)
        shoulderSlider:SetValue(db.overShoulder)
        targetEnemyCheck:SetChecked(db.targetFocusEnemy)
        targetInteractCheck:SetChecked(db.targetFocusInteract)
        addon:ApplySettings()
        addon:UpdateMinimapButton()
        addon:UpdateMinimapButtonVisibility()
    end)
    
    -- Set content height to accommodate all elements (approximately calculated)
    content:SetHeight(900)
    
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
