import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Qt.rgba(Qt.color(Colors.md3.background).r, Qt.color(Colors.md3.background).g, Qt.color(Colors.md3.background).b, 0.75)
    radius: height / 2
    implicitHeight: 32
    implicitWidth: sysRow.implicitWidth + 24

    property string cpuVal: "0"
    property string tempVal: "0"
    property string memVal: "0"

    Process {
        id: cpuProc
        command: ["sh", "-c", "awk '/^cpu /{idle=$5;t=0;for(i=2;i<=NF;i++)t+=$i;printf \"%.0f\",(1-idle/t)*100}' /proc/stat"]
        stdout: StdioCollector { onTextChanged: root.cpuVal = text.trim() }
        Component.onCompleted: exec(command)
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: cpuProc.exec(cpuProc.command) }

    Process {
        id: tempProc
        command: ["sh", "-c", "awk '{printf \"%.0f\",$1/1000}' /sys/class/hwmon/hwmon2/temp1_input"]
        stdout: StdioCollector { onTextChanged: root.tempVal = text.trim() }
        Component.onCompleted: exec(command)
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: tempProc.exec(tempProc.command) }

    Process {
        id: memProc
        command: ["sh", "-c", "free | awk '/^Mem:/{printf \"%.0f\",$3/$2*100}'"]
        stdout: StdioCollector { onTextChanged: root.memVal = text.trim() }
        Component.onCompleted: exec(command)
    }
    Timer { interval: 2000; running: true; repeat: true; onTriggered: memProc.exec(memProc.command) }

    Process {
        id: btopProc
        command: ["kitty", "--title", "btop", "btop"]
    }

    RowLayout {
        id: sysRow
        anchors.centerIn: parent
        spacing: 10

        Text {
            text: " " + root.cpuVal + "%"
            color: Colors.md3.on_surface
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font Propo"
        }
        Text {
            text: " " + root.tempVal + "°C"
            color: Colors.md3.on_surface
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font Propo"
        }
        WrapperMouseArea {
            onClicked: btopProc.exec(btopProc.command)

            Text {
                text: " " + root.memVal + "%"
                color: Colors.md3.on_surface
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font Propo"
            }
        }
    }
}
