import QtQuick
import qs

// On/off switch, squared off like the key caps: a tinted track, lit when on,
// and a knob that slides across. The row it sits in handles the click.
Rectangle {
    id: toggle

    property bool checked: false

    width: Theme.toggleWidth
    height: Theme.toggleHeight
    radius: Theme.cornerRadius
    color: checked ? Theme.toggleOnColor : Theme.keyColor

    Behavior on color {
        ColorAnimation {
            duration: Theme.animationDuration
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: toggle.checked ? toggle.width - width - 2 : 2
        width: toggle.height - 4
        height: width
        radius: Theme.cornerRadius - 1
        color: toggle.checked ? Theme.textColor : Theme.dimColor

        Behavior on x {
            NumberAnimation {
                duration: Theme.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }
}
