import QtQuick
import Quickshell
import Quickshell.Wayland
import Twilight.Core
import "card"

// Notification popups stacked in the top-right corner under the bar.
// New cards fly in from the right, the rest slide down to make room.
PanelWindow {
    id: window

    // The notifications on screen, newest first.
    property var notifications: []
    // Name of the output to show on; the first screen when empty or unknown.
    property string outputName: ""
    // Screen y down to which something else covers the top of the column, 0
    // when nothing does. The cards stay below it.
    property real avoid: 0

    screen: Quickshell.screens.find(s => s.name === window.outputName) ?? Quickshell.screens[0]
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    // Spare room on the left: cards overshoot past their spot as they spring in.
    readonly property int overshoot: 56

    implicitWidth: 392 + overshoot + Theme.gap
    // Only the cards take input; the rest of the window lets clicks through.
    mask: Region {
        item: list
    }

    WlrLayershell.namespace: "twilight-notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: 64
        right: Theme.gap
    }

    ListView {
        id: list

        x: window.overshoot
        // Room for the critical halo around the top card, and below any
        // popout hanging over this corner.
        y: Math.max(6, window.avoid + 16 - window.margins.top)
        width: 392
        height: contentHeight
        interactive: false
        spacing: 12
        model: ScriptModel {
            values: window.notifications
        }

        delegate: NotificationCard {}

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; from: 440; to: 0; duration: 620; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
                NumberAnimation { property: "rotation"; from: 10; to: 0; duration: 720; easing.type: Easing.OutBack; easing.overshoot: 2 }
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation { property: "x"; to: 440; duration: 320; easing.type: Easing.InBack; easing.overshoot: 1.2 }
                NumberAnimation { property: "rotation"; to: 6; duration: 320 }
                NumberAnimation { property: "opacity"; to: 0; duration: 320; easing.type: Easing.InQuad }
            }
        }

        displaced: Transition {
            NumberAnimation { property: "y"; duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
            NumberAnimation { property: "x"; to: 0; duration: 300 }
            NumberAnimation { property: "opacity"; to: 1; duration: 200 }
        }
    }
}
