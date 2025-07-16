const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const path = "/sys/class/thermal/thermal_zone0/temp";
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [2048]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];
    const trimmed = std.mem.trim(u8, content, "\n");

    const trimmed_to_int = try std.fmt.parseInt(u64, trimmed, 10);
    const result: u64 = trimmed_to_int / 1000;
    const temp_percentage: u8 = @intCast(result);

    try stdout.print(" <span color='{s}'>{s} {:>1}ºC </span>\n ", .{ getColor(temp_percentage), getIcon(temp_percentage), temp_percentage });
}

fn getColor(temp: u8) []const u8 {
    if (temp < 50) {
        return "#00FF00";
    } else if (temp < 55) {
        return "#bfff00";
    } else if (temp < 60) {
        return "#ffff00";
    } else if (temp < 65) {
        return "#ffbf00";
    } else if (temp < 70) {
        return "#ff8000";
    } else {
        return "#ff0000";
    }
}

fn getIcon(temp: u8) []const u8 {
    if (temp < 50) {
        return "";
    } else if (temp < 55) {
        return "";
    } else if (temp < 60) {
        return "";
    } else if (temp < 65) {
        return "";
    } else {
        return "";
    }
}
