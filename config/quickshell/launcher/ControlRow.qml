pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import qs

// One row of the control panel (ControlPanel.qml), its section's header over
// the first: a slider (a volume), a switch (Wi-Fi, bluetooth), the
// notifications' bell, a device, network or notification on a page, or a
// password being typed. What kind it is, and what it shows, comes from the
// row (`modelData`, one of the panel's `rows`); clicks and keys go to the
// panel.
Column {
    id: entry

    // The panel (ControlPanel.qml): its rows, state and actions
    required property var panel
    required property var modelData
    required property int index

    readonly property string kind: modelData.kind
    readonly property PwNode node: modelData.node ?? null
    // A bluetooth device, or a wired network device
    readonly property var device: modelData.device ?? null
    readonly property WifiNetwork network: modelData.network ?? null
    readonly property bool slider: panel.isSlider(modelData)
    // Wi-Fi and bluetooth on or off
    readonly property bool toggle: kind === "bluetooth" || kind === "wifi"
    // Sliders, switches and the password are full size;
    // lists are a little smaller
    readonly property bool main: !modelData.list || kind === "password"
    readonly property bool app: modelData.app ?? false
    readonly property bool muted: node?.audio?.muted ?? false
    readonly property real level: node?.audio?.volume ?? 0
    // Under the mouse or picked with the keys: there's
    // no highlight, the row's text, knob or switch
    // brightens instead
    readonly property bool active: panel.current === index

    // Glyph before a main row; lists are plain text
    readonly property string glyph: {
        if (kind === "bell")
            return panel.notifications.doNotDisturb ? Theme.doNotDisturbIcon : panel.notifications.unread > 0 ? Theme.bellUnreadIcon : Theme.bellIcon;
        if (kind === "volume" && !app)
            return node.type === PwNodeType.AudioSink ? Theme.volumeIcon(level, muted) : muted ? Theme.micMutedIcon : Theme.micIcon;
        if (kind === "bluetooth")
            return !panel.bluetoothOn ? Theme.bluetoothOffIcon : panel.bluetoothDevices.some(device => device.connected) ? Theme.bluetoothConnectedIcon : Theme.bluetoothIcon;
        if (kind === "wifi")
            return Networking.wifiEnabled ? Theme.wifiIcon : Theme.wifiOffIcon;
        return "";
    }
    readonly property color glyphColor: {
        if (kind === "bell")
            return panel.notifications.doNotDisturb ? Theme.bluetoothOffColor : panel.notifications.unread > 0 ? Theme.accentColor : Theme.bluetoothColor;
        if (toggle)
            return on ? Theme.bluetoothColor : Theme.bluetoothOffColor;
        return Theme.volumeColor(level, muted);
    }
    // A switch's row says what it's connected to
    readonly property bool on: kind === "wifi" ? Networking.wifiEnabled : kind === "bluetooth" ? panel.bluetoothOn : false
    readonly property string label: {
        if (kind === "bell")
            return panel.bellLabel();
        if (kind === "empty")
            return "No notifications";
        if (app)
            return panel.appName(node);
        if (kind === "device")
            return panel.deviceName(node);
        if (kind === "bluetooth") {
            const state = panel.adapter.state;
            if (state === BluetoothAdapterState.Enabling)
                return "Turning on…";
            if (state === BluetoothAdapterState.Disabling)
                return "Turning off…";
            if (state === BluetoothAdapterState.Blocked)
                return "Off (blocked)";
            return on ? panel.summary("Bluetooth") || "No devices" : "Off";
        }
        if (kind === "bluetoothDevice")
            return device.name || device.address;
        if (kind === "wifi") {
            if (!Networking.wifiHardwareEnabled)
                return "Off (hardware switch)";
            return on ? panel.summary("Network") || "Not connected" : "Off";
        }
        if (kind === "network")
            return network.name;
        if (kind === "wired")
            return "Ethernet";
        return "";
    }
    // Dimmed text after the label
    readonly property string detail: {
        if (kind === "network") {
            if (network.state === ConnectionState.Connecting)
                return "connecting…";
            if (network.state === ConnectionState.Disconnecting)
                return "disconnecting…";
            const failure = panel.failures[network.name];
            if (failure !== undefined)
                return failure === ConnectionFailReason.NoSecrets || failure === ConnectionFailReason.WifiAuthTimeout ? "wrong password" : "failed";
            return network.known && !network.connected ? "saved" : "";
        }
        if (kind === "wired")
            return device.linkSpeed ? device.linkSpeed + " Mb/s" : "";
        if (kind !== "bluetoothDevice")
            return "";
        if (device.pairing)
            return "pairing…";
        if (device.state === BluetoothDeviceState.Connecting)
            return "connecting…";
        if (device.state === BluetoothDeviceState.Disconnecting)
            return "disconnecting…";
        if (!device.paired)
            return "new";
        return device.connected && device.batteryAvailable ? Math.round(device.battery * 100) + "%" : "";
    }
    // The device in use, a connected network or
    // bluetooth device; a switch that's on
    readonly property bool checked: {
        if (kind === "device")
            return panel.isDefault(node);
        if (kind === "bluetoothDevice" || kind === "wired")
            return device.connected;
        if (kind === "network")
            return network.connected;
        return false;
    }
    readonly property bool bright: kind !== "empty" && (checked || active || (main && kind !== "bluetooth" && kind !== "wifi") || on)
    readonly property var notification: modelData.notification ?? null

    // A failed connection shows on the row; a missing
    // password asks for one
    Connections {
        target: entry.network
        enabled: entry.kind === "network"

        function onConnectionFailed(reason) {
            panel.setFailure(entry.network, reason);
            if (reason === ConnectionFailReason.NoSecrets && !entry.network.known)
                panel.askPassword(entry.network);
        }
    }

    // Rows sit on the glass like the other menus' rows,
    // under a header per section
    readonly property bool first: index === 0 || panel.rows[index - 1].section !== modelData.section

    width: parent ? parent.width : 0
    spacing: Theme.rowSpacing
    bottomPadding: Theme.rowSpacing

    // On the main view, a line across between one
    // section and the next, with room either side; the
    // headers themselves have none
    Item {
        width: parent.width
        height: Theme.sectionGap
        visible: entry.first && entry.index > 0 && panel.page === ""

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 1
            color: Theme.dividerColor
        }
    }

    SectionHeader {
        width: parent.width
        visible: entry.first
        text: entry.modelData.section
        // Just the name, like the notifications' app
        // headers
        line: false
        opensPage: panel.page === "" && panel.hasPage(entry.modelData.section)
        // On a page, the header is the title and goes
        // back
        back: panel.page !== ""
        titleSize: Theme.controlFontSize
        // A page's title and its Search cap run to the
        // ends of the divider under them
        inset: back ? 0 : Theme.rowPadding
        // A slider has no label of its own, so the header
        // says which device it's for
        summary: !back && (entry.modelData.section === "Output" || entry.modelData.section === "Input") ? panel.summary(entry.modelData.section) : ""
        // The bluetooth page searches from its title,
        // the notifications page clears
        action: {
            if (!back)
                return "";
            if (entry.modelData.section === "Bluetooth" && panel.bluetoothOn)
                return panel.adapter.discovering ? "Searching…" : "Search";
            if (entry.modelData.section === "Notifications" && panel.notificationList.length > 0)
                return "Clear";
            return "";
        }
        actionActive: entry.modelData.section === "Bluetooth" && (panel.adapter?.discovering ?? false)
        onClicked: back ? panel.closePage() : panel.openPage(entry.modelData.section)
        onActionClicked: entry.modelData.section === "Notifications" ? panel.notifications.clear() : panel.toggleSearch()
    }

    // The app over its notifications, just its name
    SectionHeader {
        width: parent.width
        visible: entry.kind === "notification" && (entry.index === 0 || panel.rows[entry.index - 1].group !== entry.modelData.group)
        text: entry.modelData.group ?? ""
        inset: 0
        line: false
    }

    Item {
        width: parent.width
        height: entry.kind === "notification" ? notificationView.implicitHeight + Theme.rowSpacing * 2 : Theme.rowHeight

        MouseArea {
            id: rowMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: entry.slider || entry.kind === "empty" ? Qt.ArrowCursor : Qt.PointingHandCursor
            onPositionChanged: panel.current = entry.index
            onClicked: if (!entry.slider)
                panel.activate(entry.modelData)
        }

        // A notification: its icon, summary and age, the
        // body under them, then its actions
        NotificationRow {
            id: notificationView

            y: Theme.rowSpacing
            width: parent.width
            visible: entry.kind === "notification"
            notification: entry.notification
            server: entry.panel.notifications
            active: entry.active
        }

        Row {
            id: content

            anchors.verticalCenter: parent.verticalCenter
            visible: entry.kind !== "notification"
            // Flush with a page's title and divider, like
            // the title itself
            x: panel.page !== "" ? 0 : Theme.rowPadding
            width: parent.width - x * 2
            spacing: Theme.iconSpacing

            // The glyph, on main rows only. The volume
            // glyph mutes on a click.
            Item {
                id: icon

                anchors.verticalCenter: parent.verticalCenter
                visible: entry.glyph !== ""
                width: Theme.iconSize
                height: Theme.iconSize

                Text {
                    anchors.centerIn: parent
                    text: entry.glyph
                    color: entry.glyphColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlFontSize

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        enabled: entry.kind === "volume"
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.toggleMute(entry.modelData)
                    }
                }
            }

            // A volume's slider only has a label for an app
            Text {
                id: label

                anchors.verticalCenter: parent.verticalCenter
                visible: (!entry.slider || entry.app) && entry.kind !== "password"
                width: entry.slider ? parent.width * 0.3 : parent.width - (end.visible ? end.width + parent.spacing : 0) - (icon.visible ? icon.width + parent.spacing : 0) - (detail.visible ? detail.width + parent.spacing : 0) - (signal.visible ? signal.width + parent.spacing : 0)
                text: entry.label
                textFormat: Text.PlainText
                elide: Text.ElideRight
                // The device in use or what's connected is
                // green all the way across, like its check
                color: entry.checked ? Theme.accentColor : entry.bright ? Theme.textColor : Theme.keyTextColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.controlFontSize
                font.weight: Theme.fontWeight

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.animationDuration
                    }
                }
            }

            // A new network's password, underlined like a
            // field: Enter connects, Escape gives up
            TextInput {
                id: password

                anchors.verticalCenter: parent.verticalCenter
                visible: entry.kind === "password"
                width: parent.width
                echoMode: TextInput.Password
                color: Theme.textColor
                selectionColor: Theme.dividerColor
                selectedTextColor: Theme.textColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.controlFontSize
                font.weight: Theme.fontWeight
                clip: true

                Component.onCompleted: if (visible)
                    forceActiveFocus()

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                        panel.submitPassword(text);
                    else if (event.key === Qt.Key_Escape)
                        panel.cancelPassword();
                    else
                        return;
                    event.accepted = true;
                }

                Text {
                    visible: password.text.length === 0
                    text: Theme.passwordPlaceholder
                    color: Theme.dimColor
                    font: password.font
                }

                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: 3
                    width: parent.width
                    height: 1
                    color: password.activeFocus ? Theme.keyTextColor : Theme.dividerColor
                }
            }

            Slider {
                anchors.verticalCenter: parent.verticalCenter
                visible: entry.slider
                width: parent.width - percent.width - parent.spacing - (icon.visible ? icon.width + parent.spacing : 0) - (label.visible ? label.width + parent.spacing : 0)
                active: entry.active
                value: entry.level
                color: Theme.volumeColor(entry.level, entry.muted)
                onMoved: value => {
                    panel.current = entry.index;
                    panel.setVolume(entry.modelData, value);
                }
            }

            // A key cap, like the key bindings menu's;
            // as wide as "100%" so it doesn't jump
            KeyCap {
                id: percent

                anchors.verticalCenter: parent.verticalCenter
                visible: entry.slider
                minWidth: Math.ceil(percentWidth.advanceWidth) + Theme.keyPadding * 2
                text: entry.muted ? "mute" : Math.round(entry.level * 100) + "%"
                fontSize: Theme.controlSmallFontSize
                lit: entry.active
            }

            Text {
                id: detail

                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
                text: entry.detail
                color: entry.checked ? Theme.accentColor : Theme.dimColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.controlSmallFontSize
                font.weight: Theme.fontWeight
            }

            // A network's signal bars, dimmed, with a lock
            // when it needs a password
            Text {
                id: signal

                anchors.verticalCenter: parent.verticalCenter
                visible: entry.kind === "network"
                text: visible ? panel.networkIcon(entry.network) : ""
                color: entry.checked ? Theme.accentColor : Theme.dimColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.controlFontSize
            }

            // A check on what's in use or connected, or
            // the switch, or the do not disturb button
            Item {
                id: end

                anchors.verticalCenter: parent.verticalCenter
                visible: !entry.slider && entry.kind !== "password" && entry.kind !== "empty"
                width: entry.toggle ? Theme.toggleWidth : entry.kind === "bell" ? doNotDisturb.width : Theme.iconSize
                height: Theme.iconSize

                Text {
                    anchors.centerIn: parent
                    visible: !entry.toggle && entry.kind !== "bell"
                    text: entry.checked ? Theme.checkIcon : ""
                    color: Theme.accentColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.sectionFontSize
                }

                Toggle {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.toggle
                    checked: entry.on
                }

                // A key cap with the bell struck through,
                // lit and orange while do not disturb is on
                KeyCap {
                    id: doNotDisturb

                    anchors.verticalCenter: parent.verticalCenter
                    visible: entry.kind === "bell"
                    minWidth: height
                    text: Theme.doNotDisturbIcon
                    fontSize: Theme.controlFontSize
                    lit: panel.notifications?.doNotDisturb ?? false
                    textColor: doNotDisturbMouse.containsMouse ? Theme.textColor : Theme.keyTextColor
                    litTextColor: Theme.accentColor

                    MouseArea {
                        id: doNotDisturbMouse
                        anchors.fill: parent
                        anchors.margins: -4
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panel.notifications.doNotDisturb = !panel.notifications.doNotDisturb
                    }
                }
            }
        }
    }

    // The widest volume, so the sliders line up
    TextMetrics {
        id: percentWidth
        text: "100%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.controlSmallFontSize
        font.weight: Theme.fontWeight
    }
}
