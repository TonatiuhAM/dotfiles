import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Colors.md3.surface_container
    radius: 0
    implicitHeight: 32
    implicitWidth: Math.max(trayRow.implicitWidth + 20, 40)

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: WrapperMouseArea {
                id: trayDelegate
                required property var modelData

                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                QsMenuAnchor {
                    id: trayMenu
                    anchor.item: trayDelegate
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                    // modelData.menu is already a QsMenuHandle — no .menu needed
                    menu: modelData.menu
                }

                IconImage {
                    implicitSize: 18
                    // SystemTrayItem.icon is already a fully-resolved image source
                    // (image://icon/... or image://qspixmap/...) — do not re-wrap
                    // with Quickshell.iconPath(), which expects a bare theme icon name.
                    source: modelData.icon
                    mipmap: true
                }

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
                        trayMenu.open()
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate()
                    } else {
                        modelData.activate()
                    }
                }
            }
        }
    }
}
