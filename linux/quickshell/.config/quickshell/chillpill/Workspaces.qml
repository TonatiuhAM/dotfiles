import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
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

      // one entry per distinct app open in this workspace (deduped by appId/class)
      readonly property var apps: {
        if (!ws) return []
        const seen = new Set()
        const out = []
        for (const t of ws.toplevels.values) {
          const id = t.wayland?.appId || t.lastIpcObject?.class || ""
          if (!id || seen.has(id)) continue
          seen.add(id)
          out.push(id)
        }
        return out
      }

      readonly property real baseSize: 17.5 * Config.pillScale
      readonly property real iconSize: 11 * Config.pillScale

      // square pill when empty, grows to the right to fit the app icons
      Layout.preferredWidth: apps.length > 0 ? content.implicitWidth + 2 * (5 * Config.pillScale) : baseSize
      Layout.preferredHeight: baseSize
      radius: 8 * Config.pillScale
      color: isActive ? activeBg : (ws ? inactiveBg : Theme.transparent)

      // animate color transition on workspace switch
      Behavior on color { ColorAnimation { duration: 120 } }
      Behavior on Layout.preferredWidth { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

      Row {
        id: content
        anchors.centerIn: parent
        spacing: 3 * Config.pillScale

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: wsButton.index + 1
          color: wsButton.isActive ? Theme.wsActiveFg : Theme.wsInactiveFg
          font {
            family: Theme.fontFamily
            pixelSize: 10 * Config.pillScale
            weight: 700
          }
        }

        Repeater {
          model: wsButton.apps

          delegate: Item {
            id: appIcon
            required property string modelData
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: wsButton.iconSize
            implicitHeight: wsButton.iconSize
            // dim icons on non-focused workspaces
            opacity: wsButton.isActive ? 1.0 : 0.7

            // checked lookup: "" when nothing in the theme matches, so we never
            // hand IconImage a missing name (that renders the purple/black checkerboard)
            readonly property string iconSrc: wsButton.resolveIcon(modelData)

            IconImage {
              anchors.fill: parent
              visible: appIcon.iconSrc !== ""
              source: appIcon.iconSrc
              // black & white: fully desaturate the icon
              layer.enabled: true
              layer.effect: MultiEffect { saturation: -1.0 }
            }

            // generic glyph for apps with no resolvable icon
            Text {
              anchors.centerIn: parent
              visible: appIcon.iconSrc === ""
              text: String.fromCodePoint(0xf08c6) // nf-md-application_outline
              color: wsButton.isActive ? Theme.wsActiveFg : Theme.wsInactiveFg
              font.family: Theme.nerdFontFamily
              font.pixelSize: wsButton.iconSize
            }
          }
        }
      }

      // try several icon names for an app id and return the first one that exists
      function resolveIcon(appId) {
        const lower = appId.toLowerCase()
        const candidates = []
        const entry = DesktopEntries.heuristicLookup(appId)
        if (entry?.icon) candidates.push(entry.icon)
        candidates.push(appId, lower)
        // reverse-DNS ids (org.gnome.Nautilus -> nautilus)
        if (lower.includes(".")) candidates.push(lower.split(".").pop())
        // browser PWAs / suffixed classes (vivaldi-stable -> vivaldi)
        if (lower.includes("-")) candidates.push(lower.split("-")[0])

        for (const c of candidates) {
          if (!c) continue
          if (c.startsWith("/")) return "file://" + c
          const path = Quickshell.iconPath(c, true)
          if (path) return path
        }
        return Quickshell.iconPath("application-x-executable", true)
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
