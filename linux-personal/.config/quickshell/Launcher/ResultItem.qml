import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../terminal"

Rectangle {
    id: root

    required property string itemName
    required property string itemIcon
    required property bool   isSelected
    required property bool   isApp
    required property string itemIconName

    signal activated()

    implicitHeight: 34
    color: isSelected ? Colors.md3.primary_container : "transparent"

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.activated()
        onEntered: if (!root.isSelected) root.color = Qt.alpha(Colors.md3.primary_container, 0.3)
        onExited:  if (!root.isSelected) root.color = "transparent"
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 14
            rightMargin: 14
        }
        spacing: 10

        // Icon — system icon for apps, nerd-font glyph for everything else
        Loader {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.alignment: Qt.AlignVCenter
            sourceComponent: (isApp && itemIconName !== "") ? appIcon : glyphIcon
        }

        Component {
            id: appIcon
            IconImage {
                source: itemIconName
                implicitSize: 16
            }
        }

        Component {
            id: glyphIcon
            Text {
                text: itemIcon
                color: root.isSelected
                       ? Colors.md3.on_primary_container
                       : Colors.md3.on_surface_variant
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Text {
            text: itemName
            color: root.isSelected
                   ? Colors.md3.on_primary_container
                   : Colors.md3.on_surface
            font.pixelSize: 13
            font.family: "JetBrainsMono Nerd Font"
            font.weight: root.isSelected ? Font.Medium : Font.Normal
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }
}
