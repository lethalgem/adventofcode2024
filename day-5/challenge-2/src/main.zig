const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const sum = try get_sum("./input.txt");
    std.debug.print("sum: {d}", .{sum});
}

fn get_sum(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator); // was getting a seg fault with the general allocator, probably should pay attention to it, but eh
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var instruction_manual = std.AutoHashMap(u32, ArrayList(u32)).init(allocator);
    defer _ = instruction_manual.deinit();

    var sum: u32 = 0;

    // separate instructions from update
    var sections = std.mem.splitSequence(u8, input, "\n\n");

    // stuff instructions into easy to use reference data structure
    const instruction_set = sections.next();
    var lines = std.mem.splitScalar(u8, instruction_set.?, '\n');
    while (lines.next()) |line| {
        var num_pair = std.mem.splitScalar(u8, line, '|');

        const first_num = try std.fmt.parseInt(u32, num_pair.first(), 10);
        const second_num = try std.fmt.parseInt(u32, num_pair.next().?, 10);

        if (instruction_manual.get(first_num) == null) {
            try instruction_manual.put(first_num, ArrayList(u32).init(allocator));
        }

        var existing_second_nums = instruction_manual.get(first_num).?;
        try existing_second_nums.append(second_num);
        try instruction_manual.put(first_num, existing_second_nums);
    }

    // print instruction manual if needed
    // var manual_iter = instruction_manual.keyIterator();
    // while (manual_iter.next()) |first_num| {
    //     std.debug.print("second_nums: {d}\n", .{instruction_manual.get(first_num.*).?.items});
    // }

    // parse through updates
    const update_set = sections.next();
    var update_lines = std.mem.splitScalar(u8, update_set.?, '\n');
    while (update_lines.next()) |line| {
        var invalid_line = false;
        var invalid_num: ?u32 = null;

        // store nums on the line in an array
        var update_nums = ArrayList(u32).init(allocator);
        var nums = std.mem.splitScalar(u8, line, ',');
        while (nums.next()) |num| {
            const parsed_num = try std.fmt.parseInt(u32, num, 10);
            try update_nums.append(parsed_num);
        }

        // analyze the line
        // have a line like 75,47,61,53,29
        // rules are key before any values that may be in the line
        for (update_nums.items, 0..) |num, index| {
            const numbers_that_must_come_after = instruction_manual.get(num);
            if (numbers_that_must_come_after == null) {
                continue;
            }

            // look through list before this num and see if any are in banned number list
            for (0..index) |i| {
                for (numbers_that_must_come_after.?.items) |banned_num| {
                    if (banned_num == update_nums.items[i]) {
                        invalid_line = true;
                        invalid_num = num;
                        // std.debug.print("analyzed and found invalid with banned_number: {d} in front of: {d}\n", .{ banned_num, num });
                    }
                }
            }
        }

        // if line is valid, get the middle number for the sum
        if (invalid_line) {
            std.debug.print("invalid line found (that's a good thing): {any}\n", .{update_nums.items});

            var counter: u32 = 0;
            var new_num_list = update_nums.items;
            while (invalid_line) {
                // reorder properly, could do it above too instead
                const old_index = std.mem.indexOf(u32, new_num_list, &[_]u32{invalid_num.?}).?;
                const num_to_be_swapped = new_num_list[old_index - 1];
                new_num_list[old_index - 1] = new_num_list[old_index];
                new_num_list[old_index] = num_to_be_swapped;
                std.debug.print("new line is now: {any}\n", .{new_num_list});

                // check for validity, repeat until valid
                invalid_line = false;
                invalid_num = null;
                for (new_num_list, 0..) |num, index| {
                    const numbers_that_must_come_after = instruction_manual.get(num);
                    if (numbers_that_must_come_after == null) {
                        continue;
                    }

                    // look through list before this num and see if any are in banned number list
                    for (0..index) |i| {
                        for (numbers_that_must_come_after.?.items) |banned_num| {
                            if (banned_num == new_num_list[i]) {
                                // std.debug.print("reanalyzed and found invalid\n", .{});
                                invalid_line = true;
                                invalid_num = num;
                            }

                            // break out so that we always move the first invalid num forward and don't end up in an endless loop
                            // where the last invalid num just swaps places with the one in front of it
                            if (invalid_line) {
                                break;
                            }
                        }
                        if (invalid_line) {
                            break;
                        }
                    }
                    if (invalid_line) {
                        break;
                    }
                }

                // if ever not valid, we should crash
                counter += 1;
                if (counter > 10000) {
                    std.debug.print("exceeded loop counter, giving up\n", .{});
                    invalid_line = false;
                }
            }
            // std.debug.print("reanalyzed and found valid\n", .{});

            const index = (new_num_list.len - 1) / 2;
            const middle_num = new_num_list[index];
            sum += middle_num;
        } else {
            // std.debug.print("valid line found: {any}\n", .{update_nums.items});
        }
    }

    return sum;
}

test "simple test" {
    const sum = try get_sum("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 123), sum);
}
