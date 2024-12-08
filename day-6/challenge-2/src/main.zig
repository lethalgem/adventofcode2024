const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const inf_loops = try get_total_inf_loops("./input.txt");
    std.debug.print("there can be {d} placed barriers to create infinite loops", .{inf_loops});

    std.debug.print("time elapsed nanoseconds: {d}", .{timer.read()});
}

const Coord = struct {
    x: usize,
    y: usize,
};

const VisitedCoord = struct {
    y: usize,
    direction: Direction,
};

const Direction = enum { north, east, south, west };

fn get_total_inf_loops(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator); // was getting a seg fault with the general allocator, probably should pay attention to it, but eh
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var visited_coords = std.AutoHashMap(usize, ArrayList(usize)).init(allocator); // x, y's
    defer _ = visited_coords.deinit();

    var barrier_locations = std.AutoHashMap(usize, ArrayList(usize)).init(allocator); // x, y's
    defer _ = barrier_locations.deinit();

    var max_coord: ?Coord = null;

    var starting_guard_location: ?Coord = null;

    var current_guard_location: ?Coord = null;

    // get starting location, location of all barriers (turn points), and bounds
    var rows = std.mem.splitScalar(u8, input, '\n');
    var y: usize = 0;
    while (rows.next()) |row| : (y += 1) {
        for (row, 0..) |col, x| {
            if (col == '^') {
                starting_guard_location = Coord{ .x = x, .y = y };
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

            if (x == starting_guard_location.?.x and c_y == starting_guard_location.?.y) {
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
    current_guard_location = starting_guard_location;
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

    // print the path taken by the guard
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

    // try a barrier at each position the guard traveled previously
    // if the guard travels the same spot in the same direction, then it is an infinite loop
    var total_spots: u32 = 0;
    var newly_visited_coords = std.AutoHashMap(usize, ArrayList(VisitedCoord)).init(allocator);
    var visited_coords_iter = visited_coords.keyIterator();
    var debug_count: u32 = 0;
    var new_barrier = false;
    while (visited_coords_iter.next()) |visited_x_loc| {
        const visited_y_locs = visited_coords.get(visited_x_loc.*);
        // std.debug.print("visited y locations for x of {d} are {d}\n", .{ visited_x_loc.*, visited_y_locs.?.items });

        // the guard may have traveled to the same place before. We need to make sure the list is only unique spots
        // no sets in zig, so just using a HashMap with null values
        var unique_visited_y_locs = std.AutoHashMap(usize, ?usize).init(allocator);
        defer _ = unique_visited_y_locs.deinit();
        for (visited_y_locs.?.items) |visited_y_loc| {
            try unique_visited_y_locs.put(visited_y_loc, null);
        }

        var unique_visited_y_locs_iter = unique_visited_y_locs.keyIterator();
        while (unique_visited_y_locs_iter.next()) |unique_visited_y_loc| {
            const visited_y_loc = unique_visited_y_loc.*;

            // place a barrier there if it's not the starting point
            if (starting_guard_location.?.x == visited_x_loc.* and starting_guard_location.?.y == visited_y_loc) {
                // std.debug.print("Not placing a barrier because it is the starting location x: {d}, y {d}\n", .{ visited_x_loc.*, visited_y_loc });
                continue;
            } else {
                if (barrier_locations.get(visited_x_loc.*) == null) {
                    try barrier_locations.put(visited_x_loc.*, ArrayList(usize).init(allocator));
                }

                var barrier_y_coords = barrier_locations.get(visited_x_loc.*).?;
                try barrier_y_coords.append(visited_y_loc);
                try barrier_locations.put(visited_x_loc.*, barrier_y_coords);

                // std.debug.print("Placing barrier at x: {d}, y: {d}\n", .{ visited_x_loc.*, visited_y_loc });
                new_barrier = true;
            }

            // see what happens
            is_patrolling = true;
            current_direction = Direction.north;
            current_guard_location = starting_guard_location;
            var inf_loop = false;
            var should_print_path = false;
            if (visited_x_loc.* == 3 and visited_y_loc == 6) {
                should_print_path = true;
            }

            debug_count += 1;
            // std.debug.print("debug_count: {d}\n", .{debug_count});
            // std.debug.print("starting_location: {any}\n", .{current_guard_location});

            while (is_patrolling) {
                // check the next location the guard may move to
                var peek_location = current_guard_location.?;

                if ((peek_location.y == 0 and current_direction == Direction.north) or (peek_location.x == 0 and current_direction == Direction.west)) {
                    is_patrolling = false;
                    // std.debug.print("leaving the map up or left\n", .{});
                }

                if (is_patrolling) { // only update if we aren't going to leave the bounds
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
                }

                // see of the guard has left the map
                if (peek_location.x > max_coord.?.x or peek_location.y > max_coord.?.y) {
                    is_patrolling = false;
                    // std.debug.print("leaving the map\n", .{});
                }

                // see if we've been there before or not
                if (newly_visited_coords.get(peek_location.x) != null and is_patrolling) {
                    const visited_y_coords = newly_visited_coords.get(peek_location.x).?;
                    for (visited_y_coords.items) |visited_y_coord| {
                        if (peek_location.y == visited_y_coord.y and visited_y_coord.direction == current_direction) {
                            total_spots += 1;
                            is_patrolling = false;
                            inf_loop = true;
                            // std.debug.print("inf loop found\n", .{});

                            break;
                        }
                    }
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

                // if (should_print_path) {
                //     std.debug.print("current_guard_location: {any}\n", .{current_guard_location});
                //     std.debug.print("peek_location: {any}\n", .{peek_location});
                //     std.debug.print("barrier_in_front: {any}\n", .{barrier_in_front});
                // }

                // move
                if (!barrier_in_front) {
                    current_guard_location = peek_location;

                    if (newly_visited_coords.get(current_guard_location.?.x) == null) {
                        try newly_visited_coords.put(current_guard_location.?.x, ArrayList(VisitedCoord).init(allocator));
                    }
                    var visited_y_coords = newly_visited_coords.get(current_guard_location.?.x).?;
                    const newly_visited_coord = VisitedCoord{ .y = current_guard_location.?.y, .direction = current_direction };
                    try visited_y_coords.append(newly_visited_coord);
                    try newly_visited_coords.put(current_guard_location.?.x, visited_y_coords);
                }

                // reset where we've been for the next loop
                if (!is_patrolling) {
                    // // print the new path taken by the guard
                    // if (inf_loop) {
                    //     for (0..max_coord.?.y + 1) |c_y| {
                    //         for (0..max_coord.?.x + 1) |x| {
                    //             var printed = false;

                    //             const barrier_y_locs = barrier_locations.get(x);
                    //             if (barrier_y_locs != null) {
                    //                 for (barrier_y_locs.?.items) |barrier_y_loc| {
                    //                     if (visited_y_loc == c_y and x == visited_x_loc.*) {
                    //                         std.debug.print("0", .{});
                    //                         printed = true;
                    //                         break;
                    //                     }

                    //                     if (barrier_y_loc == c_y) {
                    //                         std.debug.print("#", .{});
                    //                         printed = true;
                    //                         break;
                    //                     }
                    //                 }
                    //             }

                    //             if (x == max_coord.?.x and c_y == max_coord.?.y) {
                    //                 std.debug.print("m", .{});
                    //                 printed = true;
                    //             }

                    //             const newly_visited_y_locs = newly_visited_coords.get(x);
                    //             if (newly_visited_y_locs != null) {
                    //                 for (newly_visited_y_locs.?.items) |newly_visited_y_loc| {
                    //                     if (newly_visited_y_loc.y == c_y) {
                    //                         std.debug.print("X", .{});
                    //                         printed = true;
                    //                         break;
                    //                     }
                    //                 }
                    //             }

                    //             if (!printed) {
                    //                 std.debug.print(".", .{});
                    //             }
                    //         }
                    //         std.debug.print("\n", .{});
                    //     }
                    //     inf_loop = false;
                    // }

                    newly_visited_coords.clearRetainingCapacity();
                }
            }

            // // print which barrier is being tested and nothing else
            // if (new_barrier) {
            //     for (0..max_coord.?.y + 1) |c_y| {
            //         for (0..max_coord.?.x + 1) |x| {
            //             var printed = false;

            //             if (visited_y_loc == c_y and x == visited_x_loc.*) {
            //                 std.debug.print("0", .{});
            //                 printed = true;
            //             }

            //             if (x == max_coord.?.x and c_y == max_coord.?.y) {
            //                 std.debug.print("m", .{});
            //                 printed = true;
            //             }

            //             if (!printed) {
            //                 std.debug.print(".", .{});
            //             }
            //         }
            //         std.debug.print("\n", .{});
            //     }
            //     std.debug.print("\n", .{});

            //     new_barrier = false;
            // }

            // remove the new barrier
            if (starting_guard_location.?.x == visited_x_loc.* and starting_guard_location.?.y == visited_y_loc) {
                // nothing, can't figure out why starting_guard_location.?.x != visited_x_loc.* and starting_guard_location.?.y != visited_y_loc
                // doesn't work for the negative case???
            } else {
                var barrier_y_coords = barrier_locations.get(visited_x_loc.*).?;
                // std.debug.print("Removing barrier at x: {d}, y: {d}\n", .{ visited_x_loc.*, barrier_y_coords.getLast() });

                _ = barrier_y_coords.pop();
                try barrier_locations.put(visited_x_loc.*, barrier_y_coords);
            }
        }
    }

    return total_spots;
}

test "simple test" {
    const inf_loops = try get_total_inf_loops("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 6), inf_loops);
}
