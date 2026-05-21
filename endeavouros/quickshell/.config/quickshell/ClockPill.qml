import Quickshell
import QtQuick

Rectangle {
    id: root

    color: Qt.rgba(Qt.color(Colors.md3.background).r, Qt.color(Colors.md3.background).g, Qt.color(Colors.md3.background).b, 0.75)
    radius: height / 2
    implicitHeight: 32
    implicitWidth: timeLabel.implicitWidth + 28

    // SystemClock is the correct Quickshell singleton — no manual Timer needed
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: timeLabel
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: Colors.md3.on_surface
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font Propo"
        font.weight: Font.Medium
    }
}
