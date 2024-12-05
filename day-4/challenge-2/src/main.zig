const std = @import("std");
const ArrayList = std.ArrayList;

// 1. create a 2d array of x, y for each character
// 2. iterate through each location
// 3. on each iteration look at all possible angles for the xmas to appear
// 4. reuse the struct from yesterday

pub fn main() !void {
    const instances = try get_instances("./input.txt");
    std.debug.print("XMAS appears {d} times", .{instances});
}

fn get_instances(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator); // was getting a seg fault with the general allocator, probably should pay attention to it, but eh
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var count: u32 = 0;
    var rows = ArrayList(ArrayList(u8)).init(allocator);
    defer _ = rows.deinit();

    var debug_coords = ArrayList(Coords).init(allocator);
    defer _ = debug_coords.deinit();

    // store grid
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var values = ArrayList(u8).init(allocator);

        for (line) |char| {
            values.append(char) catch |err| {
                std.debug.print("{any}", .{err});
            };
        }
        rows.append(values) catch |err| {
            std.debug.print("{any}", .{err});
        };
        // std.debug.print("{any}\n", .{row.values.items.len});
    }
    // std.debug.print("{any}\n", .{rows.items});

    // start looking for xmas
    for (rows.items, 0..) |row, y| {
        std.debug.print("{c} \n", .{row.items});
        for (row.items, 0..) |value, x| {

            // search corners around A
            if (value == 'A') {
                try debug_coords.append(Coords{ .x = x, .y = y });

                // determine we will be within bounds
                if (x + 1 > rows.items.len - 1 or y + 1 > row.items.len - 1 or x == 0 or y == 0) {
                    continue;
                }

                // search for
                // M.S
                // .A.
                // M.S
                if (rows.items[y - 1].items[x - 1] == 'M' and
                    rows.items[y - 1].items[x + 1] == 'S' and
                    rows.items[y + 1].items[x - 1] == 'M' and rows.items[y + 1].items[x + 1] == 'S')
                {
                    count += 1;
                    try debug_coords.append(Coords{ .x = x, .y = y });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y + 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y + 1 });
                }

                // search for
                // S.S
                // .A.
                // M.M
                if (rows.items[y - 1].items[x - 1] == 'S' and
                    rows.items[y - 1].items[x + 1] == 'S' and
                    rows.items[y + 1].items[x - 1] == 'M' and rows.items[y + 1].items[x + 1] == 'M')
                {
                    count += 1;
                    try debug_coords.append(Coords{ .x = x, .y = y });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y + 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y + 1 });
                }

                // search for
                // S.M
                // .A.
                // S.M
                if (rows.items[y - 1].items[x - 1] == 'S' and
                    rows.items[y - 1].items[x + 1] == 'M' and
                    rows.items[y + 1].items[x - 1] == 'S' and rows.items[y + 1].items[x + 1] == 'M')
                {
                    count += 1;
                    try debug_coords.append(Coords{ .x = x, .y = y });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y + 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y + 1 });
                }

                // search for
                // M.M
                // .A.
                // S.S
                if (rows.items[y - 1].items[x - 1] == 'M' and
                    rows.items[y - 1].items[x + 1] == 'M' and
                    rows.items[y + 1].items[x - 1] == 'S' and rows.items[y + 1].items[x + 1] == 'S')
                {
                    count += 1;
                    try debug_coords.append(Coords{ .x = x, .y = y });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x - 1, .y = y + 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y - 1 });
                    try debug_coords.append(Coords{ .x = x + 1, .y = y + 1 });
                }
            }
        }
    }

    // create debug grid to print
    var debug_chars = ArrayList(ArrayList(u8)).init(allocator);
    defer _ = debug_chars.deinit();

    for (rows.items) |row| {
        var dots = ArrayList(u8).init(allocator);
        for (row.items) |_| {
            try dots.append('.');
        }
        try debug_chars.append(dots);
    }

    // replace with found coords
    for (debug_coords.items) |coord| {
        debug_chars.items[coord.y].items[coord.x] = rows.items[coord.y].items[coord.x];
    }

    // print debug locations
    for (debug_chars.items) |line| {
        for (line.items) |char| {
            std.debug.print("{c}", .{char});
        }
        std.debug.print("\n", .{});
    }

    rows.deinit();
    debug_coords.deinit();
    debug_chars.deinit();

    return count;
}

const Coords = struct {
    x: usize,
    y: usize,
};

test "simple test" {
    const instances = try get_instances("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 9), instances);
}

test "simple test 2" {
    const instances = try get_instances("./test_input_2.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}

test "simple test 3" {
    const instances = try get_instances("./test_input_3.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}
test "simple test 4" {
    const instances = try get_instances("./test_input_4.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}
test "simple test 5" {
    const instances = try get_instances("./test_input_5.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}
