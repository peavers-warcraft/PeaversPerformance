local addonName, addon = ...

local PeaversCommons = _G.PeaversCommons
local Utils = PeaversCommons.Utils

-- Applies the preset the user picked for wherever they are (raid, Mythic+ or
-- Challenge Mode where the client has one, dungeon, open world). Fully opt-in:
-- does nothing unless
-- Config.autoSwitchEnabled is true, and any context set to "none" is left
-- alone so manual choices survive there.

local AutoSwitch = {}
addon.AutoSwitch = AutoSwitch

local Client = addon.Client

-- UI display order. configKey holds that context's target:
-- "none" | preset key | "restore". short is the label for one-line summaries.
--
-- Other addons read this list (the PeaversUI installer builds its graphics
-- screen from it), so its shape and keys are a contract. What changes per
-- client is only which entries are in it: the difficulty-8 context keeps the
-- key "mythicplus" and its config key everywhere so saved choices and readers
-- never need to know which client they are on, but it is named Challenge Mode
-- on Mists Classic and left out entirely on Era and Anniversary, which have no
-- timed dungeons to offer.
AutoSwitch.contexts = {
    { key = "raid",       name = "Raid",       short = "Raid",    configKey = "autoSwitchRaid" },
}
if Client.hasChallengeDungeons then
    table.insert(AutoSwitch.contexts,
        { key = "mythicplus", name = Client.challengeName, short = Client.challengeShort, configKey = "autoSwitchMythicPlus" })
end
table.insert(AutoSwitch.contexts, { key = "dungeon", name = "Dungeon",    short = "Dungeon", configKey = "autoSwitchDungeon" })
table.insert(AutoSwitch.contexts, { key = "world",   name = "Open world", short = "World",   configKey = "autoSwitchWorld" })

local contextByKey = {}
for _, ctx in ipairs(AutoSwitch.contexts) do
    contextByKey[ctx.key] = ctx
end

-- The context we last acted on. Loading screens re-fire PLAYER_ENTERING_WORLD
-- within the same context (raid wing teleports, M+ releases), so without this
-- every one would re-apply the preset and re-print the summary.
local lastContext = nil

local DIFFICULTY_MYTHIC_KEYSTONE = 8

function AutoSwitch.GetContextName(key)
    local ctx = contextByKey[key]
    return ctx and ctx.name or "Unknown"
end

-- The instance kinds this client can switch on, as prose for help text:
-- "a raid, Mythic+, or dungeon" on retail, "a raid or dungeon" on Era.
function AutoSwitch.GetInstanceListText()
    local names = {}
    for _, ctx in ipairs(AutoSwitch.contexts) do
        if ctx.key ~= "world" then
            table.insert(names, ctx.key == "mythicplus" and ctx.name or ctx.name:lower())
        end
    end

    if #names == 1 then
        return "a " .. names[1]
    elseif #names == 2 then
        return "a " .. names[1] .. " or " .. names[2]
    end
    return "a " .. table.concat(names, ", ", 1, #names - 1) .. ", or " .. names[#names]
end

-- Maps the player's location to a context key, or nil for places deliberately
-- left alone (battlegrounds, arenas, scenarios).
function AutoSwitch.GetContext()
    local inInstance, instanceType = IsInInstance()

    if instanceType == "raid" then
        return "raid"
    end

    if instanceType == "party" then
        -- Difficulty 8 is a Mythic+ keystone on retail and a Challenge Mode
        -- on Mists Classic. Guarded on the context existing so a client
        -- without one can never hand back a key nothing is configured for.
        local _, _, difficultyID = GetInstanceInfo()
        if difficultyID == DIFFICULTY_MYTHIC_KEYSTONE and contextByKey.mythicplus then
            return "mythicplus"
        end
        return "dungeon"
    end

    if not inInstance then
        return "world"
    end

    return nil
end

-- Acts on a known context. force skips the same-context guard; used when the
-- user just changed the auto-switch config so the new choice takes effect
-- where they stand.
local function ApplyForContext(context, force)
    if not addon.Config.autoSwitchEnabled then
        return
    end
    if not context or not contextByKey[context] then
        return
    end
    if context == lastContext and not force then
        return
    end
    lastContext = context

    local target = addon.Config[contextByKey[context].configKey]
    if not target or target == "none" then
        return
    end

    local status = addon.PresetManager.GetStatus()

    if target == "restore" then
        if status.hasSnapshot then
            Utils.Print(addon, "Auto-switch (" .. contextByKey[context].name .. "): restoring your original settings.")
            addon.PresetManager.RestoreOriginal()
        end
        return
    end

    if status.active ~= target then
        Utils.Print(addon, "Auto-switch (" .. contextByKey[context].name .. "): applying " .. addon.Presets.GetName(target) .. ".")
        addon.PresetManager.ApplyPreset(target)
    end
end

function AutoSwitch.Evaluate(force)
    ApplyForContext(AutoSwitch.GetContext(), force)
end

function AutoSwitch:Initialize()
    -- Fires after every loading screen; instance info is accurate by then.
    PeaversCommons.Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        AutoSwitch.Evaluate()
    end)

    -- Era and Anniversary have no timed dungeons, so there is nothing for the
    -- challenge events to switch to. The events themselves do exist on every
    -- Classic client; this is about meaning, not about the registration
    -- erroring.
    if not contextByKey.mythicplus then
        return
    end

    -- A keystone (or, on Mists Classic, a Challenge Mode) starting changes the
    -- dungeon's difficulty without a loading screen - and at the moment the
    -- event fires GetInstanceInfo() can still report plain Mythic, so deriving
    -- the context would race and lose. The event itself is authoritative: a
    -- challenge mode started, period.
    PeaversCommons.Events:RegisterEvent("CHALLENGE_MODE_START", function()
        ApplyForContext("mythicplus")
    end)

    -- On reset the difficulty change lags the event the same way, so give the
    -- world state a moment to settle before re-reading it.
    PeaversCommons.Events:RegisterEvent("CHALLENGE_MODE_RESET", function()
        C_Timer.After(1, function()
            AutoSwitch.Evaluate()
        end)
    end)
end

return AutoSwitch
