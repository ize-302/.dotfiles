const std = @import("std");
const process = std.process.chec;

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    //list out files with "::capslock"

    const path = "/sys/class/leds/input3::capslock/brightness";
    var file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    defer file.close(init.io);

    var buffer: [2]u8 = undefined;
    var bytes_read = std.Io.File.reader(file, init.io, &buffer);

    var content_buffer: [2048]u8 = undefined;
    const bytes_read_size = try bytes_read.interface.readSliceShort(&content_buffer);
    const content = content_buffer[0..bytes_read_size];

    if (content[0] == 49) {
        try stdout.print(" <span color='#ff5555'> ON</span> \n", .{});
    }

    try stdout.flush();
}
