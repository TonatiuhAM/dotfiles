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

        Repeater {
            model: Hyprland.workspaces

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
                    text: modelData.name.startsWith("special") ? "" : modelData.name
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
