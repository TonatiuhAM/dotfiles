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

    implicitHeight: 32
    color: Colors.md3.surface

    RowLayout {
        anchors.fill: parent
        spacing: 0

        LauncherButton {}
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
