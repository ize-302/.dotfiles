const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const path = "/sys/class/thermal/thermal_zone0/temp";
    var file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    defer file.close(init.io);

    var read_buffer: [64]u8 = undefined;
    var bytes_read = std.Io.File.reader(file, init.io, &read_buffer);

    var content_buffer: [2048]u8 = undefined;
    const bytes_read_size = try bytes_read.interface.readSliceShort(&content_buffer);
    const content = content_buffer[0..bytes_read_size];
    const trimmed = std.mem.trim(u8, content, "\n");

    const trimmed_to_int = try std.fmt.parseInt(u64, trimmed, 10);
    const result: u64 = trimmed_to_int / 1000;
    const temp_percentage: u8 = @intCast(result);

    try stdout.print(" <span color='{s}'>{s} {:>1}ºC </span>\n ", .{ getColor(temp_percentage), getIcon(temp_percentage), temp_percentage });
    try stdout.flush();
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
