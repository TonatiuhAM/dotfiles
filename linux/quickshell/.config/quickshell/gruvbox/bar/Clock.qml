import QtQuick
import Quickshell
import "../components"
import "../config"
import "../services"

ModuleButton {
    id: root

    required property string screenName

    implicitWidth: 78
    baseColor: Theme.bg1
    horizontalPadding: 9

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    StyledText {
        text: Qt.formatDateTime(clock.date, "hh:mm AP")
        color: Theme.fg1
    }

    onClicked: PopupManager.toggle("calendar", screenName)
}
