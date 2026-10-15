pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs

// Music popup: what's playing (MediaRow.qml) on the glass panel of the
// other menus, floating just above the bar by the right edge. Toggled by
// ~/.local/bin/media-panel (`qs -c launcher ipc call media toggleMediaPanel`)
// or the bar's music module.
//
// Space or Enter plays or pauses, Left and Right (or h and l) skip back and
// forward, and Escape closes it. It closes by itself when the player goes.
//
// The bar's music module is a note while a song is playing, dimmed while
// paused: this writes $XDG_RUNTIME_DIR/media.json for waybar's
// custom/media module and signals it (SIGRTMIN+9) to read it again. With
// nothing playing or paused the text is empty, which hides the module.
Scope {
    id: root

    property bool open: false

    // The player to show: one that's playing, else one with a track, paused
    readonly property MprisPlayer player: {
        const players = Mpris.players.values.filter(player => player.trackTitle || player.isPlaying);
        return players.find(player => player.isPlaying) ?? players[0] ?? null;
    }

    // What the bar's module shows: { text, class } for waybar
    readonly property string status: {
        if (!player || !player.trackTitle)
            return JSON.stringify({
                text: ""
            });
        // Just the note; the song is in the popup
        return JSON.stringify({
            text: Theme.musicIcon,
            class: player.isPlaying ? "playing" : "paused"
        });
    }

    onStatusChanged: statusFile.setText(status + "\n")
    Component.onCompleted: statusFile.setText(status + "\n")

    // Nothing left to control
    onPlayerChanged: if (!player)
        open = false

    IpcHandler {
        target: "media"

        function toggleMediaPanel(): void {
            root.open = !root.open && root.player !== null;
        }
    }

    FileView {
        id: statusFile

        path: Quickshell.env("XDG_RUNTIME_DIR") + "/media.json"
        printErrors: false
        onSaved: Quickshell.execDetached(["pkill", "-RTMIN+9", "-x", "waybar"])
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: window

        visible: root.open && root.player !== null
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        implicitWidth: Theme.mediaPanelWidth
        implicitHeight: panel.height

        WlrLayershell.namespace: "launcher-shadow"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            bottom: true
            right: true
        }
        margins.bottom: Theme.floatingGap
        margins.right: Theme.floatingGap

        onVisibleChanged: {
            if (!visible)
                return;

            keys.forceActiveFocus();
            panel.appear();
        }

        Glass {
            id: panel

            floating: true
            width: parent.width
            height: media.implicitHeight + Theme.panelPadding * 2

            Item {
                id: keys

                Keys.onPressed: event => {
                    const player = root.player;
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q)
                        root.open = false;
                    else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        player.togglePlaying();
                    else if ((event.key === Qt.Key_Right || event.key === Qt.Key_L) && player.canGoNext)
                        player.next();
                    else if ((event.key === Qt.Key_Left || event.key === Qt.Key_H) && player.canGoPrevious)
                        player.previous();
                    else
                        return;
                    event.accepted = true;
                }
            }

            MediaRow {
                id: media

                x: Theme.panelPadding
                y: Theme.panelPadding
                width: parent.width - x * 2
                player: root.player
                active: true
            }
        }
    }
}
