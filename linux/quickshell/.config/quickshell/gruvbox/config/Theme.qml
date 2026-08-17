pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font"

    // Surfaces, darkest to brightest — sourced live from the generated Material You
    // palette (~/.local/state/quickshell/generated/colors.json) instead of static hex.
    readonly property color bg0: SystemColors.md3.surface_container_lowest
    readonly property color bg1: SystemColors.md3.surface_container
    readonly property color bg3: SystemColors.md3.outline_variant
    readonly property color bg4: SystemColors.md3.surface_container_highest
    readonly property color bg5: SystemColors.md3.surface_bright

    readonly property color statusline2: SystemColors.md3.surface_container_high

    readonly property color fg0: SystemColors.md3.on_surface_variant
    readonly property color fg1: SystemColors.md3.on_surface
    readonly property color grey0: SystemColors.md3.outline_variant
    readonly property color grey1: SystemColors.md3.outline
    readonly property color grey2: SystemColors.md3.on_surface_variant

    // "On/active" states (workspace focus, media playing, volume) share the
    // system accent; "identity" accents (network, bluetooth, mic) share the
    // complementary tertiary tone; alerts use the system error color.
    readonly property color red: SystemColors.md3.error
    readonly property color orange: SystemColors.md3.error
    readonly property color yellow: SystemColors.md3.secondary
    readonly property color green: SystemColors.md3.primary
    readonly property color aqua: SystemColors.md3.tertiary
    readonly property color blue: SystemColors.md3.secondary
    readonly property color purple: SystemColors.md3.tertiary

    readonly property color transparent: "transparent"
    readonly property color barBackground: Qt.rgba(Qt.color(SystemColors.md3.surface).r, Qt.color(SystemColors.md3.surface).g, Qt.color(SystemColors.md3.surface).b, 0.96)
    readonly property color popupBackground: bg1
    readonly property color hoverBackground: statusline2
    readonly property color border: bg3
}
