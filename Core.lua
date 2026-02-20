-- Core.lua - Main event handler and initialization

ExpCameraTweaks = ExpCameraTweaks or {}
local addon = ExpCameraTweaks

-- Event handler
local EventFrame = CreateFrame("Frame", "ExpCameraTweaksEventFrame")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

EventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ExpCameraTweaks" then
        addon:InitializeDB()
        addon:CreateSettingsPanel()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local db = addon.db or ExpCameraTweaksDB
        if db.autoApply then
            C_Timer.After(1, function()
                addon:ApplySettings()
            end)
        end
    end
end)
