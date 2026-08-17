import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root

    color: Colors.md3.tertiary_container
    radius: 0
    implicitHeight: 32
    implicitWidth: 42

    Process {
        id: launcherProc
        command: ["sh", "-c", "echo t > /tmp/qs_launcher_pipe"]
    }

    Text {
        anchors.centerIn: parent
        text: ""
        color: Colors.md3.on_tertiary_container
        font.pixelSize: 16
        font.family: "JetBrainsMono Nerd Font"
    }

    Rectangle {
        id: hoverOverlay
        anchors.fill: parent
        color: Colors.md3.on_tertiary_container
        opacity: 0
        radius: 0
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: launcherProc.exec(launcherProc.command)
        onEntered: hoverOverlay.opacity = 0.12
        onExited:  hoverOverlay.opacity = 0
        onPressed: hoverOverlay.opacity = 0.22
        onReleased: hoverOverlay.opacity = containsMouse ? 0.12 : 0
    }
}
