const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const batt_capacity_path = "/sys/class/power_supply/BAT0/capacity";
    const energy_now_path = "/sys/class/power_supply/BAT0/energy_now";
    const power_now_path = "/sys/class/power_supply/BAT0/power_now";

    const batt_capacity_u64 = try readIntFromFile(batt_capacity_path);
    const batt_capacity: u8 = @as(u8, @intCast(batt_capacity_u64)); // cast to u8

    const plugged = try isPluggedIn();
    const icon = try getIcon(batt_capacity, plugged);
    const color = try getColor(batt_capacity, plugged);
    const energy_now = try readIntFromFile(energy_now_path);
    const power_now = try readIntFromFile(power_now_path);

    if (plugged) {
        if (batt_capacity > 0) {
            try stdout.print(" <span color='{s}'>{s} {}% ⚡</span>\n", .{ color, icon, batt_capacity });
        }
    } else if (power_now == 0) {
        try stdout.print(" <span color='{s}'>{s} {}% 🤔</span>\n", .{ color, icon, batt_capacity });
    } else if (power_now > 0) {
        const time_hours = @as(f64, @floatFromInt(energy_now)) / @as(f64, @floatFromInt(power_now));
        const time_minutes_f64 = time_hours * 60.0;
        const time_minutes = @as(u32, @intFromFloat(time_minutes_f64));
        const hrs = time_minutes / 60;
        const mins = time_minutes % 60;

        try stdout.print(" <span color='{s}'>{s} {}% {}h{}m</span>\n", .{ color, icon, batt_capacity, hrs, mins });
    }
}

fn getColor(percent: u8, plugged: bool) ![]const u8 {
    if (plugged) {
        return "#7dd3fc";
    } else if (percent < 10) {
        return "#FF0000";
    } else if (percent < 30) {
        return "#ff8000";
    } else if (percent < 50) {
        return "#ffff00";
    } else if (percent < 80) {
        return "#bfff00";
    } else if (percent < 100) {
        return "#00FF00";
    } else {
        return "...";
    }
}

fn getIcon(percent: u8, plugged: bool) ![]const u8 {
    if (plugged) {
        return "󰂄";
    } else if (percent < 10) {
        return "󰁻";
    } else if (percent < 30) {
        return "󰁼";
    } else if (percent < 50) {
        return "󰁾";
    } else if (percent < 80) {
        return "󰂀";
    } else if (percent < 100) {
        return "󰁹";
    } else {
        return "...";
    }
}

fn isPluggedIn() !bool {
    const file_path = "/sys/class/power_supply/AC/online";
    var file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    var buffer: [16]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const trimmed = std.mem.trim(u8, buffer[0..bytes_read], "\n");

    return std.mem.eql(u8, trimmed, "1");
}

fn readIntFromFile(path: []const u8) !u64 {
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [32]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const trimmed = std.mem.trim(u8, buffer[0..bytes_read], "\n");

    return try std.fmt.parseInt(u64, trimmed, 10);
}
