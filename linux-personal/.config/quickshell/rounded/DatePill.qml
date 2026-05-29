import Quickshell
import QtQuick

Rectangle {
    id: root

    color: Qt.rgba(Qt.color(Colors.md3.background).r, Qt.color(Colors.md3.background).g, Qt.color(Colors.md3.background).b, 0.75)
    radius: height / 2
    implicitHeight: 32
    implicitWidth: dateLabel.implicitWidth + 28

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
        color: Colors.md3.on_surface
        font.pixelSize: 14
        font.family: "JetBrainsMono Nerd Font Propo"
        font.weight: Font.Medium
    }
}
