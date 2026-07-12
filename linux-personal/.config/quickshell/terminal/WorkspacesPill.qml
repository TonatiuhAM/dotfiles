import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Colors.md3.surface_container
    radius: 0
    implicitHeight: 32
    implicitWidth: wsRow.implicitWidth

    RowLayout {
        id: wsRow
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: specialWsButton

            property string specialName: "M"
            property bool exists: Hyprland.workspaces.values.some(ws => ws.name === "special:" + specialName)
            property bool isShown: false
            property bool isActive: exists && isShown

            visible: exists
            Layout.preferredWidth: exists ? 28 : 0
            Layout.preferredHeight: 32
            radius: 0
            color: isActive ? Colors.md3.primary : "transparent"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Component.onCompleted: {
                const mon = Hyprland.focusedMonitor;
                if (mon && mon.lastIpcObject && mon.lastIpcObject.specialWorkspace)
                    isShown = mon.lastIpcObject.specialWorkspace.name === "special:" + specialName;
            }

            Connections {
                target: Hyprland

                function onRawEvent(event) {
                    if (event.name !== "activespecial")
                        return;
                    const wsName = event.data.split(",")[0];
                    specialWsButton.isShown = wsName === "special:" + specialWsButton.specialName;
                }
            }

            Text {
                anchors.centerIn: parent
                text: ""
                color: parent.isActive ? Colors.md3.on_primary : Colors.md3.on_surface
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font Propo"
                font.weight: parent.isActive ? Font.Medium : Font.Normal
            }

            TapHandler {
                onTapped: Hyprland.dispatch("hl.dsp.workspace.toggle_special(\"" + specialWsButton.specialName + "\")")
            }
        }

        Repeater {
            model: Hyprland.workspaces.values.filter(ws => !ws.name.startsWith("special:"))

            delegate: Rectangle {
                required property var modelData

                property bool isActive: Hyprland.focusedWorkspace !== null &&
                                        Hyprland.focusedWorkspace.id === modelData.id

                Layout.preferredWidth: 28
                Layout.preferredHeight: 32
                radius: 0
                color: isActive ? Colors.md3.primary : "transparent"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: modelData.name
                    color: parent.isActive ? Colors.md3.on_primary : Colors.md3.on_surface
                    font.pixelSize: 13
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.weight: parent.isActive ? Font.Medium : Font.Normal
                }

                TapHandler {
                    onTapped: modelData.activate()
                }
            }
        }
    }
}
