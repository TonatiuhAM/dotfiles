import QtQuick
import QtQuick.Layouts

Item {
  id: root
  property bool active: false
  property var notif: null

  anchors.centerIn: parent
  opacity: active ? 1 : 0
  visible: opacity > 0
  Behavior on opacity { NumberAnimation { duration: 150 } }

  RowLayout {
    anchors.centerIn: parent
    spacing: 10

    Text {
      text: String.fromCodePoint(0xf0f3)
      color: Theme.fg
      font { family: Theme.nerdFontFamily; pixelSize: 18 }
      visible: notifIcon.status !== Image.Ready
    }

    Image {
      id: notifIcon
      width: 27 * box.dpi
      height: 27 * box.dpi
      fillMode: Image.PreserveAspectCrop
      source: {
        if (root.notif && root.notif.image) return root.notif.image
        if (root.notif && root.notif.appIcon) {
          return root.notif.appIcon.startsWith("/") 
            ? "file://" + root.notif.appIcon 
            : "image://icon/" + root.notif.appIcon
        }
        return ""
      }
      sourceSize: Qt.size(27 * box.dpi, 27 * box.dpi)
      visible: status === Image.Ready
    }

    ColumnLayout {
      spacing: 3
      Text {
        text: root.notif ? root.notif.summary : ""
        textFormat: Text.PlainText
        color: Theme.fg
        font { family: Theme.fontFamily; pixelSize: 12; weight: 700 }
        elide: Text.ElideRight
        Layout.maximumWidth: 260
      }

      Text {
        text: root.notif ? root.notif.body.replace(
          /\[([^\]]+)\]\(["']?([^)"']+)["']?\)/g,
          '<a href="$2">$1</a>'
        ) : ""
        textFormat: Text.StyledText
        linkColor: Theme.accent
        color: Theme.notificationFg
        font { family: Theme.fontFamily; pixelSize: 11 }
        elide: Text.ElideRight
        Layout.maximumWidth: 260
        visible: text !== ""
      }
    }
  }
}
