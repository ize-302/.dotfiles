const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    var fba_buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&fba_buffer);
    const allocator = fba.allocator();

    const volumeLevel = try getVolumeLevel(allocator, init);
    const isMute = volumeLevel.is_muted;
    const color = try getColor(isMute);
    const icon = try getIcon(isMute, volumeLevel.percent);

    try stdout.print(" <span color='{s}'>{s}{d}% </span>\n ", .{ color, icon, volumeLevel.percent });
    try stdout.flush();
}

fn getVolumeLevel(allocator: std.mem.Allocator, init: std.process.Init) !struct { percent: u8, is_muted: bool } {
    const result = try std.process.run(allocator, init.io, .{
        .argv = &[_][]const u8{
            "wpctl",
            "get-volume",
            "@DEFAULT_AUDIO_SINK@",
        },
    });
    defer allocator.free(result.stdout);

    const output = std.mem.trim(u8, result.stdout, " \n");

    // Expected: "Volume: 0.42" or "Volume: 0.42 [MUTED]"
    var it = std.mem.tokenizeAny(u8, output, " ");

    _ = it.next(); // "Volume:"
    const vol_str = it.next() orelse return error.ParseError;
    const volume = try std.fmt.parseFloat(f32, vol_str);

    const is_muted = std.mem.containsAtLeast(u8, output, 1, "MUTED");
    const percent: u8 = @intFromFloat(volume * 100.0);

    return .{ .percent = percent, .is_muted = is_muted };
}

fn getIcon(isMute: bool, vol: u8) ![]const u8 {
    if (isMute) {
        return " ";
    } else {
        if (vol > 50) {
            return "  ";
        } else if (vol <= 50) {
            return " ";
        }
    }
    return undefined;
}

fn getColor(isMute: bool) ![]const u8 {
    if (isMute) return "#808080" else return "#ffffff";
}
