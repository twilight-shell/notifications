import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The notification daemon, and the cards it shows in the top-right corner under
// the bar. Only one daemon can own the name on the session bus, so run this
// instead of mako, dunst and the like.
Scope {
    id: root

    // Name of the output to show on; the first screen when empty or unknown.
    // The compositor is the host's business, so the host sets it.
    property string outputName: ""
    // Screen y down to which something else covers the top of the column, such
    // as a popout hanging over it, 0 when nothing does. The cards move below it.
    property real avoid: 0

    // The notifications on screen, newest first.
    property var popups: []

    function hide(notification) {
        popups = popups.filter(n => n !== notification);
    }

    NotificationServer {
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
            notification.closed.connect(() => root.hide(notification));
            root.popups = [notification, ...root.popups];
        }
    }

    Popups {
        notifications: root.popups
        outputName: root.outputName
        avoid: root.avoid
    }
}
