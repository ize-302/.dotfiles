pragma Singleton

import QtQuick
import Quickshell

// Same glass as the status bar (config/waybar/style.css): a neutral dark
// tint with a faint hairline edge, white text. sway's
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
    // Small solid bits, like the scratchpad cards' close button
    readonly property color panelColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.9)
    // The menus' panels: the bar's tint, a little less see-through, as they
    // hold more text
    readonly property color glassPanelColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.7)
    readonly property color edgeColor: Qt.rgba(1, 1, 1, 0.12)
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
    readonly property color textColor: "#ffffff"
    readonly property color dimColor: "#9a9a9a"
    readonly property color dividerColor: Qt.rgba(1, 1, 1, 0.12)
    readonly property int searchPadding: 10

    // Results
    readonly property int maxRows: 12
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 4
    readonly property int rowPadding: 8
    readonly property int iconSize: 22
    readonly property int iconSpacing: 10
    // What's selected or in use: white and semibold, the rest of its list in
    // unselectedColor
    readonly property color selectedColor: textColor
    readonly property int selectedWeight: Font.DemiBold
    readonly property int unselectedWeight: Font.Normal
    readonly property color unselectedColor: keyTextColor
    // Under the row the keys or the mouse are on: a faint white tint
    readonly property color currentRowColor: Qt.rgba(1, 1, 1, 0.08)
    // A lit key cap or button: a white tint
    readonly property color hoverColor: Qt.rgba(1, 1, 1, 0.12)

    // Key caps, a fainter white tint
    readonly property color keyColor: Qt.rgba(1, 1, 1, 0.06)
    readonly property color keyTextColor: "#cccccc"
    readonly property int keyFontSize: 13
    readonly property int keyHeight: 22
    readonly property int keyPadding: 7
    readonly property int keySpacing: 4

    // Group headers
    readonly property int sectionFontSize: 12
    readonly property int sectionHeight: 30

    // Shown instead of the list when nothing matches
    readonly property string emptyText: "No apps found"

    // Power menu: a row of tiles floating centred just above the bar, a large
    // icon over each label
    // Line glyphs in the text's colour, like the control panel's (and the
    // login screen's power menu)
    readonly property string powerLockIcon: String.fromCodePoint(0xf0341)
    readonly property string powerLogoutIcon: String.fromCodePoint(0xf0343)
    readonly property string powerSleepIcon: String.fromCodePoint(0xf04b2)
    readonly property string powerRestartIcon: String.fromCodePoint(0xf0709)
    readonly property string powerShutDownIcon: String.fromCodePoint(0xf0425)
    readonly property int powerIconSize: 26
    readonly property int powerTileWidth: 72
    readonly property int powerTilePadding: 8
    readonly property int powerPanelPadding: 6
    readonly property int powerFontSize: 13
    // The bar's own tint (config/waybar/style.css)
    readonly property color powerColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.5)

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
    // A blue pill when on, like a macOS switch (macOS's system blue); the
    // sliders' fill and the filled buttons too
    readonly property color toggleOnColor: "#0a84ff"
    // Opens a section's page, and goes back from it
    readonly property string pageIcon: String.fromCodePoint(0xf0142)
    readonly property string backIcon: String.fromCodePoint(0xf0141)
    // How far a page slides in
    readonly property int pageSlide: 24
    // Orange like the focused window's border (client.focused in
    // config/sway/config): what's in use or connected
    readonly property color accentColor: "#ff7518"

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

    // Caps lock popup (CapsLock.qml): a square centred across the bottom of
    // the screen, floatingGap above the bar, with the menus' corners and a
    // caps lock icon (icons/capslock.svg); up while caps lock is on, and for
    // capsLockTimeout ms after it's turned off. How often the keyboards'
    // lights are read, in ms.
    readonly property int capsLockSize: 60
    readonly property int capsLockIconSize: 24
    readonly property int capsLockFontSize: 9
    readonly property int capsLockTimeout: 1200
    readonly property int capsLockPoll: 150
    // Fainter than the menus' glass, and its edge
    readonly property color capsLockColor: Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.5)
    readonly property color capsLockEdgeColor: Qt.rgba(1, 1, 1, 0.08)

    // The bar's height ("height" in config/waybar/config.jsonc), where
    // ~/.local/bin/bar-anchor looks for the module a popup was opened from
    readonly property int barHeight: 38
    readonly property string barAnchor: Quickshell.env("HOME") + "/.local/bin/bar-anchor"

    // Volume popup: floats above the bar while the volume changes
    readonly property int osdWidth: 320
    readonly property int osdMargin: 24
    readonly property int osdTimeout: 1500

    // Like the bar's volume: white, red past 100%, faint when muted
    // (config/waybar/style.css)
    function volumeColor(volume, muted) {
        if (muted)
            return Qt.rgba(1, 1, 1, 0.3);
        return volume > 1.005 ? closeColor : textColor;
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
    // The notification centre's cards (NotificationCard.qml), like
    // macOS's: rounded, a little lighter than the glass, with the app's icon
    // in a rounded square. A collapsed stack's cards peek out underneath.
    readonly property int noteCardRadius: 14
    readonly property int noteCardPadding: 12
    readonly property int noteCardIconSize: 34
    readonly property int noteCardSpacing: 8
    readonly property color noteCardColor: Qt.rgba(1, 1, 1, 0.06)
    readonly property color noteCardHoverColor: Qt.rgba(1, 1, 1, 0.1)
    readonly property color noteCardEdgeColor: Qt.rgba(1, 1, 1, 0.08)
    readonly property int noteCardStackPeek: 6
    readonly property int noteCardStackInset: 10
    readonly property int noteCardCloseSize: 20
    // The round and pill buttons: do not disturb, Clear All, Show less
    readonly property int noteCardButtonHeight: 26

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
    // A bell, with a badge while there are new notifications
    readonly property string bellIcon: String.fromCodePoint(0xf009a)
    readonly property string bellUnreadIcon: String.fromCodePoint(0xf116b)
    readonly property int notificationRowIconSize: 20
    // Do not disturb, in the notification centre (and on the bar's clock,
    // ~/.local/bin/clock-status)
    readonly property string doNotDisturbIcon: String.fromCodePoint(0xf009b)
    // Do not disturb "until morning" ends at this hour
    readonly property int doNotDisturbMorning: 8

    readonly property int animationDuration: 120

    // For entries with Terminal=true
    readonly property list<string> terminal: ["alacritty", "-e"]
}
