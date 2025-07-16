const std = @import("std");

const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    const path = "/proc/sys/kernel/osrelease";

    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [16]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];
    const trimmed = std.mem.trim(u8, content, "\n");

    try stdout.print(" <span color='#1793d1'> {s}</span> \n", .{trimmed});
}
