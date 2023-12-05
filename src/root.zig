const std = @import("std");
const testing = std.testing;

pub const StringifyOptions = struct {
    /// Whether or not to use `ali` instead of `ale`
    ali: bool = false,
};

pub fn stringifyRoman(num: anytype, writer: anytype) !void {
    var working = num;

    //If the number is 0, dont do anything
    if (num == 0) return;

    while (working >= 100) : (working -= 100) {
        try writer.writeByte('A');
    }

    while (working >= 20) : (working -= 20) {
        try writer.writeByte('M');
    }

    while (working >= 5) : (working -= 5) {
        try writer.writeByte('L');
    }

    while (working >= 2) : (working -= 2) {
        try writer.writeByte('T');
    }

    if (working == 1) {
        try writer.writeByte('W');
    }
}

pub fn parseRoman(comptime T: type, reader: anytype) !T {
    var sum: T = 0;

    while (blk: {
        break :blk reader.readByte() catch |err| {
            if (err == error.EndOfStream) break :blk null;

            return err;
        };
    }) |b| {
        switch (b) {
            'A' => sum += 100,
            'M' => sum += 20,
            'L' => sum += 5,
            'T' => sum += 2,
            'W' => sum += 1,
            else => return error.UnrecognizedCharacter,
        }
    }

    return sum;
}

test "wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 1), string.writer());

    try testing.expectEqualStrings("W", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 1), try parseRoman(usize, fbs.reader()));
}

test "tu roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 2), string.writer());

    try testing.expectEqualStrings("T", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 2), try parseRoman(usize, fbs.reader()));
}

test "tu wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 3), string.writer());

    try testing.expectEqualStrings("TW", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 3), try parseRoman(usize, fbs.reader()));
}

test "luka tu wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 8), string.writer());

    try testing.expectEqualStrings("LTW", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 8), try parseRoman(usize, fbs.reader()));
}

test "luka roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 5), string.writer());

    try testing.expectEqualStrings("L", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 5), try parseRoman(usize, fbs.reader()));
}

test "mute luka wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 26), string.writer());

    try testing.expectEqualStrings("MLW", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 26), try parseRoman(usize, fbs.reader()));
}

test "mute roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 20), string.writer());

    try testing.expectEqualStrings("M", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 20), try parseRoman(usize, fbs.reader()));
}

test "ale mute luka tu wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 128), string.writer());

    try testing.expectEqualStrings("AMLTW", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 128), try parseRoman(usize, fbs.reader()));
}

test "ale ale mute luka tu wan roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 228), string.writer());

    try testing.expectEqualStrings("AAMLTW", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 228), try parseRoman(usize, fbs.reader()));
}

test "ale roman" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringifyRoman(@as(usize, 100), string.writer());

    try testing.expectEqualStrings("A", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 100), try parseRoman(usize, fbs.reader()));
}

pub fn stringify(num: anytype, writer: anytype, options: StringifyOptions) !void {
    var working = num;

    //If the number is 0, only write ala and early-return
    if (num == 0) {
        try writer.writeAll("ala");
        return;
    }

    while (working >= 100) : (working -= 100) {
        try writer.writeAll(if (options.ali) "ali" else "ale");

        if (working != 100) try writer.writeByte(' ');
    }

    while (working >= 20) : (working -= 20) {
        try writer.writeAll("mute");

        if (working != 20) try writer.writeByte(' ');
    }

    while (working >= 5) : (working -= 5) {
        try writer.writeAll("luka");

        if (working != 5) try writer.writeByte(' ');
    }

    while (working >= 2) : (working -= 2) {
        try writer.writeAll("tu");

        if (working != 2) try writer.writeByte(' ');
    }

    if (working == 1) try writer.writeAll("wan");
}

pub fn parse(comptime T: type, reader: anytype) !T {
    var buf: [5]u8 = undefined;

    var ret: T = 0;
    while (try reader.readUntilDelimiterOrEof(&buf, ' ')) |token| {
        const trimmed_token = std.mem.trimRight(u8, token, " ");
        if (std.mem.eql(u8, trimmed_token, "ale") or std.mem.eql(u8, trimmed_token, "ali")) {
            ret += 100;
        } else if (std.mem.eql(u8, trimmed_token, "mute")) {
            ret += 20;
        } else if (std.mem.eql(u8, trimmed_token, "luka")) {
            ret += 5;
        } else if (std.mem.eql(u8, trimmed_token, "tu")) {
            ret += 2;
        } else if (std.mem.eql(u8, trimmed_token, "wan")) {
            ret += 1;
        } else {
            return error.InvalidWord;
        }
    }

    return ret;
}

test "wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 1), string.writer(), .{});

    try testing.expectEqualStrings("wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 1), try parse(usize, fbs.reader()));
}

test "tu" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 2), string.writer(), .{});

    try testing.expectEqualStrings("tu", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 2), try parse(usize, fbs.reader()));
}

test "tu wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 3), string.writer(), .{});

    try testing.expectEqualStrings("tu wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 3), try parse(usize, fbs.reader()));
}

test "luka tu wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 8), string.writer(), .{});

    try testing.expectEqualStrings("luka tu wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 8), try parse(usize, fbs.reader()));
}

test "luka" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 5), string.writer(), .{});

    try testing.expectEqualStrings("luka", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 5), try parse(usize, fbs.reader()));
}

test "mute luka wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 26), string.writer(), .{});

    try testing.expectEqualStrings("mute luka wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 26), try parse(usize, fbs.reader()));
}

test "mute" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 20), string.writer(), .{});

    try testing.expectEqualStrings("mute", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 20), try parse(usize, fbs.reader()));
}

test "ale mute luka tu wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 128), string.writer(), .{});

    try testing.expectEqualStrings("ale mute luka tu wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 128), try parse(usize, fbs.reader()));
}

test "ale ale mute luka tu wan" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 228), string.writer(), .{});

    try testing.expectEqualStrings("ale ale mute luka tu wan", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 228), try parse(usize, fbs.reader()));
}

test "ale" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 100), string.writer(), .{});

    try testing.expectEqualStrings("ale", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 100), try parse(usize, fbs.reader()));
}

test "ali" {
    var string = std.ArrayList(u8).init(testing.allocator);
    defer string.deinit();

    try stringify(@as(usize, 100), string.writer(), .{ .ali = true });

    try testing.expectEqualStrings("ali", string.items);

    var fbs = std.io.fixedBufferStream(string.items);
    try testing.expectEqual(@as(usize, 100), try parse(usize, fbs.reader()));
}
