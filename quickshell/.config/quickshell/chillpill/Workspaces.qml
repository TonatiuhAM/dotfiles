import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
  Layout.fillWidth: false
  spacing: 4 * Config.paddingScale
 
  Repeater {
    // Show workspaces dynamically, ignore maxWorkspaces if active workspaces are more than maxWorkspaces 
    model: Math.max(Config.maxWorkspaces, Hyprland.workspaces.values.reduce((max, w) => Math.max(max, w.id), 0))

    delegate: Rectangle {
      id: wsButton

      required property int index
      property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
      property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
      property string activeBg: Theme.wsActiveBg
      property string inactiveBg: Theme.wsInactiveBg

      // square pill showing only the workspace number
      Layout.preferredWidth: 17.5 * Config.pillScale
      Layout.preferredHeight: Layout.preferredWidth
      radius: 8 * Config.pillScale
      color: isActive ? activeBg : (ws ? inactiveBg : Theme.transparent)

      // animate color transition on workspace switch
      Behavior on color { ColorAnimation { duration: 120 } }

      Text {
        anchors.centerIn: parent
        text: wsButton.index + 1
        color: wsButton.isActive ? Theme.wsActiveFg : Theme.wsInactiveFg
        font {
          family: Theme.fontFamily
          pixelSize: 10 * Config.pillScale
          weight: 700
        }
      }

      // clickable text buttons
      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (wsButton.index + 1 + "})"))
        cursorShape: Qt.PointingHandCursor
      }
    }
  }

  // special workspaces (scratchpads like special:M) go after the numbered ones,
  // only while they hold windows (hyprland drops empty workspaces)
  property string openSpecial: "" // name of the special shown right now, "" when none

  Connections {
    target: Hyprland
    // activespecial>>special:M,DP-2 when shown, >>,DP-2 when hidden
    function onRawEvent(event) {
      if (event.name === "activespecial")
        openSpecial = event.data.split(",")[0]
    }
  }

  // initial state, in case a special was already open when the shell started
  Process {
    running: true
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const mon = JSON.parse(this.text).find(m => m.focused)
          if (mon && mon.specialWorkspace) openSpecial = mon.specialWorkspace.name || ""
        } catch (e) {}
      }
    }
  }

  Repeater {
    model: Hyprland.workspaces.values.filter(w => w.name.startsWith("special:"))

    delegate: Rectangle {
      id: specialButton

      required property var modelData
      readonly property string shortName: modelData.name.slice("special:".length)
      property bool isActive: openSpecial === modelData.name

      Layout.preferredWidth: 17.5 * Config.pillScale
      Layout.preferredHeight: Layout.preferredWidth
      radius: 8 * Config.pillScale
      color: isActive ? Theme.wsActiveBg : Theme.wsInactiveBg

      Behavior on color { ColorAnimation { duration: 120 } }

      Text {
        anchors.centerIn: parent
        // M is the minimized-apps scratchpad, others show their first letter
        text: specialButton.shortName === "M" ? String.fromCodePoint(0xf05b0) // nf-md-window_minimize
                                               : specialButton.shortName.charAt(0).toUpperCase()
        color: specialButton.isActive ? Theme.wsActiveFg : Theme.wsInactiveFg
        font {
          family: specialButton.shortName === "M" ? Theme.nerdFontFamily : Theme.fontFamily
          pixelSize: 10 * Config.pillScale
          weight: 700
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("hl.dsp.workspace.toggle_special(\"" + specialButton.shortName + "\")")
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
