local addonName, addon = ...

-- Which game client this is, and which graphics CVars it actually has.
--
-- One package ships to retail, to WoW Forever and to the Classic clients (Era,
-- Anniversary, Mists of Pandaria Classic), and the presets are written against
-- retail. Forever carries every graphics CVar retail does - it probes identically
-- - so only the content questions below differ there: no timed dungeons, and
-- nothing unmanaged beyond battlegrounds.
-- Rather than keep a second copy of every tier per client, everything that
-- cares asks here: the apply engine skips CVars the client does not have, the
-- Transparency tab leaves them out, and auto-switch and the help text word
-- themselves for what the client really offers.
--
-- Which client this is comes from PeaversCommons.Client and from nowhere else.
-- This file used to derive it again locally "in case Compat is missing", and the
-- two copies drifted until they disagreed about Forever. Commons revision 4 is a
-- hard requirement instead.

local Client = {}
addon.Client = Client

-- PeaversCommons.Client is the one place that works out which game this is, and
-- this file no longer has a second opinion. It used to: a Compat branch and an
-- interface-number fallback that disagreed about WoW Forever, so the same addon
-- behaved differently depending on whether Commons had loaded. Revision 4 is
-- required rather than worked around, because a silent local answer is how that
-- happened.
--
-- The names below are this addon's own vocabulary kept pointing at the shared
-- facts, so every call site reads as before.
local Commons = _G.PeaversCommons
local shared = Commons and Commons.Require and Commons:Require(4, addonName) and Commons.Client

if shared then
    Client.interface = shared.interface
    Client.isRetail = shared.isRetail
    Client.isForever = shared.isForever
    Client.isClassic = shared.isClassic
    Client.isClassicEra = shared.isClassicEra
    Client.isAnniversary = shared.isAnniversary
    Client.isMists = shared.isMists

    -- Timed dungeons, named for what players here call them.
    Client.challengeName = shared.timedDungeonName
    Client.challengeShort = shared.timedDungeonShort
    Client.hasChallengeDungeons = shared.hasTimedDungeons

    Client.unmanagedText = shared.unmanagedInstanceText
end

Client.unsupported = not shared

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
