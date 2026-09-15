local addonName, addon = ...

-- Which game client this is, and which graphics CVars it actually has.
--
-- One package ships to retail and to the Classic clients (Era, Anniversary,
-- Mists of Pandaria Classic), and the preset tables are written against retail.
-- Rather than keep a second copy of every tier per client, everything that
-- cares asks here: the apply engine skips CVars the client does not have, the
-- Transparency tab leaves them out, and auto-switch and the help text word
-- themselves for what the client really offers.
--
-- PeaversCommons.Compat answers the "which client" question when the installed
-- PeaversCommons is new enough to have it. The released one does not, so the
-- same answer is derived here from the interface number - never assume Compat
-- exists.

local Client = {}
addon.Client = Client

local Compat = _G.PeaversCommons and _G.PeaversCommons.Compat

if Compat then
    Client.interface = Compat.interface or 0
    Client.isRetail = Compat.isRetail and true or false
    Client.isClassicEra = Compat.isClassicEra and true or false
    Client.isAnniversary = Compat.isAnniversary and true or false
    Client.isMists = Compat.isMists and true or false
else
    local interface = tonumber((select(4, GetBuildInfo()))) or 0
    Client.interface = interface

    -- WOW_PROJECT_ID is the authoritative retail check where it exists; the
    -- interface number is the fallback and is what separates the Classic
    -- clients from one another, because the project constants for the newer
    -- Classic clients have been renamed before and the interface number has not.
    local project, mainline = _G.WOW_PROJECT_ID, _G.WOW_PROJECT_MAINLINE
    if project ~= nil and mainline ~= nil then
        Client.isRetail = project == mainline
    else
        Client.isRetail = interface >= 100000
    end

    local classic = not Client.isRetail
    Client.isClassicEra = classic and interface < 20000
    Client.isAnniversary = classic and interface >= 20000 and interface < 30000
    Client.isMists = classic and interface >= 50000 and interface < 60000
end
Client.isClassic = not Client.isRetail

-- Timed dungeons that report instance difficulty 8: Mythic+ on retail,
-- Challenge Mode on Mists Classic. Era and Anniversary have neither.
if Client.isRetail then
    Client.challengeName = "Mythic+"
    Client.challengeShort = "M+"
elseif Client.isMists then
    Client.challengeName = "Challenge Mode"
    Client.challengeShort = "CM"
end
Client.hasChallengeDungeons = Client.challengeName ~= nil

-- Instance types that exist here but that auto-switch deliberately leaves
-- alone. Only used for the "you are currently in" line, so it only has to be
-- honest, not exhaustive: Era has no arenas, and scenarios arrived in Mists.
if Client.isRetail or Client.isMists then
    Client.unmanagedText = "battleground, arena, scenario"
elseif Client.isAnniversary then
    Client.unmanagedText = "battleground, arena"
else
    Client.unmanagedText = "battleground"
end

-- Does this client have the CVar at all? GetCVar returns nil for a name the
-- client does not know (retail-only settings on Classic, or one renamed by a
-- patch). The set of CVars never changes while the client runs, so each
-- answer is cached - this is asked for every entry of every preset apply.
local cvarExists = {}

function Client.HasCVar(cvar)
    local known = cvarExists[cvar]
    if known ~= nil then
        return known
    end

    local ok, value = pcall(C_CVar.GetCVar, cvar)
    known = ok and value ~= nil
    cvarExists[cvar] = known
    return known
end

return Client
