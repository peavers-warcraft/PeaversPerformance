local addonName, addon = ...

-- Pure data: the graphics preset tiers, from maxed-out to potato.
-- Every entry drives BOTH the apply engine and the "what this changes" UI,
-- so what we show the user can never drift from what we actually set.
--
-- Design rules:
-- * Individual CVars only, never graphicsQuality - the options panel flips
--   to "Custom" on its own and restore stays unambiguous.
-- * Safety floor in every tier: projectedTextures stays ON (ground danger
--   swirlies) and graphicsSpellDensity never goes below 1 ("Some") - except
--   the Minimum tier, which drops to 0 ("Essential"): the engine itself
--   guarantees must-see spell effects are always drawn at that setting.
-- * graphicsSpellDensity is a dropdown INDEX, not a percentage:
--   0=Essential 1=Some 2=Half 3=Most 4=Dynamic 5=Everything.
-- * Never touched: maxFPS (foreground cap is a user choice), SpellQueueWindow,
--   latency, sound, camera and nameplate CVars.

local Presets = {}
addon.Presets = Presets

Presets.order = { "maximum", "quality", "balanced", "performance", "minimum" }

Presets.presets = {
    maximum = {
        name = "Maximum",
        blurb = "Everything cranked - screenshots and beefy rigs",
        cvars = {
            { cvar = "graphicsShadowQuality", value = "5", note = "Ultra High shadows; WoW's biggest GPU cost" },
            { cvar = "ssao", value = "4", note = "Highest ambient occlusion" },
            { cvar = "graphicsDepthEffects", value = "3", note = "Full depth of field effects" },
            { cvar = "sunShafts", value = "2", note = "High quality god-rays" },
            { cvar = "reflectionMode", value = "3", note = "Full water reflections; huge cost near water" },
            { cvar = "graphicsLiquidDetail", value = "3", note = "Most complex water shader" },
            { cvar = "graphicsEnvironmentDetail", value = "9", note = "Maximum doodad draw distance" },
            { cvar = "farclip", value = "2500", note = "Maximum terrain view distance" },
            { cvar = "groundEffectDensity", value = "256", note = "Densest grass and clutter" },
            { cvar = "groundEffectDist", value = "500", note = "Maximum clutter draw distance" },
            { cvar = "particleDensity", value = "5", note = "Maximum ambient particles" },
            { cvar = "graphicsSpellDensity", value = "5", note = "Everything - all spell visuals kept" },
            { cvar = "weatherDensity", value = "3", note = "Full rain and snow" },
            { cvar = "textureFilteringMode", value = "5", note = "16x anisotropic filtering" },
            { cvar = "MSAAQuality", value = "4", restart = true, note = "Maximum MSAA anti-aliasing; very expensive" },
            { cvar = "ffxGlow", value = "1", note = "Fullscreen bloom on" },
            { cvar = "RenderScale", value = "1", note = "Native resolution rendering" },
            { cvar = "maxFPSBk", value = "30", note = "Background FPS cap; free win while tabbed out" },
            { cvar = "raidSettingsEnabled", value = "0", note = "Use these same settings in raids and battlegrounds" },
            { cvar = "projectedTextures", value = "1", note = "SAFETY: ground danger swirlies stay ON" },
        },
    },

    quality = {
        name = "Quality",
        blurb = "Mild FPS wins, keeps it pretty",
        cvars = {
            { cvar = "graphicsShadowQuality", value = "3", note = "Shadows are WoW's biggest GPU cost; 3 keeps contact shadows" },
            { cvar = "ssao", value = "1", note = "Ambient occlusion is expensive and subtle at low settings" },
            { cvar = "graphicsDepthEffects", value = "1", note = "Depth of field outlines; barely visible" },
            { cvar = "sunShafts", value = "0", note = "Fullscreen god-rays; big cost, pure cosmetic" },
            { cvar = "reflectionMode", value = "0", note = "Water reflections; huge cost near water" },
            { cvar = "graphicsLiquidDetail", value = "1", note = "Water shader complexity" },
            { cvar = "graphicsEnvironmentDetail", value = "2", note = "Doodad draw distance" },
            { cvar = "farclip", value = "1500", note = "Terrain view distance; biggest CPU-side win" },
            { cvar = "groundEffectDensity", value = "48", note = "Grass and clutter density" },
            { cvar = "groundEffectDist", value = "100", note = "Clutter draw distance" },
            { cvar = "particleDensity", value = "3", note = "Ambient particle count" },
            { cvar = "graphicsSpellDensity", value = "5", note = "Everything - all spell visuals kept" },
            { cvar = "weatherDensity", value = "1", note = "Rain and snow particles" },
            { cvar = "textureFilteringMode", value = "3", note = "Anisotropic filtering level" },
            { cvar = "MSAAQuality", value = "0", restart = true, note = "MSAA is the priciest anti-aliasing" },
            { cvar = "maxFPSBk", value = "30", note = "Background FPS cap; free win while tabbed out" },
            { cvar = "raidSettingsEnabled", value = "0", note = "Use these same settings in raids and battlegrounds" },
            { cvar = "projectedTextures", value = "1", note = "SAFETY: ground danger swirlies stay ON" },
        },
    },

    balanced = {
        name = "Balanced",
        blurb = "Noticeable FPS gains, moderate visual cost",
        cvars = {
            { cvar = "graphicsShadowQuality", value = "1", note = "Shadows are WoW's biggest GPU cost" },
            { cvar = "ssao", value = "0", note = "Ambient occlusion off; expensive, subtle" },
            { cvar = "graphicsDepthEffects", value = "0", note = "Depth of field off; barely visible" },
            { cvar = "sunShafts", value = "0", note = "Fullscreen god-rays off; pure cosmetic" },
            { cvar = "reflectionMode", value = "0", note = "Water reflections off; huge cost near water" },
            { cvar = "graphicsLiquidDetail", value = "1", note = "Water shader complexity" },
            { cvar = "graphicsEnvironmentDetail", value = "1", note = "Doodad draw distance" },
            { cvar = "farclip", value = "1000", note = "Terrain view distance; biggest CPU-side win" },
            { cvar = "groundEffectDensity", value = "16", note = "Grass and clutter density" },
            { cvar = "groundEffectDist", value = "70", note = "Clutter draw distance" },
            { cvar = "particleDensity", value = "2", note = "Ambient particle count" },
            { cvar = "graphicsSpellDensity", value = "4", note = "Dynamic - auto-culls non-essential visuals in heavy fights" },
            { cvar = "weatherDensity", value = "0", note = "Rain and snow particles off" },
            { cvar = "textureFilteringMode", value = "1", note = "Anisotropic filtering lowered" },
            { cvar = "MSAAQuality", value = "0", restart = true, note = "MSAA is the priciest anti-aliasing" },
            { cvar = "vsync", value = "0", note = "Uncaps the GPU from your refresh rate" },
            { cvar = "maxFPSBk", value = "30", note = "Background FPS cap; free win while tabbed out" },
            { cvar = "raidSettingsEnabled", value = "0", note = "Use these same settings in raids and battlegrounds" },
            { cvar = "projectedTextures", value = "1", note = "SAFETY: ground danger swirlies stay ON" },
        },
    },

    performance = {
        name = "Performance",
        blurb = "Maximum FPS, potato mode (danger swirlies stay on)",
        cvars = {
            { cvar = "graphicsShadowQuality", value = "0", note = "Lowest shadows; biggest single GPU win" },
            { cvar = "ssao", value = "0", note = "Ambient occlusion off" },
            { cvar = "graphicsDepthEffects", value = "0", note = "Depth of field off" },
            { cvar = "sunShafts", value = "0", note = "Fullscreen god-rays off" },
            { cvar = "reflectionMode", value = "0", note = "Water reflections off" },
            { cvar = "graphicsLiquidDetail", value = "0", note = "Simplest water shader" },
            { cvar = "graphicsEnvironmentDetail", value = "0", note = "Minimum doodad draw distance" },
            { cvar = "farclip", value = "500", note = "Minimum comfortable view distance; biggest CPU-side win" },
            { cvar = "groundEffectDensity", value = "8", note = "Barely any grass or clutter" },
            { cvar = "groundEffectDist", value = "50", note = "Minimum clutter draw distance" },
            { cvar = "particleDensity", value = "1", note = "Minimum ambient particles" },
            { cvar = "graphicsSpellDensity", value = "1", note = "SAFETY FLOOR: 'Some' - essential spell effects always kept" },
            { cvar = "weatherDensity", value = "0", note = "Rain and snow particles off" },
            { cvar = "textureFilteringMode", value = "0", note = "Cheapest texture filtering" },
            { cvar = "MSAAQuality", value = "0", restart = true, note = "MSAA off" },
            { cvar = "ffxGlow", value = "0", note = "Fullscreen bloom off; visibly changes the look" },
            { cvar = "RenderScale", value = "0.75", note = "Renders below native resolution, then upscales" },
            { cvar = "vsync", value = "0", note = "Uncaps the GPU from your refresh rate" },
            { cvar = "maxFPSBk", value = "20", note = "Background FPS cap; free win while tabbed out" },
            { cvar = "raidSettingsEnabled", value = "0", note = "Use these same settings in raids and battlegrounds" },
            { cvar = "projectedTextures", value = "1", note = "SAFETY: ground danger swirlies stay ON" },
        },
    },

    minimum = {
        name = "Minimum",
        blurb = "Absolute floor - everything off that can be off",
        cvars = {
            { cvar = "graphicsShadowQuality", value = "0", note = "Lowest shadows; biggest single GPU win" },
            { cvar = "ssao", value = "0", note = "Ambient occlusion off" },
            { cvar = "graphicsDepthEffects", value = "0", note = "Depth of field off" },
            { cvar = "sunShafts", value = "0", note = "Fullscreen god-rays off" },
            { cvar = "reflectionMode", value = "0", note = "Water reflections off" },
            { cvar = "graphicsLiquidDetail", value = "0", note = "Simplest water shader" },
            { cvar = "graphicsEnvironmentDetail", value = "0", note = "Doodad draw distance floor" },
            { cvar = "farclip", value = "100", note = "Engine floor for view distance; extreme pop-in" },
            { cvar = "groundEffectDensity", value = "0", note = "No grass or clutter at all" },
            { cvar = "groundEffectDist", value = "0", note = "No clutter draw distance" },
            { cvar = "particleDensity", value = "0", note = "No ambient particles" },
            { cvar = "graphicsSpellDensity", value = "0", note = "Essential - the engine still draws must-see spell effects" },
            { cvar = "weatherDensity", value = "0", note = "Rain and snow particles off" },
            { cvar = "textureFilteringMode", value = "0", note = "Cheapest texture filtering" },
            { cvar = "MSAAQuality", value = "0", restart = true, note = "MSAA off" },
            { cvar = "ffxGlow", value = "0", note = "Fullscreen bloom off; visibly changes the look" },
            { cvar = "RenderScale", value = "0.5", note = "Half resolution, upscaled - blurry but fast" },
            { cvar = "vsync", value = "0", note = "Uncaps the GPU from your refresh rate" },
            { cvar = "maxFPSBk", value = "10", note = "Background FPS cap; free win while tabbed out" },
            { cvar = "raidSettingsEnabled", value = "0", note = "Use these same settings in raids and battlegrounds" },
            { cvar = "projectedTextures", value = "1", note = "SAFETY: ground danger swirlies stay ON" },
        },
    },
}

function Presets.Get(key)
    return key and Presets.presets[key] or nil
end

function Presets.GetName(key)
    local preset = Presets.Get(key)
    return preset and preset.name or "None"
end

return Presets
