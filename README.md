# twilight-shell/notifications

The notification daemon of the [twilight-shell](https://github.com/twilight-shell)
organization, and the cards it shows: stickers in the top-right corner under the
bar. New cards fly in from the right and the rest slide down to make room, a fuse
burns down until the card leaves, hover pauses it, a click runs the default
action, and a drag to the right or the ✕ dismisses it. Critical notifications
pulse a pink halo and stay until dismissed. It works on its own or as a piece of
the full shell.

## Requirements

[Quickshell](https://quickshell.org) 0.3 or newer and
[twilight-shell/core](https://github.com/twilight-shell/core) installed.

Only one daemon can own the name on the session bus, so stop mako, dunst and the
like before you start this one.

## Running on its own

```sh
qs -p /path/to/notifications
```

If `Twilight.Core` is not in a directory Qt searches, point `QML_IMPORT_PATH` at
its parent.

## Using it in a shell

```sh
sudo make install        # to /usr/lib/qt6/qml/Twilight/Notifications
```

```qml
import Twilight.Notifications

Notifications {
    outputName: "DP-1"      // where to show them; the first screen by default
    avoid: popouts.push     // keep below a card that hangs over their corner
}
```

| | |
|---|---|
| `outputName` | The output to show on. |
| `avoid` | Screen y down to which something else covers the top of the column, `0` when nothing does. The cards move below it. |

## License

MIT, see `LICENSE`.
