const std = @import("std");

const nanpa = @import("nanpa");

pub fn main() !void {
    const raw_writer = std.io.getStdErr().writer();

    var buffered_writer = std.io.bufferedWriter(raw_writer);
    const writer = buffered_writer.writer();

    for (0..1001) |i| {
        try std.fmt.format(writer, "{d}: ", .{i});
        try nanpa.stringify(i, writer, .{});
        try writer.writeByte(' ');
        try nanpa.stringifyRoman(i, writer);
        try writer.writeByte('\n');
    }

    try buffered_writer.flush();
}
