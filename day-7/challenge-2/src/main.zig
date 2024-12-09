const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const calibration_result = try get_total_calibration_result("./input.txt");
    std.debug.print("the calibration result is: {d}", .{calibration_result});
}

const Operator = enum { mul, add };

fn get_total_calibration_result(comptime path: []const u8) !u64 {
    var timer = try std.time.Timer.start();

    const input = @embedFile(path);

    var gpa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var equations = std.AutoHashMap(u64, ArrayList(u64)).init(allocator); // result, numbers //*crossed fingers* there are no dupes of results :/
    defer _ = equations.deinit();

    var calibration_result: u64 = 0;

    var line_count: usize = 0;

    // get all equations into data structure for analysis
    var lines = std.mem.splitScalar(u8, input, '\n');
    while (lines.next()) |line| {
        line_count += 1;
        std.debug.print("working on line: {d}. Time elapsed: {d} ns\n", .{ line_count, timer.read() });

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

        // std.debug.print("parsed_nums: {d}\n", .{equation_numbers.items});

        // loop over every operator, modifying one by one
        // ex. 1 + 1 + 1, then 1 + 1 - 1, then 1 + 1 / 1, etc
        const total_operator_positions = equation_numbers.items.len - 1; // 2 if [1, 1, 1]

        // std.debug.print("operators in before modification: {any}\n", .{operators.items});

        // create operations list to go through later
        var operations_list = ArrayList([]u8).init(allocator);
        defer _ = operations_list.deinit();

        var operators = ArrayList(u8).init(allocator);
        defer _ = operators.deinit();

        // create initial operators to be modified in place
        const needed_op_lists = std.math.pow(usize, 4, total_operator_positions);
        for (0..needed_op_lists) |_| {
            for (0..total_operator_positions) |_| {
                try operators.append('+');
            }

            try operations_list.append(try operators.toOwnedSlice());
        }

        // for (operations_list.items) |op_list| {
        //     std.debug.print("op_list: {c}\n", .{op_list});
        // }

        // want to continuously loop over the created
        // ex. loop 1 = +++ and *++
        // loop 2 = +*+, **+ in addition to existing +++, *++
        // loop 3 = +**, *** in addition to existing, +++, *++, +*+, **+

        // what about for 4?
        // ++++ and *+++
        // +*++ and **++
        // +**+ and ***+
        // +*** and ****
        // but missing +*+* and *+*+ and ++*+ and **+*

        // so how do we get
        // ++++ and *+++
        // +*++ and **++

        // ++*+ and *+*+ and +**+ and ***+

        // +++* and *++* and +*+* and **+* and ++** and *+** and +*** and ****
        // this is done by looping through all the previous ones and modifying each index to be the opposite of what it currently is
        // total loops is number of operations

        // manually create each list given the pattern needed, probably will fail for part 2, but mem leaks and seg faults be holding me back
        // ex.
        // individual_op_list: { +, +, +, +, +, + }
        // individual_op_list: { *, +, +, +, +, + }
        // individual_op_list: { +, *, +, +, +, + }
        // individual_op_list: { *, *, +, +, +, + }
        // individual_op_list: { +, +, *, +, +, + }
        // individual_op_list: { *, +, *, +, +, + }
        // individual_op_list: { +, *, *, +, +, + }
        // individual_op_list: { *, *, *, +, +, + }
        for (0..total_operator_positions) |op_index| {
            const change_op_interval = std.math.pow(usize, 4, op_index);
            // std.debug.print("change_op_interval: {d}\n", .{change_op_interval});
            var flip_count: usize = 0;
            var op: usize = 0;
            for (0..operations_list.items.len) |list_index| {
                if (flip_count == change_op_interval) {
                    op += 1;
                    if (op > 2) {
                        op = 0;
                    }
                    flip_count = 0;
                }
                flip_count += 1;

                // std.debug.print("should_flip: {d}\n", .{list_index % change_op_interval});
                if (op == 1) {
                    operations_list.items[list_index][op_index] = '*';
                } else if (op == 2) {
                    operations_list.items[list_index][op_index] = '|';
                }
            }
        }

        // // print to confirm ops list
        // for (operations_list.items) |op_list| {
        //     std.debug.print("op_list: {c}\n", .{op_list});
        // }

        // evaluate each op list to get a result and compare
        for (operations_list.items) |individual_op_list| {
            var intermediate_result: ?u64 = null;

            for (individual_op_list, 0..) |op, op_index| {
                // std.debug.print("equation_numbers.items: {d}\n", .{equation_numbers.items});
                // std.debug.print("individual_op_list.items: {any}\n", .{individual_op_list});
                switch (op) {
                    '*' => {
                        if (op_index == 0) {
                            intermediate_result = equation_numbers.items[op_index] * equation_numbers.items[op_index + 1];
                        } else {
                            // const mul = @mulWithOverflow(intermediate_result.?, equation_numbers.items[op_index + 1]);
                            // if (mul[1] == 1) {
                            //     std.debug.print("Oops! we had an overflow multiplying\n", .{});
                            // } else {
                            //     intermediate_result = mul[0];
                            // }

                            intermediate_result.? *%= equation_numbers.items[op_index + 1];
                        }
                        // std.debug.print("intermediate result {?d} found by {d} * {d}\n", .{ intermediate_result, equation_numbers.items[op_index], equation_numbers.items[op_index + 1] });
                    },
                    '+' => {
                        if (op_index == 0) {
                            intermediate_result = equation_numbers.items[op_index] + equation_numbers.items[op_index + 1];
                        } else {
                            intermediate_result.? += equation_numbers.items[op_index + 1];
                        }
                        // std.debug.print("intermediate result {?d} found by {d} + {d}\n", .{ intermediate_result, equation_numbers.items[op_index], equation_numbers.items[op_index + 1] });
                    },
                    '|' => {
                        var left_num = try std.fmt.allocPrint(gpa.allocator(), "{d}", .{equation_numbers.items[op_index]});
                        if (intermediate_result != null) {
                            left_num = try std.fmt.allocPrint(gpa.allocator(), "{d}", .{intermediate_result.?});
                        }

                        const right_num = try std.fmt.allocPrint(gpa.allocator(), "{d}", .{equation_numbers.items[op_index + 1]});

                        var combined = ArrayList(u8).init(allocator);
                        defer _ = combined.deinit();

                        try combined.appendSlice(left_num);
                        try combined.appendSlice(right_num);

                        const combined_num = try std.fmt.parseInt(u64, combined.items, 10);
                        // std.debug.print("combined_num: {any}\n", .{combined_num});

                        intermediate_result = combined_num;
                    },
                    else => {
                        // do nothing
                    },
                }
            }
            if (result == intermediate_result) {
                calibration_result += result;
                break; // just one proper result to make the line count
            }
        }
    }

    // std.debug.print("\n------\n\n", .{});

    return calibration_result;
}

