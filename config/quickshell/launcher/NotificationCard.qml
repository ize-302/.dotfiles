pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs

// A notification in the notification centre (NotificationCenter.qml), as a
// card like macOS's: the app's icon in a rounded square, the summary in bold
// with its age at the end, the body under it, and its other actions as pill
// buttons. Under the mouse, a round × on the top left corner dismisses it.
//
// A collapsed stack (`stack` above 1: more from the same app behind it)
// shows the edges of two cards peeking out underneath, and its × dismisses
// the whole stack.
Item {
    id: card

    // The notification, and the server it came from (Notifications.qml),
    // for its icon and age
    required property var notification
    required property var server
    // How many it stands for: 1, or the size of a collapsed stack
    property int stack: 1
    // Picked with the keys: a blue outline
    property bool selected: false
    readonly property bool hovered: hover.hovered

    signal clicked
    signal closeClicked

    implicitHeight: face.height + (stack > 1 ? Theme.noteCardStackPeek * 2 : 0)

    HoverHandler {
        id: hover
    }

    // The cards behind a stack, narrower and lower, peeking out underneath:
    // only their rounded bottoms, cut off at the edge above them, as the
    // cards are see-through
    Repeater {
        model: card.stack > 1 ? 2 : 0

        Item {
            required property int index

            x: Theme.noteCardStackInset * (index + 1)
            y: face.height + Theme.noteCardStackPeek * index
            width: card.width - x * 2
            height: Theme.noteCardStackPeek
            clip: true

            Rectangle {
                // Only its bottom edge shows
                y: parent.height - height
                width: parent.width
                height: Theme.noteCardRadius * 2
                radius: Theme.noteCardRadius
                color: Theme.noteCardHoverColor
                border.width: 1
                border.color: Theme.noteCardEdgeColor
                opacity: 1 - parent.index * 0.35
            }
        }
    }

    Rectangle {
        id: face

        width: parent.width
        height: content.implicitHeight + Theme.noteCardPadding * 2
        radius: Theme.noteCardRadius
        color: hover.hovered ? Theme.noteCardHoverColor : Theme.noteCardColor
        border.width: card.selected ? 1.5 : 1
        border.color: card.selected ? Theme.selectedColor : Theme.noteCardEdgeColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.animationDuration
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.clicked()
        }

        Row {
            id: content

            x: Theme.noteCardPadding
            y: Theme.noteCardPadding
            width: parent.width - x * 2
            spacing: Theme.noteCardPadding

            // The app's icon, or the picture sent with it, in a rounded
            // square
            ClippingRectangle {
                width: Theme.noteCardIconSize
                height: Theme.noteCardIconSize
                radius: Theme.noteCardIconSize / 4.5
                color: "transparent"

                IconImage {
                    property int tried: 0
                    readonly property list<string> candidates: card.notification ? card.server.icons(card.notification) : []

                    anchors.fill: parent
                    implicitSize: Theme.noteCardIconSize
                    source: candidates[tried] ?? ""
                    onStatusChanged: if (status === Image.Error && tried < candidates.length - 1)
                        tried++
                }
            }

            Column {
                width: parent.width - Theme.noteCardIconSize - parent.spacing
                spacing: 2

                // The summary (or the app, when there's none) and its age
                Item {
                    width: parent.width
                    height: summary.implicitHeight

                    Text {
                        id: summary
                        width: parent.width - age.width - Theme.iconSpacing
                        text: card.notification?.summary || card.notification?.appName || "Notification"
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: Theme.textColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.controlFontSize
                        font.weight: Font.DemiBold
                    }

                    Text {
                        id: age
                        anchors.right: parent.right
                        anchors.baseline: summary.baseline
                        text: card.notification ? card.server.age(card.notification) : ""
                        color: Theme.dimColor
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.controlSmallFontSize
                        font.weight: Theme.fontWeight
                    }
                }

                // Apps may send simple markup (bold, italics, links)
                Text {
                    width: parent.width
                    visible: text !== ""
                    text: card.notification?.body ?? ""
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: Theme.notificationBodyLines
                    elide: Text.ElideRight
                    color: Theme.keyTextColor
                    linkColor: Theme.textColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.controlSmallFontSize + 1
                    font.weight: Theme.fontWeight
                }

                // Its other actions, as pills
                Flow {
                    readonly property list<var> actions: (card.notification?.actions ?? []).filter(action => action.identifier !== "default")

                    width: parent.width
                    visible: actions.length > 0
                    topPadding: Theme.rowSpacing * 1.5
                    spacing: Theme.keySpacing * 1.5

                    Repeater {
                        model: parent.actions

                        Rectangle {
                            id: action

                            required property var modelData

                            width: label.implicitWidth + Theme.noteCardPadding * 1.5
                            height: label.implicitHeight + 8
                            radius: height / 2
                            color: actionMouse.containsMouse ? Theme.noteCardHoverColor : Theme.keyColor
                            border.width: 1
                            border.color: Theme.noteCardEdgeColor

                            Text {
                                id: label
                                anchors.centerIn: parent
                                text: action.modelData.text
                                color: Theme.textColor
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.controlSmallFontSize
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: action.modelData.invoke()
                            }
                        }
                    }
                }
            }
        }
    }

    // Dismisses it (or the stack), on the corner, under the mouse
    Rectangle {
        x: -Theme.noteCardCloseSize / 3
        y: -Theme.noteCardCloseSize / 3
        z: 1
        width: Theme.noteCardCloseSize
        height: width
        radius: width / 2
        visible: hover.hovered || card.selected
        color: closeMouse.containsMouse ? Theme.noteCardHoverColor : Theme.glassPanelColor
        border.width: 1
        border.color: Theme.noteCardEdgeColor

        Text {
            anchors.centerIn: parent
            text: Theme.closeIcon
            color: closeMouse.containsMouse ? Theme.textColor : Theme.keyTextColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.controlSmallFontSize
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            anchors.margins: -3
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: card.closeClicked()
        }
    }
}
