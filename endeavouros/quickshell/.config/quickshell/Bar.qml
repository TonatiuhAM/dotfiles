import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 5
        left: 10
        right: 10
    }

    implicitHeight: 36
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        spacing: 8

        WorkspacesPill {}
        FocusedWindowPill {}
        SysInfoPill {}

        Item { Layout.fillWidth: true }

        TrayPill {}
        AudioNetPill {}
        DatePill {}
        ClockPill {}
    }
}
