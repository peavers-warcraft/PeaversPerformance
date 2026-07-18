# PeaversPerformance

[![AddonSentry](https://addonsentry.io/api/public/repos/peavers-warcraft/PeaversPerformance/badge.svg)](https://addonsentry.io/dashboard/peavers-warcraft/PeaversPerformance)

A World of Warcraft addon that boosts FPS with three transparent one-click graphics presets, showing exactly which CVars change and restoring your original settings on demand.

## Features

<!-- peavers:features -->
- Three one-click graphics presets: Quality, Balanced, and Performance
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
2. Expand "What 'Performance' changes" to review any preset before applying
3. Click a preset button to apply it
4. Click "Restore my original settings" at any time to undo everything

### Slash Commands

- `/pperf` - Open settings
- `/pperf quality` - Mild FPS wins, keeps it pretty
- `/pperf balanced` - Noticeable FPS gains, moderate visual cost
- `/pperf performance` - Maximum FPS, potato mode
- `/pperf restore` - Restore your original settings
- `/pperf status` - Show the active preset
<!-- /peavers:usage -->

## Configuration

<!-- peavers:configuration -->
Access the preset panel through `/pperf`:

- **Preset buttons**: Apply Quality, Balanced, or Performance with one click
- **Restore my original settings**: Return every CVar to its pre-preset value
- **Full Transparency sections**: Per-preset list of every CVar with current and new values
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
