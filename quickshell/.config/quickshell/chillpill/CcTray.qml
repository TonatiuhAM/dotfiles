import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

// system tray row (background services: discord, nextcloud, etc.) shown at the
// very bottom of the control center. Ported from simple-catppuccin/simple-bar/bar/Tray.qml
Item {
  id: root

  // window used to anchor the native tray menus (right click)
  required property var hostWindow
  property real iconSize: 18
  property real rowHeight: 28

  readonly property bool hasItems: SystemTray.items.values.length > 0

  implicitHeight: hasItems ? rowHeight : 0
  visible: hasItems

  Row {
    id: trayRow
    anchors.centerIn: parent
    spacing: 10

    Repeater {
      model: SystemTray.items

      delegate: Item {
        id: trayDelegate

        required property var modelData
        width: root.iconSize
        height: root.iconSize
        // small hover feedback
        scale: pointer.containsMouse ? 1.12 : 1.0
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

        IconImage {
          anchors.fill: parent
          source: trayDelegate.modelData.icon
        }

        MouseArea {
          id: pointer
          anchors.fill: parent
          hoverEnabled: true
          acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
          cursorShape: Qt.PointingHandCursor
          onClicked: mouse => {
            const item = trayDelegate.modelData
            if (mouse.button === Qt.MiddleButton) {
              item.secondaryActivate()
              return
            }
            if ((mouse.button === Qt.RightButton || item.onlyMenu) && item.hasMenu) {
              // map through the box's dpi scale into window coordinates
              const pos = trayDelegate.mapToItem(root.hostWindow.contentItem, mouse.x, mouse.y)
              item.display(root.hostWindow, Math.round(pos.x), Math.round(pos.y))
              return
            }
            item.activate()
          }
          onWheel: wheel => trayDelegate.modelData.scroll(wheel.angleDelta.y, false)
        }
      }
    }
  }
}
