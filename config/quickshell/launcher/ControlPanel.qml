pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import Quickshell.Widgets
import qs

// Control panel: the glass panel of the other menus, standing on the bar a
// little in from the right edge. Notifications (with do not disturb), the
// output and input volume, a volume per app that's playing, Wi-Fi and
// bluetooth. Toggled by ~/.local/bin/control-panel
// (`qs -c launcher ipc call controlPanel toggleControlPanel`), Super+A or the
// bar's button; `control-panel Notifications` (Super+Shift+N) opens it on
// that page.
//
// Up and Down move between rows, Left and Right (or h and l) move the
// selected slider, m mutes a volume, Enter mutes a volume, makes a device
// the default, turns Wi-Fi or bluetooth on or off, or connects to a network
// or device (asking for a new network's password) or runs a notification's
// action, Delete forgets a network or bluetooth device or dismisses a
// notification, s searches for bluetooth devices, c clears the
// notifications, and d turns do not disturb on or off.
//
// The main view has a section per thing, split by lines, with just its
// slider or switch. The lists (notifications, audio devices, networks,
// bluetooth devices) are on a page per section: a click on the section's
// header, Space, or Right on a switch opens the selected row's page in place
// of the main view, and Escape, Backspace, Left or a click on the page's
// title goes back.
Scope {
    id: root

    property bool open: false
    property int current: 0
    // The notification server (Notifications.qml), for the centre
    property var notifications: null
    readonly property var notificationList: notifications ? Array.from(notifications.notifications) : []

    readonly property list<PwNode> sinks: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioSink)
    readonly property list<PwNode> sources: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioSource)
    // Apps playing sound
    readonly property list<PwNode> streams: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioOutStream)

    readonly property NetworkDevice wifiDevice: Networking.devices.values.find(device => device.type === DeviceType.Wifi) ?? null
    // Cables plugged in
    readonly property list<NetworkDevice> wiredDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wired && device.hasLink)
    // The nearest networks; the connected one first, then saved ones
    readonly property list<WifiNetwork> networks: {
        if (!wifiDevice || !Networking.wifiEnabled)
            return [];
        const rank = network => network.connected ? 0 : network.known ? 1 : 2;
        const networks = wifiDevice.networks.values.filter(network => network.name);
        return networks.sort((a, b) => rank(a) - rank(b) || b.signalStrength - a.signalStrength).slice(0, Theme.maxNetworks);
    }
    // The new network a password is being typed for, and why recent
    // attempts failed (name -> ConnectionFailReason)
    property WifiNetwork passwordFor: null
    property var failures: ({})

    // The section whose page is open, or "" for the main view; the main view
    // each time the panel opens
    property string page: ""

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool bluetoothOn: adapter?.enabled ?? false
    // Paired devices, and while searching the named ones nearby; connected
    // ones first
    readonly property list<BluetoothDevice> bluetoothDevices: {
        if (!bluetoothOn)
            return [];
        const searching = adapter.discovering;
        const devices = adapter.devices.values.filter(device => device.paired || (searching && device.deviceName));
        const rank = device => device.connected ? 0 : device.paired ? 1 : 2;
        return devices.sort((a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name));
    }

    // One per row, with the section it's in: a volume
    // ({ kind: "volume", node, app }), an audio device to make the default ({ kind: "device", node }), a cable
    // ({ kind: "wired", device }), the Wi-Fi switch ({ kind: "wifi" }), a
    // network ({ kind: "network", network }) and the password for it
    // ({ kind: "password", network }), the bluetooth switch
    // ({ kind: "bluetooth" }) or a bluetooth device
    // ({ kind: "bluetoothDevice", device }). List rows (`list`) are on the
    // section's page; the rest are on the main view.
    readonly property var rows: {
        const rows = [];
        if (notifications) {
            rows.push({
                section: "Notifications",
                kind: "bell"
            });
            // Grouped by app, the app with the newest first
            const groups = new Map();
            for (const notification of notificationList) {
                const app = notification.appName || "Other";
                groups.set(app, (groups.get(app) ?? []).concat([notification]));
            }
            for (const [app, list] of groups)
                for (const notification of list)
                    rows.push({
                        section: "Notifications",
                        kind: "notification",
                        list: true,
                        group: app,
                        notification: notification
                    });
            if (notificationList.length === 0)
                rows.push({
                    section: "Notifications",
                    kind: "empty",
                    list: true
                });
        }
        const add = (section, devices, fallback) => {
            if (fallback)
                rows.push({
                    section: section,
                    kind: "volume",
                    node: fallback,
                    app: false
                });
            for (const node of devices)
                rows.push({
                    section: section,
                    kind: "device",
                    list: true,
                    node: node
                });
        };
        add("Output", sinks, Pipewire.defaultAudioSink);
        add("Input", sources, Pipewire.defaultAudioSource);
        // One slider per app, however many streams it plays: a browser
        // opens one per tab
        const apps = new Map();
        for (const node of streams) {
            const name = appName(node);
            apps.set(name, (apps.get(name) ?? []).concat([node]));
        }
        for (const nodes of apps.values())
            rows.push({
                section: "Apps",
                kind: "volume",
                node: nodes[0],
                nodes: nodes,
                app: true
            });
        for (const device of wiredDevices)
            rows.push({
                section: "Network",
                kind: "wired",
                list: true,
                device: device
            });
        if (wifiDevice) {
            rows.push({
                section: "Network",
                kind: "wifi"
            });
            for (const network of networks) {
                rows.push({
                    section: "Network",
                    kind: "network",
                    list: true,
                    network: network
                });
                if (network === passwordFor)
                    rows.push({
                        section: "Network",
                        kind: "password",
                        list: true,
                        network: network
                    });
            }
        }
        if (adapter) {
            rows.push({
                section: "Bluetooth",
                kind: "bluetooth"
            });
            for (const device of bluetoothDevices)
                rows.push({
                    section: "Bluetooth",
                    kind: "bluetoothDevice",
                    list: true,
                    device: device
                });
        }
        // Sliders and switches are only on the main view; a page is just the
        // section's list
        return rows.filter(row => page === "" ? !row.list : row.section === page && row.list);
    }

    function isSlider(row) {
        return row.kind === "volume";
    }

    function appName(node) {
        return node.properties["application.name"] ?? node.nickname ?? node.name;
    }

    // "HDMI / DisplayPort 3 Output" -> "HDMI / DisplayPort 3": the section
    // already says it's an output
    function deviceName(node) {
        return (node.nickname || node.description || node.name).replace(/ Output$/, "");
    }

    function isDefault(node) {
        return node === Pipewire.defaultAudioSink || node === Pipewire.defaultAudioSource;
    }

    // A volume row's nodes: an app's streams, or the one device
    function nodesOf(row) {
        return row.nodes ?? [row.node];
    }

    // Unmutes too; an app's streams all move together
    function setVolume(row, volume) {
        for (const node of root.nodesOf(row)) {
            node.audio.muted = false;
            node.audio.volume = volume;
        }
    }

    function toggleMute(row) {
        const muted = !row.node.audio.muted;
        for (const node of root.nodesOf(row))
            node.audio.muted = muted;
    }

    // One step up or down a volume, on the step grid. Never pushes past
    // 100%, but leaves a volume already past it there.
    function step(row, direction) {
        const value = row.node.audio.volume;
        const next = Math.round((value + direction * Theme.volumeStep) * 20) / 20;
        root.setVolume(row, Math.max(0, Math.min(next, Math.max(value, 1))));
    }

    // Blocked by rfkill (like the bar's click, which this mirrors) can't be
    // undone over bluez
    function toggleBluetooth() {
        if (adapter.state === BluetoothAdapterState.Blocked)
            Quickshell.execDetached(["sh", "-c", "rfkill unblock bluetooth && sleep 1 && bluetoothctl power on"]);
        else
            adapter.enabled = !adapter.enabled;
    }

    // Pairs a new device, or connects or disconnects a paired one. A
    // connected device is trusted, so it reconnects by itself later.
    function toggleDevice(device) {
        if (device.pairing) {
            device.cancelPair();
        } else if (!device.paired) {
            device.pair();
        } else if (device.connected) {
            device.disconnect();
        } else {
            device.trusted = true;
            device.connect();
        }
    }

    // Signal bars for a network, with a lock when it needs a password
    function networkIcon(network) {
        const strength = network.signalStrength > 1 ? network.signalStrength / 100 : network.signalStrength;
        const bars = Math.max(0, Math.min(3, Math.floor(strength * 4)));
        return (root.isSecured(network) ? Theme.wifiStrengthLockIcons : Theme.wifiStrengthIcons)[bars];
    }

    function isSecured(network) {
        return network.security !== WifiSecurityType.Open && network.security !== WifiSecurityType.Owe;
    }

    function setFailure(network, reason) {
        const failures = Object.assign({}, root.failures);
        if (reason === undefined)
            delete failures[network.name];
        else
            failures[network.name] = reason;
        root.failures = failures;
    }

    // Disconnects, connects with what's saved, or asks for the password of
    // a new secured network
    function toggleNetwork(network) {
        root.setFailure(network);
        if (network.connected) {
            network.disconnect();
        } else if (network.known || !root.isSecured(network)) {
            network.connect();
        } else {
            root.askPassword(network);
        }
    }

    // Opens the password row under the network and moves to it
    function askPassword(network) {
        passwordFor = network;
        Qt.callLater(() => root.current = root.rows.findIndex(row => row.kind === "password"));
    }

    function submitPassword(password) {
        const network = passwordFor;
        passwordFor = null;
        list.forceActiveFocus();
        if (network && password)
            network.connectWithPsk(password);
    }

    function cancelPassword() {
        passwordFor = null;
        list.forceActiveFocus();
    }

    // Sections with a page: notifications, audio devices, and networks and
    // bluetooth devices while they're on
    function hasPage(section) {
        if (section === "Output" || section === "Input" || section === "Notifications")
            return true;
        if (section === "Network")
            return Networking.wifiEnabled;
        if (section === "Bluetooth")
            return bluetoothOn;
        return false;
    }

    // Slides in from the side it's going to
    function openPage(section) {
        if (!root.hasPage(section))
            return;
        page = section;
        current = 0;
        if (section === "Notifications")
            notifications.markRead();
        pageSlide.direction = 1;
        pageSlide.restart();
    }

    // Back to the main view, on the section's row
    function closePage() {
        const section = page;
        page = "";
        current = Math.max(0, rows.findIndex(row => row.section === section));
        pageSlide.direction = -1;
        pageSlide.restart();
    }

    // What a section is set to, for the main view: the device in use, the
    // connected network, the connected bluetooth devices
    function summary(section) {
        if (section === "Output")
            return Pipewire.defaultAudioSink ? root.deviceName(Pipewire.defaultAudioSink) : "";
        if (section === "Input")
            return Pipewire.defaultAudioSource ? root.deviceName(Pipewire.defaultAudioSource) : "";
        if (section === "Network")
            return wiredDevices.some(device => device.connected) ? "Ethernet" : wifiDevice?.networks.values.find(network => network.connected)?.name ?? "";
        if (section === "Bluetooth")
            return bluetoothDevices.filter(device => device.connected).map(device => device.name).join(", ");
        return "";
    }

    // Looks for new bluetooth devices, which then join the list
    function toggleSearch() {
        if (bluetoothOn)
            adapter.discovering = !adapter.discovering;
    }

    // "3 new", "5 notifications", "No notifications"
    function bellLabel() {
        const unread = Math.min(notifications.unread, notificationList.length);
        if (unread > 0)
            return unread + " new";
        const count = notificationList.length;
        return count === 0 ? "No notifications" : count === 1 ? "1 notification" : count + " notifications";
    }

    function activate(row) {
        if (row.kind === "bell") {
            root.openPage("Notifications");
        } else if (row.kind === "notification") {
            notifications.activate(row.notification);
        } else if (row.kind === "device") {
            if (row.node.type === PwNodeType.AudioSink)
                Pipewire.preferredDefaultAudioSink = row.node;
            else
                Pipewire.preferredDefaultAudioSource = row.node;
        } else if (row.kind === "volume") {
            root.toggleMute(row);
        } else if (row.kind === "bluetooth") {
            root.toggleBluetooth();
        } else if (row.kind === "bluetoothDevice") {
            root.toggleDevice(row.device);
        } else if (row.kind === "wifi") {
            Networking.wifiEnabled = !Networking.wifiEnabled;
        } else if (row.kind === "network") {
            root.toggleNetwork(row.network);
        } else if (row.kind === "wired") {
            if (row.device.connected)
                row.device.disconnect();
            else
                row.device.network?.connect();
        }
    }

    // Searching for bluetooth devices, and scanning for networks, only while
    // the panel is open
    onOpenChanged: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = open;
        if (open) {
            page = "";
        } else {
            passwordFor = null;
            if (adapter?.discovering)
                adapter.discovering = false;
        }
    }

    IpcHandler {
        target: "controlPanel"

        function toggleControlPanel(): void {
            root.open = !root.open;
        }

        // Opens the panel on a section's page ("Output", "Network", ...)
        // Again on the same page closes it
        function openSection(section: string): void {
            if (root.open && root.page === section) {
                root.open = false;
                return;
            }
            root.open = true;
            root.openPage(section);
        }
    }

    // Volumes, and the app names the streams are grouped by, are only
    // there for nodes that are tracked. Not taken from the rows, which are
    // built from those names.
    PwObjectTracker {
        objects: root.open ? [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource].concat(root.streams) : []
    }

    // The widest volume, so the sliders line up
    TextMetrics {
        id: percentWidth
        text: "100%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.controlSmallFontSize
        font.weight: Theme.fontWeight
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: window

        visible: root.open
        color: "transparent"
        exclusionMode: ExclusionMode.Normal
        implicitWidth: Math.round(screen.width * Theme.controlWidth)
        implicitHeight: panel.height

        WlrLayershell.namespace: "launcher-shadow"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        anchors {
            bottom: true
            right: true
        }
        margins.right: Theme.edgeMargin

        onVisibleChanged: {
            if (!visible)
                return;

            root.current = 0;
            list.forceActiveFocus();
            panel.appear();
        }

        Glass {
            id: panel

            standing: true
            width: parent.width
            height: list.height + Theme.panelPadding * 2

            Column {
                id: list

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.panelPadding

                transform: Translate {
                    id: listSlide
                }

                // A page slides in from the right, the main view back from
                // the left
                ParallelAnimation {
                    id: pageSlide

                    property int direction: 1

                    NumberAnimation {
                        target: listSlide
                        property: "x"
                        from: pageSlide.direction * Theme.pageSlide
                        to: 0
                        duration: Theme.animationDuration
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: list
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: Theme.animationDuration
                    }
                }

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    const count = root.rows.length;
                    const row = root.rows[Math.min(root.current, count - 1)];

                    if (event.key === Qt.Key_Escape && root.page !== "") {
                        root.closePage();
                    } else if (event.key === Qt.Key_Escape) {
                        root.open = false;
                    } else if (event.key === Qt.Key_Backspace && root.page !== "") {
                        root.closePage();
                    } else if (count === 0) {
                        return;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.activate(row);
                    } else if (event.key === Qt.Key_Space && root.page === "") {
                        root.openPage(row.section);
                    } else if (event.key === Qt.Key_Delete && row.kind === "notification") {
                        row.notification.dismiss();
                    } else if (event.key === Qt.Key_D && notifications) {
                        notifications.doNotDisturb = !notifications.doNotDisturb;
                    } else if (event.key === Qt.Key_C && root.page === "Notifications") {
                        notifications.clear();
                    } else if (event.key === Qt.Key_S && root.page === "Bluetooth") {
                        root.toggleSearch();
                    } else if (event.key === Qt.Key_M && row.kind === "volume") {
                        root.toggleMute(row);
                    } else if (event.key === Qt.Key_Delete && row.kind === "bluetoothDevice" && row.device.paired) {
                        row.device.forget();
                    } else if (event.key === Qt.Key_Delete && row.kind === "network" && row.network.known) {
                        row.network.forget();
                    } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab || event.key === Qt.Key_J || (ctrl && event.key === Qt.Key_N)) {
                        root.current = (root.current + 1) % count;
                    } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab || event.key === Qt.Key_K || (ctrl && event.key === Qt.Key_P)) {
                        root.current = (root.current + count - 1) % count;
                    } else if (!root.isSlider(row) && root.page === "" && (event.key === Qt.Key_Right || event.key === Qt.Key_L)) {
                        root.openPage(row.section);
                    } else if (!root.isSlider(row) && root.page !== "" && (event.key === Qt.Key_Left || event.key === Qt.Key_H)) {
                        root.closePage();
                    } else if (root.isSlider(row) && (event.key === Qt.Key_Right || event.key === Qt.Key_L)) {
                        root.step(row, 1);
                    } else if (root.isSlider(row) && (event.key === Qt.Key_Left || event.key === Qt.Key_H)) {
                        root.step(row, -1);
                    } else {
                        return;
                    }
                    event.accepted = true;
                }

                Repeater {
                    model: root.rows

                    Column {
                        id: entry

                        required property var modelData
                        required property int index

                        readonly property string kind: modelData.kind
                        readonly property PwNode node: modelData.node ?? null
                        // A bluetooth device, or a wired network device
                        readonly property var device: modelData.device ?? null
                        readonly property WifiNetwork network: modelData.network ?? null
                        readonly property bool slider: root.isSlider(modelData)
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
                        readonly property bool active: root.current === index

                        // Glyph before a main row; lists are plain text
                        readonly property string glyph: {
                            if (kind === "bell")
                                return root.notifications.doNotDisturb ? Theme.doNotDisturbIcon : root.notifications.unread > 0 ? Theme.bellUnreadIcon : Theme.bellIcon;
                            if (kind === "volume" && !app)
                                return node.type === PwNodeType.AudioSink ? Theme.volumeIcon(level, muted) : muted ? Theme.micMutedIcon : Theme.micIcon;
                            if (kind === "bluetooth")
                                return !root.bluetoothOn ? Theme.bluetoothOffIcon : root.bluetoothDevices.some(device => device.connected) ? Theme.bluetoothConnectedIcon : Theme.bluetoothIcon;
                            if (kind === "wifi")
                                return Networking.wifiEnabled ? Theme.wifiIcon : Theme.wifiOffIcon;
                            return "";
                        }
                        readonly property color glyphColor: {
                            if (kind === "bell")
                                return root.notifications.doNotDisturb ? Theme.bluetoothOffColor : root.notifications.unread > 0 ? Theme.accentColor : Theme.bluetoothColor;
                            if (toggle)
                                return on ? Theme.bluetoothColor : Theme.bluetoothOffColor;
                            return Theme.volumeColor(level, muted);
                        }
                        // A switch's row says what it's connected to
                        readonly property bool on: kind === "wifi" ? Networking.wifiEnabled : kind === "bluetooth" ? root.bluetoothOn : false
                        readonly property string label: {
                            if (kind === "bell")
                                return root.bellLabel();
                            if (kind === "empty")
                                return "No notifications";
                            if (app)
                                return root.appName(node);
                            if (kind === "device")
                                return root.deviceName(node);
                            if (kind === "bluetooth") {
                                const state = root.adapter.state;
                                if (state === BluetoothAdapterState.Enabling)
                                    return "Turning on…";
                                if (state === BluetoothAdapterState.Disabling)
                                    return "Turning off…";
                                if (state === BluetoothAdapterState.Blocked)
                                    return "Off (blocked)";
                                return on ? root.summary("Bluetooth") || "No devices" : "Off";
                            }
                            if (kind === "bluetoothDevice")
                                return device.name || device.address;
                            if (kind === "wifi") {
                                if (!Networking.wifiHardwareEnabled)
                                    return "Off (hardware switch)";
                                return on ? root.summary("Network") || "Not connected" : "Off";
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
                                const failure = root.failures[network.name];
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
                                return root.isDefault(node);
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
                                root.setFailure(entry.network, reason);
                                if (reason === ConnectionFailReason.NoSecrets && !entry.network.known)
                                    root.askPassword(entry.network);
                            }
                        }

                        // Rows sit on the glass like the other menus' rows,
                        // under a header per section
                        readonly property bool first: index === 0 || root.rows[index - 1].section !== modelData.section

                        width: list.width
                        spacing: Theme.rowSpacing
                        bottomPadding: Theme.rowSpacing

                        // On the main view, a line across between one
                        // section and the next, with room either side; the
                        // headers themselves have none
                        Item {
                            width: parent.width
                            height: Theme.sectionGap
                            visible: entry.first && entry.index > 0 && root.page === ""

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
                            opensPage: root.page === "" && root.hasPage(entry.modelData.section)
                            // On a page, the header is the title and goes
                            // back
                            back: root.page !== ""
                            titleSize: Theme.controlFontSize
                            // A page's title and its Search cap run to the
                            // ends of the divider under them
                            inset: back ? 0 : Theme.rowPadding
                            // A slider has no label of its own, so the header
                            // says which device it's for
                            summary: !back && (entry.modelData.section === "Output" || entry.modelData.section === "Input") ? root.summary(entry.modelData.section) : ""
                            // The bluetooth page searches from its title,
                            // the notifications page clears
                            action: {
                                if (!back)
                                    return "";
                                if (entry.modelData.section === "Bluetooth" && root.bluetoothOn)
                                    return root.adapter.discovering ? "Searching…" : "Search";
                                if (entry.modelData.section === "Notifications" && root.notificationList.length > 0)
                                    return "Clear";
                                return "";
                            }
                            actionActive: entry.modelData.section === "Bluetooth" && (root.adapter?.discovering ?? false)
                            onClicked: back ? root.closePage() : root.openPage(entry.modelData.section)
                            onActionClicked: entry.modelData.section === "Notifications" ? root.notifications.clear() : root.toggleSearch()
                        }

                        // The app over its notifications, just its name
                        SectionHeader {
                            width: parent.width
                            visible: entry.kind === "notification" && (entry.index === 0 || root.rows[entry.index - 1].group !== entry.modelData.group)
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
                                onPositionChanged: root.current = entry.index
                                onClicked: if (!entry.slider)
                                    root.activate(entry.modelData)
                            }

                            // A notification: its icon, summary and age, the
                            // body under them, then its actions
                            Column {
                                id: notificationView

                                y: Theme.rowSpacing
                                width: parent.width
                                visible: entry.kind === "notification"
                                spacing: Theme.rowSpacing / 2

                                Row {
                                    width: parent.width
                                    spacing: Theme.iconSpacing

                                    IconImage {
                                        property int tried: 0
                                        readonly property list<string> candidates: entry.notification ? root.notifications.icons(entry.notification) : []

                                        anchors.verticalCenter: parent.verticalCenter
                                        implicitSize: Theme.notificationRowIconSize
                                        source: candidates[tried] ?? ""
                                        onStatusChanged: if (status === Image.Error && tried < candidates.length - 1)
                                            tried++
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - Theme.notificationRowIconSize - age.width - dismiss.width - parent.spacing * 3
                                        text: entry.notification?.summary ?? ""
                                        textFormat: Text.PlainText
                                        elide: Text.ElideRight
                                        color: Theme.textColor
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.controlFontSize
                                        font.weight: Theme.fontWeight
                                    }

                                    Text {
                                        id: age
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: entry.notification ? root.notifications.age(entry.notification) : ""
                                        color: Theme.dimColor
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.controlSmallFontSize
                                        font.weight: Theme.fontWeight
                                    }

                                    // Dismisses it, shown under the mouse
                                    Text {
                                        id: dismiss
                                        anchors.verticalCenter: parent.verticalCenter
                                        opacity: entry.active ? 1 : 0
                                        text: Theme.closeIcon
                                        color: dismissMouse.containsMouse ? Theme.textColor : Theme.keyTextColor
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.controlFontSize

                                        MouseArea {
                                            id: dismissMouse
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: entry.notification.dismiss()
                                        }
                                    }
                                }

                                Text {
                                    x: Theme.notificationRowIconSize + Theme.iconSpacing
                                    width: parent.width - x
                                    visible: text !== ""
                                    text: entry.notification?.body ?? ""
                                    textFormat: Text.StyledText
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    color: Theme.keyTextColor
                                    linkColor: Theme.textColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.controlSmallFontSize + 1
                                    font.weight: Theme.fontWeight
                                }

                                Flow {
                                    readonly property list<var> actions: (entry.notification?.actions ?? []).filter(action => action.identifier !== "default")

                                    x: Theme.notificationRowIconSize + Theme.iconSpacing
                                    width: parent.width - x
                                    visible: actions.length > 0
                                    topPadding: Theme.rowSpacing / 2
                                    spacing: Theme.keySpacing

                                    Repeater {
                                        model: parent.actions

                                        KeyCap {
                                            id: actionCap

                                            required property var modelData

                                            text: modelData.text
                                            fontSize: Theme.controlSmallFontSize
                                            lit: actionMouse.containsMouse

                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: actionCap.modelData.invoke()
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                id: content

                                anchors.verticalCenter: parent.verticalCenter
                                visible: entry.kind !== "notification"
                                // Flush with a page's title and divider, like
                                // the title itself
                                x: root.page !== "" ? 0 : Theme.rowPadding
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
                                            onClicked: root.toggleMute(entry.modelData)
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
                                            root.submitPassword(text);
                                        else if (event.key === Qt.Key_Escape)
                                            root.cancelPassword();
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
                                        root.current = entry.index;
                                        root.setVolume(entry.modelData, value);
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
                                    text: visible ? root.networkIcon(entry.network) : ""
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
                                        lit: root.notifications?.doNotDisturb ?? false
                                        textColor: doNotDisturbMouse.containsMouse ? Theme.textColor : Theme.keyTextColor
                                        litTextColor: Theme.accentColor

                                        MouseArea {
                                            id: doNotDisturbMouse
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.notifications.doNotDisturb = !root.notifications.doNotDisturb
                                        }
                                    }
                                }
                            }
                        }

                    }
                }

                Text {
                    visible: root.rows.length === 0
                    x: Theme.rowPadding
                    height: Theme.rowHeight
                    verticalAlignment: Text.AlignVCenter
                    text: Theme.controlEmptyText
                    color: Theme.dimColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlFontSize
                }
            }
        }
    }
}
