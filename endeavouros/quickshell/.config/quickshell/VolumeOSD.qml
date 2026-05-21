import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    anchors.bottom: true
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    margins.bottom: 70

    implicitWidth: barRow.implicitWidth + 28
    implicitHeight: barRow.implicitHeight + 16
    color: "transparent"

    visible: false

    // ─── Volume state ─────────────────────────────────────────────────────
    // vol = -1 means "not yet initialized" — first read won't trigger the OSD
    property int vol: -1
    property bool muted: false

    readonly property int totalBlocks: 20
    readonly property int filledBlocks: vol < 0 ? 0 : Math.round(Math.min(vol / 100, 1.0) * totalBlocks)
    readonly property int emptyBlocks: totalBlocks - filledBlocks

    // ─── Polling (same proven pattern as AudioNetPill) ────────────────────
    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onTextChanged: {
                const match = text.trim().match(/Volume:\s*([\d.]+)(\s*\[MUTED\])?/)
                if (!match) return
                const newVol = Math.round(parseFloat(match[1]) * 100)
                const newMuted = !!match[2]

                if (root.vol === -1) {
                    // First read: store baseline without showing OSD
                    root.vol = newVol
                    root.muted = newMuted
                } else if (newVol !== root.vol || newMuted !== root.muted) {
                    root.vol = newVol
                    root.muted = newMuted
                    showOsd()
                }
            }
        }
        Component.onCompleted: exec(command)
    }

    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: volProc.exec(volProc.command)
    }

    // ─── Show / hide logic ────────────────────────────────────────────────
    function showOsd() {
        if (fadeOut.running) fadeOut.stop()
        root.visible = true
        osdBox.opacity = 1.0
        hideTimer.restart()
    }

    NumberAnimation {
        id: fadeOut
        target: osdBox
        property: "opacity"
        to: 0.0
        duration: 200
        easing.type: Easing.InOutQuad
        onFinished: root.visible = false
    }

    Timer {
        id: hideTimer
        interval: 2000
        repeat: false
        onTriggered: fadeOut.start()
    }

    // ─── Visual ───────────────────────────────────────────────────────────
    Rectangle {
        id: osdBox
        anchors.fill: parent
        opacity: 0.0

        color: Qt.rgba(
            Qt.color(Colors.md3.background).r,
            Qt.color(Colors.md3.background).g,
            Qt.color(Colors.md3.background).b,
            0.95
        )
        border.width: 1
        border.color: root.muted ? Colors.md3.error : Colors.md3.primary
        radius: 0

        Row {
            id: barRow
            anchors.centerIn: parent
            spacing: 0

            Text {
                text: root.muted ? "󰖁 " :
                      root.vol > 66 ? "󰕾 " :
                      root.vol > 33 ? "󰖀 " : "󰕿 "
                color: root.muted ? Colors.md3.error : Colors.md3.primary
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "["
                color: Colors.md3.on_surface_variant
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "█".repeat(root.filledBlocks)
                color: root.muted ? Colors.md3.error : Colors.md3.primary
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: "░".repeat(root.emptyBlocks)
                color: Colors.md3.outline_variant
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                text: root.muted ? "] MUTED" : "] " + root.vol + "%"
                color: Colors.md3.on_surface_variant
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
