pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Wayland
import qs

// Caps lock popup, like macOS's: a rounded glass square in the middle of the
// screen with the focus, the ⇪ symbol and "Caps Lock On" (or dimmed, "Caps
// Lock Off"), for a moment each time it's switched. Clicks go through it.
//
// The state is the keyboards' caps lock lights
// (/sys/class/leds/*::capslock), which sway keeps the same on every
// keyboard. They're read a few times a second; sysfs doesn't say when they
// change.
Scope {
    id: root

    property bool on: false
    property bool shown: false
    // The first reading is what it already was, not a change
    property bool armed: false

    readonly property var focusedScreen: Quickshell.screens.find(screen => screen.name === I3.focusedMonitor?.name) ?? null

    function update(lit) {
        if (lit === on && armed)
            return;
        on = lit;
        if (!armed) {
            armed = true;
            return;
        }
        if (!shown) {
            shown = true;
            panel.appear();
        }
        hide.restart();
    }

    // Reads the lights in a loop and prints 1 or 0 when caps lock changes
    // (and once to start). Every keyboard's, found again each time, so
    // keyboards plugged in later count. One process; a file reader
    // re-reading sysfs kept its old value.
    Process {
        id: watcher

        command: ["python3", "-c", `
import glob, time
last = None
while True:
    lit = False
    for path in glob.glob("/sys/class/leds/*::capslock/brightness"):
        try:
            with open(path) as file:
                lit = lit or file.read().strip() not in ("", "0")
        except OSError:
            pass
    if lit != last:
        print(int(lit), flush=True)
        last = lit
    time.sleep(${Theme.capsLockPoll / 1000})
`]
        running: true

        stdout: SplitParser {
            onRead: line => root.update(line.trim() === "1")
        }

        // Gone: again in a moment, without spinning if it keeps failing
        onExited: restart.start()
    }

    Timer {
        id: restart
        interval: 5000
        onTriggered: watcher.running = true
    }

    Timer {
        id: hide
        interval: Theme.capsLockTimeout
        onTriggered: root.shown = false
    }

    PanelWindow { // qmllint disable uncreatable-type
        visible: root.shown
        screen: root.focusedScreen
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        implicitWidth: panel.width
        implicitHeight: panel.height
        // Clicks go through to whatever is underneath
        mask: Region {}

        // No edges anchored: the layer shell centres it. Blurred behind
        // (`layer_effects "launcher"`), but no drop shadow: it's meant to
        // be subtle.
        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Glass {
            id: panel

            floating: true
            cornerRadius: Theme.capsLockRadius
            width: Theme.capsLockSize
            height: Theme.capsLockSize
            // More see-through than the menus, plain, with a faint edge
            color: Theme.capsLockColor
            sheen: false
            edgeColor: Theme.capsLockEdgeColor

            Column {
                anchors.centerIn: parent
                spacing: Theme.panelPadding / 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Theme.capsLockIcon
                    color: root.on ? Theme.keyTextColor : Theme.dimColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.capsLockSize * 0.42
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.on ? "Caps Lock On" : "Caps Lock Off"
                    color: root.on ? Theme.keyTextColor : Theme.dimColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlSmallFontSize
                    font.weight: Theme.fontWeight
                }
            }
        }
    }
}
