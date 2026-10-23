import QtQuick
import Twilight.Core

// A fuse burning down along the bottom edge of a card, with a spark at its tip.
Item {
    id: root

    // How much of the fuse is left, 1 to 0.
    property real fuse: 1
    // Whether it is burning now, which spins the spark.
    property bool burning: false

    height: 4

    Rectangle {
        id: fuseBar

        width: parent.width * root.fuse
        height: parent.height
        radius: 2
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Theme.secondary }
            GradientStop { position: 1; color: Theme.star }
        }
    }

    Text {
        x: fuseBar.width - width / 2
        anchors.verticalCenter: parent.verticalCenter
        text: "✦"
        color: Theme.text
        font.pixelSize: 11
        visible: root.fuse > 0.02

        RotationAnimation on rotation {
            running: root.burning
            loops: Animation.Infinite
            from: 0
            to: 360
            duration: 900
        }
    }
}
