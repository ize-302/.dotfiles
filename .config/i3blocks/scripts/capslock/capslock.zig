const std = @import("std");
const process = std.process.chec;

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const path = "/sys/class/leds/input7::capslock/brightness";
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    var buffer: [2]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const content = buffer[0..bytes_read];

    if (content[0] == 49) {
        try stdout.print(" <span color='#FF0000'>⇪ locked</span> \n", .{});
        try stdout.flush();
    }
}
