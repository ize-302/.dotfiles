import QtQuick
import qs

// Panel background shared by the menus: translucent, with a sheen fading down
// from the top and a lit top and right edge. Left and bottom touch the screen
// edge and the bar, unless the panel is floating: then every corner is
// rounded and every edge lit. A full width panel, like the bar, only has its
// top edge lit and no rounded corner.
Rectangle {
    id: glass

    property bool floating: false
    property int cornerRadius: Theme.cornerRadius
    property bool fullWidth: false

    color: Theme.panelColor
    radius: floating ? cornerRadius : 0
    // The one corner that touches neither the screen edge nor the bar
    topRightRadius: fullWidth ? 0 : cornerRadius

    // Rises out of the bar
    function appear() {
        animation.restart();
    }

    transform: Translate {
        id: slide
    }

    ParallelAnimation {
        id: animation

        NumberAnimation {
            target: slide
            property: "y"
            from: 16
            to: 0
            duration: Theme.animationDuration
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: glass
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.animationDuration
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: glass.radius
        topRightRadius: glass.topRightRadius
        gradient: Gradient {
            GradientStop {
                position: 0
                color: Theme.sheenTop
            }
            GradientStop {
                position: 0.45
                color: Theme.sheenMiddle
            }
            GradientStop {
                position: 1
                color: "transparent"
            }
        }
    }
    // The lit edge is an outline that follows the corner; its left and bottom
    // sides hang outside the panel and are clipped away (unless floating)
    Item {
        anchors.fill: parent
        clip: true

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: glass.floating ? 0 : -border.width
            anchors.bottomMargin: glass.floating ? 0 : -border.width
            anchors.rightMargin: glass.fullWidth ? -border.width : 0
            color: "transparent"
            radius: glass.radius
            topRightRadius: glass.topRightRadius
            border.width: 1
            border.color: Theme.edgeColor
        }
    }
}
