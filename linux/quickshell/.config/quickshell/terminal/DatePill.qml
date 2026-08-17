import Quickshell
import QtQuick

Rectangle {
    id: root

    color: Colors.md3.secondary_container
    radius: 0
    implicitHeight: 32
    implicitWidth: dateLabel.implicitWidth + 20

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property var monthNames: [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    Text {
        id: dateLabel
        anchors.centerIn: parent
        text: clock.date.getDate() + " de " + root.monthNames[clock.date.getMonth()]
        color: Colors.md3.on_secondary_container
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font Propo"
        font.weight: Font.Medium
    }
}
