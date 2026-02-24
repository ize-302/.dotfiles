# i3 blocklets

This repository contains a set of blocklets for i3blocks, all written in Zig
(0.15.2).

## Blocklets

| Blocklet      | Description                                                                                                                                                              |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `battery`     | Shows battery percentage with icon and color. When discharging, displays estimated time remaining (hours and minutes). Color shifts from green to red as battery drains. |
| `brightness`  | Shows screen brightness as a percentage, reading from the Intel backlight sysfs interface.                                                                               |
| `capslock`    | Displays a red "CAPS ON" indicator when Caps Lock is active. Shows nothing when off.                                                                                     |
| `cpu_usage`   | Shows CPU usage percentage by sampling `/proc/stat` twice over 500ms. Color shifts from green to red as usage increases.                                                 |
| `kernel`      | Displays the running kernel version string read from `/proc/sys/kernel/osrelease`.                                                                                       |
| `memory`      | Shows RAM usage as a percentage of total memory. Color shifts from green to red as usage increases.                                                                      |
| `temperature` | Shows CPU temperature in °C with a thermometer icon that changes based on heat level. Color shifts from green to red as temperature rises.                               |
| `volume`      | Shows system audio volume percentage via `wpctl`. Displays a muted icon and grey color when muted, otherwise shows a speaker icon.                                       |

### Extra blocks in the config

The `config` also includes two non-Zig blocks that use shell commands directly:

| Block  | Command                | Description                               |
| ------ | ---------------------- | ----------------------------------------- |
| `date` | `date +"  %a, %d %b "` | Displays the current day and date.        |
| `time` | `date +" %H:%M"`       | Displays the current time in 24hr format. |

## Building

Each blocklet is built individually using its `build.sh` script. All blocklets follow the same pattern — compiled with `zig build-exe` at `ReleaseFast` optimization level:

```sh
cd <blocklet>
./build.sh
```

This produces a standalone binary in the same directory (e.g. `battery/battery`).

To build all blocklets at once:

```sh
for dir in battery brightness capslock cpu_usage kernel memory temperature volume; do
    (cd "$dir" && ./build.sh)
done
```

> **Requirement:** [Zig](https://ziglang.org) must be installed and available on your `$PATH`.

The `volume` blocklet additionally requires `wpctl` (part of [WirePlumber](https://pipewire.pages.freedesktop.org/wireplumber/)) to be available at runtime.

The config assumes all binaries live in their respective subdirectories relative to the config file (e.g. `./battery/battery`), so i3blocks should be launched from the repo root, or the paths in `config` adjusted accordingly.

All Zig blocklets output [Pango](https://docs.gtk.org/Pango/pango_markup.html) markup for colored text, so every block entry in the config requires `markup=pango`.
