import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string cpu: "..."
    property string ram: "..."

    // previous /proc/stat totals, cpu % is the delta between two reads
    property real lastTotal: 0
    property real lastIdle: 0

    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight

    Process {
        id: usageProc
        command: ["sh", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")

                // cpu  user nice system idle iowait irq softirq steal
                const f = lines[0].trim().split(/\s+/).slice(1).map(Number)
                const idle = f[3] + (f[4] || 0)
                const total = f.reduce((a, b) => a + b, 0)
                if (root.lastTotal > 0 && total > root.lastTotal) {
                    const pct = 100 * (1 - (idle - root.lastIdle) / (total - root.lastTotal))
                    root.cpu = Math.round(pct) + "%"
                }
                root.lastTotal = total
                root.lastIdle = idle

                let memTotal = 0, memAvail = 0
                for (let i = 1; i < lines.length; i++) {
                    const kb = parseInt(lines[i].split(/\s+/)[1])
                    if (lines[i].startsWith("MemTotal")) memTotal = kb
                    else memAvail = kb
                }
                if (memTotal > 0) {
                    const gib = (kb) => (kb / 1048576).toFixed(1)
                    root.ram = gib(memTotal - memAvail) + "/" + gib(memTotal) + " GB"
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: box.miniDashboard
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            usageProc.running = false
            usageProc.running = true
        }
    }

    Column {
        id: col
        spacing: 2

        Text {
            anchors.right: parent.right
            text: "CPU " + root.cpu
            color: Theme.fg
            font { family: Theme.fontFamily; pixelSize: 10; weight: 600 }
        }

        Text {
            anchors.right: parent.right
            text: "RAM " + root.ram
            color: Theme.fg
            opacity: 0.6
            font { family: Theme.fontFamily; pixelSize: 10 }
        }
    }
}
