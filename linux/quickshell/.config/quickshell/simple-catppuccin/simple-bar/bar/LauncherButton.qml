import QtQuick
import Quickshell
import "../components"
import "../config"

ModuleButton {
    id: root

    implicitWidth: 36
    baseColor: Theme.green
    hoverColor: Theme.aqua
    pressedColor: Theme.yellow
    horizontalPadding: 6

    StyledText {
        text: ""
        color: Theme.bg0
        font.family: Theme.iconFontFamily
        font.pixelSize: 18
        font.weight: Font.DemiBold
    }

    onClicked: Quickshell.execDetached(["sh", Settings.launcherToggleScript])
}
