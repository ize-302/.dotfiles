import QtQuick
import qs

// A small triangle under a popup (Glass.qml), pointing down at the bar
// module it was opened from: the glass's fill, with its lit edge along the
// two slanted sides. Its owner puts it just under the glass and sets `tip`,
// the x (in the glass) it points at; it stays clear of the rounded corners.
Canvas {
    id: arrow

    property real tip: 0
    // The glass it hangs from, for its width, fill and edge
    property Item glass: parent

    width: Theme.arrowWidth
    height: Theme.arrowHeight
    x: Math.max(Theme.panelRadius, Math.min(tip - width / 2, (glass?.width ?? width) - width - Theme.panelRadius))
    // Over the glass's bottom edge, so the two read as one shape
    y: (glass?.height ?? 0) - 1

    onPaint: {
        const context = getContext("2d");
        context.reset();
        context.beginPath();
        context.moveTo(0, 0);
        context.lineTo(width / 2, height);
        context.lineTo(width, 0);
        context.closePath();
        context.fillStyle = Theme.glassPanelColor;
        context.fill();

        context.beginPath();
        context.moveTo(0.5, 0);
        context.lineTo(width / 2, height - 0.5);
        context.lineTo(width - 0.5, 0);
        context.strokeStyle = Theme.edgeColor;
        context.lineWidth = 1;
        context.stroke();
    }
}
