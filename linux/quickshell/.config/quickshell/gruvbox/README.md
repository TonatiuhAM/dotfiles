# Gruvbox-shaped Bar (Quickshell)

A self-contained bar for Quickshell 0.3.0 / Hyprland, using the Gruvbox bar's layout and module set but colored from your live Material You palette rather than static Gruvbox hex values. This directory contains the bar plus a volume OSD (`osd/VolumeOSD.qml`, ported from `./terminal/VolumeOSD.qml`) — no notification toasts/history, since that's handled by your existing setup.

## Dependencies

- Quickshell 0.3.0
- Hyprland
- Qt 6 / QtQuick
- JetBrainsMono Nerd Font (used for both text and icon glyphs)
- NetworkManager, BlueZ, PipeWire/WirePlumber, UPower
- An MPRIS-compatible player for the media module
- `../Launcher` (this repo's Quickshell-based launcher, toggled via its FIFO script), `brightnessctl`, `pavucontrol`, `kitty`, `btop`, `loginctl`, `systemctl`, `hyprctl`

## Using it

This directory has no `shell.qml` of its own — it's imported directly from `~/.config/quickshell/shell.qml`, the same way `./terminal` and `./Launcher` are:

```qml
import "./gruvbox"

ShellRoot {
    Bar {}
}
```

A root `qmldir` exposes `Bar`. The volume OSD lives inside `Bar.qml` itself, anchored to the audio module like every other popup — there's nothing separate to instantiate. Since this machine has a single monitor, bare `Bar {}` is enough. For multi-monitor setups, wrap it in a `Variants { model: Quickshell.screens; delegate: Bar { required property var modelData; screen: modelData } }` instead.

Start/stop it the normal way, from the quickshell root:

```bash
qs -p ~/.config/quickshell --no-duplicate
qs kill -p ~/.config/quickshell
```

## Architecture

```text
gruvbox/
├── qmldir           # exposes Bar for `import "./gruvbox"`
├── config/          # Theme.qml (colors, fonts), Settings.qml (dimensions, commands), SystemColors.qml (live palette)
├── services/        # Hyprland, MPRIS, PipeWire, Network, Bluetooth, UPower, memory, brightness, popup state
├── components/      # Shared buttons, text, sliders, popup surface
├── bar/             # Bar.qml and its modules
├── popups/          # Contextual popups opened from the bar
└── osd/             # VolumeOSD.qml — anchored under the audio module, fades in on volume/mute change
```

## Bar modules

Left: Fedora/launcher button, special workspace `M` (only when it exists), occupied/active/urgent Hyprland workspaces, active-window title.

Center: selected MPRIS player, artist, and title.

Right: network state + throughput, PipeWire volume, memory usage, UPower battery, tray, clock, power menu.

Pointer actions:

- launcher: left-click toggles `../Launcher` (same FIFO your `SUPER+SPACE` keybind uses)
- special workspace `M`: left-click toggles it (only visible once it exists; stays visible while it holds windows, even when hidden)
- media: left-click popup, middle/right-click play-pause, wheel previous/next
- network: left-click popup
- audio: left-click popup, middle-click mute, right-click `pavucontrol`, wheel volume
- memory: left-click `kitty -e btop`
- battery: left-click Control Center (includes Bluetooth, volume, brightness)
- clock: left-click calendar
- power: left-click power menu

## Theme and sizing

`config/SystemColors.qml` watches `~/.local/state/quickshell/generated/colors.json` (your matugen-generated Material You palette, same file `./terminal` already reads via its own `Colors.qml`) and reloads live whenever it changes — no restart needed when your wallpaper/palette regenerates.

`config/Theme.qml` maps that live palette onto the bar's original Gruvbox-shaped role names, so every other file in this directory is untouched and still just uses `Theme.red`, `Theme.green`, `Theme.bg1`, etc.:

- surfaces (`bg0`…`bg5`, `statusline2`, `barBackground`, `popupBackground`, `hoverBackground`, `border`) → `surface`/`surface_container*`/`outline*` tiers, darkest to brightest
- text/icons (`fg0`, `fg1`, `grey0`…`grey2`) → `on_surface`/`on_surface_variant`/`outline`/`outline_variant` tiers, brightest to dimmest
- "on/active" accents (`green`, `yellow`) → `primary`/`secondary` (workspace focus, media playing, volume)
- "identity" accents (`aqua`, `blue`, `purple`) → `tertiary`/`secondary` (network, bluetooth, mic)
- alerts (`red`, `orange`) → `error` (urgent workspace, critical battery, power-off, error text)

Material You intentionally derives every role from one source color, so hues that were visually distinct in static Gruvbox (e.g. yellow vs. green) end up closer together now — that's expected, not a bug. If `colors.json` is ever missing, `SystemColors.qml` falls back to Gruvbox-ish defaults baked into the file.

Dimensions and external commands live in `config/Settings.qml` (`barHeight`, `fontSize`, `popupWidth`, `launcherToggleScript`, etc.) and are unaffected by any of this.

All popups (Control Center, power menu, media, network, audio, calendar) open only by clicking their bar module — there's no `IpcHandler`/`qs ipc call` wiring, since that lived in the standalone `shell.qml` this directory no longer has. Add one in the root `shell.qml` if you want keybind-triggered toggles.

## What was intentionally removed

The upstream version of this bar also shipped a notification toast/history system with its own `NotificationServer`. That was removed here:

- `notifications/` directory deleted
- `NotificationService`, the `NotificationCenter` popup, and the bar's notification indicator deleted
- the "Notifications" row in Control Center removed
- the `notificationServerEnabled` setting (which would have taken over `org.freedesktop.Notifications` from your existing daemon) removed entirely

Its original brightness/volume OSD overlay was also dropped initially, then the volume half was brought back (see below) once you asked for it specifically — `osd/` now holds only `VolumeOSD.qml`, no brightness OSD.

## Fixes applied for this machine

- `Theme.iconFontFamily` was `"Symbols Nerd Font"`, which isn't installed here; changed to `"JetBrainsMono Nerd Font"` (already installed and patched with the icon glyphs), matching the existing `terminal/` bar.
- The root `shell.qml` still had `VolumeOSD {}` left over from when it imported `./terminal`; removed, since `./gruvbox` has no such component and you already have your own OSD.
- The launcher button now shows the Fedora glyph (was Arch) and toggles `../Launcher` via its `toggle_launcher.sh` FIFO script (was launching `rofi` directly against a theme file that no longer exists).
- The special workspace `M` button (`bar/Workspaces.qml`) mirrors `./terminal/WorkspacesPill.qml`'s show/hide logic but dispatches the standard `togglespecialworkspace M` command — the string `terminal/WorkspacesPill.qml` currently dispatches (`hl.dsp.workspace.toggle_special(...)`) isn't a valid Hyprland dispatcher, so it was not carried over.
- `osd/VolumeOSD.qml` is ported from `./terminal/VolumeOSD.qml`, but instead of polling `wpctl get-volume` every 150ms it listens to `AudioService.osdRequested` — a signal the audio service already emits reactively (via PipeWire's own change notifications) on every volume/mute change, whichever module or external source triggered it. Same fade-in/fade-out/box UI, colors switched from `terminal`'s `Colors.md3.*` to this bar's own `Theme.*` tokens. Displayed icon/percentage/muted state bind live to `AudioService` (like the bar's own `AudioIndicator` does) rather than being copied out of the signal's arguments — the signal only triggers visibility. `AudioService.setVolume()` reads `sink.audio.volume` back immediately after writing it, before PipeWire confirms the change, so a value carried in the signal itself can be one step stale; a live binding always shows the same number the bar shows and self-corrects the instant the real change lands.
- `terminal`'s `VolumeOSD` is a screen-centered `PanelWindow` (`anchors.top: true` with no horizontal anchor), so it always renders in the horizontal middle of the screen regardless of where any bar module sits. This one is a `PopupWindow` anchored to `audioIndicator` (`anchor.item`/`anchor.edges: Edges.Bottom`, same mechanism `AudioPopup` and every other bar popup already use in `Bar.qml`), so it opens directly under wherever the volume module actually is — including when neighboring modules (tray, network rate text) shift its position. `grabFocus: false` keeps it from stealing keyboard focus, matching the original's non-modal intent.
