local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

local PresetManager = {}
addon.PresetManager = PresetManager

-- Action deferred because the player was in combat: { kind = "apply"|"restore", key = presetKey }
local pendingAction = nil

--------------------------------------------------------------------------------
-- Snapshot storage
-- Lives on the raw SavedVariables table, NOT inside the AceDB profile:
-- graphics CVars are machine-wide, so the snapshot must not switch with profiles.
--------------------------------------------------------------------------------

local function GetSV()
    _G.PeaversPerformanceDB = _G.PeaversPerformanceDB or {}
    return _G.PeaversPerformanceDB
end

local function GetSnapshot()
    return GetSV().snapshot
end

-- Records the user's current value for a CVar, once. Never overwrites an
-- existing entry, so the snapshot always holds the values from BEFORE the
-- first preset was applied - even after switching between presets.
local function EnsureSnapshotEntry(cvar)
    local sv = GetSV()
    sv.snapshot = sv.snapshot or { takenAt = time(), values = {} }

    if sv.snapshot.values[cvar] == nil then
        local current = C_CVar.GetCVar(cvar)
        if current ~= nil then
            sv.snapshot.values[cvar] = tostring(current)
        end
    end
end

--------------------------------------------------------------------------------
-- CVar application
--------------------------------------------------------------------------------

-- Unknown CVar names (renamed or removed by a patch) become visible failures
-- in the summary instead of Lua errors.
local function SetCVarSafe(cvar, value)
    if C_CVar.GetCVar(cvar) == nil then
        return false, "unknown CVar"
    end

    local ok, err = pcall(SetCVar, cvar, value)
    if ok then
        return true
    end
    return false, tostring(err)
end

local function RefreshUI()
    if addon.ConfigUI and addon.ConfigUI.Refresh then
        addon.ConfigUI:Refresh()
    end
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function PresetManager.GetStatus()
    local snapshot = GetSnapshot()
    return {
        active = addon.Config.activePreset or nil,
        hasSnapshot = snapshot ~= nil and next(snapshot.values or {}) ~= nil,
    }
end

function PresetManager.ApplyPreset(key)
    local preset = addon.Presets.Get(key)
    if not preset then
        Utils.Print(addon, "Unknown preset: " .. tostring(key))
        return
    end

    if InCombatLockdown() then
        pendingAction = { kind = "apply", key = key }
        Utils.Print(addon, preset.name .. " will be applied when combat ends.")
        return "queued"
    end

    local applied = 0
    local failed = {}
    local needsRestart = false

    for _, entry in ipairs(preset.cvars) do
        EnsureSnapshotEntry(entry.cvar)

        local previous = C_CVar.GetCVar(entry.cvar)
        local ok = SetCVarSafe(entry.cvar, entry.value)
        if ok then
            applied = applied + 1
            if entry.restart and previous ~= nil and tostring(previous) ~= tostring(entry.value) then
                needsRestart = true
            end
        else
            table.insert(failed, entry.cvar)
        end
    end

    addon.Config.activePreset = key
    addon.Config:Save()

    local summary = preset.name .. " applied - " .. applied .. " CVars set"
    if #failed > 0 then
        summary = summary .. ", " .. #failed .. " failed (" .. table.concat(failed, ", ") .. ")"
    end
    Utils.Print(addon, summary .. ". /pperf restore undoes everything.")

    if needsRestart then
        if RestartGx then
            pcall(RestartGx)
        else
            Utils.Print(addon, "Some changes may need /reload or a graphics restart to fully apply.")
        end
    end

    RefreshUI()
    return applied, failed
end

function PresetManager.RestoreOriginal()
    local snapshot = GetSnapshot()
    if not snapshot or not next(snapshot.values or {}) then
        Utils.Print(addon, "Nothing to restore - no preset has been applied.")
        return
    end

    if InCombatLockdown() then
        pendingAction = { kind = "restore" }
        Utils.Print(addon, "Your original settings will be restored when combat ends.")
        return "queued"
    end

    local restored = 0
    for cvar, value in pairs(snapshot.values) do
        if SetCVarSafe(cvar, value) then
            restored = restored + 1
        end
    end

    addon.Config.activePreset = false
    addon.Config:Save()
    GetSV().snapshot = nil

    Utils.Print(addon, "Restored " .. restored .. " CVars to your original settings.")

    RefreshUI()
    return restored
end

-- Called from Main.lua on PLAYER_REGEN_ENABLED.
function PresetManager.HandleCombatEnd()
    if not pendingAction then
        return
    end

    local action = pendingAction
    pendingAction = nil

    if action.kind == "apply" then
        PresetManager.ApplyPreset(action.key)
    elseif action.kind == "restore" then
        PresetManager.RestoreOriginal()
    end
end

return PresetManager
