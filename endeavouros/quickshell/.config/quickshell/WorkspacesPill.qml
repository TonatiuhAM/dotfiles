import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Qt.rgba(Qt.color(Colors.md3.background).r, Qt.color(Colors.md3.background).g, Qt.color(Colors.md3.background).b, 0.75)
    radius: height / 2
    implicitHeight: 32
    implicitWidth: wsRow.implicitWidth + 10

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                required property var modelData

                property bool isActive: Hyprland.focusedWorkspace !== null &&
                                        Hyprland.focusedWorkspace.id === modelData.id

                Layout.preferredWidth: isActive ? 29 : 24
                Layout.preferredHeight: 24
                radius: 12
                color: isActive ? Colors.md3.primary : "transparent"

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutCubic }
                }
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
