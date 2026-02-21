-- MinimapButton.lua - Minimap button interface

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
