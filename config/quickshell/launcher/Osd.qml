import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs

// Volume popup: a small glass gauge centred just above the bar, in the caps
// lock popup's glass, drawn like the control panel's rows, shown for a
// moment on the screen with the focus whenever the output volume changes or
// the output or microphone is muted (from the volume keys, the bar or any
// app). Clicks go through it.
Scope {
    id: root

    // Not while the control panel is open: it shows the same thing
    property bool suppressed: false
    property bool shown: false
    // "output", or "input" (the microphone)
    property string mode: "output"
    // Volumes report in once when the daemon starts; that isn't a change
    property bool armed: false

    readonly property var focusedScreen: Quickshell.screens.find(screen => screen.name === I3.focusedMonitor?.name) ?? null
    readonly property PwNode node: mode === "input" ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real level: node?.audio?.volume ?? 0

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
        screen: root.focusedScreen
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        implicitWidth: panel.width
        implicitHeight: panel.height
        // Clicks go through to whatever is underneath
        mask: Region {}

        // Only the bottom anchored: the layer shell centres it across
        anchors.bottom: true
        margins.bottom: Theme.centredGap

        // Blurred behind (`layer_effects "launcher"`), but no drop shadow,
        // like the caps lock popup
        WlrLayershell.namespace: "launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Glass {
            id: panel

            floating: true
            width: Theme.osdWidth
            height: Theme.rowHeight + Theme.panelPadding
            // The caps lock popup's fainter glass
            color: Theme.popupColor
            edgeColor: Theme.popupEdgeColor

            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.panelPadding
                width: parent.width - x * 2
                spacing: Theme.iconSpacing

                // The control panel's glyphs: the bar's speaker, or the
                // microphone
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSize
                    horizontalAlignment: Text.AlignHCenter
                    text: root.mode === "input" ? (root.muted ? Theme.micMutedIcon : Theme.micIcon) : Theme.volumeIcon(root.level, root.muted)
                    color: Theme.volumeColor(root.level, root.muted)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlFontSize
                }

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.iconSize - percent.width - parent.spacing * 2
                    interactive: false
                    value: root.level
                    color: Theme.sliderColor(root.level, root.muted)
                }

                // A key cap, as wide as "100%" so it doesn't jump
                KeyCap {
                    id: percent

                    anchors.verticalCenter: parent.verticalCenter
                    minWidth: Math.ceil(percentWidth.advanceWidth) + Theme.keyPadding * 2
                    text: root.muted ? "mute" : Math.round(root.level * 100) + "%"
                    fontSize: Theme.controlSmallFontSize
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
