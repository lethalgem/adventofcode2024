const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const calibration_result = try get_total_calibration_result("./test_input_solo.txt");
    std.debug.print("the calibration result is: {d}", .{calibration_result});
}

const Operator = enum { mul, div, add, sub };

fn get_total_calibration_result(comptime path: []const u8) !u64 {
    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator); // was getting a seg fault with the general allocator, probably should pay attention to it, but eh
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var equations = std.AutoHashMap(u64, ArrayList(u64)).init(allocator); // result, numbers //*crossed fingers* there are no dupes of results :/
    defer _ = equations.deinit();

    var calibration_result: u64 = 0;

    // get all equations into data structure for analysis
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var sections = std.mem.splitScalar(u8, line, ':');

        // get results
        const first_section = sections.first();
        const result = try std.fmt.parseInt(u64, first_section, 10);

        // get numbers
        var parsed_nums = ArrayList(u64).init(allocator);
        defer _ = parsed_nums.deinit();

        const second_section = sections.next().?;
        var numbers = std.mem.tokenizeScalar(u8, second_section, ' ');
        while (numbers.next()) |num| {
            const parsed_num = try std.fmt.parseInt(u64, num, 10);
            try parsed_nums.append(parsed_num);
        }

        if (equations.get(result) != null) {
            std.debug.print("we got a dup result, the jig is up batman", .{});
            break;
        }
        // try equations.put(result, parsed_nums);

        // analyze for possible operators
        const equation_numbers = parsed_nums;

        std.debug.print("parsed_nums: {d}\n ", .{equation_numbers.items});

        // loop over every operator, modifying one by one
        // ex. 1 + 1 + 1, then 1 + 1 - 1, then 1 + 1 / 1, etc
        const total_operator_positions = equation_numbers.items.len - 1; // 2 if [1, 1, 1]

        // create initial operators to be modified in place
        var operators = ArrayList(Operator).init(allocator);
        for (0..total_operator_positions) |_| {
            try operators.append(Operator.add);
        }

        std.debug.print("operators in before modification: {any}\n", .{operators.items});

        var operator_position: usize = total_operator_positions;
        while (operator_position > 0) {
            // update operator to test
            operator_position -= 1;
            for (0..4) |current_operator| {
                operators.items[operator_position] = @enumFromInt(current_operator);
                std.debug.print("operators in order: {any}\n", .{operators.items});

                // test operator, need to respect order of ops
                // create a copy of the equation and operators so we don't modify anything while calcing intermediate results
                var operator_list_state = operators;
                var equation_num_state = equation_numbers;
                var has_op = true;
                for (0..4) |desired_operator| {
                    while (has_op) {
                        std.debug.print("checking for the desired operator\n", .{});
                        for (operator_list_state.items, 0..) |op, op_index| {
                            const usize_op: usize = @intFromEnum(op);
                            std.debug.print("equation_num_state.items: {d}\n", .{equation_num_state.items});
                            std.debug.print("operator_list_state.items: {any}\n", .{operator_list_state.items});

                            // brute force remove any pointers to zero. Idk why they're there.
                            var had_zero_pointer = true;
                            while (had_zero_pointer) {
                                for (equation_num_state.items) |num| {
                                    if (num == 12297829382473034410) {
                                        _ = equation_num_state.orderedRemove(op_index + 1);
                                        had_zero_pointer = true;
                                        break;
                                    } else {
                                        had_zero_pointer = false;
                                    }
                                }
                            }
                            std.debug.print("equation_num_state.items after brute force remove: {d}\n", .{equation_num_state.items});

                            if (desired_operator == usize_op) {
                                var intermediate_result: ?u64 = null;
                                switch (op) {
                                    Operator.mul => {
                                        intermediate_result = equation_num_state.items[op_index] * equation_num_state.items[op_index + 1];
                                        std.debug.print("intermediate result {?d} found by {d} * {d}\n", .{ intermediate_result, equation_num_state.items[op_index], equation_num_state.items[op_index + 1] });
                                    },
                                    Operator.div => {
                                        intermediate_result = equation_num_state.items[op_index] / equation_num_state.items[op_index + 1];
                                        std.debug.print("intermediate result {?d} found by {d} / {d}\n", .{ intermediate_result, equation_num_state.items[op_index], equation_num_state.items[op_index + 1] });
                                    },
                                    Operator.add => {
                                        intermediate_result = equation_num_state.items[op_index] + equation_num_state.items[op_index + 1];
                                        std.debug.print("intermediate result {?d} found by {d} + {d}\n", .{ intermediate_result, equation_num_state.items[op_index], equation_num_state.items[op_index + 1] });
                                    },
                                    Operator.sub => {
                                        intermediate_result = equation_num_state.items[op_index] - equation_num_state.items[op_index + 1];
                                        std.debug.print("intermediate result {?d} found by {d} - {d}\n", .{ intermediate_result, equation_num_state.items[op_index], equation_num_state.items[op_index + 1] });
                                    },
                                }

                                // update state with the intermediate result
                                std.debug.print("equation_num_state.items before remove: {any}\n", .{equation_num_state.items});

                                _ = equation_num_state.orderedRemove(op_index + 1);
                                equation_num_state.items[op_index] = intermediate_result.?;
                                _ = operator_list_state.orderedRemove(op_index);

                                std.debug.print("equation_num_state.items after remove: {any}\n", .{equation_num_state.items});

                                break; // list has been updated, so we can't continue
                            }

                            if (op_index == operator_list_state.items.len - 1) {
                                std.debug.print("no more of this op in the list: {any}\n", .{op});
                                has_op = false; // move on to searching for the next op
                            }
                        }

                        if (operator_list_state.items.len == 0) {
                            std.debug.print("we've calced a final result to test against\n", .{});
                            has_op = false; // move on to searching for the next op
                            break;
                        }
                    }
                }

                std.debug.print("equation resulted in: {any}\n", .{equation_num_state.items[0]});

                if (result == equation_num_state.items[0]) {
                    calibration_result += result;
                    operator_position = 0;
                    break; // just one proper result to make the line count
                }
            }
        }
    }

    std.debug.print("\n------\n\n", .{});

    return calibration_result;
}

test "simple test" {
    const calibration_result = try get_total_calibration_result("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 3749), calibration_result);
}
