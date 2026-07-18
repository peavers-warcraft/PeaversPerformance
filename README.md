# PeaversPerformance

One-click graphics presets for more FPS in retail World of Warcraft — transparently.

Popular "FPS boost" UI packs get much of their reputation by quietly lowering graphics
console variables (draw distance, shadows, ground clutter, and so on). PeaversPerformance
does the same thing honestly: three preset buttons that batch-apply graphics CVars, a
full list of exactly what each one changes, and a restore button that puts everything
back the way you had it.

## Presets

- **Quality** — mild FPS wins, keeps it pretty
- **Balanced** — noticeable FPS gains, moderate visual cost
- **Performance** — maximum FPS, potato mode

Every preset shows its complete CVar list (current value → new value) in the settings
panel before you click anything.

## Safety floor

All three presets — including Performance — keep:

- `projectedTextures = 1` — ground danger swirlies are never turned off
- Spell Density never below "Some" (`graphicsSpellDensity >= 1`) — essential spell effects
  are always kept

The addon never touches `maxFPS`, spell queue window, input latency, sound, camera, or
nameplate CVars.

## Restore

Before the first preset is applied, your current value of every CVar the presets touch
is snapshotted. **Restore my original settings** puts every one of them back and clears
the snapshot. Switching between presets keeps the original snapshot — restore always
returns you to your pre-preset settings.

## Usage

- `/pperf` — open settings
- `/pperf quality` / `balanced` / `performance` — apply a preset
- `/pperf restore` — restore your original settings
- `/pperf status` — show the active preset

## Notes

- Presets are applied once; the values persist in WoW's own config. The addon does not
  re-apply anything at login.
- Coexists fine with PeaversCVars — different SavedVariables and no login writes.
- If you're in combat, the action is queued and runs when combat ends.

## Dependencies

- [PeaversCommons](https://github.com/peavers-warcraft/PeaversCommons)
- [PeaversConfig](https://github.com/peavers-warcraft/PeaversConfig)
