import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../terminal"
import "data.js" as Data

PanelWindow {
    id: root

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    color: "transparent"
    visible: false

    // ─── IPC via FIFO ─────────────────────────────────────────────────────────
    // Creates the pipe once, then a second Process loops: block → signal → toggle → repeat.
    // This gives <5ms response vs inotify file-watching.

    Process {
        id: pipeSetup
        // Re-create FIFO clean each time Quickshell starts
        command: ["sh", "-c", "rm -f /tmp/qs_launcher_pipe; mkfifo /tmp/qs_launcher_pipe"]
        onRunningChanged: if (!running) pipeWaiter.exec(pipeWaiter.command)
        Component.onCompleted: exec(command)
    }

    Process {
        id: pipeWaiter
        // Blocks until Hyprland bind does: echo t > /tmp/qs_launcher_pipe
        command: ["sh", "-c", "read x < /tmp/qs_launcher_pipe"]
        onRunningChanged: {
            if (!running) {
                root.visible ? root.close() : root.open()
                // Re-arm for next keypress
                Qt.callLater(() => exec(command))
            }
        }
    }

    // ─── State ───────────────────────────────────────────────────────────────
    property int    activeTab: 0
    property string searchText: ""
    property var    filteredItems: []
    property var    allApps: []
    property bool   appsLoaded: false
    property int    selectedIndex: -1

    // ─── App list loader ──────────────────────────────────────────────────────
    // Searches system packages + system flatpaks + user flatpaks.
    // Uses -L to follow symlinks (flatpak exports are often symlinks).
    Process {
        id: appListProc
        command: ["bash", "-c",
            "find -L" +
            " /usr/share/applications" +
            " /var/lib/flatpak/exports/share/applications" +
            " ~/.local/share/applications" +
            " ~/.local/share/flatpak/exports/share/applications" +
            " -maxdepth 1 -name '*.desktop' 2>/dev/null |" +
            " while IFS= read -r f; do" +
            "   name=$(grep -m1 '^Name='      \"$f\" | cut -d= -f2-);" +
            "   icon=$(grep -m1 '^Icon='      \"$f\" | cut -d= -f2-);" +
            "   nd=$(grep   -m1 '^NoDisplay=' \"$f\" | cut -d= -f2- | tr '[:upper:]' '[:lower:]');" +
            "   hid=$(grep  -m1 '^Hidden='    \"$f\" | cut -d= -f2- | tr '[:upper:]' '[:lower:]');" +
            "   [ \"$nd\"  = 'true' ] && continue;" +
            "   [ \"$hid\" = 'true' ] && continue;" +
            "   [ -z \"$name\" ]      && continue;" +
            "   printf '%s\\t%s\\t%s\\n' \"$name\" \"$icon\" \"$f\";" +
            " done | sort -f -t$'\\t' -k1,1"
        ]
        stdout: StdioCollector {
            onTextChanged: {
                const lines = text.trim().split("\n").filter(l => l.length > 0)
                const apps = []
                for (const line of lines) {
                    const p = line.split("\t")
                    if (p.length < 3) continue
                    apps.push({
                        name: p[0],
                        icon: p[1],
                        desktopFile: p[2],
                        type: "app",
                        itemIcon: ""
                    })
                }
                root.allApps = apps
                root.appsLoaded = true
                root.rebuild()
            }
        }
    }

    // ─── Executor ────────────────────────────────────────────────────────────
    // Wrapper script path — computed once at startup
    readonly property string execScript:
        Quickshell.env("HOME") + "/.config/quickshell/Launcher/launcher_exec.sh"

    // Shell command string that drives the execProc binding below.
    // We avoid dynamic JS-array assignment to list<string> because Quickshell
    // may silently discard it; a QML binding is always a valid list<string>.
    property string execShellCmd: ""

    Process {
        id: execProc
        // command is a QML binding — evaluated lazily when exec() reads it.
        // Changing root.execShellCmd marks it dirty; the next read sees new value.
        command: ["bash", root.execScript, root.execShellCmd]
    }

    // Delay close() so the launched process inherits a valid Wayland context
    // before the launcher releases exclusive keyboard focus.
    Timer {
        id: closeTimer
        interval: 50
        repeat: false
        onTriggered: root.close()
    }

    // Build a shell command string that launcher_exec.sh will run via `bash -c`.
    // Single-quotes each argument for safety; for ["sh/bash","-c","CMD"] patterns
    // the inner CMD is passed verbatim so $VAR references expand correctly.
    function buildLaunchCmd(item) {
        if (item.type === "app") {
            return "gio launch " + sq(item.desktopFile)
        }
        const cmd = item.command
        // ["sh","-c","CMD"] or ["bash","-c","CMD"] → pass CMD directly
        if (cmd.length >= 3 && (cmd[0] === "sh" || cmd[0] === "bash") && cmd[1] === "-c") {
            return cmd[2]
        }
        // Direct commands: ["systemctl","poweroff"] → 'systemctl' 'poweroff'
        return cmd.map(a => sq(a)).join(" ")
    }

    function sq(s) { return "'" + s.replace(/'/g, "'\\''") + "'" }

    // ─── Open / close ─────────────────────────────────────────────────────────
    function open() {
        activeTab = 0
        searchText = ""
        selectedIndex = -1
        rebuild()
        visible = true
        Qt.callLater(() => {
            searchInput.text = ""
            searchInput.forceActiveFocus()
        })
        if (!appsLoaded) appListProc.exec(appListProc.command)
    }

    function close() {
        visible = false
        searchInput.text = ""
        searchText = ""
        selectedIndex = -1
    }

    // ─── Build filtered list ──────────────────────────────────────────────────
    function rebuild() {
        const q = searchText.toLowerCase().trim()

        let list = []
        if (activeTab === 0) {
            for (const s of Data.scripts)
                if (!q || s.name.toLowerCase().includes(q)) list.push(s)
            for (const c of Data.systemCommands)
                if (!q || c.name.toLowerCase().includes(q)) list.push(c)
            if (appsLoaded)
                for (const a of allApps)
                    if (!q || a.name.toLowerCase().includes(q)) list.push(a)
        } else if (activeTab === 1) {
            if (appsLoaded)
                list = allApps.filter(a => !q || a.name.toLowerCase().includes(q))
        } else if (activeTab === 2) {
            list = Data.scripts.filter(s => !q || s.name.toLowerCase().includes(q))
        } else if (activeTab === 3) {
            list = Data.systemCommands.filter(c => !q || c.name.toLowerCase().includes(q))
        }

        filteredItems = list
        selectedIndex = list.length > 0 ? 0 : -1
    }

    // ─── Navigation ───────────────────────────────────────────────────────────
    function selectPrev() {
        if (filteredItems.length === 0) return
        selectedIndex = selectedIndex > 0 ? selectedIndex - 1 : filteredItems.length - 1
        resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function selectNext() {
        if (filteredItems.length === 0) return
        selectedIndex = selectedIndex < filteredItems.length - 1 ? selectedIndex + 1 : 0
        resultList.positionViewAtIndex(selectedIndex, ListView.Contain)
    }

    function switchTab(delta) {
        activeTab = ((activeTab + delta) % 4 + 4) % 4
        rebuild()
    }

    // ─── Execute ──────────────────────────────────────────────────────────────
    function execute() {
        if (selectedIndex < 0 || selectedIndex >= filteredItems.length) return

        // Capture item and build command BEFORE any state changes
        const shellCmd = buildLaunchCmd(filteredItems[selectedIndex])

        // Set the string property that drives the QML command binding
        root.execShellCmd = shellCmd

        // Launch BEFORE closing so the child process inherits the live Wayland session
        execProc.exec(execProc.command)

        // Close the launcher after a brief delay
        closeTimer.restart()
    }

    // ─── Backdrop ─────────────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        onClicked: root.close()
    }

    // ─── Panel ────────────────────────────────────────────────────────────────
    Rectangle {
        id: panel
        width: 560
        height: panelCol.implicitHeight
        anchors.centerIn: parent

        color: Colors.md3.surface
        border.width: 1
        border.color: Colors.md3.outline_variant
        radius: 0

        MouseArea { anchors.fill: parent }  // swallow backdrop clicks

        Column {
            id: panelCol
            width: parent.width

            // ── Search bar ────────────────────────────────────────────────
            Item {
                width: parent.width
                height: 46

                RowLayout {
                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                    spacing: 10

                    Text {
                        text: "󰍉"
                        color: Colors.md3.primary
                        font.pixelSize: 16
                        font.family: "JetBrainsMono Nerd Font"
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        color: Colors.md3.on_surface
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        selectionColor: Colors.md3.primary_container
                        selectedTextColor: Colors.md3.on_primary_container
                        cursorVisible: activeFocus
                        verticalAlignment: TextInput.AlignVCenter

                        cursorDelegate: Rectangle {
                            width: 2
                            color: Colors.md3.primary
                        }

                        Text {
                            anchors.fill: parent
                            text: "Go..."
                            color: Colors.md3.outline
                            font: searchInput.font
                            visible: searchInput.text.length === 0
                            verticalAlignment: Text.AlignVCenter
                        }

                        onTextChanged: {
                            root.searchText = text
                            root.rebuild()
                        }

                        Keys.onUpPressed:      (e) => { root.selectPrev(); e.accepted = true }
                        Keys.onDownPressed:    (e) => { root.selectNext(); e.accepted = true }
                        Keys.onReturnPressed:  (e) => { root.execute();    e.accepted = true }
                        Keys.onEnterPressed:   (e) => { root.execute();    e.accepted = true }
                        Keys.onEscapePressed:  (e) => { root.close();      e.accepted = true }
                        Keys.onTabPressed:     (e) => { root.switchTab(1); e.accepted = true }
                        Keys.onBacktabPressed: (e) => { root.switchTab(-1); e.accepted = true }

                        Keys.onPressed: (e) => {
                            if (e.modifiers & Qt.ControlModifier) {
                                if (e.key === Qt.Key_Left)  { root.switchTab(-1); e.accepted = true }
                                if (e.key === Qt.Key_Right) { root.switchTab(1);  e.accepted = true }
                            }
                        }
                    }

                    Text {
                        text: ["General", "Apps", "Scripts", "System"][root.activeTab]
                        color: Colors.md3.primary
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        opacity: 0.8
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.md3.outline_variant; opacity: 0.5 }

            // ── Tab bar ───────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 30
                color: Colors.md3.surface_container

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: [
                            { label: "General", icon: "󱗼" },
                            { label: "Apps",    icon: "󰣆" },
                            { label: "Scripts", icon: "󰅩" },
                            { label: "System",  icon: "󰒓" }
                        ]

                        delegate: Item {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Rectangle {
                                anchors.fill: parent
                                color: root.activeTab === index
                                       ? Colors.md3.primary_container
                                       : "transparent"
                            }

                            Rectangle {
                                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                                height: 2
                                color: Colors.md3.primary
                                visible: root.activeTab === index
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    root.activeTab = index
                                    root.rebuild()
                                    searchInput.forceActiveFocus()
                                }
                            }

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: modelData.icon
                                    color: root.activeTab === index
                                           ? Colors.md3.on_primary_container
                                           : Colors.md3.on_surface_variant
                                    font.pixelSize: 13
                                    font.family: "JetBrainsMono Nerd Font"
                                }
                                Text {
                                    text: modelData.label
                                    color: root.activeTab === index
                                           ? Colors.md3.on_primary_container
                                           : Colors.md3.on_surface_variant
                                    font.pixelSize: 10
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.weight: root.activeTab === index ? Font.Medium : Font.Normal
                                }
                            }
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: Colors.md3.outline_variant; opacity: 0.4 }

            // ── Results ───────────────────────────────────────────────────
            ListView {
                id: resultList
                width: parent.width
                height: Math.min(count, 6) * 34
                visible: count > 0
                clip: true
                model: root.filteredItems
                spacing: 0
                currentIndex: root.selectedIndex
                keyNavigationEnabled: false

                ScrollBar.vertical: ScrollBar {
                    policy: resultList.count > 6 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                    width: 4
                    contentItem: Rectangle {
                        radius: 2
                        color: Colors.md3.outline_variant
                    }
                }

                delegate: ResultItem {
                    required property int index
                    required property var modelData

                    width: resultList.width - (resultList.count > 6 ? 4 : 0)
                    itemName:     modelData.name
                    itemIcon:     modelData.icon ?? ""
                    itemIconName: modelData.type === "app" ? (modelData.icon ?? "") : ""
                    isApp:        modelData.type === "app"
                    isSelected:   root.selectedIndex === index

                    onActivated: {
                        root.selectedIndex = index
                        root.execute()
                    }
                }
            }

            Item {
                width: parent.width
                height: 34
                visible: resultList.count === 0

                Text {
                    anchors.centerIn: parent
                    text: (root.activeTab === 1 && !root.appsLoaded)
                          ? "Cargando aplicaciones…"
                          : "Sin resultados"
                    color: Colors.md3.outline
                    font.pixelSize: 12
                    font.family: "JetBrainsMono Nerd Font"
                }
            }

            // ── Footer ────────────────────────────────────────────────────
            Rectangle {
                width: parent.width
                height: 22
                color: Colors.md3.surface_container

                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 10 }
                    text: "↑↓ nav  Tab switch  ↵ run  Esc close"
                    color: Colors.md3.outline
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                }

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10 }
                    text: resultList.count > 0
                          ? (root.selectedIndex + 1) + " / " + resultList.count
                          : "0 / 0"
                    color: Colors.md3.outline
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }
    }
}
