import QtQuick
import Quickshell
import "../components"
import "../config"
import "../services"

PopupWindow {
    id: root

    required property Item anchorItem

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Settings.popupMargin
    anchor.adjustment: PopupAdjustment.All
    grabFocus: false

    implicitWidth: barRow.implicitWidth + 28
    implicitHeight: barRow.implicitHeight + 16
    color: Theme.transparent

    visible: false

    // ─── Volume state ─────────────────────────────────────────────────────
    // Bound live to AudioService, same as the bar's AudioIndicator — never
    // copied out of the osdRequested signal's arguments, since those can be
    // a stale pre-write snapshot (setVolume reads sink.audio.volume back
    // immediately after setting it, before PipeWire confirms the change).
    // osdRequested only tells us *when* to become visible.
    readonly property bool muted: AudioService.muted
    readonly property string icon: AudioService.volumeIcon(AudioService.volume, muted)
    readonly property int percentage: Math.round(AudioService.volume * 100)

    readonly property int totalBlocks: 20
    readonly property int filledBlocks: Math.round(Math.min(percentage / 100, 1.0) * totalBlocks)
    readonly property int emptyBlocks: totalBlocks - filledBlocks

    Connections {
        target: AudioService

        function onOsdRequested() {
            root.showOsd();
        }
    }

    // ─── Show / hide logic ────────────────────────────────────────────────
    function showOsd(): void {
        if (fadeOut.running)
            fadeOut.stop();
        root.visible = true;
        anchor.updateAnchor();
        osdBox.opacity = 1.0;
        hideTimer.restart();
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

        color: Theme.barBackground
        border.width: 1
        border.color: root.muted ? Theme.red : Theme.green
        radius: Settings.popupRadius

        Row {
            id: barRow
            anchors.centerIn: parent
            spacing: 0

            StyledText {
                text: root.icon + " "
                color: root.muted ? Theme.red : Theme.green
                font.family: Theme.iconFontFamily
            }

            StyledText {
                text: "["
                color: Theme.fg0
            }

            StyledText {
                text: "█".repeat(root.filledBlocks)
                color: root.muted ? Theme.red : Theme.green
            }

            StyledText {
                text: "░".repeat(root.emptyBlocks)
                color: Theme.grey0
            }

            StyledText {
                text: root.muted ? "] MUTED" : "] " + root.percentage + "%"
                color: Theme.fg0
            }
        }
    }
}
