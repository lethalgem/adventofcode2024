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
    // std.debug.print("instructions: {?c} \n\n", .{instruction_set});
    var lines = std.mem.splitScalar(u8, instruction_set.?, '\n');
    while (lines.next()) |line| {
        var num_pair = std.mem.splitScalar(u8, line, '|');

        const first_num = try std.fmt.parseInt(u32, num_pair.first(), 10);
        const second_num = try std.fmt.parseInt(u32, num_pair.next().?, 10);

        if (instruction_manual.get(first_num) != null) {
            var existing_second_nums = instruction_manual.get(first_num).?;
            try existing_second_nums.append(second_num);
            try instruction_manual.put(first_num, existing_second_nums);
        } else {
            try instruction_manual.put(first_num, ArrayList(u32).init(allocator));
        }
    }

    // // print instruction manual if needed
    // var manual_iter = instruction_manual.keyIterator();
    // while (manual_iter.next()) |first_num| {
    //     std.debug.print("second_nums: {d}\n", .{instruction_manual.get(first_num.*).?.items});
    // }

    // parse through updates
    const update_set = sections.next();
    // std.debug.print("updates: {?c} \n\n", .{update_set});
    var update_lines = std.mem.splitScalar(u8, update_set.?, '\n');
    while (update_lines.next()) |line| {
        var invalid_line = false;

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
                    }
                }
            }
        }

        // if line is valid, get the middle number for the sum
        if (invalid_line) {
            std.debug.print("invalid line found: {any}\n", .{update_nums.items});
        } else {
            std.debug.print("valid line found: {any}\n", .{update_nums.items});
            const index = (update_nums.items.len - 1) / 2;
            const middle_num = update_nums.items[index];
            sum += middle_num;
        }
    }

    return sum;
}

test "simple test" {
    const sum = try get_sum("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 143), sum);
}
