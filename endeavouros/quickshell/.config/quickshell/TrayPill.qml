import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Qt.rgba(Qt.color(Colors.md3.background).r, Qt.color(Colors.md3.background).g, Qt.color(Colors.md3.background).b, 0.75)
    radius: height / 2
    implicitHeight: 32
    implicitWidth: Math.max(trayRow.implicitWidth + 24, 48)

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
