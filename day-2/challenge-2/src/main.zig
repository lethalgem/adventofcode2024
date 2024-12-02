const std = @import("std");

const ArrayList = std.ArrayList;

// 1. parse line by line
// 2. parse each line with delimiter ' '
// 3. parse tokens as ints
// 4. iterate through the array of the numbers in the line
// 5. check on each item ahead and current item, look at difference (must be between 1 and 3), look at ascending or descending (flag based on first analysis)
// 6. keep count of safe reports

pub fn main() !void {
    const safe_reports = try get_safe_report_count("./input.txt");
    std.debug.print("safe reports: {d} ", .{safe_reports});
}

fn get_safe_report_count(comptime path: []const u8) !u32 {
    const input = @embedFile(path);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var report = ArrayList(i32).init(allocator);
    defer report.deinit();

    var safe_report_count: u32 = 0;

    var reports = std.mem.splitScalar(u8, input, '\n');
    while (reports.next()) |token| {

        // create arraylist of levels for the line
        var level_tokens = std.mem.tokenizeScalar(u8, token, ' ');

        var i: i32 = 0;
        while (level_tokens.next()) |location_id| : (i += 1) {
            const level = try std.fmt.parseInt(i32, location_id, 10);
            try report.append(level);
        }

        // check if the report is safe, skip the moment it's not
        var previous_level: i32 = 0;
        var is_ascending: bool = false;
        var is_descending: bool = false;
        const len = report.items.len;

        std.debug.print("\ntesting report {any} \n", .{report.items});

        for (try report.toOwnedSlice(), 0..) |level, index| {
            if (index == 0) {
                previous_level = level;
                continue;
            }

            const difference: i32 = level - previous_level;

            // make sure the difference between levels is acceptable
            if (@abs(difference) > 3 or difference == 0) {
                std.debug.print("found unsafe report with too much difference: {d} and {d} \n", .{ level, previous_level });
                break;
            }

            // establish the list sorting to maintain for all future levels
            if (index == 1) {
                if (difference > 0) {
                    is_ascending = true;
                } else if (difference < 0) {
                    is_descending = true;
                }
            } else {
                if (difference > 0 and is_descending) {
                    std.debug.print("found unsafe report with not descending: {d} and {d}, difference of {d} \n", .{ level, previous_level, difference });

                    break;
                } else if (difference < 0 and is_ascending) {
                    std.debug.print("found unsafe report with not ascending: {d} and {d}, difference of {d} \n", .{ level, previous_level, difference });

                    break;
                }
            }

            // we've reached the end of the list, it's safe
            if (index == len - 1) {
                std.debug.print("report found safe \n", .{});

                safe_report_count += 1;
            }

            previous_level = level;
        }
    }

    return safe_report_count;
}

test "simple test" {
    const safe_reports = try get_safe_report_count("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 2), safe_reports);
}
