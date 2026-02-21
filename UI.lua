-- UI.lua - Settings panel interface

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- ============================================================================
-- MINIMAP HELPERS
-- ============================================================================

-- Minimap shape detection for square minimap addon compatibility
-- Returns true if minimap appears to be square
local function IsMinimapSquare()
    -- Global function set by some addons
    if GetMinimapShape then
        return GetMinimapShape() == "SQUARE"
    end

    -- Method on Minimap frame (ElvUI, VelUI, and forks set this)
    if Minimap.GetShape then
        return Minimap:GetShape() == "SQUARE"
    end

    -- Known square minimap addon frames
    if SexyMapCustomBackdrop or SexyMapSuperTrackerBackground then
        return true
    end
    if BasicMinimapSquare then
        return true
    end

    -- Check mask texture - if changed from default circular mask, assume square
    if Minimap.GetMaskTexture then
        local mask = Minimap:GetMaskTexture()
        if mask and type(mask) == "string" then
            local lower = mask:lower()
            -- Default circular mask contains "minimapmask"; anything else is likely square
            if not lower:find("minimapmask") then
                return true
            end
        end
    end

    return false
end

-- Calculate position for square minimap (uses corner/edge positioning)
local function GetSquarePosition(angle)
    -- For square minimaps, we clamp to the edges
    local rad = math.rad(angle)
    local x = math.cos(rad)
    local y = math.sin(rad)

    -- Normalize to square edges (half-width ~80 for standard minimap)
    local halfSize = 80
    local maxComponent = math.max(math.abs(x), math.abs(y))
    if maxComponent > 0 then
        x = (x / maxComponent) * halfSize
        y = (y / maxComponent) * halfSize
    end

    return x, y
end

-- Calculate position for circular minimap
local function GetCircularPosition(angle)
    local rad = math.rad(angle)
    -- Radius 95 = outside minimap border (minimap ~70 radius + button half-width + buffer)
    local x = math.cos(rad) * 95
    local y = math.sin(rad) * 95
    return x, y
end

-- ============================================================================
-- MINIMAP BUTTON
-- ============================================================================

-- Create minimap icon
function addon:CreateMinimapButton()
    local db = self.db or ExpCameraTweaksDB
    
    -- Create the minimap button
    local minimapButton = CreateFrame("Button", "ExpCameraTweaksMinimapButton", Minimap)
    minimapButton:SetSize(32, 32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:RegisterForClicks("LeftButtonUp")
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Create icon
    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 0)

    -- Load icon
    local iconPath = "Interface\\AddOns\\ExpCameraTweaks\\minimap.tga"

    -- Try to set the texture - if it fails, fall back to a standard icon
    local success = icon:SetTexture(iconPath)
    if not success or icon:GetTexture() == nil then
        -- Fallback to standard WoW icon if custom icon doesn't load
        iconPath = "Interface\\Icons\\Trade_Engineering"
        icon:SetTexture(iconPath)
    end

    minimapButton.icon = icon

    -- Create border
    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(52, 52)
    overlay:SetPoint("TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimapButton.overlay = overlay

    -- Click handler - toggle ActionCam
    minimapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            db.enabled = not db.enabled
            if db.enabled then
                addon:ApplySettings()
            else
                addon:DisableSettings()
            end
            addon:UpdateMinimapButton()
        end
    end)

    -- Drag handler
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", addon.OnMinimapUpdate)
    end)

    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- Tooltip
    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("ActionCam Tweaks")
        GameTooltip:AddLine(db.enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r", 1, 1, 1)
        GameTooltip:AddLine("Left-click to toggle", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Drag to move around border", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    self.minimapButton = minimapButton
    addon:UpdateMinimapPosition()
    addon:UpdateMinimapButton()
    addon:UpdateMinimapButtonVisibility()
end

function addon:OnMinimapUpdate(self)
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale

    local angle = math.atan2(py - my, px - mx)
    local db = ExpCameraTweaksDB or {}
    db.minimapPos = math.deg(angle)
    ExpCameraTweaks:UpdateMinimapPosition()
end

function addon:UpdateMinimapPosition()
    if not self.minimapButton then return end
    local db = self.db or ExpCameraTweaksDB
    
    self.minimapButton:ClearAllPoints()

    local angle = db.minimapPos or 220
    local x, y

    if IsMinimapSquare() then
        x, y = GetSquarePosition(angle)
    else
        x, y = GetCircularPosition(angle)
    end

    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- Update minimap button visibility
function addon:UpdateMinimapButtonVisibility()
    if not self.minimapButton then return end
    local db = self.db or ExpCameraTweaksDB
    
    if db.showMinimapButton then
        self.minimapButton:Show()
    else
        self.minimapButton:Hide()
    end
end

-- Update minimap button appearance based on enabled state
function addon:UpdateMinimapButton()
    if not self.minimapButton then return end
    local db = self.db or ExpCameraTweaksDB
    local button = self.minimapButton
    
    if db.enabled then
        -- Brighten the icon when enabled
        button.icon:SetDesaturated(false)
        button.icon:SetAlpha(1)
    else
        -- Desaturate and fade when disabled
        button.icon:SetDesaturated(true)
        button.icon:SetAlpha(0.5)
    end
end

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
    
    -- Over-Shoulder slider
    local shoulderSlider = CreateFrame("Slider", nil, content, "OptionsSliderTemplate")
    shoulderSlider:SetPoint("TOPLEFT", dynamicPitchCheck, "BOTTOMLEFT", 0, -20)
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
