import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import qs

// Volume popup: a small floating glass gauge above the middle of the bar,
// shown for a moment whenever the output volume changes or the output or
// microphone is muted, from the volume keys, the bar or any app. Clicks go
// through it.
Scope {
    id: root

    // Not while the control panel is open: it shows the same thing
    property bool suppressed: false
    property bool shown: false
    // Showing the microphone instead of the output
    property bool input: false
    // Volumes report in once when the daemon starts; that isn't a change
    property bool armed: false

    readonly property PwNode node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real level: node?.audio?.volume ?? 0

    function show(input) {
        if (!armed || suppressed)
            return;

        root.input = input;
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
            root.show(false);
        }

        function onMutedChanged() {
            root.show(false);
        }
    }

    // The microphone's own volume is left out: apps turn it up and down
    // by themselves
    Connections {
        target: Pipewire.defaultAudioSource?.audio ?? null

        function onMutedChanged() {
            root.show(true);
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

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.iconSize
                    horizontalAlignment: Text.AlignHCenter
                    text: root.input ? (root.muted ? Theme.micMutedIcon : Theme.micIcon) : Theme.volumeIcon(root.level, root.muted)
                    color: Theme.volumeColor(root.level, root.muted)
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                Slider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - Theme.iconSize - percent.width - parent.spacing * 2
                    interactive: false
                    value: root.level
                    color: Theme.volumeColor(root.level, root.muted)
                }

                Text {
                    id: percent

                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.ceil(percentWidth.advanceWidth)
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.level * 100) + "%"
                    color: root.muted ? Theme.dimColor : Theme.keyTextColor
                    font: percentWidth.font
                }
            }
        }
    }

    // The widest volume, so the gauge doesn't jump
    TextMetrics {
        id: percentWidth
        text: "100%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
