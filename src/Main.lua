local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
if not PeaversCommons then
    print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons to work properly.")
    return
end

local requiredModules = { "Events", "SlashCommands", "Utils" }
for _, module in ipairs(requiredModules) do
    if not PeaversCommons[module] then
        print("|cffff0000Error:|r " .. addonName .. " requires PeaversCommons." .. module .. " which is missing.")
        return
    end
end

local Utils = PeaversCommons.Utils

addon.name = addonName
addon.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "1.0.0"

-- Register slash commands
PeaversCommons.SlashCommands:Register(addonName, "pperf", {
    default = function()
        addon.ConfigUI:OpenOptions()
    end,
    maximum = function()
        addon.PresetManager.ApplyPreset("maximum")
    end,
    max = function()
        addon.PresetManager.ApplyPreset("maximum")
    end,
    quality = function()
        addon.PresetManager.ApplyPreset("quality")
    end,
    balanced = function()
        addon.PresetManager.ApplyPreset("balanced")
    end,
    performance = function()
        addon.PresetManager.ApplyPreset("performance")
    end,
    minimum = function()
        addon.PresetManager.ApplyPreset("minimum")
    end,
    min = function()
        addon.PresetManager.ApplyPreset("minimum")
    end,
    restore = function()
        addon.PresetManager.RestoreOriginal()
    end,
    auto = function()
        addon.Config.autoSwitchEnabled = not addon.Config.autoSwitchEnabled
        addon.Config:Save()
        Utils.Print(addon, "Auto-switch " .. (addon.Config.autoSwitchEnabled and "enabled" or "disabled") .. ".")
        if addon.Config.autoSwitchEnabled then
            addon.AutoSwitch.Evaluate(true)
        end
        if addon.ConfigUI and addon.ConfigUI.Refresh then
            addon.ConfigUI:Refresh()
        end
    end,
    status = function()
        local state = addon.PresetManager.GetStatus()
        if state.active then
            Utils.Print(addon, "Active preset: " .. addon.Presets.GetName(state.active))
        else
            Utils.Print(addon, "No preset active - your own settings are in use.")
        end
        if state.hasSnapshot then
            print("  Original settings are saved. /pperf restore brings them back.")
        end
        if addon.Config.autoSwitchEnabled then
            print("  Auto-switch is on. Configure it with /pperf.")
        end
    end,
    help = function()
        Utils.Print(addon, "Commands:")
        print("  /pperf - Open settings")
        print("  /pperf max - Everything cranked, for beefy rigs")
        print("  /pperf quality - Mild FPS wins, keeps it pretty")
        print("  /pperf balanced - Noticeable FPS gains, moderate visual cost")
        print("  /pperf performance - Maximum FPS, potato mode")
        print("  /pperf min - Absolute floor, everything off that can be off")
        print("  /pperf restore - Restore your original settings")
        print("  /pperf auto - Toggle auto-switching by location")
        print("  /pperf status - Show the active preset")
    end,
})

-- Initialize the addon
PeaversCommons.Events:Init(addonName, function()
    addon.Config:Initialize()

    if addon.ConfigUI and addon.ConfigUI.Initialize then
        addon.ConfigUI:Initialize()
    end

    if addon.Patrons and addon.Patrons.Initialize then
        addon.Patrons:Initialize()
    end

    -- Preset/restore actions requested during combat run once it ends
    PeaversCommons.Events:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        addon.PresetManager.HandleCombatEnd()
    end)

    -- Location-based preset switching (opt-in via settings)
    addon.AutoSwitch:Initialize()

    -- Use the centralized SettingsUI system from PeaversCommons
    C_Timer.After(0.5, function()
        if PeaversCommons.SettingsUI then
            PeaversCommons.SettingsUI:CreateRedirectPage(addon, "PeaversPerformance", "Peavers Performance")
        end
    end)

    -- Register with PeaversConfig registry
    if PeaversCommons.ConfigRegistry then
        PeaversCommons.ConfigRegistry:Register({
            name = "PeaversPerformance",
            displayName = "Performance",
            description = "One-click graphics presets for more FPS - transparently",
            addonRef = addon,
            config = addon.Config,
            pages = addon.ConfigUI:GetPages(),
            order = 12,
        })
    end
end, {
    suppressAnnouncement = true
})

_G.PeaversPerformance = addon
