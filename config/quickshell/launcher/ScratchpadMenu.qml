import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Windows parked in sway's scratchpad, in the same corner panel as the app
// launcher. Toggled by ~/.local/bin/scratchpad-menu
// (`qs -c launcher ipc call scratchpad toggleScratchpadMenu`). Enter takes the
// window out of the scratchpad and tiles it on the current workspace.
Scope {
    id: root

    property alias open: menu.open
    // One per scratchpad container: { id, appId, title }
    property var entries: []

    // Windows inside a container. Usually the container itself, but a whole
    // split can be sent to the scratchpad too.
    function windows(node) {
        if (node.nodes.length === 0)
            return [node];

        return node.nodes.reduce((found, child) => found.concat(root.windows(child)), []);
    }

    // Hidden scratchpad windows float on the "__i3_scratch" workspace
    function parse(tree) {
        const output = tree.nodes.find(output => output.name === "__i3");
        const workspace = output?.nodes.find(workspace => workspace.name === "__i3_scratch");

        return (workspace?.floating_nodes ?? []).map(node => {
            const windows = root.windows(node);
            return {
                id: node.id,
                // XWayland windows have a class instead of an app id
                appId: windows[0].app_id ?? windows[0].window_properties?.class ?? "",
                title: windows.map(window => window.name ?? "").join(" · ")
            };
        });
    }

    // Every word of the query has to appear in the title or app id
    function search(query, entries) {
        const words = query.toLowerCase().split(/\s+/).filter(word => word);
        if (words.length === 0)
            return entries;

        return entries.filter(entry => {
            const text = (entry.appId + " " + entry.title).toLowerCase();
            return words.every(word => text.includes(word));
        });
    }

    onOpenChanged: if (open)
        lister.running = true

    IpcHandler {
        target: "scratchpad"

        function toggleScratchpadMenu(): void {
            root.open = !root.open;
        }
    }

    Process {
        id: lister
        command: ["swaymsg", "-t", "get_tree"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.entries = root.parse(JSON.parse(text));
                } catch (error) {
                    root.entries = [];
                }
            }
        }
    }

    SearchMenu {
        id: menu

        results: root.search(query, root.entries)
        label: entry => entry.title
        icon: entry => Quickshell.iconPath(DesktopEntries.heuristicLookup(entry.appId)?.icon ?? entry.appId, "application-x-executable")
        emptyText: Theme.scratchpadEmptyText

        // Showing it puts it on the current workspace; tiling it is what
        // takes it out of the scratchpad
        onAccepted: entry => Quickshell.execDetached(["swaymsg", `[con_id=${entry.id}] scratchpad show, floating disable`])
    }
}
