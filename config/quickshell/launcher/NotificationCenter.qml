pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Wayland
import qs

// Notification centre: the notifications kept by the server
// (Notifications.qml), grouped by app, the app with the newest first. The
// glass panel of the other menus, floating just above the bar by the right
// edge, like the control panel. Toggled by
// ~/.local/bin/notification-center
// (`qs -c launcher ipc call notificationCenter toggleNotificationCenter`),
// Super+Shift+N or the bar's bell.
//
// The title has a do not disturb key cap and Clear; while do not disturb is
// on, a row under it says how long for: an hour, until morning, or until
// it's turned off. Up and Down (or j and k) move between notifications,
// Enter runs one's default action, Delete dismisses it, c clears them all,
// d turns do not disturb on or off (h for an hour, m until morning), and
// Escape closes it. Scrolls when there are more than fit.
//
// Opened from the bar's bell (`notification-center --pointer`), it's
// centred over the bell, kept on the screen; from the keyboard, it's at the
// right edge (like ControlPanel.qml).
Scope {
    id: root

    property bool open: false
    property int current: 0

    // Centred on the pointer, opened from the bar; where it is (shell.qml),
    // -1 until known. Shown once it's placed, or after a moment at the
    // right edge if the pointer can't be found.
    property bool atPointer: false
    property real pointerX: -1
    property var pointerScreen: null
    property bool placeWaited: false
    readonly property bool placed: !atPointer || pointerX >= 0 || placeWaited
    // The notification server (Notifications.qml)
    property var server: null
    readonly property var notifications: server ? Array.from(server.notifications) : []

    // { notification, group }, grouped by app, the app with the newest first
    readonly property var rows: {
        const groups = new Map();
        for (const notification of notifications) {
            const app = notification.appName || "Other";
            groups.set(app, (groups.get(app) ?? []).concat([notification]));
        }
        const rows = [];
        for (const [app, list] of groups)
            for (const notification of list)
                rows.push({
                    group: app,
                    notification: notification
                });
        return rows;
    }

    // "3 new", "5 notifications"; nothing when there are none, the list
    // says so
    function countLabel() {
        const unread = Math.min(server?.unread ?? 0, notifications.length);
        if (unread > 0)
            return unread + " new";
        const count = notifications.length;
        return count === 0 ? "" : count === 1 ? "1 notification" : count + " notifications";
    }

    function toggleDoNotDisturb() {
        server.doNotDisturb = !server.doNotDisturb;
    }

    // The selected row stays on screen
    function reveal() {
        const item = repeater.itemAt(current);
        if (!item)
            return;
        if (item.y < flick.contentY)
            flick.contentY = item.y;
        else if (item.y + item.height > flick.contentY + flick.height)
            flick.contentY = item.y + item.height - flick.height;
    }

    onCurrentChanged: Qt.callLater(root.reveal)
    // Dismissing the last row moves up to the new last
    onRowsChanged: current = Math.max(0, Math.min(current, rows.length - 1))

    // Opening it reads them all
    onOpenChanged: {
        if (open && server)
            server.markRead();
        if (!open) {
            atPointer = false;
            placeWaited = false;
        }
    }

    // The pointer wasn't found: the right edge, rather than nothing
    Timer {
        running: root.open && !root.placed
        interval: 250
        onTriggered: root.placeWaited = true
    }

    IpcHandler {
        target: "notificationCenter"

        function toggleNotificationCenter(): void {
            root.open = !root.open;
        }

        // The same, over the bar's bell under the pointer
        function toggleNotificationCenterAtPointer(): void {
            if (!root.open)
                root.atPointer = true;
            root.open = !root.open;
        }

        function openNotificationCenter(): void {
            root.open = true;
        }

        function closeNotificationCenter(): void {
            root.open = false;
        }
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: window

        visible: root.open && root.placed
        screen: (root.atPointer && root.pointerX >= 0 ? root.pointerScreen : null) ?? Quickshell.screens.find(screen => screen.name === I3.focusedMonitor?.name) ?? null
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        implicitWidth: Theme.notificationCenterWidth
        implicitHeight: panel.height

        WlrLayershell.namespace: "launcher-shadow"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            bottom: true
            right: true
        }
        margins.bottom: Theme.floatingGap
        // Centred on the pointer, kept on the screen
        margins.right: {
            if (!root.atPointer || root.pointerX < 0 || !screen)
                return Theme.floatingGap;
            const right = screen.width - root.pointerX - implicitWidth / 2;
            return Math.round(Math.max(Theme.floatingGap, Math.min(right, screen.width - implicitWidth - Theme.floatingGap)));
        }

        onVisibleChanged: {
            if (!visible)
                return;

            root.current = 0;
            flick.contentY = 0;
            content.forceActiveFocus();
            panel.appear();
        }

        Glass {
            id: panel

            floating: true
            width: parent.width
            height: content.height + Theme.panelPadding * 2

            Column {
                id: content

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.panelPadding

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    const count = root.rows.length;
                    const row = root.rows[Math.min(root.current, count - 1)];

                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                        root.open = false;
                    } else if (event.key === Qt.Key_D && root.server) {
                        root.toggleDoNotDisturb();
                    } else if (event.key === Qt.Key_H && root.server) {
                        root.server.setDoNotDisturb("hour");
                    } else if (event.key === Qt.Key_M && root.server) {
                        root.server.setDoNotDisturb("morning");
                    } else if (count === 0) {
                        return;
                    } else if (event.key === Qt.Key_C) {
                        root.server.clear();
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.server.activate(row.notification);
                    } else if (event.key === Qt.Key_Delete || event.key === Qt.Key_X) {
                        row.notification.dismiss();
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_J || (ctrl && event.key === Qt.Key_N)) {
                        root.current = (root.current + 1) % count;
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || event.key === Qt.Key_K || (ctrl && event.key === Qt.Key_P)) {
                        root.current = (root.current + count - 1) % count;
                    } else {
                        return;
                    }
                    event.accepted = true;
                }

                // The title, how many there are, and the do not disturb and
                // Clear key caps, over a divider like the search row's
                Item {
                    width: parent.width
                    height: Theme.controlFontSize * 2 + Theme.searchPadding

                    Text {
                        id: title
                        y: (parent.height - Theme.searchPadding - height) / 2
                        text: "Notifications"
                        color: Theme.textColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.controlFontSize
                        font.weight: Theme.fontWeight
                    }

                    Text {
                        anchors.left: title.right
                        anchors.leftMargin: Theme.iconSpacing
                        anchors.baseline: title.baseline
                        text: root.countLabel()
                        color: (root.server?.unread ?? 0) > 0 ? Theme.accentColor : Theme.dimColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.controlSmallFontSize
                        font.weight: Theme.fontWeight
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: title.verticalCenter
                        spacing: Theme.keySpacing

                        // The bell struck through, lit and blue while do not
                        // disturb is on, like a switch
                        KeyCap {
                            minWidth: height
                            text: Theme.doNotDisturbIcon
                            fontSize: Theme.controlFontSize
                            lit: root.server?.doNotDisturb ?? false
                            textColor: doNotDisturbMouse.containsMouse ? Theme.textColor : Theme.keyTextColor
                            litTextColor: Theme.selectedColor

                            MouseArea {
                                id: doNotDisturbMouse
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.toggleDoNotDisturb()
                            }
                        }

                        KeyCap {
                            visible: root.rows.length > 0
                            text: "Clear"
                            fontSize: Theme.keyFontSize
                            lit: clearMouse.containsMouse

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                anchors.margins: -4
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.server.clear()
                            }
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Theme.searchPadding / 2
                        width: parent.width
                        height: 1
                        color: Theme.dividerColor
                    }
                }

                // How long do not disturb lasts, while it's on: the choice
                // lit blue like the bell's cap, and when it ends
                Item {
                    visible: root.server?.doNotDisturb ?? false
                    width: parent.width
                    height: Theme.rowHeight

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (root.server?.doNotDisturbEnd() ?? "") ? "Ends " + root.server.doNotDisturbEnd() : "Do not disturb"
                        color: Theme.dimColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.controlSmallFontSize
                        font.weight: Theme.fontWeight
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.keySpacing

                        Repeater {
                            model: [
                                {
                                    duration: "hour",
                                    text: "1 hour"
                                },
                                {
                                    duration: "morning",
                                    text: "Until morning"
                                },
                                {
                                    duration: "",
                                    text: "Until off"
                                }
                            ]

                            KeyCap {
                                id: durationCap

                                required property var modelData

                                text: modelData.text
                                fontSize: Theme.controlSmallFontSize
                                lit: (root.server?.doNotDisturbFor ?? "") === modelData.duration || durationMouse.containsMouse
                                litTextColor: (root.server?.doNotDisturbFor ?? "") === modelData.duration ? Theme.selectedColor : Theme.textColor

                                MouseArea {
                                    id: durationMouse
                                    anchors.fill: parent
                                    anchors.margins: -2
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.server.setDoNotDisturb(durationCap.modelData.duration)
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: root.rows.length === 0
                    height: Theme.rowHeight
                    verticalAlignment: Text.AlignVCenter
                    text: (root.server?.doNotDisturb ?? false) ? Theme.doNotDisturbText : Theme.noNotificationsText
                    color: Theme.dimColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlFontSize
                    font.weight: Theme.fontWeight
                }

                // Up to notificationCenterMaxHeight of the screen, then
                // scrolls
                Flickable {
                    id: flick

                    visible: root.rows.length > 0
                    width: parent.width
                    height: Math.min(list.height, window.screen.height * Theme.notificationCenterMaxHeight)
                    contentHeight: list.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: list

                        width: flick.width

                        Repeater {
                            id: repeater

                            model: root.rows

                            Column {
                                id: entry

                                required property var modelData
                                required property int index
                                readonly property bool active: root.current === index

                                width: list.width

                                // The app over its notifications, just its
                                // name
                                SectionHeader {
                                    width: parent.width
                                    visible: entry.index === 0 || root.rows[entry.index - 1].group !== entry.modelData.group
                                    text: entry.modelData.group
                                    inset: 0
                                    line: false
                                }

                                Item {
                                    width: parent.width
                                    height: row.implicitHeight + Theme.rowSpacing * 2

                                    // The selected one, faintly, so the keys
                                    // show where they are
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Theme.cornerRadius
                                        color: Theme.hoverColor
                                        visible: entry.active
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onPositionChanged: root.current = entry.index
                                        onClicked: root.server.activate(entry.modelData.notification)
                                    }

                                    NotificationRow {
                                        id: row

                                        x: Theme.rowSpacing
                                        y: Theme.rowSpacing
                                        width: parent.width - x * 2
                                        notification: entry.modelData.notification
                                        server: root.server
                                        active: entry.active
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
