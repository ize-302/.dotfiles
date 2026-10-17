pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
import Quickshell
import Quickshell.Io
import qs

// Month view at the bottom of the notification centre, on a card like its
// title's: the month and year with arrows to the month before and after,
// the days of the week, and the month's days (with the ends of the months
// either side, dimmed), today on a blue circle like a switch that's on,
// weeks from Monday. Days with events (~/.local/bin/calendar-events, from the
// Google calendars in ~/.config/calendar/urls) have an orange dot, like the
// bar's clock's for new notifications. Scrolling moves a month too. The
// owner calls reset() to come back to this month, which fetches the events
// again if they're old.
Rectangle {
    id: calendar

    property date today: new Date()
    property int month: today.getMonth()
    property int year: today.getFullYear()
    // Days with events ("YYYY-MM-DD" -> true), and when they were fetched
    property var events: ({})
    property real fetched: 0

    function reset() {
        today = new Date();
        month = today.getMonth();
        year = today.getFullYear();
        if (Date.now() - fetched > Theme.calendarRefresh && !fetcher.running)
            fetcher.running = true;
    }

    function key(year, month, day) {
        return year + "-" + String(month + 1).padStart(2, "0") + "-" + String(day).padStart(2, "0");
    }

    // A month forwards (1) or back (-1)
    function step(months) {
        const date = new Date(year, month + months, 1);
        month = date.getMonth();
        year = date.getFullYear();
        fade.restart();
    }

    height: rows.height + Theme.panelPadding
    radius: Theme.cornerRadius
    color: Theme.noteCardColor

    Process {
        id: fetcher

        command: [Quickshell.env("HOME") + "/.local/bin/calendar-events"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const events = {};
                    for (const day of JSON.parse(text))
                        events[day] = true;
                    calendar.events = events;
                    calendar.fetched = Date.now();
                } catch (error) {
                    // Kept as they were; tried again next time it opens
                }
            }
        }
    }

    // Today moves on at midnight while it's open
    Timer {
        running: calendar.visible
        repeat: true
        interval: 60 * 1000
        onTriggered: {
            const now = new Date();
            if (now.getDate() !== calendar.today.getDate())
                calendar.today = now;
        }
    }

    WheelHandler {
        onWheel: event => calendar.step(event.angleDelta.y > 0 ? -1 : 1)
    }

    Column {
        id: rows

        x: Theme.panelPadding
        y: Theme.panelPadding / 2
        width: parent.width - x * 2

        Item {
            width: parent.width
            height: Theme.noteCardButtonHeight + Theme.rowSpacing * 2

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.locale().standaloneMonthName(calendar.month) + " " + calendar.year
                color: Theme.textColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.searchFontSize
                font.weight: Font.DemiBold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.keySpacing * 2

                Repeater {
                    model: [
                        {
                            icon: Theme.backIcon,
                            months: -1
                        },
                        {
                            icon: Theme.pageIcon,
                            months: 1
                        }
                    ]

                    Rectangle {
                        id: arrow

                        required property var modelData

                        width: Theme.noteCardButtonHeight
                        height: width
                        radius: Theme.cornerRadius
                        color: arrowMouse.containsMouse ? Theme.hoverColor : Theme.keyColor

                        Text {
                            anchors.centerIn: parent
                            text: arrow.modelData.icon
                            color: Theme.keyTextColor
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.controlFontSize
                        }

                        MouseArea {
                            id: arrowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: calendar.step(arrow.modelData.months)
                        }
                    }
                }
            }
        }

        // The templates, not QtQuick.Controls' styled ones: those drew
        // nothing here. Each cell a seventh of the width.
        T.AbstractDayOfWeekRow {
            id: weekdays

            width: parent.width
            implicitHeight: contentItem.implicitHeight
            locale: grid.locale

            contentItem: Row {
                Repeater {
                    model: weekdays.source
                    delegate: weekdays.delegate
                }
            }

            delegate: Text {
                required property string shortName

                width: weekdays.width / 7
                height: Theme.calendarCellSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: shortName
                color: Theme.dimColor
                font.family: Theme.fontFamily
                font.pixelSize: Theme.controlSmallFontSize
                font.weight: Theme.fontWeight
            }
        }

        T.AbstractMonthGrid {
            id: grid

            width: parent.width
            implicitHeight: contentItem.implicitHeight
            month: calendar.month
            year: calendar.year
            // British English: weeks from Monday
            locale: Qt.locale("en_GB")

            contentItem: Grid {
                rows: 6
                columns: 7

                Repeater {
                    model: grid.source
                    delegate: grid.delegate
                }
            }

            delegate: Item {
                id: day

                required property var model
                readonly property bool isToday: model.day === calendar.today.getDate() && model.month === calendar.today.getMonth() && model.year === calendar.today.getFullYear()
                readonly property bool busy: calendar.events[calendar.key(model.year, model.month, model.day)] ?? false

                width: grid.width / 7
                height: Theme.calendarCellSize

                Rectangle {
                    anchors.centerIn: parent
                    visible: day.isToday
                    width: Theme.calendarCellSize - Theme.rowSpacing * 2
                    height: width
                    radius: width / 2
                    color: Theme.toggleOnColor
                }

                Text {
                    anchors.centerIn: parent
                    text: day.model.day
                    color: day.isToday ? "white" : day.model.month === calendar.month ? Theme.textColor : Theme.dimColor
                    opacity: day.isToday || day.model.month === calendar.month ? 1 : 0.6
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.calendarFontSize
                    font.weight: day.isToday ? Theme.selectedWeight : Theme.fontWeight
                }

                // Under the number, just below today's circle
                Rectangle {
                    visible: day.busy
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: Theme.calendarDotSize
                    height: width
                    radius: width / 2
                    color: Theme.accentColor
                    opacity: day.model.month === calendar.month ? 1 : 0.6
                }
            }

            // A new month fades in
            NumberAnimation {
                id: fade
                target: grid
                property: "opacity"
                from: 0.3
                to: 1
                duration: Theme.animationDuration
            }
        }
    }
}
