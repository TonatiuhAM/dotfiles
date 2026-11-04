import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Moves the default audio output to Bluetooth headphones when they connect,
// and puts it back on the previous output (e.g. the speakers) when they disconnect.
//
// BlueZ only handles the Bluetooth link. Which output gets the audio is up to
// PipeWire/WirePlumber, and WirePlumber keeps whatever default was chosen last
// even after a new Bluetooth output shows up. So we switch it ourselves.
//
// Rules:
//  - New Bluetooth output appears  -> remember the current default and switch to Bluetooth.
//  - Bluetooth output goes away    -> if we were on Bluetooth, go back to the remembered output.
//  - If you pick another output by hand while the headphones are connected, that choice
//    is kept, and the audio doesn't move when they disconnect.
Scope {
    id: root

    // How long to wait before acting. Covers profile changes (A2DP <-> HFP), where
    // the Bluetooth output disappears and comes back quickly, and the first load,
    // when PipeWire hasn't told us the default output yet.
    property int settleMs: 800

    function isBtSink(node) {
        return node !== null && node !== undefined
            && node.isSink && !node.isStream
            && (node.name || "").startsWith("bluez_output.")
    }

    function findSinkByName(name) {
        if (!name) return null
        const nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            const n = nodes[i]
            if (n && n.isSink && !n.isStream && n.name === name) return n
        }
        return null
    }

    // Recomputed whenever the node list changes (a node is added or removed).
    // Uses node.name, which is available without binding the node.
    readonly property PwNode btSink: {
        const nodes = Pipewire.nodes.values
        for (let i = 0; i < nodes.length; i++) {
            if (root.isBtSink(nodes[i])) return nodes[i]
        }
        return null
    }

    // Survives config hot-reloads, so a reload doesn't switch the output again.
    PersistentProperties {
        id: state
        reloadableId: "bluetoothAudioRouter"

        property string handledBtName: ""   // Bluetooth output we already switched to
        property string savedSinkName: ""   // output to go back to on disconnect
        property bool routedToBt: false     // the default output is currently Bluetooth
    }

    function reconcile() {
        const bt = root.btSink
        const def = Pipewire.defaultAudioSink

        if (bt) {
            if (bt.name === state.handledBtName) return // already handled
            state.handledBtName = bt.name

            if (def && !root.isBtSink(def)) state.savedSinkName = def.name
            if (def !== bt) {
                console.log("[BluetoothAudioRouter] switching output to", bt.name)
                Pipewire.preferredDefaultAudioSink = bt
            }
            state.routedToBt = true
            return
        }

        if (state.handledBtName === "") return // nothing to undo
        state.handledBtName = ""

        if (state.routedToBt) {
            const back = root.findSinkByName(state.savedSinkName)
            if (back) {
                console.log("[BluetoothAudioRouter] Bluetooth gone, going back to", back.name)
                Pipewire.preferredDefaultAudioSink = back
            } else {
                console.log("[BluetoothAudioRouter] saved output", state.savedSinkName, "not found, leaving it to WirePlumber")
            }
        }
        state.routedToBt = false
    }

    onBtSinkChanged: settle.restart()

    Timer {
        id: settle
        interval: root.settleMs
        onTriggered: root.reconcile()
    }

    // Track output changes made by hand (pavucontrol, wpctl, the volume panel...)
    // while the headphones are connected, so we respect them.
    Connections {
        target: Pipewire
        function onDefaultAudioSinkChanged() {
            const def = Pipewire.defaultAudioSink
            if (settle.running || !root.btSink || !def) return
            if (state.handledBtName === "") return // not handled yet, reconcile() takes care of it
            if (root.isBtSink(def)) {
                state.routedToBt = true
            } else {
                state.routedToBt = false
                state.savedSinkName = def.name
            }
        }
    }

    Component.onCompleted: settle.restart()
}
