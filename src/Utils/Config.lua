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

    -- Auto-switch: apply a preset based on where the player is.
    -- Per-context targets: "none" (leave alone) | a preset key | "restore"
    -- (back to the pre-preset snapshot).
    autoSwitchEnabled = false,
    autoSwitchRaid = "performance",
    autoSwitchMythicPlus = "performance",
    autoSwitchDungeon = "none",
    autoSwitchWorld = "restore",

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
