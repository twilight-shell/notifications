import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Twilight.Core

// One notification as a sticker card: icon, app name, summary, body,
// action buttons and a fuse that burns down until the card leaves.
// Hover pauses the fuse, click runs the default action, drag right or
// the ✕ dismisses it.
Item {
    id: card

    required property var modelData
    required property int index

    readonly property var notification: modelData
    readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: notification?.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notification?.actions.filter(a => a.identifier !== "default") ?? []
    readonly property string iconSource: notification ? iconFor(notification) : ""
    // The notification object can be gone while the card plays its exit animation.
    // Seconds requested by the app, else 6s; critical ones stay until dismissed.
    readonly property int timeout: critical ? 0 : (notification?.expireTimeout > 0 ? notification.expireTimeout * 1000 : 6000)

    property real fuse: 1

    width: ListView.view.width
    height: content.implicitHeight + 28

    function dismiss() {
        notification?.dismiss();
    }

    function iconFor(notification) {
        const entry = notification.desktopEntry ? DesktopEntries.byId(notification.desktopEntry) : null;
        return Icons.find([notification.image, notification.appIcon, entry?.icon]);
    }

    Component.onCompleted: if (timeout > 0) burn.start()

    NumberAnimation {
        id: burn

        target: card
        property: "fuse"
        from: 1
        to: 0
        duration: card.timeout
        paused: running && hover.hovered
        onFinished: card.notification?.expire()
    }

    HoverHandler {
        id: hover
    }

    // Drag right to throw the card away.
    DragHandler {
        id: drag

        target: body
        xAxis.minimum: -20
        yAxis.enabled: false
        onActiveChanged: {
            if (active)
                return;
            if (body.x > 120)
                card.dismiss();
            else
                snapBack.restart();
        }
    }

    NumberAnimation {
        id: snapBack

        target: body
        property: "x"
        to: 0
        duration: 400
        easing.type: Easing.OutBack
        easing.overshoot: 2
    }

    Item {
        id: body

        width: card.width
        height: card.height
        opacity: 1 - Math.max(0, x) / 260
        rotation: x / 30
        scale: hover.hovered ? 1.02 : 1

        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2.5 }
        }

        Sticker {
            id: sticker

            anchors.fill: parent
            radius: 18
            lift: hover.hovered ? 8 : 6
            fill: Theme.surface
            edge: card.critical ? Theme.accent : Theme.ink

            Behavior on lift {
                NumberAnimation { duration: 250; easing.type: Easing.OutBack }
            }
        }

        // Critical cards pulse a pink halo.
        Rectangle {
            anchors.fill: parent
            anchors.margins: -4
            radius: 22
            color: "transparent"
            border.color: Theme.accent
            border.width: 2
            visible: card.critical

            SequentialAnimation on opacity {
                running: card.critical
                loops: Animation.Infinite

                NumberAnimation { to: 0.1; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.9; duration: 700; easing.type: Easing.InOutSine }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton && card.defaultAction)
                    card.defaultAction.invoke();
                else
                    card.dismiss();
            }
        }

        RowLayout {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 14
            }
            spacing: 12

            // Icon
            Sticker {
                Layout.alignment: Qt.AlignTop
                implicitWidth: 48
                implicitHeight: 48
                radius: 14
                lift: 3
                fill: Theme.surfaceHigh

                IconImage {
                    id: icon

                    anchors.centerIn: parent
                    implicitSize: 32
                    source: card.iconSource
                    visible: card.iconSource !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: !icon.visible
                    text: "✦"
                    color: Theme.star
                    font.pixelSize: 24
                    style: Text.Outline
                    styleColor: Theme.ink
                }

                // The icon hops in after the card lands.
                SequentialAnimation {
                    running: true

                    PropertyAction { target: icon; property: "scale"; value: 0 }
                    PauseAnimation { duration: 260 }
                    NumberAnimation { target: icon; property: "scale"; to: 1; duration: 520; easing.type: Easing.OutBack; easing.overshoot: 3 }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    StyledText {
                        Layout.fillWidth: true
                        text: card.notification?.appName || "notification"
                        color: Theme.muted
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Tap {
                        implicitWidth: 22
                        implicitHeight: 22
                        lift: 2
                        fill: Theme.surfaceHigh
                        hoverFill: Theme.accent
                        onClicked: card.dismiss()

                        StyledText {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 11
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: card.notification?.summary ?? ""
                    color: Theme.star
                    font.family: Theme.font
                    font.pixelSize: 15
                    font.bold: true
                    style: Text.Outline
                    styleColor: Theme.ink
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: card.notification?.body ?? ""
                    color: Theme.text
                    font.pixelSize: 13
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                }

                ActionButtons {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    visible: card.buttons.length > 0
                    actions: card.buttons
                }
            }
        }

        Fuse {
            visible: card.timeout > 0
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                leftMargin: 18
                rightMargin: 18
                bottomMargin: 7
            }
            fuse: card.fuse
            burning: burn.running && !burn.paused
        }
    }
}
