const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const brighPath = "/sys/class/backlight/intel_backlight/actual_brightness";
    const maxBrighPath = "/sys/class/backlight/intel_backlight/max_brightness";

    const brightness = try readFile(brighPath) * 100;
    const maxBrightness = try readFile(maxBrighPath);

    const brightness_perc = brightness / maxBrightness;

    try stdout.print(" <span color='orange'>☀️{:>1}%</span> \n ", .{brightness_perc});
}

fn readFile(path: []const u8) !u64 {
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [16]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    const trimmed = std.mem.trim(u8, content, "\n");
    return std.fmt.parseInt(u64, trimmed, 10);
}
