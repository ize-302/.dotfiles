import QtQuick
import qs

// Tinted cap around a short bit of text, like the bar's workspace buttons:
// a key in the key bindings menu, a volume or a device in the control panel.
// Brighter when lit.
Rectangle {
    id: cap

    property string text: ""
    property bool lit: false
    // At least this wide, so a changing number doesn't make it jump
    property int minWidth: 0
    property int fontSize: Theme.keyFontSize
    // The text's colour, and when lit
    property color textColor: Theme.keyTextColor
    property color litTextColor: Theme.textColor

    width: Math.max(minWidth, label.implicitWidth + Theme.keyPadding * 2)
    height: Theme.keyHeight
    radius: Theme.cornerRadius
    color: lit ? Theme.selectedColor : Theme.keyColor

    Text {
        id: label
        anchors.centerIn: parent
        text: cap.text
        textFormat: Text.PlainText
        color: cap.lit ? cap.litTextColor : cap.textColor
        font.family: Theme.fontFamily
        font.pixelSize: cap.fontSize
        font.weight: Theme.fontWeight
    }
}
