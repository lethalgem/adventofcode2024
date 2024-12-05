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
    var xmas = Xmas{ .x = false, .m = false, .a = false, .s = false };
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
    for (rows.items, 0..) |row, i| {
        std.debug.print("{c} \n", .{row.items});
        for (row.items, 0..) |_, j| {
            var temp_debug_coords = ArrayList(Coords).init(allocator);
            defer _ = temp_debug_coords.deinit();

            // search forward
            for (0..4) |x| {
                if (j + x > row.items.len - 1) {
                    xmas.reset();
                    break;
                }
                // std.debug.print("looking at char: {c}\n", .{row.items[j + x]});
                const search_results = xmas.look_for_next_char(row.items[j + x]);
                if (search_results.xmas_found) {
                    // std.debug.print("found xmas \n", .{});
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    // std.debug.print("restarting the search \n", .{});
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i });
                }
                // std.debug.print("found a char we're looking for \n", .{});
            }

            // search backward
            for (0..4) |x| {
                if (x > j) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(row.items[j - x]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i });
                }
            }

            // search up
            for (0..4) |y| {
                if (y > i) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i - y].items[j]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j, .y = i - y });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j, .y = i - y });
                }
            }

            // search down
            for (0..4) |y| {
                if (i + y > rows.items.len - 1) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i + y].items[j]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j, .y = i + y });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j, .y = i + y });
                }
            }

            // search forward down
            for (0..4) |x| {
                if (j + x > row.items.len - 1 or i + x > rows.items.len - 1) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i + x].items[j + x]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i + x });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i + x });
                }
            }

            // search forward up
            for (0..4) |x| {
                if (j + x > row.items.len - 1 or x > i) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i - x].items[j + x]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i - x });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j + x, .y = i - x });
                }
            }

            // search backward down
            for (0..4) |x| {
                if (x > j or i + x > rows.items.len - 1) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i + x].items[j - x]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i + x });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i + x });
                }
            }

            // search backward up
            for (0..4) |x| {
                if (x > j or x > i) {
                    xmas.reset();
                    break;
                }
                const search_results = xmas.look_for_next_char(rows.items[i - x].items[j - x]);
                if (search_results.xmas_found) {
                    count += 1;
                    xmas.reset();
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i - x });
                    try debug_coords.appendSlice(temp_debug_coords.items);
                } else if (!search_results.char_found) {
                    temp_debug_coords.deinit();
                    temp_debug_coords = ArrayList(Coords).init(allocator);
                    break;
                } else {
                    try temp_debug_coords.append(Coords{ .x = j - x, .y = i - x });
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

// each bool represents whether we've seen it or not
const Xmas = struct {
    x: bool,
    m: bool,
    a: bool,
    s: bool,

    // consume token to create command, return whether or not command is complete
    fn look_for_next_char(self: *Xmas, char: u8) struct { char_found: bool, xmas_found: bool } {
        var found_char = false;

        if (char == 'X' and self.x) {
            self.reset();
            found_char = false;
        } else if (char == 'X' and !self.x) {
            self.reset();
            self.x = true;
            found_char = true;
        } else if (self.x and char == 'M' and !self.m) {
            self.m = true;
            found_char = true;
        } else if (self.m and char == 'A' and !self.a) {
            self.a = true;
            found_char = true;
        } else if (self.a and char == 'S' and !self.s) {
            self.s = true;
            found_char = true;
        } else {
            self.reset();
        }

        return .{ .char_found = found_char, .xmas_found = self.s };
    }

    fn reset(self: *Xmas) void {
        self.x = false;
        self.m = false;
        self.a = false;
        self.s = false;
    }
};

test "simple test" {
    const instances = try get_instances("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 18), instances);
}

test "simple test 2" {
    const instances = try get_instances("./test_input_2.txt");
    try std.testing.expectEqual(@as(u32, 5), instances);
}

test "simple test forward" {
    const instances = try get_instances("./test_input_forward.txt");
    try std.testing.expectEqual(@as(u32, 4), instances);
}

test "simple test backward" {
    const instances = try get_instances("./test_input_backward.txt");
    try std.testing.expectEqual(@as(u32, 4), instances);
}

test "simple test up" {
    const instances = try get_instances("./test_input_up.txt");
    try std.testing.expectEqual(@as(u32, 2), instances);
}

test "simple test down" {
    const instances = try get_instances("./test_input_down.txt");
    try std.testing.expectEqual(@as(u32, 2), instances);
}

test "simple test forward down" {
    const instances = try get_instances("./test_input_forward_down.txt");
    try std.testing.expectEqual(@as(u32, 3), instances);
}

test "simple test forward up" {
    const instances = try get_instances("./test_input_forward_up.txt");
    try std.testing.expectEqual(@as(u32, 3), instances);
}

test "simple test backward down" {
    const instances = try get_instances("./test_input_backward_down.txt");
    try std.testing.expectEqual(@as(u32, 3), instances);
}
test "simple test backward up" {
    const instances = try get_instances("./test_input_backward_up.txt");
    try std.testing.expectEqual(@as(u32, 3), instances);
}

test "simple test up 2" {
    const instances = try get_instances("./test_input_up_2.txt");
    try std.testing.expectEqual(@as(u32, 2), instances);
}

test "simple test forward 2" {
    const instances = try get_instances("./test_input_forward_2.txt");
    try std.testing.expectEqual(@as(u32, 3), instances);
}

test "simple test backward 2" {
    const instances = try get_instances("./test_input_backward_2.txt");
    try std.testing.expectEqual(@as(u32, 2), instances);
}

test "simple test down 2" {
    const instances = try get_instances("./test_input_down_2.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}

test "simple test forward down 2" {
    const instances = try get_instances("./test_input_forward_down_2.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}

test "simple test backward down 2" {
    const instances = try get_instances("./test_input_backward_down_2.txt");
    try std.testing.expectEqual(@as(u32, 1), instances);
}

test "simple test backward up 2" {
    const instances = try get_instances("./test_input_backward_up_2.txt");
    try std.testing.expectEqual(@as(u32, 4), instances);
}

test "simple test forward up 2" {
    const instances = try get_instances("./test_input_forward_up_2.txt");
    try std.testing.expectEqual(@as(u32, 4), instances);
}

test "simple test spiral" {
    const instances = try get_instances("./test_input_spiral.txt");
    try std.testing.expectEqual(@as(u32, 8), instances);
}

test "simple test spiral 2" {
    const instances = try get_instances("./test_input_spiral_2.txt");
    try std.testing.expectEqual(@as(u32, 8), instances);
}
