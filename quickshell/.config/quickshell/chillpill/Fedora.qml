import Quickshell
import QtQuick

// fedora logo, left click opens the spotlight app launcher
Text {
  id: root

  text: String.fromCodePoint(0xf30a) // nf-linux-fedora
  color: Theme.fg

  font {
    family: Theme.nerdFontFamily
    pixelSize: 12 * Config.pillScale
  }

  // own MouseArea so the click doesn't fall through to the pill (which opens the control center)
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      box.controlCenter = false
      box.miniDashboard = false
      box.cliphistOpen = false
      box.wallpaperSwitcherOpen = false
      box.powerMenu = false
      box.themePicker = false
      box.spotlight = true
    }
  }
}
