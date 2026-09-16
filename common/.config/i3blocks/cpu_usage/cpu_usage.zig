const std = @import("std");

const CpuTimes = struct {
    user: u64,
    nice: u64,
    system: u64,
    idle: u64,
    iowait: u64,
    irq: u64,
    softirq: u64,
    steal: u64,
    guest: u64,
    guest_nice: u64,

    pub fn total(self: CpuTimes) u64 {
        return self.user + self.nice + self.system + self.idle +
            self.iowait + self.irq + self.softirq + self.steal +
            self.guest + self.guest_nice;
    }

    pub fn active(self: CpuTimes) u64 {
        return self.total() - self.idle;
    }
};

fn readCpuTimes(init: std.process.Init) !CpuTimes {
    const path = "/proc/stat";
    var file = try std.Io.Dir.openFileAbsolute(init.io, path, .{});
    defer file.close(init.io);

    var buffer: [256]u8 = undefined;
    var bytes_read = std.Io.File.reader(file, init.io, &buffer);

    var content_buffer: [2048]u8 = undefined;
    const bytes_read_size = try bytes_read.interface.readSliceShort(&content_buffer);
    const content = content_buffer[0..bytes_read_size];

    var lines = std.mem.splitAny(u8, content, "\n");

    const cpu_line = lines.next() orelse return error.MissingCpuLine;

    if (!std.mem.startsWith(u8, cpu_line, "cpu ")) {
        return error.UnexpectedFormat;
    }

    var it = std.mem.tokenizeAny(u8, cpu_line[4..], " ");
    const parse = std.fmt.parseInt;

    return CpuTimes{
        .user = try parse(u64, it.next() orelse return error.Parse, 10),
        .nice = try parse(u64, it.next() orelse return error.Parse, 10),
        .system = try parse(u64, it.next() orelse return error.Parse, 10),
        .idle = try parse(u64, it.next() orelse return error.Parse, 10),
        .iowait = try parse(u64, it.next() orelse return error.Parse, 10),
        .irq = try parse(u64, it.next() orelse return error.Parse, 10),
        .softirq = try parse(u64, it.next() orelse return error.Parse, 10),
        .steal = try parse(u64, it.next() orelse return error.Parse, 10),
        .guest = try parse(u64, it.next() orelse return error.Parse, 10),
        .guest_nice = try parse(u64, it.next() orelse return error.Parse, 10),
    };
}

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const cpu1 = try readCpuTimes(init);
    try std.Io.sleep(init.io, std.Io.Duration{ .nanoseconds = 500 * std.time.ns_per_ms }, .awake); // 500ms

    const cpu2 = try readCpuTimes(init);

    const delta_total = cpu2.total() - cpu1.total();
    const delta_active = cpu2.active() - cpu1.active();

    const usage_percent_f64 = @as(f64, @floatFromInt(delta_active)) / @as(f64, @floatFromInt(delta_total)) * 100.0;
    const usage_percent = @as(u8, @intFromFloat(usage_percent_f64));

    try stdout.print(" <span color='{s}'> {:.2}%</span> \n", .{ getColor(usage_percent), usage_percent });
    try stdout.flush();
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
