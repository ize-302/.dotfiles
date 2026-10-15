pragma Singleton

import QtQuick
import Quickshell

// Same glass as the status bar (config/waybar/style.css): translucent
// #15161e with a sheen fading down and a lit edge. sway's
// `layer_effects "launcher"` blurs what's behind.
Singleton {
    // Proportional (Adwaita Sans is Inter); fontconfig fills in the Nerd Font
    // glyphs
    readonly property string fontFamily: "Adwaita Sans"
    readonly property int fontSize: 15
    readonly property int fontWeight: 500

    // Fraction of the screen width
    readonly property real panelWidth: 0.22
    readonly property int panelPadding: 14
    readonly property color panelColor: Qt.rgba(21 / 255, 22 / 255, 30 / 255, 0.96)
    // The menus' panels, more see-through than the bar
    readonly property color glassPanelColor: Qt.rgba(21 / 255, 22 / 255, 30 / 255, 0.9)
    readonly property color sheenTop: Qt.rgba(1, 1, 1, 0.05)
    readonly property color sheenMiddle: Qt.rgba(1, 1, 1, 0.01)
    readonly property color edgeColor: Qt.rgba(1, 1, 1, 0.16)
    // Top right corner of the menus, and the smaller things inside them
    readonly property int panelRadius: 4
    readonly property int cornerRadius: 4
    // Hairline space between a floating panel (the control panel,
    // notification cards, the clipboard menu, ...) and the bar, and the
    // screen's right edge
    readonly property int floatingGap: 3

    // Search row
    readonly property int searchFontSize: 14
    readonly property string searchIcon: ""
    readonly property string placeholder: "Search…"
    readonly property color textColor: "#c0caf5"
    readonly property color dimColor: "#565f89"
    readonly property color dividerColor: "#414868"
    readonly property int searchPadding: 10

    // Results
    readonly property int maxRows: 12
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 4
    readonly property int rowPadding: 8
    readonly property int iconSize: 22
    readonly property int iconSpacing: 10
    // macOS's system blue (dark mode), like a macOS menu's highlighted item
    readonly property color selectedColor: "#0a84ff"
    // A lit key cap or button: a tint, like the bar's focused workspace button
    readonly property color hoverColor: Qt.rgba(192 / 255, 202 / 255, 245 / 255, 0.12)

    // Key caps, tinted like the bar's workspace buttons
    readonly property color keyColor: Qt.rgba(192 / 255, 202 / 255, 245 / 255, 0.05)
    readonly property color keyTextColor: "#a9b1d6"
    readonly property int keyFontSize: 13
    readonly property int keyHeight: 22
    readonly property int keyPadding: 7
    readonly property int keySpacing: 4

    // Group headers
    readonly property int sectionFontSize: 12
    readonly property int sectionHeight: 30

    // Shown instead of the list when nothing matches
    readonly property string emptyText: "No apps found"

    // Clipboard menu: wider, entries are whole lines of text
    readonly property real clipboardWidth: 0.35
    readonly property string clipboardEmptyText: "Nothing found"

    // Key bindings menu: a "Shortcuts" sheet in the middle of the screen, the
    // groups in two columns with a line between, each row's keys lined up in
    // outlined caps after the descriptions
    readonly property string keybindTitle: "Shortcuts"
    readonly property int keybindRadius: 8
    readonly property int keybindPadding: 28
    readonly property int keybindFontSize: 14
    readonly property int keybindRowHeight: 28
    // Between a group's last row and the next group's name
    readonly property int keybindGroupGap: 18
    // Between the descriptions and the keys, and on each side of the line
    // between the columns
    readonly property int keybindLabelGap: 24
    readonly property int keybindColumnGap: 32
    // Descriptions longer than this many characters are cut short
    readonly property int keybindMaxLabel: 36
    // Taller than this fraction of the screen and the columns scroll
    readonly property real keybindMaxHeight: 0.65
    readonly property int keybindScrollbarWidth: 6
    // The search field in the title bar's top right corner
    readonly property int keybindSearchWidth: 200
    readonly property string keybindEmptyText: "No bindings found"

    // Scratchpad menu: a full width strip of window previews on the bar
    readonly property string scratchpadEmptyText: "No windows in the scratchpad"
    // Card width as a fraction of the screen width
    readonly property real cardWidth: 0.15
    // Two lone Super taps within this many ms open the strip
    readonly property int doubleTapInterval: 400
    // Close button on a hovered card, red like the bar's urgent workspace
    readonly property int closeButtonSize: 24
    readonly property color closeColor: "#f7768e"
    // Fade over an edge of the strip with more cards past it
    readonly property int stripFadeWidth: 64
    // Card height as a fraction of the screen height; the card inside leaves
    // cardSpacing around it
    readonly property real cardHeight: 0.2
    readonly property int cardSpacing: 6
    readonly property int cardTitleHeight: 34

    // Control panel: on the bar near the right edge, by the bar's volume
    readonly property real controlWidth: 0.18
    // Extra room above each of the control panel's sections
    readonly property int sectionGap: 12
    // Rows, padding and headers are the other menus', the text smaller: the
    // names and glyphs, then the percentages, caps and details after them
    readonly property int controlFontSize: 14
    readonly property int controlSmallFontSize: 12
    readonly property string controlEmptyText: "Nothing to control"
    // Arrow keys and the mouse wheel move a slider this far
    readonly property real volumeStep: 0.05
    readonly property int sliderHeight: 6
    // Like the switch: the track of a switch that's off, a white knob, and
    // the fill from sliderColor()
    readonly property color sliderTrackColor: keyColor
    readonly property color sliderKnobColor: "white"
    readonly property int knobSize: 12
    readonly property int knobActiveSize: 16
    // The bar's volume glyphs (config/waybar/config.jsonc)
    readonly property string volumeMutedIcon: "\uf026"
    readonly property string volumeLowIcon: "\uf027"
    readonly property string volumeHighIcon: "\uf028"
    readonly property string micIcon: "\uf130"
    readonly property string micMutedIcon: "\uf131"
    // The bar's bluetooth glyphs and colours: on, a device connected, off
    readonly property string bluetoothIcon: String.fromCodePoint(0xf00af)
    readonly property string bluetoothConnectedIcon: String.fromCodePoint(0xf00b1)
    readonly property string bluetoothOffIcon: String.fromCodePoint(0xf00b2)
    // The control panel's glyphs (volume, mic, Wi-Fi, bluetooth), and
    // when off or muted
    readonly property color controlIconColor: keyTextColor
    readonly property color controlIconOffColor: dimColor
    // Wi-Fi: signal bars (an outline, then one to three filled), like the
    // bar's network module (config/waybar/config.jsonc); struck through
    // when off. A lock beside them for networks that need a password.
    readonly property list<string> wifiStrengthIcons: [0xf08bf, 0xf08bc, 0xf08bd, 0xf08be].map(code => String.fromCodePoint(code))
    readonly property string wifiOffIcon: String.fromCodePoint(0xf0783)
    readonly property string lockIcon: String.fromCodePoint(0xf033e)
    // Networks listed at most; the rest are further away
    readonly property int maxNetworks: 6
    readonly property string passwordPlaceholder: "Password"
    // Network details and joining hidden networks, with nmcli
    readonly property string networkInfo: Quickshell.env("HOME") + "/.local/bin/network-info"
    // A bluetooth device's audio profiles, with pactl
    readonly property string bluetoothAudio: Quickshell.env("HOME") + "/.local/bin/bluetooth-audio"
    // On/off switch
    readonly property int toggleWidth: 30
    readonly property int toggleHeight: 18
    // A blue pill when on, like a macOS switch
    readonly property color toggleOnColor: selectedColor
    // Opens a section's page, and goes back from it
    readonly property string pageIcon: String.fromCodePoint(0xf0142)
    readonly property string backIcon: String.fromCodePoint(0xf0141)
    // How far a page slides in
    readonly property int pageSlide: 24
    // Orange like the focused window's border (client.focused in
    // config/sway/config): what's in use or connected
    readonly property color accentColor: "#ff7518"
    // Marks what's in use or connected
    readonly property string checkIcon: "\uf00c"

    // Bluetooth pairing prompt (BluetoothAgent.qml): the code's digits as
    // key caps, and the buttons
    readonly property int pairingWidth: 400
    readonly property int pairingCodeSize: 20
    readonly property int pairingButtonWidth: 80
    readonly property int pairingButtonHeight: 30

    // The sound popup's Now playing (ControlPanel.qml, MediaRow.qml)
    readonly property int mediaArtSize: 48
    readonly property int mediaButtonSize: 26
    readonly property int mediaPlaySize: 30
    readonly property string musicIcon: String.fromCodePoint(0xf075a)
    readonly property string previousIcon: String.fromCodePoint(0xf04ae)
    readonly property string nextIcon: String.fromCodePoint(0xf04ad)
    readonly property string playIcon: String.fromCodePoint(0xf040a)
    readonly property string pauseIcon: String.fromCodePoint(0xf03e4)

    // Caps lock popup (CapsLock.qml): a square in the middle of the screen,
    // with macOS's ⇪, for a moment after each switch. How often the
    // keyboards' lights are read, in ms.
    readonly property int capsLockSize: 110
    readonly property int capsLockRadius: 12
    readonly property int capsLockTimeout: 1200
    readonly property int capsLockPoll: 150
    readonly property string capsLockIcon: String.fromCodePoint(0xf0632)
    // Fainter than the menus' glass, and its edge
    readonly property color capsLockColor: Qt.rgba(21 / 255, 22 / 255, 30 / 255, 0.55)
    readonly property color capsLockEdgeColor: Qt.rgba(1, 1, 1, 0.08)

    // Volume popup: floats above the bar while the volume changes
    readonly property int osdWidth: 320
    readonly property int osdMargin: 24
    readonly property int osdTimeout: 1500

    // Like the bar's volume: the clock's colour, more opaque the louder it
    // gets, red past 100%, faintest when muted (config/waybar/style.css)
    function volumeColor(volume, muted) {
        if (muted)
            return Qt.rgba(192 / 255, 202 / 255, 245 / 255, 0.2);
        if (volume > 1.005)
            return closeColor;
        const percent = Math.round(volume * 100);
        const alpha = percent >= 71 ? 1 : percent >= 51 ? 0.75 : percent >= 31 ? 0.55 : 0.35;
        return Qt.rgba(192 / 255, 202 / 255, 245 / 255, alpha);
    }

    // A volume slider's fill: blue like a switch that's on, red past 100%,
    // dim when muted like a switch's knob when off
    function sliderColor(volume, muted) {
        if (muted)
            return dimColor;
        return volume > 1.005 ? closeColor : toggleOnColor;
    }

    // Louder icon above 50%, like the bar
    function volumeIcon(volume, muted) {
        return muted ? volumeMutedIcon : Math.round(volume * 100) > 50 ? volumeHighIcon : volumeLowIcon;
    }

    // Notifications: cards stacked up from the bar's right end, where dunst
    // put them, as wide as dunst's
    readonly property int notificationWidth: 360
    readonly property int notificationSpacing: 6
    readonly property int notificationIconSize: 32
    // Popups at once; the rest only go to the history
    readonly property int maxPopups: 3
    // For notifications that don't say how long to stay; critical ones stay
    // until closed
    readonly property int notificationTimeout: 5000
    // Notification centre (NotificationCenter.qml): as wide as the cards,
    // scrolling past this fraction of the screen height
    readonly property int notificationCenterWidth: 380
    readonly property real notificationCenterMaxHeight: 0.7
    readonly property string noNotificationsText: "No notifications"
    readonly property string doNotDisturbText: "Do not disturb is on"
    // Kept for the notification centre, oldest dropped first
    readonly property int maxNotifications: 50
    readonly property int notificationBodyLines: 3
    // Played for each one, as dunst did (message.oga from the freedesktop
    // sound theme)
    readonly property string notificationSound: "/usr/share/sounds/freedesktop/stereo/message.oga"
    readonly property string closeIcon: String.fromCodePoint(0xf0156)
    // The bar's notification bell (config/waybar/config.jsonc), with a
    // badge while there are new ones
    readonly property string bellIcon: String.fromCodePoint(0xf009a)
    readonly property string bellUnreadIcon: String.fromCodePoint(0xf116b)
    readonly property int notificationRowIconSize: 20
    // Do not disturb, in the notification centre and on the bar's bell
    readonly property string doNotDisturbIcon: String.fromCodePoint(0xf009b)
    // Do not disturb "until morning" ends at this hour
    readonly property int doNotDisturbMorning: 8

    readonly property int animationDuration: 120

    // For entries with Terminal=true
    readonly property list<string> terminal: ["alacritty", "-e"]
}
