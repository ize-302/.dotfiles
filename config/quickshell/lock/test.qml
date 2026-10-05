import QtQuick
import Quickshell
import qs

// The lock UI in a normal window, for working on it without locking the
// session: `qs -p ~/.config/quickshell/lock/test.qml`. The password is still
// checked through PAM.
ShellRoot {
    LockContext {
        id: lockContext
        onUnlocked: Qt.quit()
    }

    FloatingWindow {
        implicitWidth: 960
        implicitHeight: 540
        color: Theme.background

        LockSurface {
            anchors.fill: parent
            context: lockContext
        }
    }

    Connections {
        target: Quickshell
        function onLastWindowClosed() {
            Qt.quit();
        }
    }
}
