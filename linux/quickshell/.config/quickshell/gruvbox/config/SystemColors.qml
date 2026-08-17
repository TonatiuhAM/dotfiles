pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias md3: jsonAdapter.md3

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter

            readonly property Md3 md3: Md3 {}
        }
    }

    component Md3: JsonObject {
        property string background: "#1d2021"
        property string error: "#ea6962"
        property string on_error: "#000000"
        property string on_primary: "#000000"
        property string on_secondary: "#000000"
        property string on_surface: "#d4be98"
        property string on_surface_variant: "#a89984"
        property string on_tertiary: "#000000"
        property string outline: "#928374"
        property string outline_variant: "#3c3836"
        property string primary: "#a9b665"
        property string secondary: "#89b482"
        property string surface: "#1d2021"
        property string surface_bright: "#504945"
        property string surface_container: "#282828"
        property string surface_container_high: "#32302f"
        property string surface_container_highest: "#3c3836"
        property string surface_container_lowest: "#141617"
        property string tertiary: "#7daea3"
    }
}
