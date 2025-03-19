#!/usr/bin/env zig

const std = @import("std");

pub fn main() void {
	const message = "Ize";
	std.debug.print("{}\n", .{message});
}
