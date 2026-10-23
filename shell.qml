import Quickshell
import Twilight.Notifications

// Standalone entry: `qs -p /path/to/notifications`. Stop any other notification
// daemon first: only one can own the name on the session bus.
ShellRoot {
    Notifications {}
}
