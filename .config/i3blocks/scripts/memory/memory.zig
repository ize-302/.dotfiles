const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const path = "/proc/meminfo";
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [2048]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    const total = readMemInfoValue(content, "MemTotal:") orelse return error.MissingMemTotal;
    const available = readMemInfoValue(content, "MemAvailable:") orelse return error.MissingMemAvailable;

    const used = total - available;
    const usage_percent_f64 = @as(f64, @floatFromInt(used)) / @as(f64, @floatFromInt(total)) * 100.0;
    const usage_percent = @as(u8, @intFromFloat(usage_percent_f64));

    try stdout.print(" <span color='{s}'> {:>1}% </span>\n ", .{ getColor(usage_percent), usage_percent });
}

fn readMemInfoValue(content: []const u8, key: []const u8) ?u64 {
    var lines = std.mem.splitAny(u8, content, "\n");
    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, key)) {
            var tokens = std.mem.tokenizeAny(u8, line, " ");
            _ = tokens.next(); // skip key itself
            const value_str = tokens.next() orelse return null;
            return std.fmt.parseInt(u64, value_str, 10) catch null;
        }
    }
    return null;
}

fn getColor(percent: u8) []const u8 {
    if (percent < 10) {
        return "#00FF00";
    } else if (percent < 25) {
        return "#bfff00";
    } else if (percent < 50) {
        return "#ffff00";
    } else if (percent < 60) {
        return "#ffbf00";
    } else if (percent < 70) {
        return "#ff8000";
    } else {
        return "#ff0000";
    }
}
