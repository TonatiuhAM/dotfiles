import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Colors.md3.surface_container_high
    radius: 0
    implicitHeight: 32
    implicitWidth: audioRow.implicitWidth + 20

    property string netIcon: "󰌗"
    property int vol: 0
    property bool muted: false

    // wpctl is reliable — same source Waybar used
    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onTextChanged: {
                const line = text.trim()
                // Output: "Volume: 0.40" or "Volume: 0.40 [MUTED]"
                const match = line.match(/Volume:\s*([\d.]+)(\s*\[MUTED\])?/)
                if (match) {
                    root.vol = Math.round(parseFloat(match[1]) * 100)
                    root.muted = !!match[2]
                }
            }
        }
        Component.onCompleted: exec(command)
    }
    Timer { interval: 200; running: true; repeat: true; onTriggered: volProc.exec(volProc.command) }

    Process { id: volUp;   command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"] }
    Process { id: volDown; command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"] }
    Process { id: volMute; command: ["wpctl", "set-mute",   "@DEFAULT_AUDIO_SINK@", "toggle"] }

    Process {
        id: netProc
        command: ["sh", "-c",
            "iface=$(ip route 2>/dev/null | awk '/default/{print $5;exit}'); " +
            "if [ -z \"$iface\" ]; then echo 'none'; " +
            "elif [ -d /sys/class/net/$iface/wireless ]; then echo 'wifi'; " +
            "else echo 'eth'; fi"
        ]
        stdout: StdioCollector {
            onTextChanged: {
                const t = text.trim()
                if (t === "wifi") root.netIcon = "󰤨"
                else if (t === "eth") root.netIcon = "󰌗"
                else root.netIcon = "󰖪"
            }
        }
        Component.onCompleted: exec(command)
    }
    Timer { interval: 3000; running: true; repeat: true; onTriggered: netProc.exec(netProc.command) }

    Process {
        id: pulsemixerProc
        command: ["kitty", "--title", "pulsemixer", "pulsemixer"]
    }

    Process {
        id: impalaProc
        command: ["kitty", "--title", "impala", "impala"]
    }

    Process {
        id: powerProc
        command: ["/home/tona/.config/rofi/launcher.sh"]
    }

    RowLayout {
        id: audioRow
        anchors.centerIn: parent
        spacing: 10

        Item {
            implicitWidth: volLabel.implicitWidth
            implicitHeight: volLabel.implicitHeight

            Text {
                id: volLabel
                text: root.muted ? "󰖁 Muted" :
                      root.vol > 66 ? "󰕾 " + root.vol + "%" :
                      root.vol > 33 ? "󰖀 " + root.vol + "%" :
                                      "󰕿 " + root.vol + "%"
                color: root.muted ? Colors.md3.primary : Colors.md3.on_surface
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font Propo"
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        volMute.exec(volMute.command)
                        Qt.callLater(() => volProc.exec(volProc.command))
                    } else {
                        pulsemixerProc.exec(pulsemixerProc.command)
                    }
                }

                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) volUp.exec(volUp.command)
                    else volDown.exec(volDown.command)
                    Qt.callLater(() => volProc.exec(volProc.command))
                }
            }
        }

        Item {
            implicitWidth: netIconLabel.implicitWidth
            implicitHeight: netIconLabel.implicitHeight

            Text {
                id: netIconLabel
                text: root.netIcon
                color: Colors.md3.on_surface
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font Propo"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: impalaProc.exec(impalaProc.command)
            }
        }

        Item {
            implicitWidth: powerLabel.implicitWidth
            implicitHeight: powerLabel.implicitHeight

            Text {
                id: powerLabel
                text: ""
                color: Colors.md3.on_surface
                font.pixelSize: 13
                font.family: "JetBrainsMono Nerd Font Propo"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: powerProc.exec(powerProc.command)
            }
        }
    }
}
