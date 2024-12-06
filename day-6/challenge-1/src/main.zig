const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const positions = try get_total_positions("./input.txt");
    std.debug.print("the guard visited a distinct total of {d} positions", .{positions});
}

const Coord = struct {
    x: usize,
    y: usize,
};

const Direction = enum { north, east, south, west };

fn get_total_positions(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator); // was getting a seg fault with the general allocator, probably should pay attention to it, but eh
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var visited_coords = std.AutoHashMap(usize, ArrayList(usize)).init(allocator); // x, y's
    defer _ = visited_coords.deinit();

    var barrier_locations = std.AutoHashMap(usize, ArrayList(usize)).init(allocator); // x, y's
    defer _ = barrier_locations.deinit();

    var max_coord: ?Coord = null;

    var current_guard_location: ?Coord = null;

    // get starting location, location of all barriers (turn points), and bounds
    var rows = std.mem.splitScalar(u8, input, '\n');
    var y: usize = 0;
    while (rows.next()) |row| : (y += 1) {
        for (row, 0..) |col, x| {
            if (col == '^') {
                current_guard_location = Coord{ .x = x, .y = y };
                try visited_coords.put(x, ArrayList(usize).init(allocator));
                var y_coords = visited_coords.get(x).?;
                try y_coords.append(y);
                try visited_coords.put(x, y_coords);
            } else if (col == '#') {
                if (barrier_locations.get(x) == null) {
                    try barrier_locations.put(x, ArrayList(usize).init(allocator));
                }

                var y_coords = barrier_locations.get(x).?;
                try y_coords.append(y);
                try barrier_locations.put(x, y_coords);
            }
            max_coord = Coord{ .x = x, .y = y }; // Reassigning every iteration is dumb, but also.... lol
        }
    }

    // print barrier_locations, max_coord and starting location to confirm
    for (0..max_coord.?.y + 1) |c_y| {
        for (0..max_coord.?.x + 1) |x| {
            var printed = false;

            const barrier_y_locs = barrier_locations.get(x);
            if (barrier_y_locs != null) {
                for (barrier_y_locs.?.items) |barrier_y_loc| {
                    if (barrier_y_loc == c_y) {
                        std.debug.print("#", .{});
                        printed = true;
                        break;
                    }
                }
            }

            if (x == current_guard_location.?.x and c_y == current_guard_location.?.y) {
                std.debug.print("^", .{});
                printed = true;
            }

            if (x == max_coord.?.x and c_y == max_coord.?.y) {
                std.debug.print("m", .{});
                printed = true;
            }

            if (!printed) {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    // follow the leader
    var is_patrolling = true;
    var current_direction: Direction = Direction.north;
    while (is_patrolling) {
        // see if we're leaving the bounds
        var peek_location = current_guard_location.?;

        switch (current_direction) {
            Direction.north => {
                peek_location.y = peek_location.y - 1;
            },
            Direction.east => {
                peek_location.x = peek_location.x + 1;
            },
            Direction.south => {
                peek_location.y = peek_location.y + 1;
            },
            Direction.west => {
                peek_location.x = peek_location.x - 1;
            },
        }

        // see of the guard has left the map
        if (peek_location.x > max_coord.?.x or peek_location.y > max_coord.?.y) {
            is_patrolling = false;
        }

        // see if there is a barrier
        var barrier_in_front = false;
        const y_coords = barrier_locations.get(peek_location.x);
        if (y_coords != null) {
            for (y_coords.?.items) |barrier_y| {
                if (peek_location.y == barrier_y) {
                    // time to turn
                    barrier_in_front = true;

                    switch (current_direction) {
                        Direction.north => {
                            current_direction = Direction.east;
                        },
                        Direction.east => {
                            current_direction = Direction.south;
                        },
                        Direction.south => {
                            current_direction = Direction.west;
                        },
                        Direction.west => {
                            current_direction = Direction.north;
                        },
                    }
                }
            }
        }

        // move
        if (!barrier_in_front) {
            current_guard_location = peek_location;

            if (visited_coords.get(current_guard_location.?.x) == null) {
                try visited_coords.put(current_guard_location.?.x, ArrayList(usize).init(allocator));
            }
            var visited_y_coords = visited_coords.get(current_guard_location.?.x).?;
            try visited_y_coords.append(current_guard_location.?.y);
            try visited_coords.put(current_guard_location.?.x, visited_y_coords);
        }
    }

    std.debug.print("\n----\n\n", .{});

    // print the path and count unique
    var total_unique: u32 = 0;
    for (0..max_coord.?.y + 1) |c_y| {
        for (0..max_coord.?.x + 1) |x| {
            var printed = false;

            const barrier_y_locs = barrier_locations.get(x);
            if (barrier_y_locs != null) {
                for (barrier_y_locs.?.items) |barrier_y_loc| {
                    if (barrier_y_loc == c_y) {
                        std.debug.print("#", .{});
                        printed = true;
                        break;
                    }
                }
            }

            if (x == max_coord.?.x and c_y == max_coord.?.y) {
                std.debug.print("m", .{});
                printed = true;
            }

            const visited_y_locs = visited_coords.get(x);
            if (visited_y_locs != null) {
                for (visited_y_locs.?.items) |visited_y_loc| {
                    if (visited_y_loc == c_y) {
                        std.debug.print("X", .{});
                        total_unique += 1;
                        printed = true;
                        break;
                    }
                }
            }

            if (!printed) {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    return total_unique;
}

test "simple test" {
    const positions = try get_total_positions("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 41), positions);
}
