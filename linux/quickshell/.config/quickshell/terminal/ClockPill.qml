import Quickshell
import QtQuick

Rectangle {
    id: root

    color: Colors.md3.primary
    radius: 0
    implicitHeight: 32
    implicitWidth: timeLabel.implicitWidth + 20

    // SystemClock is the correct Quickshell singleton — no manual Timer needed
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: timeLabel
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: Colors.md3.on_primary
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font Propo"
        font.weight: Font.Medium
    }
}
