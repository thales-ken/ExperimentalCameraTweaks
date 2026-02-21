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
        addon:UpdateMinimapButton()
    end)
    
    -- Auto-apply checkbox
    local autoApplyCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    autoApplyCheck:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -8)
    autoApplyCheck.Text:SetText("Auto-apply on login")
    autoApplyCheck:SetChecked(db.autoApply)
    autoApplyCheck:SetScript("OnClick", function(self)
        db.autoApply = self:GetChecked()
    end)
    
    -- Show minimap button checkbox
    local showMinimapCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    showMinimapCheck:SetPoint("TOPLEFT", autoApplyCheck, "BOTTOMLEFT", 0, -8)
    showMinimapCheck.Text:SetText("Show minimap icon")
    showMinimapCheck:SetChecked(db.showMinimapButton)
    showMinimapCheck:SetScript("OnClick", function(self)
        db.showMinimapButton = self:GetChecked()
        addon:UpdateMinimapButtonVisibility()
    end)
    
    -- Dynamic Pitch checkbox
    local dynamicPitchCheck = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    dynamicPitchCheck:SetPoint("TOPLEFT", showMinimapCheck, "BOTTOMLEFT", 0, -8)
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
        showMinimapCheck:SetChecked(db.showMinimapButton)
        dynamicPitchCheck:SetChecked(db.dynamicPitch)
        headStrengthSlider:SetValue(db.headMovementStrength)
        headRangeSlider:SetValue(db.headMovementRange)
        shoulderSlider:SetValue(db.overShoulder)
        targetEnemyCheck:SetChecked(db.targetFocusEnemy)
        targetInteractCheck:SetChecked(db.targetFocusInteract)
        addon:ApplySettings()
        addon:UpdateMinimapButton()
        addon:UpdateMinimapButtonVisibility()
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