test "simple test" {
    const calibration_result = try get_total_calibration_result("./test_input.txt");
    try std.testing.expectEqual(@as(u64, 11387), calibration_result);
}

test "simple test 2" {
    const calibration_result = try get_total_calibration_result("./test_input_2.txt");
    try std.testing.expectEqual(@as(u64, 194558), calibration_result);
}

test "simple test 3" {
    const calibration_result = try get_total_calibration_result("./test_input_3.txt");
    try std.testing.expectEqual(@as(u64, 156), calibration_result);
}

test "simple test 4" {
    const calibration_result = try get_total_calibration_result("./test_input_4.txt");
    try std.testing.expectEqual(@as(u64, 7290), calibration_result);
}

test "simple test 5" {
    const calibration_result = try get_total_calibration_result("./test_input_5.txt");
    try std.testing.expectEqual(@as(u64, 192), calibration_result);
}

test "simple test 6" {
    const calibration_result = try get_total_calibration_result("./test_input_6.txt");
    try std.testing.expectEqual(@as(u64, 60397606), calibration_result);
}

test "simple test 7" {
    const calibration_result = try get_total_calibration_result("./test_input_7.txt");
    try std.testing.expectEqual(@as(u64, 8088777769), calibration_result);
}

test "simple test solo" {
    const calibration_result = try get_total_calibration_result("./test_input_solo.txt");
    try std.testing.expectEqual(@as(u64, 190), calibration_result);
}

test "simple test 3 operands" {
    const calibration_result = try get_total_calibration_result("./test_input_3_operands.txt");
    try std.testing.expectEqual(@as(u64, 3267), calibration_result);
}

test "simple test 4 operands" {
    const calibration_result = try get_total_calibration_result("./test_input_4_operands.txt");
    try std.testing.expectEqual(@as(u64, 292), calibration_result);
}
