pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import Quickshell.Wayland
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
    // Apps playing sound. Not the short sounds of the volume keys and
    // notifications (paplay and the like), which would make the Apps
    // section come and go
    readonly property list<PwNode> streams: Pipewire.nodes.values.filter(node => node.type === PwNodeType.AudioOutStream && !root.isSoundEffect(node))

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

    function isSoundEffect(node) {
        const players = ["paplay", "pw-play", "pw-cat", "aplay", "canberra-gtk-play"];
        const props = node.properties ?? {};
        return players.includes(node.name) || players.includes(props["application.name"]) || ["event", "notification"].includes((props["media.role"] ?? "").toLowerCase());
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

        // Opens it on the main view, whatever it showed before
        function showControlPanel(): void {
            if (root.page !== "")
                root.closePage();
            root.open = true;
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

                    ControlRow {
                        panel: root
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
