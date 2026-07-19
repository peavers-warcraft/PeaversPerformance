# PeaversPerformance

[![AddonSentry](https://addonsentry.io/api/public/repos/peavers-warcraft/PeaversPerformance/badge.svg)](https://addonsentry.io/dashboard/peavers-warcraft/PeaversPerformance)

A World of Warcraft addon with transparent one-click graphics presets spanning the whole scale, showing exactly which CVars change and restoring your original settings on demand.

## Features

<!-- peavers:features -->
- Five one-click graphics presets spanning the whole scale: Maximum, Quality, Balanced, Performance, and Minimum
- Auto-switch (opt-in): apply a chosen preset when you zone into a raid, Mythic+, or dungeon, and switch back in the open world
- Full transparency - every preset lists exactly which CVars it changes, with current and new values
- Snapshots your original settings before the first preset and restores them with one click
- Safety floor in every tier: ground danger indicators stay on and essential spell effects are always kept
- Applies to raids and battlegrounds too, and queues safely if you're in combat
<!-- /peavers:features -->

## Usage

<!-- peavers:usage -->
Popular "FPS boost" UI packs get much of their reputation by quietly lowering graphics
settings. PeaversPerformance does the same thing honestly - pick a preset, see exactly
what it changes, and restore your own settings whenever you like.

1. Open the settings with `/pperf` (or `/pconfig` > Performance)
2. Review any preset on the Transparency tab before applying
3. Click a preset button on the Presets tab to apply it
4. Optionally enable location-based switching on the Auto-Switch tab
5. Click "Restore my original settings" at any time to undo everything

### Slash Commands

- `/pperf` - Open settings
- `/pperf max` - Everything cranked, for beefy rigs
- `/pperf quality` - Mild FPS wins, keeps it pretty
- `/pperf balanced` - Noticeable FPS gains, moderate visual cost
- `/pperf performance` - Maximum FPS, potato mode
- `/pperf min` - Absolute floor, everything off that can be off
- `/pperf restore` - Restore your original settings
- `/pperf auto` - Toggle auto-switching by location
- `/pperf status` - Show the active preset
<!-- /peavers:usage -->

## Configuration

<!-- peavers:configuration -->
Access the preset panel through `/pperf`. Settings are organised into tabs:

- **Presets**: Apply Maximum, Quality, Balanced, Performance, or Minimum with one click, and restore every CVar to its pre-preset value
- **Auto-Switch**: Enable location-based switching and pick a preset (or "My original settings") per location - raid, Mythic+, dungeon, open world. Every automatic switch is announced in chat
- **Transparency**: Per-preset list of every CVar it changes, with current and new values
- **Information**: Overview and slash command reference
<!-- /peavers:configuration -->


## Installation

### Recommended: PeaversUpdater

Download and install [PeaversUpdater](https://github.com/peavers-warcraft/PeaversUpdater/releases/latest), the desktop updater for the whole Peavers collection. It installs PeaversPerformance together with its required dependencies and delivers updates before they reach CurseForge.

### Alternative: CurseForge

1. Download from [CurseForge](https://www.curseforge.com/wow/addons/peaversperformance)
2. Ensure [PeaversCommons](https://www.curseforge.com/wow/addons/peaverscommons) is also installed
3. Ensure [PeaversConfig](https://www.curseforge.com/wow/addons/peaversconfig) is also installed
4. Enable the addon on the character selection screen

---

*Part of the [Peavers](https://peavers.io) addon collection · [Report an issue](https://github.com/peavers-warcraft/PeaversPerformance/issues) · [Support development on Patreon](https://www.patreon.com/Peavers)*
