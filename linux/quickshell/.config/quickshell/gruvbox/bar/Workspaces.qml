import QtQuick
import Quickshell.Hyprland
import "../components"
import "../config"

Rectangle {
    id: root

    implicitWidth: workspaceRow.implicitWidth + 6
    implicitHeight: Settings.barHeight
    color: Theme.bg1

    function workspaceById(workspaceId: int): var {
        return Hyprland.workspaces.values.find(workspace => workspace.id === workspaceId) ?? null;
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        height: parent.height

        Rectangle {
            id: specialWorkspaceButton

            readonly property string specialName: "M"
            readonly property var workspace: Hyprland.workspaces.values.find(ws => ws.name === "special:" + specialName) ?? null
            readonly property bool exists: workspace !== null
            readonly property bool active: workspace !== null && workspace.active

            visible: exists
            width: exists ? 25 : 0
            height: workspaceRow.height
            color: pointer.pressed ? Theme.bg4 : pointer.containsMouse || active ? Theme.statusline2 : Theme.transparent

            Behavior on color {
                ColorAnimation { duration: Settings.animationFast; easing.type: Easing.OutCubic }
            }

            StyledText {
                anchors.centerIn: parent
                text: specialWorkspaceButton.specialName
                color: specialWorkspaceButton.active ? Theme.fg1 : Theme.fg0
                font.pixelSize: Settings.smallFontSize + 1
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 2
                height: 2
                color: specialWorkspaceButton.active ? Theme.green : Theme.transparent
            }

            MouseArea {
                id: pointer
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("hl.dsp.workspace.toggle_special(\"" + specialWorkspaceButton.specialName + "\")")
            }
        }

        Repeater {
            model: Settings.workspaceCount

            delegate: Rectangle {
                id: workspaceButton

                required property int index
                readonly property int workspaceId: index + 1
                readonly property var workspace: root.workspaceById(workspaceId)
                readonly property bool active: workspace !== null && workspace.active
                readonly property bool focused: workspace !== null && workspace.focused
                readonly property bool urgent: workspace !== null && workspace.urgent
                readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0

                visible: active || occupied || urgent
                width: visible ? 25 : 0
                height: workspaceRow.height
                color: pointer.pressed ? Theme.bg4 : pointer.containsMouse || focused ? Theme.statusline2 : Theme.transparent

                Behavior on color {
                    ColorAnimation { duration: Settings.animationFast; easing.type: Easing.OutCubic }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: workspaceButton.workspaceId
                    color: workspaceButton.urgent ? Theme.red : workspaceButton.focused ? Theme.fg1 : workspaceButton.occupied || workspaceButton.active ? Theme.fg0 : Theme.grey1
                    font.pixelSize: Settings.smallFontSize + 1
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                    height: 2
                    color: workspaceButton.urgent ? Theme.red : workspaceButton.focused ? Theme.green : Theme.transparent
                }

                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (workspaceButton.workspace)
                            workspaceButton.workspace.activate();
                        else
                            Hyprland.dispatch("workspace " + workspaceButton.workspaceId);
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        cursorShape: Qt.PointingHandCursor
        onWheel: wheel => Hyprland.dispatch(wheel.angleDelta.y > 0 ? "workspace e-1" : "workspace e+1")
    }
}
