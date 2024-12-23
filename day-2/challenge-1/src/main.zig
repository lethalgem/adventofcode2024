const std = @import("std");

const ArrayList = std.ArrayList;

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
        var dampener_activated = false;

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
                if (handle_dampener(&dampener_activated, index, len, &safe_report_count)) break;
                continue;
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
                    if (handle_dampener(&dampener_activated, index, len, &safe_report_count)) break;
                    continue;
                } else if (difference < 0 and is_ascending) {
                    std.debug.print("found unsafe report with not ascending: {d} and {d}, difference of {d} \n", .{ level, previous_level, difference });
                    if (handle_dampener(&dampener_activated, index, len, &safe_report_count)) break;
                    continue;
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

fn handle_dampener(dampener_activated: *bool, index: usize, len: usize, safe_report_count: *u32) bool {
    if (dampener_activated.*) {
        return true;
    } else {
        if (index == len - 1) {
            std.debug.print("report found safe \n", .{});
            safe_report_count.* += 1;
        }
        dampener_activated.* = true;
        return false;
    }
}

test "simple test" {
    const safe_reports = try get_safe_report_count("./test_input.txt");
    try std.testing.expectEqual(@as(u32, 4), safe_reports);
}
