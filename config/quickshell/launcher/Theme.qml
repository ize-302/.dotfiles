pragma Singleton

import QtQuick
import Quickshell

// Same glass as the status bar (config/waybar/style.css): translucent
// #15161e with a sheen fading down and a lit edge. sway's
// `layer_effects "launcher"` blurs what's behind.
Singleton {
    readonly property string fontFamily: "JetBrainsMono NF"
    readonly property int fontSize: 17
    readonly property int fontWeight: 500

    // Fraction of the screen width
    readonly property real panelWidth: 0.22
    readonly property int panelPadding: 14
    readonly property color panelColor: Qt.rgba(21 / 255, 22 / 255, 30 / 255, 0.96)
    // The menus' panels, more see-through than the bar
    readonly property color glassPanelColor: Qt.rgba(21 / 255, 22 / 255, 30 / 255, 0.8)
    readonly property color sheenTop: Qt.rgba(1, 1, 1, 0.05)
    readonly property color sheenMiddle: Qt.rgba(1, 1, 1, 0.01)
    readonly property color edgeColor: Qt.rgba(1, 1, 1, 0.16)
    // Top right corner of the menus
    readonly property int cornerRadius: 4
    // Gap between a standing panel and the screen edge
    readonly property int edgeMargin: 2

    // Search row
    readonly property int searchFontSize: 15
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
    // Tint, like the bar's focused workspace button
    readonly property color selectedColor: Qt.rgba(192 / 255, 202 / 255, 245 / 255, 0.12)

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

    // Key bindings menu: wider, a description and its keys share the row
    readonly property real keybindWidth: 0.35
    readonly property int keybindRadius: cornerRadius
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
    // Rows, padding and headers are the other menus', the text smaller: the
    // names and glyphs, then the percentages, caps and details after them
    readonly property int controlFontSize: 14
    readonly property int controlSmallFontSize: 12
    readonly property string controlEmptyText: "Nothing to control"
    // Arrow keys and the mouse wheel move a slider this far
    readonly property real volumeStep: 0.05
    readonly property int sliderHeight: 6
    readonly property int knobSize: 12
    readonly property int knobActiveSize: 16
    // The bar's volume glyphs (config/waybar/config.jsonc)
    readonly property string volumeMutedIcon: "\uf026"
    readonly property string volumeLowIcon: "\uf027"
    readonly property string volumeHighIcon: "\uf028"
    readonly property string micIcon: "\uf130"
    readonly property string micMutedIcon: "\uf131"
    // The bar's brightness emoji and colour (config/waybar/config.jsonc and
    // style.css)
    readonly property string brightnessIcon: "\u2600\ufe0f"
    readonly property color brightnessColor: "orange"
    // The bar's bluetooth glyphs and colours: on, a device connected, off
    readonly property string bluetoothIcon: String.fromCodePoint(0xf00af)
    readonly property string bluetoothConnectedIcon: String.fromCodePoint(0xf00b1)
    readonly property string bluetoothOffIcon: String.fromCodePoint(0xf00b2)
    readonly property color bluetoothColor: "#b0b0b2"
    readonly property color bluetoothOffColor: "#808080"
    // Wi-Fi: on, off, and signal bars (weak to strong), with a lock for
    // networks that need a password
    readonly property string wifiIcon: String.fromCodePoint(0xf05a9)
    readonly property string wifiOffIcon: String.fromCodePoint(0xf05aa)
    readonly property list<string> wifiStrengthIcons: [0xf091f, 0xf0922, 0xf0925, 0xf0928].map(code => String.fromCodePoint(code))
    readonly property list<string> wifiStrengthLockIcons: [0xf0921, 0xf0924, 0xf0927, 0xf092a].map(code => String.fromCodePoint(code))
    // Networks listed at most; the rest are further away
    readonly property int maxNetworks: 6
    readonly property string passwordPlaceholder: "Password"
    // On/off switch
    readonly property int toggleWidth: 30
    readonly property int toggleHeight: 18
    readonly property color toggleOnColor: Qt.rgba(192 / 255, 202 / 255, 245 / 255, 0.35)
    // Opens a section's page, and goes back from it
    readonly property string collapsedIcon: String.fromCodePoint(0xf0142)
    readonly property string backIcon: String.fromCodePoint(0xf0141)
    // How far a page slides in
    readonly property int pageSlide: 24
    // Orange like the focused window's border (client.focused in
    // config/sway/config): what's in use or connected
    readonly property color accentColor: "#ff7518"
    // Marks what's in use or connected
    readonly property string checkIcon: "\uf00c"

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

    // Louder icon above 50%, like the bar
    function volumeIcon(volume, muted) {
        return muted ? volumeMutedIcon : Math.round(volume * 100) > 50 ? volumeHighIcon : volumeLowIcon;
    }

    readonly property int animationDuration: 120

    // For entries with Terminal=true
    readonly property list<string> terminal: ["alacritty", "-e"]
}
