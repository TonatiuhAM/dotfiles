pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias md3: jsonAdapter.md3

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/themes/catppuccin-mocha.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter

            readonly property Md3 md3: Md3 {}
        }
    }

    component Md3: JsonObject {
        property string background: "#1e1e2e"
        property string error: "#f38ba8"
        property string on_error: "#11111b"
        property string on_primary: "#11111b"
        property string on_secondary: "#11111b"
        property string on_surface: "#cdd6f4"
        property string on_surface_variant: "#a6adc8"
        property string on_tertiary: "#11111b"
        property string outline: "#7f849c"
        property string outline_variant: "#585b70"
        property string primary: "#94e2d5"
        property string secondary: "#89dceb"
        property string surface: "#1e1e2e"
        property string surface_bright: "#585b70"
        property string surface_container: "#1e1e2e"
        property string surface_container_high: "#313244"
        property string surface_container_highest: "#45475a"
        property string surface_container_lowest: "#11111b"
        property string tertiary: "#cba6f7"
    }
}
