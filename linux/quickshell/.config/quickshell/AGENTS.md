# CLAUDE.md - Quickshell Configuration Environment & Rules

This file provides crucial context, technical guardrails, and architectural guidelines for Claude Code working within this specific Quickshell configuration directory.

## ⚠️ CRITICAL MANDATORY RULE - DO NOT RESTART

* **NUNCA REINICIES QUICKSHELL POR TU CUENTA (NEVER RESTART QUICKSHELL).**
* El desarrollador se encarga de recargar, reiniciar o testear la configuración manualmente.
* **Prohibido:** Ejecutar comandos de terminal como `quickshell`, `qs`, `killall quickshell`, `pkill quickshell`, o interactuar con señales de recarga a través de scripts de ejecución automatizada en segundo plano durante las sesiones de edición. 
* Limítate estrictamente a leer, estructurar, modificar o crear los archivos `.qml` y scripts asociados sin alterar el proceso en ejecución.

---

## 🛠️ Tech Stack & Overview

* **Core Framework:** Quickshell (v0.3.0) — A flexible, component-based Wayland desktop shell configuration tool utilizing QML (Qt Quick).
* **Primary Environment:** Arch Linux (EndeavourOS) running **Hyprland** WM.
* **Paradigm:** Reactive data-bindings, asynchronous component lifecycle management, and explicit platform abstractions.

---

## 📐 Architecture & Key Design Patterns

### 1. Window Management & Protocols
* **PanelWindow & WlrLayershell:** Use `PanelWindow` (or the Wayland-native `WlrLayershell` attached object) for desktop bars, docks, or system overlays.
  * Always define `anchors` and `exclusiveZone` when reserving layout space from the compositor.
  * Opposite anchors force the window size to stick to screen bounds (e.g., `top: true`, `bottom: true` forces height). Use `margins` to build floating or detached bars.
* **PopupWindow:** Used for dropdown menus, tooltips, and system trays. It requires a valid `anchor` relative to an existing `QsWindow` or `Item` before it can become visible.
* **FloatingWindow:** Standard desktop application window paradigm. Use only if a traditional window surface is desired.

### 2. State & Reloading Logic (`Reloadable`)
* Quickshell hot-reloads configurations automatically without restarting the engine process.
* **PersistentProperties:** Essential for preserving UI states (e.g., whether a menu or volume slider popup is currently open) across code modifications or reloads. Inherits from `Reloadable` and requires stable `reloadableId` scopes.
* Avoid full initialization loops inside simple UI items; delegate long-standing configurations to native singletons.

### 3. Asynchronous & Lazy Loading
* Do not saturate layout instantiation. Use **LazyLoader** for heavy components (menus, network detail grids, notification histories) that shouldn't block the GUI on startup.
* When accessing an item inside a `LazyLoader`, remember it will block synchronously if it's currently building. Handle `activeChanged` or `loading` signals elegantly.

### 4. Native Quickshell Built-In Singletons & Modules
Always utilize the optimal built-in interface for desktop telemetry:
* **SystemClock:** View into the clock, customizable via `precision` (`SystemClock.Seconds`, `Minutes`, `Hours`). Use its `date` property directly instead of instantiating costly JavaScript `new Date()` instances continuously.
* **Quickshell.Hyprland (Hyprland):** Access monitors, layout workspaces (`HyprlandWorkspace`), focus windows, and listen to incoming dispatchers via `rawEvent` from `socket2`.
* **Quickshell.Services.Pipewire (Pipewire):** Handle default audio sink/source management, volume peaks, and link tracking via `PwNode`.
* **Quickshell.Services.Mpris (Mpris):** Track connected media players (`MprisPlayer`), handle playback state transitions, shuffle capabilities, and extract structural `metadata` / metadata changes.
* **Quickshell.Services.Notifications (NotificationServer):** Handle desktop banners. Remember to set `.tracked = true` on incoming `Notification` references to prevent structural automatic garbage collection/dismissal.
* **Quickshell.Services.SystemTray (SystemTray):** Exposes system icons as `SystemTrayItem` models to hook with `QsMenuAnchor` or context wrappers.

---

## 💻 QML Idioms & Pitfalls to Avoid

* **QTBUG-137166 (Transparent Holes):** If a `Rectangle` color is set to `"transparent"` and its `border` properties are touched dynamically, it can trigger an internal compositor bug causing everything underneath it to map as invisible. *Workaround:* explicitly declare `border.width: 0` if you only want to change properties like `radius`.
* **Surface Opaqueness:** Quickshell optimizes performance based on initial context format colors. If text/windows require dynamic alpha paths, enforce `surfaceFormat.opaque: false` inside the core `QsWindow` to prevent rendering artifacts.
* **Process Execution (`Quickshell.Io.Process`):** Do **not** run command lines directly inside shell strings unless explicitly calling a wrapper shell. `Process` does not execute commands within a user shell environment automatically. Use `["sh", "-c", "<command>"]` if typical terminal pipelines (pipes, env expansion) are strictly necessary.
* **Box-Sizing & Layouts:** Flex and Grid abstractions do not mimic web logic natively. Enforce proper anchor chains (`anchors.left`, `anchors.right`, etc.) or layout elements. Keep explicit measurements normalized.
* **IconImage Component:** Use `Quickshell.Widgets.IconImage` for panel icons or system tray nodes. It scales down gracefully using mipmaps and pulls metadata efficiently. Avoid regular `Image` structures for small status bar indices.

---

## 🛠️ Code Conventions & Preferences

* Write clean, highly segmented QML blocks. Split monolithic layouts into individual functional sub-components (e.g., `CpuWidget.qml`, `VolumeSlider.qml`).
* Rely primarily on **declarative property bindings** rather than complex imperative JavaScript blocks inside signal handlers.
* Comment on complex layout properties, especially when overriding implicit coordinates or modifying Wayland specific layers (`WlrLayer.Top`, `WlrLayer.Overlay`).
