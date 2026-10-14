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

    readonly property int animationDuration: 120

    // For entries with Terminal=true
    readonly property list<string> terminal: ["alacritty", "-e"]
}
