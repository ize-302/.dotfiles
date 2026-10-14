import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs

// Popup: a small floating glass gauge above the middle of the bar, drawn like
// the control panel's rows, shown for a moment whenever the output volume
// changes or the output or microphone is muted (from the volume keys, the
// bar or any app), or the brightness keys are pressed. Clicks go through it.
//
// The brightness has no change to watch (sysfs doesn't report one), so the
// brightness keys call `qs -c launcher ipc call osd showBrightness` after
// brightnessctl (config/sway/config).
Scope {
    id: root

    // Not while the control panel is open: it shows the same thing
    property bool suppressed: false
    property bool shown: false
    // "output", "input" (the microphone) or "brightness"
    property string mode: "output"
    // Volumes report in once when the daemon starts; that isn't a change
    property bool armed: false
    // Backlight brightness, 0 to 1, read with brightnessctl
    property real brightness: 0

    // The backlight is the laptop's own screen's, so brightness shows there;
    // volume shows on the screen with the focus
    readonly property var laptopScreen: Quickshell.screens.find(screen => screen.name.startsWith("eDP")) ?? null
    readonly property var focusedScreen: Quickshell.screens.find(screen => screen.name === I3.focusedMonitor?.name) ?? null

    readonly property PwNode node: mode === "input" ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool muted: mode !== "brightness" && (node?.audio?.muted ?? false)
    readonly property real level: mode === "brightness" ? brightness : node?.audio?.volume ?? 0

    function show(mode) {
        if (!armed || suppressed)
            return;

        root.mode = mode;
        if (!shown) {
            shown = true;
            panel.appear();
        }
        hide.restart();
    }

    IpcHandler {
        target: "osd"

        // Reads the brightness, then shows it
        function showBrightness(): void {
            brightnessRead.running = true;
        }
    }

    // "intel_backlight,backlight,3158,13%,24242": current, then max
    Process {
        id: brightnessRead

        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const fields = text.trim().split(",");
                if (fields.length < 5)
                    return;
                root.brightness = parseInt(fields[2]) / parseInt(fields[4]);
                root.show("brightness");
            }
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumesChanged() {
            root.show("output");
        }

        function onMutedChanged() {
            root.show("output");
        }
    }

    // The microphone's own volume is left out: apps turn it up and down
    // by themselves
    Connections {
        target: Pipewire.defaultAudioSource?.audio ?? null

        function onMutedChanged() {
            root.show("input");
        }
    }

    Timer {
        running: Pipewire.ready
        interval: 1000
        onTriggered: root.armed = true
    }

    Timer {
        id: hide
        interval: Theme.osdTimeout
        onTriggered: root.shown = false
    }

    onSuppressedChanged: if (suppressed)
        shown = false

    PanelWindow { // qmllint disable uncreatable-type
        visible: root.shown
        screen: root.mode === "brightness" && root.laptopScreen ? root.laptopScreen : root.focusedScreen
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        implicitWidth: panel.width
        implicitHeight: panel.height
        // Clicks go through to whatever is underneath
        mask: Region {}

        WlrLayershell.namespace: "launcher-shadow"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Only the bottom edge: centred above the bar
        anchors.bottom: true
        margins.bottom: Theme.osdMargin

        Glass {
            id: panel

            floating: true
            width: Theme.osdWidth
            height: Theme.rowHeight + Theme.panelPadding

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.panelPadding
                width: parent.width - x * 2
                spacing: Theme.iconSpacing

                // The control panel's glyphs: the bar's sun, speaker or
                // microphone
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSize
                    horizontalAlignment: Text.AlignHCenter
                    text: root.mode === "brightness" ? Theme.brightnessIcon : root.mode === "input" ? (root.muted ? Theme.micMutedIcon : Theme.micIcon) : Theme.volumeIcon(root.level, root.muted)
                    color: root.mode === "brightness" ? Theme.brightnessColor : Theme.volumeColor(root.level, root.muted)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlFontSize
                }

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.iconSize - percent.width - parent.spacing * 2
                    interactive: false
                    value: root.level
                    color: root.mode === "brightness" ? Theme.brightnessColor : Theme.volumeColor(root.level, root.muted)
                }

                // A key cap, as wide as "100%" so it doesn't jump
                KeyCap {
                    id: percent

                    anchors.verticalCenter: parent.verticalCenter
                    minWidth: Math.ceil(percentWidth.advanceWidth) + Theme.keyPadding * 2
                    text: root.muted ? "mute" : Math.round(root.level * 100) + "%"
                    fontSize: Theme.controlSmallFontSize
                    textColor: root.mode === "brightness" ? Theme.brightnessColor : Theme.keyTextColor
                }
            }
        }
    }

    TextMetrics {
        id: percentWidth
        text: "100%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.controlSmallFontSize
        font.weight: Theme.fontWeight
    }
}
