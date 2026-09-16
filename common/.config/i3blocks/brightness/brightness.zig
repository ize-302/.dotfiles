const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const brighPath = "/sys/class/backlight/intel_backlight/actual_brightness";
    const maxBrighPath = "/sys/class/backlight/intel_backlight/max_brightness";

    const brightness = try readFile(brighPath, init) * 100;
    const maxBrightness = try readFile(maxBrighPath, init);

    const brightness_perc = brightness / maxBrightness;

    try stdout.print(" <span color='orange'>☀️{:>1}%</span> \n ", .{brightness_perc});
    try stdout.flush();
}

fn readFile(path: []const u8, init: std.process.Init) !u64 {
    var file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    defer file.close(init.io);

    var buffer: [16]u8 = undefined;
    var bytes_read = std.Io.File.reader(file, init.io, &buffer);

    var content_buffer: [2048]u8 = undefined;
    const bytes_read_size = try bytes_read.interface.readSliceShort(&content_buffer);
    const content = content_buffer[0..bytes_read_size];

    const trimmed = std.mem.trim(u8, content, "\n");
    return std.fmt.parseInt(u64, trimmed, 10);
}
