//@ pragma UseQApplication

import Quickshell
import QtQuick
import "./simple-catppuccin/simple-bar"
import "./simple-catppuccin/app-launcher"

ShellRoot {
    id: root

    Bar {}
    Launcher {}
}
