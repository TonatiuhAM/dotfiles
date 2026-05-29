import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Colors.md3.surface_container_low
    radius: 0
    implicitHeight: 32
    implicitWidth: contentRow.implicitWidth + 20

    visible: root.windowClass !== "" || root.windowTitle !== ""

    property string windowClass: ""
    property string windowTitle: ""
    property bool windowFloating: false
    property int windowFullscreen: 0

    // Terminals: show title (reflects running process — nvim, claude, btop, etc.)
    // Ferdium: show title (reflects active service — WhatsApp, Discord, etc.)
    // Everything else: show window class
    readonly property string displayName: {
        const id = windowClass.toLowerCase()
        const t = windowTitle.trim()
        const terminals = ["kitty", "alacritty", "foot", "wezterm", "ghostty", "konsole", "xterm"]
        for (var i = 0; i < terminals.length; i++) {
            if (id === terminals[i] || id.endsWith("." + terminals[i])) {
                return t !== "" ? t : windowClass
            }
        }
        if (id === "ferdium" || id.endsWith(".ferdium")) {
            return t !== "" ? t : "Ferdium"
        }
        return windowClass
    }

    // N = tiling, Z = fullscreen/maximized, F = floating
    readonly property string stateLabel: {
        if (windowFullscreen > 0) return "Z"
        if (windowFloating) return "F"
        return "N"
    }

    Process {
        id: activeWindowProc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onTextChanged: {
                const raw = text.trim()
                if (raw === "" || raw.indexOf("{") < 0) {
                    root.windowClass = ""
                    root.windowTitle = ""
                    root.windowFloating = false
                    root.windowFullscreen = 0
                    return
                }
                try {
                    const data = JSON.parse(raw)
                    root.windowClass = data.class || ""
                    root.windowTitle = data.title || ""
                    root.windowFloating = data.floating || false
                    root.windowFullscreen = data.fullscreen || 0
                } catch (e) {}
            }
        }
        Component.onCompleted: exec(command)
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const triggers = ["activewindow", "activewindowv2", "fullscreen", "changefloatingmode", "closewindow", "workspace"]
            if (triggers.indexOf(event.name) >= 0) {
                activeWindowProc.exec(activeWindowProc.command)
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.displayName
            color: Colors.md3.on_surface
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font Propo"
            Layout.maximumWidth: 200
            elide: Text.ElideRight
        }

        Text {
            text: "|"
            color: Colors.md3.on_surface_variant
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font Propo"
        }

        Text {
            text: root.stateLabel
            color: Colors.md3.primary
            font.pixelSize: 13
            font.weight: Font.Medium
            font.family: "JetBrainsMono Nerd Font Propo"
        }
    }
}
