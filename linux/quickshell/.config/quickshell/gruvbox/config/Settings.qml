pragma Singleton

import Quickshell

Singleton {
    readonly property int barHeight: 32
    readonly property int moduleHeight: barHeight
    readonly property int fontSize: 14
    readonly property int smallFontSize: 12
    readonly property int activeWindowMaxWidth: 260
    readonly property int mediaMaxWidth: 420
    readonly property int popupWidth: 410
    readonly property int popupMargin: 7
    readonly property int popupRadius: 4
    readonly property int animationFast: 140
    readonly property int animationNormal: 180
    readonly property int workspaceCount: 7
    readonly property int volumeStep: 5
    readonly property string clockTimeZone: "America/Argentina/Cordoba"
    readonly property bool powerProfilesAvailable: false
    readonly property string launcherToggleScript: Quickshell.env("HOME") + "/.config/quickshell/Launcher/toggle_launcher.sh"
}
