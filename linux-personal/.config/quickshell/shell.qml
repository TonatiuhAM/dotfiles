//@ pragma UseQApplication

import Quickshell
import QtQuick
import "./terminal"
import "./Launcher"

ShellRoot {
    id: root

    Bar {}
    VolumeOSD {}
    Launcher {}
}
