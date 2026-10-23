import QtQuick
import Twilight.Core

// One button per action the app offers.
Flow {
    id: root

    // The notification's actions to offer as buttons.
    property var actions: []

    spacing: 8

    Repeater {
        model: root.actions

        Tap {
            required property var modelData

            implicitWidth: label.implicitWidth + 24
            implicitHeight: 28
            fill: Theme.secondary
            hoverFill: Theme.primary
            onClicked: modelData.invoke()

            StyledText {
                id: label

                anchors.centerIn: parent
                text: modelData.text
                font.pixelSize: 12
            }
        }
    }
}
