# AGENTS.md

For AI coding agents working in this repository; humans may find it a quick orientation. The full guide is [CONTRIBUTING.md](CONTRIBUTING.md) and [the organization's](https://github.com/twilight-shell/.github/blob/main/CONTRIBUTING.md).

## What this is

The notification daemon (`org.freedesktop.Notifications`) and its cards.

It is one repository of [twilight-shell](https://github.com/twilight-shell), a Wayland desktop shell made of independent repositories. It needs: Twilight.Core.

## Layout

- `Twilight/Notifications/Notifications.qml`: the server and the stack of cards; `Popups.qml` places them
- `Twilight/Notifications/card/`: the card, its fuse and its action buttons
- `DEPENDS`: the modules it needs; `CHANGELOG.md`; `Makefile` (`make install`)

## Run and check it

```sh
XDG_CONFIG_HOME=$(mktemp -d) QML_IMPORT_PATH=$HOME/src/core:$HOME/src/notifications qs -p .
```

Send one with `busctl --user call org.freedesktop.Notifications /org/freedesktop/Notifications org.freedesktop.Notifications Notify susssasa{sv}i app 0 "" Title Body 0 0 5000`.

There are no automated tests for what is drawn: run it, look at it, and say what you tried.

The checks CI runs are scripts in the [`.github` repository](https://github.com/twilight-shell/.github/tree/main/ci); run them before you push.

## Rules

- Work on a branch (`feat/...`, `fix/...`, `docs/...`); never commit to or push `main`. Changes land through a pull request.
- Commit messages are `type: Subject` (`feat`, `fix`, `docs`, `test`, `ci`, `chore`, `refactor`), imperative, capitalized, no full stop.
- One change per pull request, small. Update the `CHANGELOG.md` (`## Unreleased`), the README, and `DEPENDS` if you import another `Twilight.*` module.
- **Defaults live in one place:** `<name>.defaults.toml`. Never repeat a default in code.
- **A component doesn't know the others:** what it needs comes in as properties and signals, set by the shell. Don't import another component to reach into it.
- Don't add a dependency without asking. Comments say why, not what; English; match the style around.

## Be careful

- **Use a throwaway settings folder** while you try things: `XDG_CONFIG_HOME=$(mktemp -d)`. Don't write to the user's `~/.config/twilight-shell/`.
- **Don't match your own command with `pkill -f` or `pgrep -f`:** a pattern that is in the command line of the shell that runs it kills that shell. Use `pgrep -x qs`, or `qs -p <path> kill`.
- A screenshot of the whole screen shows whatever windows are open. Take them on an empty workspace, and don't publish what isn't yours.
- Don't run the real lock screen without a way out (a TTY, and a timer that unlocks); see the `lock` repository.

## This repository

- Only one program can own the name `org.freedesktop.Notifications` on the session bus. To try this, stop the other daemon first; mako comes back by itself through D-Bus activation when the name is free.

## QML and Quickshell gotchas

- Typed properties (`string`, `bool`, `real`) see `undefined` at startup until a defaults file is read; coerce with `!!x`, `Number(x)` or `x ?? ""` rather than repeating the default.
- In a function with typed parameters QML wants a return type too (`function f(a: string): void`); without it a returned value is an error.
- An `id` can hide a property of the same name: `auth: auth` is a property bound to itself. Give ids names that don't repeat a property.
- `Process` and `FileView` are asynchronous; whatever reads their result has to wait for it.
- Quickshell loads the config again when a file of the config changes, but QML Qt has already loaded from elsewhere is cached, and the list of module folders is read once, at start.
- A `Row` doesn't use `implicitWidth`: give the items a `width`, or they have none.
