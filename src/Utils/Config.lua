--------------------------------------------------------------------------------
-- PeaversPerformance Configuration
-- Uses PeaversCommons.ConfigManager with AceDB-3.0 for profile management
--------------------------------------------------------------------------------

local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
local ConfigManager = PeaversCommons.ConfigManager

local DEFAULTS = {
    -- "quality" | "balanced" | "performance" | false (none active)
    activePreset = false,
    DEBUG_ENABLED = false,
}

addon.Config = ConfigManager:NewWithAceDB(
    addon,
    DEFAULTS,
    {
        savedVariablesName = "PeaversPerformanceDB",
        profileType = "shared",
    }
)

return addon.Config
