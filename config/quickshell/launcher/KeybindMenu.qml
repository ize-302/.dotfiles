import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Cheat sheet of the sway key bindings, in the same corner panel as the app
// launcher. Toggled by ~/.local/bin/keybind-menu
// (`qs -c launcher ipc call keybinds toggleKeybindMenu`). Read only: Enter
// just closes it.
Scope {
    id: root

    property alias open: menu.open
    // One per binding: { keys, label, text }
    property var entries: []

    readonly property var keyNames: ({
            "Mod4": "Super",
            "Mod1": "Alt",
            "Return": "Enter",
            "space": "Space",
            "minus": "-",
            "slash": "/"
        })

    // "Mod4+Shift+r" -> "Super+Shift+R"
    function keys(combo) {
        return combo.split("+").map(key => root.keyNames[key] ?? (key.length === 1 ? key.toUpperCase() : key)).join("+");
    }

    // Bindings in the config sway has loaded. A binding is named by the
    // comment right above it when it has that comment to itself; one in a run
    // of bindings under a shared comment is named by its command.
    function parse(config) {
        const lines = config.split("\n").map(line => line.trim());
        const isBinding = line => /^bind(sym|code)\s/.test(line ?? "");
        const variables = {};
        const entries = [];
        let comment = [];
        let mode = "";

        for (let index = 0; index < lines.length; index++) {
            const line = lines[index];
            const variable = line.match(/^set\s+(\$\S+)\s+(.*)$/);
            const block = line.match(/^mode\s+"?([^"{\s]+)"?\s*\{$/);

            if (/^#\s*\S/.test(line)) {
                comment.push(line.replace(/^#+\s*/, ""));
                continue;
            }

            if (variable)
                variables[variable[1]] = variable[2];
            else if (block)
                mode = block[1];
            else if (line === "}")
                mode = "";

            if (isBinding(line)) {
                const words = line.replace(/\$\w+/g, name => variables[name] ?? name).split(/\s+/).slice(1).filter(word => !word.startsWith("--"));
                const combo = (mode ? mode + ": " : "") + root.keys(words[0]);
                const command = words.slice(1).join(" ").replace(/^exec\s+/, "");
                const own = comment.length > 0 && !isBinding(lines[index + 1]);

                entries.push({
                    keys: combo,
                    label: own ? comment.join(" ") : command,
                    text: [combo, command, comment.join(" ")].join(" ").toLowerCase()
                });
            }
            comment = [];
        }

        return entries;
    }

    // Every word of the query has to appear in the keys, command or comment
    function search(query, entries) {
        const words = query.toLowerCase().split(/\s+/).filter(word => word);
        if (words.length === 0)
            return entries;

        return entries.filter(entry => words.every(word => entry.text.includes(word)));
    }

    onOpenChanged: if (open)
        lister.running = true

    IpcHandler {
        target: "keybinds"

        function toggleKeybindMenu(): void {
            root.open = !root.open;
        }
    }

    Process {
        id: lister
        command: ["swaymsg", "-t", "get_config"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.entries = root.parse(JSON.parse(text).config);
                } catch (error) {
                    root.entries = [];
                }
            }
        }
    }

    SearchMenu {
        id: menu

        panelWidth: Theme.keybindWidth
        results: root.search(query, root.entries)
        label: entry => entry.label
        hint: entry => entry.keys
        emptyText: Theme.keybindEmptyText
    }
}
