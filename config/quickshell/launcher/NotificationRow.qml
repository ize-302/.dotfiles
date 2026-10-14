pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import qs

// A notification in the control panel's notification centre: its app's icon,
// summary and age (with a close button under the mouse), the body under them,
// then its other actions as key caps.
Column {
    id: row

    // The notification, and the server it came from (Notifications.qml),
    // for its icon and age
    required property var notification
    required property var server
    // Picked with the keys or under the mouse: shows the close button
    property bool active: false

    spacing: Theme.rowSpacing / 2

    Row {
        width: parent.width
        spacing: Theme.iconSpacing

        IconImage {
            property int tried: 0
            readonly property list<string> candidates: row.notification ? row.server.icons(row.notification) : []

            anchors.verticalCenter: parent.verticalCenter
            implicitSize: Theme.notificationRowIconSize
            source: candidates[tried] ?? ""
            onStatusChanged: if (status === Image.Error && tried < candidates.length - 1)
                tried++
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.notificationRowIconSize - age.width - dismiss.width - parent.spacing * 3
            text: row.notification?.summary ?? ""
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
            text: row.notification ? row.server.age(row.notification) : ""
            color: Theme.dimColor
            font.family: Theme.fontFamily
            font.pixelSize: Theme.controlSmallFontSize
            font.weight: Theme.fontWeight
        }

        // Dismisses it, shown under the mouse
        Text {
            id: dismiss
            anchors.verticalCenter: parent.verticalCenter
            opacity: row.active ? 1 : 0
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
                onClicked: row.notification.dismiss()
            }
        }
    }

    Text {
        x: Theme.notificationRowIconSize + Theme.iconSpacing
        width: parent.width - x
        visible: text !== ""
        text: row.notification?.body ?? ""
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
        readonly property list<var> actions: (row.notification?.actions ?? []).filter(action => action.identifier !== "default")

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
